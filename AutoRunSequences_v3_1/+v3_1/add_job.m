function campaign = add_job(campaign, job)
%ADD_JOB Append job to campaign and assign next order if needed.

if nargin < 2 || isempty(job)
    job = v3_1.new_job();
end

if ~isfield(campaign, 'jobs') || isempty(campaign.jobs)
    campaign.jobs = repmat(job, 0, 1);
end

if ~isfield(job, 'order') || ~isnumeric(job.order) || job.order <= 0
    if isempty(campaign.jobs)
        job.order = 1;
    else
        job.order = max([campaign.jobs.order]) + 1;
    end
end

campaign.jobs(end + 1, 1) = job;
campaign.lastSavedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
