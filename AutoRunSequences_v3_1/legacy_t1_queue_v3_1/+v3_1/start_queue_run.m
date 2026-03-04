function campaign = start_queue_run(campaign)
%START_QUEUE_RUN Create a new queue root folder for this run and initialize logs.

validate_campaign(campaign);

if ~isfolder(campaign.saveRoot)
    mkdir(campaign.saveRoot);
end

queueName = sprintf('Queue_%s_%s', datestr(now, 'yyyymmdd_HHMMSS'), campaign.campaignId);
queueRoot = fullfile(campaign.saveRoot, queueName);
mkdir(queueRoot);
mkdir(fullfile(queueRoot, 'Runs'));

campaign.queueRoot = queueRoot;
campaign.queueStatePath = fullfile(queueRoot, 'queue_state.mat');
campaign.attemptLogPath = fullfile(queueRoot, 'queue_attempt_log.csv');
campaign.finalLogPath = fullfile(queueRoot, 'final_sq_dq_log.csv');
campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');

v3_1.save_campaign_state(campaign);
write_attempt_log_header(campaign.attemptLogPath);
end

function validate_campaign(campaign)
if ~isstruct(campaign)
    error('SmartT1:v3_1:InvalidCampaign', 'Campaign must be a struct.');
end
if ~isfield(campaign, 'saveRoot') || isempty(campaign.saveRoot)
    error('SmartT1:v3_1:InvalidCampaign', 'Campaign saveRoot is missing.');
end
if ~isfield(campaign, 'campaignId') || isempty(campaign.campaignId)
    error('SmartT1:v3_1:InvalidCampaign', 'Campaign campaignId is missing.');
end
end

function write_attempt_log_header(csvPath)
headers = { ...
    'campaignId', 'jobId', 'attemptIdx', ...
    'B_set', 'T_set', 'startedAt', 'endedAt', ...
    'outcome', 'errorMessage', 'runFolder' ...
};
fid = fopen(csvPath, 'w');
if fid < 0
    error('SmartT1:v3_1:FileOpenFailed', 'Cannot open %s for writing.', csvPath);
end
cleanupObj = onCleanup(@() fclose(fid));
fprintf(fid, '%s\n', strjoin(headers, ','));
end
