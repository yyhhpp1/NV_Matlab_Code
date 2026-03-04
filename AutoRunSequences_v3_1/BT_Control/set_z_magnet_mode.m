function [ok, message, info] = set_z_magnet_mode(ZkG, mode, cfg)
%SET_Z_MAGNET_MODE High-level Z-magnet transition with zero-first sequence.
%   [ok, message, info] = set_z_magnet_mode(ZkG, mode)
%   [ok, message, info] = set_z_magnet_mode(ZkG, mode, cfg)
%
% Inputs
%   ZkG  - Target Z field in kG.
%   mode - Final requested mode: 'driven' or 'persistent'.
%   cfg  - Optional struct:
%          .ip                      (default '192.168.0.101')
%          .port                    (default 7185)
%          .timeoutSec              (default 3)
%          .pollSec                 (default 0.25)
%          .setUnitEachCall         (default true)
%          .skipSecondRampIfTargetZero (default true)
%          .zeroFirstDriven         (default true)
%          .zeroFirstPersistent     (default true)
%          .waitPersistentBy        (default 'pers_query')
%          .psOffBufferSec          (default 10, applied after each ramp stage)
%          .hsHeatUpMinBufferSec    (default 30, min wait after PS 1)
%          .hsCoolDownMinBufferSec  (default 30, min wait after PS 0)
%          .verbose                 (default false)
%
%   Internal fixed timing constants (not configurable via cfg):
%       rampTimeoutSec = 1800
%       zeroTimeoutSec = 1800
%       heaterTimeoutSec = 120
%       persistentTimeoutSec = 300
%
% Transition sequence
%   1) Query PERSistent? (current state awareness).
%   2) If currently persistent, send PS 1 and wait heating transition.
%   3) Optional zero-first stage:
%      - if enabled for the requested final mode, send ZERO and wait STATE? == 8.
%      - if disabled, skip ZERO and ramp directly to target.
%   4) Ramp to target (or skip second ramp if target==0 and configured after ZERO stage).
%   5) End in requested final mode:
%      - driven: ensure PS 1
%      - persistent: PS 0 then wait PERSistent? == 1

ok = false;
message = '';
info = struct();

