function IDSCamRelease()
% IDSCamRelease  Deliberately disconnect the IDS camera and clear gCamIDS.
%
% Use before running a standalone Python script against the camera, or when a
% USB fault needs the device re-enumerated. Normal runs never need this: the
% camera object persists for the session on purpose, and RunSequence_IDSCam
% reuses whatever is already open.
%
% Unlike the HeliCam's C4 .NET SDK -- where re-opening inside one MATLAB session
% crashes the runtime uncatchably (0xe0434352, see docs/HELICAM_HANDOFF.md) --
% the GenTL producer can be closed and re-opened, so this is a safe operation
% rather than a last resort. The Python module itself stays imported; only the
% Harvester and the device handle go.

global gCamIDS %#ok<GVMIS>

if isempty(gCamIDS)
    fprintf('[IDS] No camera object to release.\n');
else
    try
        if isvalid(gCamIDS); delete(gCamIDS); end
    catch ME
        fprintf(2, '[IDS] delete(gCamIDS) failed (%s); clearing anyway.\n', ME.message);
    end
    gCamIDS = [];
    fprintf('[IDS] gCamIDS released and cleared.\n');
end

% Belt and braces: the backend holds its own module-level handles, and a stale
% one would make the next connect() return a reused-but-dead camera.
try
    py.ids_acquire.disconnect();
catch
    % Python may not be loaded at all in this session -- nothing to do.
end
end
