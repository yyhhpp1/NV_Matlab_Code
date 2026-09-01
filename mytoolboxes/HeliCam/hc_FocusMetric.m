function [F, info] = hc_FocusMetric(stack, valid, cfg)
% hc_FocusMetric(stack, valid, cfg)  Sharpness score per Z for an hc_ZScan stack.
%
%   [F, info] = hc_FocusMetric(stack, valid, cfg)
%     stack : H x W x K intensity images (dark-subtracted mean I)
%     valid : H x W logical from hc_FocusMask, or [] to use the whole frame
%             interior (only sensible when there is no shadow in the field)
%     cfg   : WidefieldConfig struct, a resolved hc_FocusConfig struct, or []
%     F     : 1 x K primary score, the one plotted live. Larger = sharper.
%     info  : .metrics struct with all four scores, plus what was used
%
% PRIMARY METRIC: normalised Tenengrad
%
%   F(k) = mean_valid( gx^2 + gy^2 ) / mean_valid( |A| )^2
%
% with gx, gy from a 3x3 Sobel applied to a mildly smoothed frame.
%
% Three deliberate choices in that one line:
%
%   * Gradient energy, not intensity variance. Defocus is a low-pass filter, so
%     it destroys high spatial frequencies specifically; a derivative metric
%     responds to exactly what is lost and therefore gives the sharpest, most
%     selective peak. (Normalised variance is computed too, and is the metric to
%     switch to if the residual row/column pattern noise ever proves worse than
%     the extra selectivity is worth -- it is derivative-free.)
%
%   * Pre-smoothed. A lock-in camera is noisy and squaring a derivative
%     amplifies that noise; without the smooth, the noise floor can rival the
%     focus contrast on a dim sample. The 3x3 binomial kernel costs almost no
%     real resolution because the features that matter here span several pixels.
%
%   * Divided by mean(|A|)^2. This makes the score dimensionless and immune to
%     laser-power drift and to the overall brightness change across the sweep.
%     Without it the curve tracks how much light arrived rather than how sharp
%     the image was, and it can peak where the illumination happened to be best.
%     mean(|A|) rather than mean(A) because readIQ negates I, so the signed mean
%     can sit near zero and blow the ratio up.
%
% Gradients are taken on the SIGNED image (gx^2 is sign-invariant, and abs()
% would manufacture a spurious edge wherever the frame crosses zero). Only the
% masking in hc_FocusMask uses abs().
%
% CAVEAT worth knowing: 'Obj_Piezo' currently drives an EO-Drive tunable lens,
% not a translation stage, so changing Z also changes magnification slightly.
% That puts a smooth monotonic trend underneath the focus peak -- the mean(|A|)^2
% normalisation handles brightness but not magnification. Over a modest Z span
% the peak is still well defined; over a very wide one, prefer the peak position
% from a narrow rescan around it.
%
% All four metrics are evaluated on the SAME masked pixel set and the SAME
% smoothed frame, so hc_FocusCompare's curves are directly comparable.

fcfg = hc_FocusConfig(cfg);

if ndims(stack) == 2
    stack = reshape(stack, size(stack, 1), size(stack, 2), 1);
end
[H, W, K] = size(stack);

if nargin < 2 || isempty(valid)
    % No mask supplied: the frame interior, eroded to keep the filter footprints
    % inside the array. Note this does NOT reject the stripline shadow.
    n = 2 * fcfg.erodePx + 1;
    valid = conv2(ones(H, W), ones(n, n), 'same') >= (n * n - 0.5);
end
valid = logical(valid);

info          = struct();
info.params   = fcfg;
info.nValid   = sum(valid(:));
info.metric   = lower(char(string(fcfg.metric)));
info.metrics  = struct();

names = {'tenengrad', 'normvar', 'brenner', 'laplacian'};
for i = 1:numel(names)
    info.metrics.(names{i}) = NaN(1, K);
end
F = NaN(1, K);

if info.nValid == 0
    fprintf(2, '[Focus] WARNING: empty focus mask, no score can be computed.\n');
    return;
end

% --- Kernels ----------------------------------------------------------------
kSmooth = [1 2 1]' * [1 2 1] / 16;                  % 3x3 binomial
kSobelX = [-1 0 1; -2 0 2; -1 0 1] / 8;
kSobelY = kSobelX';
kBrenX  = [1 0 -1];                                 % 2-pixel step, horizontal
kBrenY  = kBrenX';
kLap    = [0 1 0; 1 -4 1; 0 1 0];

for k = 1:K
    A = stack(:,:,k);

    % NaNs inside the filter footprint would spread over the whole neighbourhood
    % via conv2. Masked-out pixels never contribute to a mean, but they do sit
    % inside the footprint of nearby valid ones -- except that the erosion in
    % hc_FocusMask guarantees a valid pixel's whole 5x5 neighbourhood is valid,
    % so zeroing the rest is safe and keeps conv2 from poisoning the result.
    A(~isfinite(A)) = 0;

    if fcfg.smooth
        As = conv2(A, kSmooth, 'same');
    else
        As = A;
    end

    % Common normaliser: the mean light level over the pixels being scored.
    den = mean(abs(As(valid)))^2;
    den = max(den, eps);

    gx = conv2(As, kSobelX, 'same');
    gy = conv2(As, kSobelY, 'same');
    info.metrics.tenengrad(k) = mean(gx(valid).^2 + gy(valid).^2) / den;

    v = As(valid);
    info.metrics.normvar(k) = var(v) / den;

    bx = conv2(As, kBrenX, 'same');
    by = conv2(As, kBrenY, 'same');
    info.metrics.brenner(k) = mean(bx(valid).^2 + by(valid).^2) / den;

    L = conv2(As, kLap, 'same');
    info.metrics.laplacian(k) = mean(L(valid).^2) / den;
end

if isfield(info.metrics, info.metric)
    F = info.metrics.(info.metric);
else
    fprintf(2, ['[Focus] WARNING: unknown focusMetric ''%s''; using tenengrad. ', ...
                'Valid names: %s.\n'], info.metric, strjoin(names, ', '));
    info.metric = 'tenengrad';
    F = info.metrics.tenengrad;
end
end
