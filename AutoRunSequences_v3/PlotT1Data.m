function PlotT1Data(handles,raw_j)
global gmSEQ

%dataN is number of counters
cmp = tab10(10);
colors = {cmp(1,:),cmp(2,:),cmp(3,:),cmp(4,:),cmp(5,:),cmp(6,:)};
labels = ["S00","S01","S10","S11","RefB","RefD"];
ctrShow = [2,5,8,11];%S00, S01, S10, S11
refB_mean = (gmSEQ.signal(1, :)+gmSEQ.signal(4, :)+gmSEQ.signal(7, :)+gmSEQ.signal(10, :))/4;
refD_mean = (gmSEQ.signal(3, :)+gmSEQ.signal(6, :)+gmSEQ.signal(9, :)+gmSEQ.signal(12, :))/4;
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
        single(refB_mean),'-', ...
        'color', colors{5},...
        'LineWidth', 0.5,...
        'DisplayName', labels(5))
plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refD_mean),'-', ...
        'color', colors{6},...
        'LineWidth', 0.5,...
        'DisplayName', labels(6))



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

%S00-S01
sig = sig00 - sig01;
ref = (refB00+refB01)/2 - (refD00+refD01)/2;
data1 = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref));
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig));
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data1_err = rel_err .* data1;


%S11-S10
sig = sig11 - sig10;
ref = (refB10+refB11)/2 - (refD10+refD11)/2;
data2 = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref)); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig)); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data2_err = rel_err .* data2;



errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data1, data1_err,...
    'LineStyle', '-',...
    'Marker', 'o',...
    'Color', cmp(7,:),...
    'DisplayName', 'S00-S01')
hold(handles.axes3, "on");
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data2)).*gmSEQ.ScaleT, data2, data2_err,...
    'LineStyle', '-',...
    'Marker', 'square',...
    'Color', cmp(10,:),...
    'DisplayName', 'S11-S10')

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
end

end

