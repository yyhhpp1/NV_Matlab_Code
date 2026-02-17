function T1_SemiAuto_Program(hObject, eventdata, handlesMain, handlesAuto)
% Data-driven auto-measurement program entry point.
% Edit AutoPipelineConfig.m to change step order, parameter mapping, and fit hook.

global gSaveDataAve

cfg = AutoPipelineConfig();
validate_pipeline_config(cfg);

for iStep = 1:numel(cfg.stepOrder)
    stepId = cfg.stepOrder{iStep};
    stepCfg = cfg.steps.(stepId);

    % Load one step's settings from the T1 GUI into the main experiment GUI.
    seq = build_step_sequence(stepCfg, handlesAuto);
    apply_step_to_main_gui(seq, handlesMain);

    % Refresh globals from main GUI controls.
    Auto_LoadUserInputs(hObject, eventdata, handlesMain);

    if ~strcmpi(stepCfg.kind, 'preset')
        T1_SemiAuto_Run(hObject, eventdata, handlesMain, handlesAuto);
        run_configured_fit(stepCfg, handlesMain, handlesAuto);
        save_and_maybe_upload_main_figure( ...
            handlesMain, handlesAuto, gSaveDataAve.file, cfg, ...
            '. Current sequence is finished.');
    end

    if handlesAuto.pushbutton_stopProg.UserData
        break;
    end
end

end

function validate_pipeline_config(cfg)
for i = 1:numel(cfg.stepOrder)
    stepId = cfg.stepOrder{i};
    if ~isfield(cfg.steps, stepId)
        error('AutoPipelineConfig:MissingStep', ...
            'Step "%s" exists in cfg.stepOrder but is missing in cfg.steps.', stepId);
    end
end
end

function seq = build_step_sequence(stepCfg, handlesAuto)
switch lower(stepCfg.kind)
    case 'preset'
        seq = build_preset_step(handlesAuto);
    case 'generic'
        seq = build_generic_step(stepCfg, handlesAuto);
    case 'custom'
        switch stepCfg.customBuilder
            case 'build_step_t00'
                seq = build_step_t00(handlesAuto);
            case 'build_step_t11'
                seq = build_step_t11(handlesAuto);
            otherwise
                seq = feval(stepCfg.customBuilder, handlesAuto);
        end
    otherwise
        error('AutoPipelineConfig:UnsupportedStepKind', ...
            'Unsupported step kind: %s', stepCfg.kind);
end
end

function seq = build_preset_step(h)
if h.zone1_radio_button.Value
    seq.readout = get_control_string(h, 'initZ1');
    seq.CtrGateDur = get_control_string(h, 'readoutZ1');
elseif h.zone2_radio_button.Value
    seq.readout = get_control_string(h, 'initZ2');
    seq.CtrGateDur = get_control_string(h, 'readoutZ2');
elseif h.zone3_radio_button.Value
    seq.readout = get_control_string(h, 'initZ3');
    seq.CtrGateDur = get_control_string(h, 'readoutZ3');
else
    error('AutoPipelineConfig:NoZoneSelected', ...
        'No zone is selected in the T1 parameter GUI.');
end
end

function seq = build_generic_step(stepCfg, h)
seq = struct();
if isfield(stepCfg, 'sequenceName') && ~isempty(stepCfg.sequenceName)
    seq.name = stepCfg.sequenceName;
end

if isfield(stepCfg, 'uiStringMap') && ~isempty(stepCfg.uiStringMap)
    uiMap = stepCfg.uiStringMap;
    if iscell(uiMap) && numel(uiMap) == 1 && iscell(uiMap{1})
        uiMap = uiMap{1};
    end
    for i = 1:size(uiMap, 1)
        targetField = uiMap{i, 1};
        sourceControl = uiMap{i, 2};
        seq.(targetField) = get_control_string(h, sourceControl);
    end
end

if isfield(stepCfg, 'constantValues') && ~isempty(stepCfg.constantValues)
    f = fieldnames(stepCfg.constantValues);
    for i = 1:numel(f)
        seq.(f{i}) = stepCfg.constantValues.(f{i});
    end
end

if isfield(stepCfg, 'derivedValues') && ~isempty(stepCfg.derivedValues)
    f = fieldnames(stepCfg.derivedValues);
    for i = 1:numel(f)
        seq.(f{i}) = resolve_derived_value(stepCfg.derivedValues.(f{i}));
    end
end
end

function seq = build_step_t00(h)
[from1, to1, from2, to2] = split_sweep_range( ...
    str2double(get_control_string(h, 'startT1')), ...
    str2double(get_control_string(h, 'stopT1')));

seq.name = 'T1_S00_S01_S10';
seq.FROM1 = num2str(from1);
seq.TO1 = num2str(to1);
seq.SweepNPoints = get_control_string(h, 'nPtsT1');
seq.fixPow = get_control_string(h, 'MWPowerRabi');
seq.fixPow2 = get_control_string(h, 'MWPowerRabi2');
seq.Repeat = get_control_string(h, 'RepeatT1');
seq.Average = get_control_string(h, 'maxAveT1');
seq.useSG2 = 0;

seq.bSweep2 = 1;
seq.FROM2 = num2str(from2);
seq.TO2 = num2str(to2);
seq.SweepNPoints2 = 5;
end

function seq = build_step_t11(h)
[from1, to1, from2, to2] = split_sweep_range( ...
    str2double(get_control_string(h, 'startT12')), ...
    str2double(get_control_string(h, 'stopT12')));

seq.name = 'T1_S11_S1m1';
seq.FROM1 = num2str(from1);
seq.TO1 = num2str(to1);
seq.SweepNPoints = get_control_string(h, 'nPtsT12');
seq.fixPow = get_control_string(h, 'MWPowerRabi');
seq.fixPow2 = get_control_string(h, 'MWPowerRabi2');
seq.Repeat = get_control_string(h, 'RepeatT12');
seq.Average = get_control_string(h, 'maxAveT12');
seq.useSG2 = 1;

