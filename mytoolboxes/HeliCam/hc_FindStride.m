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
% Reports the current stride, the best stride, and the seam column, so the fix is
% a number rather than an impression.

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

    fprintf('%-8s %-8s %-14s %s\n', 'STRIDE', 'ROWS', 'VERT-ROUGHNESS', 'NOTE');
    best = struct('L', NaN, 'score', Inf);
    rows = zeros(1, numel(cands));
    score = zeros(1, numel(cands));
    for k = 1:numel(cands)
        L = cands(k);
        rows(k)  = N / L;
        score(k) = vertRoughness(v, L);
        if score(k) < best.score
            best.score = score(k);
            best.L     = L;
        end
    end

    % Print, flagging the current and the best.
    for k = 1:numel(cands)
        note = '';
        if cands(k) == strideNow; note = [note '<- in use  ']; end
        if cands(k) == best.L;    note = [note '<== BEST (smoothest)']; end
        fprintf('%-8d %-8d %-14.5g %s\n', cands(k), rows(k), score(k), note);
    end
    fprintf('\n');

    s.strideNow  = strideNow;
    s.strideBest = best.L;
    s.candidates = cands;
    s.roughness  = score;

    % --- seam / offset within the best stride ------------------------------- %
    M = reshape(v, best.L, []).';           % rows x best.L
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
        fprintf(2, ['\n*** The stride in use (%d) is NOT the smoothest (%d). readIQ is\n', ...
                    '    reshaping with the wrong row length, which shears the image by\n', ...
                    '    %d px per row. ***\n'], strideNow, best.L, abs(strideNow - best.L));
    else
        fprintf('\nStride in use matches the smoothest candidate.\n');
    end

    fprintf(['\nTo eyeball a candidate without changing any code:\n', ...
             '    v = reshape(double(gWide.reference(:,:,%d)).'', [], 1);\n', ...
             '    figure; imagesc(circshift(reshape(v, %d, []).'', [0 -%d])); axis image; colorbar\n'], ...
            j, best.L, s.shiftSuggested);
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
    if isempty(src)
        gW = getGlobalWide();
        if isempty(gW) || ~isfield(gW, 'reference')
            error('hc_FindStride: global gWide has no reference data yet.');
        end
        ref   = gW.reference;
        label = 'global gWide';
        return
    end
    p = char(string(src));
    if ~isfile(p)
        error('hc_FindStride: file not found: %s', p);
    end
    ref   = h5read(p, '/reference');
    label = p;
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
