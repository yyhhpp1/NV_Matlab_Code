function hFig = open_tb_queue_minimal_gui()
%OPEN_TB_QUEUE_MINIMAL_GUI Minimal GUI for T->B queue execution.
%   hFig = v3_1.open_tb_queue_minimal_gui()
%
% Queue model:
%   Each row is one temperature step with its own PID and B list.
%   Runner executes:
%       set T(step1) -> run all B(step1)
%       set T(step2) -> run all B(step2)
%       ...

ensure_bt_control_on_path();

hFig = figure( ...
    'Name', 'v3.1 Minimal T->B Queue', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'HandleVisibility', 'callback', ...
    'Position', [80 80 1080 700], ...
    'Resize', 'off', ...
    'CloseRequestFcn', @on_close_figure);

ui = struct();

% Step input panel
uicontrol(hFig, 'Style', 'text', 'Position', [20 664 120 18], ...
    'HorizontalAlignment', 'left', 'String', 'Queue Step Input');
uicontrol(hFig, 'Style', 'text', 'Position', [20 638 50 18], ...
    'HorizontalAlignment', 'left', 'String', 'T (K):');
ui.editT = uicontrol(hFig, 'Style', 'edit', 'Position', [70 636 80 22], 'String', '10');
uicontrol(hFig, 'Style', 'text', 'Position', [170 638 50 18], ...
    'HorizontalAlignment', 'left', 'String', 'PID P:');
ui.editPidP = uicontrol(hFig, 'Style', 'edit', 'Position', [220 636 80 22], 'String', '1');
uicontrol(hFig, 'Style', 'text', 'Position', [320 638 50 18], ...
    'HorizontalAlignment', 'left', 'String', 'PID I:');
ui.editPidI = uicontrol(hFig, 'Style', 'edit', 'Position', [370 636 80 22], 'String', '0');
uicontrol(hFig, 'Style', 'text', 'Position', [470 638 50 18], ...
    'HorizontalAlignment', 'left', 'String', 'PID D:');
ui.editPidD = uicontrol(hFig, 'Style', 'edit', 'Position', [520 636 80 22], 'String', '0');
uicontrol(hFig, 'Style', 'text', 'Position', [620 638 130 18], ...
    'HorizontalAlignment', 'left', 'String', 'B list (kG):');
ui.editB = uicontrol(hFig, 'Style', 'edit', 'Position', [700 636 360 22], ...
    'HorizontalAlignment', 'left', 'String', '0.2, 0.5, 1.0');

ui.btnAdd = uicontrol(hFig, 'Style', 'pushbutton', 'Position', [20 604 110 24], ...
    'String', 'Add Step', 'Callback', @on_add_step);
ui.btnReplace = uicontrol(hFig, 'Style', 'pushbutton', 'Position', [140 604 150 24], ...
    'String', 'Replace Selected', 'Callback', @on_replace_step);
ui.btnRemove = uicontrol(hFig, 'Style', 'pushbutton', 'Position', [300 604 130 24], ...
    'String', 'Remove Selected', 'Callback', @on_remove_step);
ui.btnClear = uicontrol(hFig, 'Style', 'pushbutton', 'Position', [440 604 90 24], ...
    'String', 'Clear', 'Callback', @on_clear_steps);

uicontrol(hFig, 'Style', 'text', 'Position', [20 578 260 18], ...
    'HorizontalAlignment', 'left', 'String', 'Queue (executes top -> bottom):');
ui.listQueue = uicontrol(hFig, 'Style', 'listbox', ...
    'Position', [20 390 1040 186], 'String', {'(empty)'}, 'Max', 1, 'Min', 0);

% Runtime controls
uicontrol(hFig, 'Style', 'text', 'Position', [20 362 220 18], ...
    'HorizontalAlignment', 'left', 'String', 'Runtime Settings');

uicontrol(hFig, 'Style', 'text', 'Position', [20 336 80 18], ...
    'HorizontalAlignment', 'left', 'String', 'tcIp:');
ui.editTcIp = uicontrol(hFig, 'Style', 'edit', 'Position', [100 334 140 22], ...
    'HorizontalAlignment', 'left', 'String', '192.168.0.116');
uicontrol(hFig, 'Style', 'text', 'Position', [260 336 80 18], ...
    'HorizontalAlignment', 'left', 'String', 'magIp:');
