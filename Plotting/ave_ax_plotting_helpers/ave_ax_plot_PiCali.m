function ave_ax_plot_PiCali(handles,raw_j)
global gmSEQ

for i = 1:gmSEQ.dataN
    signal(i,:) = gmSEQ.signal(i, ~isnan(gmSEQ.signal(i,:)));
end

ref1 = signal(1,:);
sig1 = signal(2,:);
ref2 = signal(3,:);
sig2 = signal(4,:);
data = sig1./sig2;

plot(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data)

% set up axes before looping
grid(handles.axes3, 'on');
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Fluorescence contrast');
xlabel(handles.axes3, gmSEQ.ScaleStr);
% don't rescale x axis of the plots if num of sweep param is set to 1
if length(gmSEQ.SweepParam) ~= 1
    xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
end

if raw_j~=0
    xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
end

end
