function [nAdded, payloadRows] = master_db_append_rows(masterDbPath, warningsPath, bSetG, tSetK, analysisRows)
%MASTER_DB_APPEND_ROWS Append v2.2 analysis rows into the v3.2 master DB.

nAdded = 0;
payloadRows = repmat(struct( ...
    'B_set', '', ...
    'B_meas', '', ...
    'T', '', ...
    'measurement_family', '', ...
    'group', '', ...
    'measurement_type', '', ...
    'sequence_name', '', ...
    'date', '', ...
    'num', '', ...
    'spot_name', '', ...
    'spot_order', '', ...
    'spot_folder', '', ...
    'comment', ''), 0, 1);

if nargin < 5 || isempty(analysisRows) || isempty(masterDbPath)
    return;
end

[fid, msg] = fopen(masterDbPath, 'a');
if fid < 0
    append_warning_line_local(warningsPath, sprintf('Cannot append to master DB "%s": %s', masterDbPath, msg));
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

for i = 1:numel(analysisRows)
    a = analysisRows(i);
    sequenceName = char(string(safe_struct_field_local(a, 'sequence', '')));
    if isempty(sequenceName)
        append_warning_line_local(warningsPath, 'Skipped row: empty analysis sequence name.');
        continue;
    end

    saveString = char(string(safe_struct_field_local(a, 'saveString', '')));
    [okParse, dateStr, numVal, parseReason] = parse_date_num_from_save_string_local(saveString, sequenceName);
    if ~okParse
        append_warning_line_local(warningsPath, sprintf( ...
            'Skipped row: parse failed for sequence="%s", saveString="%s": %s', ...
            sequenceName, saveString, parseReason));
        continue;
    end

    measurementFamily = normalize_measurement_family_local(safe_struct_field_local(a, 'family', ''));
    if isempty(measurementFamily)
        measurementFamily = infer_measurement_family_local(sequenceName);
    end
    groupTok = normalize_group_local(safe_struct_field_local(a, 'group', ''));
    spin = char(string(safe_struct_field_local(a, 'spin', '')));
    measurementType = map_measurement_type_local(measurementFamily, sequenceName, spin);
    if isempty(measurementType)
        append_warning_line_local(warningsPath, sprintf( ...
            'Skipped row: unknown measurement mapping for family="%s", sequence="%s", spin="%s".', ...
            measurementFamily, sequenceName, spin));
        continue;
    end

    if isfinite(double(bSetG))
        bSetTok = num2str(double(bSetG), '%.12g');
    else
        bSetTok = '';
    end

    bMeas = double(safe_struct_field_local(a, 'B', NaN));
    bMeasured = logical(safe_struct_field_local(a, 'BMeasured', true));
    if bMeasured && isfinite(bMeas)
        bMeasTok = num2str(bMeas, '%.12g');
    else
        bMeasTok = '';
    end

    if isfinite(double(tSetK))
        tTok = num2str(double(tSetK), '%.12g');
    else
        tTok = '';
    end

    spotNameTok = char(string(safe_struct_field_local(a, 'spotName', '')));
    spotOrderVal = double(safe_struct_field_local(a, 'spotOrder', NaN));
    if isfinite(spotOrderVal)
        spotOrderTok = sprintf('%d', round(spotOrderVal));
    else
        spotOrderTok = '';
    end
    spotFolderTok = char(string(safe_struct_field_local(a, 'spotFolder', '')));

    numTok = sprintf('%d', round(numVal));
    commentTok = '';

    line = strjoin({ ...
        csv_quote_local(bSetTok), ...
        csv_quote_local(bMeasTok), ...
        csv_quote_local(tTok), ...
        csv_quote_local(measurementFamily), ...
        csv_quote_local(groupTok), ...
        csv_quote_local(measurementType), ...
        csv_quote_local(sequenceName), ...
        csv_quote_local(dateStr), ...
        csv_quote_local(numTok), ...
        csv_quote_local(spotNameTok), ...
        csv_quote_local(spotOrderTok), ...
        csv_quote_local(spotFolderTok), ...
        csv_quote_local(commentTok)}, ',');
    fprintf(fid, '%s\n', line);

    payload = struct();
    payload.B_set = bSetTok;
    payload.B_meas = bMeasTok;
    payload.T = tTok;
    payload.measurement_family = measurementFamily;
    payload.group = groupTok;
    payload.measurement_type = measurementType;
    payload.sequence_name = sequenceName;
    payload.date = dateStr;
    payload.num = numTok;
    payload.spot_name = spotNameTok;
    payload.spot_order = spotOrderTok;
    payload.spot_folder = spotFolderTok;
    payload.comment = commentTok;
    payloadRows(end + 1, 1) = payload; %#ok<AGROW>

    nAdded = nAdded + 1;
