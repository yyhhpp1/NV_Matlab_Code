function [ok, info, message] = mag_z_gate_precheck(magIp, cfg)
%MAG_Z_GATE_PRECHECK Check Z-magnet safety gate.
% Default policy: require STATE==8 only (PS/current are logged but not gated).
%
%   [ok, info, message] = mag_z_gate_precheck(magIp)
%   [ok, info, message] = mag_z_gate_precheck(magIp, cfg)
%
% Optional cfg:
%   .port      (default 7185)
%   .timeoutSec (default 3)
%   .requirePsZero (default false)
%   .allowPausedStateWithPsOff (default false)
%   .pausedCurrentAbsTol (default 1e-3)

ok = false;
message = '';
info = struct('ps', NaN, 'state', NaN, 'current', NaN, 'currentCmd', '', 'currentRaw', '', ...
    'currentKnown', false, 'ok', false, 'checkedAt', '', ...
    'lastErrorCode', NaN, 'lastErrorText', '', 'lastErrorRaw', '', ...
    'commLog', repmat(struct('timestamp', '', 'cmd', '', 'response', '', 'errorCode', NaN, 'errorText', '', 'errorRaw', ''), 0, 1));

if nargin < 2 || isempty(cfg)
    cfg = struct();
end
fileCfg = bt_control_cfg_load('mag_z_gate_precheck');
if ~isfield(cfg, 'port') || isempty(cfg.port), cfg.port = cfg_file_value(fileCfg, 'port', 7185); end
if ~isfield(cfg, 'timeoutSec') || isempty(cfg.timeoutSec), cfg.timeoutSec = cfg_file_value(fileCfg, 'timeoutSec', 3); end
if ~isfield(cfg, 'requirePsZero') || isempty(cfg.requirePsZero), cfg.requirePsZero = cfg_file_value(fileCfg, 'requirePsZero', false); end
if ~isfield(cfg, 'allowPausedStateWithPsOff') || isempty(cfg.allowPausedStateWithPsOff), cfg.allowPausedStateWithPsOff = cfg_file_value(fileCfg, 'allowPausedStateWithPsOff', false); end
if ~isfield(cfg, 'pausedCurrentAbsTol') || isempty(cfg.pausedCurrentAbsTol), cfg.pausedCurrentAbsTol = cfg_file_value(fileCfg, 'pausedCurrentAbsTol', 1e-3); end

if ~(isnumeric(cfg.port) && isscalar(cfg.port) && isfinite(cfg.port) && cfg.port > 0)
    message = 'cfg.port must be a positive numeric scalar.';
    return;
end
if ~(isnumeric(cfg.timeoutSec) && isscalar(cfg.timeoutSec) && isfinite(cfg.timeoutSec) && cfg.timeoutSec > 0)
    message = 'cfg.timeoutSec must be a positive numeric scalar.';
    return;
end
if ~(isnumeric(cfg.pausedCurrentAbsTol) && isscalar(cfg.pausedCurrentAbsTol) && isfinite(cfg.pausedCurrentAbsTol) && cfg.pausedCurrentAbsTol >= 0)
    message = 'cfg.pausedCurrentAbsTol must be a numeric scalar >= 0.';
    return;
end

tcp = [];
cleanupObj = onCleanup(@() local_disconnect(tcp)); %#ok<NASGU>

