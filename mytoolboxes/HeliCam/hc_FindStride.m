function s = hc_FindStride(src, j)
% s = hc_FindStride(src, j)  Recover the true pixel row length (stride) and any
% row offset from an already-acquired widefield image. No hardware needed.
%
%   src : omitted/[] -> global gWide;  char/string -> a saved .h5
%   j   : sweep index (default: first slice that is not all-NaN)
%
% Why this works without re-acquiring: readIQ stores
%     img = transpose(reshape(v, w, h))
% which is a pure PERMUTATION of the linear pixel stream v. Nothing is lost, so v
% is exactly recoverable from the stored image as v = img.'(:), and we can re-cut
% it with different row lengths and see which one is right.
%
% How the two defects are told apart:
%
%   ROW LENGTH (stride). If the row length L is correct, pixels one row apart in
%   the display are one row apart on the sensor, so vertical differences are
%   small. A wrong L shears the image, breaking vertical adjacency. So the correct
%   L MINIMISES vertical roughness. Note this test is independent of any offset: a
%   constant offset still keeps vertically adjacent display pixels exactly L
%   samples apart in the stream.
%
%   ROW OFFSET. If the stream starts part-way into a row, every display row is
%   split, leaving one vertical SEAM at the same column in every row. So the
%   offset is the column with the largest horizontal jump. Circularly shifting the
%   columns left by that amount moves the seam to the edge -- which is exactly the
%   "move the right half to the left" operation when the offset happens to be L/2.
%
% IMPORTANT -- why a bare "which stride is smoothest" test does not work, and what
% is done instead. Comparing vertical roughness across strides is comparing the
% stream's autocorrelation at different lags, and the baseline correlation falls
% off with lag on its own. At L = 32, "vertically adjacent" pixels are 32 samples
% apart, i.e. 32 px along the SAME sensor row; at L = 512 they are one row apart.
% When row-to-row fixed-pattern noise dominates, along-a-row neighbours are more
% alike than down-a-row neighbours, so small strides always win on that score
% regardless of the true geometry.
%
% The true row length is a PEAK in the stream autocorrelation ABOVE the local
% baseline, with harmonics at 2L, 3L, ... So this detrends the autocorrelation
% against a running median and looks for peaks, which is scale-free. The divisor
% table is still printed for context, with its bias called out.
%
% Reports the current stride, the detected stride, and the seam column, so the fix
% is a number rather than an impression.

    if nargin < 1; src = []; end
    if nargin < 2; j   = []; end

    [ref, label] = loadRef(src);

    if isempty(j); j = firstValidSlice(ref); end
    if isnan(j)
        error('hc_FindStride: every sweep slice is all-NaN -- no acquired data.');
    end

    img = double(ref(:,:,j));
    if any(isnan(img(:)))
        error('hc_FindStride: slice %d contains NaN; pick a completed slice.', j);
    end

    [a, b] = size(img);
    strideNow = b;                  % readIQ used w = size(img,2) as the row length

    % Recover the original linear stream (exact inverse of readIQ's permutation).
    v = reshape(img.', [], 1);
    N = numel(v);

    fprintf('=== hc_FindStride (%s, sweep index %d) ===\n', label, j);
    fprintf('Stored image      : %d rows x %d cols  (%d pixels)\n', a, b, N);
    fprintf('Stride now in use : %d\n\n', strideNow);

    % --- candidate strides: exact divisors of N in a plausible range --------- %
    cands = [];
    for L = 32:floor(N/32)
        if mod(N, L) == 0
            cands(end+1) = L; %#ok<AGROW>
        end
    end
    if isempty(cands)
        error('hc_FindStride: %d has no divisors in the searched range.', N);
    end

    % --- PRIMARY test: detrended stream autocorrelation --------------------- %
    maxLag = min(4096, floor(N/8));
    [lags, acRatio] = detrendedAutocorr(v, maxLag);
    peaks = localPeaks(lags, acRatio, 1.02);      % lag, ratio; sorted by ratio

    fprintf('--- Autocorrelation peaks (scale-free; the true row length is here) ---\n');
    if isempty(peaks)
        fprintf('   No peak stands above the baseline. Either the image has no\n');
        fprintf('   row-to-row structure to lock onto, or it is pure noise.\n');
        strideDetected = NaN;
    else
        fprintf('%-8s %s\n', 'LAG', 'PEAK / BASELINE');
        nShow = min(8, size(peaks,1));
        for k = 1:nShow
            fprintf('%-8d %.4f\n', peaks(k,1), peaks(k,2));
        end
        % The fundamental is the smallest lag among the strong peaks whose
        % harmonics also appear -- a shear cannot fake that structure.
        strideDetected = pickFundamental(peaks);
        fprintf('\n   Fundamental (row length): %d\n', strideDetected);
    end
    fprintf('\n');

    % --- CONTEXT: divisor table, with its bias stated ---------------------- %
    fprintf('--- Vertical roughness by exact-divisor stride (BIASED, context only) ---\n');
    fprintf('    Small strides score well simply because their "vertical"\n');
    fprintf('    neighbours are nearby pixels on the SAME row. Read this for a\n');
    fprintf('    DIP against the local trend, not for the global minimum.\n');
    fprintf('%-8s %-8s %-14s %s\n', 'STRIDE', 'ROWS', 'VERT-ROUGHNESS', 'NOTE');
    rows  = zeros(1, numel(cands));
    score = zeros(1, numel(cands));
    for k = 1:numel(cands)
        rows(k)  = N / cands(k);
        score(k) = vertRoughness(v, cands(k));
    end
    for k = 1:numel(cands)
        note = '';
        if cands(k) == strideNow;      note = [note '<- in use  ']; end
        if cands(k) == strideDetected; note = [note '<== autocorr fundamental']; end
        fprintf('%-8d %-8d %-14.5g %s\n', cands(k), rows(k), score(k), note);
    end
    fprintf('\n');

    if isnan(strideDetected); strideDetected = strideNow; end
    best.L = strideDetected;

    s.strideNow      = strideNow;
    s.strideDetected = strideDetected;
    s.candidates     = cands;
    s.roughness      = score;
    s.acLags         = lags;
    s.acRatio        = acRatio;
    s.acPeaks        = peaks;

    % --- seam / offset within the detected stride --------------------------- %
    ny = floor(N / best.L);
    M  = reshape(v(1:ny*best.L), best.L, []).';   % rows x best.L
    d = mean(abs(diff(M, 1, 2)), 1);         % horizontal jump per column gap
    [~, ix] = max(d);
    seamCol = ix;                            % jump sits between ix and ix+1
    s.seamCol   = seamCol;
    s.seamRatio = max(d) / max(median(d), eps);

    fprintf('Best stride %d -> %d rows.\n', best.L, N/best.L);
    fprintf('Largest horizontal jump at column %d (%.3gx the median jump).\n', ...
            seamCol, s.seamRatio);

    if s.seamRatio < 3
        fprintf(['No dominant seam: the row offset is probably 0 (or the image is\n', ...
                 'too noisy to localise one).\n']);
        s.shiftSuggested = 0;
    else
        s.shiftSuggested = seamCol;
        fprintf(['=> Row offset detected. Circularly shift columns LEFT by %d to\n', ...
                 '   move the seam to the frame edge.\n'], seamCol);
        if abs(seamCol - best.L/2) <= max(2, 0.02*best.L)
            fprintf(['   That is almost exactly HALF the row length -- consistent with\n', ...
                     '   "move the right half to the left", i.e. a half-row offset.\n']);
        end
    end

    if best.L ~= strideNow
        fprintf(2, ['\n*** The stride in use (%d) does not match the autocorrelation\n', ...
                    '    fundamental (%d). readIQ would be reshaping with the wrong row\n', ...
                    '    length, shearing the image by %d px per row. ***\n'], ...
                strideNow, best.L, abs(strideNow - best.L));
    else
        fprintf(['\nStride in use (%d) matches the autocorrelation fundamental:\n', ...
                 'the reshape geometry is CORRECT and needs no change.\n'], strideNow);
    end

    fprintf(['\nTo eyeball a candidate without changing any code:\n', ...
             '    v = reshape(double(gWide.I(:,:,%d)).'', [], 1);\n', ...
             '    figure; imagesc(circshift(reshape(v, %d, []).'', [0 -%d])); axis image; colorbar\n'], ...
            j, best.L, s.shiftSuggested);

    fprintf(['\nReminder: geometry and photometry are independent. A sheared or\n', ...
             'offset image still has the right histogram, so this says nothing\n', ...
             'about whether the frame contains LIGHT -- and with an unmodulated\n', ...
             'LED, I = Q1-Q3 should be ~0 and any apparent picture is pattern\n', ...
             'noise. Settle that with the LED on/off pair in hc_ImageStats.\n']);
end

% ---------------------------------------------------------------------------- %
function [lags, ratio] = detrendedAutocorr(v, maxLag)
% Autocorrelation of the pixel stream, divided by a running-median baseline.
%
% The raw autocorrelation decays with lag, so a global maximum is meaningless for
% finding geometry. Dividing by the local median removes that decay and leaves
% only genuine periodicity -- which is what a fixed row length is.

    x = double(v(:));
    x = x - mean(x);

    n  = 2^nextpow2(2*numel(x));
    F  = fft(x, n);
    ac = real(ifft(F .* conj(F)));
    ac = ac(1:maxLag+1);
    if ac(1) == 0
        lags = (1:maxLag)'; ratio = ones(maxLag,1); return
    end
    ac = ac / ac(1);

    lags = (1:maxLag)';
    a    = ac(2:end);                       % drop lag 0

    % Baseline: running median wide enough to ignore individual peaks.
    win  = max(21, 2*round(maxLag/64) + 1);
    base = movmedian(a, win, 'Endpoints', 'shrink');

    ratio = a ./ max(abs(base), eps);
end

% ---------------------------------------------------------------------------- %
function pk = localPeaks(lags, ratio, thresh)
% Strict local maxima above thresh, returned as [lag ratio] sorted by ratio.
% Hand-rolled rather than findpeaks so no Signal Processing Toolbox is needed.

    pk = zeros(0, 2);
    for i = 2:(numel(ratio)-1)
        if ratio(i) > thresh && ratio(i) > ratio(i-1) && ratio(i) >= ratio(i+1)
            pk(end+1, :) = [lags(i), ratio(i)]; %#ok<AGROW>
        end
    end
    if ~isempty(pk)
        [~, ord] = sort(pk(:,2), 'descend');
        pk = pk(ord, :);
    end
end

% ---------------------------------------------------------------------------- %
function L = pickFundamental(peaks)
% The row length is the smallest strong lag whose harmonics also show up. Taking
% the tallest peak alone can land on a harmonic (2L, 3L), which would look like a
% plausible stride while halving the row count.

    cand = peaks(:,1);
    strong = cand(peaks(:,2) >= 0.5*max(peaks(:,2)));
    if isempty(strong); strong = cand; end
    strong = sort(strong);

    bestL = strong(1); bestN = -1;
    for i = 1:numel(strong)
        L0 = strong(i);
        if L0 < 8; continue; end
        % Count how many of this candidate's harmonics appear among all peaks.
        nHarm = 0;
        for m = 2:6
            if any(abs(cand - m*L0) <= max(1, 0.01*m*L0)); nHarm = nHarm + 1; end
        end
        if nHarm > bestN
            bestN = nHarm;
            bestL = L0;
        end
    end
    L = bestL;
end

% ---------------------------------------------------------------------------- %
function r = vertRoughness(v, L)
% Mean |difference| between vertically adjacent pixels for row length L,
% normalised by the overall spread so different strides compare fairly.
    ny = floor(numel(v) / L);
    M  = reshape(v(1:ny*L), L, ny).';        % ny x L
    dv = diff(M, 1, 1);
    sd = std(v);
    r  = mean(abs(dv(:))) / max(sd, eps);
end

% ---------------------------------------------------------------------------- %
function [ref, label] = loadRef(src)
    % Shared loader: accepts the live gWide or a path, and both the current
    % /I,/Q datasets and the pre-rename /reference,/rawsignal ones.
    [ref, ~, label] = hc_LoadIQ(src, 'hc_FindStride');
end

% ---------------------------------------------------------------------------- %
function gW = getGlobalWide()
    global gWide %#ok<GVMIS>
    gW = gWide;
end

% ---------------------------------------------------------------------------- %
function j = firstValidSlice(ref)
    j = NaN;
    for k = 1:size(ref, 3)
        sl = ref(:,:,k);
        if ~all(isnan(sl(:))); j = k; return; end
    end
end
