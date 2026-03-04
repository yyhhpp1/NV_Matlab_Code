function [ok, message, result] = overnight_stabilize_temperature(TtargetK, cfg)
%OVERNIGHT_STABILIZE_TEMPERATURE Hold one setpoint overnight with adaptive PID.
%   [ok, message, result] = overnight_stabilize_temperature(TtargetK, cfg)
%
% Purpose
%   Keep a constant temperature using conventional PID mode and periodically
%   adjust (K, Ti, Td) based on rolling stability metrics.
%
% Important parameter meaning in this function
%   PID fields are interpreted as conventional coefficients:
%     P -> K
%     I -> Ti
%     D -> Td
%
% Required cfg fields:
%   tcIp
%   initialPid struct: .P .I .D   (K, Ti, Td)
%   pidBounds struct: Pmin,Pmax,Imin,Imax,Dmin,Dmax
%
% Optional cfg fields:
%   heaterNr                (default 4)
%   controlChannel          (default 8)
%   safetyChannel           (default 3)
%   T_safe_max              (default inf, disables safety gate when inf)
%   durationSec             (default 10*3600)
%   pollSec                 (default 2.0)
%   evalWindowSec           (default 600)
%   lookbackMin             (default 5)
%   commRetryCount          (default 3)
%   commRetryBackoffSec     (default 0.5)
%   verifyTol               (default 1e-12)
%   pidMin                  (default 0)
%   verifyRetryWithMinClamp (default true)
%   pidModeValue            (default 1)
%   controlAlgorithm        (default 1)
%   errBandK                (default 0.002)
%   stdBandK                (default 0.003)
%   slopeBandKPerMin        (default 5e-4)
%   adjustFracK             (default 0.10)
%   adjustFracTi            (default 0.10)
%   adjustFracTd            (default 0.05)
%   maxAdjustFrac           (default 0.30)
%   minApplyIntervalSec     (default 300)
%   logRoot                 (default pwd)
%   logPrefix               (default 'Temp_Overnight')
%   verbose                 (default true)

ok = false;
message = '';
result = struct();

