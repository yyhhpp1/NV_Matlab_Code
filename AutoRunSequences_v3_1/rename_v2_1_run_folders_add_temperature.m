function out = rename_v2_1_run_folders_add_temperature(runRoot, masterDbPath, cfg)
%RENAME_V2_1_RUN_FOLDERS_ADD_TEMPERATURE Add temperature tags to legacy v2.1 run folders.
%   out = rename_v2_1_run_folders_add_temperature(runRoot)
%   out = rename_v2_1_run_folders_add_temperature(runRoot, masterDbPath)
%   out = rename_v2_1_run_folders_add_temperature(runRoot, masterDbPath, cfg)
%
% Legacy folder format:
%   Run_<Btag>_<yyyymmdd_HHMMSS>
% Example:
%   Run_100p00G_20260305_072512
%
% New folder format:
%   Run_<Btag>_<Ttag>_<yyyymmdd_HHMMSS>
% Example:
%   Run_100p00G_5p00K_20260305_072512
%
% Matching strategy:
%   1) Find SQ screenshot in each legacy folder:
%        T1_S00_S01_S10_<date>_Ave_<num>.png
%   2) Parse sequence/date/num from screenshot name.
%   3) Match (sequence_name, date, num) in master_db.csv.
%   4) Cross-check folder B estimate against DB B_set (or B_meas fallback).
%   5) Rename folder by inserting temperature tag from DB.
%
% masterDbPath can be either:
%   - A single CSV file path to one master_db.csv
%   - A folder root; then all **\master_db.csv files are loaded
%     (e.g. t1_auto_saves_v3_1\TB_Run_*\master_db.csv)
% If masterDbPath is omitted/empty, runRoot is used.
%
% Required CSV columns:
%   B_set,B_meas,T,measurement_type,sequence_name,date,num,comment
%
% cfg fields (optional):
%   .sequenceName      default 'T1_S00_S01_S10'
%   .dryRun            default true  (preview only)
%   .recursive         default true  (scan runRoot recursively)
%   .bToleranceG       default 2.0   (B consistency tolerance in G)
%   .temperatureDigits default 2     (T tag formatting, e.g. 5p00K)
%   .verbose           default true
%
% Output:
%   out.summary   : counts
%   out.records   : per-folder struct array
%   out.table     : per-folder table

if nargin < 1 || isempty(runRoot)
    error('SmartT1:v3_1:MissingInput', 'runRoot is required.');
