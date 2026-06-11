function varargout = T1_SemiAuto_ParamInput_v2_2(varargin)
%T1_SEMIAUTO_PARAMINPUT_V2_2 Programmatic Smart automation GUI for v2.2.

[parentArgs, launchOpts] = parse_launch_args(varargin{:});
if launchOpts.resetLayout
    delete_layout_override_file();
end

existing = findall(0, 'Type', 'figure', 'Tag', 'T1_SemiAuto_ParamInput_v2_2');
if ~isempty(existing) && isgraphics(existing(1), 'figure')
    if launchOpts.resetLayout
        reset_layout_to_defaults(existing(1));
    end
    figure(existing(1));
    if launchOpts.layoutEdit
        open_layout_editor(existing(1));
    end
    if nargout > 0
        varargout{1} = existing(1);
    end
    return;
end

cfg = config();
hFig = figure( ...
    'Name', 'Smart Relaxation v2.2', ...
    'Tag', 'T1_SemiAuto_ParamInput_v2_2', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'HandleVisibility', 'callback', ...
    'Units', 'normalized', ...
    'Position', [0.04 0.06 0.92 0.86], ...
    'Color', get(0, 'DefaultUicontrolBackgroundColor'), ...
    'CloseRequestFcn', @on_close_request);

handles = struct();
handles.output = hFig;
if numel(parentArgs) >= 1, handles.hFigA = parentArgs{1}; else, handles.hFigA = []; end
if numel(parentArgs) >= 2, handles.hObjectA = parentArgs{2}; else, handles.hObjectA = []; end
if numel(parentArgs) >= 3, handles.eventdataA = parentArgs{3}; else, handles.eventdataA = []; end
handles = ensure_parent_main_gui_handles(handles);
handles.figure1 = hFig;
handles.layoutEditMode = logical(launchOpts.layoutEdit);

build_layout(hFig, cfg);
store_default_layout_positions(hFig);
apply_layout_overrides(hFig);
handles = harvest_tagged_controls(hFig, handles);
restore_state(handles);
reset_run_elapsed_display(handles, cfg);
guidata(hFig, handles);

if launchOpts.layoutEdit
    open_layout_editor(hFig);
end

if nargout > 0
    varargout{1} = hFig;
end
end

function build_layout(hFig, cfg)
mainBg = get(hFig, 'Color');
pTop = uipanel('Parent', hFig, 'Tag', 'panel_program_control', 'Units', 'normalized', 'Position', [0.01 0.93 0.98 0.06], ...
    'Title', 'Program Control', 'BackgroundColor', mainBg);
pLeft = uipanel('Parent', hFig, 'Tag', 'panel_configuration', 'Units', 'normalized', 'Position', [0.01 0.01 0.42 0.91], ...
    'Title', 'Configuration', 'BackgroundColor', mainBg);
pRight = uipanel('Parent', hFig, 'Tag', 'panel_timing', 'Units', 'normalized', 'Position', [0.44 0.01 0.55 0.91], ...
    'Title', 'Per-Target Timing', 'BackgroundColor', mainBg);

uicontrol('Parent', pTop, 'Style', 'pushbutton', 'String', 'Start Program', ...
    'Tag', 'pushbutton_startProg', 'Units', 'normalized', 'Position', [0.01 0.15 0.12 0.7], ...
    'Callback', @pushbutton_startProg_Callback);
uicontrol('Parent', pTop, 'Style', 'pushbutton', 'String', 'Stop Program', ...
    'Tag', 'pushbutton_stopProg', 'Units', 'normalized', 'Position', [0.14 0.15 0.12 0.7], ...
    'UserData', 0, 'Callback', @pushbutton_stopProg_Callback);
uicontrol('Parent', pTop, 'Style', 'text', 'Tag', 'txt_program_note', 'String', ...
    'Programmatic GUI. T1/T2/T2* sequence mapping is configured in config.m.', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.29 0.15 0.48 0.7], ...
    'BackgroundColor', mainBg);
uicontrol('Parent', pTop, 'Style', 'text', 'Tag', cfg.smart.ui.tags.display.runElapsed, ...
    'String', 'Elapsed: 0d 00:00:00', 'HorizontalAlignment', 'left', ...
    'Units', 'normalized', 'Position', [0.79 0.15 0.19 0.7], ...
    'BackgroundColor', mainBg, 'FontWeight', 'bold');

build_left_panels(pLeft, cfg, mainBg);
build_right_tabs(pRight, cfg, mainBg);
end

function build_left_panels(parent, cfg, bg)
pMeas = uipanel('Parent', parent, 'Tag', 'panel_measurement_families', 'Title', 'Measurement Families', ...
    'Units', 'normalized', 'Position', [0.02 0.86 0.96 0.12], 'BackgroundColor', bg);
uicontrol('Parent', pMeas, 'Style', 'checkbox', 'String', 'Enable T1', ...
    'Tag', cfg.smart.ui.tags.measure.t1, 'Units', 'normalized', 'Position', [0.02 0.56 0.28 0.28], ...
    'BackgroundColor', bg, 'Value', double(cfg.smart.measurements.t1.enabled));
uicontrol('Parent', pMeas, 'Style', 'checkbox', 'String', 'Enable T2', ...
    'Tag', cfg.smart.ui.tags.measure.t2, 'Units', 'normalized', 'Position', [0.34 0.56 0.28 0.28], ...
    'BackgroundColor', bg, 'Value', double(cfg.smart.measurements.t2.enabled));
uicontrol('Parent', pMeas, 'Style', 'checkbox', 'String', 'Enable T2*', ...
    'Tag', cfg.smart.ui.tags.measure.t2star, 'Units', 'normalized', 'Position', [0.66 0.56 0.30 0.28], ...
    'BackgroundColor', bg, 'Value', double(cfg.smart.measurements.t2star.enabled));
uicontrol('Parent', pMeas, 'Style', 'checkbox', 'String', 'T1 Sij-all override', ...
    'Tag', cfg.smart.ui.tags.measure.t1SijAll, 'Units', 'normalized', 'Position', [0.02 0.31 0.55 0.20], ...
    'BackgroundColor', bg, 'Value', double(cfg.smart.sijAll.enabled));
uicontrol('Parent', pMeas, 'Style', 'text', 'Tag', 'txt_measurement_note', 'String', 'SQ targets apply to all families. DQ targets are T1-only.', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.02 0.10 0.94 0.24], ...
    'BackgroundColor', bg);