if nargin < 2 || ~isstruct(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

result.startedAt = now_stamp();
result.endedAt = '';
result.ok = false;
result.message = '';
result.targetK = TtargetK;
result.config = cfg;
result.runFolder = '';
result.sampleLogPath = '';
result.tuneLogPath = '';
result.samples = repmat(struct('tNow','', 'tSec',NaN, 'T_K',NaN, 'Tsafe_K',NaN), 0, 1);
result.evaluations = repmat(new_eval_record(), 0, 1);
result.pidInitial = new_pid(NaN, NaN, NaN);
result.pidFinal = new_pid(NaN, NaN, NaN);
result.pidFinalVerified = new_pid(NaN, NaN, NaN);
result.abortReason = '';

[valid, errMsg, cfg, pidNow] = validate_inputs(TtargetK, cfg);
if ~valid
    message = errMsg;
    result.message = message;
    result.abortReason = message;
    result.endedAt = now_stamp();
    return;
end
result.config = cfg;
result.pidInitial = pidNow;

[okFolder, runFolder, sampleLogPath, tuneLogPath, msgFolder] = setup_log_paths(cfg);
if ~okFolder
    message = msgFolder;
    result.message = message;
    result.abortReason = message;
    result.endedAt = now_stamp();
    return;
end
result.runFolder = runFolder;
result.sampleLogPath = sampleLogPath;
result.tuneLogPath = tuneLogPath;

[okLogs, msgLogs] = init_logs(sampleLogPath, tuneLogPath);
if ~okLogs
    message = msgLogs;
    result.message = message;
    result.abortReason = message;
    result.endedAt = now_stamp();
    return;
end

vlog(cfg, 'Run folder: %s', runFolder);
vlog(cfg, 'Target=%.6g K, duration=%.0f s, start PID[K,Ti,Td]=[%.6g %.6g %.6g]', ...
    TtargetK, cfg.durationSec, pidNow.P, pidNow.I, pidNow.D);

% Apply initial PID at fixed setpoint.
[okApply0, msgApply0, outApply0] = apply_pid_verified(cfg, TtargetK, pidNow);
if ~okApply0
    [~, offMsg] = heater_off(cfg);
    message = sprintf('Failed to apply initial PID: %s. Heater OFF: %s', msgApply0, offMsg);
    result.message = message;
    result.abortReason = message;
    result.endedAt = now_stamp();
    return;
end
pidNow = effective_pid_from_verify(outApply0, pidNow);

tStart = tic;
tLastApply = -inf;
nextEvalSec = cfg.evalWindowSec;

while toc(tStart) <= cfg.durationSec
    tSec = toc(tStart);

    [okReadT, TK, tStr, msgReadT] = read_temp_with_retry(cfg, cfg.controlChannel);
    if ~okReadT
        [~, offMsg] = heater_off(cfg);
        message = sprintf('Control channel read failed: %s. Heater OFF: %s', msgReadT, offMsg);
        result.message = message;
        result.abortReason = message;
        result.endedAt = now_stamp();
        return;
    end

    Tsafe = NaN;
    if isfinite(cfg.T_safe_max)
        [okReadS, Tsafe, ~, msgReadS] = read_temp_with_retry(cfg, cfg.safetyChannel);
        if ~okReadS
            [~, offMsg] = heater_off(cfg);
            message = sprintf('Safety channel read failed: %s. Heater OFF: %s', msgReadS, offMsg);
            result.message = message;
            result.abortReason = message;
            result.endedAt = now_stamp();
            return;
        end
        if Tsafe > cfg.T_safe_max
            [~, offMsg] = heater_off(cfg);
            message = sprintf('Safety limit exceeded: CH:%d %.6g K > %.6g K. Heater OFF: %s', ...
                cfg.safetyChannel, Tsafe, cfg.T_safe_max, offMsg);
            result.message = message;
            result.abortReason = message;
            result.endedAt = now_stamp();
            return;
        end
    end

    srow = struct('tNow', tStr, 'tSec', tSec, 'T_K', TK, 'Tsafe_K', Tsafe);
    result.samples(end + 1, 1) = srow; %#ok<AGROW>
    append_sample_log(sampleLogPath, srow, pidNow);

    while tSec >= nextEvalSec
        evalRec = new_eval_record();
        evalRec.tNow = now_stamp();
        evalRec.tSec = tSec;
        evalRec.pidBefore = pidNow;

        [okWin, win, msgWin] = extract_window(result.samples, tSec, cfg.evalWindowSec);
        if ~okWin
            evalRec.status = 'skip';
            evalRec.action = 'none';
            evalRec.message = msgWin;
            result.evaluations(end + 1, 1) = evalRec; %#ok<AGROW>
            append_tune_log(tuneLogPath, evalRec);
            nextEvalSec = nextEvalSec + cfg.evalWindowSec;
            continue;
        end

        [metrics, okMetrics] = compute_window_metrics(win.tSec, win.T_K, TtargetK);
        if ~okMetrics
            evalRec.status = 'skip';
            evalRec.action = 'none';
            evalRec.message = 'Window metric computation failed.';
            result.evaluations(end + 1, 1) = evalRec; %#ok<AGROW>
            append_tune_log(tuneLogPath, evalRec);
            nextEvalSec = nextEvalSec + cfg.evalWindowSec;
            continue;
        end

        evalRec.meanT = metrics.meanT;
        evalRec.stdT = metrics.stdT;
        evalRec.meanErrK = metrics.meanErrK;
        evalRec.slopeKPerMin = metrics.slopeKPerMin;

        [pidProposed, action, reason] = propose_pid_update(pidNow, metrics, cfg);
        pidProposed = clamp_pid(pidProposed, cfg.pidBounds);
        evalRec.pidProposed = pidProposed;
        evalRec.action = action;
        evalRec.reason = reason;

        canApply = (tSec - tLastApply) >= cfg.minApplyIntervalSec;
        changed = pid_changed(pidNow, pidProposed);
        if changed && canApply
            [okApply, msgApply, outApply] = apply_pid_verified(cfg, TtargetK, pidProposed);
            evalRec.applyOk = okApply;
            evalRec.applyMessage = msgApply;
            if ~okApply
                [~, offMsg] = heater_off(cfg);
                message = sprintf('PID update failed (%s). Heater OFF: %s', msgApply, offMsg);
                result.message = message;
                result.abortReason = message;
                evalRec.status = 'fatal';
                result.evaluations(end + 1, 1) = evalRec; %#ok<AGROW>
                append_tune_log(tuneLogPath, evalRec);
                result.endedAt = now_stamp();
                return;
            end
            pidNow = effective_pid_from_verify(outApply, pidProposed);
            evalRec.pidApplied = pidNow;
            evalRec.status = 'applied';
            tLastApply = tSec;
            vlog(cfg, 'Tune applied at %.0fs: action=%s K/ Ti/ Td -> [%.6g %.6g %.6g] | meanErr=%.6gK std=%.6gK slope=%.6gK/min', ...
                tSec, action, pidNow.P, pidNow.I, pidNow.D, metrics.meanErrK, metrics.stdT, metrics.slopeKPerMin);
        elseif changed && ~canApply
            evalRec.status = 'deferred';
            evalRec.applyMessage = sprintf('Deferred by minApplyIntervalSec=%.0f', cfg.minApplyIntervalSec);
        else
            evalRec.status = 'hold';
            evalRec.applyMessage = 'No PID update needed.';
        end

        result.evaluations(end + 1, 1) = evalRec; %#ok<AGROW>
        append_tune_log(tuneLogPath, evalRec);
        nextEvalSec = nextEvalSec + cfg.evalWindowSec;
    end

    pause(max(0.01, cfg.pollSec));
end

ok = true;
message = sprintf('Overnight stabilization complete at target %.6g K.', TtargetK);
result.ok = true;
result.message = message;
result.pidFinal = pidNow;
result.pidFinalVerified = pidNow;
result.endedAt = now_stamp();
vlog(cfg, '%s', message);
end

function [ok, message, out] = apply_pid_verified(cfg, targetK, pid)
cfgSet = struct( ...
    'setpointK', targetK, ...
    'pidP', pid.P, ...
    'pidI', pid.I, ...
    'pidD', pid.D, ...
    'pidMode', cfg.pidModeValue, ...
    'controlAlgorithm', cfg.controlAlgorithm);

cfgVerify = struct( ...
    'heaterNr', cfg.heaterNr, ...
    'verifyTol', cfg.verifyTol, ...
    'pidMin', cfg.pidMin, ...
    'verifyRetryWithMinClamp', cfg.verifyRetryWithMinClamp, ...
    'commRetryCount', cfg.commRetryCount, ...
    'commRetryBackoffSec', cfg.commRetryBackoffSec, ...
    'verbose', cfg.verbose);

[ok, message, out] = bf_tc_set_heater4_verified(cfg.tcIp, true, cfgSet, cfgVerify);
end

function [ok, message] = heater_off(cfg)
cfgVerify = struct( ...
    'heaterNr', cfg.heaterNr, ...
    'commRetryCount', cfg.commRetryCount, ...
    'commRetryBackoffSec', cfg.commRetryBackoffSec, ...
    'verbose', cfg.verbose);
[ok, message] = bf_tc_set_heater4_verified(cfg.tcIp, false, struct(), cfgVerify);
end

function pidOut = effective_pid_from_verify(outVerify, fallbackPid)
pidOut = fallbackPid;
if ~isstruct(outVerify)
    return;
end
if isfield(outVerify, 'usedClampRetry') && logical(outVerify.usedClampRetry) && ...
        isfield(outVerify, 'pidReadback2') && has_finite_pid(outVerify.pidReadback2)
    pidOut = outVerify.pidReadback2;
    return;
end
if isfield(outVerify, 'pidReadback1') && has_finite_pid(outVerify.pidReadback1)
    pidOut = outVerify.pidReadback1;
end
end

function [okRead, TK, tStr, msgRead] = read_temp_with_retry(cfg, channelNr)
okRead = false;
TK = NaN;
tStr = '';
msgRead = 'unknown';
for k = 1:cfg.commRetryCount
    [ok1, t1, tdt, msg1] = bf_tc_read_latest_channel(cfg.tcIp, channelNr, cfg.lookbackMin);
    if ok1
        okRead = true;
        TK = t1;
        tStr = char(tdt);
        msgRead = '';
        return;
    end
    msgRead = msg1;
    if k < cfg.commRetryCount
        pause(max(0, cfg.commRetryBackoffSec));
    end
end
end

function [ok, win, msg] = extract_window(samples, tNow, windowSec)
ok = false;
msg = '';
win = struct('tSec', [], 'T_K', []);
if isempty(samples)
    msg = 'No samples yet.';
    return;
end
tAll = [samples.tSec].';
TAll = [samples.T_K].';
idx = tAll >= (tNow - windowSec);
if nnz(idx) < 8
    msg = 'Not enough samples in evaluation window.';
    return;
end
win.tSec = tAll(idx);
win.T_K = TAll(idx);
ok = true;
end

function [metrics, ok] = compute_window_metrics(tSec, TK, targetK)
ok = false;
metrics = struct('meanT', NaN, 'stdT', NaN, 'meanErrK', NaN, 'slopeKPerMin', NaN);
if numel(tSec) < 5 || numel(TK) < 5
    return;
end
metrics.meanT = mean(TK);
metrics.stdT = std(TK);
metrics.meanErrK = targetK - metrics.meanT;
t0 = tSec - tSec(1);
if numel(unique(t0)) < 2
    return;
end
p = polyfit(t0, TK, 1); % K/s
metrics.slopeKPerMin = p(1) * 60;
ok = true;
end

function [pidNew, action, reason] = propose_pid_update(pidNow, metrics, cfg)
pidNew = pidNow;
action = 'none';
reason = '';

e = metrics.meanErrK;
stdT = metrics.stdT;
slope = metrics.slopeKPerMin;

if stdT > cfg.stdBandK
    pidNew.P = pidNow.P * (1 - cfg.adjustFracK);
    pidNew.I = pidNow.I * (1 + cfg.adjustFracTi);
    pidNew.D = pidNow.D * (1 + cfg.adjustFracTd);
    action = 'damp_oscillation';
    reason = sprintf('std %.6g > %.6g', stdT, cfg.stdBandK);
    return;
end

if abs(e) > cfg.errBandK
    if e > 0
        % Too cold: stronger heating loop.
        pidNew.P = pidNow.P * (1 + cfg.adjustFracK);
        pidNew.I = pidNow.I * (1 - cfg.adjustFracTi);
    else
        % Too warm: weaker loop.
        pidNew.P = pidNow.P * (1 - cfg.adjustFracK);
        pidNew.I = pidNow.I * (1 + cfg.adjustFracTi);
    end
    action = 'correct_offset';
    reason = sprintf('|meanErr| %.6g > %.6g', abs(e), cfg.errBandK);
    return;
end

if abs(slope) > cfg.slopeBandKPerMin
    if slope > 0
        % Upward drift.
        pidNew.I = pidNow.I * (1 + 0.5 * cfg.adjustFracTi);
    else
        % Downward drift.
        pidNew.I = pidNow.I * (1 - 0.5 * cfg.adjustFracTi);
    end
    action = 'trim_drift';
    reason = sprintf('|slope| %.6g > %.6g K/min', abs(slope), cfg.slopeBandKPerMin);
end
end

function tf = pid_changed(a, b)
tol = 1e-12;
tf = abs(a.P - b.P) > tol || abs(a.I - b.I) > tol || abs(a.D - b.D) > tol;
end

function pidOut = clamp_pid(pidIn, bounds)
pidOut = new_pid( ...
    min(max(pidIn.P, bounds.Pmin), bounds.Pmax), ...
    min(max(pidIn.I, bounds.Imin), bounds.Imax), ...
    min(max(pidIn.D, bounds.Dmin), bounds.Dmax));
end

function tf = has_finite_pid(pid)
tf = isstruct(pid) && isfield(pid,'P') && isfield(pid,'I') && isfield(pid,'D') && ...
    isnumeric(pid.P) && isnumeric(pid.I) && isnumeric(pid.D) && ...
    isscalar(pid.P) && isscalar(pid.I) && isscalar(pid.D) && ...
    isfinite(pid.P) && isfinite(pid.I) && isfinite(pid.D);
end

function pid = new_pid(P, I, D)
pid = struct('P', double(P), 'I', double(I), 'D', double(D));
end

function rec = new_eval_record()
rec = struct( ...
    'tNow', '', ...
    'tSec', NaN, ...
    'meanT', NaN, ...
    'stdT', NaN, ...
    'meanErrK', NaN, ...
    'slopeKPerMin', NaN, ...
    'pidBefore', new_pid(NaN, NaN, NaN), ...
    'pidProposed', new_pid(NaN, NaN, NaN), ...
    'pidApplied', new_pid(NaN, NaN, NaN), ...
    'action', '', ...
    'reason', '', ...
    'status', '', ...
    'applyOk', false, ...
    'applyMessage', '', ...
    'message', '');
end

function [ok, runFolder, sampleLogPath, tuneLogPath, msg] = setup_log_paths(cfg)
ok = false;
runFolder = '';
sampleLogPath = '';
tuneLogPath = '';
msg = '';
try
    stamp = datestr(now, 'yyyymmdd_HHMMSS');
    runFolder = fullfile(char(cfg.logRoot), sprintf('%s_%s', char(cfg.logPrefix), stamp));
    if ~isfolder(runFolder)
        mkdir(runFolder);
    end
    sampleLogPath = fullfile(runFolder, 'sample_log.csv');
    tuneLogPath = fullfile(runFolder, 'tune_log.csv');
    ok = true;
catch ME
    msg = sprintf('Failed to create run folder: %s', ME.message);
end
end

function [ok, msg] = init_logs(sampleLogPath, tuneLogPath)
ok = false;
msg = '';

fid = fopen(sampleLogPath, 'w');
if fid < 0
    msg = sprintf('Cannot create sample log: %s', sampleLogPath);
    return;
end
cleanupA = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, 'timestamp,tSec,T_K,Tsafe_K,K,Ti,Td\n');

