function out = run_b_queue_multispot(targetBkGList, cfg)
%RUN_B_QUEUE_MULTISPOT Minimal B-field queue runner for v2.2 + spots.
%   out = v3_2.run_b_queue_multispot(targetBkGList, cfg)
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
%       .masterDbPath      optional queue-level master DB CSV path
%       .masterWarningsPath optional warning log path paired with masterDbPath
%       .tempBaseCfg       temperature-controller connection cfg
%       .tempHistoryCfg    per-spot temperature-history save cfg
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
ensure_v2_2_path();

validateattributes(targetBkGList, {'numeric'}, {'vector', 'real', 'finite'}, mfilename, 'targetBkGList', 1);
targetBkGList = targetBkGList(:);

if isempty(cfg.hFigAuto) || ~(ishandle(cfg.hFigAuto) || isgraphics(cfg.hFigAuto))
    error('BTControl:MissingAutoFigure', 'cfg.hFigAuto must be a valid T1_SemiAuto_ParamInput_v2_2 figure handle.');
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
    error('BTControl:MissingMainFigure', 'Unable to resolve main v2.2 GUI handle. Set cfg.hFigMain.');
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
    'v22StartedAt', '', ...
    'status', '', ...
    'message', '', ...
    'masterDbRowsAdded', 0, ...
    'tempHistoryFilesSaved', 0, ...
    'tempHistoryWarnings', 0, ...
    'analysisRows', repmat(struct( ...
        'date', '', ...
        'nArg', NaN, ...
        'group', '', ...
        'family', '', ...
        'sequence', '', ...
        'spin', '', ...
        'B', NaN, ...
        'BMeasured', false, ...
        'saveString', '', ...
        'spotName', '', ...
        'spotOrder', NaN, ...
        'spotFolder', ''), 0, 1), ...
    'spotRuns', repmat(struct('spotName', '', 'spotOrder', NaN, 'spotFolder', '', 'status', '', 'message', '', ...
        'tempHistoryFilesSaved', 0, 'tempHistoryWarnings', 0, 'startedAt', '', 'finishedAt', '', ...
        'elapsedSec', NaN, 'failedStage', '', 'imageGuiScanRun', false, 'imageGuiScanMessage', '', ...
        'imageGuiScreenshotSaved', false, 'imageGuiScreenshotPath', '', 'imageGuiScreenshotMessage', ''), 0, 1), ...
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
        'v22StartedAt', '', ...
        'status', 'running', ...
        'message', '', ...
        'masterDbRowsAdded', 0, ...
        'tempHistoryFilesSaved', 0, ...
        'tempHistoryWarnings', 0, ...
        'analysisRows', repmat(struct( ...
            'date', '', ...
            'nArg', NaN, ...
            'group', '', ...
            'family', '', ...
            'sequence', '', ...
            'spin', '', ...
            'B', NaN, ...
            'BMeasured', false, ...
            'saveString', '', ...
            'spotName', '', ...
            'spotOrder', NaN, ...
            'spotFolder', ''), 0, 1), ...
        'spotRuns', repmat(struct('spotName', '', 'spotOrder', NaN, 'spotFolder', '', 'status', '', 'message', '', ...
            'tempHistoryFilesSaved', 0, 'tempHistoryWarnings', 0, 'startedAt', '', 'finishedAt', '', ...
            'elapsedSec', NaN, 'failedStage', '', 'imageGuiScanRun', false, 'imageGuiScanMessage', '', ...
            'imageGuiScreenshotSaved', false, 'imageGuiScreenshotPath', '', 'imageGuiScreenshotMessage', ''), 0, 1), ...
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
    if cfg.testModeNoBT || cfg.skipFieldControl
        log_msg(cfg, sprintf('Queue item %d/%d: skip magnet set to %.6g kG.', ...
            i, numel(targetBkGList), BkG));
        row.magnetInfo = struct('ok', true, 'skipped', true, ...
            'message', 'Skipped magnet control by runtime settings.', ...
            'testModeNoBT', logical(cfg.testModeNoBT), ...
            'skipFieldControl', logical(cfg.skipFieldControl));
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
        row.message = sprintf('Cannot find v2.2 B_estimate control: %s', bTag);
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

    row.v22StartedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    if cfg.writeStartLog
        [okLog, logErr] = append_start_log_row(out.startLogPath, i, row.targetBkG, row.bEstimateG, row.v22StartedAt, cfg.mode);
        if ~okLog
            row.status = 'failed';
            row.message = sprintf('Failed to write start log: %s', logErr);
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'failed';
            out.stopReason = row.message;
            break;
        end
    end
    log_msg(cfg, sprintf('Queue item %d/%d: run v2.2 automation (B_estimate=%.6g G).', ...
        i, numel(targetBkGList), row.bEstimateG));
    spotList = ordered_or_default_spots(cfg);
    allAnalysis = repmat(empty_analysis_row(), 0, 1);
    spotRuns = repmat(struct('spotName', '', 'spotOrder', NaN, 'spotFolder', '', 'status', '', 'message', '', ...
        'tempHistoryFilesSaved', 0, 'tempHistoryWarnings', 0, 'startedAt', '', 'finishedAt', '', ...
        'elapsedSec', NaN, 'failedStage', '', 'imageGuiScanRun', false, 'imageGuiScanMessage', '', ...
        'imageGuiScreenshotSaved', false, 'imageGuiScreenshotPath', '', 'imageGuiScreenshotMessage', ''), 0, 1);
    for iSpot = 1:numel(spotList)
        spot = spotList(iSpot);
        spotFolder = ensure_spot_run_folder(cfg, i, row.targetBkG, spot);
        spot.saveFolder = spotFolder;
        [okSpot, spotErr, spotRun, spotAnalysis, nAddedSpot] = execute_spot_with_command_log( ...
            cfg, hMain, hAuto, row, spot, spotFolder, i, numel(targetBkGList), iSpot, numel(spotList));
        if ~isempty(spotRun)
            spotRuns(end + 1, 1) = spotRun; %#ok<AGROW>
        end
        if ~isempty(spotAnalysis)
            allAnalysis = [allAnalysis; spotAnalysis]; %#ok<AGROW>
        end
        row.masterDbRowsAdded = row.masterDbRowsAdded + nAddedSpot;
        row.tempHistoryFilesSaved = row.tempHistoryFilesSaved + max(0, round(safe_struct_field(spotRun, 'tempHistoryFilesSaved', 0)));
        row.tempHistoryWarnings = row.tempHistoryWarnings + max(0, round(safe_struct_field(spotRun, 'tempHistoryWarnings', 0)));
        if ~okSpot
            row.status = 'failed';
            row.message = spotErr;
            row.spotRuns = spotRuns;
            row.analysisRows = allAnalysis;
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'failed';
            out.stopReason = row.message;
            break;
        end

        [stopNow, stopWhy] = is_stop_requested(cfg, cfg.hFigAuto);
        if stopNow
            row.status = 'stopped';
            row.message = stopWhy;
            row.spotRuns = spotRuns;
            row.analysisRows = allAnalysis;
            out.rows(end + 1, 1) = row; %#ok<AGROW>
            out.status = 'stopped';
            out.stopReason = stopWhy;
            break;
        end
    end
    if ~strcmp(row.status, 'running')
        break;
    end

    row.status = 'success';
    row.message = 'Completed';
    row.spotRuns = spotRuns;
    row.analysisRows = allAnalysis;
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
cfg = set_default(cfg, 'masterDbPath', cfg_file_value(fileCfg, 'masterDbPath', ''));
cfg = set_default(cfg, 'masterWarningsPath', cfg_file_value(fileCfg, 'masterWarningsPath', ''));
cfg = set_default(cfg, 'tempBaseCfg', cfg_file_value(fileCfg, 'tempBaseCfg', struct()));
cfg = set_default(cfg, 'tempHistoryCfg', cfg_file_value(fileCfg, 'tempHistoryCfg', struct()));
cfg = set_default(cfg, 'tbStepIndex', cfg_file_value(fileCfg, 'tbStepIndex', NaN));
cfg = set_default(cfg, 'tSetK', cfg_file_value(fileCfg, 'tSetK', NaN));
cfg = set_default(cfg, 'testModeNoBT', cfg_file_value(fileCfg, 'testModeNoBT', false));
cfg = set_default(cfg, 'skipTemperatureControl', false);
cfg = set_default(cfg, 'skipFieldControl', false);
cfg = set_default(cfg, 'skipFirstMagControl', cfg_file_value(fileCfg, 'skipFirstMagControl', false));
cfg = set_default(cfg, 'spots', repmat(v3_2.new_spot(), 0, 1));
cfg = set_default(cfg, 'spotSettleSec', 0.05);
cfg = set_default(cfg, 'hFigImage', []);
cfg = set_default(cfg, 'handlesImage', struct());
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
    fprintf('[run_b_queue_multispot] %s\n', txt);
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
fprintf(fid, 'index,targetBkG,bEstimateG,v22StartedAt,mode\n');
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

