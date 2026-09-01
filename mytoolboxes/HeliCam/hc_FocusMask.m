function [valid, info] = hc_FocusMask(stack, cfg)
% hc_FocusMask(stack, cfg)  Pixels that may contribute to an hc_ZScan focus score.
%
%   [valid, info] = hc_FocusMask(stack, cfg)
%     stack : H x W x K intensity images (dark-subtracted mean I, i.e.
%             gWide.I(:,:,1:K)). K may be a partial stack -- the live
%             display calls this with however many Z points have been acquired.
%     cfg   : WidefieldConfig struct, a resolved hc_FocusConfig struct, or []
%     valid : H x W logical, true where a pixel may contribute
%     info  : what the thresholds did, for the display title and the .h5
%
% WHY THIS EXISTS
%
% A stripline sits ~50 um above the diamond and casts a dark shadow across the
% field. Two separate problems come from that, and the second is the one that
% actually breaks autofocus:
%
%   1. Shadowed pixels see almost no fluorescence, so they contribute noise
%      rather than sharpness and they drag the mean-intensity normalisation
%      around as the shadow blurs.
%   2. The shadow's EDGE is the sharpest feature in the whole frame -- and it
%      belongs to a plane 50 um above the NV layer. Any gradient metric that can
%      see that edge peaks when the STRIPLINE is in focus, which parks the
%      objective ~50 um away from where the NVs are. Excluding the dark pixels
%      alone does not fix this: the edge lives at the boundary of the dark
%      region, so the boundary has to be cut away too. That is what the erosion
%      in step 5 is for, and it is the single most important line in this file.
%
% METHOD
%
%   1. Brightness is abs(stack), not stack. readIQ returns I negated
%      (HeliCamInterface.m, "polarity inversion"), so which sign means "bright"
%      is not obvious from the code. After dark subtraction a pixel receiving no
%      light sits at ~0, so |I| is the light level whichever way the sign went.
%      The Python viewer (analysis/wf_viewer.py) already uses abs(I) and a
%      percentile of abs(I) for exactly this reason.
%   2. Normalise each frame by its own high percentile before thresholding, so
%      the threshold is scale-free as the frame dims and spreads with defocus.
%      An absolute threshold would reject progressively more of the frame at the
%      ends of the sweep and bias the score toward the middle Z.
%   3. Exclude a pixel that is dark at ANY Z (min across the stack), not one that
%      is dark on average. The penumbra MOVES as the shadow blurs, so the union
%      of the shadows is what has to go; an intersection would leave the edge
%      sweeping through the "valid" set.
%   4. Exclude hot pixels, which would otherwise plant a Z-independent spike in
%      a gradient metric and flatten the real peak by comparison.
%   5. Erode, so the filter footprints in hc_FocusMetric never reach across the
%      boundary into the shadow.
%
% REQUIRES DARK-SUBTRACTED INPUT. On the raw scale the ~517 per-pixel pedestal
% dwarfs the light, |I| is nearly uniform, and step 2 normalises to the pedestal
% instead of to the signal -- the mask then means nothing. Selecting hc_ZScan
% ticks the takeDarkRef checkbox for you; this function additionally sniffs for
% the pedestal signature and warns (info.looksUndarked).

fcfg = hc_FocusConfig(cfg);

if ndims(stack) == 2
    stack = reshape(stack, size(stack, 1), size(stack, 2), 1);
end
[H, W, K] = size(stack);

info                = struct();
info.params         = fcfg;
info.nFrames        = K;
info.fallback       = false;
info.looksUndarked  = false;
info.framesUsed     = 0;
info.frameScales    = NaN(1, K);

% --- Steps 1-2: per-frame normalised brightness, accumulated as a running min
% and max so a 40-point stack never needs a second copy in memory ------------
minB = inf(H, W);
maxB = zeros(H, W);
finiteAll = true(H, W);

for k = 1:K
    A  = stack(:,:,k);
    b  = abs(A);
    sk = hc_Quantile(b, fcfg.brightPct / 100);
    info.frameScales(k) = sk;

    % A frame with no positive scale carries no light at all (all-NaN, or an
    % all-zero slice from a run that aborted before this point). Skip it
    % ENTIRELY -- including its finiteness -- because it says nothing about any
    % pixel. Folding it in would drive the running min to zero everywhere, and
    % letting it vote on finiteAll would let one unfilled slice void the whole
    % mask and leave nothing to score.
    if ~isfinite(sk) || sk <= 0
        continue;
    end

    fk = isfinite(A);
    finiteAll = finiteAll & fk;

    bn = b / sk;
    bn(~fk) = NaN;   % min/max ignore NaN pairwise, so these pixels just abstain

    minB = min(minB, bn);
    maxB = max(maxB, bn);
    info.framesUsed = info.framesUsed + 1;
