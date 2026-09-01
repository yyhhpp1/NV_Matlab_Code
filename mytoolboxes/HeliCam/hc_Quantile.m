function q = hc_Quantile(x, p)
% hc_Quantile(x, p)  Quantile of the finite elements of x, p in [0, 1].
%
% Stand-in for prctile(x, 100*p). The Statistics and Machine Learning Toolbox is
% not used anywhere else in this repo, so the focus code cannot depend on it --
% and a focus scan failing with "Unrecognized function 'prctile'" on a machine
% without that licence would be a silly way to lose beam time.
%
% Uses the same convention prctile does: sample i of n sits at plotting position
% (i - 0.5)/n, with linear interpolation between neighbours and clamping to the
% extremes outside that range. So hc_Quantile(x, 0.5) matches median(x) and
% hc_Quantile(x, 0.95) matches prctile(x, 95) to within floating point.
%
% NaN/Inf are dropped rather than propagated: a single bad pixel must not turn
% the whole brightness scale into NaN and silently void the mask.

v = x(:);
v = v(isfinite(v));
if isempty(v)
    q = NaN;
    return;
end

v = sort(v);
n = numel(v);
if n == 1
    q = v(1);
    return;
end

% Position on the (i - 0.5)/n grid, clamped so p outside [0.5/n, 1-0.5/n]
% returns the min/max rather than extrapolating past the data.
pos = p * n + 0.5;
pos = min(max(pos, 1), n);

lo = floor(pos);
hi = ceil(pos);
w  = pos - lo;
q  = (1 - w) * v(lo) + w * v(hi);
end