end
end

function out = normalize_group_local(in)
raw = lower(strtrim(char(string(in))));
if contains(raw, 'off')
    out = 'OffAligned';
elseif contains(raw, 'aligned') || isempty(raw)
    out = 'Aligned';
else
    out = char(string(in));
end
end

function [ok, dateStr, numVal, reason] = parse_date_num_from_save_string_local(saveString, sequenceName)
ok = false;
dateStr = '';
numVal = NaN;
reason = '';

raw = char(string(saveString));
raw = strtrim(raw);
if isempty(raw)
    reason = 'save string is empty';
    return;
end

[~, stem, ext] = fileparts(raw);
if isempty(stem)
    stem = raw;
elseif ~isempty(ext)
    stem = stem;
end

seqPrefix = [char(string(sequenceName)) '_'];
if startsWith(stem, seqPrefix)
    tail = stem(numel(seqPrefix) + 1:end);
    tokens = regexp(tail, '^(.+?)_Ave_(\d+)$', 'tokens', 'once');
    if ~isempty(tokens) && numel(tokens) == 2
        dateStr = char(tokens{1});
        numVal = str2double(tokens{2});
        if isfinite(numVal)
            ok = true;
            return;
        end
        reason = 'parsed num is not finite';
        dateStr = '';
        numVal = NaN;
        return;
    end
end

tokens = regexp(stem, '^((?:T1|T2|T2Star)_[A-Za-z0-9_]+)_(.+?)_Ave_(\d+)$', 'tokens', 'once');
if isempty(tokens) || numel(tokens) ~= 3
    reason = 'does not match expected <sequence>_<date>_Ave_<num> pattern';
    return;
end

dateStr = char(tokens{2});
numVal = str2double(tokens{3});
if ~isfinite(numVal)
    reason = 'parsed num is not finite';
    dateStr = '';
    numVal = NaN;
    return;
end

ok = true;
end

function measurementFamily = infer_measurement_family_local(sequenceName)
seq = char(string(sequenceName));
if startsWith(seq, 'T2Star_')
    measurementFamily = 'T2*';
elseif startsWith(seq, 'T2_')
    measurementFamily = 'T2';
elseif startsWith(seq, 'T1_')
    measurementFamily = 'T1';
else
    measurementFamily = '';
end
end

function out = normalize_measurement_family_local(in)
raw = lower(strtrim(char(string(in))));
switch raw
    case 't1'
        out = 'T1';
    case 't2'
        out = 'T2';
    case {'t2star', 't2*'}
        out = 'T2*';
    otherwise
        out = '';
end
end

function measurementType = map_measurement_type_local(measurementFamily, sequenceName, spin)
measurementType = '';
seq = char(string(sequenceName));
sp = lower(strtrim(char(string(spin))));

if any(strcmp(measurementFamily, {'T1', 'T2', 'T2*'}))
    if strcmp(sp, '0m1')
        measurementType = 'SQ 0 to -1';
        return;
    end
    if strcmp(sp, '0p1')
        measurementType = 'SQ 0 to +1';
        return;
    end
end

if strcmp(measurementFamily, 'T1') && strcmp(seq, 'T1_Sij_all') && strcmp(sp, 'all')
    measurementType = 'Sij all';
    return;
end

if strcmp(measurementFamily, 'T1') && strcmp(seq, 'T1_S11_S1m1') && strcmp(sp, 'm1p1')
    measurementType = 'DQ -1 to +1';
end
end

function out = safe_struct_field_local(s, fieldName, fallback)
out = fallback;
if isstruct(s) && isfield(s, fieldName)
    out = s.(fieldName);
end
end

function out = csv_quote_local(token)
raw = char(string(token));
raw = strrep(raw, '"', '""');
out = ['"' raw '"'];
end

function append_warning_line_local(warningsPath, msg)
if isempty(warningsPath)
    fprintf('[master_db_append_rows] %s\n', char(string(msg)));
    return;
end
[fid, fopenMsg] = fopen(warningsPath, 'a');
if fid < 0
    fprintf('[master_db_append_rows] warning log write failed (%s): %s\n', warningsPath, fopenMsg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '[%s] %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'), char(string(msg)));
end
