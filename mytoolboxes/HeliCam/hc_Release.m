function hc_Release()
% hc_Release  Fully release the HeliCam so another process can open it.
%
% Use before running the Python acquisition script (hc_ExtTrigAcquire.py), the
% Heliotis C4Utility GUI, or anything else that needs the camera: the GigE
% device allows one owner at a time, and MATLAB keeps it for as long as the
% global gCam object lives.
%
% Clearing the variable is NOT enough on its own. gCam is a handle object that
% many functions declare `global gCam`, so every one of those bindings is a
% reference and the destructor will not run while any of them survives.
% delete() invokes the destructor immediately regardless of the other
% references, which is what actually releases the device -- the clears
% afterwards just remove the now-stale handles.
%
% Release order inside HeliCamInterface.delete: stopAcquisition, then
% c4dev.release, c4if.release, c4sys.reset (the last frees the native handle).
%
% Reconnecting needs no action: RunSequence_HeliCam re-creates gCam lazily when
% it finds it empty, so the next widefield run just opens the camera again.
%
% Note: the C4HdlCLR .NET assembly stays loaded for the lifetime of the MATLAB
% session -- MATLAB cannot unload .NET assemblies. That is harmless; it holds
% no device. If another process still cannot open the camera after this, the
% remaining options are `clear classes` (fails while any instance exists) or
% restarting MATLAB.

    global gCam %#ok<GVMIS>

    if isempty(gCam)
        fprintf('[hc_Release] No camera connection (gCam already empty).\n');
    else
        if isvalid(gCam)
            try
                gCam.stopAcq();
            catch ME
                fprintf(2, '[hc_Release] stopAcq failed (%s); continuing.\n', ME.message);
            end
            try
                delete(gCam);      % runs HeliCamInterface.delete -> releases device
                fprintf('[hc_Release] Camera released.\n');
            catch ME
                fprintf(2, '[hc_Release] delete failed: %s\n', ME.message);
            end
        else
            fprintf('[hc_Release] Handle was already deleted; clearing it.\n');
        end
    end

    % Drop the stale handle everywhere, so nothing later mistakes it for a live
    % connection and the lazy re-init in RunSequence_HeliCam triggers cleanly.
    clear global gCam

    fprintf(['[hc_Release] Done. Other software can open the camera now; ', ...
             'the next widefield run reconnects automatically.\n']);
end
