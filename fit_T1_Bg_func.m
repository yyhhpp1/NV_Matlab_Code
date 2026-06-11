function [popt, perr, x_plot, y_plot] = fit_T1_Bg_func(x,y)
%%% Input
% x: time in ms
% y: normalzied data
%%% Return 
% popt: optimized parameter
% perr: fit error
% x_plot, y_plot: data for plottinhg the fit

func = @(p, x) p(1)*exp(-p(2)*x)+p(3);

A0 = max(y);
p0 = [2/max(x)];
Bg0 = min(y);
x0 = [A0, p0, Bg0];
lb = [0];
ub = [inf];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(func, x0, x, y, lb, ub, opts);
res = y - func(popt, x);
dof = length(y) - length(popt);
mse = sum(res.^2) / dof;
pcov = mse * inv(jacob' * jacob);
perr = full(sqrt(diag(pcov)));

x_plot = linspace(x(1),x(end),301);
y_plot = func(popt, x_plot);