ui.editMagIp = uicontrol(hFig, 'Style', 'edit', 'Position', [340 334 140 22], ...
    'HorizontalAlignment', 'left', 'String', '192.168.0.101');
uicontrol(hFig, 'Style', 'text', 'Position', [500 336 100 18], ...
    'HorizontalAlignment', 'left', 'String', 'Mag mode:');
ui.popupMode = uicontrol(hFig, 'Style', 'popupmenu', 'Position', [600 334 120 22], ...
    'String', {'driven', 'persistent'}, 'Value', 1);
uicontrol(hFig, 'Style', 'text', 'Position', [740 336 170 18], ...
    'HorizontalAlignment', 'left', 'String', 'B_est scale (G/kG):');
ui.editScale = uicontrol(hFig, 'Style', 'edit', 'Position', [910 334 150 22], 'String', '1000');

uicontrol(hFig, 'Style', 'text', 'Position', [20 308 90 18], ...
    'HorizontalAlignment', 'left', 'String', 'T_safe_max:');
ui.editTSafe = uicontrol(hFig, 'Style', 'edit', 'Position', [110 306 70 22], 'String', '8');
uicontrol(hFig, 'Style', 'text', 'Position', [200 308 60 18], ...
    'HorizontalAlignment', 'left', 'String', 'T_tol:');
ui.editTTol = uicontrol(hFig, 'Style', 'edit', 'Position', [260 306 70 22], 'String', '0.02');
uicontrol(hFig, 'Style', 'text', 'Position', [350 308 70 18], ...
    'HorizontalAlignment', 'left', 'String', 'holdSec:');
ui.editHold = uicontrol(hFig, 'Style', 'edit', 'Position', [420 306 70 22], 'String', '30');
uicontrol(hFig, 'Style', 'text', 'Position', [510 308 90 18], ...
    'HorizontalAlignment', 'left', 'String', 'maxWaitSec:');
ui.editMaxWait = uicontrol(hFig, 'Style', 'edit', 'Position', [600 306 90 22], 'String', '1800');
uicontrol(hFig, 'Style', 'text', 'Position', [710 308 70 18], ...
    'HorizontalAlignment', 'left', 'String', 'pollSec:');
ui.editPoll = uicontrol(hFig, 'Style', 'edit', 'Position', [780 306 70 22], 'String', '1');
uicontrol(hFig, 'Style', 'text', 'Position', [870 308 90 18], ...
    'HorizontalAlignment', 'left', 'String', 'magPort:');
ui.editMagPort = uicontrol(hFig, 'Style', 'edit', 'Position', [960 306 100 22], 'String', '7185');

% v2.1 binding
uicontrol(hFig, 'Style', 'text', 'Position', [20 276 260 18], ...
    'HorizontalAlignment', 'left', 'String', 'v2.1 GUI handle (required):');
ui.editHandle = uicontrol(hFig, 'Style', 'edit', 'Position', [20 252 120 22], ...
    'HorizontalAlignment', 'left', 'String', '');
ui.btnBindHandle = uicontrol(hFig, 'Style', 'pushbutton', ...
    'Position', [150 252 100 22], 'String', 'Bind', 'Callback', @on_bind_handle);
ui.btnAutoDetect = uicontrol(hFig, 'Style', 'pushbutton', ...
    'Position', [260 252 140 22], 'String', 'Auto Detect v2.1', 'Callback', @on_auto_detect);
ui.txtBound = uicontrol(hFig, 'Style', 'text', ...
    'Position', [420 252 640 22], 'HorizontalAlignment', 'left', 'String', 'Bound v2.1 GUI: (none)');

% Run controls
ui.btnRun = uicontrol(hFig, 'Style', 'pushbutton', 'Position', [20 214 120 28], ...
    'String', 'Run Queue', 'Callback', @on_run_queue);
ui.btnStop = uicontrol(hFig, 'Style', 'pushbutton', 'Position', [150 214 120 28], ...
    'String', 'Stop Queue', 'Callback', @on_stop_queue);
ui.btnClearStop = uicontrol(hFig, 'Style', 'pushbutton', 'Position', [280 214 120 28], ...
    'String', 'Clear Stop', 'Callback', @on_clear_stop);
