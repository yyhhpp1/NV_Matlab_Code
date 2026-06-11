function plot_data(handles, raw_j)
% Generic fallback plotter adapted from base runner.
global gmSEQ

for i = 1:gmSEQ.dataN
    if gmSEQ.dataN == 1
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT, single(gmSEQ.signal(i, :)), '-', ...
            'color', [0, 0, 1], 'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i));
    else
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT, single(gmSEQ.signal(i, :)), '-', ...
            'color', [0, (i-1)/(gmSEQ.dataN - 1), 1-(i-1)/(gmSEQ.dataN - 1)], 'LineWidth', 0.5, ...
            'DisplayName', sprintf('signal %d', i));
    end
    if i == 1
        hold(handles.axes2, 'on');
    end
end

grid(handles.axes2, 'on');
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);
if length(gmSEQ.SweepParam) ~= 1
    xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
end
if get(handles.bShowLegend,'Value')
    legend(handles.axes2);
end
if raw_j~=0
    xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT, '--', 'color','r', 'HandleVisibility','off');
end
hold(handles.axes2, 'off');

if ~isfield(gmSEQ,'bLiO') && gmSEQ.ctrN~=1
    signal = [];
    for i = 1:gmSEQ.dataN
        signal(i,:) = gmSEQ.signal(i, ~isnan(gmSEQ.signal(i,:))); %#ok<AGROW>
    end

    if gmSEQ.ctrN==2
        sig = signal(2,:);
        ref = signal(1,:);
        data = sig./ref;
        ref_err = 1./sqrt(gmSEQ.iAverage * ref);
        sig_err = 1./sqrt(gmSEQ.iAverage * sig);
        rel_err = sqrt(ref_err.^2 + sig_err.^2);
        data_err = rel_err .* data;
    elseif gmSEQ.ctrN==12
        sig_B = signal(3,:);
        ref_B = signal(7,:);
        sig_D = signal(5,:);
        ref_D = signal(1,:);
        [data, data_err] = ContrastDiff(ref_B, ref_D, sig_B, sig_D, gmSEQ.iAverage);
    else
        data = zeros(size(signal(1,:)));
        data_err = data;
    end

    errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data, data_err, '-g');
    grid(handles.axes3, 'on');
    set(handles.axes3,'FontSize',8);
    ylabel(handles.axes3, 'Fluorescence contrast');
    xlabel(handles.axes3, gmSEQ.ScaleStr);
    if length(gmSEQ.SweepParam) ~= 1
        xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
    end
    if raw_j~=0
        xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT, '--', 'color','r', 'HandleVisibility','off');
    end
end
end