function send_v2_1_stop_signal(handlesAuto)
%SEND_V2_1_STOP_SIGNAL Best-effort stop request for current v2.1 run.

global gmSEQ

if nargin >= 1 && isstruct(handlesAuto) ...
        && isfield(handlesAuto, 'pushbutton_stopProg') ...
        && isgraphics(handlesAuto.pushbutton_stopProg, 'uicontrol')
    try
        handlesAuto.pushbutton_stopProg.UserData = 1;
    catch
    end
end

try
    gmSEQ.bGo = 0;
    gmSEQ.bGoAfterAvg = 0;
    gmSEQ.bExp = 0;
catch
end
end