end
if nargin < 3 || isempty(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

runRoot = char(string(runRoot));
if nargin < 2 || isempty(masterDbPath)
    masterDbPath = runRoot;
end
masterDbPath = char(string(masterDbPath));
if exist(runRoot, 'dir') ~= 7
    error('SmartT1:v3_1:FolderNotFound', 'runRoot does not exist: %s', runRoot);
end
if exist(masterDbPath, 'file') ~= 2 && exist(masterDbPath, 'dir') ~= 7
    error('SmartT1:v3_1:PathNotFound', 'masterDbPath not found: %s', masterDbPath);
end

masterDbCsvFiles = collect_master_db_csv_files(masterDbPath);
if isempty(masterDbCsvFiles)
    error('SmartT1:v3_1:NoMasterDbFiles', 'No master_db.csv found under: %s', masterDbPath);
end

dbRows = read_master_db_rows(masterDbCsvFiles);
if isempty(dbRows)
    error('SmartT1:v3_1:NoValidDbRows', 'No valid rows parsed from master DB path: %s', masterDbPath);
end
[dbMapSeq, dbMapNoSeq] = build_db_lookup_maps(dbRows);

runFolders = collect_run_folders(runRoot, cfg.recursive);
records = repmat(make_record_template(), 0, 1);

for i = 1:numel(runFolders)
    runFolder = runFolders{i};
    rec = make_record_template();
    rec.oldFolder = runFolder;

    [okOld, bTag, tsTag] = parse_old_style_run_folder(runFolder);
    if ~okOld
        rec.status = 'skip_not_legacy';
        rec.message = 'Folder name is not legacy format.';
        records(end + 1, 1) = rec; %#ok<AGROW>
        continue;
    end

    rec.folderBTag = bTag;
    rec.folderTimestamp = tsTag;
    rec.folderB_G = decode_tag_value(bTag, 'G');
    if ~isfinite(rec.folderB_G)
        rec.status = 'skip_bad_folder_B';
        rec.message = sprintf('Cannot parse B tag from folder: %s', bTag);
        records(end + 1, 1) = rec; %#ok<AGROW>
        continue;
    end

    [okPng, seqName, dateNorm, numVal, sqPngPath, pngReason] = find_sq_screenshot_key(runFolder, cfg.sequenceName);
    rec.sqPngPath = sqPngPath;
    rec.sequenceName = seqName;
    rec.date = dateNorm;
    rec.num = numVal;
    if ~okPng
        rec.status = 'skip_no_sq_match';
        rec.message = pngReason;
        records(end + 1, 1) = rec; %#ok<AGROW>
        continue;
    end

    [okDb, dbRow, dbReason] = find_db_row(dbRows, dbMapSeq, dbMapNoSeq, seqName, dateNorm, numVal, rec.folderB_G, cfg.bToleranceG);
    if ~okDb
        rec.status = 'skip_no_db_match';
        rec.message = dbReason;
        records(end + 1, 1) = rec; %#ok<AGROW>
        continue;
    end

    rec.dbB_set_G = dbRow.B_set;
    rec.dbB_meas_G = dbRow.B_meas;
    rec.dbT_K = dbRow.T;
    rec.dbSourceCsv = dbRow.source_csv;

    if ~isfinite(dbRow.T)
        rec.status = 'skip_bad_db_T';
        rec.message = 'Matched DB row has invalid T.';
        records(end + 1, 1) = rec; %#ok<AGROW>
        continue;
    end

    tTag = encode_value_tag(dbRow.T, cfg.temperatureDigits, 'K');
    rec.newFolderName = sprintf('Run_%s_%s_%s', bTag, tTag, tsTag);
    rec.newFolder = fullfile(fileparts(runFolder), rec.newFolderName);

    if exist(rec.newFolder, 'dir') == 7
        rec.status = 'skip_target_exists';
        rec.message = sprintf('Target folder already exists: %s', rec.newFolderName);
        records(end + 1, 1) = rec; %#ok<AGROW>
        continue;
    end

    if cfg.dryRun
        rec.status = 'would_rename';
        rec.message = 'Dry run: rename not executed.';
    else
        [okMv, msgMv] = movefile(runFolder, rec.newFolder);
        if okMv
            rec.status = 'renamed';
            rec.message = 'Renamed successfully.';
        else
            rec.status = 'error_rename_failed';
            rec.message = sprintf('movefile failed: %s', msgMv);
        end
    end
    records(end + 1, 1) = rec; %#ok<AGROW>
end

out = struct();
out.runRoot = runRoot;
out.masterDbPath = masterDbPath;
out.masterDbCsvFiles = masterDbCsvFiles;
out.cfg = cfg;
out.records = records;
out.table = records_to_table(records);
out.summary = summarize_records(records);

if cfg.verbose
    print_summary(out.summary, cfg.dryRun);
end
end

function cfg = apply_defaults(cfg)
cfg = set_default(cfg, 'sequenceName', 'T1_S00_S01_S10');
cfg = set_default(cfg, 'dryRun', true);
cfg = set_default(cfg, 'recursive', true);
cfg = set_default(cfg, 'bToleranceG', 2.0);
cfg = set_default(cfg, 'temperatureDigits', 2);
cfg = set_default(cfg, 'verbose', true);
end

function cfg = set_default(cfg, key, val)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = val;
end
end

function csvFiles = collect_master_db_csv_files(masterDbPath)
csvFiles = {};
if exist(masterDbPath, 'file') == 2
    csvFiles = {masterDbPath};
    return;
end

d = dir(fullfile(masterDbPath, '**', 'master_db.csv'));
for i = 1:numel(d)
    if ~d(i).isdir
        csvFiles{end + 1, 1} = fullfile(d(i).folder, d(i).name); %#ok<AGROW>
    end
end
csvFiles = unique(sort(csvFiles));
end

function rows = read_master_db_rows(csvFiles)
rows = repmat(struct( ...
    'B_set', NaN, ...
    'B_meas', NaN, ...
    'T', NaN, ...
    'sequence_name', '', ...
    'date_norm', '', ...
    'num', NaN, ...
    'source_csv', ''), 0, 1);

required = ["B_set","B_meas","T","sequence_name","date","num"];

for iFile = 1:numel(csvFiles)
    csvPath = csvFiles{iFile};
    tbl = readtable(csvPath, 'Delimiter', ',', 'TextType', 'string', 'VariableNamingRule', 'preserve');
    for i = 1:numel(required)
        if ~any(strcmp(tbl.Properties.VariableNames, required(i)))
            error('SmartT1:v3_1:MissingColumn', 'master DB missing required column (%s): %s', required(i), csvPath);
        end
    end

    for iRow = 1:height(tbl)
        seq = scalar_to_text(tbl.sequence_name(iRow));
        dateNorm = normalize_date_token(tbl.date(iRow));
        numVal = parse_int_value(tbl.num(iRow));
        tVal = parse_double_value(tbl.T(iRow));
        bSet = parse_double_value(tbl.B_set(iRow));
        bMeas = parse_double_value(tbl.B_meas(iRow));

        if isempty(seq) || isempty(dateNorm) || ~isfinite(numVal)
            continue;
        end

        r = struct();
        r.B_set = bSet;
        r.B_meas = bMeas;
        r.T = tVal;
        r.sequence_name = seq;
        r.date_norm = dateNorm;
        r.num = round(numVal);
        r.source_csv = csvPath;
        rows(end + 1, 1) = r; %#ok<AGROW>
    end
end
end

function [mapSeq, mapNoSeq] = build_db_lookup_maps(rows)
mapSeq = containers.Map('KeyType', 'char', 'ValueType', 'any');
mapNoSeq = containers.Map('KeyType', 'char', 'ValueType', 'any');
for i = 1:numel(rows)
    rs = rows(i);
    keySeq = make_key_seq(rs.sequence_name, rs.date_norm, rs.num);
    keyNoSeq = make_key_no_seq(rs.date_norm, rs.num);

    if isKey(mapSeq, keySeq)
        mapSeq(keySeq) = [mapSeq(keySeq), i];
    else
        mapSeq(keySeq) = i;
    end
    if isKey(mapNoSeq, keyNoSeq)
        mapNoSeq(keyNoSeq) = [mapNoSeq(keyNoSeq), i];
    else
        mapNoSeq(keyNoSeq) = i;
    end
end
end

function folders = collect_run_folders(runRoot, recursiveScan)
folders = {};
if recursiveScan
    d = dir(fullfile(runRoot, '**', 'Run_*'));
else
    d = dir(fullfile(runRoot, 'Run_*'));
end

for i = 1:numel(d)
    if d(i).isdir
        folders{end + 1, 1} = fullfile(d(i).folder, d(i).name); %#ok<AGROW>
    end
end

[~, rootName, ~] = fileparts(runRoot);
if startsWith(rootName, 'Run_')
    folders{end + 1, 1} = runRoot; %#ok<AGROW>
end

if isempty(folders)
    return;
end
folders = unique(folders, 'stable');
folders = sort(folders);
end

function [ok, bTag, tsTag] = parse_old_style_run_folder(runFolder)
ok = false;
bTag = '';
tsTag = '';
[~, name, ~] = fileparts(runFolder);

% New style already contains temperature; do not process.
tokNew = regexp(name, '^Run_([^_]+)_([^_]+)_\d{8}_\d{6}(?:_\d+)?$', 'tokens', 'once');
if ~isempty(tokNew)
    return;
end

tokOld = regexp(name, '^Run_([^_]+)_(\d{8}_\d{6}(?:_\d+)?)$', 'tokens', 'once');
if isempty(tokOld) || numel(tokOld) < 2
    return;
end

bTag = char(tokOld{1});
tsTag = char(tokOld{2});
ok = true;
end

function [ok, seqName, dateNorm, numVal, sqPngPath, reason] = find_sq_screenshot_key(runFolder, sequenceName)
ok = false;
seqName = '';
dateNorm = '';
numVal = NaN;
sqPngPath = '';
reason = '';

pat = sprintf('%s_*_Ave_*.png', char(string(sequenceName)));
files = dir(fullfile(runFolder, '**', pat));
if isempty(files)
    files = dir(fullfile(runFolder, pat));
end
if isempty(files)
    reason = sprintf('No SQ screenshot found with pattern: %s', pat);
    return;
end

keys = repmat(struct('seq', '', 'date', '', 'num', NaN, 'path', ''), 0, 1);
for i = 1:numel(files)
    if files(i).isdir
        continue;
    end
    fullP = fullfile(files(i).folder, files(i).name);
    [okP, seqP, dateP, numP, whyP] = parse_sequence_date_num_from_png(files(i).name);
    if ~okP
        reason = sprintf('Found screenshot but parse failed (%s): %s', files(i).name, whyP);
        continue;
    end
    if ~strcmp(seqP, sequenceName)
        continue;
    end
    k = struct();
    k.seq = seqP;
    k.date = dateP;
    k.num = numP;
    k.path = fullP;
    keys(end + 1, 1) = k; %#ok<AGROW>
end

if isempty(keys)
    if isempty(reason)
        reason = sprintf('No parseable SQ screenshot found matching sequence: %s', sequenceName);
    end
    return;
end

sig = arrayfun(@(k) sprintf('%s|%s|%d', lower(k.seq), k.date, k.num), keys, 'UniformOutput', false);
sigUnique = unique(sig);
if numel(sigUnique) ~= 1
    reason = sprintf('Ambiguous SQ screenshot keys in folder (%d unique keys).', numel(sigUnique));
    return;
end

seqName = keys(1).seq;
dateNorm = keys(1).date;
numVal = keys(1).num;
sqPngPath = keys(1).path;
ok = true;
end

function [ok, dbRow, reason] = find_db_row(dbRows, mapSeq, mapNoSeq, sequenceName, dateNorm, numVal, folderB, tolG)
ok = false;
reason = '';
dbRow = struct();

keySeq = make_key_seq(sequenceName, dateNorm, numVal);
if isKey(mapSeq, keySeq)
    idxCandidates = mapSeq(keySeq);
    [ok, dbRow, reason] = choose_db_candidate_by_B(dbRows, idxCandidates, folderB, tolG, 'sequence+date+num');
    return;
end

keyNoSeq = make_key_no_seq(dateNorm, numVal);
if isKey(mapNoSeq, keyNoSeq)
    idxCandidates = mapNoSeq(keyNoSeq);
    [ok, dbRow, reason] = choose_db_candidate_by_B(dbRows, idxCandidates, folderB, tolG, 'date+num fallback');
    return;
end

reason = 'No DB row found for sequence/date/num or date/num.';
end

function [ok, dbRow, reason] = choose_db_candidate_by_B(dbRows, idxCandidates, folderB, tolG, keyLabel)
ok = false;
dbRow = struct();
reason = '';
if isempty(idxCandidates)
    reason = sprintf('No DB candidates for %s.', keyLabel);
    return;
end

idxPass = [];
deltaPass = [];
for i = 1:numel(idxCandidates)
    idx = idxCandidates(i);
    row = dbRows(idx);
    [okB, ~] = check_b_consistency(folderB, row.B_set, row.B_meas, tolG);
    if okB
        idxPass(end + 1, 1) = idx; %#ok<AGROW>
        deltaPass(end + 1, 1) = compute_b_delta(folderB, row.B_set, row.B_meas); %#ok<AGROW>
    end
end

if isempty(idxPass)
    reason = sprintf('Found %d DB candidate(s) for %s, but all failed B consistency (tol=%.6g G).', ...
        numel(idxCandidates), keyLabel, tolG);
    return;
end

if numel(idxPass) == 1
    dbRow = dbRows(idxPass(1));
    ok = true;
    return;
end

[minDelta, iBest] = min(deltaPass);
if ~isfinite(minDelta)
    reason = sprintf('Found %d B-consistent DB candidates for %s but none has finite B_set/B_meas.', ...
        numel(idxPass), keyLabel);
    return;
end

tieIdx = find(abs(deltaPass - minDelta) <= 1e-12);
if numel(tieIdx) > 1
    tVals = arrayfun(@(k) dbRows(idxPass(k)).T, tieIdx);
    if numel(unique(tVals)) > 1
        reason = sprintf('Ambiguous DB match for %s: %d candidates share same closest B delta %.6g G but different T.', ...
            keyLabel, numel(tieIdx), minDelta);
        return;
    end
end

dbRow = dbRows(idxPass(iBest));
ok = true;
end

function d = compute_b_delta(folderB, dbBset, dbBmeas)
d = inf;
if ~isfinite(folderB)
    return;
end
if isfinite(dbBset)
    d = abs(folderB - dbBset);
    return;
end
if isfinite(dbBmeas)
    d = abs(folderB - dbBmeas);
end
end

function key = make_key_seq(sequenceName, dateNorm, numVal)
key = sprintf('%s|%s|%d', lower(strtrim(char(string(sequenceName)))), char(string(dateNorm)), round(numVal));
end

function key = make_key_no_seq(dateNorm, numVal)
key = sprintf('%s|%d', char(string(dateNorm)), round(numVal));
end

function [ok, reason] = check_b_consistency(folderB, dbBset, dbBmeas, tolG)
ok = true;
reason = '';
if ~isfinite(folderB)
    ok = false;
    reason = 'Folder B is invalid.';
    return;
end

if isfinite(dbBset)
    d = abs(folderB - dbBset);
    if d > tolG
        ok = false;
        reason = sprintf('B mismatch vs DB B_set: folder=%.6g G, B_set=%.6g G, |d|=%.6g > tol=%.6g', ...
            folderB, dbBset, d, tolG);
        return;
    end
    return;
end

if isfinite(dbBmeas)
    d = abs(folderB - dbBmeas);
    if d > tolG
        ok = false;
        reason = sprintf('B mismatch vs DB B_meas fallback: folder=%.6g G, B_meas=%.6g G, |d|=%.6g > tol=%.6g', ...
            folderB, dbBmeas, d, tolG);
    end
end
end

function tag = encode_value_tag(v, digits, suffix)
if ~isfinite(v)
    error('SmartT1:v3_1:InvalidValue', 'Cannot encode non-finite value tag.');
end
digits = round(digits);
if digits < 0
    digits = 0;
end
fmt = sprintf('%%.%df', digits);
absTxt = sprintf(fmt, abs(v));
absTxt = strrep(absTxt, '.', 'p');
if v < 0
    signTok = 'm';
else
    signTok = '';
end
tag = [signTok absTxt char(string(suffix))];
end

function val = decode_tag_value(tagStr, suffixChar)
val = NaN;
raw = char(string(tagStr));
if isempty(raw)
    return;
end
if nargin >= 2 && ~isempty(suffixChar)
    sf = char(string(suffixChar));
    if endsWith(raw, sf)
        raw = raw(1:end-numel(sf));
    end
end
raw = strrep(raw, 'm', '-');
raw = strrep(raw, 'p', '.');
v = str2double(raw);
if isfinite(v)
    val = v;
end
end

function [ok, seqName, dateNorm, numVal, reason] = parse_sequence_date_num_from_png(fileName)
ok = false;
seqName = '';
dateNorm = '';
numVal = NaN;
reason = '';

[~, stem, ~] = fileparts(char(string(fileName)));
tok = regexp(stem, '^(T1_[A-Za-z0-9_]+)_(.+?)_Ave_(\d+)$', 'tokens', 'once');
if isempty(tok) || numel(tok) ~= 3
    reason = 'File name does not match ^(T1_[A-Za-z0-9_]+)_(.+?)_Ave_(\d+)$';
    return;
end

seqName = char(tok{1});
dateRaw = char(tok{2});
numVal = str2double(tok{3});
if ~isfinite(numVal)
    reason = 'Parsed num is not finite.';
    return;
end
numVal = round(numVal);

dateNorm = normalize_date_token(dateRaw);
if isempty(dateNorm)
    reason = sprintf('Cannot normalize date token: %s', dateRaw);
    return;
end

ok = true;
end

function out = normalize_date_token(in)
out = '';
s = scalar_to_text(in);
if isempty(s)
    return;
end

% Explicit date pattern anywhere in token: yyyy-m-d, yyyy/m/d, yyyy_m_d.
tok = regexp(s, '(\d{4})[-/_](\d{1,2})[-/_](\d{1,2})', 'tokens', 'once');
if ~isempty(tok) && numel(tok) == 3
    y = str2double(tok{1});
    m = str2double(tok{2});
    d = str2double(tok{3});
    if isfinite(y) && isfinite(m) && isfinite(d) && m >= 1 && m <= 12 && d >= 1 && d <= 31
        out = sprintf('%d-%d-%d', y, m, d);
        return;
    end
end

% Compact date: yyyymmdd.
tok2 = regexp(s, '(\d{8})', 'tokens', 'once');
if ~isempty(tok2)
    raw = tok2{1};
    y = str2double(raw(1:4));
    m = str2double(raw(5:6));
    d = str2double(raw(7:8));
    if isfinite(y) && isfinite(m) && isfinite(d) && m >= 1 && m <= 12 && d >= 1 && d <= 31
        out = sprintf('%d-%d-%d', y, m, d);
        return;
    end
end

% Fallback parser.
try
    dv = datevec(s);
    out = sprintf('%d-%d-%d', dv(1), dv(2), dv(3));
catch
    out = '';
end
end

function v = parse_double_value(x)
v = NaN;
if nargin < 1 || isempty(x)
    return;
end

if iscell(x)
    if isempty(x)
        return;
    end
    x = x{1};
end

if isnumeric(x) || islogical(x)
    if ~isempty(x)
        xv = double(x(1));
        if isfinite(xv)
            v = xv;
        end
    end
    return;
end

if isstring(x)
    if isempty(x)
        return;
    end
    xs = x(1);
    if ismissing(xs)
        return;
    end
    xt = strtrim(char(xs));
    if isempty(xt)
        return;
    end
    vv = str2double(xt);
    if isfinite(vv)
        v = vv;
    end
    return;
end

if ischar(x)
    xt = strtrim(x);
    if isempty(xt)
        return;
    end
    vv = str2double(xt);
    if isfinite(vv)
        v = vv;
    end
    return;
end

try
    xt = scalar_to_text(x);
    if isempty(xt)
        return;
    end
    vv = str2double(xt);
    if isfinite(vv)
        v = vv;
    end
catch
end
end

function v = parse_int_value(x)
v = parse_double_value(x);
if isfinite(v)
    v = round(v);
end
end

function out = scalar_to_text(x)
out = '';
if nargin < 1 || isempty(x)
    return;
end

if iscell(x)
    if isempty(x)
        return;
    end
    x = x{1};
end

if isstring(x)
    if isempty(x)
        return;
    end
    xs = x(1);
    if ismissing(xs)
        return;
    end
    out = strtrim(char(xs));
    return;
end

if ischar(x)
    out = strtrim(x);
    return;
end

if isnumeric(x) || islogical(x)
    if isempty(x)
        return;
    end
    xv = double(x(1));
    if ~isfinite(xv)
        return;
    end
    out = strtrim(num2str(xv, '%.15g'));
    return;
end

if isdatetime(x)
    if isempty(x) || isnat(x(1))
        return;
    end
    out = datestr(x(1), 'yyyy-mm-dd');
    out = strtrim(out);
    return;
end

try
    sx = string(x);
    if isempty(sx)
        return;
    end
    s1 = sx(1);
    if ismissing(s1)
        return;
    end
    out = strtrim(char(s1));
catch
    out = '';
end
end

function rec = make_record_template()
rec = struct( ...
    'oldFolder', '', ...
    'newFolder', '', ...
    'newFolderName', '', ...
    'folderBTag', '', ...
    'folderTimestamp', '', ...
    'folderB_G', NaN, ...
    'sequenceName', '', ...
    'date', '', ...
    'num', NaN, ...
    'sqPngPath', '', ...
    'dbB_set_G', NaN, ...
    'dbB_meas_G', NaN, ...
    'dbT_K', NaN, ...
    'dbSourceCsv', '', ...
    'status', '', ...
    'message', '');
end

function tbl = records_to_table(records)
if isempty(records)
    tbl = table();
    return;
end

tbl = struct2table(records);
end

function summary = summarize_records(records)
summary = struct();
summary.nTotal = numel(records);
summary.nRenamed = 0;
summary.nWouldRename = 0;
summary.nSkipped = 0;
summary.nErrors = 0;

for i = 1:numel(records)
    st = char(string(records(i).status));
    switch st
        case 'renamed'
            summary.nRenamed = summary.nRenamed + 1;
        case 'would_rename'
            summary.nWouldRename = summary.nWouldRename + 1;
        case {'error_rename_failed'}
            summary.nErrors = summary.nErrors + 1;
        otherwise
            summary.nSkipped = summary.nSkipped + 1;
    end
end
end

function print_summary(summary, isDryRun)
modeTxt = 'EXECUTE';
if isDryRun
    modeTxt = 'DRY RUN';
end
fprintf('[rename_v2_1_run_folders_add_temperature] Mode: %s\n', modeTxt);
fprintf('[rename_v2_1_run_folders_add_temperature] Total examined: %d\n', summary.nTotal);
fprintf('[rename_v2_1_run_folders_add_temperature] Renamed: %d\n', summary.nRenamed);
fprintf('[rename_v2_1_run_folders_add_temperature] Would rename: %d\n', summary.nWouldRename);
fprintf('[rename_v2_1_run_folders_add_temperature] Skipped: %d\n', summary.nSkipped);
fprintf('[rename_v2_1_run_folders_add_temperature] Errors: %d\n', summary.nErrors);
end
