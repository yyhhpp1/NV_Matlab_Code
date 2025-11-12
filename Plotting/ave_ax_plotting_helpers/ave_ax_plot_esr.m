function ave_ax_plot_esr(handles,raw_j)
global gmSEQ

plot(handles.axes3, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(1, :)),'-', ...
    'color', [0, 0, 1],'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', 1))

plot(handles.axes3, gmSEQ.SweepParam.*gmSEQ.ScaleT, ProcessData(A))
grid on;
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Fluorescence contrast');
xlabel(handles.axes3, gmSEQ.ScaleStr);
if length(gmSEQ.SweepParam) ~= 1
    xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
end
if raw_j~=0
    xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
end
end
