function [spot, ok, msg] = read_current_image_spot(runtimeCtx)
%READ_CURRENT_IMAGE_SPOT Read the currently displayed ImageNVC fixed XY.
spot = v3_2.new_spot('name', 'CurrentImageSpot', 'xV', NaN, 'yV', NaN);
ok = false;
msg = '';

if nargin < 1 || ~isstruct(runtimeCtx) || ~isfield(runtimeCtx, 'handlesImage') || isempty(runtimeCtx.handlesImage)
    msg = 'ImageNVC handles are not attached.';
    return;
end
handlesImage = runtimeCtx.handlesImage;
if ~isfield(handlesImage, 'FixVx') || ~isfield(handlesImage, 'FixVy')
    msg = 'ImageNVC FixVx/FixVy controls are missing.';
    return;
end

try
    spot.xV = str2double(string(get(handlesImage.FixVx, 'String')));
    spot.yV = str2double(string(get(handlesImage.FixVy, 'String')));
    if ~(isfinite(spot.xV) && isfinite(spot.yV))
        msg = 'Current ImageNVC spot voltages are invalid.';
        return;
    end
    ok = true;
catch ME
    msg = ME.message;
end
end
