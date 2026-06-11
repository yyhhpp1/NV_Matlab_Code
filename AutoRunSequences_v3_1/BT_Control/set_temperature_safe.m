function [ok, message, info] = set_temperature_safe(TtargetK, cfg)
%SET_TEMPERATURE_SAFE Safely change temperature with magnet-aware gating.
%   [ok, message, info] = set_temperature_safe(TtargetK, cfg)
%
% Required cfg fields:
%   tcIp, magIp, T_safe_max, T_tol, holdSec, maxWaitSec, pollSec,
%   pidP, pidI, pidD
%
% Optional cfg fields:
%   lookbackMin (default 5)
%   commRetryCount (default 3)
%   commRetryBackoffSec (default 0.5)
%   magPort (default 7185)
%   magTimeoutSec (default 3)
%   tcConnectTimeoutSec (default 20)
%   tcResponseTimeoutSec (default 30)
%   stopCheckEnabled (default false)
%   stopAppDataKey (default 'BT_CONTROL_STOP_B_QUEUE')
%   hFigAuto (default [])
%   verbose (default false)
%
% Fixed IDs in this v1 module:
%   control channel = CH:8
%   magnet-temp channel = CH:3
%   heater = 4

ok = false;
message = '';
info = struct();

if nargin < 2 || ~isstruct(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

info.startedAt = now_stamp();
info.targetK = TtargetK;
info.channels = struct('control', 8, 'magnet', 3);
info.heaterNr = 4;
info.heaterOffIssued = false;
info.heaterOnIssued = false;
info.settled = false;
info.abortReason = '';
info.samples = repmat(struct('tNow', '', 'T8_K', NaN, 'T3_K', NaN), 0, 1);
info.retryStats = struct( ...
    'readCh8Failures', 0, ...
    'readCh3Failures', 0, ...
    'heaterOnFailures', 0, ...
    'heaterOffFailures', 0);
info.magGateStart = struct('ok', false, 'ps', NaN, 'state', NaN, 'message', '');
info.precheck = struct('T3_K', NaN, 'T3_time', '', 'tempGateOk', false);
info.final = struct('T8_K', NaN, 'T8_time', '', 'T3_K', NaN, 'T3_time', '');

[valid, errMsg] = validate_inputs(TtargetK, cfg);
if ~valid
    message = errMsg;
    info.abortReason = errMsg;
    info.endedAt = now_stamp();
    return;
end

[connEffInit, respEffInit] = effective_comm_timeouts(cfg);
vlog(cfg, 'Start: target=%.6g K, maxWait=%.6g s, poll=%.6g s, hold=%.6g s, stopGranularity=%.6g s, commTimeout(connect=%.6g s,response=%.6g s)', ...
    TtargetK, cfg.maxWaitSec, cfg.pollSec, cfg.holdSec, cfg.stopWaitGranularitySec, connEffInit, respEffInit);

[stopNow, stopWhy] = is_stop_requested_local(cfg);
if stopNow
    message = sprintf('Stop requested before temperature change: %s', stopWhy);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return;
end

[connEff, respEff] = effective_comm_timeouts(cfg);
vlog(cfg, 'Magnet gate precheck...');
[gateOk, gateInfo, gateMsg] = mag_z_gate_precheck(cfg.magIp, struct( ...
    'port', cfg.magPort, ...
    'timeoutSec', cfg.magTimeoutSec, ...
    'requirePsZero', cfg.magGateRequirePsZero, ...
    'allowPausedStateWithPsOff', cfg.magGateAllowPausedStateWithPsOff, ...
    'pausedCurrentAbsTol', cfg.magGatePausedCurrentAbsTol));
info.magGateStart = gateInfo;
if ~gateOk
    message = sprintf('Magnet pre-check gate failed: %s', gateMsg);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return; % keep heater unchanged by policy
end
vlog(cfg, 'Magnet gate OK: %s', gateMsg);

[connEff, respEff] = effective_comm_timeouts(cfg);
vlog(cfg, 'Pre-check CH:3 read (effective timeouts connect=%.6g s, response=%.6g s)...', connEff, respEff);
[okT3pre, T3pre, t3pre, msgT3pre] = read_channel_with_retry(cfg.tcIp, 3, cfg, 'readCh3Failures');
if ~okT3pre
    message = sprintf('Pre-check CH:3 read failed: %s', msgT3pre);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return; % keep heater unchanged by policy
end
info.precheck.T3_K = T3pre;
info.precheck.T3_time = t3pre;
info.precheck.tempGateOk = (T3pre <= cfg.T_safe_max);

if T3pre > cfg.T_safe_max
    vlog(cfg, 'Pre-check CH:3=%.6g K exceeds T_safe_max=%.6g K, turning heater OFF.', T3pre, cfg.T_safe_max);
    [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
    info.heaterOffIssued = true;
    message = sprintf('Pre-check CH:3 above T_safe_max (%.6g K > %.6g K). Heater OFF. %s', ...
        T3pre, cfg.T_safe_max, offMsg);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return;
end

[connEff, respEff] = effective_comm_timeouts(cfg);
vlog(cfg, 'Heater ON command (effective timeouts connect=%.6g s, response=%.6g s)...', connEff, respEff);
[okOn, onMsg] = heater_on_with_retry(cfg.tcIp, TtargetK, cfg);
if ~okOn
    if is_stop_message(onMsg)
        message = sprintf('Stop requested before heater-ON was confirmed. Heater state preserved. (%s)', onMsg);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end
    [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
    info.heaterOffIssued = true;
    message = sprintf('Failed to enable heater control: %s. %s', onMsg, offMsg);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return;
end
info.heaterOnIssued = true;
vlog(cfg, 'Heater ON acknowledged. Enter stabilization loop.');

tStart = tic;
tInTol = NaN;
while toc(tStart) <= cfg.maxWaitSec
    [stopNow, stopWhy] = is_stop_requested_local(cfg);
    if stopNow
        message = sprintf('Stop requested during temperature stabilization. Heater state preserved. (%s)', stopWhy);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end

    [okT8, T8, t8, msgT8] = read_channel_with_retry(cfg.tcIp, 8, cfg, 'readCh8Failures');
    if ~okT8
        if is_stop_message(msgT8)
            message = sprintf('Stop requested during CH:8 read. Heater state preserved. (%s)', msgT8);
            info.abortReason = message;
            info.endedAt = now_stamp();
            return;
        end
        [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
        info.heaterOffIssued = true;
        message = sprintf('Runtime CH:8 read failed after retries: %s. %s', msgT8, offMsg);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end

    [okT3, T3, t3, msgT3] = read_channel_with_retry(cfg.tcIp, 3, cfg, 'readCh3Failures');
    if ~okT3
        if is_stop_message(msgT3)
            message = sprintf('Stop requested during CH:3 read. Heater state preserved. (%s)', msgT3);
            info.abortReason = message;
            info.endedAt = now_stamp();
            return;
        end
        [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
        info.heaterOffIssued = true;
        message = sprintf('Runtime CH:3 read failed after retries: %s. %s', msgT3, offMsg);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end

    row = struct('tNow', now_stamp(), 'T8_K', T8, 'T3_K', T3);
    info.samples(end + 1, 1) = row; %#ok<AGROW>
    info.final.T8_K = T8;
    info.final.T8_time = t8;
    info.final.T3_K = T3;
    info.final.T3_time = t3;
    elapsed = toc(tStart);
    dT = abs(T8 - TtargetK);
    if isnan(tInTol)
        holdNow = 0;
    else
        holdNow = toc(tInTol);
    end
    vlog(cfg, 'Loop: t=%.3f/%.3f s, T8=%.6g K (|dT|=%.6g, tol=%.6g), T3=%.6g K, inTolHold=%.3f/%.3f s', ...
        elapsed, cfg.maxWaitSec, T8, dT, cfg.T_tol, T3, holdNow, cfg.holdSec);

    if T3 > cfg.T_safe_max
        [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
        info.heaterOffIssued = true;
        message = sprintf('Runtime CH:3 above T_safe_max (%.6g K > %.6g K). Heater OFF. %s', ...
            T3, cfg.T_safe_max, offMsg);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end

    if abs(T8 - TtargetK) <= cfg.T_tol
        if isnan(tInTol)
            tInTol = tic;
        end
        if toc(tInTol) >= cfg.holdSec
            ok = true;
            info.settled = true;
            message = sprintf('Temperature settled at %.6g K (target %.6g K). Heater kept ON.', T8, TtargetK);
            info.endedAt = now_stamp();
            return;
        end
    else
        tInTol = NaN;
    end

    [stopDuringSleep, stopWhySleep] = sleep_with_stop_check(max(0.01, cfg.pollSec), cfg);
    if stopDuringSleep
        message = sprintf('Stop requested during temperature wait. Heater state preserved. (%s)', stopWhySleep);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end
end

[~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
info.heaterOffIssued = true;
message = sprintf('Timeout before stabilization. Heater OFF. %s', offMsg);
info.abortReason = message;
info.endedAt = now_stamp();

    function [okRead, TK, tStr, errRead] = read_channel_with_retry(tcIp, ch, cfgLocal, retryField)
        okRead = false;
        TK = NaN;
        tStr = '';
        errRead = 'unknown';
        for k = 1:cfgLocal.commRetryCount
            [stopNowLocal, stopWhyLocal] = is_stop_requested_local(cfgLocal);
            if stopNowLocal
                errRead = sprintf('Stop requested: %s', stopWhyLocal);
                return;
            end
            [connEffLocal, respEffLocal] = effective_comm_timeouts(cfgLocal);
            readCfg = struct( ...
                'connectTimeoutSec', connEffLocal, ...
                'responseTimeoutSec', respEffLocal);
            vlog(cfgLocal, 'Read CH:%d attempt %d/%d (timeouts connect=%.6g s, response=%.6g s)', ...
                ch, k, cfgLocal.commRetryCount, connEffLocal, respEffLocal);
            [ok1, t1, tdt, msg1] = bf_tc_read_latest_channel(tcIp, ch, cfgLocal.lookbackMin, readCfg);
            if ok1
                okRead = true;
                TK = t1;
                tStr = char(tdt);
                errRead = '';
                return;
            end
            info.retryStats.(retryField) = info.retryStats.(retryField) + 1;
            errRead = msg1;
            if cfgLocal.verbose
                fprintf('[set_temperature_safe] CH:%d read retry %d/%d failed: %s\n', ...
                    ch, k, cfgLocal.commRetryCount, msg1);
            end
            if k < cfgLocal.commRetryCount
                [stopBackoff, stopWhyBackoff] = sleep_with_stop_check(max(0, cfgLocal.commRetryBackoffSec), cfgLocal);
                if stopBackoff
                    errRead = sprintf('Stop requested: %s', stopWhyBackoff);
                    return;
                end
            end
        end
    end

    function [okOnLocal, msgOn] = heater_on_with_retry(tcIp, targetK, cfgLocal)
        okOnLocal = false;
        msgOn = 'unknown';
        [connEffLocal, respEffLocal] = effective_comm_timeouts(cfgLocal);
        hcfg = struct( ...
            'setpointK', targetK, ...
            'pidP', cfgLocal.pidP, ...
            'pidI', cfgLocal.pidI, ...
            'pidD', cfgLocal.pidD, ...
            'connectTimeoutSec', connEffLocal, ...
            'responseTimeoutSec', respEffLocal);
        for k = 1:cfgLocal.commRetryCount
            [stopNowLocal, stopWhyLocal] = is_stop_requested_local(cfgLocal);
            if stopNowLocal
                msgOn = sprintf('Stop requested: %s', stopWhyLocal);
                return;
            end
            vlog(cfgLocal, 'Heater ON attempt %d/%d (timeouts connect=%.6g s, response=%.6g s)', ...
                k, cfgLocal.commRetryCount, connEffLocal, respEffLocal);
            [okH, msgH] = bf_tc_set_heater4(tcIp, true, hcfg);
            if okH
                okOnLocal = true;
                msgOn = 'Heater ON command accepted.';
                return;
            end
            info.retryStats.heaterOnFailures = info.retryStats.heaterOnFailures + 1;
            msgOn = msgH;
            if k < cfgLocal.commRetryCount
                [stopBackoff, stopWhyBackoff] = sleep_with_stop_check(max(0, cfgLocal.commRetryBackoffSec), cfgLocal);
                if stopBackoff
                    msgOn = sprintf('Stop requested: %s', stopWhyBackoff);
                    return;
                end
            end
        end
    end

    function [okOffLocal, msgOff] = heater_off_with_retry(tcIp, cfgLocal)
        okOffLocal = false;
        msgOff = 'Heater OFF command failed.';
        [connEffLocal, respEffLocal] = effective_comm_timeouts(cfgLocal);
        hcfgOff = struct('connectTimeoutSec', connEffLocal, 'responseTimeoutSec', respEffLocal);
        for k = 1:cfgLocal.commRetryCount
            vlog(cfgLocal, 'Heater OFF attempt %d/%d (timeouts connect=%.6g s, response=%.6g s)', ...
                k, cfgLocal.commRetryCount, connEffLocal, respEffLocal);
            [okH, msgH] = bf_tc_set_heater4(tcIp, false, hcfgOff);
            if okH
                okOffLocal = true;
                msgOff = 'Heater OFF command accepted.';
                return;
            end
            info.retryStats.heaterOffFailures = info.retryStats.heaterOffFailures + 1;
            msgOff = msgH;
            if k < cfgLocal.commRetryCount
                [stopBackoff, stopWhyBackoff] = sleep_with_stop_check(max(0, cfgLocal.commRetryBackoffSec), cfgLocal);
                if stopBackoff
                    msgOff = sprintf('Stop requested: %s', stopWhyBackoff);
                    return;
                end
            end
        end
    end

    function [stopNowLocal, stopWhyLocal] = is_stop_requested_local(cfgLocal)
        stopNowLocal = false;
        stopWhyLocal = '';
        if ~isfield(cfgLocal, 'stopCheckEnabled') || ~logical(cfgLocal.stopCheckEnabled)
            return;
        end
        try
            latched = getappdata(0, cfgLocal.stopAppDataKey);
        catch
            latched = false;
        end
        if ~isempty(latched) && logical(latched)
            stopNowLocal = true;
            stopWhyLocal = 'stop latch set';
            return;
        end
        try
            hFig = cfgLocal.hFigAuto;
            if ~isempty(hFig) && (ishandle(hFig) || isgraphics(hFig))
                hAutoLocal = guidata(hFig);
                if isstruct(hAutoLocal) && isfield(hAutoLocal, 'pushbutton_stopProg') && isgraphics(hAutoLocal.pushbutton_stopProg, 'uicontrol')
                    ud = get(hAutoLocal.pushbutton_stopProg, 'UserData');
                    if ~isempty(ud) && logical(ud)
                        stopNowLocal = true;
                        stopWhyLocal = 'v2.1 stop button';
                    end
                end
            end
        catch
        end
    end

    function [stopNowLocal, stopWhyLocal] = sleep_with_stop_check(sec, cfgLocal)
        stopNowLocal = false;
        stopWhyLocal = '';
        if sec <= 0
            return;
        end
        t0 = tic;
        while toc(t0) < sec
            try
                drawnow;
            catch
            end
            [stopNowLocal, stopWhyLocal] = is_stop_requested_local(cfgLocal);
            if stopNowLocal
                return;
            end
            remSec = sec - toc(t0);
            pause(min(max(0.005, cfgLocal.stopWaitGranularitySec), max(0.005, remSec)));
        end
    end

    function [connectSec, responseSec] = effective_comm_timeouts(cfgLocal)
        connectSec = cfgLocal.tcConnectTimeoutSec;
        responseSec = cfgLocal.tcResponseTimeoutSec;
        if isfield(cfgLocal, 'stopCheckEnabled') && logical(cfgLocal.stopCheckEnabled)
            cap = cfgLocal.commMaxBlockSecWhenStop;
            if isfinite(cap) && cap > 0
                connectSec = min(connectSec, cap);
                responseSec = min(responseSec, cap);
            end
        end
    end

    function tf = is_stop_message(msgIn)
        tf = contains(lower(char(string(msgIn))), 'stop requested');
    end

    function vlog(cfgLocal, fmt, varargin)
        if isfield(cfgLocal, 'verbose') && logical(cfgLocal.verbose)
            fprintf('[set_temperature_safe] %s\n', sprintf(fmt, varargin{:}));
        end
    end
end

function cfg = apply_defaults(cfg)
fileCfg = bt_control_cfg_load('set_temperature_safe');
cfg = set_default(cfg, 'lookbackMin', cfg_file_value(fileCfg, 'lookbackMin', 5));
cfg = set_default(cfg, 'commRetryCount', cfg_file_value(fileCfg, 'commRetryCount', 3));
cfg = set_default(cfg, 'commRetryBackoffSec', cfg_file_value(fileCfg, 'commRetryBackoffSec', 0.5));
cfg = set_default(cfg, 'magPort', cfg_file_value(fileCfg, 'magPort', 7185));
cfg = set_default(cfg, 'magTimeoutSec', cfg_file_value(fileCfg, 'magTimeoutSec', 3));
cfg = set_default(cfg, 'magGateRequirePsZero', cfg_file_value(fileCfg, 'magGateRequirePsZero', false));
cfg = set_default(cfg, 'magGateAllowPausedStateWithPsOff', cfg_file_value(fileCfg, 'magGateAllowPausedStateWithPsOff', false));
cfg = set_default(cfg, 'magGatePausedCurrentAbsTol', cfg_file_value(fileCfg, 'magGatePausedCurrentAbsTol', 1e-3));
cfg = set_default(cfg, 'tcConnectTimeoutSec', cfg_file_value(fileCfg, 'tcConnectTimeoutSec', 20));
cfg = set_default(cfg, 'tcResponseTimeoutSec', cfg_file_value(fileCfg, 'tcResponseTimeoutSec', 30));
cfg = set_default(cfg, 'commMaxBlockSecWhenStop', cfg_file_value(fileCfg, 'commMaxBlockSecWhenStop', 2));
cfg = set_default(cfg, 'stopWaitGranularitySec', cfg_file_value(fileCfg, 'stopWaitGranularitySec', 2));
cfg = set_default(cfg, 'stopCheckEnabled', cfg_file_value(fileCfg, 'stopCheckEnabled', false));
cfg = set_default(cfg, 'stopAppDataKey', cfg_file_value(fileCfg, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE'));
cfg = set_default(cfg, 'hFigAuto', cfg_file_value(fileCfg, 'hFigAuto', []));
cfg = set_default(cfg, 'verbose', cfg_file_value(fileCfg, 'verbose', false));
end

function cfg = set_default(cfg, key, value)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = value;
end
end

function v = cfg_file_value(s, key, fallback)
if isstruct(s) && isfield(s, key) && ~isempty(s.(key))
    v = s.(key);
else
    v = fallback;
end
end

function [ok, errMsg] = validate_inputs(TtargetK, cfg)
ok = false;
errMsg = '';
required = {'tcIp','magIp','T_safe_max','T_tol','holdSec','maxWaitSec','pollSec','pidP','pidI','pidD'};
for i = 1:numel(required)
    if ~isfield(cfg, required{i}) || isempty(cfg.(required{i}))
        errMsg = sprintf('Missing required cfg field: %s', required{i});
        return;
    end
end
if ~(isnumeric(TtargetK) && isscalar(TtargetK) && isfinite(TtargetK))
    errMsg = 'TtargetK must be a finite numeric scalar.';
    return;
end
numFields = {'T_safe_max','T_tol','holdSec','maxWaitSec','pollSec','pidP','pidI','pidD','lookbackMin','commRetryCount','commRetryBackoffSec','magPort','magTimeoutSec','magGatePausedCurrentAbsTol','tcConnectTimeoutSec','tcResponseTimeoutSec','commMaxBlockSecWhenStop','stopWaitGranularitySec'};
for i = 1:numel(numFields)
    v = cfg.(numFields{i});
    if ~(isnumeric(v) && isscalar(v) && isfinite(v))
        errMsg = sprintf('cfg.%s must be a finite numeric scalar.', numFields{i});
        return;
    end
end
if cfg.T_tol <= 0 || cfg.holdSec <= 0 || cfg.maxWaitSec <= 0 || cfg.pollSec <= 0
    errMsg = 'cfg.T_tol, cfg.holdSec, cfg.maxWaitSec, and cfg.pollSec must be > 0.';
    return;
end
if cfg.stopWaitGranularitySec <= 0
    errMsg = 'cfg.stopWaitGranularitySec must be > 0.';
    return;
end
if cfg.commMaxBlockSecWhenStop <= 0
    errMsg = 'cfg.commMaxBlockSecWhenStop must be > 0.';
    return;
end
if cfg.commRetryCount < 1 || mod(cfg.commRetryCount, 1) ~= 0
    errMsg = 'cfg.commRetryCount must be an integer >= 1.';
    return;
end
if cfg.tcConnectTimeoutSec <= 0 || cfg.tcResponseTimeoutSec <= 0
    errMsg = 'cfg.tcConnectTimeoutSec and cfg.tcResponseTimeoutSec must be > 0.';
    return;
end
if ~(isscalar(cfg.stopCheckEnabled) && (islogical(cfg.stopCheckEnabled) || isnumeric(cfg.stopCheckEnabled)))
    errMsg = 'cfg.stopCheckEnabled must be a logical/numeric scalar.';
    return;
end
if ~(isscalar(cfg.magGateRequirePsZero) && (islogical(cfg.magGateRequirePsZero) || isnumeric(cfg.magGateRequirePsZero)))
    errMsg = 'cfg.magGateRequirePsZero must be a logical/numeric scalar.';
    return;
end
if ~(isscalar(cfg.magGateAllowPausedStateWithPsOff) && (islogical(cfg.magGateAllowPausedStateWithPsOff) || isnumeric(cfg.magGateAllowPausedStateWithPsOff)))
    errMsg = 'cfg.magGateAllowPausedStateWithPsOff must be a logical/numeric scalar.';
    return;
end
ok = true;
end

function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