pSel = uipanel('Parent', parent, 'Tag', 'panel_targets_globals', 'Title', 'Targets + Globals', ...
    'Units', 'normalized', 'Position', [0.02 0.69 0.96 0.15], 'BackgroundColor', bg);
targetLabels = { ...
    'Aligned SQ-', cfg.smart.ui.tags.sel.aligned_sq_m1; ...
    'Aligned SQ+', cfg.smart.ui.tags.sel.aligned_sq_p1; ...
    'Aligned DQ (T1)', cfg.smart.ui.tags.sel.aligned_dq; ...
    'Off-aligned SQ-', cfg.smart.ui.tags.sel.off_sq_m1; ...
    'Off-aligned SQ+', cfg.smart.ui.tags.sel.off_sq_p1; ...
    'Off-aligned DQ (T1)', cfg.smart.ui.tags.sel.off_dq};
for i = 1:size(targetLabels, 1)
    row = 0.88 - (i - 1) * 0.12;
    uicontrol('Parent', pSel, 'Style', 'checkbox', 'String', targetLabels{i, 1}, ...
        'Tag', targetLabels{i, 2}, 'Units', 'normalized', 'Position', [0.02 row 0.54 0.10], ...
        'BackgroundColor', bg, 'Value', double(cfg.smart.targets(i).enabled));
end
add_labeled_edit(pSel, 'Estimated B (G)', cfg.smart.ui.tags.input.estimatedB, '100', [0.61 0.50 0.31 0.30]);
uicontrol('Parent', pSel, 'Style', 'checkbox', ...
    'String', 'Nonuniform points (first quarter gets half)', ...
    'Tag', cfg.smart.ui.tags.input.nonuniform, 'Units', 'normalized', 'Position', [0.58 0.26 0.38 0.13], ...
    'BackgroundColor', bg, 'Value', 0);
uicontrol('Parent', pSel, 'Style', 'checkbox', ...
    'String', 'Add additional late time points', ...
    'Tag', cfg.smart.ui.tags.input.addLateTimePoints, 'Units', 'normalized', 'Position', [0.58 0.11 0.38 0.13], ...
    'BackgroundColor', bg, 'Value', 0);

pRough = uipanel('Parent', parent, 'Tag', 'panel_rough_search', 'Title', 'Rough Search', ...
    'Units', 'normalized', 'Position', [0.02 0.49 0.96 0.18], 'BackgroundColor', bg);
uicontrol('Parent', pRough, 'Style', 'checkbox', 'String', 'Enable rough pre-scan', ...
    'Tag', cfg.smart.ui.tags.rough.enable, 'Units', 'normalized', 'Position', [0.02 0.82 0.44 0.12], ...
    'BackgroundColor', bg, 'Value', double(cfg.smart.rough.enabled));
uicontrol('Parent', pRough, 'Style', 'checkbox', 'String', 'Final fit auto-stop', ...
    'Tag', cfg.smart.ui.tags.finalT1.enable, 'Units', 'normalized', 'Position', [0.50 0.82 0.22 0.12], ...
    'BackgroundColor', bg, 'Value', double(cfg.smart.finalT1.autoStopByRelErr));
add_labeled_edit(pRough, 'Final min avg', cfg.smart.ui.tags.finalT1.minAverage, ...
    num2str(cfg.smart.finalT1.minAverageForAutoStop), [0.74 0.72 0.22 0.20]);
add_labeled_edit(pRough, 'Rough N', cfg.smart.ui.tags.rough.nPoints, num2str(cfg.smart.rough.nPoints), [0.02 0.48 0.21 0.24]);
add_labeled_edit(pRough, 'Repeat', cfg.smart.ui.tags.rough.repeat, num2str(cfg.smart.rough.repeat), [0.26 0.48 0.21 0.24]);
add_labeled_edit(pRough, 'Average', cfg.smart.ui.tags.rough.average, num2str(cfg.smart.rough.average), [0.50 0.48 0.21 0.24]);
add_labeled_edit(pRough, 'Max retries', cfg.smart.ui.tags.rough.maxRetries, num2str(cfg.smart.rough.maxRetries), [0.74 0.48 0.22 0.24]);
add_labeled_edit(pRough, 'Fit err', cfg.smart.ui.tags.rough.fitRelErr, num2str(cfg.smart.rough.fitRelErrThreshold), [0.02 0.16 0.21 0.24]);
add_labeled_popup(pRough, 'Stop mode', cfg.smart.ui.tags.rough.stopPolicy, {'first_good', 'max_retries'}, ...
    popup_value({'first_good', 'max_retries'}, cfg.smart.rough.stopPolicy), [0.26 0.16 0.21 0.24]);
add_labeled_edit(pRough, 'Stop factor', cfg.smart.ui.tags.rough.stopFactor, num2str(cfg.smart.rough.stopFactor), [0.50 0.16 0.21 0.24]);
add_labeled_edit(pRough, 'Final fit err', cfg.smart.ui.tags.finalT1.relErr, num2str(cfg.smart.finalT1.relErrThreshold), [0.74 0.16 0.22 0.24]);
uicontrol('Parent', pRough, 'Style', 'text', 'Tag', 'txt_rough_note', 'String', 'T2 uses fit-based roughing. T2* uses edge-ratio roughing.', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.02 0.02 0.93 0.08], 'BackgroundColor', bg);

pPre = uipanel('Parent', parent, 'Tag', 'panel_precal_power', 'Title', 'Precalibration + Power', ...
    'Units', 'normalized', 'Position', [0.02 0.13 0.96 0.35], 'BackgroundColor', bg);
uicontrol('Parent', pPre, 'Style', 'checkbox', 'String', 'Enable precalibration', ...
    'Tag', cfg.smart.ui.tags.precal.enable, 'Units', 'normalized', 'Position', [0.02 0.90 0.30 0.08], ...
    'BackgroundColor', bg, 'Value', 1);
uicontrol('Parent', pPre, 'Style', 'checkbox', 'String', 'Find MW power for target pi', ...
    'Tag', cfg.smart.ui.tags.precal.calipi.enable, 'Units', 'normalized', 'Position', [0.36 0.90 0.36 0.08], ...
    'BackgroundColor', bg, 'Value', double(cfg.smart.precal.calipi.enabled));
