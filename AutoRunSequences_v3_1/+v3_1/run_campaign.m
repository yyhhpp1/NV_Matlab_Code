function [campaign, report] = run_campaign(campaign, runtimeCtx)
%RUN_CAMPAIGN Execute queued (B,T) jobs using v3.1 outer orchestration.
%
% This is backend architecture for queue execution. GUI callbacks should
% update campaign.runtimeControl and job ordering, then this runner applies
% those controls at safe boundaries.

if nargin < 2
    runtimeCtx = struct();
end
runtimeCtx = normalize_runtime_ctx(runtimeCtx);

campaign = ensure_queue_started(campaign);
campaign = sync_runtime_state(campaign, runtimeCtx);
campaign.isRunning = true;
campaign.stopRequested = false;
campaign.lastSavedAt = now_stamp();
v3_1.save_campaign_state(campaign);

report = struct( ...
    'campaignId', campaign.campaignId, ...
    'queueRoot', campaign.queueRoot, ...
    'startedAt', now_stamp(), ...
    'finishedAt', '', ...
    'jobsExecuted', 0 ...
);

while true
    drawnow;
    campaign = sync_runtime_state(campaign, runtimeCtx);

    if is_stop_requested(campaign.runtimeControl.stopMode)
        break;
    end

    idx = next_pending_enabled_job(campaign.jobs);
    if idx == 0
        break;
    end

    [campaign, attemptRec] = run_one_attempt(campaign, idx, runtimeCtx);
    report.jobsExecuted = report.jobsExecuted + 1;
    append_attempt_log_row(campaign.attemptLogPath, campaign, campaign.jobs(idx), attemptRec);
    v3_1.save_campaign_state(campaign);

    if is_stop_requested(campaign.runtimeControl.stopMode)
        break;
    end
end

campaign = sync_runtime_state(campaign, runtimeCtx);
campaign.isRunning = false;
campaign.currentJobId = '';
campaign.currentJobIndex = 0;
campaign.lastSavedAt = now_stamp();
v3_1.save_campaign_state(campaign);

v3_1.generate_final_sq_dq_log(campaign, campaign.finalLogPath);

report.finishedAt = now_stamp();
if strcmpi(campaign.runtimeControl.stopMode, 'none')
    report.finalState = 'finished';
else
    report.finalState = 'stopped';
end
end

function [campaign, attemptRec] = run_one_attempt(campaign, idx, runtimeCtx)
job = campaign.jobs(idx);
job.status.state = 'running';
job.status.lastTimestamp = now_stamp();
job.status.userDeclaredFailed = false;
job.status.userFailAction = 'none';
campaign.currentJobId = job.id;
campaign.currentJobIndex = idx;
campaign.jobs(idx) = job;
v3_1.save_campaign_state(campaign);

attemptIdx = numel(job.history) + 1;
attemptRec = struct( ...
    'attemptIdx', attemptIdx, ...
    'startedAt', now_stamp(), ...
    'endedAt', '', ...
    'outcome', '', ...
    'errorMessage', '', ...
    'runFolder', '', ...
    'sequenceRows', repmat(struct( ...
        'sequenceName', '', ...
        'date', '', ...
        'aveFigureName', '', ...
        'figurePath', ''), 0, 1) ...
);

runFolder = make_run_folder(campaign.queueRoot, job, attemptIdx);
attemptRec.runFolder = runFolder;

[okTB, errTB] = execute_setpoint_and_stabilization(job, runtimeCtx);
if ~okTB
    attemptRec.outcome = 'failed';
    attemptRec.errorMessage = errTB;
    attemptRec.endedAt = now_stamp();
    [campaign, job] = finalize_job_outcome(campaign, idx, job, attemptRec, false);
    campaign.jobs(idx) = job;
    return;
end

try
    v3_1.apply_profile_snapshot(runtimeCtx.handlesAuto, job.profile.snapshot);
catch ME
    attemptRec.outcome = 'failed';
    attemptRec.errorMessage = sprintf('apply_profile_snapshot failed: %s', ME.message);
    attemptRec.endedAt = now_stamp();
    [campaign, job] = finalize_job_outcome(campaign, idx, job, attemptRec, false);
    campaign.jobs(idx) = job;
    return;
end

[okRun, errRun] = execute_v2_1(runtimeCtx);
if okRun
    attemptRec.outcome = 'success';
    attemptRec.errorMessage = '';
else
    attemptRec.outcome = 'failed';
    attemptRec.errorMessage = errRun;
end
attemptRec.endedAt = now_stamp();
attemptRec.sequenceRows = discover_sequence_rows(runFolder);

campaign = sync_runtime_state(campaign, runtimeCtx);
[campaign, job] = apply_runtime_user_action(campaign, idx, job, attemptRec);
campaign.jobs(idx) = job;
end

