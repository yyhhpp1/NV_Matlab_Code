function [ok, actualT, message] = wait_temperature_stable_placeholder(Ttarget, cfg)
%WAIT_TEMPERATURE_STABLE_PLACEHOLDER Placeholder stabilization API for temperature.

if nargin < 2
    cfg = struct();
end

settleSec = 0.2;
if isfield(cfg, 'settleSec') && isnumeric(cfg.settleSec)
    settleSec = max(0, cfg.settleSec);
end
pause(settleSec);

ok = true;
actualT = Ttarget;
message = sprintf('Placeholder T settled at %.6g', actualT);

if isfield(cfg, 'forceWaitTempFail') && cfg.forceWaitTempFail
    ok = false;
    message = 'Forced placeholder failure: wait_temperature_stable.';
    return;
end
if isfield(cfg, 'tempOffset') && isnumeric(cfg.tempOffset)
    actualT = Ttarget + cfg.tempOffset;
end
end
