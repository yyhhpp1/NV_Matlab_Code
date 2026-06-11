function fit_rabi(varargin)
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
doPlot = true;
if nargin >= 3
    try
        doPlot = logical(varargin{3});
    catch
        doPlot = true;
    end
end

cfg = config();
fitCfg = struct();
if isfield(cfg, 'smart') && isfield(cfg.smart, 'rabiFit')
    fitCfg = cfg.smart.rabiFit;
end
model = read_cfg_text(fitCfg, 'model', 'cos');
model = canonical_rabi_model(model);
minCos = read_cfg_num(fitCfg, 'minPointsCos', 4);
minCosExp = read_cfg_num(fitCfg, 'minPointsCosExp', 5);

status = struct('ok', false, 'model', model, 'validN', 0, 'nRequired', 0, 'msg', '');

% Prevent stale values when fit is skipped/failed.
gmSEQ.RabiFitPi = NaN;
gmSEQ.RabiFitPiErr = NaN;
gmSEQ.RabiFitPiHalf = NaN;
gmSEQ.RabiFitPiHalfErr = NaN;
gmSEQ.RabiFitThreeHalfPi = NaN;
gmSEQ.RabiFitThreeHalfPiErr = NaN;
gmSEQ.RabiFitFreqMHz = NaN;
gmSEQ.RabiFitFreqErrMHz = NaN;
gmSEQ.RabiFitContrastPct = NaN;

if ~isfield(gmSEQ, 'signal') || size(gmSEQ.signal, 1) < 2 || ~isfield(gmSEQ, 'SweepParam')
    status.msg = 'Fit skipped: Rabi data unavailable';
    gmSEQ.RabiFitLastStatus = status;
    return;
end

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1));
if size(signal, 1) < 2 || isempty(signal)
    status.msg = 'Fit skipped: Rabi data unavailable';
    gmSEQ.RabiFitLastStatus = status;
    return;
end

sig = signal(2,:);
ref = signal(1,:);
y = sig ./ ref;
x = double(gmSEQ.SweepParam(1:numel(y))); % ns

valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
status.validN = numel(x);

if strcmp(model, 'cos_exp')
    nRequired = max(5, round(minCosExp));
else
    nRequired = max(4, round(minCos));
end
status.nRequired = nRequired;

if numel(x) < nRequired || (max(x) - min(x)) <= 0
    status.msg = sprintf('Fit skipped: %d valid points (<%d required)', numel(x), nRequired);
    gmSEQ.RabiFitLastStatus = status;
    return;
end

[x, ord] = sort(x, 'ascend');
y = y(ord);

amp0 = max(y) - min(y);
if ~isfinite(amp0) || amp0 <= 0
    amp0 = eps;
end
pi0 = max(x) / 4;
if ~isfinite(pi0) || pi0 <= 0
    pi0 = max((max(x)-min(x))/4, eps);
end
freq0 = 1 / max(2*pi0, eps);
phi0 = -0.01;
span = max(x) - min(x);

cmp = tab10(20);

