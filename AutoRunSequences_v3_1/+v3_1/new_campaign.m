function campaign = new_campaign(varargin)
%NEW_CAMPAIGN Create a v3.1 queue campaign struct with default fields.
%
% Usage:
%   campaign = v3_1.new_campaign();
%   campaign = v3_1.new_campaign('saveRoot', 'C:\path\to\root');

opts = parse_name_value(varargin{:});
campaign = struct();
campaign.schemaVersion = '3.1.0';
campaign.campaignId = make_campaign_id();
campaign.createdAt = now_stamp();
campaign.lastSavedAt = campaign.createdAt;
campaign.currentJobId = '';
campaign.currentJobIndex = 0;
campaign.isRunning = false;
campaign.stopRequested = false;
campaign.jobs = repmat(v3_1.new_job(), 0, 1);

if isfield(opts, 'saveRoot') && ~isempty(opts.saveRoot)
    campaign.saveRoot = char(opts.saveRoot);
else
    campaign.saveRoot = fullfile(pwd, 'AutoRunSequences_v3_1_Saves');
end

campaign.queueRoot = '';
campaign.queueStatePath = '';
campaign.attemptLogPath = '';
campaign.finalLogPath = '';

campaign.runtimeControl = struct( ...
    'stopMode', 'none', ...                 % none | stop_queue | stop_all
    'currentJobAction', 'none', ...         % none | mark_failed_skip | mark_failed_redo
    'statusMessage', '' ...
);
end

function id = make_campaign_id()
id = sprintf('%s_%04d', datestr(now, 'yyyymmdd_HHMMSS'), randi([0, 9999]));
end

function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end

function opts = parse_name_value(varargin)
opts = struct();
if mod(nargin, 2) ~= 0
    error('SmartT1:v3_1:InvalidArgs', 'Name/value arguments must be paired.');
end
for i = 1:2:nargin
    key = varargin{i};
    if ~(ischar(key) || isstring(key))
        error('SmartT1:v3_1:InvalidArgs', 'Option names must be text.');
    end
    opts.(char(key)) = varargin{i + 1};
end
end
