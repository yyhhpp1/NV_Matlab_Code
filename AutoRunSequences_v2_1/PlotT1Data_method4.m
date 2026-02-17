function PlotT1Data_method4(handles,raw_j)
% use on T1_S11_S1m1

global gmSEQ

%dataN is number of counters
cmp = tab10(10);
colors = {cmp(1,:),cmp(2,:),cmp(3,:),cmp(4,:),cmp(5,:),cmp(6,:),cmp(7,:)};
labels = ["S_{0,0}","S_{0,-1}","S_{-1,0}", "Ref_B","Ref_D"];
ctrShow = [2,5,8];%S11, S1m1
refB_mean = (gmSEQ.signal(1, :)+gmSEQ.signal(4, :)+gmSEQ.signal(7, :))/3;
refD_mean = (gmSEQ.signal(3, :)+gmSEQ.signal(6, :)+gmSEQ.signal(9, :))/3;
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

refB00 = signal(1,:);
sig00 = signal(2,:);
refD00 = signal(3,:);
refB01 = signal(4,:);
sig01 = signal(5,:);
refD01 = signal(6,:);
refB10 = signal(7,:);
sig10 = signal(8,:);
refD10 = signal(9,:);

%S11-S1m1
sig = sig00 - sig01;
ref = (refB00+refB01)/2;
data = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref)); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig)); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;
if strcmp(gmSEQ.meas,'APD')
    data_err = rel_err .* 0;
end


cmp2 = tab20(20);

errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data, data_err,...
    'LineStyle', '-',...
    'Marker', 'square',...
    'Color', cmp2(1,:),...
    'DisplayName', 'C_{0,0}-C_{0,-1}')

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
    fit1_text = sprintf('3\\Omega = %.1f \\pm %.1f Hz', popt1(1)*1000, perr1(1)*1000);
    if isfield(gmSEQ, 'T1FitLastStatus') && isstruct(gmSEQ.T1FitLastStatus) ...
            && isfield(gmSEQ.T1FitLastStatus, 'ok') && ~gmSEQ.T1FitLastStatus.ok
        fit1_text = gmSEQ.T1FitLastStatus.msg;
    end
    

    hold(handles.axes3, 'on');

    if isempty(x1_plot) || isempty(y1_plot)
        plot(handles.axes3, nan, nan,...
            'DisplayName', fit1_text,...
            'Color', cmp2(2,:),...
            'LineStyle', '-.')
    else
        plot(handles.axes3, x1_plot, y1_plot,...
            'DisplayName', fit1_text,...
            'Color', cmp2(2,:),...
            'LineStyle', '-.')
    end
    
    legend(handles.axes3, 'Location', 'best')
    hold(handles.axes3, 'off');
end

end

