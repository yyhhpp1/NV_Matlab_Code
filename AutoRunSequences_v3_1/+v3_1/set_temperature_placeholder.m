function [ok, message] = set_temperature_placeholder(Ttarget, cfg)
%SET_TEMPERATURE_PLACEHOLDER Placeholder setpoint API for temperature.

if nargin < 2
    cfg = struct();
end

ok = true;
message = sprintf('Placeholder T set to %.6g', Ttarget);

if isfield(cfg, 'forceSetTempFail') && cfg.forceSetTempFail
    ok = false;
    message = 'Forced placeholder failure: set_temperature.';
    return;
end

if isfield(cfg, 'setDelaySec') && isnumeric(cfg.setDelaySec) && cfg.setDelaySec > 0
    pause(cfg.setDelaySec);
end
end