fid2 = fopen(tuneLogPath, 'w');
if fid2 < 0
    msg = sprintf('Cannot create tune log: %s', tuneLogPath);
    return;
end
cleanupB = onCleanup(@() fclose(fid2)); %#ok<NASGU>
fprintf(fid2, ['timestamp,tSec,status,action,reason,meanT,stdT,meanErrK,slopeKPerMin,' ...
    'K_before,Ti_before,Td_before,K_prop,Ti_prop,Td_prop,K_applied,Ti_applied,Td_applied,applyOk,applyMessage,message\n']);

ok = true;
end

function append_sample_log(path, srow, pid)
fid = fopen(path, 'a');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s,%.6f,%.12g,%.12g,%.12g,%.12g,%.12g\n', ...
    srow.tNow, srow.tSec, srow.T_K, srow.Tsafe_K, pid.P, pid.I, pid.D);
end

function append_tune_log(path, rec)
fid = fopen(path, 'a');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s,%.6f,%s,%s,"%s",%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%.12g,%d,"%s","%s"\n', ...
    rec.tNow, rec.tSec, csv_token(rec.status), csv_token(rec.action), sanitize_csv_text(rec.reason), ...
    rec.meanT, rec.stdT, rec.meanErrK, rec.slopeKPerMin, ...
    rec.pidBefore.P, rec.pidBefore.I, rec.pidBefore.D, ...
    rec.pidProposed.P, rec.pidProposed.I, rec.pidProposed.D, ...
    rec.pidApplied.P, rec.pidApplied.I, rec.pidApplied.D, ...
    logical_to_num(rec.applyOk), sanitize_csv_text(rec.applyMessage), sanitize_csv_text(rec.message));
