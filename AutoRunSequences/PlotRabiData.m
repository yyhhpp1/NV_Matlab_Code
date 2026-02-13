function PlotRabiData(handles,raw_j)
global gmSEQ

%dataN is number of counters
cmp = tab10(20);
colors = {cmp(1,:),cmp(2,:),cmp(3,:)};

for i = 1:gmSEQ.ctrN 
    plot(handles.axes2,...
        single(gmSEQ.SweepParam*gmSEQ.ScaleT),...
        single(gmSEQ.signal(i, :)),'-', ...
        'color', colors{i},...
        'LineWidth', 0.5,...
        'DisplayName', sprintf('signal %d', i))
    if i == 1
       hold(handles.axes2, 'on')
    end
end

grid(handles.axes2, 'on');
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);
xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);

if get(handles.bShowLegend,'Value')
    legend(handles.axes2)
end

% draw vertical dashed line to indicate where is the current measruement
xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes2, 'off')

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1)); %remove nan values
sig = signal(2,:);
ref = signal(1,:);
data = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
if strcmp(gmSEQ.meas, 'APD')
    data_err = rel_err * 0;
else
    data_err = rel_err .* data;
end
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data, data_err,...
    'LineStyle', '-', ...
    'Marker', 'o',...
    'Color', colors{3})
hold(handles.axes3, "on");
grid(handles.axes3, "on");
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Contrast');
xlabel(handles.axes3, gmSEQ.ScaleStr);
xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes3, "off")

end