try
    tcp = tcpclient(magIp, cfg.port);
    tcp.Timeout = cfg.timeoutSec;

    [psRaw, psComm, psOk, psMsg] = query_with_error_check(tcp, "PS?");
    info.commLog(end + 1, 1) = psComm; %#ok<AGROW>
    info.lastErrorCode = psComm.errorCode;
    info.lastErrorText = psComm.errorText;
    info.lastErrorRaw = psComm.errorRaw;
    if ~psOk
        message = sprintf('PS? failed: %s', psMsg);
        info.checkedAt = now_stamp();
        return;
    end

    [stRaw, stComm, stOk, stMsg] = query_with_error_check(tcp, "STATE?");
    info.commLog(end + 1, 1) = stComm; %#ok<AGROW>
    info.lastErrorCode = stComm.errorCode;
    info.lastErrorText = stComm.errorText;
    info.lastErrorRaw = stComm.errorRaw;
    if ~stOk
        message = sprintf('STATE? failed: %s', stMsg);
        info.checkedAt = now_stamp();
        return;
    end

    ps = parse_first_integer(psRaw);
    st = parse_first_integer(stRaw);
    if isnan(ps) || isnan(st)
        message = sprintf('Could not parse PS?/STATE? (PS="%s", STATE="%s").', psRaw, stRaw);
        info.checkedAt = now_stamp();
        return;
    end

    info.ps = ps;
    info.state = st;

    % Use measured PSU current for gate decisions in active control paths.
    curCmd = 'CURRent:SUPPly?';
    [curRaw, curComm, curOkComm, curMsg] = query_with_error_check(tcp, curCmd);
    info.commLog(end + 1, 1) = curComm; %#ok<AGROW>
    info.lastErrorCode = curComm.errorCode;
    info.lastErrorText = curComm.errorText;
    info.lastErrorRaw = curComm.errorRaw;
    if ~curOkComm
        message = sprintf('%s failed: %s', curCmd, curMsg);
        info.checkedAt = now_stamp();
        return;
    end
    curVal = parse_first_number(curRaw);
    curKnown = isfinite(curVal);
    info.currentKnown = curKnown;
    info.current = curVal;
    info.currentCmd = curCmd;
    info.currentRaw = curRaw;

    pausedWithPsOffOk = logical(cfg.allowPausedStateWithPsOff) && ...
        (ps == 0) && (st == 3) && curKnown && (abs(curVal) <= cfg.pausedCurrentAbsTol);

    if logical(cfg.requirePsZero)
        info.ok = ((ps == 0) && (st == 8)) || pausedWithPsOffOk;
    else
        info.ok = (st == 8) || pausedWithPsOffOk;
    end
    info.checkedAt = now_stamp();

    if info.ok
        ok = true;
        if logical(cfg.requirePsZero)
            message = sprintf('Magnet gate OK (PS=%d, STATE=%d; strict PS gate ON%s).', ...
                ps, st, current_tail(info));
        else
            message = sprintf('Magnet gate OK (STATE=%d; PS=%d%s).', ...
                st, ps, current_tail(info));
        end
    else
        if logical(cfg.requirePsZero)
            message = sprintf('Magnet gate failed (PS=%d, STATE=%d). Required PS=0 with STATE=8%s.', ...
                ps, st, paused_suffix(cfg));
        else
            message = sprintf('Magnet gate failed (PS=%d, STATE=%d). Required STATE=8%s.', ...
                ps, st, paused_suffix(cfg));
        end
    end
catch ME
    message = sprintf('mag_z_gate_precheck failed: %s', ME.message);
    info.checkedAt = now_stamp();
end
end

function out = paused_suffix(cfg)
if isfield(cfg, 'allowPausedStateWithPsOff') && logical(cfg.allowPausedStateWithPsOff)
    out = ' or (STATE=3 with PS=0 and |current|<=tol)';
else
    out = '';
end
end

function out = current_tail(info)
if ~isstruct(info) || ~isfield(info, 'currentKnown') || ~logical(info.currentKnown)
    out = ', current=unknown';
    return;
end
cmd = '';
if isfield(info, 'currentCmd')
    cmd = char(string(info.currentCmd));
end
if isempty(cmd)
    out = sprintf(', current=%.6g', info.current);
else
    out = sprintf(', current=%.6g (%s)', info.current, cmd);
end
end

function [resp, comm, ok, msg] = query_with_error_check(tcp, cmd)
resp = '';
ok = false;
msg = '';
comm = struct('timestamp', now_stamp(), 'cmd', char(string(cmd)), ...
    'response', '', 'errorCode', NaN, 'errorText', '', 'errorRaw', '');
try
    resp = lowlevel_query(tcp, cmd);
    comm.response = resp;
catch ME
    msg = sprintf('command failed: %s', ME.message);
    return;
end

try
    errRaw = lowlevel_query(tcp, "SYST:ERR?");
catch ME
    msg = sprintf('SYST:ERR? failed: %s', ME.message);
    return;
end
[errCode, errText] = parse_error_response(errRaw);
comm.errorCode = errCode;
comm.errorText = errText;
comm.errorRaw = errRaw;

if isnan(errCode)
    msg = sprintf('unable to parse SYST:ERR? response "%s"', errRaw);
    return;
end
if errCode ~= 0
    if isempty(errText)
        msg = sprintf('%d', errCode);
    else
        msg = sprintf('%d: %s', errCode, errText);
    end
    return;
end
ok = true;
end

function resp = lowlevel_query(tcp, cmd)
raw = writeread(tcp, string(cmd));
if isstring(raw)
    resp = char(raw);
else
    resp = char(raw(:).');
end
resp = strtrim(resp);
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

function n = parse_first_integer(txt)
token = regexp(char(txt), '[-+]?\d+', 'match', 'once');
if isempty(token)
    n = NaN;
else
    n = str2double(token);
end
end

function n = parse_first_number(txt)
token = regexp(char(txt), '[-+]?\d*\.?\d+([eE][-+]?\d+)?', 'match', 'once');
if isempty(token)
    n = NaN;
else
    n = str2double(token);
end
end

function v = cfg_file_value(s, key, fallback)
if isstruct(s) && isfield(s, key) && ~isempty(s.(key))
    v = s.(key);
else
    v = fallback;
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

function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
