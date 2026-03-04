function campaign = request_current_job_action(campaign, action)
%REQUEST_CURRENT_JOB_ACTION Latch user action for running job.
%
% action:
%   'none' | 'mark_failed_skip' | 'mark_failed_redo'

allowed = {'none', 'mark_failed_skip', 'mark_failed_redo'};
action = lower(char(action));
if ~any(strcmp(action, allowed))
    error('SmartT1:v3_1:InvalidAction', 'Unsupported action: %s', action);
end

campaign.runtimeControl.currentJobAction = action;
campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
