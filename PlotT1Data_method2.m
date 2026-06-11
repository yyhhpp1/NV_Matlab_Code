function PlotT1Data_method2(handles,raw_j)
% use on T1_S00_S01_S10_S11_S1m1

global gmSEQ

%dataN is number of counters
cmp = tab10(10);
colors = {cmp(1,:),cmp(2,:),cmp(3,:),cmp(4,:),cmp(5,:),cmp(6,:),cmp(7,:)};
labels = ["S_{0,0}","S_{0,-1}","S_{-1,0}","S_{-1,-1}","S_{-1,+1}", "Ref_B","Ref_D"];
ctrShow = [2,5,8,11,14];%S00, S01, S10, S11, S1m1
refB_mean = (gmSEQ.signal(1, :)+gmSEQ.signal(4, :)+gmSEQ.signal(7, :)...
    +gmSEQ.signal(10, :)+gmSEQ.signal(13, :))/5;
refD_mean = (gmSEQ.signal(3, :)+gmSEQ.signal(6, :)+gmSEQ.signal(9, :)...
    +gmSEQ.signal(12, :)+gmSEQ.signal(15, :))/5;
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
        'color', colors{6},...
        'LineWidth', 0.5,...
        'DisplayName', labels(6))
plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refD_mean),'--', ...
        'color', colors{7},...
        'LineWidth', 0.5,...
        'DisplayName', labels(7))



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
refB11 = signal(10,:);
sig11 = signal(11,:);
refD11 = signal(12,:);
refB1m1 = signal(13,:);
sig1m1 = signal(14,:);
refD1m1 = signal(15,:);

%S00-S01
sig = sig00 - sig01;
ref = (refB00+refB01)/2 - (refD00+refD01)/2;
data1 = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref));
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig));
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data1_err = rel_err .* data1;


%S11-S1m1
sig = sig11 - sig1m1;
ref = (refB11+refB1m1)/2 - (refD11+refD1m1)/2;
data2 = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref)); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig)); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data2_err = rel_err .* data2;


cmp2 = tab20(20);
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data1, data1_err,...
    'LineStyle', '-',...
    'Marker', 'o',...
    'Color', cmp2(1,:),...
    'DisplayName', 'C_{0,0}-C_{0,-1}')
hold(handles.axes3, "on");
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data2)).*gmSEQ.ScaleT, data2, data2_err,...
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

    
    
    x1 = double(gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT); %ms
    y1 = data1;
    [popt1, perr1, x1_plot, y1_plot] = fit_T1_func(x1, y1);
    fit1_text = sprintf('3\\Omega = %.2f \\pm %.2f kHz', popt1, perr1);
    
    
    x2 = double(gmSEQ.SweepParam(1:length(data2)).*gmSEQ.ScaleT); %ms
    y2 = data2;
    [popt2, perr2, x2_plot, y2_plot] = fit_T1_func(x2, y2);  
    fit2_text = sprintf('\\Omega + 2\\gamma = %.2f \\pm %.2f kHz', popt2, perr2);

    hold(handles.axes3, 'on');

    plot(handles.axes3, x1_plot, y1_plot,...
        'DisplayName', fit1_text,...
        'Color', cmp2(2,:),...
        'LineStyle', '-.')

    plot(handles.axes3, x2_plot, y2_plot,...
        'DisplayName', fit2_text,...
        'Color', cmp2(4,:),...
        'LineStyle', '-.')
    
    legend(handles.axes3, 'Location', 'best')
    hold(handles.axes3, 'off');
end

end

