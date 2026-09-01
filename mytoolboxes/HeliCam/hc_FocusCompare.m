function out = hc_FocusCompare(src, cfg)
% hc_FocusCompare(src, cfg)  Re-score a saved Z stack with every focus metric.
%
%   out = hc_FocusCompare()          % use the live gWide
%   out = hc_FocusCompare(h5path)    % a file written by SaveWidefield
%   out = hc_FocusCompare(h5path, cfg)
%
% Offline only -- touches no hardware. Recomputes the mask and all four metrics
% from the stored I stack, plots them normalised to their own maxima on
% one set of axes, and prints each one's best Z and confidence.
%
% This is how the 'tenengrad' default gets confirmed or overturned on the actual
% sample, from a file you already have, instead of from another hour of Z scans.
% What to look for: the metric with the narrowest peak at the same Z as the
% others is the best discriminator here. A metric that peaks somewhere DIFFERENT
% from the rest is the interesting case -- usually it means that metric is
% latching onto something other than the diamond surface (the stripline edge, or
% row/column pattern noise), which is a reason to distrust it, not to adopt it.
%
% Also useful for tuning the mask: rerun with
%   cfg = WidefieldConfig(); cfg.focusDarkFrac = 0; hc_FocusCompare(f, cfg)
% and compare the best Z against the masked result. A large shift is the shadow
% edge pulling the answer, which is exactly what the mask exists to prevent.

global gWide

if nargin < 2; cfg = []; end
fcfg = hc_FocusConfig(cfg);

% --- Load the stack ---------------------------------------------------------
% Focus is measured on I: it asks how sharp the LIGHT is, so it needs an
% intensity image, not a derived combination.
[stack, ~, label] = hc_LoadIQ(src, 'hc_FocusCompare');
darkSubtracted = true;
if nargin < 1 || isempty(src)
    z = [];
    if ~isempty(gWide) && isfield(gWide,'SweepParam'); z = gWide.SweepParam; end
    if ~isempty(gWide) && isfield(gWide,'darkSubtracted')
        darkSubtracted = gWide.darkSubtracted;
    end
else
    src = char(string(src));
    try
        z = h5read(src, '/sweep_param');
    catch
        z = 1:size(stack, 3);
    end
    try
        darkSubtracted = h5readatt(src, '/', 'dark_subtracted') ~= 0;
    catch
        % Older files predate the attribute; hc_FocusMask still sniffs for the
        % pedestal, so this is not the only line of defence.
    end
end
if isempty(z); z = 1:size(stack, 3); end

z = double(z(:))';
K = size(stack, 3);
if numel(z) ~= K
    z = 1:K;
end
if K < 3
    error('hc_FocusCompare:TooShort', ...
          'Need at least 3 Z points to compare focus curves; this stack has %d.', K);
end

if ~darkSubtracted
    fprintf(2, ['[FocusCompare] This file reports dark_subtracted = 0. The ~517 ', ...
                'pedestal flattens |I|, so the mask cannot separate the stripline ', ...
                'shadow and every curve below is suspect.\n']);
end

% --- Score ------------------------------------------------------------------
[valid, minfo] = hc_FocusMask(stack, fcfg);
[~, finfo]     = hc_FocusMetric(stack, valid, fcfg);

names = fieldnames(finfo.metrics);
out          = struct();
out.source   = label;
out.z        = z;
out.metrics  = finfo.metrics;
out.valid    = valid;
out.maskInfo = minfo;
out.best     = struct();

fprintf('\n[FocusCompare] %s\n', label);
fprintf('  %d Z points over %g..%g; mask kept %d px (%.1f%% of frame)\n', ...
        K, min(z), max(z), minfo.nValid, 100*minfo.validFrac);
if minfo.fallback
    fprintf(2, '  MASK FELL BACK -- the stripline shadow was NOT rejected.\n');
end
fprintf('  darkFrac %g, erodePx %d, brightPct %g\n\n', ...
        fcfg.darkFrac, fcfg.erodePx, fcfg.brightPct);
fprintf('  %-12s %12s %8s %12s\n', 'metric', 'best Z', 'conf', 'peak');
fprintf('  %-12s %12s %8s %12s\n', '------', '------', '----', '----');

figure('Name', ['Focus metrics: ' label], 'NumberTitle', 'off');
hold on;
leg = {};
for i = 1:numel(names)
    F = finfo.metrics.(names{i});
    [zBest, iBest, isInterior, conf] = hc_FocusPeak(z, F);

    out.best.(names{i}) = struct('zBest', zBest, 'iBest', iBest, ...
                                 'isInterior', isInterior, 'conf', conf);

    if isInterior; peakTag = 'interior'; else; peakTag = 'AT EDGE'; end
    fprintf('  %-12s %12.4g %8.2f %12s\n', names{i}, zBest, conf, peakTag);

    % Normalise to its own max so four metrics with wildly different scales are
    % comparable by SHAPE, which is the only thing that matters for autofocus.
    s = max(F);
    if ~isfinite(s) || s == 0; s = 1; end
    plot(z, F / s, '-o', 'LineWidth', 1.2);
    leg{end+1} = sprintf('%s (best %.3g)', names{i}, zBest);   %#ok<AGROW>
end
hold off;
grid on;
xlabel('Z (\mum)');
ylabel('focus score, normalised to own max');
title(sprintf('%s -- mask kept %.1f%% of frame', label, 100*minfo.validFrac), ...
      'Interpreter', 'none');
legend(leg, 'Location', 'best', 'Interpreter', 'none');
fprintf('\n');
end
