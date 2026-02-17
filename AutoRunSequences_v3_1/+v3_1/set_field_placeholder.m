function [ok, message] = set_field_placeholder(Btarget, cfg)
%SET_FIELD_PLACEHOLDER Placeholder setpoint API for magnetic field.

if nargin < 2
    cfg = struct();
end

ok = true;
message = sprintf('Placeholder B set to %.6g', Btarget);

if isfield(cfg, 'forceSetFieldFail') && cfg.forceSetFieldFail
    ok = false;
    message = 'Forced placeholder failure: set_field.';
    return;
end

if isfield(cfg, 'setDelaySec') && isnumeric(cfg.setDelaySec) && cfg.setDelaySec > 0
    pause(cfg.setDelaySec);
end
end
