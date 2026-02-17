function [popt, perr, x_plot, y_plot] = fit_T1_func(x,y)
%%% Input
% x: time in ms
% y: normalized data
%%% Return
% popt: optimized parameters
% perr: fit parameter error estimate
% x_plot, y_plot: fit curve for plotting

global gmSEQ

model = 'single_exp';
fitCfg = struct();
if ~isempty(gmSEQ) && isstruct(gmSEQ)
    if isfield(gmSEQ, 'T1FitModel') && ~isempty(gmSEQ.T1FitModel)
        model = lower(strtrim(char(gmSEQ.T1FitModel)));
    end
    if isfield(gmSEQ, 'T1FitCfg') && isstruct(gmSEQ.T1FitCfg)
        fitCfg = gmSEQ.T1FitCfg;
    end
end

validN = sum(isfinite(x(:)) & isfinite(y(:)));
if any(strcmp(model, {'stretched_exp', 'stretched', 'stretched_exponential'}))
    nRequired = 4; % nFitParam(3)+1
else
    nRequired = 3; % nFitParam(2)+1
end

switch model
    case {'stretched_exp', 'stretched', 'stretched_exponential'}
        nParam = 3;
    otherwise
        nParam = 2;
end

errMsg = '';
try
    switch model
        case {'stretched_exp', 'stretched', 'stretched_exponential'}
            [popt, perr, x_plot, y_plot] = fit_T1_stretched_func(x, y, fitCfg);
        otherwise
            [popt, perr, x_plot, y_plot] = fit_T1_single_exp_local(x, y, fitCfg);
    end
catch ME
    popt = nan(1, nParam);
    perr = nan(1, nParam);
    x_plot = [];
    y_plot = [];
    errMsg = ME.message;
end

status = struct();
status.model = model;
status.validN = validN;
status.nRequired = nRequired;
status.ok = ~isempty(x_plot) && all(isfinite(popt));
if ~isempty(errMsg)
    status.ok = false;
    status.msg = ['Fit skipped: ' errMsg];
elseif status.ok
    status.msg = '';
elseif validN < nRequired
    status.msg = sprintf('Fit skipped: %d valid points (<%d required)', validN, nRequired);
else
    status.msg = 'Fit skipped: fit did not converge';
end
if ~isempty(gmSEQ) && isstruct(gmSEQ)
    gmSEQ.T1FitLastStatus = status;
end

end

function [popt, perr, x_plot, y_plot] = fit_T1_single_exp_local(x, y, fitCfg)
ampUpper = get_cfg_value(fitCfg, 'amplitudeUpper', 1.0);
if ~isfinite(ampUpper) || ampUpper <= 0
    ampUpper = 1.0;
end

nFitParam = 2; % [rate, amplitude]
[popt, perr, x_plot, y_plot, x, y] = init_fit_outputs(x, y, nFitParam);
if numel(x) < (nFitParam + 1)
    return;
end

func = @(p, xv) p(2) .* exp(-p(1) .* xv);
% Ensure feasible initial point and bounds.
yMax = max(y);
ampUpper = max([ampUpper, 1.2 * max(yMax, 0), eps]);
a0 = max(yMax, eps);
a0 = min(a0, 0.95 * ampUpper);
r0 = 2 / max(max(x), eps);
r0 = max(r0, eps);
p0 = [r0, a0];
lb = [0, 0];
ub = [inf, ampUpper];

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