try
    if strcmp(model, 'cos_exp')
        tau0 = max(span / 2, 600);
        func = @(p, xv) p(1) .* exp(-xv ./ max(p(4), eps)) .* cos(2*pi*p(2).*xv + p(3)) + 1 - p(1);
        p0 = [amp0, freq0, phi0, tau0];
        lb = [0, 0, -pi/2, max(400, span/1000)];
        ub = [1, inf, pi/2, max(10*span, 1e3)];
    else
        func = @(p, xv) p(1) .* cos(2*pi*p(2).*xv + p(3)) + 1 - p(1);
        p0 = [amp0, freq0, phi0];
        lb = [0, 0, -pi/2];
        ub = [1, inf, pi/2];
    end

    opts = optimoptions('lsqcurvefit', 'Display', 'off');
    [popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(func, p0, x, y, lb, ub, opts);

    res = y - func(popt, x);
    dof = numel(y) - numel(popt);
    perr = nan(size(popt));
    if dof > 0 && ~isempty(jacob)
        mse = sum(res.^2) / dof;
        pcov = mse * pinv(full(jacob' * jacob));
        perr = full(sqrt(max(real(diag(pcov)), 0))).';
    end

    phi = popt(3);
    freq = popt(2) * 1000; % MHz
    freq_err = perr(2) * 1000; % MHz
    contrast = popt(1) * 2 * 100;

    [piTime, thetaPi] = solve_target_time_ns(popt(2), phi, pi, min(x));
    [piHalfTime, thetaPiHalf] = solve_target_time_ns(popt(2), phi, pi/2, min(x));
    [threeHalfPiTime, thetaThreeHalfPi] = solve_target_time_ns(popt(2), phi, 3*pi/2, min(x));

    if isfinite(popt(2)) && popt(2) > 0
        dtdphi = 1 / (2*pi*popt(2));
        dtdf_pi = thetaPi / (2*pi*popt(2)^2);
        dtdf_half = thetaPiHalf / (2*pi*popt(2)^2);
        dtdf_threehalf = thetaThreeHalfPi / (2*pi*popt(2)^2);
        piTime_err = sqrt((dtdphi * perr(3))^2 + (dtdf_pi * perr(2))^2);
        piHalfTime_err = sqrt((dtdphi * perr(3))^2 + (dtdf_half * perr(2))^2);
        threeHalfPiTime_err = sqrt((dtdphi * perr(3))^2 + (dtdf_threehalf * perr(2))^2);
    else
        piTime_err = NaN;
        piHalfTime_err = NaN;
        threeHalfPiTime_err = NaN;
    end

    if strcmp(model, 'cos_exp')
        fit_text = sprintf(['Pi Time = %.1f +/- %.1f ns\nPi/2 Time = %.1f +/- %.1f ns\n3Pi/2 Time = %.1f +/- %.1f ns\n', ...
            'Freq = %.2f +/- %.2f MHz\nTau = %.1f ns\nPhase = %.2f +/- %.2f\nC = %.1f %%'], ...
            piTime, piTime_err, piHalfTime, piHalfTime_err, threeHalfPiTime, threeHalfPiTime_err, ...
            freq, freq_err, popt(4), phi, perr(3), contrast);
    else
        fit_text = sprintf(['Pi Time = %.1f +/- %.1f ns\nPi/2 Time = %.1f +/- %.1f ns\n3Pi/2 Time = %.1f +/- %.1f ns\n', ...
            'Freq = %.2f +/- %.2f MHz\nPhase = %.2f +/- %.2f\nC = %.1f %%'], ...
            piTime, piTime_err, piHalfTime, piHalfTime_err, threeHalfPiTime, threeHalfPiTime_err, ...
            freq, freq_err, phi, perr(3), contrast);
    end

    if doPlot
        hold(handles.axes3, 'on');
        delete(findobj(handles.axes3, 'Tag', 'rabi_fit_line'));
        x_plot = linspace(x(1), x(end), 301);
        y_plot = func(popt, x_plot);
        plot(handles.axes3, x_plot*gmSEQ.ScaleT, y_plot, 'DisplayName', fit_text, ...
            'Color', cmp(4,:), 'LineStyle', '-.', 'Tag', 'rabi_fit_line');

        if get(handles.bShowLegend, 'Value')
            legend(handles.axes3, 'Location', 'best');
        end
        hold(handles.axes3, 'off');
    end

    gmSEQ.RabiFitPi = piTime;
    gmSEQ.RabiFitPiErr = piTime_err;
    gmSEQ.RabiFitPiHalf = piHalfTime;
    gmSEQ.RabiFitPiHalfErr = piHalfTime_err;
    gmSEQ.RabiFitThreeHalfPi = threeHalfPiTime;
    gmSEQ.RabiFitThreeHalfPiErr = threeHalfPiTime_err;
    gmSEQ.RabiFitFreqMHz = freq;
    gmSEQ.RabiFitFreqErrMHz = freq_err;
    gmSEQ.RabiFitContrastPct = contrast;

    status.ok = true;
    status.msg = '';
catch ME
    status.msg = ['Fit skipped: ' ME.message];
end

gmSEQ.RabiFitLastStatus = status;

if ~isempty(handles2) && isfield(handles2, 'thrsRabi') && isgraphics(handles2.thrsRabi, 'uicontrol')
    % Keep backward compatibility with GUI threshold control.
    th = str2double(get(handles2.thrsRabi, 'String')); %#ok<NASGU>
end

end

function model = canonical_rabi_model(model)
model = lower(strtrim(char(model)));
switch model
    case {'cos', 'plain', 'cosine'}
        model = 'cos';
    case {'cos_exp', 'cosexp', 'damped', 'damped_cos'}
        model = 'cos_exp';
    otherwise
        model = 'cos';
end
end

function [t, theta] = solve_target_time_ns(freqPerNs, phi, targetPhase, tMin)
% Solve 2*pi*f*t + phi = targetPhase + 2*pi*k and return earliest t>=tMin.
t = NaN;
theta = NaN;
if ~isfinite(freqPerNs) || freqPerNs <= 0 || ~isfinite(phi)
    return;
end
k = ceil((2*pi*freqPerNs*tMin + phi - targetPhase) / (2*pi));
theta = targetPhase - phi + 2*pi*k;
t = theta / (2*pi*freqPerNs);
if t < tMin
    k = k + 1;
    theta = targetPhase - phi + 2*pi*k;
    t = theta / (2*pi*freqPerNs);
end
end

function v = read_cfg_text(s, key, defaultVal)
v = defaultVal;
if isstruct(s) && isfield(s, key)
    tmp = s.(key);
    if ischar(tmp) || isstring(tmp)
        v = char(tmp);
    end
end
end

function v = read_cfg_num(s, key, defaultVal)
v = defaultVal;
if isstruct(s) && isfield(s, key)
    tmp = s.(key);
    if isnumeric(tmp) && isscalar(tmp) && isfinite(tmp)
        v = tmp;
    end
end
end
