function PlotESRData(handles)
global gmSEQ

cmp = tab10(20);
colors = {cmp(1,:),cmp(2,:)};
plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT, single(gmSEQ.signal(1, :)),'-', ...
            'color', colors{1},...
            'LineWidth', 0.5,...
            'DisplayName', 'data')
hold(handles.axes2, 'on');
grid(handles.axes2, 'on');
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);

% don't rescale x axis of the plots if num of sweep param is set to 1
if length(gmSEQ.SweepParam) ~= 1
    xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
end

legend(handles.axes2)
hold(handles.axes2, 'off')

%clear axes3
cla(handles.axes3);

end