add_labeled_edit(pPre, 'ODMR', cfg.smart.ui.tags.power.odmr, num2str(cfg.smart.power.odmr_dBm), [0.02 0.74 0.29 0.13]);
add_labeled_edit(pPre, 'ODMR P1', cfg.smart.ui.tags.power.odmrP1, num2str(cfg.smart.power.odmr_p1_dBm), [0.35 0.74 0.29 0.13]);
add_labeled_edit(pPre, 'Rabi base', cfg.smart.ui.tags.power.rabi, num2str(cfg.smart.power.rabi_dBm), [0.68 0.74 0.29 0.13]);

add_labeled_edit(pPre, 'Rabi SG1', cfg.smart.ui.tags.power.rabiSg1, num2str(cfg.smart.power.rabi_sg1_dBm), [0.02 0.61 0.29 0.13]);
add_labeled_edit(pPre, 'Rabi SG2', cfg.smart.ui.tags.power.rabiSg2, num2str(cfg.smart.power.rabi_sg2_dBm), [0.35 0.61 0.29 0.13]);
add_labeled_edit(pPre, 'Target pi', cfg.smart.ui.tags.precal.calipi.targetPiNs, num2str(cfg.smart.precal.calipi.targetPiNs), [0.68 0.61 0.29 0.13]);

add_labeled_edit(pPre, 'PiCal t0', cfg.smart.ui.tags.precal.rabi.start, num2str(cfg.smart.precal.rabi.start), [0.02 0.48 0.29 0.13]);
add_labeled_edit(pPre, 'PiCal t1', cfg.smart.ui.tags.precal.rabi.stop, num2str(cfg.smart.precal.rabi.stop), [0.35 0.48 0.29 0.13]);
add_labeled_edit(pPre, 'PiCal N', cfg.smart.ui.tags.precal.rabi.nPoints, num2str(cfg.smart.precal.rabi.nPoints), [0.68 0.48 0.29 0.13]);

add_labeled_edit(pPre, 'PiCal rep', cfg.smart.ui.tags.precal.rabi.repeat, num2str(cfg.smart.precal.rabi.repeat), [0.02 0.35 0.29 0.13]);
add_labeled_edit(pPre, 'PiCal avg', cfg.smart.ui.tags.precal.rabi.average, num2str(cfg.smart.precal.rabi.average), [0.35 0.35 0.29 0.13]);
add_labeled_edit(pPre, 'ODMR rep', cfg.smart.ui.tags.precal.odmr.repeat, num2str(cfg.smart.precal.odmr.repeat), [0.68 0.35 0.29 0.13]);

add_labeled_edit(pPre, 'ODMR avg', cfg.smart.ui.tags.precal.odmr.average, num2str(cfg.smart.precal.odmr.average), [0.02 0.22 0.29 0.13]);
add_labeled_edit(pPre, 'Pts/MHz', cfg.smart.ui.tags.precal.odmr.pointsPerMHz, num2str(cfg.smart.precal.odmr.pointsPerMHz), [0.35 0.22 0.29 0.13]);
add_labeled_edit(pPre, 'P start', cfg.smart.ui.tags.precal.calipi.powerStartDbm, num2str(cfg.smart.precal.calipi.powerStartDbm), [0.68 0.22 0.29 0.13]);

add_labeled_edit(pPre, 'P stop', cfg.smart.ui.tags.precal.calipi.powerStopDbm, num2str(cfg.smart.precal.calipi.powerStopDbm), [0.02 0.09 0.29 0.13]);
add_labeled_edit(pPre, 'P npts', cfg.smart.ui.tags.precal.calipi.powerNPoints, num2str(cfg.smart.precal.calipi.powerNPoints), [0.35 0.09 0.29 0.13]);

pDisp = uipanel('Parent', parent, 'Tag', 'panel_run_displays', 'Title', 'Run Displays', ...
    'Units', 'normalized', 'Position', [0.02 0.02 0.96 0.11], 'BackgroundColor', bg);
uicontrol('Parent', pDisp, 'Style', 'text', 'Tag', 'txt_display_rough_label', 'String', 'Rough display', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.02 0.78 0.20 0.12], 'BackgroundColor', bg);
uicontrol('Parent', pDisp, 'Style', 'text', 'String', 'Rough: --', ...
    'Tag', cfg.smart.ui.tags.display.roughT1, 'HorizontalAlignment', 'left', ...
    'Units', 'normalized', 'Position', [0.24 0.78 0.72 0.12], 'BackgroundColor', bg);
uicontrol('Parent', pDisp, 'Style', 'edit', 'Max', 6, 'Enable', 'inactive', ...
    'Tag', cfg.smart.ui.tags.display.precalSummary, 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'Position', [0.02 0.36 0.94 0.36], 'BackgroundColor', 'white');

statusTags = { ...
    cfg.smart.ui.tags.status.aligned_sq_m1, 'aligned SQ(-1)'; ...
    cfg.smart.ui.tags.status.aligned_sq_p1, 'aligned SQ(+1)'; ...
    cfg.smart.ui.tags.status.aligned_dq,    'aligned DQ'; ...
    cfg.smart.ui.tags.status.off_sq_m1,     'off-aligned SQ(-1)'; ...
    cfg.smart.ui.tags.status.off_sq_p1,     'off-aligned SQ(+1)'; ...
    cfg.smart.ui.tags.status.off_dq,        'off-aligned DQ'};
for i = 1:size(statusTags, 1)
    x = 0.02 + mod(i - 1, 3) * 0.32;
    y = 0.04 + (1 - floor((i - 1) / 3)) * 0.13;
    uicontrol('Parent', pDisp, 'Style', 'edit', 'Enable', 'inactive', 'Max', 2, ...
        'String', statusTags{i, 2}, 'Tag', statusTags{i, 1}, 'HorizontalAlignment', 'left', ...
        'Units', 'normalized', 'Position', [x y 0.29 0.12], 'BackgroundColor', 'white');
end
end

function build_right_tabs(parent, cfg, bg)
tt = uitabgroup('Parent', parent, 'Tag', 'tabgroup_timing', 'Units', 'normalized', 'Position', [0.01 0.01 0.98 0.98]);
build_family_tab(tt, cfg, bg, 'T1', cfg.smart.targets, 't1', true);
build_family_tab(tt, cfg, bg, 'T2', family_targets_for_gui(cfg.smart.targets, cfg.smart.measurements.t2), 't2', false);
build_family_tab(tt, cfg, bg, 'T2*', family_targets_for_gui(cfg.smart.targets, cfg.smart.measurements.t2star), 't2star', false);
end

