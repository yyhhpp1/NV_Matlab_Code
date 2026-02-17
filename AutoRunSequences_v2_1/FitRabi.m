function FitRabi(varargin)
global gmSEQ

if nargin == 1
    handles = varargin{1};
    handles2.thrsRabi.String = inf;
else
   handles = varargin{1};
   handles2 = varargin{2};
end

global gmSEQ
cmp = tab10(20);

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1)); %remove nan values
sig = signal(2,:);
ref = signal(1,:);
data = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;

x = double(gmSEQ.SweepParam); %ns
y = data;

if length(x) == length(y)

func = @(p,x) p(1)*cos(2*pi*p(2)*x+p(3))+1-p(1);
% p1 is amp, p2 is freq, p3 phase


amp0 = max(y) - min(y);
%pi_0 = x(C == min(C));
pi0 = max(x)/4;
freq0 = 1/(2*pi0);
phi0 = -0.01;

p0 = [amp0, freq0, phi0];
lb = [0, 0, -pi/2];
ub = [1, inf, pi/2];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(func, p0, x, y, lb, ub, opts);
res = y - func(popt, x);
dof = length(y) - length(popt);
mse = sum(res.^2) / dof;
pcov = mse * inv(jacob' * jacob);
perr = full(sqrt(diag(pcov)));

phi = popt(3); %rad
phi_err = perr(3); %rad
contrast = popt(1)*2*100;
contrast_err = perr(1)*2*100;
freq = popt(2) * 1000; %MHz
freq_err = perr(2) * 1000; %MHz
piTime = (pi - phi)/(2*pi*popt(2));
% piTime_err = sqrt((1/(2*pi*popt(2)))^2*phi_err+((pi-phi)/(2*pi*popt(2)^2))^2*perr(2));
piTime_err = 1/(2*pi*popt(2))*sqrt(perr(3)^2 + (pi - phi)^2/(popt(2)^2)*perr(2)^2);
piHalfTime = (pi/2 - phi)/(2*pi*popt(2));
piHalfTime_err =  1/(2*pi*popt(2))*sqrt(perr(3)^2 + (pi/2 - phi)^2/(popt(2)^2)*perr(2)^2);
fit_text = sprintf('Pi Time = %.1f ± %.1f ns\nPi/2 Time = %.1f ± %.1f ns\nFreq = %.2f ± %.2f MHz\nPhase = %.2f ± %.2f\nC = %.1f ± %.1f%%',...
    piTime, piTime_err, piHalfTime, piHalfTime_err, freq, freq_err, phi, phi_err, contrast, contrast_err);

hold(handles.axes3, 'on');

x_plot = linspace(x(1),x(end),301);
y_plot = func(popt, x_plot);
plot(handles.axes3, x_plot*gmSEQ.ScaleT, y_plot, 'DisplayName', fit_text,...
    'Color', cmp(4,:), 'LineStyle', '-.')

legend(handles.axes3, 'Location', 'best')
hold(handles.axes3, 'off');

gmSEQ.RabiFitPi = piTime; 
gmSEQ.RabiFitPiErr = piTime_err;
gmSEQ.RabiFitFreqMHz = freq;
gmSEQ.RabiFitFreqErrMHz = freq_err;
gmSEQ.RabiFitContrastPct = contrast;

end

end

