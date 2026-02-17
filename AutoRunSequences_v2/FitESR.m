function FitESR(varargin)
global gmSEQ

if nargin == 1
    handles = varargin{1};
    handles2.thrsESR.String = inf;
else
   handles = varargin{1};
   handles2 = varargin{2};
end

x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
y = double(gmSEQ.signal(2, :))./ double(gmSEQ.signal(1, :));

lorentz = @(p,x) - p(1) * (p(2)^2 ./ ((x - p(3)).^2 + p(2)^2)) + p(4);
% p1 is amp, p2 is width, p3 is loc, p4 is bg

amp0 = max(y) - min(y); 
width0 = 5e-3; %GHz
loc0 = x(y == min(y));
bg0 = max(y);
p0 = [amp0, width0, loc0, bg0];
lb = [0, 0, min(x), min(y)];
ub = [max(y), 1e-2, max(x), max(y)*2];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(lorentz, p0, x, y, lb, ub, opts);
res = y - lorentz(popt, x);
dof = length(y) - length(popt);
mse = sum(res.^2) / dof;
pcov = mse * inv(jacob' * jacob);
perr = full(sqrt(diag(pcov)));

loc = popt(3) * 1000; %MHz
loc_err = perr(3) * 1000; %MHz
contrast = popt(1)/popt(4)*100;
width = popt(2) * 1000; %MHz
width_err = perr(2) * 1000; %MHz
fit_text = sprintf('Freqency = %.2f ± %.2f MHz\nContrast = %.1f %%\nWidth = %.2f ± %.2f MHz',...
    loc, loc_err, contrast, width, width_err);

hold(handles.axes3, 'on');

x_plot = linspace(x(1),x(end),301);
y_plot = lorentz(popt, x_plot);
plot(handles.axes3, x_plot, y_plot, 'DisplayName', fit_text)

if get(handles.bShowLegend,'Value')
    legend(handles.axes3, 'Location', 'best')
end

hold(handles.axes3, 'off'); 

gmSEQ.ESRFitFreq =  loc; %in MHz
if loc_err <= str2double(handles2.thrsESR.String)
   gmSEQ.bGoAfterAvg = 0;
end
  

end

