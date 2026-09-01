function hc_ListDevices()
% hc_ListDevices  Print every GigE interface and the devices on each.
%
% Run this when the connection itself fails, e.g.
%
%   Error using HeliCamInterface
%   Message: No xml description file found on the device!
%
% That error comes from openDevice, not from discovery: an interface and a
% device WERE enumerated, but the handler could not read the GenICam XML
% description off the device afterwards. The usual reason is that cfg.ifNo
% points at the wrong NIC -- GigE discovery is a UDP broadcast, so a camera
% sitting on another interface's subnet still appears in the device list while
% directed register reads have no route back.
%
% Use the printed indices to set cfg.ifNo / cfg.devNo in WidefieldConfig.
%
% IMPORTANT: this opens the SDK itself, so run it in a FRESH MATLAB session
% with no camera connection open. C4HdlCLR cannot be opened twice in one
% session without crashing the .NET runtime (see HeliCamRelease.m), and this
% function refuses to run if a live gCam already holds the device.

    global gCam

    if ~isempty(gCam) && isvalid(gCam) && isa(gCam, 'HeliCamInterface')
        error(['hc_ListDevices: a camera connection (global gCam) is already ', ...
               'open. Opening the SDK twice in one MATLAB session crashes the ', ...
               '.NET runtime. Restart MATLAB and run this before opening the GUI.']);
    end

    if ~NET.isNETSupported
        error('hc_ListDevices:NoNET', '.NET Framework not supported on this platform.');
    end

    NET.addAssembly('C4HdlCLR');
    import C4HdlCLR.*  %#ok<SIMPT>

    c4sys = heliotis.C4HandlerCLR();
    c4sys.reset();

    nIf = double(c4sys.updateInterfaceList());
    fprintf('=== HeliCam interfaces / devices ===\n');
    if nIf == 0
        fprintf('No interfaces detected.\n');
        return
    end

    for i = 0:(nIf - 1)
        ifName = '<unreadable>';
        try
            ifName = char(string(c4sys.getInterfaceName(i)));
        catch
        end
        fprintf('interface %d : %s\n', i, ifName);

        % Opening an interface is cheap and does not claim the camera; only
        % openDevice takes the control channel, which is why this stops short
        % of that -- it must not lock out the run that follows.
        try
            c4if = c4sys.openInterface(i);
        catch ME
            fprintf('   <could not open: %s>\n', ME.message);
            continue
        end

        nDev = 0;
        try
            nDev = double(c4if.updateDeviceList());
        catch ME
            fprintf('   <device list failed: %s>\n', ME.message);
        end

        if nDev == 0
            fprintf('   (no devices)\n');
        else
            for d = 0:(nDev - 1)
                devName = '<unreadable>';
                try
                    devName = char(string(c4if.getDeviceName(d)));
                catch
                end
                fprintf('   device %d : %s\n', d, devName);
            end
        end

        try; c4if.release(); catch; end
    end

    fprintf(['=== end ===\nSet cfg.ifNo / cfg.devNo in WidefieldConfig to the ', ...
             'pair naming the HeliCam.\n']);
end
