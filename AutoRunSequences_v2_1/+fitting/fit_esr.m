function fit_esr(varargin)
global gmSEQ

if nargin < 1
    return;
end
handles = varargin{1};
if nargin >= 2
    handles2 = varargin{2};
else
    handles2 = [];
end

cfg = config();
minPoints = 5;
if isfield(cfg, 'smart') && isfield(cfg.smart, 'esrFit') && ...
        isfield(cfg.smart.esrFit, 'minPoints')
    minPoints = max(5, round(cfg.smart.esrFit.minPoints));
end

seqName = current_sequence_name(gmSEQ);
nPeaksExpected = expected_esr_fit_peak_count(gmSEQ, seqName);
status = struct('ok', false, 'validN', 0, 'nRequired', NaN, ...
    'msg', '', 'nPeaksRequested', nPeaksExpected, 'nPeaksFitted', 0);

gmSEQ.ESRFitFreq = NaN; % prevent stale values when fit is skipped/failed
gmSEQ.ESRFitFreqAllMHz = [];

if ~isfield(gmSEQ, 'signal') || size(gmSEQ.signal, 1) < 2 || ~isfield(gmSEQ, 'SweepParam')
    status.msg = 'Fit skipped: ESR data unavailable';
    gmSEQ.ESRFitLastStatus = status;
    return;
end

x = double(gmSEQ.SweepParam) .* gmSEQ.ScaleT;
y = double(gmSEQ.signal(2, :)) ./ double(gmSEQ.signal(1, :));

valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
status.validN = numel(x);

labels = {};
refs = [];
if strcmpi(seqName, 'ODMR')
    if isfield(gmSEQ, 'ESRFitWindowLabels') && iscell(gmSEQ.ESRFitWindowLabels)
        labels = gmSEQ.ESRFitWindowLabels;
    end
    if isfield(gmSEQ, 'ESRFitLabelCentersGHz')
        refs = double(gmSEQ.ESRFitLabelCentersGHz(:)).';
    end
end

nPeaks = resolve_live_odmr_peak_count(seqName, nPeaksExpected, labels, x, y);
minRequired = max(minPoints, 3 * nPeaks + 2);
status.nRequired = minRequired;

if numel(x) < minRequired || (max(x) - min(x)) <= 0
    status.msg = sprintf('Fit skipped: %d valid points (<%d required)', numel(x), minRequired);
    gmSEQ.ESRFitLastStatus = status;
    return;
end

try
    if nPeaks <= 1
        [fitOut, locErrMetricMHz] = fit_single_lorentz_esr(x, y);
    else
        [fitOut, locErrMetricMHz] = fit_multi_lorentz_esr(x, y, nPeaks, labels, refs);
    end

    delete(findobj(handles.axes3, 'Tag', 'smart_live_esr_fit'));
    hold(handles.axes3, 'on');
    xPlot = linspace(x(1), x(end), 301);
    yPlot = fitOut.model(fitOut.popt, xPlot);
    plot(handles.axes3, xPlot, yPlot, 'DisplayName', fitOut.fitText, 'Tag', 'smart_live_esr_fit');

    if get(handles.bShowLegend, 'Value')
        legend(handles.axes3, 'Location', 'best');
    end
    hold(handles.axes3, 'off');

    if ~isempty(fitOut.centerMHz)
        gmSEQ.ESRFitFreq = fitOut.centerMHz(1); % legacy scalar
        gmSEQ.ESRFitFreqAllMHz = fitOut.centerMHz(:).';
    end

    status.ok = true;
    status.msg = '';
    status.nPeaksFitted = numel(fitOut.centerMHz);

    if ~isempty(handles2) && isfield(handles2, 'thrsESR') && isgraphics(handles2.thrsESR, 'uicontrol')
        th = str2double(get(handles2.thrsESR, 'String'));
        if isfinite(th) && isfinite(locErrMetricMHz) && locErrMetricMHz <= th
            gmSEQ.bGoAfterAvg = 0;
        end
    end
catch ME
    status.msg = ['Fit skipped: ' ME.message];
end

gmSEQ.ESRFitLastStatus = status;
end

function nPeaks = resolve_live_odmr_peak_count(seqName, nExpected, labels, x, y)
nPeaks = max(1, round(double(nExpected)));
if ~strcmpi(seqName, 'ODMR')
    return;
end

nLabel = 0;
if iscell(labels)
    nLabel = numel(labels);
end
% ODMR can show up to 4 resonances in one scan window at low field.
maxN = max([nPeaks, nLabel, 4]);
nData = detect_visible_odmr_minima_count(x, y, maxN);
if isfinite(nData) && nData > nPeaks
    nPeaks = nData;
end
end

