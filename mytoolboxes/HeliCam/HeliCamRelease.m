function HeliCamRelease()
% HeliCamRelease  Fully disconnect the HeliCam and clear the global handle.
%
% The HeliCam .NET assembly (C4HdlCLR) cannot be re-opened within the same
% MATLAB session without crashing the .NET runtime (0xe0434352). The Experiment
% GUI therefore keeps a single camera connection (global gCam) alive across
% open/close cycles and reuses it. Call this ONLY when you actually want to
% release the device -- e.g. before quitting MATLAB, or to hand the camera to
% another program (heliViewer).
%
% After calling this, the next time you open Experiment_PB_DAQ a fresh
% connection is created.

global gCam
if ~isempty(gCam)
    try; delete(gCam); catch; end
end
gCam = [];
fprintf('[HeliCam] Released. Connection will be re-created on next GUI open.\n');
end
