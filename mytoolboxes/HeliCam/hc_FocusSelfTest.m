function ok = hc_FocusSelfTest(bPlot)
% hc_FocusSelfTest  Verify the hc_ZScan focus metric on synthetic data.
%
%   ok = hc_FocusSelfTest        % prints a PASS/FAIL table
%   ok = hc_FocusSelfTest(true)  % also plots the curves
%
% No hardware, no camera, no toolboxes beyond core MATLAB. Builds a Z stack that
% reproduces the thing that actually makes this problem hard, then checks that
% the code gets the right answer for the right reason.
%
% The synthetic scene has TWO planes:
%   * the diamond at zDiamond -- speckled fluorescence, the thing we want in focus
%   * a stripline shadow whose EDGE sharpens at zStrip = zDiamond + 50
%
% Test 2 is the one that matters. It runs the identical stack with masking
% disabled and asserts the answer moves toward the stripline plane. If that test
% ever starts passing trivially (no shift), the mask is not doing anything on
% this synthetic scene and the test has stopped being meaningful.

if nargin < 1 || isempty(bPlot); bPlot = false; end

H = 128; W = 136;            % small but same aspect as the real 512 x 542 sensor
zDiamond = 47;
zStrip   = zDiamond + 50;    % the stripline standoff, in the same um units
z        = 30:2:70;          % brackets the diamond, NOT the stripline

% Deterministic: a test that fails one run in ten is worse than no test.
rs = RandStream('mt19937ar', 'Seed', 20260821);

stack = synthStack(H, W, z, zDiamond, zStrip, rs);

results = {};
ok      = true;

% ---------------------------------------------------------------------------
% Test 1: with masking, the peak lands on the diamond plane.
% ---------------------------------------------------------------------------
cfg = WidefieldConfig();
cfg.focusDarkFrac = 0.35;
cfg.focusErodePx  = 3;
[validM, minfoM]  = hc_FocusMask(stack, cfg);
[Fm, ~]           = hc_FocusMetric(stack, validM, cfg);
[zBestM, ~, interiorM, confM] = hc_FocusPeak(z, Fm);

step = median(diff(z));
t1   = abs(zBestM - zDiamond) <= step;
results(end+1,:) = {'masked peak at diamond', t1, ...
    sprintf('zBest %.2f vs truth %g (tol %g)', zBestM, zDiamond, step)};

t2 = interiorM;
results(end+1,:) = {'masked peak is interior', t2, ...
    sprintf('interior = %d', interiorM)};

t3 = confM > 1.2;
results(end+1,:) = {'masked curve has a real peak', t3, ...
    sprintf('conf %.2f > 1.2', confM)};

t4 = minfoM.validFrac > 0.1 && minfoM.validFrac < 0.95 && ~minfoM.fallback;
results(end+1,:) = {'mask kept a sane pixel fraction', t4, ...
    sprintf('%.1f%% valid, fallback %d', 100*minfoM.validFrac, minfoM.fallback)};

% ---------------------------------------------------------------------------
% Test 2: THE POINT OF THE FEATURE. With the shadow left in, the stripline
% edge pulls the answer away from the diamond. Asserting the direction of the
% shift, not just that it differs, so a random wobble cannot pass this.
% ---------------------------------------------------------------------------
cfgU = cfg;
cfgU.focusDarkFrac  = 0;      % no dark rejection
cfgU.focusErodePx   = 2;      % minimum legal -- keeps the edge in view
cfgU.focusHotFactor = inf;    % and no outlier rejection either
[validU, ~] = hc_FocusMask(stack, cfgU);
[Fu, ~]     = hc_FocusMetric(stack, validU, cfgU);
[zBestU, ~, ~, ~] = hc_FocusPeak(z, Fu);

pull = zBestU - zBestM;       % stripline is ABOVE the diamond, so expect > 0
t5   = pull > step;
results(end+1,:) = {'unmasked peak pulled toward stripline', t5, ...
    sprintf('unmasked %.2f vs masked %.2f (shift %+.2f, need > %g)', ...
            zBestU, zBestM, pull, step)};

t6 = abs(zBestU - zDiamond) > abs(zBestM - zDiamond);
results(end+1,:) = {'masking improves the answer', t6, ...
    sprintf('|err| unmasked %.2f vs masked %.2f', ...
            abs(zBestU - zDiamond), abs(zBestM - zDiamond))};

% ---------------------------------------------------------------------------
% Test 3: sign-agnostic. readIQ negates I, and which sign means "bright" is not
% obvious from the code, so the whole analysis must be invariant to it.
% ---------------------------------------------------------------------------
[validN, ~] = hc_FocusMask(-stack, cfg);
[Fn, ~]     = hc_FocusMetric(-stack, validN, cfg);
[zBestN, ~, ~, ~] = hc_FocusPeak(z, Fn);

t7 = isequal(validN, validM);
results(end+1,:) = {'negating the stack keeps the mask', t7, ...
    sprintf('%d pixels differ', sum(validN(:) ~= validM(:)))};

t8 = abs(zBestN - zBestM) < 1e-6;
results(end+1,:) = {'negating the stack keeps the peak', t8, ...
    sprintf('%.6f vs %.6f', zBestN, zBestM)};

% ---------------------------------------------------------------------------
% Test 4: a flat stack must report no peak rather than inventing one.
% ---------------------------------------------------------------------------
flat = repmat(stack(:,:,1), 1, 1, numel(z));
[validF, ~] = hc_FocusMask(flat, cfg);
[Ff, ~]     = hc_FocusMetric(flat, validF, cfg);
[~, ~, ~, confF] = hc_FocusPeak(z, Ff);

