function EODriveTest
% loadlibary(dll name, header file name) : Load a DLL into memory so that MATLAB can call it.
loadlibrary('EO-Drive', 'eo-drive'); 

if (~libisloaded('EO0x2DDrive'))
	disp('Error: Library did not load correctly');
    return
end

% libfunctions: List the functions available in a DLL
m = libfunctions('EO0x2DDrive', '-full');
disp('The following functions are available to use from EO-Drive')
disp(m)

% calllib: Call a function in a loaded DLL
handle = calllib('EO0x2DDrive', 'EO_InitHandle');
if (handle == 0)
	disp('Error: Handle was not initialized correctly');
    cleanup(handle, 1);
    return;
end 

% Move to a position.
err = calllib('EO0x2DDrive', 'EO_Move', handle, 10.0);
if (err ~= 0)
    message = sprintf('Error: EO-Drive did not correctly write position. Error Code %d', err);
	disp(message);
    cleanup(handle, 1);
    return;    
end

% cleanup
cleanup(handle, 0);

function cleanup(handle, errors)
calllib('EO0x2DDrive', 'EO_ReleaseHandle', handle);
unloadlibrary('EO0x2DDrive');
if (errors == 1)
    disp('Exiting');
else
    disp('Program finished without any errors');
end
