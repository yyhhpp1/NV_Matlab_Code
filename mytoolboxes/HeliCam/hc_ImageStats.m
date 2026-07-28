function s = hc_ImageStats(src, j)
% s = hc_ImageStats(src, j)  Decide whether a widefield image is LIGHT or PATTERN.
%
%   src : omitted/[] -> use global gWide (the run just finished)
%         char/string -> path to a saved .h5 from SaveWidefield
%   j   : sweep index to analyse (default: first slice that is not all-NaN)
%
% A HeliCam lock-in image can look perfectly plausible and contain no light at
% all: electronic pedestal plus row-wise fixed-pattern noise produces a smooth,
% structured, believable picture. By eye that is indistinguishable from a flat
% uniformly-illuminated field. This separates them numerically.
%
% Two-way variance decomposition of the image A (exact, cross terms vanish):
%
%   A_ij = grand + r_i + c_j + e_ij
%   SS_total = SS_row + SS_col + SS_resid
%
%   SS_row  dominant  -> row-structured: sensor line/readout fixed-pattern noise,
%                        NOT an optical image.
%   SS_col  dominant  -> column-structured: same conclusion, other axis.
%   both moderate     -> a smooth 2-D gradient, consistent with real illumination
%                        falloff (or with a thermal/offset drift).
%   SS_resid dominant -> pixel-level; the whiteness test below then says whether
%                        it is shot/read noise or genuine fine structure.
%
% Whiteness of the residual: for white noise mean(diff^2) = 2*var, so the printed
% ratio is ~1 for noise, well below 1 for a genuinely resolved (spatially
% correlated) image, and above 1 for alternating pixel patterns.
%
% For hc_Image specifically: laser is in Q1 only, so Q = Q2 - Q4 ~ 0 and
% |rawsignal| / reference should be SMALL. A ratio near 1 means Q is picking up as
% much as I, which contradicts the sequence and points at phase misalignment
% (LockInReferenceTimeShift) rather than a real measurement.
%
% THE decisive test is still a controlled comparison -- run this with the
% excitation unblocked and again blocked, and compare 'mean'. If the mean barely
% moves, the image is not light.

    if nargin < 1; src = []; end
    if nargin < 2; j   = []; end

    [ref, raw, label] = loadStack(src);

    if isempty(j)
        j = firstValidSlice(ref);
    end
    if isnan(j)
        error('hc_ImageStats: every sweep slice is all-NaN -- no acquired data.');
    end

    A = double(ref(:,:,j));
    B = [];
    if ~isempty(raw) && size(raw,3) >= j
        B = double(raw(:,:,j));
    end

    fprintf('=== hc_ImageStats (%s, sweep index %d) ===\n', label, j);
    fprintf('Image size: %d x %d\n\n', size(A,1), size(A,2));

    s.reference = describe(A, 'reference  (mean I)');

    if ~isempty(B)
        s.rawsignal = describe(B, 'rawsignal  (-mean Q)');
        rr = mean(abs(B(:)), 'omitnan') / max(mean(abs(A(:)), 'omitnan'), eps);
        fprintf('-- Q vs I --\n');
        fprintf('   mean|rawsignal| / mean|reference| = %.4g\n', rr);
        if rr > 0.3
            fprintf(2, ['   NOTE: for hc_Image the laser is in Q1 only, so Q should be\n', ...
                        '   near zero. A ratio this large contradicts the sequence --\n', ...
                        '   suspect quarter-phase misalignment (LockInReferenceTimeShift)\n', ...
                        '   before trusting any contrast.\n']);
        else
            fprintf('   Consistent with laser in Q1 only (Q should be ~0).\n');
        end
        fprintf('\n');
        s.qOverI = rr;
    end

    fprintf(['Next: rerun with the excitation BLOCKED and compare "mean".\n', ...
             'Unchanged mean => pedestal/pattern, not light.\n']);
end

