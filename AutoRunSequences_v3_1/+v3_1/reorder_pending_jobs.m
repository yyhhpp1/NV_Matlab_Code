function campaign = reorder_pending_jobs(campaign, orderedJobIds)
%REORDER_PENDING_JOBS Reorder only pending jobs while preserving running/finished positions.
%
% orderedJobIds must contain exactly the pending job IDs in desired order.

if ~iscell(orderedJobIds)
    error('SmartT1:v3_1:InvalidReorder', 'orderedJobIds must be a cell array of job IDs.');
end

jobs = campaign.jobs;
if isempty(jobs)
    return;
end

pendingIdx = find(arrayfun(@(j) strcmpi(j.status.state, 'pending'), jobs));
pendingIds = arrayfun(@(j) char(j.id), jobs(pendingIdx), 'UniformOutput', false);
incomingIds = orderedJobIds(:)';

if numel(incomingIds) ~= numel(pendingIds) || ~all(ismember(pendingIds, incomingIds))
    error('SmartT1:v3_1:InvalidReorder', ...
        'orderedJobIds must match the full set of pending job IDs.');
end

baseOrders = sort(arrayfun(@(j) j.order, jobs(pendingIdx)));

for i = 1:numel(incomingIds)
    targetId = char(incomingIds{i});
    jobIdx = find(strcmp(arrayfun(@(j) j.id, jobs, 'UniformOutput', false), targetId), 1);
    jobs(jobIdx).order = baseOrders(i);
end

campaign.jobs = jobs;
campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
