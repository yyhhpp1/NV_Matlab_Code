function hFig = open_b_queue_minimal_gui()
%OPEN_B_QUEUE_MINIMAL_GUI Minimal GUI for B-field queue over v2.1 runs.
%   hFig = v3_1.open_b_queue_minimal_gui()
%
% Workflow:
%   1) Open v2.1 parameter GUI (T1_SemiAuto_ParamInput_v2_1) first.
%   2) In this GUI, click "Auto Detect v2.1 GUI" (or enter handle manually).
%   3) Enter B list in kG (comma/space/newline separated).
%   4) Click "Run Queue".
%   5) Click "Stop Queue" to request stop.

ensure_bt_control_on_path();

hFig = figure( ...
    'Name', 'v3.1 Minimal B Queue', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'HandleVisibility', 'callback', ...
    'Position', [100 100 760 520], ...
    'Resize', 'off');

ui = struct();
ui.txtB = uicontrol(hFig, 'Style', 'text', ...
    'Position', [20 470 180 20], ...
    'HorizontalAlignment', 'left', ...
    'String', 'B targets (kG):');
ui.editB = uicontrol(hFig, 'Style', 'edit', ...
    'Position', [20 430 720 40], ...
    'HorizontalAlignment', 'left', ...
    'String', '0.2, 0.5, 1.0', ...
    'Max', 3);