function build_family_tab(tabgroup, cfg, bg, tabTitle, targets, family, useLegacyT1Tags)
t = uitab('Parent', tabgroup, 'Tag', ['tab_' family], 'Title', tabTitle, 'BackgroundColor', bg);
headers = {'Target', 'Start', 'Stop', 'Npts', 'Repeat', 'Average'};
colX = [0.02 0.40 0.53 0.66 0.79 0.90];
for i = 1:numel(headers)
    uicontrol('Parent', t, 'Style', 'text', 'Tag', sprintf('hdr_%s_%s', family, matlab.lang.makeValidName(lower(headers{i}))), 'String', headers{i}, ...
        'HorizontalAlignment', iff(i == 1, 'left', 'center'), ...
        'Units', 'normalized', 'Position', [colX(i) 0.92 0.10 0.05], 'BackgroundColor', bg);
end

for i = 1:numel(targets)
    y = 0.84 - (i - 1) * 0.12;
    target = targets(i);
    label = target_label(target.id);
    uicontrol('Parent', t, 'Style', 'text', 'Tag', sprintf('label_%s_%s', family, target.id), 'String', label, 'HorizontalAlignment', 'left', ...
        'Units', 'normalized', 'Position', [0.02 y 0.28 0.06], 'BackgroundColor', bg);
    if useLegacyT1Tags
        tags = cfg.smart.ui.tags.t1.(target.id);
        vals = target.t1;
    else
        tags = cfg.smart.ui.tags.(family).(target.id);
        vals = target.(family);
    end
    add_row_edit(t, tags.start, num2str(vals.start), [0.33 y 0.13 0.06]);
    add_row_edit(t, tags.stop, num2str(vals.stop), [0.48 y 0.13 0.06]);
    add_row_edit(t, tags.nPoints, num2str(vals.nPoints), [0.63 y 0.13 0.06]);
    add_row_edit(t, tags.repeat, num2str(vals.repeat), [0.78 y 0.10 0.06]);
    add_row_edit(t, tags.average, num2str(vals.average), [0.89 y 0.09 0.06]);
end
end

function add_labeled_edit(parent, label, tag, defaultValue, pos)
if numel(pos) < 4
    pos(4) = 0.14;
end
labelPos = [pos(1) pos(2) + pos(4) * 0.58 pos(3) pos(4) * 0.34];
editPos = [pos(1) pos(2) + pos(4) * 0.06 pos(3) pos(4) * 0.48];
uicontrol('Parent', parent, 'Style', 'text', 'Tag', ['label_' tag], 'String', label, ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', ...
    'Position', labelPos, ...
    'FontSize', 8, ...
    'BackgroundColor', get(parent, 'BackgroundColor'));
uicontrol('Parent', parent, 'Style', 'edit', 'String', defaultValue, 'Tag', tag, ...
    'Units', 'normalized', 'Position', editPos, ...
    'FontSize', 10, ...
    'BackgroundColor', 'white');
end

function add_labeled_popup(parent, label, tag, items, value, pos)
if numel(pos) < 4
    pos(4) = 0.14;
end
labelPos = [pos(1) pos(2) + pos(4) * 0.58 pos(3) pos(4) * 0.34];
popupPos = [pos(1) pos(2) + pos(4) * 0.06 pos(3) pos(4) * 0.48];
uicontrol('Parent', parent, 'Style', 'text', 'Tag', ['label_' tag], 'String', label, ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', ...
    'Position', labelPos, ...
    'FontSize', 8, ...
    'BackgroundColor', get(parent, 'BackgroundColor'));
uicontrol('Parent', parent, 'Style', 'popupmenu', 'String', items, 'Tag', tag, ...
    'Units', 'normalized', 'Position', popupPos, ...
    'FontSize', 10, ...
    'Value', value, ...
    'BackgroundColor', 'white');
end

function add_row_edit(parent, tag, defaultValue, pos)
uicontrol('Parent', parent, 'Style', 'edit', 'String', defaultValue, 'Tag', tag, ...
    'Units', 'normalized', 'Position', pos, 'BackgroundColor', 'white');
end

function handles = harvest_tagged_controls(hFig, handles)
objs = findall(hFig, '-property', 'Tag');
for i = 1:numel(objs)
    tag = get(objs(i), 'Tag');
    if isempty(tag)
        continue;
    end
    safe = matlab.lang.makeValidName(tag);
    handles.(safe) = objs(i);
    handles.(tag) = objs(i);
end
end

function restore_state(handles)
statePath = get_v2_2_state_path();
if ~isfile(statePath)
    return;
end
loaded = load(statePath);
if ~isfield(loaded, 'state') || ~isstruct(loaded.state)
    return;
end

fields = fieldnames(loaded.state);
for i = 1:numel(fields)
    tag = fields{i};
    if ~isfield(handles, tag)
        continue;
    end
    h = handles.(tag);
    if ~isgraphics(h, 'uicontrol')
        continue;
    end
    st = get(h, 'Style');
    try
        switch st
            case {'edit', 'text'}
                set(h, 'String', loaded.state.(tag));
            case {'checkbox', 'radiobutton', 'togglebutton', 'popupmenu', 'slider'}
                set(h, 'Value', loaded.state.(tag));
        end
    catch
    end
end
end

function save_state(handles)
state = struct();
fields = fieldnames(handles);
for i = 1:numel(fields)
    name = fields{i};
    if ~startsWith(name, {'chk_', 'edit_', 'txt_', 'popup_', 'pushbutton_'})
        continue;
    end
    h = handles.(name);
    if ~isgraphics(h, 'uicontrol')
        continue;
    end
    st = get(h, 'Style');
    switch st
        case {'edit', 'text'}
            state.(name) = get(h, 'String');
        case {'checkbox', 'radiobutton', 'togglebutton', 'popupmenu', 'slider'}
            state.(name) = get(h, 'Value');
    end
end
save(get_v2_2_state_path(), 'state');
end

function pushbutton_startProg_Callback(hObject, ~)
handles = guidata(ancestor(hObject, 'figure'));
if isfield(handles, 'pushbutton_stopProg') && isgraphics(handles.pushbutton_stopProg, 'uicontrol')
    handles.pushbutton_stopProg.UserData = 0;
end
handles = ensure_parent_main_gui_handles(handles);
guidata(handles.output, handles);

