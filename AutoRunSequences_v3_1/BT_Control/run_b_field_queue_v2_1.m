function out = run_b_field_queue_v2_1(targetBkGList, cfg)
%RUN_B_FIELD_QUEUE_V2_1 Minimal B-field queue runner for v2.1 automation.
%   out = run_b_field_queue_v2_1(targetBkGList, cfg)
%
% Inputs
%   targetBkGList : numeric vector of target B fields (kG) for Z magnet.
%   cfg           : optional struct
%       .mode              final magnet mode: 'driven' or 'persistent' (default 'driven')
%       .magnetCfg         passed to set_z_magnet_mode (default struct())
%       .hFigAuto          handle to T1_SemiAuto_ParamInput_v2_1 figure (required)
%       .hFigMain          handle to parent main GUI (optional; auto-resolved from hFigAuto)
%       .bEstimateScale    B_estimate [G] = targetBkG * scale (default 1000)
%       .resetStopLatch    clear stop latch at start (default true)
%       .stopAppDataKey    appdata key for stop latch (default 'BT_CONTROL_STOP_B_QUEUE')
%       .writeStartLog     write v2.1 start log CSV (default true)
%       .startLogPath      CSV path (default: b_field_queue_start_log_*.csv in pwd)
%       .writeAnalysisSnippet write analysis snippet TXT (default true)
%       .analysisSnippetPath TXT path (default: b_field_queue_analysis_snippet_*.txt in pwd)
%       .writeNotionSequenceLog write per-sequence notion events via v2.1 (default false)
%       .notionSpoolPath   JSONL spool path for external notion uploader
%       .notionQueueLogPath CSV queue log path for debug
%       .notionPageKey     optional notion page id/key written into each event
%       .runRoot           optional TB run root path for event context
%       .tbStepIndex       optional TB step index for event context
%       .tSetK             optional temperature setpoint for event context
%       .testModeNoBT      skip magnet hardware control (default false)
%       .skipFirstMagControl skip first magnet control in this queue run (default false)
%       .verbose           print queue logs (default true)
%
% Output
%   out: struct with run summary and per-target rows.

