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
%          .allowZeroPersistentFallback (default true)
%          .allowPausedZeroPersistentFallback (default true)
%          .zeroPausedCurrentAbsTol (default 1e-3)
%          .useZeroPersistentFinalPolicy (default true)
%          .stopCheckEnabled       (default false)
%          .stopAppDataKey         (default 'BT_CONTROL_STOP_B_QUEUE')
%          .hFigAuto               (default [])
%          .stopWaitGranularitySec (default 2)
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
%        Special case for target Z=0: optional fallback pass when HS is off
%        and state is zero-current (STATE=8) or paused (STATE=3).

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
info.commLog = repmat(struct( ...
    'timestamp', '', ...
    'cmd', '', ...
    'response', '', ...
    'errorCode', NaN, ...
    'errorText', '', ...
    'errorRaw', ''), 0, 1);
info.lastErrorCode = NaN;
info.lastErrorText = '';
info.lastErrorRaw = '';
info.startPersistent = NaN;
info.endPersistent = NaN;
info.startPs = NaN;
info.endPs = NaN;
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
info.acceptedZeroPersistentFallback = false;
info.zeroPersistentFallbackReason = '';
info.zeroPersistentPolicyUsed = false;
info.zeroPersistentPolicyReason = '';

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

    [psStart, psStartErr] = read_ps_status();
    if ~isempty(psStartErr)
        message = psStartErr;
        finish_info();
        return;
    end
    info.startPs = psStart;
    log_msg(cfg, sprintf('Start status: PERSistent?=%d, PS?=%d', persStart, psStart));

    useZeroPersistentPolicy = (modeName == "persistent") && (ZkG == 0) && logical(cfg.useZeroPersistentFinalPolicy);

    % For field motion paths, force HS ON (PS=1) before ZERO/RAMP.
    if ~useZeroPersistentPolicy
        write_cmd("PS 1");
        if psStart ~= 1
            apply_hs_buffer('heatup_from_persistent', cfg.hsHeatUpMinBufferSec);
        end
        [okPsOn, psOnMsg] = wait_ps_status(1, heaterTimeoutSec, 'heater on before field motion');
        if ~okPsOn
            message = psOnMsg;
            finish_info();
            return;
        end
        [okHeatOn, heatOnMsg] = wait_not_state(9, heaterTimeoutSec, 'persistent-switch heating');
        if ~okHeatOn
            message = heatOnMsg;
            finish_info();
            return;
        end
        [psAfterOn, psAfterOnErr] = read_ps_status();
        if ~isempty(psAfterOnErr)
            message = psAfterOnErr;
            finish_info();
            return;
        end
        if psAfterOn ~= 1
            message = sprintf('Failed to turn HS on before field motion (PS=%d).', psAfterOn);
            finish_info();
            return;
        end
    end

    if cfg.setUnitEachCall
        write_cmd("CONF:FIELD:UNITS 0"); % 0 = kG
    end

    if useZeroPersistentPolicy
        [okPolicy, msgPolicy] = execute_zero_persistent_policy();
        if ~okPolicy
            message = msgPolicy;
            finish_info();
            return;
        end
        info.zeroPersistentPolicyUsed = true;
        info.zeroPersistentPolicyReason = msgPolicy;
        [stateCode, stateText, ~] = read_state();
        info.finalStateCode = stateCode;
        info.finalStateText = stateText;
        [psEnd, psEndErr] = read_ps_status();
        if isempty(psEndErr)
            info.endPs = psEnd;
        end
        [persEnd, persEndErr] = read_persistent();
        if isempty(persEndErr)
            info.endPersistent = logical(persEnd == 1);
        end
        info.errorQuery = read_error();
        ok = true;
        message = sprintf('Z magnet completed zero-persistent policy at %.6g kG.', ZkG);
        finish_info();
        return;
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
            [okFallback, fallbackReason] = zero_persistent_fallback_ok(ZkG);
            if ~okFallback
                message = persMsg;
                finish_info();
                return;
            end
            info.acceptedZeroPersistentFallback = true;
            info.zeroPersistentFallbackReason = fallbackReason;
            log_msg(cfg, sprintf('Accepted zero-field persistent fallback: %s', fallbackReason));
        end
    end

    [stateCode, stateText, ~] = read_state();
    info.finalStateCode = stateCode;
    info.finalStateText = stateText;
    [psEnd, psEndErr] = read_ps_status();
    if isempty(psEndErr)
        info.endPs = psEnd;
    end
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
        cmdChar = char(cmd);
        log_msg(cfg, sprintf('CMD> %s', cmdChar));
        writeline(tcp, cmd);
        info.commands{end + 1, 1} = cmdChar; %#ok<AGROW>
        info.responses{end + 1, 1} = ''; %#ok<AGROW>
        [errCode, errText, errRaw, okErr, errMsg] = check_last_error_after_comm();
        append_comm_log(cmdChar, '', errCode, errText, errRaw);
        if ~okErr
            error('BTControl:ControllerError', 'Controller error after "%s": %s', cmdChar, errMsg);
        end
    end

    function resp = query_cmd(cmd)
        cmd = string(cmd);
        cmdChar = char(cmd);
        resp = lowlevel_query_cmd(cmd);
        info.commands{end + 1, 1} = cmdChar; %#ok<AGROW>
        info.responses{end + 1, 1} = resp; %#ok<AGROW>

        if strcmpi(strtrim(cmdChar), 'SYST:ERR?')
            [errCode, errText] = parse_error_response(resp);
            append_comm_log(cmdChar, resp, errCode, errText, resp);
            info.lastErrorCode = errCode;
            info.lastErrorText = errText;
            info.lastErrorRaw = resp;
            return;
        end

        [errCode, errText, errRaw, okErr, errMsg] = check_last_error_after_comm();
        append_comm_log(cmdChar, resp, errCode, errText, errRaw);
        if ~okErr
            error('BTControl:ControllerError', 'Controller error after "%s": %s', cmdChar, errMsg);
        end
    end

    function resp = lowlevel_query_cmd(cmd)
        raw = writeread(tcp, string(cmd));
        if isstring(raw)
            resp = char(raw);
        else
            resp = char(raw(:).');
        end
        resp = strtrim(resp);
    end

    function [errCode, errText, errRaw, okErr, errMsg] = check_last_error_after_comm()
        errRaw = lowlevel_query_cmd("SYST:ERR?");
        [errCode, errText] = parse_error_response(errRaw);
        info.lastErrorCode = errCode;
        info.lastErrorText = errText;
        info.lastErrorRaw = errRaw;
        if isnan(errCode)
            okErr = false;
            errMsg = sprintf('Unable to parse SYST:ERR? response "%s".', errRaw);
            return;
        end
        if errCode ~= 0
            okErr = false;
            if isempty(errText)
                errMsg = sprintf('%d', errCode);
            else
                errMsg = sprintf('%d: %s', errCode, errText);
            end
            return;
        end
        okErr = true;
        errMsg = '';
    end

    function [errCode, errText] = parse_error_response(errRaw)
        errCode = NaN;
        errText = '';
        token = regexp(char(errRaw), '^\s*([+-]?\d+)\s*,?\s*(.*)\s*$', 'tokens', 'once');
        if isempty(token)
            return;
        end
        errCode = str2double(token{1});
        errText = strtrim(token{2});
        if numel(errText) >= 2 && errText(1) == '"' && errText(end) == '"'
            errText = errText(2:end-1);
        end
    end

    function append_comm_log(cmd, resp, errCode, errText, errRaw)
        rec = struct();
        rec.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
        rec.cmd = char(string(cmd));
        rec.response = char(string(resp));
        rec.errorCode = errCode;
        rec.errorText = char(string(errText));
        rec.errorRaw = char(string(errRaw));
        info.commLog(end + 1, 1) = rec; %#ok<AGROW>
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

    function [val, errMsgPs] = read_ps_status()
        raw = query_cmd("PS?");
        val = parse_first_integer(raw);
        if isnan(val)
            errMsgPs = sprintf('Unable to parse PS? response: "%s"', raw);
            return;
        end
        if val ~= 0 && val ~= 1
            errMsgPs = sprintf('Unexpected PS? value: %d', val);
            return;
        end
        errMsgPs = '';
    end

    function [okWait, waitMsg] = wait_state(targetState, timeoutSec, waitName)
        targetState = double(targetState);
        t0 = tic;
        while toc(t0) <= timeoutSec
            [stopNow, stopWhy] = is_stop_requested_local();
            if stopNow
                okWait = false;
                waitMsg = sprintf('Stop requested during %s: %s', waitName, stopWhy);
                return;
            end
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
            [stopSleep, stopWhySleep] = sleep_with_stop_check(max(0.01, cfg.pollSec));
            if stopSleep
                okWait = false;
                waitMsg = sprintf('Stop requested during %s wait: %s', waitName, stopWhySleep);
                return;
            end
        end
        okWait = false;
        waitMsg = sprintf('Timeout waiting for %s (target STATE=%d).', waitName, targetState);
    end

    function [okWait, waitMsg] = wait_not_state(blockState, timeoutSec, waitName)
        blockState = double(blockState);
        t0 = tic;
        while toc(t0) <= timeoutSec
            [stopNow, stopWhy] = is_stop_requested_local();
            if stopNow
                okWait = false;
                waitMsg = sprintf('Stop requested during %s: %s', waitName, stopWhy);
                return;
            end
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
            [stopSleep, stopWhySleep] = sleep_with_stop_check(max(0.01, cfg.pollSec));
            if stopSleep
                okWait = false;
                waitMsg = sprintf('Stop requested during %s wait: %s', waitName, stopWhySleep);
                return;
            end
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
            [stopNow, stopWhy] = is_stop_requested_local();
            if stopNow
                okWait = false;
                waitMsg = sprintf('Stop requested while waiting persistent mode: %s', stopWhy);
                return;
            end
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

            % Accept paused as a valid post-cooldown terminal mode when HS is off.
            if stateCode == 3
                [psVal, psErr] = read_ps_status();
                if ~isempty(psErr)
                    okWait = false;
                    waitMsg = psErr;
                    return;
                end
                if psVal == 0
                    okWait = true;
                    waitMsg = '';
                    return;
                end
            end

            log_msg(cfg, sprintf('Waiting persistent/paused mode: PERSistent?=%d, STATE=%d', persVal, stateCode));
            [stopSleep, stopWhySleep] = sleep_with_stop_check(max(0.01, cfg.pollSec));
            if stopSleep
                okWait = false;
                waitMsg = sprintf('Stop requested while waiting persistent mode: %s', stopWhySleep);
                return;
            end
        end
        okWait = false;
        waitMsg = 'Timeout waiting for PERSistent? == 1 or paused mode (STATE=3 with PS=0).';
    end

    function [okWait, waitMsg] = wait_ps_status(targetPs, timeoutSec, waitName)
        targetPs = double(targetPs);
        t0 = tic;
        while toc(t0) <= timeoutSec
            [stopNow, stopWhy] = is_stop_requested_local();
            if stopNow
                okWait = false;
                waitMsg = sprintf('Stop requested during %s: %s', waitName, stopWhy);
                return;
            end
            [psVal, psErr] = read_ps_status();
            if ~isempty(psErr)
                okWait = false;
                waitMsg = psErr;
                return;
            end
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
            if psVal == targetPs
                okWait = true;
                waitMsg = '';
                return;
            end
            log_msg(cfg, sprintf('Waiting %s: PS=%d (STATE=%d %s)', waitName, psVal, stateCode, stateText));
            [stopSleep, stopWhySleep] = sleep_with_stop_check(max(0.01, cfg.pollSec));
            if stopSleep
                okWait = false;
                waitMsg = sprintf('Stop requested during %s wait: %s', waitName, stopWhySleep);
                return;
            end
        end
        okWait = false;
        waitMsg = sprintf('Timeout waiting for %s (PS=%d).', waitName, targetPs);
    end

    function [okPolicy, msgPolicy] = execute_zero_persistent_policy()
        okPolicy = false;
        msgPolicy = '';

        [psVal, psErr] = read_ps_status();
        if ~isempty(psErr)
            msgPolicy = psErr;
            return;
        end
        [stateCode, stateText, stateErr] = read_state();
        if ~isempty(stateErr)
            msgPolicy = stateErr;
            return;
        end
        [curKnown, curVal, curCmd] = read_current_with_fallback();
        zeroCurrentKnown = curKnown && (abs(curVal) <= cfg.zeroPausedCurrentAbsTol);
        atZeroMode = (stateCode == 8);

        if psVal == 0 && (zeroCurrentKnown || atZeroMode)
            if atZeroMode
                msgPolicy = sprintf('Pass: HS off and zero-current mode (STATE=8). currentKnown=%d.', logical(curKnown));
            else
                msgPolicy = sprintf('Pass: HS off and |current|<=tol (|%.6g|<=%.6g via %s).', ...
                    curVal, cfg.zeroPausedCurrentAbsTol, curCmd);
            end
            okPolicy = true;
            return;
        end

        if psVal == 0
            log_msg(cfg, sprintf('Zero-persistent policy: HS off but not zero-safe (STATE=%d %s). Turning HS on and zeroing.', ...
                stateCode, stateText));
            write_cmd("PS 1");
            apply_hs_buffer('policy_heatup_for_zero', cfg.hsHeatUpMinBufferSec);
            [okHeatOn, heatOnMsg] = wait_not_state(9, heaterTimeoutSec, 'policy heatup transition');
            if ~okHeatOn
                msgPolicy = heatOnMsg;
                return;
            end
        else
            log_msg(cfg, 'Zero-persistent policy: HS on. Zeroing field then turning HS off.');
        end

        write_cmd("ZERO");
        [okZero, zeroMsg] = wait_state(8, zeroTimeoutSec, 'policy zero current (STATE=8)');
        if ~okZero
            msgPolicy = zeroMsg;
            return;
        end
        info.zeroCompleted = true;
        info.zeroFirstApplied = true;
        apply_ramp_buffer('policy_down_to_zero');

        write_cmd("PS 0");
        apply_hs_buffer('policy_cooldown_to_off', cfg.hsCoolDownMinBufferSec);
        [okPsOff, psOffMsg] = wait_ps_status(0, heaterTimeoutSec, 'policy PS off');
        if ~okPsOff
            msgPolicy = psOffMsg;
            return;
        end

        [psValF, psErrF] = read_ps_status();
        if ~isempty(psErrF)
            msgPolicy = psErrF;
            return;
        end
        [stateCodeF, stateTextF, stateErrF] = read_state();
        if ~isempty(stateErrF)
            msgPolicy = stateErrF;
            return;
        end
        [curKnownF, curValF, curCmdF] = read_current_with_fallback();
        zeroCurrentKnownF = curKnownF && (abs(curValF) <= cfg.zeroPausedCurrentAbsTol);
        atZeroModeF = (stateCodeF == 8);

        if psValF == 0 && (zeroCurrentKnownF || atZeroModeF)
            if atZeroModeF
                msgPolicy = sprintf('Pass after zeroing: HS off and zero-current mode (STATE=8). currentKnown=%d.', logical(curKnownF));
            else
                msgPolicy = sprintf('Pass after zeroing: HS off and |current|<=tol (|%.6g|<=%.6g via %s).', ...
                    curValF, cfg.zeroPausedCurrentAbsTol, curCmdF);
            end
            okPolicy = true;
            return;
        end

        msgPolicy = sprintf('Zero-persistent policy failed final check: PS=%d, STATE=%d (%s), currentKnown=%d, current=%.6g.', ...
            psValF, stateCodeF, stateTextF, logical(curKnownF), curValF);
    end

    function [okFallback, reason] = zero_persistent_fallback_ok(targetZkG)
        okFallback = false;
        reason = '';
        if ~(logical(cfg.allowZeroPersistentFallback) && targetZkG == 0)
            return;
        end

        [stateCode, stateText, stateErr] = read_state();
        if ~isempty(stateErr)
            reason = stateErr;
            return;
        end
        errTxt = read_error();
        if ~is_no_error(errTxt)
            reason = sprintf('Controller error while evaluating zero-field fallback: %s', errTxt);
            return;
        end
        [persVal, persErr] = read_persistent();
        if ~isempty(persErr)
            reason = persErr;
            return;
        end
        if persVal ~= 0
            reason = sprintf('Fallback not needed (PERSistent?=%d).', persVal);
            return;
        end

        if stateCode == 8
            okFallback = true;
            reason = 'HS off with zero-current state (STATE=8, PERSistent?=0).';
            return;
        end
        if logical(cfg.allowPausedZeroPersistentFallback) && stateCode == 3
            [curKnown, curVal, curCmd] = read_current_with_fallback();
            if ~curKnown
                reason = 'Paused-state fallback rejected: unable to read magnet current.';
                return;
            end
            if abs(curVal) <= cfg.zeroPausedCurrentAbsTol
                okFallback = true;
                reason = sprintf('HS off with paused state and near-zero current (STATE=3, PERSistent?=0, current=%.6g via %s).', ...
                    curVal, curCmd);
                return;
            end
            reason = sprintf('Paused-state fallback rejected: |current|=%.6g > tol %.6g.', ...
                abs(curVal), cfg.zeroPausedCurrentAbsTol);
            return;
        end

        reason = sprintf('Fallback rejected at target zero: STATE=%d (%s), PERSistent?=%d.', ...
            stateCode, stateText, persVal);
    end

    function [okCur, curVal, cmdUsed] = read_current_with_fallback()
        okCur = false;
        curVal = NaN;
        cmdUsed = '';
        % Use measured PSU current for zero/paused safety checks.
        cmdUsed = 'CURRent:SUPPly?';
        try
            raw = query_cmd(cmdUsed);
        catch
            return;
        end
        val = parse_first_number(raw);
        if isfinite(val)
            okCur = true;
            curVal = val;
        end
    end

    function apply_ramp_buffer(stageName)
        if cfg.psOffBufferSec <= 0
            return;
        end
        log_msg(cfg, sprintf('Buffer wait %.6g s after %s.', cfg.psOffBufferSec, stageName));
        [stopNow, stopWhy] = sleep_with_stop_check(cfg.psOffBufferSec);
        if stopNow
            error('BTControl:StopRequested', 'Stop requested during ramp buffer (%s): %s', stageName, stopWhy);
        end
        info.rampBufferAppliedCount = info.rampBufferAppliedCount + 1;
        info.rampBufferStages{end + 1, 1} = char(stageName); %#ok<AGROW>
    end

    function apply_hs_buffer(stageName, tSec)
        if tSec <= 0
            return;
        end
        log_msg(cfg, sprintf('HS min buffer wait %.6g s for %s.', tSec, stageName));
        [stopNow, stopWhy] = sleep_with_stop_check(tSec);
        if stopNow
            error('BTControl:StopRequested', 'Stop requested during HS buffer (%s): %s', stageName, stopWhy);
        end
        info.hsBufferAppliedCount = info.hsBufferAppliedCount + 1;
        info.hsBufferStages{end + 1, 1} = char(stageName); %#ok<AGROW>
    end

    function [stopNow, stopWhy] = is_stop_requested_local()
        stopNow = false;
        stopWhy = '';
        if ~isfield(cfg, 'stopCheckEnabled') || ~logical(cfg.stopCheckEnabled)
            return;
        end
        try
            latched = getappdata(0, cfg.stopAppDataKey);
        catch
            latched = false;
        end
        if ~isempty(latched) && logical(latched)
            stopNow = true;
            stopWhy = 'stop latch set';
            return;
        end
        try
            hFig = cfg.hFigAuto;
            if ~isempty(hFig) && (ishandle(hFig) || isgraphics(hFig))
                hAutoLocal = guidata(hFig);
                if isstruct(hAutoLocal) && isfield(hAutoLocal, 'pushbutton_stopProg') && isgraphics(hAutoLocal.pushbutton_stopProg, 'uicontrol')
                    ud = get(hAutoLocal.pushbutton_stopProg, 'UserData');
                    if ~isempty(ud) && logical(ud)
                        stopNow = true;
                        stopWhy = 'v2.1 stop button';
                    end
                end
            end
        catch
        end
    end

    function [stopNow, stopWhy] = sleep_with_stop_check(sec)
        stopNow = false;
        stopWhy = '';
        if sec <= 0
            return;
        end
        t0 = tic;
        while toc(t0) < sec
            try
                drawnow;
            catch
            end
            [stopNow, stopWhy] = is_stop_requested_local();
            if stopNow
                return;
            end
            remSec = sec - toc(t0);
            pause(min(max(0.005, cfg.stopWaitGranularitySec), max(0.005, remSec)));
        end
    end
end

function cfg = apply_defaults(cfg)
fileCfg = bt_control_cfg_load('set_z_magnet_mode');
cfg = set_default(cfg, 'ip', cfg_file_value(fileCfg, 'ip', '192.168.0.101'));
cfg = set_default(cfg, 'port', cfg_file_value(fileCfg, 'port', 7185));
cfg = set_default(cfg, 'timeoutSec', cfg_file_value(fileCfg, 'timeoutSec', 3));
cfg = set_default(cfg, 'pollSec', cfg_file_value(fileCfg, 'pollSec', 10));
cfg = set_default(cfg, 'setUnitEachCall', cfg_file_value(fileCfg, 'setUnitEachCall', true));
cfg = set_default(cfg, 'skipSecondRampIfTargetZero', cfg_file_value(fileCfg, 'skipSecondRampIfTargetZero', true));
cfg = set_default(cfg, 'zeroFirstDriven', cfg_file_value(fileCfg, 'zeroFirstDriven', false));
cfg = set_default(cfg, 'zeroFirstPersistent', cfg_file_value(fileCfg, 'zeroFirstPersistent', true));
cfg = set_default(cfg, 'waitPersistentBy', cfg_file_value(fileCfg, 'waitPersistentBy', 'pers_query'));
cfg = set_default(cfg, 'psOffBufferSec', cfg_file_value(fileCfg, 'psOffBufferSec', 20));
cfg = set_default(cfg, 'hsHeatUpMinBufferSec', cfg_file_value(fileCfg, 'hsHeatUpMinBufferSec', 30));
cfg = set_default(cfg, 'hsCoolDownMinBufferSec', cfg_file_value(fileCfg, 'hsCoolDownMinBufferSec', 600));
cfg = set_default(cfg, 'allowZeroPersistentFallback', cfg_file_value(fileCfg, 'allowZeroPersistentFallback', true));
cfg = set_default(cfg, 'allowPausedZeroPersistentFallback', cfg_file_value(fileCfg, 'allowPausedZeroPersistentFallback', true));
cfg = set_default(cfg, 'zeroPausedCurrentAbsTol', cfg_file_value(fileCfg, 'zeroPausedCurrentAbsTol', 1e-3));
cfg = set_default(cfg, 'useZeroPersistentFinalPolicy', cfg_file_value(fileCfg, 'useZeroPersistentFinalPolicy', true));
cfg = set_default(cfg, 'stopCheckEnabled', cfg_file_value(fileCfg, 'stopCheckEnabled', false));
cfg = set_default(cfg, 'stopAppDataKey', cfg_file_value(fileCfg, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE'));
cfg = set_default(cfg, 'hFigAuto', cfg_file_value(fileCfg, 'hFigAuto', []));
cfg = set_default(cfg, 'stopWaitGranularitySec', cfg_file_value(fileCfg, 'stopWaitGranularitySec', 2));
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
if ~(isnumeric(cfg.stopWaitGranularitySec) && isscalar(cfg.stopWaitGranularitySec) && isfinite(cfg.stopWaitGranularitySec) && cfg.stopWaitGranularitySec > 0)
    ok = false;
    errMsg = 'cfg.stopWaitGranularitySec must be a numeric scalar > 0.';
    return;
end
if ~(isnumeric(cfg.zeroPausedCurrentAbsTol) && isscalar(cfg.zeroPausedCurrentAbsTol) && isfinite(cfg.zeroPausedCurrentAbsTol) && cfg.zeroPausedCurrentAbsTol >= 0)
    ok = false;
    errMsg = 'cfg.zeroPausedCurrentAbsTol must be a numeric scalar >= 0.';
    return;
end
if ~((islogical(cfg.allowZeroPersistentFallback) || isnumeric(cfg.allowZeroPersistentFallback)) ...
        && isscalar(cfg.allowZeroPersistentFallback))
    ok = false;
    errMsg = 'cfg.allowZeroPersistentFallback must be logical/numeric scalar.';
    return;
end
if ~((islogical(cfg.allowPausedZeroPersistentFallback) || isnumeric(cfg.allowPausedZeroPersistentFallback)) ...
        && isscalar(cfg.allowPausedZeroPersistentFallback))
    ok = false;
    errMsg = 'cfg.allowPausedZeroPersistentFallback must be logical/numeric scalar.';
    return;
end
if ~((islogical(cfg.useZeroPersistentFinalPolicy) || isnumeric(cfg.useZeroPersistentFinalPolicy)) ...
        && isscalar(cfg.useZeroPersistentFinalPolicy))
    ok = false;
    errMsg = 'cfg.useZeroPersistentFinalPolicy must be logical/numeric scalar.';
    return;
end
if ~((islogical(cfg.stopCheckEnabled) || isnumeric(cfg.stopCheckEnabled)) ...
        && isscalar(cfg.stopCheckEnabled))
    ok = false;
    errMsg = 'cfg.stopCheckEnabled must be logical/numeric scalar.';
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

function val = parse_first_number(txt)
txt = char(txt);
token = regexp(txt, '[-+]?\d*\.?\d+([eE][-+]?\d+)?', 'match', 'once');
if isempty(token)
    val = NaN;
else
    val = str2double(token);
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