if ~isfield(handles, 'hFigA') || isempty(handles.hFigA) || ~(ishandle(handles.hFigA) || isgraphics(handles.hFigA))
    errordlg(['Main experiment GUI not found. Open Experiment_PB_DAQ first, ', ...
        'then start `v2.2` again.'], ...
        'Smart Relaxation v2.2');
    return;
end

handlesA = guidata(handles.hFigA);
cfg = config();
start_run_elapsed_timer(handles, cfg);
cleanupElapsedTimer = onCleanup(@() stop_run_elapsed_timer(handles, cfg)); %#ok<NASGU>
smart_relaxation_program_v2_2(handles.hObjectA, handles.eventdataA, handlesA, handles);
end

function pushbutton_stopProg_Callback(hObject, ~)
handles = guidata(ancestor(hObject, 'figure'));
global gmSEQ
handles.pushbutton_stopProg.UserData = 1;
try
    gmSEQ.bGo = 0;
    gmSEQ.bGoAfterAvg = 0;
    gmSEQ.bExp = 0;
catch
end
guidata(handles.output, handles);
end

function on_close_request(hObject, ~)
handles = guidata(hObject);
try
    stop_run_elapsed_timer(handles, config());
catch
end
try
    save_state(handles);
catch ME
    warning('T1_SemiAuto_ParamInput_v2_2:SaveStateFailed', ...
        'Failed to save GUI state on close: %s', ME.message);
end
close_layout_editor_if_open(hObject);
delete(hObject);
end

function reset_run_elapsed_display(handles, cfg)
set_run_elapsed_display(handles, cfg, 0);
end

function start_run_elapsed_timer(handles, cfg)
if nargin < 1 || ~isstruct(handles) || ~isfield(handles, 'output') || ~isgraphics(handles.output, 'figure')
    return;
end
hFig = handles.output;
stop_run_elapsed_timer(handles, cfg);
setappdata(hFig, 'V2_2_RUN_ELAPSED_START_TIC', tic);
set_run_elapsed_display(handles, cfg, 0);
t = timer( ...
    'ExecutionMode', 'fixedSpacing', ...
    'Period', 1, ...
    'BusyMode', 'drop', ...
    'Name', 'AutoRunSequences_v2_2_elapsed_timer', ...
    'TimerFcn', @(~, ~) update_run_elapsed_timer_tick(hFig, cfg));
setappdata(hFig, 'V2_2_RUN_ELAPSED_TIMER', t);
start(t);
end

function stop_run_elapsed_timer(handles, cfg)
if nargin < 1 || ~isstruct(handles) || ~isfield(handles, 'output') || ~isgraphics(handles.output, 'figure')
    return;
end
hFig = handles.output;
update_run_elapsed_timer_tick(hFig, cfg);
if isappdata(hFig, 'V2_2_RUN_ELAPSED_TIMER')
    t = getappdata(hFig, 'V2_2_RUN_ELAPSED_TIMER');
    rmappdata(hFig, 'V2_2_RUN_ELAPSED_TIMER');
    if isa(t, 'timer') && isvalid(t)
        try
            stop(t);
        catch
        end
        try
            delete(t);
        catch
        end
    end
end
end

function update_run_elapsed_timer_tick(hFig, cfg)
if isempty(hFig) || ~isgraphics(hFig, 'figure')
    return;
end
if ~isappdata(hFig, 'V2_2_RUN_ELAPSED_START_TIC')
    return;
end
try
    elapsedSec = toc(getappdata(hFig, 'V2_2_RUN_ELAPSED_START_TIC'));
catch
    elapsedSec = 0;
end
handles = guidata(hFig);
if isstruct(handles)
    set_run_elapsed_display(handles, cfg, elapsedSec);
end
end

function set_run_elapsed_display(handles, cfg, elapsedSec)
if nargin < 3 || ~isfinite(elapsedSec)
    elapsedSec = 0;
end
if ~isfield(cfg.smart.ui.tags, 'display') || ~isfield(cfg.smart.ui.tags.display, 'runElapsed')
    return;
end
tag = cfg.smart.ui.tags.display.runElapsed;
if ~isfield(handles, tag)
    return;
end
h = handles.(tag);
if isgraphics(h, 'uicontrol') && isprop(h, 'String')
    h.String = ['Elapsed: ' format_elapsed_hms(elapsedSec)];
end
drawnow limitrate;
end

function txt = format_elapsed_hms(elapsedSec)
elapsedSec = max(0, floor(double(elapsedSec)));
days = floor(elapsedSec / 86400);
hours = floor(mod(elapsedSec, 86400) / 3600);
minutes = floor(mod(elapsedSec, 3600) / 60);
seconds = mod(elapsedSec, 60);
txt = sprintf('%dd %02d:%02d:%02d', days, hours, minutes, seconds);
end

function p = get_v2_2_state_path()
thisDir = fileparts(mfilename('fullpath'));
p = fullfile(thisDir, 'T1_SemiAuto_ParamInput_v2_2_state.mat');
end

function p = get_v2_2_layout_path()
thisDir = fileparts(mfilename('fullpath'));
p = fullfile(thisDir, 'T1_SemiAuto_ParamInput_v2_2_layout.mat');
end

function handles = ensure_parent_main_gui_handles(handles)
if nargin < 1 || ~isstruct(handles)
    handles = struct();
end

if isfield(handles, 'hFigA') && is_valid_main_gui_figure(handles.hFigA)
    if ~isfield(handles, 'hObjectA') || isempty(handles.hObjectA) || ...
            ~(ishandle(handles.hObjectA) || isgraphics(handles.hObjectA))
        handles.hObjectA = handles.hFigA;
    end
    if ~isfield(handles, 'eventdataA')
        handles.eventdataA = [];
    end
    return;
end

[hFigMain, handlesMain] = find_open_main_gui();
if isempty(hFigMain)
    return;
end

handles.hFigA = hFigMain;
if isfield(handlesMain, 'output') && (ishandle(handlesMain.output) || isgraphics(handlesMain.output))
    handles.hObjectA = handlesMain.output;
else
    handles.hObjectA = hFigMain;
end
handles.eventdataA = [];
end

function tf = is_valid_main_gui_figure(hFig)
tf = false;
if isempty(hFig) || ~(ishandle(hFig) || isgraphics(hFig, 'figure'))
    return;
end

try
    handlesMain = guidata(hFig);
catch
    handlesMain = [];
end
tf = is_valid_main_gui_handles(handlesMain);
end

