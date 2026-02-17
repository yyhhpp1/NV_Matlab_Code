function campaign = request_stop_queue(campaign, message)
%REQUEST_STOP_QUEUE Graceful queue stop; current v2.1 run can finish.

if nargin < 2
    message = '';
end
campaign.runtimeControl.stopMode = 'stop_queue';
campaign.stopRequested = true;
campaign.runtimeControl.statusMessage = char(message);
campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