function n = detect_visible_odmr_minima_count(x, y, maxN)
n = 1;
if nargin < 3 || ~isfinite(maxN) || maxN < 1
    maxN = 4;
end
maxN = max(1, round(maxN));
if numel(x) < 9 || numel(y) < 9
    return;
end

ySmooth = movmean(y, max(5, 2 * floor(numel(y) / 60) + 1));
idx = find(ySmooth(2:end-1) <= ySmooth(1:end-2) & ySmooth(2:end-1) <= ySmooth(3:end)) + 1;
if isempty(idx)
    return;
end

minSepGHz = max((max(x) - min(x)) / max(10 * maxN, 20), 1e-4);
idx = select_minima_with_spacing(idx, ySmooth, x, minSepGHz, max(maxN * 4, 8));
if isempty(idx)
    return;
end

val = ySmooth(idx);
baseline = median(ySmooth);
depth = baseline - val;
depth = depth(isfinite(depth));
if isempty(depth)
    return;
end

% Adaptive visibility threshold:
% keep minima with depth >= 20% of the deepest dip or >= absolute floor.
dMax = max(depth);
dTh = max(0.2 * dMax, 5e-4);
keep = (baseline - val) >= dTh;
nCand = sum(keep);
if nCand <= 0
    nCand = min(numel(idx), 1);
end
n = max(1, min(maxN, nCand));
end

function [fitOut, locErrMetricMHz] = fit_single_lorentz_esr(x, y)
lorentz = @(p, xv) -p(1) .* (p(2)^2 ./ ((xv - p(3)).^2 + p(2)^2)) + p(4);

amp0 = max(y) - min(y);
if ~isfinite(amp0) || amp0 <= 0
    amp0 = eps;
end
width0 = min(max((max(x) - min(x)) / 20, 1e-4), 1e-2);
[~, iMin] = min(y);
loc0 = x(iMin);
bg0 = max(y);

p0 = [amp0, width0, loc0, bg0];
lb = [0, 0, min(x), min(y)];
ub = [max(y), 1e-2, max(x), max(y) * 2];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(lorentz, p0, x, y, lb, ub, opts);
perr = estimate_param_error(y, lorentz(popt, x), jacob, numel(popt));

locMHz = popt(3) * 1000;
locErrMHz = perr(3) * 1000;
contrast = popt(1) / max(popt(4), eps) * 100;
widthMHz = popt(2) * 1000;
widthErrMHz = perr(2) * 1000;

fitOut = struct();
fitOut.model = lorentz;
fitOut.popt = popt;
fitOut.centerMHz = locMHz;
fitOut.fitText = sprintf(['Freqency = %.2f +/- %.2f MHz\nContrast = %.1f %%\n', ...
    'Width = %.2f +/- %.2f MHz'], locMHz, locErrMHz, contrast, widthMHz, widthErrMHz);
locErrMetricMHz = locErrMHz;
end

function [fitOut, locErrMetricMHz] = fit_multi_lorentz_esr(x, y, nPeaks, labels, refsGHz)
lorentzN = @(p, xv) multi_lorentz_sum(p, xv, nPeaks);

centers0 = initial_peak_centers_ghz(x, y, nPeaks, refsGHz);
ampSpan = max(y) - min(y);
if ~isfinite(ampSpan) || ampSpan <= 0
    ampSpan = eps;
end
amp0 = repmat(max(ampSpan / nPeaks, eps), 1, nPeaks);
width0 = min(max((max(x) - min(x)) / max(30 * nPeaks, 20), 1e-4), 1e-2);
w0 = repmat(width0, 1, nPeaks);
bg0 = max(y);

p0 = [amp0, w0, centers0, bg0];

ampUb = max([ampSpan * 2, max(y), eps]);
lb = [zeros(1, nPeaks), zeros(1, nPeaks), repmat(min(x), 1, nPeaks), min(y)];
ub = [repmat(ampUb, 1, nPeaks), repmat(1e-2, 1, nPeaks), repmat(max(x), 1, nPeaks), max(y) * 2];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(lorentzN, p0, x, y, lb, ub, opts);
perr = estimate_param_error(y, lorentzN(popt, x), jacob, numel(popt));

a = popt(1:nPeaks);
w = popt(nPeaks + (1:nPeaks));
c = popt(2 * nPeaks + (1:nPeaks));
bg = popt(end);

cErr = perr(2 * nPeaks + (1:nPeaks));
wErr = perr(nPeaks + (1:nPeaks));

[c, ord] = sort(c, 'ascend');
a = a(ord);
w = w(ord);
cErr = cErr(ord);
wErr = wErr(ord);

