function [ok, message, out] = bf_tc_set_heater4_verified(deviceIP, active, cfgSet, cfgVerify)
%BF_TC_SET_HEATER4_VERIFIED Set heater 4 and verify PID via /heater query.
%   [ok, message, out] = bf_tc_set_heater4_verified(deviceIP, active, cfgSet, cfgVerify)
%
% Behavior (active=true):
%   1) Send /heater/update with requested PID.
%   2) Query /heater for readback.
%   3) Validate:
%       - abs(read-set) <= verifyTol for P/I/D
%       - read P/I/D >= pidMin
%   4) If attempt 1 fails for any reason and verifyRetryWithMinClamp=true:
%       - retry once with PID terms clamped to pidMin
%       - re-query and re-validate
%
% Behavior (active=false):
%   - sends /heater/update OFF command (no PID verification).
%
% cfgSet for active=true:
%   .setpointK, .pidP, .pidI, .pidD
% Optional pass-through for bf_tc_set_heater4:
%   .pidMode, .controlAlgorithm
%
% cfgVerify optional fields:
%   .heaterNr (default 4)
%   .verifyTol (default 1e-12)
%   .pidMin (default 0)
%   .verifyRetryWithMinClamp (default true)
%   .commRetryCount (default 3)
%   .commRetryBackoffSec (default 0.5)
%   .verbose (default false)

ok = false;
message = '';
out = struct();

if nargin < 3 || isempty(cfgSet)
    cfgSet = struct();
end
if nargin < 4 || isempty(cfgVerify)
    cfgVerify = struct();
end
cfgVerify = apply_defaults(cfgVerify);

out.activeRequested = logical(active);
out.verifyPassed = false;
out.usedClampRetry = false;
out.pidRequested = struct('P', NaN, 'I', NaN, 'D', NaN);
out.pidReadback1 = struct('P', NaN, 'I', NaN, 'D', NaN);
out.pidRetryRequested = struct('P', NaN, 'I', NaN, 'D', NaN);
out.pidReadback2 = struct('P', NaN, 'I', NaN, 'D', NaN);
out.verifyMessage = '';
out.setMessage1 = '';
out.setMessage2 = '';
out.queryMessage1 = '';
out.queryMessage2 = '';
out.heaterRead1 = struct();
out.heaterRead2 = struct();

if ~(islogical(active) || isnumeric(active))
    message = 'active must be logical/numeric scalar.';
    out.verifyMessage = message;
    return;
end
active = logical(active);
if cfgVerify.verbose
    fprintf('[bf_tc_set_heater4_verified] Start active=%d heater=%d verifyTol=%.6g pidMin=%.6g\n', ...
        double(active), cfgVerify.heaterNr, cfgVerify.verifyTol, cfgVerify.pidMin);
end

if ~active
    if cfgVerify.verbose
        fprintf('[bf_tc_set_heater4_verified] Sending heater OFF update.\n');
    end
    [okSetOff, msgSetOff] = send_with_retry(false, cfgSet);
    out.setMessage1 = msgSetOff;
    if ~okSetOff
        message = sprintf('Heater OFF update failed: %s', msgSetOff);
        out.verifyMessage = message;
        return;
    end
    ok = true;
    message = 'OK';
    out.verifyPassed = true;
    out.verifyMessage = 'OFF command sent (PID verify skipped for active=false).';
    return;
end

[validSet, errSet] = validate_active_cfgset(cfgSet);
if ~validSet
    message = errSet;
    out.verifyMessage = message;
    return;
end

out.pidRequested = struct('P', cfgSet.pidP, 'I', cfgSet.pidI, 'D', cfgSet.pidD);

% First set/query/verify.
firstFailure = '';
if cfgVerify.verbose
    fprintf('[bf_tc_set_heater4_verified] Attempt 1 set PID: P=%.12g I=%.12g D=%.12g setpoint=%.12g K\n', ...
        cfgSet.pidP, cfgSet.pidI, cfgSet.pidD, cfgSet.setpointK);
end
[okSet1, msgSet1] = send_with_retry(true, cfgSet);
out.setMessage1 = msgSet1;
if ~okSet1
    firstFailure = sprintf('Heater update failed (attempt 1): %s', msgSet1);