if nargin < 3 || isempty(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

rampTimeoutSec = 1800;
zeroTimeoutSec = 1800;
heaterTimeoutSec = 120;
persistentTimeoutSec = 800;

info.startedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
info.targetZkG = ZkG;
info.mode = lower(string(mode));
info.finalModeRequested = '';
info.endpoint = sprintf('%s:%d', cfg.ip, cfg.port);
info.waitPersistentBy = char(cfg.waitPersistentBy);
info.psOffBufferSec = cfg.psOffBufferSec;
info.commands = cell(0, 1);
info.responses = cell(0, 1);
info.startPersistent = NaN;
info.endPersistent = NaN;
info.zeroCompleted = false;
info.zeroFirstApplied = false;
info.zeroFirstSkipped = false;
info.zeroFirstByMode = struct('driven', logical(cfg.zeroFirstDriven), ...
    'persistent', logical(cfg.zeroFirstPersistent));
info.targetRampIssued = false;
info.holdReached = false;
info.rampBufferAppliedCount = 0;
info.rampBufferStages = cell(0, 1);
info.hsBufferAppliedCount = 0;
info.hsBufferStages = cell(0, 1);
info.finalStateCode = NaN;
info.finalStateText = '';
info.errorQuery = '';

[valid, modeName, errMsg] = validate_inputs(ZkG, mode, cfg);
if ~valid
    message = errMsg;
    info.endedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    return;
end
info.finalModeRequested = char(modeName);

tcp = [];
cleanupObj = onCleanup(@() local_disconnect(tcp)); %#ok<NASGU>

try
    tcp = tcpclient(cfg.ip, cfg.port);
    tcp.Timeout = cfg.timeoutSec;

    log_msg(cfg, sprintf('Connected to Z magnet at %s:%d', cfg.ip, cfg.port));

    [persStart, persStartErr] = read_persistent();
    if ~isempty(persStartErr)
        message = persStartErr;
        finish_info();
        return;
    end
    info.startPersistent = logical(persStart == 1);

    % If starting from persistent mode, turn heater ON before field motion.
    if info.startPersistent
        write_cmd("PS 1");
        apply_hs_buffer('heatup_from_persistent', cfg.hsHeatUpMinBufferSec);
        [okHeatOn, heatOnMsg] = wait_not_state(9, heaterTimeoutSec, 'persistent-switch heating');
        if ~okHeatOn
            message = heatOnMsg;
            finish_info();
            return;
        end
    end

    if cfg.setUnitEachCall
        write_cmd("CONF:FIELD:UNITS 0"); % 0 = kG
    end

    doZeroFirst = should_do_zero_first(modeName, cfg);
    if doZeroFirst
        % Zero-first stage (ZERO keeps target setpoint unchanged).
        write_cmd("ZERO");
        [okZero, zeroMsg] = wait_state(8, zeroTimeoutSec, 'zero current (STATE=8)');
        if ~okZero
            message = zeroMsg;
            finish_info();
            return;
        end
        info.zeroCompleted = true;
        info.zeroFirstApplied = true;
        apply_ramp_buffer('down_to_zero');
    else
        info.zeroFirstSkipped = true;
        log_msg(cfg, sprintf('Skipping ZERO stage for mode=%s by cfg policy.', modeName));
    end

    % Target stage.
    skipSecondRamp = (ZkG == 0) && cfg.skipSecondRampIfTargetZero && doZeroFirst;
    if ~skipSecondRamp
        write_cmd(sprintf("CONFigure:FIELD:TARGet %g", ZkG));
        write_cmd("RAMP");
        info.targetRampIssued = true;
        [okHold, holdMsg] = wait_state(2, rampTimeoutSec, 'hold at target');
        if ~okHold
            message = holdMsg;
            finish_info();
            return;
        end
        info.holdReached = true;
        apply_ramp_buffer('up_to_target');
    else
        log_msg(cfg, 'Target is zero and skipSecondRampIfTargetZero=true, skipping second ramp.');
    end

    % Final mode stage.
    if modeName == "driven"
        write_cmd("PS 1");
        apply_hs_buffer('heatup_final_driven', cfg.hsHeatUpMinBufferSec);
        [okFinalHeat, finalHeatMsg] = wait_not_state(9, heaterTimeoutSec, 'final driven heater transition');
        if ~okFinalHeat
            message = finalHeatMsg;
            finish_info();
            return;
        end
        errTxtDriven = read_error();
        if ~is_no_error(errTxtDriven)
            message = sprintf('Controller error during final driven stage: %s', errTxtDriven);
            finish_info();
            return;
        end
    else
        write_cmd("PS 0");
        apply_hs_buffer('cooldown_to_persistent', cfg.hsCoolDownMinBufferSec);
        [okPers, persMsg] = wait_persistent(persistentTimeoutSec, cfg.waitPersistentBy);
        if ~okPers
            message = persMsg;
            finish_info();
            return;
        end
    end

    [stateCode, stateText, ~] = read_state();
    info.finalStateCode = stateCode;
    info.finalStateText = stateText;
    [persEnd, persEndErr] = read_persistent();
    if isempty(persEndErr)
        info.endPersistent = logical(persEnd == 1);
    end
    info.errorQuery = read_error();

    ok = true;
    if info.zeroFirstApplied
        pathLabel = 'zero-first';
    else
        pathLabel = 'direct-ramp';
    end
    message = sprintf('Z magnet transitioned via %s path to %.6g kG and ended in %s mode.', ...
        pathLabel, ZkG, modeName);
    finish_info();
catch ME
    message = sprintf('set_z_magnet_mode failed: %s', ME.message);
    finish_info();
end

    function finish_info()
        info.endedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
    end

    function write_cmd(cmd)
        cmd = string(cmd);
        writeline(tcp, cmd);
        info.commands{end + 1, 1} = char(cmd); %#ok<AGROW>
    end

    function resp = query_cmd(cmd)
        cmd = string(cmd);
        raw = writeread(tcp, cmd);
        if isstring(raw)
            resp = char(raw);
        else
            resp = char(raw(:).');
        end
        resp = strtrim(resp);
        info.commands{end + 1, 1} = char(cmd); %#ok<AGROW>
        info.responses{end + 1, 1} = resp; %#ok<AGROW>
    end

    function [stateCode, stateText, errMsgState] = read_state()
        rawState = query_cmd("STATE?");
        stateCode = parse_first_integer(rawState);
        if isnan(stateCode)
            errMsgState = sprintf('Unable to parse STATE? response: "%s"', rawState);
            stateText = 'UNKNOWN';
            return;
        end
        stateText = state_name(stateCode);
        errMsgState = '';
    end

    function errTxt = read_error()
        errTxt = query_cmd("SYST:ERR?");
    end

    function [val, errMsgPers] = read_persistent()
        raw = query_cmd("PERSistent?");
        val = parse_first_integer(raw);
        if isnan(val)
            errMsgPers = sprintf('Unable to parse PERSistent? response: "%s"', raw);
            return;
        end
        if val ~= 0 && val ~= 1
            errMsgPers = sprintf('Unexpected PERSistent? value: %d', val);
            return;
        end
        errMsgPers = '';
    end

    function [okWait, waitMsg] = wait_state(targetState, timeoutSec, waitName)
        targetState = double(targetState);
        t0 = tic;
        while toc(t0) <= timeoutSec
            [stateCode, stateText, stateErr] = read_state();
            if ~isempty(stateErr)
                okWait = false;
                waitMsg = stateErr;
                return;
            end
            fatalMsg = fatal_state_message(stateCode);
            if ~isempty(fatalMsg)
                okWait = false;
                waitMsg = fatalMsg;
                return;
            end
            errTxt = read_error();
            if ~is_no_error(errTxt)
                okWait = false;
                waitMsg = sprintf('Controller error during %s: %s', waitName, errTxt);
                return;
            end
            if stateCode == targetState
                okWait = true;
                waitMsg = '';
                return;
            end
            log_msg(cfg, sprintf('Waiting %s: STATE=%d (%s)', waitName, stateCode, stateText));
            pause(max(0.01, cfg.pollSec));
        end
        okWait = false;
        waitMsg = sprintf('Timeout waiting for %s (target STATE=%d).', waitName, targetState);
    end

    function [okWait, waitMsg] = wait_not_state(blockState, timeoutSec, waitName)
        blockState = double(blockState);
        t0 = tic;
        while toc(t0) <= timeoutSec
            [stateCode, stateText, stateErr] = read_state();
            if ~isempty(stateErr)
                okWait = false;
                waitMsg = stateErr;
                return;
            end
            fatalMsg = fatal_state_message(stateCode);
            if ~isempty(fatalMsg)
                okWait = false;
                waitMsg = fatalMsg;
                return;
            end
            errTxt = read_error();
            if ~is_no_error(errTxt)
                okWait = false;
                waitMsg = sprintf('Controller error during %s: %s', waitName, errTxt);
                return;
            end
            if stateCode ~= blockState
                okWait = true;
                waitMsg = '';
                return;
            end
            log_msg(cfg, sprintf('Waiting %s: still STATE=%d (%s)', waitName, stateCode, stateText));
            pause(max(0.01, cfg.pollSec));
        end
        okWait = false;
        waitMsg = sprintf('Timeout waiting for %s (STATE != %d).', waitName, blockState);
    end

    function [okWait, waitMsg] = wait_persistent(timeoutSec, method)
        method = lower(string(method));
        if method ~= "pers_query"
            okWait = false;
            waitMsg = sprintf('Unsupported cfg.waitPersistentBy value: %s', method);
            return;
        end

        t0 = tic;
        while toc(t0) <= timeoutSec
            [stateCode, ~, stateErr] = read_state();
            if ~isempty(stateErr)
                okWait = false;
                waitMsg = stateErr;
                return;
            end
            fatalMsg = fatal_state_message(stateCode);
            if ~isempty(fatalMsg)
                okWait = false;
                waitMsg = fatalMsg;
                return;
            end

            errTxt = read_error();
            if ~is_no_error(errTxt)
                okWait = false;
                waitMsg = sprintf('Controller error while waiting persistent mode: %s', errTxt);
                return;
            end

            [persVal, persErr] = read_persistent();
            if ~isempty(persErr)
                okWait = false;
                waitMsg = persErr;
                return;
            end
            if persVal == 1
                okWait = true;
                waitMsg = '';
                return;
            end

            log_msg(cfg, 'Waiting persistent mode: PERSistent? = 0');
            pause(max(0.01, cfg.pollSec));
        end
        okWait = false;
        waitMsg = 'Timeout waiting for PERSistent? == 1.';
    end

    function apply_ramp_buffer(stageName)
        if cfg.psOffBufferSec <= 0
            return;
        end
        log_msg(cfg, sprintf('Buffer wait %.6g s after %s.', cfg.psOffBufferSec, stageName));
        pause(cfg.psOffBufferSec);
        info.rampBufferAppliedCount = info.rampBufferAppliedCount + 1;
        info.rampBufferStages{end + 1, 1} = char(stageName); %#ok<AGROW>
    end

    function apply_hs_buffer(stageName, tSec)
        if tSec <= 0
            return;
        end
        log_msg(cfg, sprintf('HS min buffer wait %.6g s for %s.', tSec, stageName));
        pause(tSec);
        info.hsBufferAppliedCount = info.hsBufferAppliedCount + 1;
        info.hsBufferStages{end + 1, 1} = char(stageName); %#ok<AGROW>
    end
end

function cfg = apply_defaults(cfg)
cfg = set_default(cfg, 'ip', '192.168.0.101');
cfg = set_default(cfg, 'port', 7185);
cfg = set_default(cfg, 'timeoutSec', 3);
cfg = set_default(cfg, 'pollSec', 10);
cfg = set_default(cfg, 'setUnitEachCall', true);
cfg = set_default(cfg, 'skipSecondRampIfTargetZero', true);
cfg = set_default(cfg, 'zeroFirstDriven', false);
cfg = set_default(cfg, 'zeroFirstPersistent', true);
cfg = set_default(cfg, 'waitPersistentBy', 'pers_query');
cfg = set_default(cfg, 'psOffBufferSec', 20);
cfg = set_default(cfg, 'hsHeatUpMinBufferSec', 30);
cfg = set_default(cfg, 'hsCoolDownMinBufferSec', 600);
cfg = set_default(cfg, 'verbose', true);
end

function cfg = set_default(cfg, key, val)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = val;
end
end

function [ok, modeName, errMsg] = validate_inputs(ZkG, mode, cfg)
modeName = lower(string(mode));
if ~(isnumeric(ZkG) && isscalar(ZkG) && isfinite(ZkG))
    ok = false;
    errMsg = 'ZkG must be a finite numeric scalar.';
    return;
end
if ~(modeName == "driven" || modeName == "persistent")
    ok = false;
    errMsg = 'mode must be ''driven'' or ''persistent''.';
    return;
end

if ~(isnumeric(cfg.port) && isscalar(cfg.port) && isfinite(cfg.port) && cfg.port > 0)
    ok = false;
    errMsg = 'cfg.port must be a positive numeric scalar.';
    return;
end
if ~(isnumeric(cfg.pollSec) && isscalar(cfg.pollSec) && isfinite(cfg.pollSec) && cfg.pollSec > 0)
    ok = false;
    errMsg = 'cfg.pollSec must be a positive numeric scalar.';
    return;
end
if ~((islogical(cfg.skipSecondRampIfTargetZero) || isnumeric(cfg.skipSecondRampIfTargetZero)) ...
        && isscalar(cfg.skipSecondRampIfTargetZero))
    ok = false;
    errMsg = 'cfg.skipSecondRampIfTargetZero must be logical/numeric scalar.';
    return;
end
if ~((islogical(cfg.zeroFirstDriven) || isnumeric(cfg.zeroFirstDriven)) ...
        && isscalar(cfg.zeroFirstDriven))
    ok = false;
    errMsg = 'cfg.zeroFirstDriven must be logical/numeric scalar.';
    return;
end
if ~((islogical(cfg.zeroFirstPersistent) || isnumeric(cfg.zeroFirstPersistent)) ...
        && isscalar(cfg.zeroFirstPersistent))
    ok = false;
    errMsg = 'cfg.zeroFirstPersistent must be logical/numeric scalar.';
    return;
end
if ~(isnumeric(cfg.psOffBufferSec) && isscalar(cfg.psOffBufferSec) && isfinite(cfg.psOffBufferSec) && cfg.psOffBufferSec >= 0)
    ok = false;
    errMsg = 'cfg.psOffBufferSec must be a numeric scalar >= 0.';
    return;
end
if ~(isnumeric(cfg.hsHeatUpMinBufferSec) && isscalar(cfg.hsHeatUpMinBufferSec) && isfinite(cfg.hsHeatUpMinBufferSec) && cfg.hsHeatUpMinBufferSec >= 0)
    ok = false;
    errMsg = 'cfg.hsHeatUpMinBufferSec must be a numeric scalar >= 0.';
    return;
end
if ~(isnumeric(cfg.hsCoolDownMinBufferSec) && isscalar(cfg.hsCoolDownMinBufferSec) && isfinite(cfg.hsCoolDownMinBufferSec) && cfg.hsCoolDownMinBufferSec >= 0)
    ok = false;
    errMsg = 'cfg.hsCoolDownMinBufferSec must be a numeric scalar >= 0.';
    return;
end
if lower(string(cfg.waitPersistentBy)) ~= "pers_query"
    ok = false;
    errMsg = 'cfg.waitPersistentBy currently supports only ''pers_query''.';
    return;
end

ok = true;
errMsg = '';
end

function tf = is_no_error(errTxt)
e = strtrim(char(errTxt));
tf = startsWith(e, '0') || startsWith(lower(e), '+0') || contains(lower(e), 'no error');
end

function code = parse_first_integer(txt)
txt = char(txt);
token = regexp(txt, '[-+]?\d+', 'match', 'once');
if isempty(token)
    code = NaN;
else
    code = str2double(token);
end
end

function msg = fatal_state_message(stateCode)
msg = '';
if stateCode == 7
    msg = 'Magnet quench detected (STATE=7).';
elseif stateCode == 11
    msg = 'External rampdown active (STATE=11).';
end
end

function name = state_name(code)
switch double(code)
    case 1
        name = 'RAMPING';
    case 2
        name = 'HOLDING';
    case 3
        name = 'PAUSED';
    case 4
        name = 'MANUAL_UP';
    case 5
        name = 'MANUAL_DOWN';
    case 6
        name = 'ZEROING_CURRENT';
    case 7
        name = 'QUENCH';
    case 8
        name = 'AT_ZERO_CURRENT';
    case 9
        name = 'HEATING_PSWITCH';
    case 10
        name = 'COOLING_PSWITCH';
    case 11
        name = 'EXTERNAL_RAMPDOWN';
    otherwise
        name = sprintf('STATE_%d', code);
end
end

function tf = should_do_zero_first(modeName, cfg)
if modeName == "driven"
    tf = logical(cfg.zeroFirstDriven);
else
    tf = logical(cfg.zeroFirstPersistent);
end
end

function local_disconnect(tcp)
if isempty(tcp)
    return;
end
try %#ok<TRYNC>
    clear tcp
end
end

function log_msg(cfg, txt)
if isfield(cfg, 'verbose') && cfg.verbose
    fprintf('[set_z_magnet_mode] %s\n', txt);
end
end
