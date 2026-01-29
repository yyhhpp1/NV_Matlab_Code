function ave_ax_plot_T1_S00_S01_S10(handles,raw_j)
global gmSEQ

for i = 1:gmSEQ.dataN
    signal(i,:) = gmSEQ.signal(i, ~isnan(gmSEQ.signal(i,:)));
end

ref1b = signal(1,:);
sig1  = signal(2,:);
ref1d = signal(3,:);
ref2b = signal(4,:);
sig2  = signal(5,:);
ref2d = signal(6,:);
ref3b = signal(7,:);
sig3  = signal(8,:);
ref3d = signal(9,:);

data = 2*(sig1-sig2)./(ref1b+ref2b);

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
