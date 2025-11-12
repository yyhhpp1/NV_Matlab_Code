function raw_ax_plot_general(handles,raw_j)
global gmSEQ

cmps10 = tab10(10);
cmps20 = tab20(20);
cmpsN = viridis(gmSEQ.dataN);

for i = 1:gmSEQ.dataN
    if gmSEQ.dataN == 1
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(i, :)),'-', ...
            'color', cmps10(i,:),'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i))
    elseif gmSEQ.dataN<=10
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(i, :)),'-', ...
            'color',  cmps10(i,:), 'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i))
    elseif gmSEQ.dataN<=20
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(i, :)),'-', ...
            'color',  cmps20(i,:), 'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i))
    else
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(i, :)),'-', ...
            'color',  cmpsN(i,:), 'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i))
    end
    if i == 1
        hold(handles.axes2, 'on')
    end
end


if get(handles.bShowLegend,'Value')
    legend(handles.axes2)
end
if raw_j~=0
    xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
end

end