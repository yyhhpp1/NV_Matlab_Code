function raw_ax_plot_T1_S00_S01_S10(handles,raw_j)
global gmSEQ

cmps10 = tab10(10);
cmps20 = tab20(20);
cmpsN = viridis(gmSEQ.dataN);

ls = {'--', '-', '--','--', '-', '--','--', '-', '--',};

for i = 1:gmSEQ.dataN
    plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(i, :)),ls{i}, ...
            'color', cmps10(i,:),'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i))
    if i == 1
        hold(handles.axes2, 'on')
    end
end

grid(handles.axes2, 'on');
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);
% don't rescale x axis of the plots if num of sweep param is set to 1
if length(gmSEQ.SweepParam) ~= 1
    xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
end

if get(handles.bShowLegend,'Value')
    legend(handles.axes2)
end
if raw_j~=0
    xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
end
hold(handles.axes2, 'off')
end