function spotList = ordered_or_default_spots(cfg)
if isfield(cfg, 'spots') && ~isempty(cfg.spots)
    spotList = cfg.spots;
    [~, ord] = sortrows([(1:numel(spotList))', [spotList.order]'], [2 1]);
    spotList = spotList(ord);
    for i = 1:numel(spotList)
        spotList(i).order = i;
    end
else
    spotList = default_current_spot();
end
end

function spot = default_current_spot()
spot = struct('id', 'current_spot', 'name', 'CurrentSpot', 'enabled', true, ...
    'order', 1, 'xV', NaN, 'yV', NaN, 'isCurrentPosition', true, 'saveFolder', '');
end

function row = empty_analysis_row()
row = struct('date', '', 'nArg', NaN, 'group', '', 'family', '', 'sequence', '', 'spin', '', ...
    'B', NaN, 'BMeasured', false, 'saveString', '', 'spotName', '', 'spotOrder', NaN, 'spotFolder', '');
end

function spotFolder = ensure_spot_run_folder(cfg, bIndex, targetBkG, spot)
base = char(string(safe_struct_field(cfg, 'runRoot', pwd)));
stepIdx = safe_struct_field(cfg, 'tbStepIndex', NaN);
tSetK = safe_struct_field(cfg, 'tSetK', NaN);
if isfinite(stepIdx)
    stepDir = sprintf('TStep_%02d_T_%sK', round(stepIdx), sanitize_name(num2str(tSetK, '%.6f')));
else
    stepDir = 'TStep_Unknown';
end
bDir = sprintf('B_%03d_%skG', round(bIndex), sanitize_name(num2str(targetBkG, '%.6f')));
if spot.isCurrentPosition
    spotDir = 'Spot_001_CurrentPosition';
else
    spotDir = sprintf('Spot_%03d_%s_X%s_Y%s', round(spot.order), sanitize_name(spot.name), ...
        sanitize_name(num2str(spot.xV, '%.6f')), sanitize_name(num2str(spot.yV, '%.6f')));
end
spotFolder = fullfile(base, stepDir, bDir, spotDir);
if ~isfolder(spotFolder)
    mkdir(spotFolder);
end
end

function [ok, errMsg, spotRun, spotAnalysis, nAddedSpot] = execute_spot_with_command_log(cfg, hMain, hAuto, row, spot, spotFolder, bIndex, nBTotal, spotIndex, nSpotTotal)
ok = false;
errMsg = '';
spotAnalysis = repmat(empty_analysis_row(), 0, 1);
nAddedSpot = 0;
spotRun = struct('spotName', safe_struct_field(spot, 'name', ''), ...
    'spotOrder', safe_struct_field(spot, 'order', NaN), ...
    'spotFolder', spotFolder, ...
    'status', 'failed', ...
    'message', '', ...
    'tempHistoryFilesSaved', 0, ...
    'tempHistoryWarnings', 0, ...
    'startedAt', '', ...
    'finishedAt', '', ...
    'elapsedSec', NaN, ...
    'failedStage', '', ...
    'imageGuiScanRun', false, ...
    'imageGuiScanMessage', '', ...
    'imageGuiScreenshotSaved', false, ...
    'imageGuiScreenshotPath', '', ...
    'imageGuiScreenshotMessage', '');