end

function cfg = apply_defaults(cfg)
cfg = set_default(cfg, 'heaterNr', 4);
cfg = set_default(cfg, 'controlChannel', 8);
cfg = set_default(cfg, 'safetyChannel', 3);
cfg = set_default(cfg, 'T_safe_max', inf);
cfg = set_default(cfg, 'durationSec', 10 * 3600);
cfg = set_default(cfg, 'pollSec', 2.0);
cfg = set_default(cfg, 'evalWindowSec', 600);
cfg = set_default(cfg, 'lookbackMin', 5);
cfg = set_default(cfg, 'commRetryCount', 3);
cfg = set_default(cfg, 'commRetryBackoffSec', 0.5);
cfg = set_default(cfg, 'verifyTol', 1e-12);
cfg = set_default(cfg, 'pidMin', 0);
cfg = set_default(cfg, 'verifyRetryWithMinClamp', true);
cfg = set_default(cfg, 'pidModeValue', 1);
cfg = set_default(cfg, 'controlAlgorithm', 1);
cfg = set_default(cfg, 'errBandK', 0.002);
cfg = set_default(cfg, 'stdBandK', 0.003);
cfg = set_default(cfg, 'slopeBandKPerMin', 5e-4);
cfg = set_default(cfg, 'adjustFracK', 0.10);
cfg = set_default(cfg, 'adjustFracTi', 0.10);
cfg = set_default(cfg, 'adjustFracTd', 0.05);
cfg = set_default(cfg, 'maxAdjustFrac', 0.30);
cfg = set_default(cfg, 'minApplyIntervalSec', 300);
cfg = set_default(cfg, 'logRoot', pwd);
cfg = set_default(cfg, 'logPrefix', 'Temp_Overnight');
cfg = set_default(cfg, 'verbose', true);
end