seq.bSweep2 = 1;
seq.FROM2 = num2str(from2);
seq.TO2 = num2str(to2);
seq.SweepNPoints2 = 5;
seq.DEERpi = resolve_derived_value('gmSEQ.RabiFitPi_ns');
end

function [from1, to1, from2, to2] = split_sweep_range(tStart, tStop)
span = tStop - tStart;
from1 = tStart;
to1 = tStart + round(span/4, -3);
from2 = to1;
to2 = tStop;
end

function out = resolve_derived_value(token)
global gmSEQ

switch token
    case 'gmSEQ.ESRFitFreq_GHz'
        out = sprintf('%.8f', gmSEQ.ESRFitFreq/1000);
    case 'gmSEQ.RabiFitPi_ns'
        out = sprintf('%.0f', gmSEQ.RabiFitPi);
    otherwise
        error('AutoPipelineConfig:UnknownDerivedToken', ...
            'Unknown derived token: %s', token);
end
end

function apply_step_to_main_gui(seq, handlesMain)
global gmSEQ

fields = fieldnames(seq);
for i = 1:numel(fields)
    fieldName = fields{i};
    value = seq.(fieldName);

    if strcmp(fieldName, 'name')
        handlesMain.sequence.Value = 1;
        handlesMain.sequence.String = {value};
        gmSEQ.name = {value};
        continue;
    end

    if ~isfield(handlesMain, fieldName)
        warning('T1_SemiAuto_Program:MissingMainControl', ...
            'Main GUI control "%s" does not exist. Skipping.', fieldName);
        continue;
    end

    set_control_value(handlesMain.(fieldName), value);
end
end

function set_control_value(hCtrl, value)
if ~isgraphics(hCtrl, 'uicontrol')
    return;
end

style = get(hCtrl, 'Style');
switch style
    case {'edit', 'text'}
        set(hCtrl, 'String', normalize_to_char(value));
    case {'checkbox', 'radiobutton', 'togglebutton', 'popupmenu', 'slider'}
        set(hCtrl, 'Value', normalize_to_numeric(value, 0));
    otherwise
        % Fallback: favor String when available.
        if isprop(hCtrl, 'String')
            set(hCtrl, 'String', normalize_to_char(value));
        elseif isprop(hCtrl, 'Value')
            set(hCtrl, 'Value', normalize_to_numeric(value, 0));
        end
end
end

function txt = get_control_string(handlesStruct, controlName)
if ~isfield(handlesStruct, controlName)
    error('T1_SemiAuto_Program:MissingControl', ...
        'Control "%s" not found in T1 parameter GUI handles.', controlName);
end

h = handlesStruct.(controlName);
if ~isgraphics(h, 'uicontrol')
    error('T1_SemiAuto_Program:InvalidControl', ...
        'Control "%s" is not a valid uicontrol.', controlName);
end

if isprop(h, 'String')
    txt = normalize_to_char(get(h, 'String'));
else
    txt = num2str(get(h, 'Value'));
end
end

function run_configured_fit(stepCfg, handlesMain, handlesAuto)
if ~isfield(stepCfg, 'fitFunction') || isempty(stepCfg.fitFunction)
    return;
end

if exist(stepCfg.fitFunction, 'file') ~= 2
    warning('T1_SemiAuto_Program:FitFunctionMissing', ...
        'Fit function "%s" not found on path.', stepCfg.fitFunction);
    return;
end

try
    feval(stepCfg.fitFunction, handlesMain, handlesAuto);
catch ME
    warning('T1_SemiAuto_Program:FitFunctionFailed', ...
        'Fit function "%s" failed: %s', stepCfg.fitFunction, ME.message);
end
end

function save_and_maybe_upload_main_figure(handlesMain, handlesAuto, runFileName, cfg, statusSuffix)
saveFolder = cfg.paths.saveFolder;
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

rawName = normalize_to_char(runFileName);
if isempty(rawName)
    rawName = ['AutoRun_' datestr(now, 'yyyymmdd_HHMMSS') '.txt'];
end
if handlesAuto.use_title.Value
    rawName = [normalize_to_char(handlesAuto.figTitle.String) rawName];
end
imageName = strrep(rawName, '.txt', '.png');
imagePath = fullfile(saveFolder, imageName);

imwrite(getframe(handlesMain.figure1).cdata, imagePath);

if ~handlesAuto.slackUploadFlag.Value
    return;
end

message = [normalize_to_char(handlesAuto.slackUploadText.String) statusSuffix];
scriptFolder = cfg.paths.slackScriptFolder;
keepCount = int32(cfg.slack.defaultKeep);

try
    if count(py.sys.path, scriptFolder) == 0
        insert(py.sys.path, int32(0), scriptFolder);
    end
    py.slack_upload_v2.upload_and_cleanup(imagePath, message, keepCount);
catch ME
    warning('T1_SemiAuto_Program:SlackUploadFailed', ...
        'Slack upload failed: %s', ME.message);
end
end

function out = normalize_to_char(in)
if iscell(in)
    if isempty(in)
        out = '';
    else
        out = normalize_to_char(in{1});
    end
elseif isstring(in)
    out = char(in);
elseif isnumeric(in)
    out = num2str(in);
elseif ischar(in)
    out = in;
else
    out = char(string(in));
end
end

function out = normalize_to_numeric(in, defaultValue)
if isnumeric(in)
    out = in;
    return;
end

inChar = normalize_to_char(in);
tmp = str2double(inChar);
if isnan(tmp)
    out = defaultValue;
else
    out = tmp;
end
end
