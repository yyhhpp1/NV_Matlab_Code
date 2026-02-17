function PlotT1DataAveCharge(handles,raw_j)
% use on T1_charge_calib

global gmSEQ

%dataN is number of counters
cmp = tab10(10);
colors = {cmp(1,:),cmp(2,:),cmp(3,:),cmp(4,:),cmp(5,:)};
labels = ["S_{00}","S_{10}","S_{-10}", "Ref_B","Ref_D"];
ctrShow = [2,5,8];%S0, Sm1, S1
refB_mean = (gmSEQ.signal(1, :)+gmSEQ.signal(4, :)+gmSEQ.signal(7, :)) / 3;
refD_mean = (gmSEQ.signal(3, :)+gmSEQ.signal(6, :)+gmSEQ.signal(9, :)) / 3;
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
        'color', colors{4},...
        'LineWidth', 0.5,...
        'DisplayName', labels(4))
plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refD_mean),'--', ...
        'color', colors{5},...
        'LineWidth', 0.5,...
        'DisplayName', labels(5))



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

refB10 = signal(7,:);
sig00 = signal(2,:);
refD00 = signal(3,:);
refB00 = signal(4,:);
sigm10 = signal(8,:);
refDm10 = signal(9,:);
refBm10 = signal(1,:);
sig10 = signal(5,:);
refD10 = signal(6,:);


ref00 = refB00;
refm10 = refBm10;
ref10 = refB10;

data1 = sig00 ./ refB00;    % S0
data2 = sigm10 ./ refBm10;  % Sm1 
data3 = sig10 ./ refB10;    % S1

ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref00));
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig00));
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data1_err = rel_err .* data1;

ref_err = 1./sqrt(gmSEQ.iAverage * abs(refm10));
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sigm10));
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data2_err = rel_err .* data2;

ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref10));
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig10));
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data3_err = rel_err .* data3;




cmp2 = tab20(20);
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data1, data1_err,...
    'LineStyle', '-',...
    'Marker', 'o',...
    'Color', cmp2(1,:),...
    'DisplayName', 'S_{0}/R_{0}')
hold(handles.axes3, "on");
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data2)).*gmSEQ.ScaleT, data2, data2_err,...
    'LineStyle', '-',...
    'Marker', 'square',...
    'Color', cmp2(3,:),...
    'DisplayName', 'S_{-1}/R_{-1}')
hold(handles.axes3, "on");
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data3)).*gmSEQ.ScaleT, data3, data3_err,...
    'LineStyle', '-',...
    'Marker', 'square',...
    'Color', cmp2(5,:),...
    'DisplayName', 'S_{1}/R_{1}')




grid(handles.axes3, "on");
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Normalized PL');
xlabel(handles.axes3, gmSEQ.ScaleStr);
xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes3, "off")

if get(handles.bShowLegend,'Value')
    legend(handles.axes2, 'Location', 'best')
    legend(handles.axes3, 'Location', 'best')

    hold(handles.axes3, "on")

    
    x1 = double(gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT); %ms
    y1 = data1;
    [popt1, perr1, x1_plot, y1_plot] = fit_T1_func(x1, y1);
        fit1_text = sprintf([ ...
            'C_{00}: k = %.2f \\pm %.2f kHz' ...
            popt1(1), perr1(1)]);    % ν1+ν2
    x2 = double(gmSEQ.SweepParam(1:length(data2)).*gmSEQ.ScaleT); %ms
    y2 = data2;
    [popt2, perr2, x2_plot, y2_plot] = fit_T1_func(x2, y2);  
    fit2_text = sprintf([ ...
        'C_{10}: k = %.2f \\pm %.2f kHz' ...
        popt2(1), perr2(1)]);    % ν1+ν2
    x3 = double(gmSEQ.SweepParam(1:length(data3)).*gmSEQ.ScaleT); %ms
    y3 = data3;
    [popt3, perr3, x3_plot, y3_plot] = fit_T1_func(x3, y3); 
    fit3_text = sprintf([ ...
        'C_{-10}: k = %.2f \\pm %.2f kHz' ...
        popt3(1), perr3(1)]);    % ν1+ν2
    
%     if ~isempty(popt1)
        plot(handles.axes3, x1_plot, y1_plot,...
            'DisplayName', fit1_text,...
            'Color', cmp2(2,:),...
            'LineStyle', '-.')

        plot(handles.axes3, x2_plot, y2_plot,...
            'DisplayName', fit2_text,...
            'Color', cmp2(4,:),...
            'LineStyle', '-.')
        plot(handles.axes3, x3_plot, y3_plot,...
            'DisplayName', fit3_text,...
            'Color', cmp2(6,:),...
            'LineStyle', '-.')

        legend(handles.axes3, 'Location', 'best')
        hold(handles.axes3, 'off');
%     end 
end

end