ui.txtMode = uicontrol(hFig, 'Style', 'text', ...
    'Position', [20 390 120 20], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Final mode:');
ui.popupMode = uicontrol(hFig, 'Style', 'popupmenu', ...
    'Position', [20 365 140 24], ...
    'String', {'driven','persistent'}, ...
    'Value', 1);

ui.txtScale = uicontrol(hFig, 'Style', 'text', ...
    'Position', [180 390 220 20], ...
    'HorizontalAlignment', 'left', ...
    'String', 'B_estimate scale (G per kG):');
ui.editScale = uicontrol(hFig, 'Style', 'edit', ...
    'Position', [180 365 120 24], ...
    'String', '1000');

ui.chkWriteLog = uicontrol(hFig, 'Style', 'checkbox', ...
    'Position', [320 367 180 20], ...
    'Value', 1, ...
    'String', 'Write start log CSV');
ui.txtLogPath = uicontrol(hFig, 'Style', 'text', ...
    'Position', [20 338 120 20], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Log path (optional):');
ui.editLogPath = uicontrol(hFig, 'Style', 'edit', ...
    'Position', [140 338 600 24], ...
    'HorizontalAlignment', 'left', ...
    'String', '');

ui.txtBind = uicontrol(hFig, 'Style', 'text', ...
    'Position', [20 305 240 20], ...
    'HorizontalAlignment', 'left', ...
    'String', 'v2.1 GUI handle (manual optional):');
ui.editHandle = uicontrol(hFig, 'Style', 'edit', ...
    'Position', [20 280 140 24], ...
    'HorizontalAlignment', 'left', ...
    'String', '');
ui.btnBindHandle = uicontrol(hFig, 'Style', 'pushbutton', ...
    'Position', [170 280 100 24], ...
    'String', 'Bind Handle', ...
    'Callback', @on_bind_handle);
ui.btnAutoDetect = uicontrol(hFig, 'Style', 'pushbutton', ...
    'Position', [280 280 150 24], ...
    'String', 'Auto Detect v2.1 GUI', ...
    'Callback', @on_auto_detect);

ui.txtBound = uicontrol(hFig, 'Style', 'text', ...
    'Position', [20 255 720 20], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Bound v2.1 GUI: (none)');

ui.btnRun = uicontrol(hFig, 'Style', 'pushbutton', ...
    'Position', [20 220 120 28], ...
    'String', 'Run Queue', ...
    'Callback', @on_run);
ui.btnStop = uicontrol(hFig, 'Style', 'pushbutton', ...
    'Position', [150 220 120 28], ...
    'String', 'Stop Queue', ...
    'Callback', @on_stop);
ui.btnClearStop = uicontrol(hFig, 'Style', 'pushbutton', ...
    'Position', [280 220 120 28], ...
    'String', 'Clear Stop', ...
    'Callback', @on_clear_stop);

ui.txtStatus = uicontrol(hFig, 'Style', 'text', ...
    'Position', [20 195 720 20], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Status: Idle');

ui.listLog = uicontrol(hFig, 'Style', 'listbox', ...
    'Position', [20 20 720 170], ...
    'String', {'[Info] Ready.'}, ...
    'Max', 2, ...
    'Min', 0);

state = struct();
state.ui = ui;
state.hFigAuto = [];
state.isRunning = false;
state.lastOut = struct();
guidata(hFig, state);

append_log(hFig, 'Open v2.1 param GUI first, then bind it here.');
end

function on_bind_handle(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
raw = strtrim(get(state.ui.editHandle, 'String'));
if isempty(raw)
    append_log(hFig, 'Manual handle is empty.');
    return;
end
h = str2double(raw);
if ~isfinite(h)
    append_log(hFig, sprintf('Invalid handle value: %s', raw));
    return;
end
if ~is_valid_v2_auto_fig(h)
    append_log(hFig, sprintf('Handle %.12g is not a valid v2.1 param GUI.', h));
    return;
end
bind_auto_fig(hFig, h);
end

function on_auto_detect(src, ~)
hFig = ancestor(src, 'figure');
[cands, labels] = find_v2_auto_figs();
if isempty(cands)
    append_log(hFig, 'No v2.1 param GUI detected.');
    return;
end
if numel(cands) == 1
    bind_auto_fig(hFig, cands(1));
    return;
end
[idx, ok] = listdlg('PromptString', 'Select v2.1 parameter GUI:', ...
    'SelectionMode', 'single', ...
    'ListString', labels);
if ~ok || isempty(idx)
    append_log(hFig, 'Auto detect canceled.');
    return;
end
bind_auto_fig(hFig, cands(idx));
end

function on_run(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
if state.isRunning
    append_log(hFig, 'Queue is already running.');
    return;
end
if isempty(state.hFigAuto) || ~is_valid_v2_auto_fig(state.hFigAuto)
    append_log(hFig, 'Bind a valid v2.1 GUI first.');
    return;
end

[okList, bList, listMsg] = parse_b_list(get(state.ui.editB, 'String'));
if ~okList
    append_log(hFig, listMsg);
    return;
end

scale = str2double(get(state.ui.editScale, 'String'));
if ~(isfinite(scale) && scale > 0)
    append_log(hFig, 'Invalid B_estimate scale (must be > 0).');
    return;
end

modeItems = get(state.ui.popupMode, 'String');
mode = modeItems{get(state.ui.popupMode, 'Value')};
writeLog = logical(get(state.ui.chkWriteLog, 'Value'));
startLogPath = strtrim(get(state.ui.editLogPath, 'String'));

runtimeCtx = struct();
runtimeCtx.hFigAuto = state.hFigAuto;
runtimeCtx.mode = mode;
runtimeCtx.bEstimateScale = scale;
runtimeCtx.writeStartLog = writeLog;
runtimeCtx.startLogPath = startLogPath;
runtimeCtx.verbose = true;

state.isRunning = true;
guidata(hFig, state);
set(state.ui.btnRun, 'Enable', 'off');
set(state.ui.txtStatus, 'String', 'Status: Running...');
drawnow;

append_log(hFig, sprintf('Run started: %d B points, mode=%s.', numel(bList), mode));
try
    out = v3_1.run_b_queue_minimal(bList, runtimeCtx);
    state = guidata(hFig);
    state.lastOut = out;
    state.isRunning = false;
    guidata(hFig, state);
    set(state.ui.btnRun, 'Enable', 'on');

    assignin('base', 'v3_1_b_queue_last_out', out);
    set(state.ui.txtStatus, 'String', sprintf('Status: %s', out.status));
    append_log(hFig, sprintf('Run finished with status: %s', out.status));
    if isfield(out, 'startLogPath') && ~isempty(out.startLogPath)
        append_log(hFig, sprintf('Start log: %s', out.startLogPath));
    end
catch ME
    state = guidata(hFig);
    state.isRunning = false;
    guidata(hFig, state);
    set(state.ui.btnRun, 'Enable', 'on');
    set(state.ui.txtStatus, 'String', 'Status: Failed');
    append_log(hFig, sprintf('Run failed: %s', ME.message));
end
end

function on_stop(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);

runtimeCtx = struct();
runtimeCtx.hFigAuto = state.hFigAuto;
runtimeCtx.verbose = true;
v3_1.request_stop_b_queue_minimal(runtimeCtx);

append_log(hFig, 'Stop requested.');
set(state.ui.txtStatus, 'String', 'Status: Stop requested');
end

function on_clear_stop(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);

runtimeCtx = struct();
runtimeCtx.hFigAuto = state.hFigAuto;
runtimeCtx.verbose = true;
v3_1.clear_stop_b_queue_minimal(runtimeCtx);

append_log(hFig, 'Stop latch cleared.');
end

function bind_auto_fig(hFig, hAuto)
state = guidata(hFig);
state.hFigAuto = hAuto;
guidata(hFig, state);
set(state.ui.editHandle, 'String', num2str(double(hAuto), '%.12g'));
set(state.ui.txtBound, 'String', sprintf('Bound v2.1 GUI: handle %.12g (%s)', ...
    double(hAuto), safe_fig_name(hAuto)));
append_log(hFig, sprintf('Bound v2.1 GUI handle %.12g.', double(hAuto)));
end

function [ok, vals, msg] = parse_b_list(raw)
ok = false;
vals = [];
msg = '';

if iscell(raw)
    raw = strjoin(raw, ' ');
end
if isempty(raw)
    msg = 'B list is empty.';
    return;
end
raw = strrep(raw, sprintf('\n'), ' ');
raw = strrep(raw, sprintf('\r'), ' ');
parts = regexp(raw, '[,;\s]+', 'split');
parts = parts(~cellfun(@isempty, parts));
if isempty(parts)
    msg = 'B list is empty.';
    return;
end

vals = nan(numel(parts), 1);
for i = 1:numel(parts)
    vals(i) = str2double(parts{i});
    if ~isfinite(vals(i))
        msg = sprintf('Invalid B token: %s', parts{i});
        vals = [];
        return;
    end
end
ok = true;
end

function append_log(hFig, txt)
state = guidata(hFig);
if isempty(state) || ~isfield(state, 'ui') || ~isfield(state.ui, 'listLog') || ~isgraphics(state.ui.listLog, 'uicontrol')
    return;
end
old = get(state.ui.listLog, 'String');
if ischar(old)
    old = {old};
end
line = sprintf('[%s] %s', datestr(now, 'HH:MM:SS'), txt);
new = [old; {line}];
if numel(new) > 1000
    new = new(end-999:end);
end
set(state.ui.listLog, 'String', new, 'Value', numel(new));
drawnow;
end

function [cands, labels] = find_v2_auto_figs()
figs = findall(0, 'Type', 'figure');
cands = [];
labels = {};
for i = 1:numel(figs)
    h = figs(i);
    if ~is_valid_v2_auto_fig(h)
        continue;
    end
    cands(end + 1, 1) = h; %#ok<AGROW>
    labels{end + 1, 1} = sprintf('%.12g - %s', double(h), safe_fig_name(h)); %#ok<AGROW>
end
end

function tf = is_valid_v2_auto_fig(h)
tf = false;
if isempty(h) || ~(ishandle(h) || isgraphics(h, 'figure'))
    return;
end
try
    gd = guidata(h);
    if ~isstruct(gd)
        return;
    end
    hasStart = isfield(gd, 'pushbutton_startProg') && isgraphics(gd.pushbutton_startProg, 'uicontrol');
    hasStop = isfield(gd, 'pushbutton_stopProg') && isgraphics(gd.pushbutton_stopProg, 'uicontrol');
    hasB = isfield(gd, 'edit_estimated_B_G') && isgraphics(gd.edit_estimated_B_G, 'uicontrol');
    tf = hasStart && hasStop && hasB;
catch
    tf = false;
end
end

function name = safe_fig_name(h)
name = '';
try
    name = get(h, 'Name');
catch
end
if isempty(name)
    name = '(unnamed figure)';
end
end

function ensure_bt_control_on_path()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);  % ...\AutoRunSequences_v3_1\+v3_1
rootDir = fileparts(thisDir);   % ...\AutoRunSequences_v3_1
btDir = fullfile(rootDir, 'BT_Control');

if exist('run_b_field_queue_v2_1', 'file') ~= 2
    if isfolder(btDir)
        addpath(btDir);
    end
end
end
