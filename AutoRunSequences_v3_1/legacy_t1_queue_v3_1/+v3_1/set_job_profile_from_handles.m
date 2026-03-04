function campaign = set_job_profile_from_handles(campaign, jobId, handlesAuto, profileName)
%SET_JOB_PROFILE_FROM_HANDLES Capture v2.1 GUI snapshot and bind it to one job.

if nargin < 4 || isempty(profileName)
    profileName = 'snapshot';
end

idx = find(strcmp(arrayfun(@(j) j.id, campaign.jobs, 'UniformOutput', false), char(jobId)), 1);
if isempty(idx)
    error('SmartT1:v3_1:JobNotFound', 'Job ID not found: %s', char(jobId));
end

snapshot = v3_1.capture_profile_snapshot(handlesAuto);
campaign.jobs(idx).profile.snapshot = snapshot;
campaign.jobs(idx).profile.name = char(profileName);
campaign.jobs(idx).profile.revision = campaign.jobs(idx).profile.revision + 1;
campaign.jobs(idx).profile.updatedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