if nargin < 4 || ~iscell(labels) || numel(labels) ~= nPeaks
    labels = arrayfun(@(k) sprintf('peak_%d', k), 1:nPeaks, 'UniformOutput', false);
end

labels = labels(:).';
if nargin >= 5 && numel(refsGHz) == nPeaks && all(isfinite(refsGHz))
    [~, iRef] = sort(refsGHz, 'ascend');
    labels = labels(iRef);
end

lines = cell(1, nPeaks);
for i = 1:nPeaks
    contrast = a(i) / max(bg, eps) * 100;
    lines{i} = sprintf('%s: %.2f +/- %.2f MHz (C=%.1f%%, W=%.2f +/- %.2f MHz)', ...
        normalize_to_char(labels{i}), c(i) * 1000, cErr(i) * 1000, ...
        contrast, w(i) * 1000, wErr(i) * 1000);
end

fitOut = struct();
fitOut.model = lorentzN;
fitOut.popt = popt;
fitOut.centerMHz = c(:).' * 1000;
fitOut.fitText = strjoin(lines, sprintf('\n'));

locErrMetricMHz = max(cErr * 1000);
end

function yFit = multi_lorentz_sum(p, x, nPeaks)
a = p(1:nPeaks);
w = p(nPeaks + (1:nPeaks));
c = p(2 * nPeaks + (1:nPeaks));
bg = p(end);
yFit = bg * ones(size(x));
for i = 1:nPeaks
    yFit = yFit - a(i) .* (w(i).^2 ./ ((x - c(i)).^2 + w(i).^2));
end
end

function perr = estimate_param_error(y, yFit, jacob, nParam)
perr = nan(1, nParam);
dof = numel(y) - nParam;
if dof <= 0 || isempty(jacob)
    return;
end
mse = sum((y - yFit).^2) / dof;
pcov = mse * pinv(full(jacob' * jacob));
perr = full(sqrt(max(real(diag(pcov)), 0))).';
end

function centers = initial_peak_centers_ghz(x, y, nPeaks, refsGHz)
if nargin >= 4 && numel(refsGHz) == nPeaks && all(isfinite(refsGHz))
    centers = sort(double(refsGHz(:)).', 'ascend');
    return;
end

ySmooth = movmean(y, max(5, 2 * floor(numel(y) / 60) + 1));
idx = find(ySmooth(2:end-1) <= ySmooth(1:end-2) & ySmooth(2:end-1) <= ySmooth(3:end)) + 1;
if isempty(idx)
    [~, ord] = sort(ySmooth, 'ascend');
    idx = ord(1:min(20, numel(ord)));
end

minSepGHz = max((max(x) - min(x)) / max(10 * nPeaks, 20), 1e-4);
idx = select_minima_with_spacing(idx, ySmooth, x, minSepGHz, max(nPeaks * 4, 6));
found = sort(x(idx), 'ascend');
if isempty(found)
    centers = linspace(min(x), max(x), nPeaks);
    return;
end

if numel(found) >= nPeaks
    centers = found(1:nPeaks);
else
    centers = linspace(min(x), max(x), nPeaks);
    place = round(linspace(1, nPeaks, numel(found)));
    centers(place) = found;
    centers = sort(centers, 'ascend');
end
end

function idxOut = select_minima_with_spacing(idxIn, ySmooth, x, minSepGHz, maxKeep)
[~, ord] = sort(ySmooth(idxIn), 'ascend');
idxSorted = idxIn(ord);
idxOut = [];
for i = 1:numel(idxSorted)
    c = idxSorted(i);
    if isempty(idxOut) || all(abs(x(c) - x(idxOut)) >= minSepGHz)
        idxOut(end+1) = c; %#ok<AGROW>
    end
    if numel(idxOut) >= maxKeep
        break;
    end
end
if isempty(idxOut)
    idxOut = idxIn(1:min(numel(idxIn), maxKeep));
end
end

function n = expected_esr_fit_peak_count(gmSEQ, seqName)
n = 1;
if ~strcmpi(seqName, 'ODMR')
    return;
end
if isfield(gmSEQ, 'ESRFitExpectedPeakCount') && isfinite(gmSEQ.ESRFitExpectedPeakCount)
    n = max(1, round(double(gmSEQ.ESRFitExpectedPeakCount)));
end
end

function out = current_sequence_name(gmSEQ)
out = '';
if ~isstruct(gmSEQ) || ~isfield(gmSEQ, 'name')
    return;
end
out = normalize_to_char(gmSEQ.name);
end

function out = normalize_to_char(in)
if iscell(in)
    if isempty(in)
        out = '';
    else
        out = normalize_to_char(in{1});
    end
elseif isstring(in)
    out = char(in);
elseif ischar(in)
    out = in;
else
    out = char(string(in));
end
end
