function run_schedule(innerRunner, hObject, eventdata, handlesMain, handlesAuto)
% Optional top-level orchestration:
% for each configured (T, B) setpoint, apply device hooks then run inner flow.

cfg = AutoPipelineConfig();
outer = get_outer_cfg(cfg);

if ~outer.enabled
    innerRunner(hObject, eventdata, handlesMain, handlesAuto);
    return;
end

if isempty(outer.schedule)
    warning('autoloop:EmptySchedule', ...
        'cfg.outerAutomation.enabled is true but schedule is empty. Running inner flow once.');
    innerRunner(hObject, eventdata, handlesMain, handlesAuto);
    return;
end

originalTitle = local_get_string(handlesAuto.figTitle);

for iSetpoint = 1:numel(outer.schedule)
    if handlesAuto.pushbutton_stopProg.UserData
        break;
    end

    setpoint = outer.schedule(iSetpoint);
    local_print_setpoint(iSetpoint, numel(outer.schedule), setpoint);

    try
        apply_environment_setpoint(setpoint, outer);
    catch ME
        if outer.stopOnSetpointError
            rethrow(ME);
        end
        warning('autoloop:SetpointApplyFailed', ...
            'Failed to apply setpoint #%d (%s): %s. Skipping to next setpoint.', ...
            iSetpoint, local_get_label(setpoint, iSetpoint), ME.message);
        continue;
    end

    if outer.autoPrefixFigureTitle && handlesAuto.use_title.Value
        handlesAuto.figTitle.String = [local_get_label(setpoint, iSetpoint) '_' originalTitle];
    end

    innerRunner(hObject, eventdata, handlesMain, handlesAuto);

    if handlesAuto.pushbutton_stopProg.UserData
        break;
    end

    if outer.pauseAfterSetpointSec > 0
        pause(outer.pauseAfterSetpointSec);
    end
end

if outer.autoPrefixFigureTitle && handlesAuto.use_title.Value
    handlesAuto.figTitle.String = originalTitle;
end
end

function outer = get_outer_cfg(cfg)
outer = struct();
outer.enabled = false;
outer.temperatureHook = 'set_temperature';
outer.magneticFieldHook = 'set_magnetic_fields';
outer.allowMissingHooks = true;
outer.stopOnSetpointError = true;
outer.pauseAfterSetpointSec = 0;
outer.autoPrefixFigureTitle = true;
outer.schedule = struct([]);

if ~isstruct(cfg) || ~isfield(cfg, 'outerAutomation') || ~isstruct(cfg.outerAutomation)
    return;
end

u = cfg.outerAutomation;
f = fieldnames(outer);
for i = 1:numel(f)
    if isfield(u, f{i}) && ~isempty(u.(f{i}))
        outer.(f{i}) = u.(f{i});
    end
end
end

function apply_environment_setpoint(setpoint, outer)
if ~isfield(setpoint, 'temperature')
    error('autoloop:MissingTemperature', ...
        'Setpoint is missing field "temperature".');
end
if ~isfield(setpoint, 'magneticField')
    error('autoloop:MissingMagneticField', ...
        'Setpoint is missing field "magneticField".');
end

invoke_hook(outer.temperatureHook, setpoint.temperature, outer.allowMissingHooks, 'temperature');
invoke_hook(outer.magneticFieldHook, setpoint.magneticField, outer.allowMissingHooks, 'magnetic field');

settleSec = 0;
if isfield(setpoint, 'settleSec') && ~isempty(setpoint.settleSec)
    settleSec = setpoint.settleSec;
end
if settleSec > 0
    pause(settleSec);
end
end

function invoke_hook(funcName, value, allowMissingHooks, targetName)
funcName = local_normalize_to_char(funcName);
if isempty(funcName)
    return;
end

if exist(funcName, 'file') ~= 2
    if allowMissingHooks
        warning('autoloop:MissingHook', ...
            'Hook "%s" for %s is missing. Continuing without applying this setpoint value.', ...
            funcName, targetName);
        return;
    end
    error('autoloop:MissingHook', ...
        'Hook "%s" for %s is missing.', funcName, targetName);
end

feval(funcName, value);
end

function local_print_setpoint(iSetpoint, nSetpoints, setpoint)
label = local_get_label(setpoint, iSetpoint);
tStr = local_value_to_text(setpoint, 'temperature');
bStr = local_value_to_text(setpoint, 'magneticField');
disp(sprintf('[AutoLoop %d/%d] %s | T=%s | B=%s', ...
    iSetpoint, nSetpoints, label, tStr, bStr));
end

function out = local_value_to_text(s, fieldName)
if ~isfield(s, fieldName)
    out = 'N/A';
    return;
end

value = s.(fieldName);
if isnumeric(value)
    out = mat2str(value);
else
    out = local_normalize_to_char(value);
end
end

function label = local_get_label(setpoint, index)
if isfield(setpoint, 'label') && ~isempty(setpoint.label)
    label = local_normalize_to_char(setpoint.label);
else
    label = ['Setpoint_' num2str(index)];
end
end

function out = local_get_string(hCtrl)
if ~isgraphics(hCtrl, 'uicontrol')
    out = '';
    return;
end
out = local_normalize_to_char(get(hCtrl, 'String'));
end

function out = local_normalize_to_char(in)
if iscell(in)
    if isempty(in)
        out = '';
    else
        out = local_normalize_to_char(in{1});
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