ui.txtStatus = uicontrol(hFig, 'Style', 'text', ...
    'Position', [420 214 640 24], 'HorizontalAlignment', 'left', 'String', 'Status: Idle');

ui.listLog = uicontrol(hFig, 'Style', 'listbox', ...
    'Position', [20 20 1040 184], 'String', {'[Info] Ready.'}, 'Max', 2, 'Min', 0);

state = struct();
state.ui = ui;
state.hFigAuto = [];
state.queueSteps = repmat(empty_queue_step(), 0, 1);
state.isRunning = false;
state.lastOut = struct();
state.stateFile = get_tb_queue_state_file();
guidata(hFig, state);

[okRestore, restoreMsg] = restore_tb_queue_state(hFig);

append_log(hFig, 'Add at least one T step with B list, bind v2.1 GUI, then run.');
if okRestore
    append_log(hFig, 'Restored previous minimal BT queue state.');
elseif ~isempty(restoreMsg)
    append_log(hFig, sprintf('State restore skipped: %s', restoreMsg));
end
refresh_queue_list(hFig);
end

function on_add_step(src, ~)
hFig = ancestor(src, 'figure');
[ok, step, msg] = read_step_from_inputs(hFig);
if ~ok
    append_log(hFig, msg);
    return;
end
state = guidata(hFig);
state.queueSteps(end + 1, 1) = step; %#ok<AGROW>
guidata(hFig, state);
refresh_queue_list(hFig);
append_log(hFig, sprintf('Added step: T=%.6g K with %d B points.', step.T_K, numel(step.bListkG)));
end

function on_replace_step(src, ~)
hFig = ancestor(src, 'figure');
[ok, step, msg] = read_step_from_inputs(hFig);
if ~ok
    append_log(hFig, msg);
    return;
end
state = guidata(hFig);
if isempty(state.queueSteps)
    append_log(hFig, 'Queue is empty.');
    return;
end
idx = get(state.ui.listQueue, 'Value');
idx = max(1, min(idx, numel(state.queueSteps)));
state.queueSteps(idx) = step;
guidata(hFig, state);
refresh_queue_list(hFig);
append_log(hFig, sprintf('Replaced step #%d.', idx));
end

