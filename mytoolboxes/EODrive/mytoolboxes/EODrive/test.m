loadlibrary('EO-Drive');
% libfunctionsview('EO0x2DDrive');

% obtain handle
handle = calllib('EO0x2DDrive', 'EO_InitHandle');
if handle==0
    disp('Failed To Get Handle')
else
    disp('Obtained Handle')
end

% get serial number
serialnum = 0;
[errorval, serialnum] = calllib('EO0x2DDrive', 'EO_GetSerialNumber', handle, serialnum);
showErrorInfo(errorval);
disp('Serial number is ');
disp(serialnum);

%vol_lst = [0];
% vol_lst = linspace(0,100,11);

for vol = vol_lst

voltage = vol;
errorval = calllib('EO0x2DDrive', 'EO_Move', handle, voltage);
showErrorInfo(errorval);


lastcommandpos = 0.0;
[errorval, lastcommandpos] = calllib('EO0x2DDrive', 'EO_GetCommandPosition', handle, lastcommandpos);
showErrorInfo(errorval);
disp('Last commanded position is ');
disp(lastcommandpos);

pause(1)

end

%2nd move
voltage = 57;
errorval = calllib('EO0x2DDrive', 'EO_Move', handle, voltage);
showErrorInfo(errorval);

lastcommandpos = 0.0;
[errorval, lastcommandpos] = calllib('EO0x2DDrive', 'EO_GetCommandPosition', handle, lastcommandpos);
showErrorInfo(errorval);
disp('Last commanded position is ');
disp(lastcommandpos);

pause(1)


% release handle
calllib('EO0x2DDrive', 'EO_ReleaseAllHandles')
% unload library
unloadlibrary('EO0x2DDrive');

% parses error codes returned by function calls
function returns = showErrorInfo(val)
    if val==0
        disp('EO_SUCCESS');
    elseif val==-1
        disp('EO_GENERAL_ERROR');
    elseif val==-2
        disp('EO_DEV_ERROR');
    elseif val==-3
        disp('EO_DEV_NOT_ATTACHED');
    elseif val==-6
        disp('EO_ARGUMENT_ERROR');
    elseif val==-8
        disp('EO_INVALID_HANDLE');
    end
    returns = 0;
end