function [ok, errMsg, cfg, pidInit] = validate_inputs(TtargetK, cfg)
ok = false;
errMsg = '';
pidInit = new_pid(NaN, NaN, NaN);

required = {'tcIp', 'initialPid', 'pidBounds'};
for i = 1:numel(required)
    k = required{i};
    if ~isfield(cfg, k) || isempty(cfg.(k))
        errMsg = sprintf('Missing required cfg.%s.', k);
        return;
    end
end
if ~(isnumeric(TtargetK) && isscalar(TtargetK) && isfinite(TtargetK))
    errMsg = 'TtargetK must be a finite numeric scalar.';
    return;
end

[okPid, pidInit, msgPid] = parse_pid_struct(cfg.initialPid);
if ~okPid
    errMsg = sprintf('Invalid cfg.initialPid: %s', msgPid);
    return;
end

b = cfg.pidBounds;
bKeys = {'Pmin','Pmax','Imin','Imax','Dmin','Dmax'};
for i = 1:numel(bKeys)
    key = bKeys{i};
    if ~isfield(b, key) || ~(isnumeric(b.(key)) && isscalar(b.(key)) && isfinite(b.(key)))
        errMsg = sprintf('Missing/invalid cfg.pidBounds.%s.', key);
        return;
    end
end
if b.Pmin > b.Pmax || b.Imin > b.Imax || b.Dmin > b.Dmax
    errMsg = 'Invalid pidBounds ordering.';
    return;
