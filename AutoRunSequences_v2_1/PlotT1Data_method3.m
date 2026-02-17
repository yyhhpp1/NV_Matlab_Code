function PlotT1Data_method3(handles,raw_j)
% use on T1_S11_S1m1

global gmSEQ

%dataN is number of counters
cmp = tab10(10);
colors = {cmp(1,:),cmp(2,:),cmp(3,:),cmp(4,:),cmp(5,:),cmp(6,:),cmp(7,:)};
labels = ["S_{-1,-1}","S_{-1,+1}", "Ref_B","Ref_D"];
ctrShow = [2,5];%S11, S1m1
refB_mean = (gmSEQ.signal(1, :)+gmSEQ.signal(4, :))/2;
refD_mean = (gmSEQ.signal(3, :)+gmSEQ.signal(6, :))/2;
ct = 1;
for i = ctrShow
    plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(gmSEQ.signal(i, :)),'-', ...
        'color', colors{ct},...
        'LineWidth', 0.5,...
        'DisplayName', labels(ct))
    
    if ct == 1; hold(handles.axes2, 'on'); end
    ct = ct + 1;
end

plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refB_mean),'--', ...
        'color', colors{3},...
        'LineWidth', 0.5,...
        'DisplayName', labels(3))
plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refD_mean),'--', ...
        'color', colors{4},...
        'LineWidth', 0.5,...
        'DisplayName', labels(4))



grid(handles.axes2, 'on');
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);
xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);

% draw vertical dashed line to indicate where is the current measruement
xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes2, 'off')

for jj = 1:length(gmSEQ.signal(:,1))
    signal(jj,:) = gmSEQ.signal(jj, ~isnan(gmSEQ.signal(jj,:)));
end

refB11 = signal(1,:);
sig11 = signal(2,:);
refD11 = signal(3,:);
refB1m1 = signal(4,:);
sig1m1 = signal(5,:);
refD1m1 = signal(6,:);

%S11-S1m1
sig = sig11 - sig1m1;
%ref = (refB11+refB1m1)/2 - (refD11+refD1m1)/2;
ref = (refB11+refB1m1)/2;
data = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref)); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig)); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;


cmp2 = tab20(20);

plot(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data,...
    'LineStyle', '-',...
    'Marker', 'square',...
    'Color', cmp2(3,:),...
    'DisplayName', 'C_{-1,-1}-C_{-1,+1}')

grid(handles.axes3, "on");
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Contrast');
xlabel(handles.axes3, gmSEQ.ScaleStr);
xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes3, "off")

if get(handles.bShowLegend,'Value')
    legend(handles.axes2, 'Location', 'best')
    legend(handles.axes3, 'Location', 'best')

    
    x1 = double(gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT); %ms
    y1 = data;
    [popt1, perr1, x1_plot, y1_plot] = fit_T1_func(x1, y1);
    fit1_text = sprintf('\\Omega + 2\\gamma = %.1f \\pm %.1f Hz', popt1(1)*1000, perr1(1)*1000);
    if isfield(gmSEQ, 'T1FitLastStatus') && isstruct(gmSEQ.T1FitLastStatus) ...
            && isfield(gmSEQ.T1FitLastStatus, 'ok') && ~gmSEQ.T1FitLastStatus.ok
        fit1_text = gmSEQ.T1FitLastStatus.msg;
    end
    

    hold(handles.axes3, 'on');

    if isempty(x1_plot) || isempty(y1_plot)
        plot(handles.axes3, nan, nan,...
            'DisplayName', fit1_text,...
            'Color', cmp2(4,:),...
            'LineStyle', '-.')
    else
        plot(handles.axes3, x1_plot, y1_plot,...
            'DisplayName', fit1_text,...
            'Color', cmp2(4,:),...
            'LineStyle', '-.')
    end
    
    legend(handles.axes3, 'Location', 'best')
    hold(handles.axes3, 'off');
end

end