logPath = fullfile(spotFolder, 'matlab_command_output.log');
header = build_spot_command_log_header(row, spot, bIndex, nBTotal, spotIndex, nSpotTotal, spotFolder, cfg.tSetK);

cmdText = '';
okInner = false;
errInner = '';
spotRunInner = spotRun;
spotAnalysisInner = spotAnalysis;
nAddedInner = 0;
try
    cmdText = evalc('[okInner, errInner, spotRunInner, spotAnalysisInner, nAddedInner] = run_one_spot_inner(cfg, hMain, hAuto, row, spot, spotFolder, bIndex, nBTotal, spotIndex, nSpotTotal);');
catch ME
    errInner = ME.message;
    spotRunInner.message = errInner;
    cmdText = sprintf('Unexpected execute_spot_with_command_log failure:\n%s\n', getReport(ME, 'extended', 'hyperlinks', 'off'));
end

footer = build_spot_command_log_footer(okInner, errInner);
write_text_file(logPath, [header cmdText footer]);
write_spot_execution_reports(cfg, row, spot, spotFolder, spotRunInner, spotAnalysisInner, nAddedInner, logPath, cmdText, errInner, bIndex, nBTotal, spotIndex, nSpotTotal);

ok = okInner;
errMsg = errInner;
spotRun = spotRunInner;
spotAnalysis = spotAnalysisInner;
nAddedSpot = nAddedInner;
end

function [ok, errMsg, spotRun, spotAnalysis, nAddedSpot] = run_one_spot_inner(cfg, hMain, hAuto, row, spot, spotFolder, bIndex, nBTotal, spotIndex, nSpotTotal)
ok = false;
errMsg = '';
spotAnalysis = repmat(empty_analysis_row(), 0, 1);
nAddedSpot = 0;
spotRun = struct('spotName', safe_struct_field(spot, 'name', ''), ...
    'spotOrder', safe_struct_field(spot, 'order', NaN), ...
    'spotFolder', spotFolder, ...
    'status', 'failed', ...
    'message', '', ...
    'tempHistoryFilesSaved', 0, ...
    'tempHistoryWarnings', 0, ...
    'startedAt', '', ...
    'finishedAt', '', ...
    'elapsedSec', NaN, ...
    'failedStage', '', ...
    'imageGuiScanRun', false, ...
    'imageGuiScanMessage', '', ...
    'imageGuiScreenshotSaved', false, ...
    'imageGuiScreenshotPath', '', ...
    'imageGuiScreenshotMessage', '');
spotStartDn = now;
spotRun.startedAt = datestr(spotStartDn, 'yyyy-mm-dd HH:MM:SS.FFF');

try
    log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: begin "%s".', ...
        bIndex, nBTotal, spotIndex, nSpotTotal, safe_struct_field(spot, 'name', '')));
    if ~spot.isCurrentPosition
        spotRun.failedStage = 'move_to_spot';
        [okMove, msgMove] = v3_2.move_to_spot(spot, cfg);
        if ~okMove
            errMsg = sprintf('Spot move failed (%s): %s', spot.name, msgMove);
            spotRun.message = errMsg;
            [spotRun.tempHistoryFilesSaved, spotRun.tempHistoryWarnings] = ...
                save_temperature_history_for_spot(spotFolder, cfg, bIndex, row.bEstimateG, spotStartDn);
            spotRun.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
            spotRun.elapsedSec = max(0, (now - spotStartDn) * 86400);
            return;
        end
    else
        log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: use current position.', ...
            bIndex, nBTotal, spotIndex, nSpotTotal));
    end

    [spotRun.imageGuiScanRun, spotRun.imageGuiScanMessage] = run_image_gui_scan_for_spot(cfg);
    if spotRun.imageGuiScanRun
        log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: ImageNVC scan completed using current GUI settings.', ...
            bIndex, nBTotal, spotIndex, nSpotTotal));
    elseif ~isempty(strtrim(char(string(spotRun.imageGuiScanMessage))))
        log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: ImageNVC scan skipped: %s', ...
            bIndex, nBTotal, spotIndex, nSpotTotal, spotRun.imageGuiScanMessage));
    end

    [okFixMarker, msgFixMarker] = ensure_image_gui_fix_marker_for_spot(cfg, spot);
    if okFixMarker
        log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: refreshed ImageNVC Fix marker before screenshot.', ...
            bIndex, nBTotal, spotIndex, nSpotTotal));
    elseif ~isempty(strtrim(char(string(msgFixMarker))))
        log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: could not refresh ImageNVC Fix marker: %s', ...
            bIndex, nBTotal, spotIndex, nSpotTotal, msgFixMarker));
    end

    [spotRun.imageGuiScreenshotSaved, spotRun.imageGuiScreenshotPath, spotRun.imageGuiScreenshotMessage] = ...
        save_image_gui_snapshot_for_spot(cfg, spotFolder);
    if spotRun.imageGuiScreenshotSaved
        log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: saved ImageNVC GUI snapshot to "%s".', ...
            bIndex, nBTotal, spotIndex, nSpotTotal, spotRun.imageGuiScreenshotPath));
    elseif ~isempty(strtrim(char(string(spotRun.imageGuiScreenshotMessage))))
        log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: ImageNVC GUI snapshot skipped: %s', ...
            bIndex, nBTotal, spotIndex, nSpotTotal, spotRun.imageGuiScreenshotMessage));
    end

    configure_notion_upload_context(cfg, row, bIndex);
    spotRun.failedStage = 'v2_2_run';
    [okRun, runErr] = execute_v2_2_spot_run(hMain, hAuto, spotFolder, row, spot, bIndex, nBTotal, spotIndex, nSpotTotal, cfg);
    if ~okRun
        errMsg = sprintf('v2.2 run failed at spot %s: %s', spot.name, runErr);
        spotRun.message = errMsg;
        [spotRun.tempHistoryFilesSaved, spotRun.tempHistoryWarnings] = ...
            save_temperature_history_for_spot(spotFolder, cfg, bIndex, row.bEstimateG, spotStartDn);
        spotRun.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
        spotRun.elapsedSec = max(0, (now - spotStartDn) * 86400);
        return;
    end

    spotRun.status = 'success';
    spotRun.message = '';
    spotRun.failedStage = '';
    spotAnalysis = capture_v2_analysis_rows(row.bEstimateG, spot);
    if ~isempty(cfg.masterDbPath)
        spotRun.failedStage = 'master_db_append';
        [nAddedSpot, ~] = v3_2.master_db_append_rows( ...
            cfg.masterDbPath, cfg.masterWarningsPath, row.bEstimateG, cfg.tSetK, spotAnalysis);
        if nAddedSpot > 0
            log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: appended %d master DB rows.', ...
                bIndex, nBTotal, spotIndex, nSpotTotal, nAddedSpot));
        elseif ~isempty(spotAnalysis)
            log_msg(cfg, sprintf('Queue item %d/%d spot %d/%d: no master DB rows appended.', ...
                bIndex, nBTotal, spotIndex, nSpotTotal));
        end
    end

    [spotRun.tempHistoryFilesSaved, spotRun.tempHistoryWarnings] = ...
        save_temperature_history_for_spot(spotFolder, cfg, bIndex, row.bEstimateG, spotStartDn);

    ok = true;
    spotRun.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    spotRun.elapsedSec = max(0, (now - spotStartDn) * 86400);
    spotRun.failedStage = '';
