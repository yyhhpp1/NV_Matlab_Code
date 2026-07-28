function s = hc_ImageStats(src, j, dark)
% s = hc_ImageStats(src, j, dark)  Decide whether a widefield image is LIGHT or
% PATTERN.
%
%   src  : omitted/[] -> use global gWide (the run just finished)
%          char/string -> path to a saved .h5 from SaveWidefield
%   j    : sweep index to analyse (default: first slice that is not all-NaN)
%   dark : optional dark reference to subtract per pixel -- a struct from
%          hc_DarkRef('load'), or a path to its .mat. The C4 carries a large
%          per-pixel electronic pedestal (~517 in decoded units with the cap on),
%          so without this the stats describe the offset and its fixed-pattern
%          structure rather than any light.
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

    if nargin < 1; src  = []; end
    if nargin < 2; j    = []; end
    if nargin < 3; dark = []; end

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
    fprintf('Image size: %d x %d\n', size(A,1), size(A,2));

    % --- optional per-pixel dark subtraction ------------------------------- %
    s.darkApplied = false;
    if ~isempty(dark)
        D = resolveDark(dark);
        checkDarkSettings(D);
        if ~isequal(size(D.reference), size(A))
            error(['hc_ImageStats: dark reference is %dx%d but the image is ', ...
                   '%dx%d.'], size(D.reference,1), size(D.reference,2), ...
                   size(A,1), size(A,2));
        end
        fprintf('Dark subtraction: ON (pedestal mean %.6g removed)\n', ...
                mean(D.reference(:), 'omitnan'));
        A = A - D.reference;
        if ~isempty(B) && isfield(D,'rawsignal') && isequal(size(D.rawsignal), size(B))
            B = B - D.rawsignal;
        end
        s.darkApplied = true;
    else
        fprintf(['Dark subtraction: off. The C4 pedestal (~500 units) dominates,\n', ...
                 '   so the numbers below describe OFFSET + PATTERN, not light.\n', ...
                 '   Capture one with hc_DarkRef(''save'') and pass it here.\n']);
    end
    fprintf('\n');

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

    if s.darkApplied
        fprintf(['Dark-subtracted, so "mean" is now light-induced signal only.\n', ...
                 'A mean near zero on an UNMODULATED source is the CORRECT result:\n', ...
                 'I = Q1-Q3 cancels DC light by design.\n']);
    else
        fprintf(['Next: capture a dark (block the light, run, hc_DarkRef(''save'')),\n', ...
                 'then pass it here. Comparing blocked vs unblocked "mean" without\n', ...
                 'it only works if the difference exceeds the pedestal drift.\n']);
    end
end

% ---------------------------------------------------------------------------- %
function D = resolveDark(dark)
% Accept a struct from hc_DarkRef('load'), or a path to its .mat.
    if isstruct(dark)
        D = dark;
    else
        D = hc_DarkRef('load', dark);
    end
    if ~isfield(D, 'reference')
        error('hc_ImageStats: dark reference has no ''reference'' field.');
    end
end

% ---------------------------------------------------------------------------- %
function checkDarkSettings(D)
% The pedestal scales with exposure, nPeriods and nFrames, so a dark taken under
% different settings subtracts the wrong amount. Warn rather than refuse -- the
% user may deliberately be comparing.
    if ~isfield(D, 'settings') || ~isstruct(D.settings); return; end
    try
        global gmSEQ %#ok<GVMIS>
        f = {'exposureSeconds', 'nPeriods', 'nFrames', 'readout'};
        for i = 1:numel(f)
            if isfield(gmSEQ, f{i}) && isfield(D.settings, f{i})
                a = double(gmSEQ.(f{i}));
                b = D.settings.(f{i});
                if isscalar(a) && ~isnan(b) && abs(a - b) > 1e-12 * max(1, abs(b))
                    fprintf(2, ['   WARNING: dark was taken at %s = %g but the run ', ...
                                'used %g. The pedestal scales with it, so the ', ...
                                'subtraction is wrong.\n'], f{i}, b, a);
                end
            end
        end
    catch
    end
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