else
    [okRead1, heater1, msgRead1] = read_with_retry();
    out.queryMessage1 = msgRead1;
    out.heaterRead1 = heater1;
    if ~okRead1
        firstFailure = sprintf('Heater readback failed (attempt 1): %s', msgRead1);
    else
        [okPid1, pid1, msgPid1] = extract_pid_from_heater(heater1);
        if okPid1
            out.pidReadback1 = pid1;
            [okCmp1, msgCmp1] = compare_pid(out.pidRequested, out.pidReadback1, cfgVerify.verifyTol, cfgVerify.pidMin);
            if okCmp1
                ok = true;
                message = 'OK';
                out.verifyPassed = true;
                out.verifyMessage = 'Set/verify passed on first attempt.';
                if cfgVerify.verbose
                    fprintf('[bf_tc_set_heater4_verified] Attempt 1 verify passed.\n');
                end
                return;
            end
            firstFailure = sprintf('PID verify failed on first attempt: %s', msgCmp1);
        else
            firstFailure = sprintf('Unable to parse PID from heater readback (attempt 1): %s', msgPid1);
        end
    end
end

if ~cfgVerify.verifyRetryWithMinClamp
    message = firstFailure;
    out.verifyMessage = message;
    if cfgVerify.verbose
        fprintf('[bf_tc_set_heater4_verified] Attempt 1 failed with no retry: %s\n', message);
    end
    return;
end

% Retry with min clamp.
retryCfgSet = cfgSet;
retryCfgSet.pidP = max(cfgSet.pidP, cfgVerify.pidMin);
retryCfgSet.pidI = max(cfgSet.pidI, cfgVerify.pidMin);
retryCfgSet.pidD = max(cfgSet.pidD, cfgVerify.pidMin);
out.pidRetryRequested = struct('P', retryCfgSet.pidP, 'I', retryCfgSet.pidI, 'D', retryCfgSet.pidD);
out.usedClampRetry = true;
if cfgVerify.verbose
    fprintf('[bf_tc_set_heater4_verified] Clamp retry set PID: P=%.12g I=%.12g D=%.12g (reason: %s)\n', ...
        retryCfgSet.pidP, retryCfgSet.pidI, retryCfgSet.pidD, firstFailure);
end

[okSet2, msgSet2] = send_with_retry(true, retryCfgSet);
out.setMessage2 = msgSet2;
if ~okSet2
    message = sprintf('Heater update failed (clamp retry): %s', msgSet2);
    out.verifyMessage = message;
    return;
end

[okRead2, heater2, msgRead2] = read_with_retry();
out.queryMessage2 = msgRead2;
out.heaterRead2 = heater2;
if ~okRead2
    message = sprintf('Heater readback failed (clamp retry): %s', msgRead2);
    out.verifyMessage = message;
    return;
end

[okPid2, pid2, msgPid2] = extract_pid_from_heater(heater2);
if okPid2
    out.pidReadback2 = pid2;
end
if ~okPid2
    message = sprintf('Unable to parse PID from heater readback (clamp retry): %s', msgPid2);
    out.verifyMessage = message;
    return;
end

[okCmp2, msgCmp2] = compare_pid(out.pidRetryRequested, out.pidReadback2, cfgVerify.verifyTol, cfgVerify.pidMin);
if ~okCmp2
    message = sprintf('PID verify failed after clamp retry: %s', msgCmp2);
    out.verifyMessage = message;
    return;
end

ok = true;
message = 'OK';
out.verifyPassed = true;
out.verifyMessage = sprintf('Set/verify passed after clamp retry. First-try reason: %s', firstFailure);
if cfgVerify.verbose
    fprintf('[bf_tc_set_heater4_verified] Clamp retry verify passed.\n');
