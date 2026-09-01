function [zBest, iBest, isInterior, conf] = hc_FocusPeak(z, F)
% hc_FocusPeak(z, F)  Best-focus Z from a focus-score curve.
%
%   [zBest, iBest, isInterior, conf] = hc_FocusPeak(z, F)
%     z          : 1 x K scanned Z positions (um), ascending
%     F          : 1 x K focus scores from hc_FocusMetric
%     zBest      : interpolated best-focus Z (um)
%     iBest      : index of the best scanned point (the slice to display)
%     isInterior : true if the peak is a genuine interior maximum
%     conf       : max(F)/median(F) -- how much of a peak there actually is
%
% Two things here matter more than the interpolation.
%
% isInterior. If the argmax lands on the first or last point, the curve is still
% rising at the edge of the range and the true focus is OUTSIDE what was scanned.
% That is the single most common way a Z scan misleads: it reports a "best" Z
% that is really just the closest the sweep got. Callers use this to refuse to
% park the objective and to tell the user which way to extend the range.
%
% conf. A flat curve has an argmax too, and it is noise. Comparing the peak with
% the median of the whole curve gives a cheap scale-free answer to "is there a
% peak at all"; ~1.0 means there is not. A focus scan on a featureless region, or
% one where the mask threw away everything with structure in it, lands here.
%
% Interpolation is a parabola through the three points around the argmax, which
% is the standard sub-step estimator for a smooth single-peaked curve. It is
% clamped to +/- half a step: a parabola fitted to a noisy near-flat top can
% otherwise place the vertex far outside the bracketing points, and a confident
% wrong answer is worse than the grid point we already had.

z = double(z(:))';
F = double(F(:))';

zBest      = NaN;
iBest      = NaN;
isInterior = false;
conf       = NaN;

ok = isfinite(F) & isfinite(z);
if ~any(ok)
    return;
end

% Work on the finite subset, then map the index back, so a run stopped early
% (trailing NaNs in a preallocated curve) behaves the same as a complete one.
idx = find(ok);
Fo  = F(ok);
zo  = z(ok);

[~, iLocal] = max(Fo);
iBest = idx(iLocal);

med = median(Fo);
if isfinite(med) && med ~= 0
    conf = max(Fo) / med;
else
    conf = NaN;
end

nOk = numel(Fo);
if nOk < 3
    % Nothing to interpolate with, and with fewer than three points "interior"
    % is not a meaningful claim.
    zBest      = zo(iLocal);
    isInterior = false;
    return;
end

isInterior = (iLocal > 1) && (iLocal < nOk);
zBest      = zo(iLocal);

if ~isInterior
    return;
end

y1 = Fo(iLocal - 1);
y2 = Fo(iLocal);
y3 = Fo(iLocal + 1);

curv = y1 - 2 * y2 + y3;
if curv >= 0
    % Not concave -- the three points do not describe a maximum (equal values, or
    % a plateau). The grid point stands.
    return;
end

delta = 0.5 * (y1 - y3) / curv;
delta = min(max(delta, -0.5), 0.5);

% Half the span of the bracketing points, so a non-uniform Z grid still works
% (RunSequence's unique() sorts the sweep, but the spacing need not be uniform
% if multiple sweep segments were combined).
halfStep = (zo(iLocal + 1) - zo(iLocal - 1)) / 2;
zBest    = zo(iLocal) + delta * halfStep;
end