function on_remove_step(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
if isempty(state.queueSteps)
    append_log(hFig, 'Queue is empty.');
    return;
end
idx = get(state.ui.listQueue, 'Value');
idx = max(1, min(idx, numel(state.queueSteps)));
state.queueSteps(idx) = [];
guidata(hFig, state);
refresh_queue_list(hFig);
append_log(hFig, sprintf('Removed step #%d.', idx));
end

function on_clear_steps(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
state.queueSteps = repmat(empty_queue_step(), 0, 1);
guidata(hFig, state);
refresh_queue_list(hFig);
append_log(hFig, 'Queue cleared.');
end

function on_bind_handle(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
raw = strtrim(get(state.ui.editHandle, 'String'));
if isempty(raw)
    append_log(hFig, 'Handle is empty.');
    return;
end
h = str2double(raw);
if ~isfinite(h)
    append_log(hFig, sprintf('Invalid handle: %s', raw));
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
    append_log(hFig, 'No v2.1 parameter GUI detected.');
    return;
end
if numel(cands) == 1
    bind_auto_fig(hFig, cands(1));
    return;
end
[idx, ok] = listdlg('PromptString', 'Select v2.1 parameter GUI:', ...
    'SelectionMode', 'single', 'ListString', labels);
if ~ok || isempty(idx)
    append_log(hFig, 'Auto detect canceled.');
    return;
end
bind_auto_fig(hFig, cands(idx));
end

function on_run_queue(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
if state.isRunning
    append_log(hFig, 'Queue is already running.');
    return;
end
if isempty(state.queueSteps)
    append_log(hFig, 'Queue is empty.');
    return;
end
if isempty(state.hFigAuto) || ~is_valid_v2_auto_fig(state.hFigAuto)
    append_log(hFig, 'Bind a valid v2.1 GUI first.');
    return;
end

[okCfg, runtimeCtx, msgCfg] = build_runtime_ctx(hFig);
if ~okCfg
    append_log(hFig, msgCfg);
    return;
end
runtimeCtx.hFigAuto = state.hFigAuto;

state.isRunning = true;
guidata(hFig, state);
set(state.ui.btnRun, 'Enable', 'off');
set(state.ui.txtStatus, 'String', 'Status: Running...');
drawnow;

append_log(hFig, sprintf('Run started: %d T steps.', numel(state.queueSteps)));
try
    out = v3_1.run_tb_queue_minimal(state.queueSteps, runtimeCtx);
    state = guidata(hFig);
    state.lastOut = out;
    state.isRunning = false;
    guidata(hFig, state);
    set(state.ui.btnRun, 'Enable', 'on');
    set(state.ui.txtStatus, 'String', sprintf('Status: %s', out.status));
    append_log(hFig, sprintf('Run finished: %s', out.status));
    stopReason = '';
    if isstruct(out) && isfield(out, 'stopReason')
        stopReason = strtrim(char(string(out.stopReason)));
    end
    if (strcmpi(out.status, 'failed') || strcmpi(out.status, 'stopped')) && ~isempty(stopReason)
        append_log(hFig, sprintf('Reason: %s', stopReason));
    end
    assignin('base', 'v3_1_tb_queue_last_out', out);
catch ME
    state = guidata(hFig);
    state.isRunning = false;
    guidata(hFig, state);
    set(state.ui.btnRun, 'Enable', 'on');
    topLoc = '';
    if ~isempty(ME.stack)
        topLoc = sprintf('%s:%d', ME.stack(1).name, ME.stack(1).line);
    end
    errMsg = strtrim(char(string(ME.message)));
    if isempty(errMsg)
        errMsg = '(empty MATLAB exception message)';
    end
    if ~isempty(topLoc)
        set(state.ui.txtStatus, 'String', sprintf('Status: Failed (%s)', topLoc));
        append_log(hFig, sprintf('Run failed at %s: %s', topLoc, errMsg));
    else
        set(state.ui.txtStatus, 'String', 'Status: Failed');
        append_log(hFig, sprintf('Run failed: %s', errMsg));
    end
    if ~isempty(ME.identifier)
        append_log(hFig, sprintf('Error ID: %s', ME.identifier));
    end
end
end

function on_stop_queue(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
runtimeCtx = struct('hFigAuto', state.hFigAuto, 'verbose', true);
v3_1.request_stop_b_queue_minimal(runtimeCtx);
append_log(hFig, 'Stop requested.');
set(state.ui.txtStatus, 'String', 'Status: Stop requested');
end

function on_clear_stop(src, ~)
hFig = ancestor(src, 'figure');
state = guidata(hFig);
runtimeCtx = struct('hFigAuto', state.hFigAuto, 'verbose', true);
v3_1.clear_stop_b_queue_minimal(runtimeCtx);
append_log(hFig, 'Stop latch cleared.');
end

function [ok, runtimeCtx, msg] = build_runtime_ctx(hFig)
ok = false;
runtimeCtx = struct();
msg = '';
state = guidata(hFig);

tcIp = strtrim(get(state.ui.editTcIp, 'String'));
magIp = strtrim(get(state.ui.editMagIp, 'String'));
if isempty(tcIp) || isempty(magIp)
    msg = 'tcIp and magIp are required.';
    return;
end

T_safe_max = str2double(get(state.ui.editTSafe, 'String'));
T_tol = str2double(get(state.ui.editTTol, 'String'));
holdSec = str2double(get(state.ui.editHold, 'String'));
maxWaitSec = str2double(get(state.ui.editMaxWait, 'String'));
pollSec = str2double(get(state.ui.editPoll, 'String'));
magPort = str2double(get(state.ui.editMagPort, 'String'));
scale = str2double(get(state.ui.editScale, 'String'));

if ~(isfinite(T_safe_max) && isfinite(T_tol) && isfinite(holdSec) && ...
        isfinite(maxWaitSec) && isfinite(pollSec) && isfinite(magPort) && isfinite(scale) && scale > 0)
    msg = 'Invalid runtime numeric fields.';
    return;
end

modeItems = get(state.ui.popupMode, 'String');
mode = modeItems{get(state.ui.popupMode, 'Value')};

tempBaseCfg = struct();
tempBaseCfg.tcIp = tcIp;
tempBaseCfg.magIp = magIp;
tempBaseCfg.T_safe_max = T_safe_max;
tempBaseCfg.T_tol = T_tol;
tempBaseCfg.holdSec = holdSec;
tempBaseCfg.maxWaitSec = maxWaitSec;
tempBaseCfg.pollSec = pollSec;
tempBaseCfg.lookbackMin = 5;
tempBaseCfg.commRetryCount = 3;
tempBaseCfg.commRetryBackoffSec = 0.5;
tempBaseCfg.tcConnectTimeoutSec = 20;
tempBaseCfg.tcResponseTimeoutSec = 30;
tempBaseCfg.magPort = round(magPort);
tempBaseCfg.magTimeoutSec = 3;
tempBaseCfg.verbose = false;

runtimeCtx.mode = mode;
runtimeCtx.magnetCfg = struct('ip', magIp, 'port', round(magPort), 'verbose', true);
runtimeCtx.bEstimateScale = scale;
runtimeCtx.tempBaseCfg = tempBaseCfg;
runtimeCtx.resetStopLatch = true;
runtimeCtx.stopAppDataKey = 'BT_CONTROL_STOP_B_QUEUE';
runtimeCtx.writeStartLog = false;
runtimeCtx.writeAnalysisSnippet = false;
runtimeCtx.verbose = true;

ok = true;
end

function refresh_queue_list(hFig)
state = guidata(hFig);
if isempty(state.queueSteps)
    set(state.ui.listQueue, 'String', {'(empty)'}, 'Value', 1);
    return;
end
lines = cell(numel(state.queueSteps), 1);
for i = 1:numel(state.queueSteps)
    s = state.queueSteps(i);
    lines{i} = sprintf('%02d) T=%.6g K | PID=[%.6g, %.6g, %.6g] | B(kG)=[%s]', ...
        i, s.T_K, s.pidP, s.pidI, s.pidD, compact_vec(s.bListkG));
end
set(state.ui.listQueue, 'String', lines, 'Value', min(get(state.ui.listQueue, 'Value'), numel(lines)));
end

function [ok, step, msg] = read_step_from_inputs(hFig)
ok = false;
step = empty_queue_step();
msg = '';
state = guidata(hFig);

T = str2double(get(state.ui.editT, 'String'));
P = str2double(get(state.ui.editPidP, 'String'));
I = str2double(get(state.ui.editPidI, 'String'));
D = str2double(get(state.ui.editPidD, 'String'));
[okB, bVals, msgB] = parse_num_list(get(state.ui.editB, 'String'));
if ~(isfinite(T) && isfinite(P) && isfinite(I) && isfinite(D))
    msg = 'Invalid T or PID values.';
    return;
end
if ~okB
    msg = msgB;
    return;
end
step.T_K = T;
step.pidP = P;
step.pidI = I;
step.pidD = D;
step.bListkG = bVals(:).';
ok = true;
end

function step = empty_queue_step()
step = struct('T_K', NaN, 'pidP', NaN, 'pidI', NaN, 'pidD', NaN, 'bListkG', []);
end

function [ok, vals, msg] = parse_num_list(raw)
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
        vals = [];
        msg = sprintf('Invalid numeric token: %s', parts{i});
        return;
    end
end
ok = true;
end

function out = compact_vec(v)
if isempty(v)
    out = '';
    return;
end
parts = arrayfun(@(x) num2str(x, '%.6g'), v(:).', 'UniformOutput', false);
out = strjoin(parts, ', ');
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

function tf = is_valid_v2_auto_fig(hFig)
tf = false;
if isempty(hFig) || ~(ishandle(hFig) || isgraphics(hFig))
    return;
end
try
    name = get(hFig, 'Name');
    h = guidata(hFig);
    tf = isstruct(h) && isfield(h, 'pushbutton_startProg') && ...
        isgraphics(h.pushbutton_startProg, 'uicontrol') && ...
        (contains(lower(char(name)), 'paraminput') || contains(lower(char(name)), 't1_semiauto'));
catch
    tf = false;
end
end

function [cands, labels] = find_v2_auto_figs()
figs = findall(0, 'Type', 'figure');
cands = [];
labels = {};
for i = 1:numel(figs)
    h = figs(i);
    if is_valid_v2_auto_fig(h)
        cands(end + 1, 1) = h; %#ok<AGROW>
        labels{end + 1, 1} = sprintf('%.12g  %s', double(h), safe_fig_name(h)); %#ok<AGROW>
    end
end
end

function name = safe_fig_name(hFig)
name = '(unnamed)';
try
    nm = get(hFig, 'Name');
    if isstring(nm) || ischar(nm)
        name = char(nm);
    end
catch
end
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
if numel(new) > 2000
    new = new(end-1999:end);
end
set(state.ui.listLog, 'String', new, 'Value', numel(new));
drawnow;
end

function on_close_figure(src, ~)
hFig = ancestor(src, 'figure');
[okSave, msgSave] = save_tb_queue_state(hFig);
if ~okSave && ~isempty(msgSave)
    try
        append_log(hFig, sprintf('State save failed: %s', msgSave));
    catch
    end
end
delete(hFig);
end

function stateFile = get_tb_queue_state_file()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);               % ...\+v3_1
stateFile = fullfile(thisDir, 'tb_queue_minimal_state.mat');
end

function [ok, msg] = save_tb_queue_state(hFig)
ok = false;
msg = '';
if isempty(hFig) || ~(ishandle(hFig) || isgraphics(hFig))
    msg = 'Invalid figure handle.';
    return;
end
state = guidata(hFig);
if isempty(state) || ~isstruct(state) || ~isfield(state, 'ui')
    msg = 'GUI state not initialized.';
    return;
end
stateFile = '';
if isfield(state, 'stateFile')
    stateFile = char(string(state.stateFile));
end
if isempty(stateFile)
    stateFile = get_tb_queue_state_file();
end

savedState = struct();
savedState.queueSteps = state.queueSteps;
savedState.values = struct();
savedState.values.editT = get_string_safe(state.ui, 'editT', '10');
savedState.values.editPidP = get_string_safe(state.ui, 'editPidP', '1');
savedState.values.editPidI = get_string_safe(state.ui, 'editPidI', '0');
savedState.values.editPidD = get_string_safe(state.ui, 'editPidD', '0');
savedState.values.editB = get_string_safe(state.ui, 'editB', '0.2, 0.5, 1.0');
savedState.values.editTcIp = get_string_safe(state.ui, 'editTcIp', '192.168.0.116');
savedState.values.editMagIp = get_string_safe(state.ui, 'editMagIp', '192.168.0.101');
savedState.values.popupMode = get_popup_value_safe(state.ui, 'popupMode', 1);
savedState.values.editScale = get_string_safe(state.ui, 'editScale', '1000');
savedState.values.editTSafe = get_string_safe(state.ui, 'editTSafe', '8');
savedState.values.editTTol = get_string_safe(state.ui, 'editTTol', '0.02');
savedState.values.editHold = get_string_safe(state.ui, 'editHold', '30');
savedState.values.editMaxWait = get_string_safe(state.ui, 'editMaxWait', '1800');
savedState.values.editPoll = get_string_safe(state.ui, 'editPoll', '1');
savedState.values.editMagPort = get_string_safe(state.ui, 'editMagPort', '7185');
savedState.values.editHandle = get_string_safe(state.ui, 'editHandle', '');
savedState.savedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');

try
    save(stateFile, 'savedState');
    ok = true;
catch ME
    msg = ME.message;
end
end

function [ok, msg] = restore_tb_queue_state(hFig)
ok = false;
msg = '';
state = guidata(hFig);
if isempty(state) || ~isstruct(state) || ~isfield(state, 'ui')
    msg = 'GUI state not initialized.';
    return;
end
stateFile = '';
if isfield(state, 'stateFile')
    stateFile = char(string(state.stateFile));
end
if isempty(stateFile)
    stateFile = get_tb_queue_state_file();
end
if exist(stateFile, 'file') ~= 2
    msg = 'state file not found';
    return;
end

try
    S = load(stateFile, 'savedState');
catch ME
    msg = sprintf('cannot load state: %s', ME.message);
    return;
end
if ~isstruct(S) || ~isfield(S, 'savedState') || ~isstruct(S.savedState)
    msg = 'invalid state file format';
    return;
end
savedState = S.savedState;

if isfield(savedState, 'values') && isstruct(savedState.values)
    v = savedState.values;
    set_if_present(state.ui, 'editT', get_struct_field(v, 'editT', '10'));
    set_if_present(state.ui, 'editPidP', get_struct_field(v, 'editPidP', '1'));
    set_if_present(state.ui, 'editPidI', get_struct_field(v, 'editPidI', '0'));
    set_if_present(state.ui, 'editPidD', get_struct_field(v, 'editPidD', '0'));
    set_if_present(state.ui, 'editB', get_struct_field(v, 'editB', '0.2, 0.5, 1.0'));
    set_if_present(state.ui, 'editTcIp', get_struct_field(v, 'editTcIp', '192.168.0.116'));
    set_if_present(state.ui, 'editMagIp', get_struct_field(v, 'editMagIp', '192.168.0.101'));
    set_popup_if_present(state.ui, 'popupMode', get_struct_field(v, 'popupMode', 1));
    set_if_present(state.ui, 'editScale', get_struct_field(v, 'editScale', '1000'));
    set_if_present(state.ui, 'editTSafe', get_struct_field(v, 'editTSafe', '8'));
    set_if_present(state.ui, 'editTTol', get_struct_field(v, 'editTTol', '0.02'));
    set_if_present(state.ui, 'editHold', get_struct_field(v, 'editHold', '30'));
    set_if_present(state.ui, 'editMaxWait', get_struct_field(v, 'editMaxWait', '1800'));
    set_if_present(state.ui, 'editPoll', get_struct_field(v, 'editPoll', '1'));
    set_if_present(state.ui, 'editMagPort', get_struct_field(v, 'editMagPort', '7185'));
    set_if_present(state.ui, 'editHandle', get_struct_field(v, 'editHandle', ''));
end

if isfield(savedState, 'queueSteps') && isstruct(savedState.queueSteps)
    state.queueSteps = savedState.queueSteps;
end
guidata(hFig, state);
refresh_queue_list(hFig);

savedHandleRaw = get_string_safe(state.ui, 'editHandle', '');
if ~isempty(strtrim(savedHandleRaw))
    h = str2double(savedHandleRaw);
    if isfinite(h) && is_valid_v2_auto_fig(h)
        bind_auto_fig(hFig, h);
    end
end

ok = true;
end

function out = get_struct_field(s, key, fallback)
out = fallback;
if isstruct(s) && isfield(s, key)
    out = s.(key);
end
end

function out = get_string_safe(ui, key, fallback)
out = fallback;
if isstruct(ui) && isfield(ui, key) && isgraphics(ui.(key), 'uicontrol')
    out = char(string(get(ui.(key), 'String')));
end
end

function out = get_popup_value_safe(ui, key, fallback)
out = fallback;
if isstruct(ui) && isfield(ui, key) && isgraphics(ui.(key), 'uicontrol')
    out = get(ui.(key), 'Value');
end
end

function out = get_checkbox_value_safe(ui, key, fallback)
out = fallback;
if isstruct(ui) && isfield(ui, key) && isgraphics(ui.(key), 'uicontrol')
    out = logical(get(ui.(key), 'Value'));
end
end

function set_if_present(ui, key, value)
if isstruct(ui) && isfield(ui, key) && isgraphics(ui.(key), 'uicontrol')
    set(ui.(key), 'String', char(string(value)));
end
end

function set_popup_if_present(ui, key, value)
if isstruct(ui) && isfield(ui, key) && isgraphics(ui.(key), 'uicontrol')
    items = get(ui.(key), 'String');
    n = numel(items);
    v = round(double(value));
    if ~isfinite(v), v = 1; end
    v = max(1, min(n, v));
    set(ui.(key), 'Value', v);
end
end

function set_checkbox_if_present(ui, key, value)
if isstruct(ui) && isfield(ui, key) && isgraphics(ui.(key), 'uicontrol')
    set(ui.(key), 'Value', logical(value));
end
end

function ensure_bt_control_on_path()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);               % ...\+v3_1
rootDir = fileparts(thisDir);                % ...\AutoRunSequences_v3_1
btDir = fullfile(rootDir, 'BT_Control');
if exist('run_b_field_queue_v2_1', 'file') ~= 2 || exist('set_temperature_safe', 'file') ~= 2
    if isfolder(btDir)
        addpath(btDir);
    end
end
end
