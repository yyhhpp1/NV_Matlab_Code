function FitESR(varargin)
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

cfg = AutoPipelineConfig();
minPoints = 5;
if isfield(cfg, 'smart') && isfield(cfg.smart, 'esrFit') && ...
        isfield(cfg.smart.esrFit, 'minPoints')
    minPoints = max(5, round(cfg.smart.esrFit.minPoints));
end

status = struct('ok', false, 'validN', 0, 'nRequired', minPoints, 'msg', '');

gmSEQ.ESRFitFreq = NaN; % prevent stale values when fit is skipped/failed

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
if numel(x) < minPoints || (max(x) - min(x)) <= 0
    status.msg = sprintf('Fit skipped: %d valid points (<%d required)', numel(x), minPoints);
    gmSEQ.ESRFitLastStatus = status;
    return;
end

lorentz = @(p, xv) -p(1) .* (p(2)^2 ./ ((xv - p(3)).^2 + p(2)^2)) + p(4);
% p = [amp, width, center, bg]

amp0 = max(y) - min(y);
if ~isfinite(amp0) || amp0 <= 0
    amp0 = eps;
end
width0 = min(max((max(x) - min(x))/20, 1e-4), 1e-2);
[~, iMin] = min(y);
loc0 = x(iMin);
bg0 = max(y);

p0 = [amp0, width0, loc0, bg0];
lb = [0, 0, min(x), min(y)];
ub = [max(y), 1e-2, max(x), max(y)*2];

try
    opts = optimoptions('lsqcurvefit', 'Display', 'off');
    [popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(lorentz, p0, x, y, lb, ub, opts);

    res = y - lorentz(popt, x);
    dof = numel(y) - numel(popt);
    perr = nan(size(popt));
    if dof > 0 && ~isempty(jacob)
        mse = sum(res.^2) / dof;
        pcov = mse * pinv(full(jacob' * jacob));
        perr = full(sqrt(max(real(diag(pcov)), 0))).';
    end

    loc = popt(3) * 1000; % MHz
    loc_err = perr(3) * 1000; % MHz
    contrast = popt(1) / max(popt(4), eps) * 100;
    width = popt(2) * 1000; % MHz
    width_err = perr(2) * 1000; % MHz

    fit_text = sprintf(['Freqency = %.2f +/- %.2f MHz\nContrast = %.1f %%\n', ...
        'Width = %.2f +/- %.2f MHz'], loc, loc_err, contrast, width, width_err);

    hold(handles.axes3, 'on');
    x_plot = linspace(x(1), x(end), 301);
    y_plot = lorentz(popt, x_plot);
    plot(handles.axes3, x_plot, y_plot, 'DisplayName', fit_text);

    if get(handles.bShowLegend, 'Value')
        legend(handles.axes3, 'Location', 'best');
    end
    hold(handles.axes3, 'off');

    gmSEQ.ESRFitFreq = loc; % MHz
    status.ok = true;
    status.msg = '';

    if ~isempty(handles2) && isfield(handles2, 'thrsESR') && isgraphics(handles2.thrsESR, 'uicontrol')
        th = str2double(get(handles2.thrsESR, 'String'));
        if isfinite(th) && loc_err <= th
            gmSEQ.bGoAfterAvg = 0;
        end
    end
catch ME
    status.msg = ['Fit skipped: ' ME.message];
end

gmSEQ.ESRFitLastStatus = status;
end