end
if b.Imin <= 0
    errMsg = 'For conventional mode, cfg.pidBounds.Imin must be > 0 (Ti must be positive).';
    return;
end
cfg.pidBounds = b;
pidInit = clamp_pid(pidInit, cfg.pidBounds);
if pidInit.I <= 0
    errMsg = 'For conventional mode, cfg.initialPid.I (Ti) must be > 0.';
    return;
end

numKeys = {'heaterNr','controlChannel','safetyChannel','durationSec','pollSec', ...
    'evalWindowSec','lookbackMin','commRetryCount','commRetryBackoffSec','verifyTol','pidMin', ...
    'pidModeValue','controlAlgorithm','errBandK','stdBandK','slopeBandKPerMin', ...
    'adjustFracK','adjustFracTi','adjustFracTd','maxAdjustFrac','minApplyIntervalSec'};
for i = 1:numel(numKeys)
    key = numKeys{i};
    v = cfg.(key);
    if ~(isnumeric(v) && isscalar(v) && isfinite(v))
        errMsg = sprintf('cfg.%s must be numeric finite scalar.', key);
        return;
    end
end
if ~(isnumeric(cfg.T_safe_max) && isscalar(cfg.T_safe_max) && (isfinite(cfg.T_safe_max) || isinf(cfg.T_safe_max)))
    errMsg = 'cfg.T_safe_max must be numeric scalar (finite or inf).';
    return;
