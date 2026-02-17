function generate_final_sq_dq_log(campaign, outputCsvPath)
%GENERATE_FINAL_SQ_DQ_LOG Build queue-level final (non-rough) SQ/DQ summary log.

if nargin < 2 || isempty(outputCsvPath)
    if ~isfield(campaign, 'finalLogPath') || isempty(campaign.finalLogPath)
        return;
    end
    outputCsvPath = campaign.finalLogPath;
end

[folderPath, ~, ~] = fileparts(outputCsvPath);
if ~isempty(folderPath) && ~isfolder(folderPath)
    mkdir(folderPath);
end

headers = { ...
    'campaignId', 'jobId', 'attemptIdx', ...
    'B_set', 'T_set', ...
    'sequenceName', 'date', 'aveFigureName', 'figurePath' ...
};

fid = fopen(outputCsvPath, 'w');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s\n', strjoin(headers, ','));

if ~isfield(campaign, 'jobs') || isempty(campaign.jobs)
    return;
end

seen = containers.Map('KeyType', 'char', 'ValueType', 'logical');

for iJob = 1:numel(campaign.jobs)
    job = campaign.jobs(iJob);
    if ~isfield(job, 'history') || isempty(job.history)
        continue;
    end
    for iAttempt = 1:numel(job.history)
        a = job.history(iAttempt);
        if ~isfield(a, 'sequenceRows') || isempty(a.sequenceRows)
            continue;
        end
        for iRow = 1:numel(a.sequenceRows)
            row = a.sequenceRows(iRow);
            if isempty(row.sequenceName) || isempty(row.aveFigureName)
                continue;
            end
            if contains(lower(row.aveFigureName), 'rough')
                continue;
            end
            key = sprintf('%s|%s|%d|%s', job.id, row.sequenceName, a.attemptIdx, row.figurePath);
            if isKey(seen, key)
                continue;
            end
            seen(key) = true;
            line = csv_line({ ...
                campaign.campaignId, ...
                job.id, ...
                a.attemptIdx, ...
                job.setpoint.B, ...
                job.setpoint.T, ...
                row.sequenceName, ...
                row.date, ...
                row.aveFigureName, ...
                row.figurePath ...
            });
            fprintf(fid, '%s\n', line);
        end
    end
end
end

function line = csv_line(cellsRow)
parts = cell(1, numel(cellsRow));
for i = 1:numel(cellsRow)
    value = cellsRow{i};
    if isnumeric(value)
        token = num2str(value, 16);
    elseif isstring(value)
        token = char(value);
    else
        token = char(value);
    end
    token = strrep(token, '"', '""');
    parts{i} = ['"' token '"'];
end
line = strjoin(parts, ',');
end