t9 = ~isfinite(confF) || confF < 1.2;
results(end+1,:) = {'flat stack yields no peak', t9, ...
    sprintf('conf %.4f < 1.2', confF)};

% ---------------------------------------------------------------------------
% Test 5: the pedestal sniffer fires on undark-subtracted data.
%
% Scaled to the real regime first. On the raw C4 scale the light-induced part is
% a few tens of counts sitting on a ~517 per-pixel pedestal -- that is what makes
% |I| nearly uniform and the mask useless. Testing at the synthetic stack's own
% (much larger) amplitude would be testing the wrong thing: a 517 pedestal really
% does not flatten a 1400-count signal, and the sniffer is right to stay quiet.
% ---------------------------------------------------------------------------
lightScale = 25 / hc_Quantile(abs(stack(:,:,1)), 0.95);   % ~25 counts of light
ped = stack * lightScale - 517;   % stack is negative-going, so this deepens it
fprintf('--- expect one pedestal warning from the next call ---\n');
[~, minfoP] = hc_FocusMask(ped, cfg);
t10 = minfoP.looksUndarked;
results(end+1,:) = {'pedestal detected in raw-scale data', t10, ...
    sprintf('looksUndarked = %d', minfoP.looksUndarked)};

% --- Report -----------------------------------------------------------------
fprintf('\nhc_FocusSelfTest\n');
fprintf('%-42s %-6s %s\n', 'check', 'result', 'detail');
fprintf('%-42s %-6s %s\n', repmat('-',1,42), '------', repmat('-',1,40));
for i = 1:size(results,1)
    pass = results{i,2};
    ok   = ok && pass;
    if pass; tag = 'PASS'; else; tag = 'FAIL'; end
    fprintf('%-42s %-6s %s\n', results{i,1}, tag, results{i,3});
end
if ok
    fprintf('\nALL PASS. Masked best Z = %.2f um (truth %g).\n', zBestM, zDiamond);
else
    fprintf(2, '\nFAILURES ABOVE.\n');
end

if bPlot
    figure('Name','hc_FocusSelfTest','NumberTitle','off');
    subplot(1,2,1);
    plot(z, Fm/max(Fm), '-o', z, Fu/max(Fu), '-s'); grid on;
    xline_local(zDiamond, 'diamond');
    xlabel('Z (\mum)'); ylabel('score / own max');
    legend({'masked','unmasked'}, 'Location','best');
    title(sprintf('masked %.2f, unmasked %.2f (truth %g)', zBestM, zBestU, zDiamond));
    subplot(1,2,2);
    imagesc(stack(:,:,round(numel(z)/2))); axis image; colormap pink;
    hold on; contour(double(validM), [0.5 0.5], 'c', 'LineWidth', 1); hold off;
    title('mid-stack frame + scored region');
end
end

% ===========================================================================
function stack = synthStack(H, W, z, zDiamond, zStrip, rs)
% A Z stack with the diamond and the stripline shadow in DIFFERENT planes.
%
% Both are blurred by their own defocus, so each has its own sharpest Z. That is
% the whole point: a metric that sees the shadow edge peaks at zStrip, and one
% that sees only the diamond peaks at zDiamond.

K = numel(z);

% Diamond plane: fine speckle, the high-frequency content focus acts on.
truth = 1 + 0.8 * randn(rs, H, W);
truth = truth - min(truth(:)) + 0.2;

% Stripline: an opaque band across the frame. Built as a sharp-edged
% transmission profile which is then blurred by ITS own defocus, so the edge
% gradient peaks at zStrip.
band = ones(H, W);
band(:, round(0.42*W):round(0.62*W)) = 0.04;    % ~20% of the width, near opaque

umPerPixelBlur = 0.09;   % how fast each plane blurs with defocus

stack = zeros(H, W, K);
for k = 1:K
    sigD = max(umPerPixelBlur * abs(z(k) - zDiamond), 1e-3);
    sigS = max(umPerPixelBlur * abs(z(k) - zStrip),   1e-3);

    lit = blurGauss(truth, sigD);
    shd = blurGauss(band,  sigS);

    frame = 400 * lit .* shd;

    % A few hot pixels, Z-independent, as the real sensor has.
    if k == 1
        hotIdx = randperm(rs, H*W, 12);
    end
    frame(hotIdx) = 6000;

    frame = frame + 6 * randn(rs, H, W);        % read noise

    % readIQ returns I negated, and RunSequence hands the focus code the
    % dark-subtracted result -- so: negative-going, centred near 0 where dark.
    stack(:,:,k) = -frame;
end
end

% ===========================================================================
function B = blurGauss(A, sigma)
% Separable Gaussian blur with conv2 only (no Image Processing Toolbox).
r = max(1, ceil(3*sigma));
x = -r:r;
g = exp(-(x.^2) / (2*sigma^2));
g = g / sum(g);
% 'symmetric'-like edge handling by padding with the border value, so the frame
% edge does not manufacture a Z-dependent gradient of its own.
Ap = padReplicate(A, r);
B  = conv2(conv2(Ap, g, 'same'), g', 'same');
B  = B(r+1:end-r, r+1:end-r);
end

% ===========================================================================
function Ap = padReplicate(A, r)
Ap = A([ones(1,r) 1:size(A,1) size(A,1)*ones(1,r)], ...
       [ones(1,r) 1:size(A,2) size(A,2)*ones(1,r)]);
end

% ===========================================================================
function xline_local(x, label)
yl = ylim;
hold on;
plot([x x], yl, 'k--');
text(x, yl(2), [' ' label], 'VerticalAlignment', 'top');
hold off;
end
