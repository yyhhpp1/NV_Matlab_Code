function save_campaign_state(campaign, statePath)
%SAVE_CAMPAIGN_STATE Save campaign struct to queue_state.mat.

if nargin < 2 || isempty(statePath)
    if ~isfield(campaign, 'queueStatePath') || isempty(campaign.queueStatePath)
        return;
    end
    statePath = campaign.queueStatePath;
end

[folderPath, ~, ~] = fileparts(statePath);
if ~isempty(folderPath) && ~isfolder(folderPath)
    mkdir(folderPath);
end

campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
save(statePath, 'campaign');
end