end

    function [okLocal, msgLocal] = send_with_retry(activeLocal, cfgSetLocal)
        okLocal = false;
        msgLocal = 'unknown';
        for k = 1:cfgVerify.commRetryCount
            if cfgVerify.verbose
                fprintf('[bf_tc_set_heater4_verified] /heater/update attempt %d/%d (active=%d)\n', ...
                    k, cfgVerify.commRetryCount, double(logical(activeLocal)));
            end
            [ok1, msg1] = bf_tc_set_heater4(deviceIP, activeLocal, cfgSetLocal);
            if ok1
                okLocal = true;
                msgLocal = 'OK';
                if cfgVerify.verbose
                    fprintf('[bf_tc_set_heater4_verified] /heater/update OK.\n');
                end
                return;
            end
            msgLocal = msg1;
            if cfgVerify.verbose
                fprintf('[bf_tc_set_heater4_verified] /heater/update failed: %s\n', msg1);
            end
            if k < cfgVerify.commRetryCount
                pause(max(0, cfgVerify.commRetryBackoffSec));
            end
        end
    end

    function [okLocal, heaterLocal, msgLocal] = read_with_retry()
        okLocal = false;
        heaterLocal = struct();
        msgLocal = 'unknown';
        for k = 1:cfgVerify.commRetryCount
            if cfgVerify.verbose
                fprintf('[bf_tc_set_heater4_verified] /heater read attempt %d/%d\n', ...
                    k, cfgVerify.commRetryCount);
            end
            [ok1, h1, msg1] = bf_tc_read_heater(deviceIP, cfgVerify.heaterNr);
            if ok1
                okLocal = true;
                heaterLocal = h1;
                msgLocal = 'OK';
                if cfgVerify.verbose
                    fprintf('[bf_tc_set_heater4_verified] /heater read OK.\n');
                end
                return;
            end
            msgLocal = msg1;
            if cfgVerify.verbose
                fprintf('[bf_tc_set_heater4_verified] /heater read failed: %s\n', msg1);
            end
            if k < cfgVerify.commRetryCount
                pause(max(0, cfgVerify.commRetryBackoffSec));
            end
        end
    end
end

function cfg = apply_defaults(cfg)
cfg = set_default(cfg, 'heaterNr', 4);
cfg = set_default(cfg, 'verifyTol', 1e-12);
cfg = set_default(cfg, 'pidMin', 0);
cfg = set_default(cfg, 'verifyRetryWithMinClamp', true);
cfg = set_default(cfg, 'commRetryCount', 3);
cfg = set_default(cfg, 'commRetryBackoffSec', 0.5);
cfg = set_default(cfg, 'verbose', false);
end

function cfg = set_default(cfg, key, value)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = value;
end
end

function [ok, errMsg] = validate_active_cfgset(cfgSet)
ok = false;
errMsg = '';
required = {'setpointK','pidP','pidI','pidD'};
for i = 1:numel(required)
    key = required{i};
    if ~isfield(cfgSet, key) || isempty(cfgSet.(key)) || ...
            ~(isnumeric(cfgSet.(key)) && isscalar(cfgSet.(key)) && isfinite(cfgSet.(key)))
        errMsg = sprintf('Missing/invalid cfgSet.%s for active=true.', key);
        return;
    end
end
ok = true;
end

function [ok, pid, errMsg] = extract_pid_from_heater(heater)
ok = false;
pid = struct('P', NaN, 'I', NaN, 'D', NaN);
errMsg = 'Missing control_algorithm_settings.';

if ~isstruct(heater)
    errMsg = 'Heater readback is not a struct.';
    return;
end
if ~isfield(heater, 'control_algorithm_settings') || ~isstruct(heater.control_algorithm_settings)
    errMsg = 'control_algorithm_settings field not found.';
    return;
end

s = heater.control_algorithm_settings;
[okP, pVal] = get_numeric_field(s, {'proportional','p'});
[okI, iVal] = get_numeric_field(s, {'integral','i'});
[okD, dVal] = get_numeric_field(s, {'derivative','d'});

if ~(okP && okI && okD)
    errMsg = 'PID fields proportional/integral/derivative not found or invalid.';
    return;
end

pid.P = pVal;
pid.I = iVal;
pid.D = dVal;
ok = true;
errMsg = '';
end

function [ok, val] = get_numeric_field(s, keys)
ok = false;
val = NaN;
for i = 1:numel(keys)
    key = keys{i};
    if isfield(s, key)
        v = s.(key);
        if isnumeric(v) && isscalar(v) && isfinite(v)
            ok = true;
            val = double(v);
            return;
        end
    end
end
end

function [ok, msg] = compare_pid(setPid, readPid, tol, pidMin)
ok = false;
msg = '';

if readPid.P < pidMin || readPid.I < pidMin || readPid.D < pidMin
    msg = sprintf('Readback PID below min %.6g (P=%.6g I=%.6g D=%.6g).', ...
        pidMin, readPid.P, readPid.I, readPid.D);
    return;
end

dP = abs(readPid.P - setPid.P);
dI = abs(readPid.I - setPid.I);
dD = abs(readPid.D - setPid.D);
if dP > tol || dI > tol || dD > tol
    msg = sprintf('Readback mismatch > tol %.6g (dP=%.6g dI=%.6g dD=%.6g).', ...
        tol, dP, dI, dD);
    return;
end

ok = true;
msg = '';
end
