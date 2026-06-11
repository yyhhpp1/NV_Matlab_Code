function PlotT1Data_9curves(handles,raw_j)
global gmSEQ

%dataN is number of counters
cmp = tab20c(20);
colors = {...
    cmp(1,:),cmp(2,:),cmp(3,:),...
    cmp(5,:),cmp(6,:),cmp(7,:),...
    cmp(9,:),cmp(10,:),cmp(11,:),...
    cmp(13,:),cmp(17,:),...
    };
labels = [...
    "S_{0,0}","S_{0,-1}","S_{0,+1}",...
    "S_{-1,0}","S_{-1,-1}","S_{-1,+1}",...
    "S_{+1,0}","S_{+1,-1}","S_{+1,+1}",...
    "RefB","RefD"...
    ];
ctrShow = 2:3:26;
refB_mean = mean(gmSEQ.signal(1:3:25, :), 1);
refD_mean = mean(gmSEQ.signal(3:3:27, :), 1);
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
        single(refB_mean),':', ...
        'color', colors{10},...
        'LineWidth', 0.5,...
        'DisplayName', labels(10))
plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refD_mean),':', ...
        'color', colors{11},...
        'LineWidth', 0.5,...
        'DisplayName', labels(11))



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

refB0m1 = signal(4,:);
sig0m1 = signal(5,:);
refD0m1 = signal(6,:);

refB0p1 = signal(7,:);
sig0p1 = signal(8,:);
refD0p1 = signal(9,:);

refBm10 = signal(10,:);
sigm10 = signal(11,:);
refDm10 = signal(12,:);

refBm1m1 = signal(13,:);
sigm1m1 = signal(14,:);
refDm1m1 = signal(15,:);

refBm1p1 = signal(16,:);
sigm1p1 = signal(17,:);
refDm1p1 = signal(18,:);

refBp10 = signal(19,:);
sigp10 = signal(20,:);
refDp10 = signal(21,:);

refBp1m1 = signal(22,:);
sigp1m1 = signal(23,:);
refDp1m1 = signal(24,:);

refBp1p1 = signal(25,:);
sigp1p1 = signal(26,:);
refDp1p1 = signal(27,:);

% S00 - S0m1
sig = sig00 - sig0m1;
ref = (refB00 + refB0m1)/2;
data1 = sig ./ ref;

% Sm10 - Sm1m1
sig = sigm10 - sigm1m1;
ref = (refBm10 + refBm1m1)/2;
data2 = sig ./ ref;

% Sp10 - Sp1m1
sig = sigp10 - sigp1m1;
ref = (refBp10 + refBp1m1)/2;
data3 = sig ./ ref;

% S00 - S0p1
sig = sig00 - sig0p1;
ref = (refB00 + refB0p1)/2;
data4 = sig ./ ref;

% Sm10 - Sm1p1
sig = sigm10 - sigm1p1;
ref = (refBm10 + refBm1p1)/2;
data5 = sig ./ ref;

% Sp10 - Sp1p1
sig = sigp10 - sigp1p1;
ref = (refBp10 + refBp1p1)/2;
data6 = sig ./ ref;

% -------------------------------------------------------------------------
% PSEUDOCODE: build a fit-only curve from only part of the Sij counters.
%
% The six data curves above are still useful for display. If you want the
% live T1 fit / auto-stop to use only selected counters, build a separate
% vector here and pass that vector to the same fitting function used before.
%
% 1) Choose which contrast curves should contribute to the fit.
%    Examples:
%       fitCurves = [data1; data2; data3];   % only C_{-1,*}
%       fitCurves = [data4; data5; data6];   % only C_{+1,*}
%       fitCurves = [data1; data4];          % only m_s=0 pair
%
% 2) Combine the selected curves into one fit trace.
%    Pick the policy that matches your physics:
%       yFit = mean(fitCurves, 1, 'omitnan');
%       yFit = max(abs(fitCurves), [], 1);   % if you want largest contrast
       yFit = data1;                        % if you only trust one curve
%
% 3) Match x to the number of valid points in the fit trace.
       xFit = double(gmSEQ.SweepParam(1:length(yFit)) .* gmSEQ.ScaleT); % ms
%
% 4) Run the same T1 fitting function and plot/store the result.
       [popt, perr, xPlot, yPlot] = fitting.fit_t1(xFit, yFit);
%       hold(handles.axes3, 'on');
%       plot(handles.axes3, xPlot, yPlot, 'k-.', 'DisplayName', 'exp fit w/ n=1');
%       hold(handles.axes3, 'off');
%
% fitting.fit_t1 writes gmSEQ.T1FitLastStatus, which is what the final
% auto-stop policy reads. Keep this block after yFit is built and before
% maybe_stop_current_t1_on_fit_relerr is reached by the runner.
% -------------------------------------------------------------------------

cmp = tab10(3);
plot(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data1,...
    'LineStyle', '-',...
    'Color', cmp(1,:),...
    'DisplayName', 'C_{-1,0}')
hold(handles.axes3, "on");

plot(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data2,...
    'LineStyle', '-',...
    'Color', cmp(2,:),...
    'DisplayName', 'C_{-1,-1}')
plot(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data3,...
    'LineStyle', '-',...
    'Color', cmp(3,:),...
    'DisplayName', 'C_{-1,+1}')
plot(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data4,...
    'LineStyle', '--',...
    'Color', cmp(1,:),...
    'DisplayName', 'C_{+1,0}')
plot(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data5,...
    'LineStyle', '--',...
    'Color', cmp(2,:),...
    'DisplayName', 'C_{+1,-1}')
plot(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data6,...
    'LineStyle', '--',...
    'Color', cmp(3,:),...
    'DisplayName', 'C_{+1,+1}')

%fit
fitLegendText = current_t1_fit_legend_label('Ae^{-(x/T)^n}');
plot(handles.axes3, xPlot, yPlot, 'k-.', 'DisplayName', fitLegendText);

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

function label = current_t1_fit_legend_label(baseLabel)
global gmSEQ

label = sprintf('%s\nrelErr=NA', baseLabel);
if isempty(gmSEQ) || ~isstruct(gmSEQ) || ...
        ~isfield(gmSEQ, 'T1FitLastStatus') || ~isstruct(gmSEQ.T1FitLastStatus)
    return;
end

st = gmSEQ.T1FitLastStatus;
if isfield(st, 'timeScaleRelErr') && isfinite(st.timeScaleRelErr)
    label = sprintf('%s\nrelErr=%.2f%%', baseLabel, 100 * st.timeScaleRelErr);
elseif isfield(st, 'msg') && ~isempty(st.msg)
    label = sprintf('%s\nrelErr=NA (%s)', baseLabel, st.msg);
end
end
