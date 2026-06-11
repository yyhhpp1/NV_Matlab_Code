masterDbCsvPath = 'D:\t1_auto_saves_v3_1\TB_Run_20260315_165319_729\master_db.csv';
out = compile_master_db_to_snippet(masterDbCsvPath);

function out = compile_master_db_to_snippet(masterDbCsvPath, outFile)
%COMPILE_MASTER_DB_TO_SNIPPET Convert master_db.csv to analysis code snippet.
%   out = compile_master_db_to_snippet(masterDbCsvPath)
%   out = compile_master_db_to_snippet(masterDbCsvPath, outFile)
%
% Input CSV schema (expected columns):
%   B_set,B_meas,T,measurement_type,sequence_name,date,num,comment
%
% Output snippet format:
%   T = <T>;
%   B = <B>;
%   data.add_entry('<date>', <num>, B, T, 'Aligned', '<sequence_name>', '<spin>');
%
% Rules:
%   1) B value: use B_meas if finite; otherwise use B_set; otherwise 0.
%   2) Group by T then B (ascending).
%   3) measurement_type -> spin mapping:
%        'SQ 0 to -1'  -> '0m1'
%        'SQ 0 to +1'  -> '0p1'
%        'DQ -1 to +1' -> 'm1p1'
%
% If outFile omitted:
%   <folder_of_master_db>\compiled_from_master_db_snippet.txt

if nargin < 1 || isempty(masterDbCsvPath)
    error('SmartT1:v3_1:MissingInput', 'masterDbCsvPath is required.');
end
masterDbCsvPath = char(string(masterDbCsvPath));
if exist(masterDbCsvPath, 'file') ~= 2
    error('SmartT1:v3_1:FileNotFound', 'master_db file not found: %s', masterDbCsvPath);
end

if nargin < 2 || isempty(outFile)
    [inDir, ~, ~] = fileparts(masterDbCsvPath);
    if isempty(inDir)
        inDir = pwd;
    end
    outFile = fullfile(inDir, 'compiled_from_master_db_snippet.txt');
else
    outFile = char(string(outFile));
end

tbl = read_master_db_table(masterDbCsvPath);
rows = table_to_rows(tbl);
if isempty(rows)
    error('SmartT1:v3_1:NoRows', 'No valid rows parsed from master_db.');
end

% Sort by T, then B, then date, then num.
Tvals = [rows.T].';
Bvals = [rows.B].';
numVals = [rows.num].';
dateVals = {rows.date}.';
dateNum = datenum_safe(dateVals);
[~, idx] = sortrows([Tvals, Bvals, dateNum, numVals], [1 2 3 4]);
rows = rows(idx);

[ok, errMsg] = write_compiled_snippet(outFile, rows, masterDbCsvPath);
if ~ok
    error('SmartT1:v3_1:WriteFailed', 'Failed to write output snippet: %s', errMsg);
end

out = struct();
out.masterDbCsvPath = masterDbCsvPath;
out.outFile = outFile;
out.nRows = numel(rows);
disp(sprintf('[compile_master_db_to_snippet] Wrote %d row(s) to %s', out.nRows, out.outFile));
end

function tbl = read_master_db_table(csvPath)
opts = detectImportOptions(csvPath, 'Delimiter', ',', 'TextType', 'string');
opts = setvartype(opts, 'string');
tbl = readtable(csvPath, opts);

required = ["B_set","B_meas","T","measurement_type","sequence_name","date","num"];
for i = 1:numel(required)
    if ~any(strcmp(tbl.Properties.VariableNames, required(i)))
        error('SmartT1:v3_1:MissingColumn', 'master_db missing required column: %s', required(i));
    end
end
end

function rows = table_to_rows(tbl)
rows = repmat(struct( ...
    'T', NaN, ...
    'B', NaN, ...
    'date', '', ...
    'num', NaN, ...
    'group', 'Aligned', ...
    'sequence_name', '', ...
    'spin', ''), 0, 1);