end

if info.framesUsed == 0
    % Nothing usable at all. Return the eroded interior so callers still get a
    % well-formed mask instead of having to special-case empty.
    valid = erodeMask(true(H, W), fcfg.erodePx);
    info.fallback   = true;
    info.nValid     = sum(valid(:));
    info.validFrac  = info.nValid / (H * W);
    info.nDark      = 0;
    info.nHot       = 0;
    fprintf(2, ['[Focus] WARNING: no usable frames in the stack (all NaN or all ', ...
                'zero); the focus mask is the plain frame interior.\n']);
    return;
end

% --- Pedestal sniff test ----------------------------------------------------
% Dark-subtracted, the shadow sits near 0 while the lit region sits near 1, so
% the low percentile of the normalised brightness is well below the high one.
% With the pedestal still in, every pixel sits near the same large value and the
% ratio approaches 1. This is a heuristic, so it warns rather than refuses.
q05 = hc_Quantile(minB, 0.05);
q95 = hc_Quantile(maxB, 0.95);
if isfinite(q05) && isfinite(q95) && q95 > 0 && (q05 / q95) > 0.5
    info.looksUndarked = true;
    fprintf(2, ['[Focus] WARNING: this stack does not look dark-subtracted ', ...
                '(5th/95th percentile of normalised |I| = %.2f, expected well ', ...
                'below 0.5). The ~517 pedestal flattens |I|, so the shadow ', ...
                'cannot be separated from the lit region and the focus score is ', ...
                'not trustworthy. Tick takeDarkRef and rerun.\n'], q05 / q95);
end

% --- Steps 3-4: the shadow union, and hot pixels ----------------------------
dark = minB < fcfg.darkFrac;        % dark at ANY Z -> out
hot  = maxB > fcfg.hotFactor;       % outlier at ANY Z -> out

% Despeckle the shadow before using it. "Dark at ANY Z" is the right rule for a
% shadow whose penumbra moves with defocus, but taken literally over a 40-point
% stack it also catches every pixel that noise dipped below the threshold in just
% one frame -- so the mask erodes from noise alone, and does so worse the longer
% the stack. The discriminator is spatial: the shadow is a large contiguous
% region, a noise dip is one isolated pixel. Requiring a majority of a 3x3
% neighbourhood to be dark keeps the shadow (interior AND edge) and drops the
% speckle. Verified: without this, a 5-frame stack of pure per-pixel noise lost
% 98% of the frame to the mask.
dark = conv2(double(dark), ones(3, 3), 'same') >= 4.5;

keep = finiteAll & ~dark & ~hot;

info.nDark = sum(dark(:));
info.nHot  = sum(hot(:));

% --- Step 5: erode away the shadow boundary --------------------------------
valid = erodeMask(keep, fcfg.erodePx);

% --- Degenerate guard -------------------------------------------------------
% An (almost) empty mask would still produce a number, and that number would be
% meaningless -- far worse than saying so. Fall back to the plain interior, which
% at least measures something well-defined, and shout about it.
nValid  = sum(valid(:));
minWant = max(fcfg.minValidPx, 0.01 * H * W);
if nValid < minWant
    fprintf(2, ['[Focus] WARNING: the focus mask kept only %d of %d pixels ', ...
                '(%.2f%%, below the %d-pixel floor). Falling back to the plain ', ...
                'frame interior WITH NO shadow rejection -- the score may be ', ...
                'dominated by the stripline edge. Lower focusDarkFrac (now %g) ', ...
                'or check that the laser is actually on.\n'], ...
            nValid, H * W, 100 * nValid / (H * W), round(minWant), fcfg.darkFrac);
    % finiteAll can itself be empty (every used frame had a non-finite pixel
    % there), which would make the "fallback" just as useless as what it
    % replaces. Fall through to the plain frame in that case.
    base = finiteAll;
    if ~any(base(:)); base = true(H, W); end
    valid = erodeMask(base, fcfg.erodePx);
    info.fallback = true;
end

info.nValid    = sum(valid(:));
info.validFrac = info.nValid / (H * W);

function m = erodeMask(m0, r)
% Erode a logical mask by r pixels, without the Image Processing Toolbox.
%
% A pixel survives only if the whole (2r+1)^2 box around it was set, which is
% exactly what conv2 counts. 'same' zero-pads, so pixels within r of the frame
% edge fail the test automatically -- convenient, since the filters in
% hc_FocusMetric are undefined there anyway.
if r <= 0
    m = m0;
    return;
end
n = 2 * r + 1;
m = conv2(double(m0), ones(n, n), 'same') >= (n * n - 0.5);