catch ME
    errMsg = ME.message;
    spotRun.message = errMsg;
    [spotRun.tempHistoryFilesSaved, spotRun.tempHistoryWarnings] = ...
        save_temperature_history_for_spot(spotFolder, cfg, bIndex, row.bEstimateG, spotStartDn);
    spotRun.finishedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    spotRun.elapsedSec = max(0, (now - spotStartDn) * 86400);
    disp(getReport(ME, 'extended', 'hyperlinks', 'off'));
end
end

function write_spot_execution_reports(cfg, row, spot, spotFolder, spotRun, spotAnalysis, nAddedSpot, commandLogPath, cmdText, errMsg, bIndex, nBTotal, spotIndex, nSpotTotal)
reportsRoot = fullfile(spotFolder, 'reports');
spotReportDir = fullfile(reportsRoot, 'spot');
failureDir = fullfile(reportsRoot, 'failures');
if ~isfolder(spotReportDir)
    mkdir(spotReportDir);
end
if ~isfolder(failureDir)
    mkdir(failureDir);
end

summaryPath = fullfile(spotReportDir, 'queue_spot_summary.txt');
write_text_file(summaryPath, build_spot_summary_text(cfg, row, spot, spotFolder, spotRun, spotAnalysis, nAddedSpot, commandLogPath, bIndex, nBTotal, spotIndex, nSpotTotal));

if ~strcmpi(char(string(safe_struct_field(spotRun, 'status', 'failed'))), 'success')
    failurePath = fullfile(failureDir, 'spot_failure_report.txt');
    write_text_file(failurePath, build_spot_failure_report_text(cfg, row, spot, spotFolder, spotRun, commandLogPath, cmdText, errMsg, bIndex, nBTotal, spotIndex, nSpotTotal));
end
end