% ---------------------------------------------------------------------------- %
function st = describe(A, name)
% Print stats + variance decomposition + whiteness for one image.

    v = A(~isnan(A));
    st.mean   = mean(v);
    st.median = median(v);
    st.std    = std(v);
    st.min    = min(v);
    st.max    = max(v);

    fprintf('-- %s --\n', name);
    fprintf('   mean %.6g   median %.6g   std %.6g\n', st.mean, st.median, st.std);
    fprintf('   min  %.6g   max    %.6g   p-p/mean %.3g %%\n', ...
            st.min, st.max, 100*(st.max - st.min)/max(abs(st.mean), eps));

    % --- two-way decomposition (needs a NaN-free image) ---
    if any(isnan(A(:)))
        fprintf('   (contains NaN -- skipping variance decomposition)\n\n');
        return
    end

    [H, W] = size(A);
    grand  = mean(A(:));
    r      = mean(A, 2) - grand;        % H x 1
    c      = mean(A, 1) - grand;        % 1 x W
    e      = A - grand - r - c;

    ssTot = sum((A(:) - grand).^2);
    ssRow = W * sum(r.^2);
    ssCol = H * sum(c.^2);
    ssRes = sum(e(:).^2);

    if ssTot <= 0
        fprintf('   (zero variance -- uniform image)\n\n');
        return
    end

    st.pctRow   = 100 * ssRow / ssTot;
    st.pctCol   = 100 * ssCol / ssTot;
    st.pctResid = 100 * ssRes / ssTot;

    fprintf('   variance share:  rows %.1f %%   cols %.1f %%   residual %.1f %%\n', ...
            st.pctRow, st.pctCol, st.pctResid);

    % --- whiteness of the residual, along each axis ---
    dRow = diff(e, 1, 1);   % down columns  (vertical neighbours)
    dCol = diff(e, 1, 2);   % across rows   (horizontal neighbours)
    vRes = var(e(:));
    st.whiteVert = mean(dRow(:).^2) / max(2*vRes, eps);
    st.whiteHorz = mean(dCol(:).^2) / max(2*vRes, eps);
    fprintf('   residual whiteness: vertical %.3g   horizontal %.3g   (1 = white noise)\n', ...
            st.whiteVert, st.whiteHorz);

    % --- interpretation ---
    dominant = max([st.pctRow, st.pctCol, st.pctResid]);
    if dominant == st.pctRow && st.pctRow > 50
        fprintf(2, ['   => ROW-DOMINATED. Consistent with sensor line/readout\n', ...
                    '      fixed-pattern noise, not an optical image.\n']);
    elseif dominant == st.pctCol && st.pctCol > 50
        fprintf(2, ['   => COLUMN-DOMINATED. Consistent with fixed-pattern noise\n', ...
                    '      along the other axis, not an optical image.\n']);
    elseif st.pctResid > 80 && min(st.whiteVert, st.whiteHorz) > 0.7
        fprintf(['   => Essentially white pixel noise: no resolved structure.\n', ...
                 '      Either there is no light, or it is buried in read noise.\n']);
    elseif st.pctResid > 50 && max(st.whiteVert, st.whiteHorz) < 0.5
        fprintf(['   => Spatially correlated fine structure: consistent with a\n', ...
                 '      genuinely resolved image.\n']);
    else
        fprintf(['   => Mixed row/column structure: a smooth 2-D gradient.\n', ...
                 '      Consistent with illumination falloff, but also with\n', ...
                 '      offset/thermal drift. The blocked-laser comparison decides.\n']);
    end
    fprintf('\n');
end

% ---------------------------------------------------------------------------- %
function [ref, raw, label] = loadStack(src)
    if isempty(src)
        gW = getGlobalWide();
        if isempty(gW) || ~isfield(gW, 'reference')
            error('hc_ImageStats: global gWide has no reference data yet.');
        end
        ref = gW.reference;
        raw = [];
        if isfield(gW, 'rawsignal'); raw = gW.rawsignal; end
        label = 'global gWide';
        return
    end

    p = char(string(src));
    if ~isfile(p)
        error('hc_ImageStats: file not found: %s', p);
    end
    ref = h5read(p, '/reference');
    raw = [];
    try
        raw = h5read(p, '/rawsignal');
    catch
    end
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
        if ~all(isnan(sl(:)))
            j = k;
            return
        end
    end
end
