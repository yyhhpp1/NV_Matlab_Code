function campaign = load_campaign_state(statePath)
%LOAD_CAMPAIGN_STATE Load campaign struct from queue_state.mat.

if ~isfile(statePath)
    error('SmartT1:v3_1:MissingStateFile', 'State file not found: %s', statePath);
end

s = load(statePath, 'campaign');
if ~isfield(s, 'campaign')
    error('SmartT1:v3_1:InvalidStateFile', 'State file does not contain variable "campaign".');
end
campaign = s.campaign;
end