function [campaign, job] = apply_runtime_user_action(campaign, idx, job, attemptRec)
forcedRedo = false;
forcedFail = false;
action = lower(char(campaign.runtimeControl.currentJobAction));

switch action
    case 'mark_failed_skip'
        forcedFail = true;
        attemptRec.outcome = 'failed_user_skip';
        attemptRec.errorMessage = join_error(attemptRec.errorMessage, 'User declared current job failed: skip.');
        job.status.userDeclaredFailed = true;
        job.status.userFailAction = 'skip';
        campaign.runtimeControl.currentJobAction = 'none';
    case 'mark_failed_redo'
        forcedFail = true;
        forcedRedo = true;
        attemptRec.outcome = 'failed_user_redo';
        attemptRec.errorMessage = join_error(attemptRec.errorMessage, 'User declared current job failed: redo.');
        job.status.userDeclaredFailed = true;
        job.status.userFailAction = 'redo';
        campaign.runtimeControl.currentJobAction = 'none';
    otherwise
end

[campaign, job] = finalize_job_outcome(campaign, idx, job, attemptRec, forcedRedo || ~forcedFail);

if forcedRedo
    maxOrder = max([campaign.jobs.order]);
    job.order = maxOrder + 1;
    job.status.state = 'pending';
    job.status.lastResult = 'redo_scheduled';
    campaign.jobs(idx) = job;
end
end

function [campaign, job] = finalize_job_outcome(campaign, idx, job, attemptRec, allowRetryPolicy)
job.status.attemptCount = job.status.attemptCount + 1;
job.status.lastTimestamp = now_stamp();
job.history(end + 1, 1) = attemptRec;

if strcmpi(attemptRec.outcome, 'success')
    job.status.state = 'success';
    job.status.lastResult = 'success';
else
    if allowRetryPolicy && should_retry(job)
        job.status.state = 'pending';
        job.status.lastResult = 'retry_pending';
    else
        job.status.state = 'failed';
        job.status.lastResult = attemptRec.outcome;
    end
end

job.status.userFailAction = 'none';
campaign.jobs(idx) = job;
campaign.lastSavedAt = now_stamp();
end

function tf = should_retry(job)
tf = false;
if ~isfield(job, 'runtime') || ~isfield(job.runtime, 'retry')
    return;
end
if ~isfield(job.runtime.retry, 'maxAttempts')
    return;
end
tf = job.status.attemptCount < job.runtime.retry.maxAttempts;
end

function [ok, errMsg] = execute_setpoint_and_stabilization(job, runtimeCtx)
ok = false;
errMsg = '';

[okT, msgT] = v3_1.set_temperature_placeholder(job.setpoint.T, runtimeCtx.placeholder);
if ~okT
    errMsg = sprintf('Temperature setpoint failed: %s', msgT);
    return;
end

[okB, msgB] = v3_1.set_field_placeholder(job.setpoint.B, runtimeCtx.placeholder);
if ~okB
    errMsg = sprintf('Field setpoint failed: %s', msgB);
    return;
end

[okWT, ~, msgWT] = v3_1.wait_temperature_stable_placeholder(job.setpoint.T, runtimeCtx.placeholder);
if ~okWT
    errMsg = sprintf('Temperature settle failed: %s', msgWT);
    return;
end

[okWB, ~, msgWB] = v3_1.wait_field_stable_placeholder(job.setpoint.B, runtimeCtx.placeholder);
if ~okWB
    errMsg = sprintf('Field settle failed: %s', msgWB);
    return;
end

ok = true;
end

function [ok, errMsg] = execute_v2_1(runtimeCtx)
ok = true;
errMsg = '';

if ~runtimeCtx.executeV21
    pause(0.01);
    return;
end

try
    runtimeCtx.v2Runner( ...
        runtimeCtx.hObjectA, ...
        runtimeCtx.eventdataA, ...
        runtimeCtx.handlesMain, ...
        runtimeCtx.handlesAuto ...
    );
catch ME
    ok = false;
    errMsg = ME.message;
end
end

function runFolder = make_run_folder(queueRoot, job, attemptIdx)
runsRoot = fullfile(queueRoot, 'Runs');
if ~isfolder(runsRoot)
    mkdir(runsRoot);
end
jobFolder = fullfile(runsRoot, sprintf('Job_%03d_%s', job.order, sanitize_name(job.id)));
if ~isfolder(jobFolder)
    mkdir(jobFolder);
end
runFolder = fullfile(jobFolder, sprintf('Attempt_%03d', attemptIdx));
if ~isfolder(runFolder)
    mkdir(runFolder);
end
end

function rows = discover_sequence_rows(runFolder)
rows = repmat(struct( ...
    'sequenceName', '', ...
    'date', '', ...
    'aveFigureName', '', ...
    'figurePath', ''), 0, 1);

if ~isfolder(runFolder)
    return;
end

