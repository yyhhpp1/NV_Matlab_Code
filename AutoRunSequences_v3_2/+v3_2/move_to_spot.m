function [ok, msg] = move_to_spot(spot, runtimeCtx)
%MOVE_TO_SPOT Move ImageNVC fixed XY to the requested spot voltages.
ok = false;
msg = '';

if nargin < 2 || ~isstruct(runtimeCtx) || ~isfield(runtimeCtx, 'handlesImage') || isempty(runtimeCtx.handlesImage)
    msg = 'ImageNVC handles are not attached.';
    return;
end
handlesImage = runtimeCtx.handlesImage;
if ~isfield(handlesImage, 'FixVx') || ~isfield(handlesImage, 'FixVy')
    msg = 'ImageNVC FixVx/FixVy controls are missing.';
    return;
end
if ~(isfinite(spot.xV) && isfinite(spot.yV))
    msg = 'Spot voltages must be finite.';
    return;
end

try
    set(handlesImage.FixVx, 'String', num2str(spot.xV, '%.6f'));
    set(handlesImage.FixVy, 'String', num2str(spot.yV, '%.6f'));
    ImageFunctionPool('Fix', ancestor(handlesImage.FixVx, 'figure'), [], handlesImage);
    pause(field_or(runtimeCtx, 'spotSettleSec', 0.05));
    ok = true;
catch ME
    msg = ME.message;
end
end

function out = field_or(s, fieldName, defaultValue)
if isfield(s, fieldName)
    out = s.(fieldName);
else
    out = defaultValue;
end
end
