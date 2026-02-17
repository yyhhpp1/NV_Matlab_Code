function [popt, perr, x_plot, y_plot] = fit_T1_stretched_func(x,y,fitCfg)
%%% Stretched exponential fit
% Model: y = A * exp(-(r*x)^n)
% Parameters: p = [r, A, n]

if nargin < 3 || ~isstruct(fitCfg)
    fitCfg = struct();
end

nLower = get_cfg_value(fitCfg, 'nLower', 0.5);
nUpper = get_cfg_value(fitCfg, 'nUpper', 3.0);
ampUpper = get_cfg_value(fitCfg, 'amplitudeUpper', 1.0);

if ~isfinite(nLower); nLower = 0.5; end
if ~isfinite(nUpper) || nUpper <= nLower; nUpper = max(nLower + 0.1, 3.0); end
if ~isfinite(ampUpper) || ampUpper <= 0; ampUpper = 1.0; end

nFitParam = 3; % [rate, amplitude, stretch]
[popt, perr, x_plot, y_plot, x, y] = init_fit_outputs(x, y, nFitParam);
if numel(x) < (nFitParam + 1)
    return;
end

func = @(p, xv) p(2) .* exp(-(max(p(1), eps) .* xv) .^ p(3));

% Ensure feasible initial point and bounds.
yMax = max(y);
ampUpper = max([ampUpper, 1.2 * max(yMax, 0), eps]);
a0 = max(yMax, eps);
a0 = min(a0, 0.95 * ampUpper);
r0 = 2 / max(max(x), eps);
r0 = max(r0, eps);
n0 = min(max(1.0, nLower), nUpper);
p0 = [r0, a0, n0];
lb = [0, 0, nLower];
ub = [inf, ampUpper, nUpper];

[popt, perr] = run_lsq_fit(func, p0, x, y, lb, ub);
x_plot = linspace(x(1), x(end), 301);
y_plot = func(popt, x_plot);

end

function [val] = get_cfg_value(s, fieldName, defaultVal)
val = defaultVal;
if isstruct(s) && isfield(s, fieldName)
    tmp = s.(fieldName);
    if ~isempty(tmp)
        val = tmp;
    end
end
end

function [popt, perr, x_plot, y_plot, x, y] = init_fit_outputs(xIn, yIn, nFitParam)
popt = nan(1, nFitParam);
perr = nan(1, nFitParam);
x_plot = [];
y_plot = [];

x = double(xIn(:));
y = double(yIn(:));
valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
[x, order] = sort(x, 'ascend');
y = y(order);
end

function [popt, perr] = run_lsq_fit(func, p0, x, y, lb, ub)
opts = optimoptions('lsqcurvefit', 'Display', 'off');
[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(func, p0, x, y, lb, ub, opts);

perr = nan(size(popt));
res = y - func(popt, x);
dof = numel(y) - numel(popt);
if dof > 0 && ~isempty(jacob)
    mse = sum(res.^2) / dof;
    jtj = full(jacob' * jacob);
    pcov = mse * pinv(jtj);
    perr = full(sqrt(max(real(diag(pcov)), 0))).';
end
end