end
if cfg.T_safe_max < 0
    errMsg = 'cfg.T_safe_max must be >= 0.';
    return;
end

if cfg.durationSec <= 0 || cfg.pollSec <= 0 || cfg.evalWindowSec <= 0 || ...
        cfg.verifyTol <= 0 || cfg.pidMin < 0 || cfg.errBandK <= 0 || ...
        cfg.stdBandK <= 0 || cfg.slopeBandKPerMin <= 0 || cfg.minApplyIntervalSec <= 0
    errMsg = 'Timing/tolerance fields must be positive; pidMin must be >= 0.';
    return;
end
if cfg.evalWindowSec < max(30, 3 * cfg.pollSec)
    errMsg = 'cfg.evalWindowSec too small for stable window metrics.';
    return;
end
if cfg.maxAdjustFrac <= 0 || cfg.maxAdjustFrac > 1
    errMsg = 'cfg.maxAdjustFrac must be in (0,1].';
    return;
end
intKeys = {'heaterNr','controlChannel','safetyChannel','commRetryCount','pidModeValue','controlAlgorithm'};
for i = 1:numel(intKeys)
    key = intKeys{i};
    if mod(cfg.(key), 1) ~= 0
        errMsg = sprintf('cfg.%s must be an integer scalar.', key);
        return;
    end
end

cfg.adjustFracK = min(max(cfg.adjustFracK, 0), cfg.maxAdjustFrac);
cfg.adjustFracTi = min(max(cfg.adjustFracTi, 0), cfg.maxAdjustFrac);
cfg.adjustFracTd = min(max(cfg.adjustFracTd, 0), cfg.maxAdjustFrac);

if ~(ischar(cfg.tcIp) || isstring(cfg.tcIp))
    errMsg = 'cfg.tcIp must be string/char.';
    return;
end
if ~(ischar(cfg.logRoot) || isstring(cfg.logRoot) || isempty(cfg.logRoot))
    errMsg = 'cfg.logRoot must be string/char.';
    return;
end
if ~(ischar(cfg.logPrefix) || isstring(cfg.logPrefix))
    errMsg = 'cfg.logPrefix must be string/char.';
    return;
end

ok = true;
end

function [ok, pid, msg] = parse_pid_struct(s)
ok = false;
msg = '';
pid = new_pid(NaN, NaN, NaN);
if ~isstruct(s)
    msg = 'Must be a struct.';
    return;
end
keys = {'P','I','D'};
for i = 1:numel(keys)
    k = keys{i};
    if ~isfield(s, k) || ~(isnumeric(s.(k)) && isscalar(s.(k)) && isfinite(s.(k)))
        msg = sprintf('Missing/invalid field %s.', k);
        return;
    end
end
pid = new_pid(s.P, s.I, s.D);
ok = true;
end

function cfg = set_default(cfg, key, value)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = value;
end
end

function vlog(cfg, fmt, varargin)
if isfield(cfg, 'verbose') && cfg.verbose
    fprintf('[overnight_stabilize_temperature] %s\n', sprintf(fmt, varargin{:}));
end
end

function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end

function out = sanitize_csv_text(txt)
out = char(string(txt));
out = strrep(out, '"', '""');
out = strrep(out, sprintf('\n'), ' | ');
out = strrep(out, sprintf('\r'), ' ');
end

function out = csv_token(txt)
out = char(string(txt));
out = strrep(out, ',', ';');
end

function n = logical_to_num(v)
n = 0;
if ~isempty(v) && logical(v)
    n = 1;
end
end
