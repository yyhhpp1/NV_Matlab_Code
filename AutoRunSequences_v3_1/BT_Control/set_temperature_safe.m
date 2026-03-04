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

[stopNow, stopWhy] = is_stop_requested_local(cfg);
if stopNow
    message = sprintf('Stop requested before temperature change: %s', stopWhy);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return;
end

[gateOk, gateInfo, gateMsg] = mag_z_gate_precheck(cfg.magIp, struct( ...
    'port', cfg.magPort, ...
    'timeoutSec', cfg.magTimeoutSec));
info.magGateStart = gateInfo;
if ~gateOk
    message = sprintf('Magnet pre-check gate failed: %s', gateMsg);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return; % keep heater unchanged by policy
end

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
    [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
    info.heaterOffIssued = true;
    message = sprintf('Pre-check CH:3 above T_safe_max (%.6g K > %.6g K). Heater OFF. %s', ...
        T3pre, cfg.T_safe_max, offMsg);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return;
end

[okOn, onMsg] = heater_on_with_retry(cfg.tcIp, TtargetK, cfg);
if ~okOn
    [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
    info.heaterOffIssued = true;
    message = sprintf('Failed to enable heater control: %s. %s', onMsg, offMsg);
    info.abortReason = message;
    info.endedAt = now_stamp();
    return;
end
info.heaterOnIssued = true;

tStart = tic;
tInTol = NaN;
while toc(tStart) <= cfg.maxWaitSec
    [stopNow, stopWhy] = is_stop_requested_local(cfg);
    if stopNow
        [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
        info.heaterOffIssued = true;
        message = sprintf('Stop requested during temperature stabilization. Heater OFF. %s (%s)', offMsg, stopWhy);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end

    [okT8, T8, t8, msgT8] = read_channel_with_retry(cfg.tcIp, 8, cfg, 'readCh8Failures');
    if ~okT8
        [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
        info.heaterOffIssued = true;
        message = sprintf('Runtime CH:8 read failed after retries: %s. %s', msgT8, offMsg);
        info.abortReason = message;
        info.endedAt = now_stamp();
        return;
    end

    [okT3, T3, t3, msgT3] = read_channel_with_retry(cfg.tcIp, 3, cfg, 'readCh3Failures');
    if ~okT3
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
        [~, offMsg] = heater_off_with_retry(cfg.tcIp, cfg);
        info.heaterOffIssued = true;
        message = sprintf('Stop requested during temperature wait. Heater OFF. %s (%s)', offMsg, stopWhySleep);
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
            readCfg = struct( ...
                'connectTimeoutSec', cfgLocal.tcConnectTimeoutSec, ...
                'responseTimeoutSec', cfgLocal.tcResponseTimeoutSec);
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
        hcfg = struct('setpointK', targetK, 'pidP', cfgLocal.pidP, 'pidI', cfgLocal.pidI, 'pidD', cfgLocal.pidD);
        for k = 1:cfgLocal.commRetryCount
            [stopNowLocal, stopWhyLocal] = is_stop_requested_local(cfgLocal);
            if stopNowLocal
                msgOn = sprintf('Stop requested: %s', stopWhyLocal);
                return;
            end
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
        for k = 1:cfgLocal.commRetryCount
            [okH, msgH] = bf_tc_set_heater4(tcIp, false, struct());
            if okH
                okOffLocal = true;
                msgOff = 'Heater OFF command accepted.';
                return;
            end
            info.retryStats.heaterOffFailures = info.retryStats.heaterOffFailures + 1;
            msgOff = msgH;
            if k < cfgLocal.commRetryCount
                pause(max(0, cfgLocal.commRetryBackoffSec));
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
            [stopNowLocal, stopWhyLocal] = is_stop_requested_local(cfgLocal);
            if stopNowLocal
                return;
            end
            remSec = sec - toc(t0);
            pause(min(0.1, max(0.01, remSec)));
        end
    end
end

function cfg = apply_defaults(cfg)
cfg = set_default(cfg, 'lookbackMin', 5);
cfg = set_default(cfg, 'commRetryCount', 3);
cfg = set_default(cfg, 'commRetryBackoffSec', 0.5);
cfg = set_default(cfg, 'magPort', 7185);
cfg = set_default(cfg, 'magTimeoutSec', 3);
cfg = set_default(cfg, 'tcConnectTimeoutSec', 20);
cfg = set_default(cfg, 'tcResponseTimeoutSec', 30);
cfg = set_default(cfg, 'stopCheckEnabled', false);
cfg = set_default(cfg, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE');
cfg = set_default(cfg, 'hFigAuto', []);
cfg = set_default(cfg, 'verbose', false);
end

function cfg = set_default(cfg, key, value)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = value;
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
numFields = {'T_safe_max','T_tol','holdSec','maxWaitSec','pollSec','pidP','pidI','pidD','lookbackMin','commRetryCount','commRetryBackoffSec','magPort','magTimeoutSec','tcConnectTimeoutSec','tcResponseTimeoutSec'};
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
ok = true;
end

function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