function tf = is_valid_main_gui_handles(handlesMain)
tf = isstruct(handlesMain) && ...
    isfield(handlesMain, 'sequence') && isfield(handlesMain, 'axes1') && ...
    isfield(handlesMain, 'axes3') && isfield(handlesMain, 'runningText');
end

function [hFigMain, handlesMain] = find_open_main_gui()
hFigMain = [];
handlesMain = [];

figs = findall(0, 'Type', 'figure');
if isempty(figs)
    return;
end

nameMatches = [];
fallbackMatches = [];
for i = 1:numel(figs)
    hFig = figs(i);
    try
        h = guidata(hFig);
    catch
        h = [];
    end
    if ~is_valid_main_gui_handles(h)
        continue;
    end

    figName = '';
    try
        figName = get(hFig, 'Name');
        if ~ischar(figName)
            figName = char(figName);
        end
    catch
    end
    if ~isempty(strfind(lower(figName), 'experiment_pb_daq')) %#ok<STREMP>
        nameMatches(end + 1) = hFig; %#ok<AGROW>
    else
        fallbackMatches(end + 1) = hFig; %#ok<AGROW>
    end
end

if ~isempty(nameMatches)
    hFigMain = nameMatches(1);
elseif ~isempty(fallbackMatches)
    hFigMain = fallbackMatches(1);
end

if ~isempty(hFigMain)
    handlesMain = guidata(hFigMain);
end
end

function [parentArgs, opts] = parse_launch_args(varargin)
opts = struct('layoutEdit', false, 'resetLayout', false);
parentArgs = {};
idx = 1;
while idx <= numel(varargin) && idx <= 3
    v = varargin{idx};
    if ischar(v) || (isstring(v) && isscalar(v))
        break;
    end
    parentArgs{end + 1} = v; %#ok<AGROW>
    idx = idx + 1;
end

while idx <= numel(varargin)
    if idx == numel(varargin)
        break;
    end
    key = lower(char(string(varargin{idx})));
    value = varargin{idx + 1};
    switch key
        case {'layout_edit', 'layoutedit'}
            opts.layoutEdit = logical(value);
        case {'reset_layout', 'resetlayout'}
            opts.resetLayout = logical(value);
    end
    idx = idx + 2;
end
end

function delete_layout_override_file()
layoutPath = get_v2_2_layout_path();
if isfile(layoutPath)
    delete(layoutPath);
end
end

function store_default_layout_positions(hFig)
controls = collect_layout_controls(hFig);
defaults = struct();
for i = 1:numel(controls)
    defaults.(controls(i).tag) = get(controls(i).handle, 'Position');
end
setappdata(hFig, 'v2_2_default_layout', defaults);
end

function apply_layout_overrides(hFig)
layoutPath = get_v2_2_layout_path();
if ~isfile(layoutPath)
    return;
end
loaded = load(layoutPath);
if ~isfield(loaded, 'layoutOverrides') || ~isstruct(loaded.layoutOverrides)
    return;
end
controls = collect_layout_controls(hFig);
for i = 1:numel(controls)
    tag = controls(i).tag;
    if isfield(loaded.layoutOverrides, tag)
        try
            set(controls(i).handle, 'Position', loaded.layoutOverrides.(tag));
        catch
        end
    end
end
end

function reset_layout_to_defaults(hFig)
defaults = getappdata(hFig, 'v2_2_default_layout');
if ~isstruct(defaults)
    return;
end
controls = collect_layout_controls(hFig);
for i = 1:numel(controls)
    if isfield(defaults, controls(i).tag) && isgraphics(controls(i).handle)
        set(controls(i).handle, 'Position', defaults.(controls(i).tag));
    end
end
end

function controls = collect_layout_controls(hFig)
objs = findall(hFig);
controls = repmat(struct('tag', '', 'handle', [], 'style', '', 'summary', ''), 0, 1);
for i = 1:numel(objs)
    h = objs(i);
    if isequal(h, hFig) || ~isgraphics(h)
        continue;
    end
    if ~isprop(h, 'Tag') || ~isprop(h, 'Position')
        continue;
    end
    tag = get(h, 'Tag');
    if isempty(tag) || startsWith(tag, 'layout_editor_')
        continue;
    end
    item = struct();
    item.tag = char(tag);
    item.handle = h;
    item.style = layout_object_style(h);
    item.summary = layout_object_summary(h);
    controls(end + 1) = item; %#ok<AGROW>
end
if isempty(controls)
    return;
end
[~, order] = sort(lower({controls.tag}));
controls = controls(order);
end

function out = layout_object_style(h)
out = class(h);
if isprop(h, 'Style')
    try
        out = char(get(h, 'Style'));
    catch
    end
elseif isa(h, 'matlab.ui.container.Panel')
    out = 'uipanel';
elseif isa(h, 'matlab.ui.container.Tab')
    out = 'uitab';
elseif isa(h, 'matlab.ui.container.TabGroup')
    out = 'uitabgroup';
end
end

function out = layout_object_summary(h)
out = '';
if isprop(h, 'String')
    try
        s = get(h, 'String');
        if iscell(s)
            s = strjoin(cellfun(@char, s, 'UniformOutput', false), ', ');
        end
        out = char(string(s));
    catch
    end
elseif isprop(h, 'Title')
    try
        out = char(string(get(h, 'Title')));
    catch
    end
end
out = strtrim(out);
if strlength(string(out)) > 40
    out = [extractBefore(string(out), 38) '...'];
    out = char(out);
end
end

function open_layout_editor(hFigMain)
if ~isgraphics(hFigMain, 'figure')
    return;
end
editorFig = [];
if isappdata(hFigMain, 'v2_2_layout_editor')
    editorFig = getappdata(hFigMain, 'v2_2_layout_editor');
end
if ~isempty(editorFig) && isgraphics(editorFig, 'figure')
    figure(editorFig);
    refresh_layout_editor(editorFig);
    return;
end

editorFig = figure( ...
    'Name', 'v2.2 Layout Editor', ...
    'Tag', 'T1_SemiAuto_ParamInput_v2_2_LayoutEditor', ...
    'NumberTitle', 'off', ...
    'MenuBar', 'none', ...
    'ToolBar', 'none', ...
    'Units', 'normalized', ...
    'Position', [0.66 0.08 0.30 0.78], ...
    'CloseRequestFcn', @layout_editor_close_request);
