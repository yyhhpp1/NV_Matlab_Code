function [ok, actualB, message] = wait_field_stable_placeholder(Btarget, cfg)
%WAIT_FIELD_STABLE_PLACEHOLDER Placeholder stabilization API for magnetic field.

if nargin < 2
    cfg = struct();
end

settleSec = 0.2;
if isfield(cfg, 'settleSec') && isnumeric(cfg.settleSec)
    settleSec = max(0, cfg.settleSec);
end
pause(settleSec);

ok = true;
actualB = Btarget;
message = sprintf('Placeholder B settled at %.6g', actualB);

if isfield(cfg, 'forceWaitFieldFail') && cfg.forceWaitFieldFail
    ok = false;
    message = 'Forced placeholder failure: wait_field_stable.';
    return;
end
if isfield(cfg, 'fieldOffset') && isnumeric(cfg.fieldOffset)
    actualB = Btarget + cfg.fieldOffset;
end
end