if nargin < 2 || isempty(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

validateattributes(targetBkGList, {'numeric'}, {'vector', 'real', 'finite'}, mfilename, 'targetBkGList', 1);
targetBkGList = targetBkGList(:);

if isempty(cfg.hFigAuto) || ~(ishandle(cfg.hFigAuto) || isgraphics(cfg.hFigAuto))
    error('BTControl:MissingAutoFigure', 'cfg.hFigAuto must be a valid T1_SemiAuto_ParamInput_v2_1 figure handle.');
end

if cfg.resetStopLatch
    clear_stop_b_field_queue(cfg);
end

hAuto = guidata(cfg.hFigAuto);
if ~isstruct(hAuto)
    error('BTControl:InvalidAutoHandles', 'guidata(cfg.hFigAuto) is invalid.');
end

hMainFig = cfg.hFigMain;
if isempty(hMainFig)
    if isfield(hAuto, 'hFigA')
        hMainFig = hAuto.hFigA;
    end
end
if isempty(hMainFig) || ~(ishandle(hMainFig) || isgraphics(hMainFig))
    error('BTControl:MissingMainFigure', 'Unable to resolve main v2.1 GUI handle. Set cfg.hFigMain.');
end
hMain = guidata(hMainFig);
if ~isstruct(hMain)
    error('BTControl:InvalidMainHandles', 'guidata(cfg.hFigMain) is invalid.');
end

cfgV2 = config();
bTag = 'edit_estimated_B_G';
if isfield(cfgV2, 'smart') && isfield(cfgV2.smart, 'ui') && isfield(cfgV2.smart.ui, 'tags') ...
        && isfield(cfgV2.smart.ui.tags, 'input') && isfield(cfgV2.smart.ui.tags.input, 'estimatedB')
    bTag = cfgV2.smart.ui.tags.input.estimatedB;
end

rows = repmat(struct( ...
    'index', 0, ...
    'targetBkG', NaN, ...
    'bEstimateG', NaN, ...
    'v21StartedAt', '', ...
    'status', '', ...
    'message', '', ...
    'analysisRows', repmat(struct( ...
        'date', '', ...
        'nArg', NaN, ...
        'group', '', ...
        'sequence', '', ...
        'spin', '', ...
        'B', NaN, ...
        'BMeasured', false, ...
        'saveString', ''), 0, 1), ...
    'magnetInfo', struct()), 0, 1);

out = struct();
out.startedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
out.finishedAt = '';
out.status = 'running';
out.stopReason = '';
out.targetsBkG = targetBkGList;
out.mode = cfg.mode;
out.rows = rows;
out.startLogPath = '';
out.analysisSnippetPath = '';
cleanupNotionCtx = onCleanup(@() clear_notion_upload_context()); %#ok<NASGU>

if cfg.writeStartLog
    [okLog, startLogPath, logErr] = prepare_start_log(cfg);
    if ~okLog
        out.status = 'failed';
        out.stopReason = logErr;
        out.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
        return;
    end
    out.startLogPath = startLogPath;
end

if cfg.writeAnalysisSnippet
    [okSnip, snippetPath, snipErr] = prepare_analysis_snippet(cfg);
    if ~okSnip
        out.status = 'failed';
        out.stopReason = snipErr;
        out.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
        return;
    end
    out.analysisSnippetPath = snippetPath;
end

for i = 1:numel(targetBkGList)
    BkG = targetBkGList(i);
    row = struct( ...
        'index', i, ...
        'targetBkG', BkG, ...
        'bEstimateG', BkG * cfg.bEstimateScale, ...
        'v21StartedAt', '', ...
        'status', 'running', ...
        'message', '', ...
        'analysisRows', repmat(struct( ...
            'date', '', ...
            'nArg', NaN, ...
            'group', '', ...
            'sequence', '', ...
            'spin', '', ...
            'B', NaN, ...
            'BMeasured', false, ...
            'saveString', ''), 0, 1), ...
        'magnetInfo', struct());

    [stopNow, stopWhy] = is_stop_requested(cfg, cfg.hFigAuto);
    if stopNow
        row.status = 'stopped';
        row.message = stopWhy;
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'stopped';
        out.stopReason = stopWhy;
        break;
    end

    skipFirstMagThisItem = logical(cfg.skipFirstMagControl) && (i == 1);
    if cfg.testModeNoBT
        log_msg(cfg, sprintf('Queue item %d/%d: test mode ON, skip set magnet to %.6g kG.', ...
            i, numel(targetBkGList), BkG));
        row.magnetInfo = struct('ok', true, 'skipped', true, 'message', 'Skipped magnet control in testModeNoBT.');
    elseif skipFirstMagThisItem
        log_msg(cfg, sprintf('Queue item %d/%d: skip first magnet check/control at %.6g kG (user requested).', ...
            i, numel(targetBkGList), BkG));
        row.magnetInfo = struct( ...
            'ok', true, ...
            'skipped', true, ...
            'message', 'Skipped first magnet control by cfg.skipFirstMagControl.', ...
            'skipReason', 'skipFirstMagControl');
    else
        log_msg(cfg, sprintf('Queue item %d/%d: set magnet to %.6g kG (%s).', ...
            i, numel(targetBkGList), BkG, cfg.mode));
        magCfg = cfg.magnetCfg;
        % Queue-level stop policy is always enforced during magnet control.
        magCfg.stopCheckEnabled = true;
        magCfg.stopAppDataKey = cfg.stopAppDataKey;
        magCfg.hFigAuto = cfg.hFigAuto;
        magCfg.verbose = cfg.verbose;
        if ~isfield(magCfg, 'stopWaitGranularitySec') || isempty(magCfg.stopWaitGranularitySec)
            magCfg.stopWaitGranularitySec = 2;
        end
        if ~isfield(magCfg, 'pollSec') || isempty(magCfg.pollSec)
            magCfg.pollSec = 1;
        end
        [okMag, msgMag, infoMag] = set_z_magnet_mode(BkG, cfg.mode, magCfg);
        row.magnetInfo = infoMag;
        if ~okMag
            [stopNowAfterMag, stopWhyAfterMag] = is_stop_requested(cfg, cfg.hFigAuto);
            if stopNowAfterMag || contains(lower(char(string(msgMag))), 'stop requested')
                row.status = 'stopped';
                row.message = sprintf('Magnet transition stopped: %s', msgMag);
                out.rows(end + 1, 1) = row; %#ok<AGROW>
                out.status = 'stopped';
                if isempty(strtrim(stopWhyAfterMag))
                    out.stopReason = row.message;
                else
                    out.stopReason = stopWhyAfterMag;
                end
                break;
            end
            row.status = 'failed';
            row.message = sprintf('Magnet set failed: %s', msgMag);
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'failed';
            out.stopReason = row.message;
            break;
        end
    end

    hAuto = guidata(cfg.hFigAuto);
    if ~isstruct(hAuto) || ~isfield(hAuto, bTag) || ~isgraphics(hAuto.(bTag), 'uicontrol')
        row.status = 'failed';
        row.message = sprintf('Cannot find v2.1 B_estimate control: %s', bTag);
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'failed';
        out.stopReason = row.message;
        break;
    end
    set(hAuto.(bTag), 'String', num2str(row.bEstimateG, '%.12g'));

    if isfield(hAuto, 'pushbutton_stopProg') && isgraphics(hAuto.pushbutton_stopProg, 'uicontrol')
        set(hAuto.pushbutton_stopProg, 'UserData', 0);
    end
    drawnow;

    [stopNow, stopWhy] = is_stop_requested(cfg, cfg.hFigAuto);
    if stopNow
        row.status = 'stopped';
        row.message = stopWhy;
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'stopped';
        out.stopReason = stopWhy;
        break;
    end

    row.v21StartedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    if cfg.writeStartLog
        [okLog, logErr] = append_start_log_row(out.startLogPath, i, row.targetBkG, row.bEstimateG, row.v21StartedAt, cfg.mode);
        if ~okLog
            row.status = 'failed';
            row.message = sprintf('Failed to write start log: %s', logErr);
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'failed';
            out.stopReason = row.message;
            break;
        end
    end
    log_msg(cfg, sprintf('Queue item %d/%d: run v2.1 automation (B_estimate=%.6g G).', ...
        i, numel(targetBkGList), row.bEstimateG));
    configure_notion_upload_context(cfg, row, i);
    try
        t1_semi_auto_program([], [], hMain, hAuto);
    catch ME
        row.status = 'failed';
        row.message = sprintf('v2.1 run failed: %s', ME.message);
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'failed';
        out.stopReason = row.message;
        break;
    end

    [stopNow, stopWhy] = is_stop_requested(cfg, cfg.hFigAuto);
    if stopNow
        row.status = 'stopped';
        row.message = stopWhy;
        out.rows(end + 1, 1) = row; %#ok<AGROW>
        out.status = 'stopped';
        out.stopReason = stopWhy;
        break;
    end

    row.status = 'success';
    row.message = 'Completed';
    row.analysisRows = capture_v2_analysis_rows(row.bEstimateG);
    out.rows(end + 1, 1) = row; %#ok<AGROW>

    if cfg.writeAnalysisSnippet && ~isempty(out.analysisSnippetPath)
        [okSnip, snipErr] = write_analysis_snippet(out.analysisSnippetPath, out.rows);
        if ~okSnip
            log_msg(cfg, sprintf('Analysis snippet update failed: %s', snipErr));
        end
    end
end

if strcmp(out.status, 'running')
    out.status = 'finished';
end
if cfg.writeAnalysisSnippet && ~isempty(out.analysisSnippetPath)
    [okSnip, snipErr] = write_analysis_snippet(out.analysisSnippetPath, out.rows);
    if ~okSnip
        log_msg(cfg, sprintf('Final analysis snippet update failed: %s', snipErr));
    end
end
out.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end

function cfg = apply_defaults(cfg)
fileCfg = bt_control_cfg_load('run_b_field_queue_v2_1');
cfg = set_default(cfg, 'mode', cfg_file_value(fileCfg, 'mode', 'driven'));
cfg = set_default(cfg, 'magnetCfg', cfg_file_value(fileCfg, 'magnetCfg', struct()));
cfg = set_default(cfg, 'hFigAuto', cfg_file_value(fileCfg, 'hFigAuto', []));
cfg = set_default(cfg, 'hFigMain', cfg_file_value(fileCfg, 'hFigMain', []));
cfg = set_default(cfg, 'bEstimateScale', cfg_file_value(fileCfg, 'bEstimateScale', 1000));
cfg = set_default(cfg, 'resetStopLatch', cfg_file_value(fileCfg, 'resetStopLatch', true));
cfg = set_default(cfg, 'stopAppDataKey', cfg_file_value(fileCfg, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE'));
cfg = set_default(cfg, 'writeStartLog', cfg_file_value(fileCfg, 'writeStartLog', true));
cfg = set_default(cfg, 'startLogPath', cfg_file_value(fileCfg, 'startLogPath', ''));
cfg = set_default(cfg, 'writeAnalysisSnippet', cfg_file_value(fileCfg, 'writeAnalysisSnippet', true));
cfg = set_default(cfg, 'analysisSnippetPath', cfg_file_value(fileCfg, 'analysisSnippetPath', ''));
cfg = set_default(cfg, 'writeNotionSequenceLog', cfg_file_value(fileCfg, 'writeNotionSequenceLog', false));
cfg = set_default(cfg, 'notionSpoolPath', cfg_file_value(fileCfg, 'notionSpoolPath', ''));
cfg = set_default(cfg, 'notionQueueLogPath', cfg_file_value(fileCfg, 'notionQueueLogPath', ''));
cfg = set_default(cfg, 'notionPageKey', cfg_file_value(fileCfg, 'notionPageKey', ''));
cfg = set_default(cfg, 'runRoot', cfg_file_value(fileCfg, 'runRoot', ''));
cfg = set_default(cfg, 'tbStepIndex', cfg_file_value(fileCfg, 'tbStepIndex', NaN));
cfg = set_default(cfg, 'tSetK', cfg_file_value(fileCfg, 'tSetK', NaN));
cfg = set_default(cfg, 'testModeNoBT', cfg_file_value(fileCfg, 'testModeNoBT', false));
cfg = set_default(cfg, 'skipFirstMagControl', cfg_file_value(fileCfg, 'skipFirstMagControl', false));
cfg = set_default(cfg, 'verbose', cfg_file_value(fileCfg, 'verbose', true));
end

function cfg = set_default(cfg, key, val)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = val;
end
end

function v = cfg_file_value(s, key, fallback)
if isstruct(s) && isfield(s, key) && ~isempty(s.(key))
    v = s.(key);
else
    v = fallback;
end
end

function [tf, reason] = is_stop_requested(cfg, hFigAuto)
tf = false;
reason = '';

try
    latched = getappdata(0, cfg.stopAppDataKey);
catch
    latched = false;
end
if ~isempty(latched) && logical(latched)
    tf = true;
    reason = 'Stop requested by request_stop_b_field_queue latch.';
    return;
end

if isempty(hFigAuto) || ~(ishandle(hFigAuto) || isgraphics(hFigAuto))
    return;
end

try
    hAuto = guidata(hFigAuto);
    if isstruct(hAuto) && isfield(hAuto, 'pushbutton_stopProg') && isgraphics(hAuto.pushbutton_stopProg, 'uicontrol')
        ud = get(hAuto.pushbutton_stopProg, 'UserData');
        if ~isempty(ud) && logical(ud)
            tf = true;
            reason = 'Stop requested by v2.1 stop button.';
            return;
        end
    end
catch
end
end

function log_msg(cfg, txt)
if isfield(cfg, 'verbose') && cfg.verbose
    fprintf('[run_b_field_queue_v2_1] %s\n', txt);
end
end

function [ok, startLogPath, errMsg] = prepare_start_log(cfg)
ok = false;
errMsg = '';
startLogPath = cfg.startLogPath;
if isempty(startLogPath)
    startLogPath = fullfile(pwd, sprintf('b_field_queue_start_log_%s.csv', datestr(now, 'yyyymmdd_HHMMSS')));
end

[fid, msg] = fopen(startLogPath, 'w');
if fid < 0
    errMsg = sprintf('Cannot create start log "%s": %s', startLogPath, msg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, 'index,targetBkG,bEstimateG,v21StartedAt,mode\n');
ok = true;
end

function [ok, errMsg] = append_start_log_row(startLogPath, index, targetBkG, bEstimateG, v21StartedAt, mode)
ok = false;
errMsg = '';
[fid, msg] = fopen(startLogPath, 'a');
if fid < 0
    errMsg = sprintf('Cannot open start log "%s": %s', startLogPath, msg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%d,%.12g,%.12g,"%s","%s"\n', index, targetBkG, bEstimateG, v21StartedAt, char(mode));
ok = true;
end

function [ok, snippetPath, errMsg] = prepare_analysis_snippet(cfg)
ok = false;
errMsg = '';
snippetPath = cfg.analysisSnippetPath;
if isempty(snippetPath)
    snippetPath = fullfile(pwd, sprintf('b_field_queue_analysis_snippet_%s.txt', datestr(now, 'yyyymmdd_HHMMSS')));
end

[folderPath, ~, ~] = fileparts(snippetPath);
if ~isempty(folderPath) && ~isfolder(folderPath)
    [mkOk, mkMsg, mkId] = mkdir(folderPath);
    if ~mkOk
        errMsg = sprintf('Cannot create snippet folder "%s": %s (%s)', folderPath, mkMsg, mkId);
        return;
    end
end

[ok, errMsg] = write_analysis_snippet(snippetPath, struct([]));
end

function [ok, errMsg] = write_analysis_snippet(snippetPath, rows)
ok = false;
errMsg = '';

[fid, msg] = fopen(snippetPath, 'w');
if fid < 0
    errMsg = sprintf('Cannot open snippet "%s": %s', snippetPath, msg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, '%% Minimal B queue analysis snippet\n');
fprintf(fid, '%% Generated at: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'));

entries = collect_all_analysis_entries(rows);
if isempty(entries)
    fprintf(fid, '%% No entries yet.\n');
    ok = true;
    return;
end

lastB = NaN;
for i = 1:numel(entries)
    e = entries(i);
    if i == 1 || ~(isfinite(lastB) && isfinite(e.B) && abs(lastB - e.B) < 1e-12)
        if i > 1
            fprintf(fid, '\n');
        end
        if isfinite(e.B)
            fprintf(fid, 'B = %.6f;\n', e.B);
        else
            fprintf(fid, 'B = NaN;\n');
        end
        lastB = e.B;
    end

    fprintf(fid, 'data.add_entry(''%s'', %d, B, T, ''%s'', ''%s'', ''%s'');\n', ...
        escape_single_quotes(e.date), round(e.nArg), ...
        escape_single_quotes(e.group), escape_single_quotes(e.sequence), escape_single_quotes(e.spin));
end

ok = true;
end

function entries = collect_all_analysis_entries(rows)
entries = repmat(struct( ...
    'date', '', ...
    'nArg', NaN, ...
    'group', '', ...
    'sequence', '', ...
    'spin', '', ...
    'B', NaN, ...
    'rowIndex', NaN, ...
    'entryIndex', NaN), 0, 1);

if nargin < 1 || isempty(rows)
    return;
end

for iRow = 1:numel(rows)
    r = rows(iRow);
    if ~isstruct(r) || ~isfield(r, 'analysisRows') || isempty(r.analysisRows)
        continue;
    end
    for iE = 1:numel(r.analysisRows)
        a = r.analysisRows(iE);
        if ~is_valid_analysis_entry(a)
            continue;
        end
        e = struct();
        e.date = char(string(a.date));
        e.nArg = double(a.nArg);
        e.group = char(string(a.group));
        e.sequence = char(string(a.sequence));
        e.spin = char(string(a.spin));
        e.B = double(a.B);
        e.rowIndex = iRow;
        e.entryIndex = iE;
        entries(end + 1, 1) = e; %#ok<AGROW>
    end
end
end

function tf = is_valid_analysis_entry(a)
tf = isstruct(a) && ...
    isfield(a, 'date') && ~isempty(char(string(a.date))) && ...
    isfield(a, 'nArg') && isfinite(double(a.nArg)) && ...
    isfield(a, 'group') && ~isempty(char(string(a.group))) && ...
    isfield(a, 'sequence') && ~isempty(char(string(a.sequence))) && ...
    isfield(a, 'spin') && ~isempty(char(string(a.spin))) && ...
    isfield(a, 'B') && isfinite(double(a.B));
end

function rows = capture_v2_analysis_rows(defaultB)
rows = repmat(struct( ...
    'date', '', ...
    'nArg', NaN, ...
    'group', '', ...
    'sequence', '', ...
    'spin', '', ...
    'B', NaN, ...
    'BMeasured', false, ...
    'saveString', ''), 0, 1);

global gmSEQ gSaveDataAve
if ~isstruct(gmSEQ) || ~isfield(gmSEQ, 'AnalysisEntries') || isempty(gmSEQ.AnalysisEntries)
    return;
end

bVal = defaultB;
bMeasured = false;
if isfield(gmSEQ, 'AnalysisMeasuredB') && isfinite(gmSEQ.AnalysisMeasuredB)
    bVal = double(gmSEQ.AnalysisMeasuredB);
    bMeasured = true;
end

entries = gmSEQ.AnalysisEntries;
for i = 1:numel(entries)
    e = entries(i);
    if ~isstruct(e) || ~isfield(e, 'nArg') || ~isfield(e, 'sequence') || ~isfield(e, 'spin')
        continue;
    end
    nArg = double(e.nArg);
    if ~isfinite(nArg)
        continue;
    end

    r = struct();
    if isfield(e, 'date')
        r.date = char(string(e.date));
    else
        r.date = '';
    end
    if isfield(e, 'group')
        r.group = char(string(e.group));
    else
        r.group = 'Aligned';
    end
    r.nArg = round(nArg);
    r.sequence = char(string(e.sequence));
    r.spin = char(string(e.spin));
    r.B = bVal;
    r.BMeasured = bMeasured;
    if isfield(e, 'saveString')
        r.saveString = normalize_save_string_stem(e.saveString);
    elseif isfield(gmSEQ, 'AnalysisSaveString')
        r.saveString = normalize_save_string_stem(gmSEQ.AnalysisSaveString);
    else
        r.saveString = normalize_save_string_stem(safe_struct_field(gSaveDataAve, 'file', ''));
    end
    rows(end + 1, 1) = r; %#ok<AGROW>
end
end

function out = normalize_save_string_stem(rawIn)
raw = char(string(rawIn));
if isempty(raw)
    out = '';
    return;
end
[~, stem, ~] = fileparts(raw);
out = char(string(stem));
end

function out = safe_struct_field(s, fieldName, fallback)
out = fallback;
if isstruct(s) && isfield(s, fieldName)
    out = s.(fieldName);
end
end

function out = escape_single_quotes(in)
out = char(string(in));
out = strrep(out, '''', '''''');
end

function configure_notion_upload_context(cfg, row, bIndex)
clear_notion_upload_context();
if ~isfield(cfg, 'writeNotionSequenceLog') || ~logical(cfg.writeNotionSequenceLog)
    return;
end
spoolPath = strtrim(char(string(safe_struct_field(cfg, 'notionSpoolPath', ''))));
if isempty(spoolPath)
    return;
end

ctx = struct();
ctx.enabled = true;
ctx.spoolPath = spoolPath;
ctx.queueLogPath = strtrim(char(string(safe_struct_field(cfg, 'notionQueueLogPath', ''))));
ctx.parentPageKey = strtrim(char(string(safe_struct_field(cfg, 'notionPageKey', ''))));
ctx.runRoot = strtrim(char(string(safe_struct_field(cfg, 'runRoot', ''))));
ctx.tbStepIndex = safe_struct_field(cfg, 'tbStepIndex', NaN);
ctx.tSetK = safe_struct_field(cfg, 'tSetK', NaN);
ctx.bItemIndex = bIndex;
ctx.targetBkG = safe_struct_field(row, 'targetBkG', NaN);
ctx.bEstimateG = safe_struct_field(row, 'bEstimateG', NaN);
ctx.setAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');

setappdata(0, 'V3_1_NOTION_UPLOAD_CONTEXT', ctx);
end

function clear_notion_upload_context()
if isappdata(0, 'V3_1_NOTION_UPLOAD_CONTEXT')
    rmappdata(0, 'V3_1_NOTION_UPLOAD_CONTEXT');
end
end