bg = get(editorFig, 'Color');

state = struct();
state.hMain = hFigMain;
state.controls = repmat(struct('tag', '', 'handle', [], 'style', '', 'summary', ''), 0, 1);
state.selectedIndex = 1;

uicontrol('Parent', editorFig, 'Style', 'text', 'Tag', 'layout_editor_title', ...
    'String', 'Select a tagged control, adjust position, then save overrides.', ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', ...
    'Position', [0.03 0.95 0.94 0.04], 'BackgroundColor', bg);
uicontrol('Parent', editorFig, 'Style', 'listbox', 'Tag', 'layout_editor_list', ...
    'Units', 'normalized', 'Position', [0.03 0.14 0.48 0.79], ...
    'Callback', @layout_editor_select_callback, 'BackgroundColor', 'white');
uicontrol('Parent', editorFig, 'Style', 'text', 'Tag', 'layout_editor_info', ...
    'String', 'No control selected.', 'Max', 3, 'HorizontalAlignment', 'left', ...
    'Units', 'normalized', 'Position', [0.54 0.81 0.42 0.12], 'BackgroundColor', bg);

add_editor_field(editorFig, bg, 'X', 'layout_editor_x', [0.56 0.70 0.16 0.08]);
add_editor_field(editorFig, bg, 'Y', 'layout_editor_y', [0.78 0.70 0.16 0.08]);
add_editor_field(editorFig, bg, 'W', 'layout_editor_w', [0.56 0.58 0.16 0.08]);
add_editor_field(editorFig, bg, 'H', 'layout_editor_h', [0.78 0.58 0.16 0.08]);
add_editor_field(editorFig, bg, 'Step', 'layout_editor_step', [0.56 0.46 0.16 0.08], '0.01');

uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Apply', ...
    'Tag', 'layout_editor_apply', 'Units', 'normalized', 'Position', [0.56 0.35 0.18 0.08], ...
    'Callback', @layout_editor_apply_callback);
uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Refresh', ...
    'Tag', 'layout_editor_refresh', 'Units', 'normalized', 'Position', [0.78 0.35 0.18 0.08], ...
    'Callback', @layout_editor_refresh_callback);
uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Save Layout', ...
    'Tag', 'layout_editor_save', 'Units', 'normalized', 'Position', [0.56 0.25 0.18 0.08], ...
    'Callback', @layout_editor_save_callback);
uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Reset Selected', ...
    'Tag', 'layout_editor_reset_selected', 'Units', 'normalized', 'Position', [0.78 0.25 0.18 0.08], ...
    'Callback', @layout_editor_reset_selected_callback);
uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Reset All', ...
    'Tag', 'layout_editor_reset_all', 'Units', 'normalized', 'Position', [0.56 0.15 0.18 0.08], ...
    'Callback', @layout_editor_reset_all_callback);

uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Left', ...
    'Tag', 'layout_editor_left', 'Units', 'normalized', 'Position', [0.56 0.03 0.09 0.08], ...
    'Callback', @(src, evt) layout_editor_nudge_callback(src, evt, -1, 0, 0, 0));
uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Right', ...
    'Tag', 'layout_editor_right', 'Units', 'normalized', 'Position', [0.67 0.03 0.09 0.08], ...
    'Callback', @(src, evt) layout_editor_nudge_callback(src, evt, 1, 0, 0, 0));
uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Up', ...
    'Tag', 'layout_editor_up', 'Units', 'normalized', 'Position', [0.78 0.03 0.08 0.08], ...
    'Callback', @(src, evt) layout_editor_nudge_callback(src, evt, 0, 1, 0, 0));
uicontrol('Parent', editorFig, 'Style', 'pushbutton', 'String', 'Down', ...
    'Tag', 'layout_editor_down', 'Units', 'normalized', 'Position', [0.88 0.03 0.08 0.08], ...
    'Callback', @(src, evt) layout_editor_nudge_callback(src, evt, 0, -1, 0, 0));

setappdata(hFigMain, 'v2_2_layout_editor', editorFig);
setappdata(editorFig, 'v2_2_main_fig', hFigMain);
guidata(editorFig, state);
refresh_layout_editor(editorFig);
end

function add_editor_field(parent, bg, label, tag, pos, defaultValue)
if nargin < 6
    defaultValue = '';
end
uicontrol('Parent', parent, 'Style', 'text', 'String', label, ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', ...
    'Position', [pos(1) pos(2) + 0.04 pos(3) 0.03], 'BackgroundColor', bg);
uicontrol('Parent', parent, 'Style', 'edit', 'Tag', tag, 'String', defaultValue, ...
    'Units', 'normalized', 'Position', [pos(1) pos(2) pos(3) 0.04], 'BackgroundColor', 'white');
end

function refresh_layout_editor(editorFig)
if ~isgraphics(editorFig, 'figure')
    return;
end
state = guidata(editorFig);
if ~isgraphics(state.hMain, 'figure')
    delete(editorFig);
    return;
end
controls = collect_layout_controls(state.hMain);
state.controls = controls;
if isempty(controls)
    set(findobj(editorFig, 'Tag', 'layout_editor_list'), 'String', {'<no tagged controls>'}, 'Value', 1);
    set(findobj(editorFig, 'Tag', 'layout_editor_info'), 'String', 'No tagged controls found.');
    guidata(editorFig, state);
    return;
end
items = cell(1, numel(controls));
for i = 1:numel(controls)
    if isempty(controls(i).summary)
        items{i} = sprintf('%s [%s]', controls(i).tag, controls(i).style);
    else
        items{i} = sprintf('%s [%s] %s', controls(i).tag, controls(i).style, controls(i).summary);
    end
end
state.selectedIndex = min(max(1, state.selectedIndex), numel(controls));
set(findobj(editorFig, 'Tag', 'layout_editor_list'), 'String', items, 'Value', state.selectedIndex);
guidata(editorFig, state);
populate_layout_editor_fields(editorFig);
end

function populate_layout_editor_fields(editorFig)
state = guidata(editorFig);
if isempty(state.controls)
    return;