function txt = build_spot_summary_text(cfg, row, spot, spotFolder, spotRun, spotAnalysis, nAddedSpot, commandLogPath, bIndex, nBTotal, spotIndex, nSpotTotal)
lines = { ...
    '==== v3.2 Spot Summary ====', ...
    sprintf('GeneratedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('Status: %s', char(string(safe_struct_field(spotRun, 'status', '')))), ...
    sprintf('Message: %s', char(string(safe_struct_field(spotRun, 'message', '')))), ...
    sprintf('StartedAt: %s', char(string(safe_struct_field(spotRun, 'startedAt', '')))), ...
    sprintf('FinishedAt: %s', char(string(safe_struct_field(spotRun, 'finishedAt', '')))), ...
    sprintf('ElapsedSec: %.6f', double(safe_struct_field(spotRun, 'elapsedSec', NaN))), ...
    sprintf('FailedStage: %s', char(string(safe_struct_field(spotRun, 'failedStage', '')))), ...
    '', ...
    'QueueContext:', ...
    sprintf('  TStepIndex: %s', format_numeric_token(safe_struct_field(cfg, 'tbStepIndex', NaN))), ...
    sprintf('  QueueBIndex: %d/%d', bIndex, nBTotal), ...
    sprintf('  QueueSpotIndex: %d/%d', spotIndex, nSpotTotal), ...
    sprintf('  TSet_K: %s', format_numeric_token(safe_struct_field(cfg, 'tSetK', NaN))), ...
    sprintf('  TargetB_kG: %s', format_numeric_token(safe_struct_field(row, 'targetBkG', NaN))), ...
    sprintf('  BEstimate_G: %s', format_numeric_token(safe_struct_field(row, 'bEstimateG', NaN))), ...
    sprintf('  TestModeNoBT: %s', bool_text(safe_struct_field(cfg, 'testModeNoBT', false))), ...
    sprintf('  SkipTemperatureControl: %s', bool_text(safe_struct_field(cfg, 'skipTemperatureControl', false))), ...
    sprintf('  SkipFieldControl: %s', bool_text(safe_struct_field(cfg, 'skipFieldControl', false))), ...
    '', ...
    'SpotContext:', ...
    sprintf('  SpotName: %s', char(string(safe_struct_field(spot, 'name', '')))), ...
    sprintf('  SpotOrder: %s', format_numeric_token(safe_struct_field(spot, 'order', NaN))), ...
    sprintf('  SpotX_V: %s', format_numeric_token(safe_struct_field(spot, 'xV', NaN))), ...
    sprintf('  SpotY_V: %s', format_numeric_token(safe_struct_field(spot, 'yV', NaN))), ...
    sprintf('  IsCurrentPosition: %s', bool_text(safe_struct_field(spot, 'isCurrentPosition', false))), ...
    sprintf('  SpotFolder: %s', spotFolder), ...
    '', ...
    'Artifacts:', ...
    sprintf('  CommandLog: %s', commandLogPath), ...
    sprintf('  ImageNVCScanRun: %s', bool_text(safe_struct_field(spotRun, 'imageGuiScanRun', false))), ...
    sprintf('  ImageNVCScanMessage: %s', char(string(safe_struct_field(spotRun, 'imageGuiScanMessage', '')))), ...
    sprintf('  ImageNVCScreenshotSaved: %s', bool_text(safe_struct_field(spotRun, 'imageGuiScreenshotSaved', false))), ...
    sprintf('  ImageNVCScreenshotPath: %s', char(string(safe_struct_field(spotRun, 'imageGuiScreenshotPath', '')))), ...
    sprintf('  ImageNVCScreenshotMessage: %s', char(string(safe_struct_field(spotRun, 'imageGuiScreenshotMessage', '')))), ...
    sprintf('  ReportsRoot: %s', fullfile(spotFolder, 'reports')), ...
    sprintf('  MeasurementsFinalReports: %s', fullfile(spotFolder, 'reports', 'measurements', 'final')), ...
    sprintf('  MeasurementsIntermediateReports: %s', fullfile(spotFolder, 'reports', 'measurements', 'intermediate_precal_rough')), ...
    sprintf('  PiCalReports: %s', fullfile(spotFolder, 'reports', 'pical')), ...
    sprintf('  FailureReports: %s', fullfile(spotFolder, 'reports', 'failures')), ...
    sprintf('  TemperatureHistoryFolder: %s', fullfile(spotFolder, 'temperature_history')), ...
    '', ...
    'PostProcessing:', ...
    sprintf('  MasterDbRowsAdded: %d', max(0, round(nAddedSpot))), ...
    sprintf('  TemperatureHistoryFilesSaved: %d', max(0, round(safe_struct_field(spotRun, 'tempHistoryFilesSaved', 0)))), ...
    sprintf('  TemperatureHistoryWarnings: %d', max(0, round(safe_struct_field(spotRun, 'tempHistoryWarnings', 0)))), ...
    '', ...
    'AnalysisRows:'};
if isempty(spotAnalysis)
    lines{end + 1} = '  none'; %#ok<AGROW>
else
    for i = 1:numel(spotAnalysis)
        a = spotAnalysis(i);
        lines{end + 1} = sprintf('  [%d] family=%s sequence=%s spin=%s group=%s save=%s B=%s', ...
            i, char(string(safe_struct_field(a, 'family', ''))), ...
            char(string(safe_struct_field(a, 'sequence', ''))), ...
            char(string(safe_struct_field(a, 'spin', ''))), ...
            char(string(safe_struct_field(a, 'group', ''))), ...
            char(string(safe_struct_field(a, 'saveString', ''))), ...
            format_numeric_token(safe_struct_field(a, 'B', NaN))); %#ok<AGROW>
    end
end
txt = sprintf('%s\n', lines{:});
end

function txt = build_spot_failure_report_text(cfg, row, spot, spotFolder, spotRun, commandLogPath, cmdText, errMsg, bIndex, nBTotal, spotIndex, nSpotTotal)
lines = { ...
    '==== v3.2 Spot Failure Report ====', ...
    sprintf('GeneratedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('Status: %s', char(string(safe_struct_field(spotRun, 'status', 'failed')))), ...
    sprintf('FailedStage: %s', char(string(safe_struct_field(spotRun, 'failedStage', '')))), ...
    sprintf('ErrorMessage: %s', char(string(errMsg))), ...
    sprintf('StartedAt: %s', char(string(safe_struct_field(spotRun, 'startedAt', '')))), ...
    sprintf('FinishedAt: %s', char(string(safe_struct_field(spotRun, 'finishedAt', '')))), ...
    sprintf('ElapsedSec: %.6f', double(safe_struct_field(spotRun, 'elapsedSec', NaN))), ...
    '', ...
    'QueueContext:', ...
    sprintf('  TStepIndex: %s', format_numeric_token(safe_struct_field(cfg, 'tbStepIndex', NaN))), ...
    sprintf('  QueueBIndex: %d/%d', bIndex, nBTotal), ...
    sprintf('  QueueSpotIndex: %d/%d', spotIndex, nSpotTotal), ...
    sprintf('  TSet_K: %s', format_numeric_token(safe_struct_field(cfg, 'tSetK', NaN))), ...
    sprintf('  TargetB_kG: %s', format_numeric_token(safe_struct_field(row, 'targetBkG', NaN))), ...
    sprintf('  BEstimate_G: %s', format_numeric_token(safe_struct_field(row, 'bEstimateG', NaN))), ...
    sprintf('  SpotName: %s', char(string(safe_struct_field(spot, 'name', '')))), ...
    sprintf('  SpotFolder: %s', spotFolder), ...
    sprintf('  CommandLogPath: %s', commandLogPath), ...
    '', ...
    '---- command output excerpt begin ----'}.';
excerpt = tail_lines_local(cmdText, 80);
if isempty(excerpt)
    lines{end + 1} = '(no captured output)'; %#ok<AGROW>
else
    excerptLines = regexp(char(string(excerpt)), '\r\n|\n|\r', 'split');
    lines = [lines; excerptLines(:)]; %#ok<AGROW>
end
lines{end + 1} = '---- command output excerpt end ----'; %#ok<AGROW>
txt = sprintf('%s\n', lines{:});
end

function txt = build_spot_command_log_header(row, spot, bIndex, nBTotal, spotIndex, nSpotTotal, spotFolder, tSetK)
lines = { ...
    '==== MATLAB Command Output Log ====', ...
    sprintf('StartedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('BIndex: %d/%d', bIndex, nBTotal), ...
    sprintf('SpotIndex: %d/%d', spotIndex, nSpotTotal), ...
    sprintf('TargetBkG: %.12g', safe_struct_field(row, 'targetBkG', NaN)), ...
    sprintf('BEstimateG: %.12g', safe_struct_field(row, 'bEstimateG', NaN)), ...
    sprintf('TSetK: %.12g', tSetK), ...
    sprintf('SpotName: %s', safe_struct_field(spot, 'name', '')), ...
    sprintf('SpotOrder: %s', format_numeric_token(safe_struct_field(spot, 'order', NaN))), ...
    sprintf('SpotXV: %s', format_numeric_token(safe_struct_field(spot, 'xV', NaN))), ...
    sprintf('SpotYV: %s', format_numeric_token(safe_struct_field(spot, 'yV', NaN))), ...
    sprintf('SpotFolder: %s', spotFolder), ...
    '---- begin captured output ----', ...
    ''};
txt = sprintf('%s\n', lines{:});
end

function txt = build_spot_command_log_footer(ok, errMsg)
status = 'success';
if ~ok
    status = 'failed';
end
lines = { ...
    '', ...
    '---- end captured output ----', ...
    sprintf('FinishedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('Status: %s', status)};
if ~isempty(strtrim(char(string(errMsg))))
    lines{end + 1} = sprintf('Error: %s', char(string(errMsg))); %#ok<AGROW>
end
txt = sprintf('%s\n', lines{:});
end

function write_text_file(pathOut, txt)
[fid, msg] = fopen(pathOut, 'w');
if fid < 0
    fprintf('[run_b_queue_multispot] cannot write command log "%s": %s\n', pathOut, msg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s', char(string(txt)));
end

function out = format_numeric_token(v)
vv = double(v);
if isfinite(vv)
    out = num2str(vv, '%.12g');
else
    out = 'NaN';
end
end

function out = bool_text(v)
try
    out = ternary_local(logical(v), 'true', 'false');
catch
    out = 'false';
end
end

function out = ternary_local(cond, a, b)
if logical(cond)
    out = a;
else
    out = b;
end
end

function out = tail_lines_local(txt, nLines)
out = '';
if nargin < 2 || ~isfinite(nLines) || nLines <= 0
    nLines = 40;
end
raw = char(string(txt));
if isempty(raw)
    return;
end
parts = regexp(raw, '\r\n|\n|\r', 'split');
if isempty(parts)
    out = raw;
    return;
end
i0 = max(1, numel(parts) - round(nLines) + 1);
out = strjoin(parts(i0:end), newline);
end

function [ok, msg] = run_image_gui_scan_for_spot(cfg)
ok = false;
msg = '';
figImage = resolve_image_gui_figure(cfg);
if isempty(figImage) || ~isgraphics(figImage, 'figure')
    msg = 'ImageNVC GUI figure is not bound.';
    return;
end
handlesImage = safe_struct_field(cfg, 'handlesImage', struct());
if isempty(handlesImage) || ~isstruct(handlesImage)
    try
        handlesImage = guidata(figImage);
    catch
        handlesImage = struct();
    end
end
if isempty(handlesImage) || ~isstruct(handlesImage)
    msg = 'ImageNVC handles are unavailable.';
    return;
end
try
    ImageFunctionPool('Scan', figImage, [], handlesImage);
    ok = true;
catch ME
    msg = ME.message;
end
end

function [ok, msg] = ensure_image_gui_fix_marker_for_spot(cfg, spot)
ok = false;
msg = '';
figImage = resolve_image_gui_figure(cfg);
if isempty(figImage) || ~isgraphics(figImage, 'figure')
    msg = 'ImageNVC GUI figure is not bound.';
    return;
end
try
    handlesImage = guidata(figImage);
catch
    handlesImage = struct();
end
if isempty(handlesImage) || ~isstruct(handlesImage)
    msg = 'ImageNVC handles are unavailable.';
    return;
end
if ~(isfield(handlesImage, 'FixVx') && isfield(handlesImage, 'FixVy'))
    msg = 'ImageNVC FixVx/FixVy controls are missing.';
    return;
end
try
    if nargin >= 2 && isstruct(spot)
        if isfield(spot, 'xV') && isfinite(spot.xV)
            set(handlesImage.FixVx, 'String', num2str(spot.xV, '%.6f'));
        end
        if isfield(spot, 'yV') && isfinite(spot.yV)
            set(handlesImage.FixVy, 'String', num2str(spot.yV, '%.6f'));
        end
    end
    ImageFunctionPool('Fix', figImage, [], handlesImage);
    pause(field_or(cfg, 'spotSettleSec', 0.05));
    ok = true;
catch ME
    msg = ME.message;
end
end

function [ok, imagePath, msg] = save_image_gui_snapshot_for_spot(cfg, spotFolder)
ok = false;
imagePath = '';
msg = '';
figImage = resolve_image_gui_figure(cfg);
if isempty(figImage) || ~isgraphics(figImage, 'figure')
    msg = 'ImageNVC GUI figure is not bound.';
    return;
end
imagePath = fullfile(spotFolder, 'ImageNVC_GUI.png');
try
    drawnow;
    frameImage = getframe(figImage);
    if isstruct(frameImage) && isfield(frameImage, 'cdata') && ~isempty(frameImage.cdata)
        imwrite(frameImage.cdata, imagePath);
        ok = true;
        msg = '';
    else
        msg = 'ImageNVC GUI frame is empty.';
        imagePath = '';
    end
catch ME
    msg = ME.message;
    imagePath = '';
end
end

function figH = resolve_image_gui_figure(cfg)
figH = [];
if isstruct(cfg) && isfield(cfg, 'hFigImage') && ~isempty(cfg.hFigImage) && isgraphics(cfg.hFigImage, 'figure')
    figH = cfg.hFigImage;
    return;
end
handlesImage = safe_struct_field(cfg, 'handlesImage', struct());
candidateFields = {'output', 'FixVx', 'FixVy'};
for i = 1:numel(candidateFields)
    f = candidateFields{i};
    if isstruct(handlesImage) && isfield(handlesImage, f) && ~isempty(handlesImage.(f)) && isgraphics(handlesImage.(f))
        figCand = ancestor(handlesImage.(f), 'figure');
        if ~isempty(figCand) && isgraphics(figCand, 'figure')
            figH = figCand;
            return;
        end
    end
end
end

function [nFiles, nWarn] = save_temperature_history_for_spot(spotFolder, cfg, bIndex, bSetG, spotStartDn)
nFiles = 0;
nWarn = 0;

histCfg = safe_struct_field(cfg, 'tempHistoryCfg', struct());
if ~logical(safe_struct_field(histCfg, 'enabled', true))
    return;
end

tcBase = safe_struct_field(cfg, 'tempBaseCfg', struct());
tcIp = strtrim(char(string(safe_struct_field(tcBase, 'tcIp', ''))));
if isempty(tcIp)
    append_warning_line_local(safe_struct_field(cfg, 'masterWarningsPath', ''), ...
        sprintf('Spot temperature history skipped (b=%d, folder="%s"): tempBaseCfg.tcIp is empty.', bIndex, spotFolder));
    nWarn = nWarn + 1;
    return;
end

channels = double(safe_struct_field(histCfg, 'channels', [3 8]));
channels = unique(round(channels(isfinite(channels))));
channels = channels(channels >= 1);
if isempty(channels)
    append_warning_line_local(safe_struct_field(cfg, 'masterWarningsPath', ''), ...
        sprintf('Spot temperature history skipped (b=%d, folder="%s"): no valid channels configured.', bIndex, spotFolder));
    nWarn = nWarn + 1;
    return;
end

baseLookbackHours = double(safe_struct_field(histCfg, 'maxLoopbackHours', safe_struct_field(histCfg, 'lookbackHours', 0.5)));
if ~isfinite(baseLookbackHours) || baseLookbackHours <= 0
    baseLookbackHours = 0.5;
end
actualSpotHours = max(0, (now - spotStartDn) * 24);
lookbackHours = max(actualSpotHours, baseLookbackHours);
lookbackMin = lookbackHours * 60;

estOffsetH = double(safe_struct_field(histCfg, 'estUtcOffsetHours', -5));
if ~isfinite(estOffsetH)
    estOffsetH = -5;
end
savePlotPng = logical(safe_struct_field(histCfg, 'savePlotPng', true));

readCfg = struct();
readCfg.connectTimeoutSec = min(double(safe_struct_field(tcBase, 'tcConnectTimeoutSec', 20)), 5);
readCfg.responseTimeoutSec = min(double(safe_struct_field(tcBase, 'tcResponseTimeoutSec', 30)), 5);

pointDir = fullfile(spotFolder, 'temperature_history');
if ~isfolder(pointDir)
    [okMk, msgMk, idMk] = mkdir(pointDir);
    if ~okMk
        append_warning_line_local(safe_struct_field(cfg, 'masterWarningsPath', ''), ...
            sprintf('Spot temperature history folder create failed "%s": %s (%s)', pointDir, msgMk, idMk));
        nWarn = nWarn + 1;
        return;
    end
end

for iCh = 1:numel(channels)
    ch = channels(iCh);
    [okHist, tempK, tsPosix, msgHist] = bf_tc_read_channel_history(tcIp, ch, lookbackMin, readCfg);
    if ~okHist
        append_warning_line_local(safe_struct_field(cfg, 'masterWarningsPath', ''), ...
            sprintf('Spot temperature history read failed (folder="%s", ch=%d): %s', spotFolder, ch, msgHist));
        nWarn = nWarn + 1;
        continue;
    end
    if isempty(tempK) || isempty(tsPosix)
        append_warning_line_local(safe_struct_field(cfg, 'masterWarningsPath', ''), ...
            sprintf('Spot temperature history empty (folder="%s", ch=%d).', spotFolder, ch));
        nWarn = nWarn + 1;
        continue;
    end

    dtUtc = datetime(tsPosix, 'ConvertFrom', 'posixtime', 'TimeZone', 'UTC');
    dtEst = dtUtc + hours(estOffsetH);
    dtEst.TimeZone = '';

    txtPath = fullfile(pointDir, sprintf('ch%d_T_vs_time_EST.txt', ch));
    [okTxt, txtErr] = write_channel_history_txt_local(txtPath, ch, dtEst, tempK, lookbackHours, actualSpotHours, ...
        safe_struct_field(cfg, 'tSetK', NaN), bSetG, estOffsetH);
    if ~okTxt
        append_warning_line_local(safe_struct_field(cfg, 'masterWarningsPath', ''), ...
            sprintf('Spot temperature history TXT save failed (folder="%s", ch=%d): %s', spotFolder, ch, txtErr));
        nWarn = nWarn + 1;
    else
        nFiles = nFiles + 1;
    end

    if savePlotPng
        pngPath = fullfile(pointDir, sprintf('ch%d_T_vs_time_EST.png', ch));
        [okPng, pngErr] = save_channel_history_plot_png_local(pngPath, ch, dtEst, tempK, ...
            safe_struct_field(cfg, 'tSetK', NaN), bSetG, estOffsetH, actualSpotHours);
        if ~okPng
            append_warning_line_local(safe_struct_field(cfg, 'masterWarningsPath', ''), ...
                sprintf('Spot temperature history plot save failed (folder="%s", ch=%d): %s', spotFolder, ch, pngErr));
            nWarn = nWarn + 1;
        else
            nFiles = nFiles + 1;
        end
    end
end
end

function [ok, errMsg] = write_channel_history_txt_local(txtPath, ch, dtEst, tempK, lookbackHours, actualSpotHours, tSetK, bSetG, estOffsetH)
ok = false;
errMsg = '';
[fid, msg] = fopen(txtPath, 'w');
if fid < 0
    errMsg = sprintf('Cannot open "%s": %s', txtPath, msg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, '# Channel: %d\n', ch);
fprintf(fid, '# Time zone: EST (UTC%+.0f)\n', estOffsetH);
fprintf(fid, '# LookbackHoursUsed: %.6g\n', lookbackHours);
fprintf(fid, '# SpotElapsedHours: %.6g\n', actualSpotHours);
fprintf(fid, '# T_set_K: %.12g\n', double(tSetK));
fprintf(fid, '# B_set_G: %.12g\n', double(bSetG));
fprintf(fid, '# GeneratedAt: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'));
fprintf(fid, 'time_EST\ttemperature_K\n');
for i = 1:numel(tempK)
    tStr = datestr(dtEst(i), 'yyyy-mm-dd HH:MM:SS');
    fprintf(fid, '%s\t%.12g\n', tStr, double(tempK(i)));
end
ok = true;
end

function [ok, errMsg] = save_channel_history_plot_png_local(pngPath, ch, dtEst, tempK, tSetK, bSetG, estOffsetH, actualSpotHours)
ok = false;
errMsg = '';
h = [];
try
    h = figure('Visible', 'off', 'Color', 'w');
    x = datenum(dtEst);
    plot(x, tempK, '-', 'LineWidth', 1.2);
    grid on;
    datetick('x', 'yyyy-mm-dd HH:MM', 'keeplimits');
    xlabel(sprintf('Time (EST, UTC%+.0f)', estOffsetH));
    ylabel(sprintf('CH%d Temperature (K)', ch));
    title(sprintf('CH%d T vs Time | Tset=%.6g K | Bset=%.6g G | SpotHours=%.4g', ...
        ch, double(tSetK), double(bSetG), actualSpotHours));
    saveas(h, pngPath);
    ok = true;
catch ME
    errMsg = ME.message;
end
if ~isempty(h) && isgraphics(h)
    close(h);
end
end

function append_warning_line_local(warningsPath, msg)
if isempty(warningsPath)
    fprintf('[run_b_queue_multispot] %s\n', char(string(msg)));
    return;
end
[fid, fopenMsg] = fopen(warningsPath, 'a');
if fid < 0
    fprintf('[run_b_queue_multispot] warning log write failed (%s): %s\n', warningsPath, fopenMsg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '[%s] %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'), char(string(msg)));
end

function clear_run_save_folder_override()
if isappdata(0, 'SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE')
    rmappdata(0, 'SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE');
end
end

function clear_v2_2_spot_report_context()
if isappdata(0, 'SMART_V2_2_SPOT_REPORT_CONTEXT')
    rmappdata(0, 'SMART_V2_2_SPOT_REPORT_CONTEXT');
end
end

function [ok, errMsg] = execute_v2_2_spot_run(hMain, hAuto, spotFolder, row, spot, bIndex, nBTotal, spotIndex, nSpotTotal, cfg)
ok = false;
errMsg = '';
try
    if isstruct(hAuto) && isfield(hAuto, 'output') && (ishandle(hAuto.output) || isgraphics(hAuto.output))
        hAuto = guidata(hAuto.output);
    end
    if isstruct(hMain) && isfield(hMain, 'output') && (ishandle(hMain.output) || isgraphics(hMain.output))
        hMain = guidata(hMain.output);
    end
    if isstruct(hAuto) && isfield(hAuto, 'pushbutton_stopProg') && isgraphics(hAuto.pushbutton_stopProg, 'uicontrol')
        set(hAuto.pushbutton_stopProg, 'UserData', 0);
    end
    hObjectA = safe_struct_field(hAuto, 'hObjectA', []);
    eventdataA = safe_struct_field(hAuto, 'eventdataA', []);
    spotCtx = struct('tSetK', safe_struct_field(cfg, 'tSetK', NaN), ...
        'targetBkG', safe_struct_field(row, 'targetBkG', NaN), ...
        'bEstimateG', safe_struct_field(row, 'bEstimateG', NaN), ...
        'spotName', safe_struct_field(spot, 'name', ''), ...
        'spotOrder', safe_struct_field(spot, 'order', NaN), ...
        'spotX_V', safe_struct_field(spot, 'xV', NaN), ...
        'spotY_V', safe_struct_field(spot, 'yV', NaN), ...
        'spotFolder', spotFolder, ...
        'tbStepIndex', safe_struct_field(cfg, 'tbStepIndex', NaN), ...
        'bIndex', bIndex, ...
        'nBTotal', nBTotal, ...
        'spotIndex', spotIndex, ...
        'nSpotTotal', nSpotTotal, ...
        'skipTemperatureControl', safe_struct_field(cfg, 'testModeNoBT', false) || safe_struct_field(cfg, 'skipTemperatureControl', false), ...
        'skipFieldControl', safe_struct_field(cfg, 'testModeNoBT', false) || safe_struct_field(cfg, 'skipFieldControl', false), ...
        'testModeNoBT', safe_struct_field(cfg, 'testModeNoBT', false));
    setappdata(0, 'SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE', spotFolder);
    setappdata(0, 'SMART_V2_2_SPOT_REPORT_CONTEXT', spotCtx);
    cleanupSaveFolder = onCleanup(@() clear_run_save_folder_override()); %#ok<NASGU>
    cleanupSpotContext = onCleanup(@() clear_v2_2_spot_report_context()); %#ok<NASGU>
    t1_semi_auto_program_v3_2(hObjectA, eventdataA, hMain, hAuto);
    ok = true;
catch ME
    errMsg = ME.message;
    disp(getReport(ME, 'extended', 'hyperlinks', 'off'));
end
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

function rows = capture_v2_analysis_rows(defaultB, spot)
rows = repmat(struct( ...
    'date', '', ...
    'nArg', NaN, ...
    'group', '', ...
    'family', '', ...
    'sequence', '', ...
    'spin', '', ...
    'B', NaN, ...
    'BMeasured', false, ...
    'saveString', '', ...
    'spotName', '', ...
    'spotOrder', NaN, ...
    'spotFolder', ''), 0, 1);

if nargin < 2 || isempty(spot)
    spot = default_current_spot();
end

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
    if isfield(e, 'family')
        r.family = char(string(e.family));
    else
        r.family = '';
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
    r.spotName = safe_struct_field(spot, 'name', '');
    r.spotOrder = safe_struct_field(spot, 'order', NaN);
    r.spotFolder = safe_struct_field(spot, 'saveFolder', '');
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

function out = sanitize_name(raw)
out = regexprep(char(string(raw)), '[^a-zA-Z0-9_\-]', '_');
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

function ensure_v2_2_path()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);
repoRoot = fileparts(fileparts(thisDir));
v2Dir = fullfile(repoRoot, 'AutoRunSequences_v2_2');
if isfolder(v2Dir)
    addpath(v2Dir, '-end');
end
end
