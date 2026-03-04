function campaign = request_stop_all(campaign, handlesAuto, message)
%REQUEST_STOP_ALL Stop queue and send immediate stop signal to v2.1 core.

if nargin < 3
    message = '';
end
campaign.runtimeControl.stopMode = 'stop_all';
campaign.stopRequested = true;
campaign.runtimeControl.statusMessage = char(message);
campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');

if nargin >= 2
    v3_1.send_v2_1_stop_signal(handlesAuto);
else
    v3_1.send_v2_1_stop_signal(struct());
end
end
