function ave_plot_Rabi(handles,raw_j)
global gmSEQ

% Remove NaN (empty data)
for i = 1:gmSEQ.dataN
    signal(i,:) = gmSEQ.signal(i, ~isnan(gmSEQ.signal(i,:)));
end

sig = signal(2,:);
ref = signal(1,:);
data = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;

errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data, data_err, '-')

grid on;
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Fluorescence contrast');
xlabel(handles.axes3, gmSEQ.ScaleStr);
if length(gmSEQ.SweepParam) ~= 1
    xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
end
if raw_j~=0
    xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
end
end
