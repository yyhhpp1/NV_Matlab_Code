function [ok, info, message] = mag_z_gate_precheck(magIp, cfg)
%MAG_Z_GATE_PRECHECK Check Z-magnet safety gate: PS==0 and STATE==8.
%
%   [ok, info, message] = mag_z_gate_precheck(magIp)
%   [ok, info, message] = mag_z_gate_precheck(magIp, cfg)
%
% Optional cfg:
%   .port      (default 7185)
%   .timeoutSec (default 3)

ok = false;
message = '';
info = struct('ps', NaN, 'state', NaN, 'ok', false, 'checkedAt', '');

if nargin < 2 || isempty(cfg)
    cfg = struct();
end
if ~isfield(cfg, 'port') || isempty(cfg.port), cfg.port = 7185; end
if ~isfield(cfg, 'timeoutSec') || isempty(cfg.timeoutSec), cfg.timeoutSec = 3; end

if ~(isnumeric(cfg.port) && isscalar(cfg.port) && isfinite(cfg.port) && cfg.port > 0)
    message = 'cfg.port must be a positive numeric scalar.';
    return;
end
if ~(isnumeric(cfg.timeoutSec) && isscalar(cfg.timeoutSec) && isfinite(cfg.timeoutSec) && cfg.timeoutSec > 0)
    message = 'cfg.timeoutSec must be a positive numeric scalar.';
    return;
end

tcp = [];
cleanupObj = onCleanup(@() local_disconnect(tcp)); %#ok<NASGU>

try
    tcp = tcpclient(magIp, cfg.port);
    tcp.Timeout = cfg.timeoutSec;

    psRaw = strtrim(char(writeread(tcp, "PS?")));
    stRaw = strtrim(char(writeread(tcp, "STATE?")));

    ps = parse_first_integer(psRaw);
    st = parse_first_integer(stRaw);
    if isnan(ps) || isnan(st)
        message = sprintf('Could not parse PS?/STATE? (PS="%s", STATE="%s").', psRaw, stRaw);
        info.checkedAt = now_stamp();
        return;
    end

    info.ps = ps;
    info.state = st;
    info.ok = (ps == 0 && st == 8);
    info.checkedAt = now_stamp();

    if info.ok
        ok = true;
        message = 'Magnet gate OK (PS=0, STATE=8).';
    else
        message = sprintf('Magnet gate failed (PS=%d, STATE=%d). Required PS=0 and STATE=8.', ps, st);
    end
catch ME
    message = sprintf('mag_z_gate_precheck failed: %s', ME.message);
    info.checkedAt = now_stamp();
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