for i = 1:height(tbl)
    tVal = str2double(strtrim(char(tbl.T(i))));
    if ~isfinite(tVal)
        continue;
    end

    bMeas = str2double(strtrim(char(tbl.B_meas(i))));
    bSet = str2double(strtrim(char(tbl.B_set(i))));
    if isfinite(bMeas)
        bVal = bMeas;
    elseif isfinite(bSet)
        bVal = bSet;
    else
        bVal = 0;
    end

    seqName = strtrim(char(tbl.sequence_name(i)));
    if isempty(seqName)
        continue;
    end

    dateStr = strtrim(char(tbl.date(i)));
    if isempty(dateStr)
        dateStr = '';
    end

    numVal = str2double(strtrim(char(tbl.num(i))));
    if ~isfinite(numVal)
        continue;
    end
    numVal = round(numVal);

    mType = strtrim(char(tbl.measurement_type(i)));
    spin = map_measurement_type_to_spin(mType);
    if isempty(spin)
        continue;
    end

    r = struct();
    r.T = tVal;
    r.B = bVal;
    r.date = dateStr;
    r.num = numVal;
    r.group = 'Aligned';
    r.sequence_name = seqName;
    r.spin = spin;
    rows(end + 1, 1) = r; %#ok<AGROW>
end
end

function spin = map_measurement_type_to_spin(measurementType)
spin = '';
m = strtrim(char(string(measurementType)));
switch m
    case 'SQ 0 to -1'
        spin = '0m1';
    case 'SQ 0 to +1'
        spin = '0p1';
    case 'DQ -1 to +1'
        spin = 'm1p1';
    otherwise
        spin = '';
end
end

function [ok, errMsg] = write_compiled_snippet(outFile, rows, sourceCsv)
ok = false;
errMsg = '';

[outDir, ~, ~] = fileparts(outFile);
if ~isempty(outDir) && exist(outDir, 'dir') ~= 7
    [mkOk, mkMsg, mkId] = mkdir(outDir);
    if ~mkOk
        errMsg = sprintf('Cannot create output folder "%s": %s (%s)', outDir, mkMsg, mkId);
        return;
    end
end

[fid, fopenMsg] = fopen(outFile, 'w');
if fid < 0
    errMsg = sprintf('Cannot open output file "%s": %s', outFile, fopenMsg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, '%% Compiled from master_db.csv\n');
fprintf(fid, '%% Source: %s\n', sourceCsv);
fprintf(fid, '%% Generated at: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'));

lastT = NaN;
lastB = NaN;
for i = 1:numel(rows)
    r = rows(i);

    tChanged = (i == 1) || abs(r.T - lastT) > 1e-12;
    if tChanged
        if i > 1
            fprintf(fid, '\n');
        end
        fprintf(fid, 'T = %.12g;\n', r.T);
        lastB = NaN;
    end

    bChanged = (i == 1) || abs(r.B - lastB) > 1e-12;
    if bChanged
        fprintf(fid, 'B = %.12g;\n', r.B);
    end

    fprintf(fid, 'data.add_entry(''%s'', %d, B, T, ''%s'', ''%s'', ''%s'');\n', ...
        escape_quotes(r.date), r.num, escape_quotes(r.group), ...
        escape_quotes(r.sequence_name), escape_quotes(r.spin));

    lastT = r.T;
    lastB = r.B;
end

ok = true;
end

function out = escape_quotes(in)
out = char(string(in));
out = strrep(out, '''', '''''');
end

function dn = datenum_safe(dateStrCell)
dn = nan(numel(dateStrCell), 1);
for i = 1:numel(dateStrCell)
    s = strtrim(char(string(dateStrCell{i})));
    if isempty(s)
        continue;
    end
    % Try common run format yyyy-m-d first.
    try
        v = sscanf(s, '%d-%d-%d');
        if numel(v) == 3
            dn(i) = datenum(v(1), v(2), v(3));
            continue;
        end
    catch
    end
    % Fallback to datenum parser.
    try
        dn(i) = datenum(s);
    catch
        dn(i) = NaN;
    end
end
dn(~isfinite(dn)) = inf;
end