end
idx = min(max(1, state.selectedIndex), numel(state.controls));
ctrl = state.controls(idx);
pos = get(ctrl.handle, 'Position');
set(findobj(editorFig, 'Tag', 'layout_editor_x'), 'String', num2str(pos(1), '%.4f'));
set(findobj(editorFig, 'Tag', 'layout_editor_y'), 'String', num2str(pos(2), '%.4f'));
set(findobj(editorFig, 'Tag', 'layout_editor_w'), 'String', num2str(pos(3), '%.4f'));
set(findobj(editorFig, 'Tag', 'layout_editor_h'), 'String', num2str(pos(4), '%.4f'));
info = sprintf('Tag: %s\nType: %s\nSummary: %s', ctrl.tag, ctrl.style, ctrl.summary);
set(findobj(editorFig, 'Tag', 'layout_editor_info'), 'String', info);
end

function layout_editor_select_callback(hObject, ~)
editorFig = ancestor(hObject, 'figure');
state = guidata(editorFig);
state.selectedIndex = get(hObject, 'Value');
guidata(editorFig, state);
populate_layout_editor_fields(editorFig);
end

function layout_editor_apply_callback(hObject, ~)
editorFig = ancestor(hObject, 'figure');
state = guidata(editorFig);
if isempty(state.controls)
    return;
end
idx = state.selectedIndex;
ctrl = state.controls(idx);
if ~isgraphics(ctrl.handle)
    refresh_layout_editor(editorFig);
    return;
end
pos = read_layout_editor_position(editorFig, get(ctrl.handle, 'Position'));
set(ctrl.handle, 'Position', pos);
populate_layout_editor_fields(editorFig);
drawnow;
end

function pos = read_layout_editor_position(editorFig, defaultPos)
pos = defaultPos;
tags = {'layout_editor_x', 'layout_editor_y', 'layout_editor_w', 'layout_editor_h'};
for i = 1:4
    h = findobj(editorFig, 'Tag', tags{i});
    if isempty(h) || ~isgraphics(h)
        continue;
    end
    v = str2double(get(h, 'String'));
    if isfinite(v)
        pos(i) = v;
    end
end
end

function layout_editor_refresh_callback(hObject, ~)
refresh_layout_editor(ancestor(hObject, 'figure'));
end

function layout_editor_save_callback(hObject, ~)
editorFig = ancestor(hObject, 'figure');
state = guidata(editorFig);
if ~isgraphics(state.hMain, 'figure')
    return;
end
controls = collect_layout_controls(state.hMain);
layoutOverrides = struct();
for i = 1:numel(controls)
    layoutOverrides.(controls(i).tag) = get(controls(i).handle, 'Position');
end
save(get_v2_2_layout_path(), 'layoutOverrides');
refresh_layout_editor(editorFig);
end

function layout_editor_reset_selected_callback(hObject, ~)
editorFig = ancestor(hObject, 'figure');
state = guidata(editorFig);
if isempty(state.controls) || ~isgraphics(state.hMain, 'figure')
    return;
end
defaults = getappdata(state.hMain, 'v2_2_default_layout');
ctrl = state.controls(state.selectedIndex);
if isstruct(defaults) && isfield(defaults, ctrl.tag) && isgraphics(ctrl.handle)
    set(ctrl.handle, 'Position', defaults.(ctrl.tag));
end
populate_layout_editor_fields(editorFig);
drawnow;
end

function layout_editor_reset_all_callback(hObject, ~)
editorFig = ancestor(hObject, 'figure');
state = guidata(editorFig);
if ~isgraphics(state.hMain, 'figure')
    return;
end
defaults = getappdata(state.hMain, 'v2_2_default_layout');
if isstruct(defaults)
    controls = collect_layout_controls(state.hMain);
    for i = 1:numel(controls)
        if isfield(defaults, controls(i).tag) && isgraphics(controls(i).handle)
            set(controls(i).handle, 'Position', defaults.(controls(i).tag));
        end
    end
end
delete_layout_override_file();
refresh_layout_editor(editorFig);
drawnow;
end

function layout_editor_nudge_callback(hObject, ~, dx, dy, dw, dh)
editorFig = ancestor(hObject, 'figure');
state = guidata(editorFig);
if isempty(state.controls)
    return;
end
step = str2double(get(findobj(editorFig, 'Tag', 'layout_editor_step'), 'String'));
if ~isfinite(step) || step <= 0
    step = 0.01;
end
ctrl = state.controls(state.selectedIndex);
if ~isgraphics(ctrl.handle)
    refresh_layout_editor(editorFig);
    return;
end
pos = get(ctrl.handle, 'Position');
pos = pos + step .* [dx dy dw dh];
set(ctrl.handle, 'Position', pos);
populate_layout_editor_fields(editorFig);
drawnow;
end

function layout_editor_close_request(hObject, ~)
if isappdata(hObject, 'v2_2_main_fig')
    hMain = getappdata(hObject, 'v2_2_main_fig');
    if isgraphics(hMain, 'figure') && isappdata(hMain, 'v2_2_layout_editor')
        rmappdata(hMain, 'v2_2_layout_editor');
    end
end
delete(hObject);
end

function close_layout_editor_if_open(hFigMain)
if isappdata(hFigMain, 'v2_2_layout_editor')
    editorFig = getappdata(hFigMain, 'v2_2_layout_editor');
    if isgraphics(editorFig, 'figure')
        delete(editorFig);
    end
    rmappdata(hFigMain, 'v2_2_layout_editor');
end
end

function targetsOut = family_targets_for_gui(targetsIn, familyCfg)
targetsOut = targetsIn;
if isfield(familyCfg, 'supportedTargetIds') && ~isempty(familyCfg.supportedTargetIds)
    supported = familyCfg.supportedTargetIds;
    keep = false(1, numel(targetsIn));
    for i = 1:numel(targetsIn)
        keep(i) = any(strcmp(targetsIn(i).id, supported));
    end
    targetsOut = targetsIn(keep);
end
end

function out = target_label(targetId)
switch char(targetId)
    case 'aligned_sq_m1'
        out = 'Aligned SQ-';
    case 'aligned_sq_p1'
        out = 'Aligned SQ+';
    case 'aligned_dq'
        out = 'Aligned DQ';
    case 'off_sq_m1'
        out = 'Off-aligned SQ-';
    case 'off_sq_p1'
        out = 'Off-aligned SQ+';
    case 'off_dq'
        out = 'Off-aligned DQ';
    otherwise
        out = strrep(char(targetId), '_', ' ');
end
end

function out = popup_value(items, selected)
out = 1;
for i = 1:numel(items)
    if strcmpi(items{i}, selected)
        out = i;
        return;
    end
end
end

function out = iff(tf, a, b)
if tf
    out = a;
else
    out = b;
end
end