exts = {'*.fig', '*.png', '*.jpg', '*.jpeg', '*.pdf'};
allFiles = [];
for i = 1:numel(exts)
    allFiles = [allFiles; dir(fullfile(runFolder, '**', exts{i}))]; %#ok<AGROW>
end
for i = 1:numel(allFiles)
    name = allFiles(i).name;
    lowerName = lower(name);
    if contains(lowerName, 'rough')
        continue;
    end
    seq = '';
    if contains(name, 'T1_S00_S01_S10')
        seq = 'T1_S00_S01_S10';
    elseif contains(name, 'T1_S11_S1m1')
        seq = 'T1_S11_S1m1';
    end
    if isempty(seq)
        continue;
    end

    row = struct();
    row.sequenceName = seq;
    row.date = datestr(allFiles(i).datenum, 'yyyy-mm-dd HH:MM:SS');
    row.aveFigureName = name;
    row.figurePath = fullfile(allFiles(i).folder, name);
    rows(end + 1, 1) = row; %#ok<AGROW>
end
end

function append_attempt_log_row(csvPath, campaign, job, attemptRec)
row = { ...
    campaign.campaignId, ...
    job.id, ...
    attemptRec.attemptIdx, ...
    job.setpoint.B, ...
    job.setpoint.T, ...
    attemptRec.startedAt, ...
    attemptRec.endedAt, ...
    attemptRec.outcome, ...
    sanitize_csv_text(attemptRec.errorMessage), ...
    attemptRec.runFolder ...
};

fid = fopen(csvPath, 'a');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s\n', csv_line(row));
end

function line = csv_line(cellsRow)
parts = cell(1, numel(cellsRow));
for i = 1:numel(cellsRow)
    value = cellsRow{i};
    if isnumeric(value)
        token = num2str(value, 16);
    elseif isstring(value)
        token = char(value);
    elseif ischar(value)
        token = value;
    else
        token = evalc('disp(value)');
        token = strtrim(token);
    end
    token = strrep(token, '"', '""');
    parts{i} = ['"' token '"'];
end
line = strjoin(parts, ',');
end

function tf = is_stop_requested(stopMode)
tf = strcmpi(stopMode, 'stop_queue') || strcmpi(stopMode, 'stop_all');
end

function idx = next_pending_enabled_job(jobs)
idx = 0;
if isempty(jobs)
    return;
end
enabledPending = find(arrayfun(@(j) j.enabled && strcmpi(j.status.state, 'pending'), jobs));
if isempty(enabledPending)
    return;
end
[~, localMinIdx] = min(arrayfun(@(k) jobs(k).order, enabledPending));
idx = enabledPending(localMinIdx);
end

function campaign = ensure_queue_started(campaign)
if ~isfield(campaign, 'queueRoot') || isempty(campaign.queueRoot) || ~isfolder(campaign.queueRoot)
    campaign = v3_1.start_queue_run(campaign);
end
end

function campaign = sync_runtime_state(campaign, runtimeCtx)
if isa(runtimeCtx.pullCampaignFcn, 'function_handle')
    try
        pulled = runtimeCtx.pullCampaignFcn();
        if isstruct(pulled)
            if isfield(pulled, 'runtimeControl')
                campaign.runtimeControl = pulled.runtimeControl;
            end
            if isfield(pulled, 'jobs')
                campaign.jobs = pulled.jobs;
            end
        end
    catch
    end
end
end

function name = sanitize_name(name)
name = regexprep(char(name), '[^a-zA-Z0-9_\-]', '_');
end

function txt = sanitize_csv_text(txt)
txt = strrep(char(txt), sprintf('\n'), ' | ');
txt = strrep(txt, sprintf('\r'), ' ');
end

function msg = join_error(oldMsg, addMsg)
if isempty(oldMsg)
    msg = addMsg;
else
    msg = [oldMsg ' | ' addMsg];
end
end

function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end

function runtimeCtx = normalize_runtime_ctx(runtimeCtx)
if ~isfield(runtimeCtx, 'executeV21')
    runtimeCtx.executeV21 = false;
end
if ~isfield(runtimeCtx, 'placeholder') || isempty(runtimeCtx.placeholder)
    runtimeCtx.placeholder = struct();
end
if ~isfield(runtimeCtx, 'v2Runner') || isempty(runtimeCtx.v2Runner)
    runtimeCtx.v2Runner = @t1_semi_auto_program_v3_1;
end
if ~isfield(runtimeCtx, 'hObjectA'), runtimeCtx.hObjectA = []; end
if ~isfield(runtimeCtx, 'eventdataA'), runtimeCtx.eventdataA = []; end
if ~isfield(runtimeCtx, 'handlesMain'), runtimeCtx.handlesMain = struct(); end
if ~isfield(runtimeCtx, 'handlesAuto'), runtimeCtx.handlesAuto = struct(); end
if ~isfield(runtimeCtx, 'pullCampaignFcn'), runtimeCtx.pullCampaignFcn = []; end
end
