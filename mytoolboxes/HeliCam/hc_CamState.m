function hc_CamState()
% hc_CamState  Print what the camera ACTUALLY holds for every lock-in feature.
%
% Everything so far has confirmed what we SENT (PB pin, pulse count, pulse width,
% timebase -- all verified on a scope) and what we ASKED the camera for. Nothing
% has confirmed what the camera ACCEPTED. GenICam clamps silently, and a rejected
% or clamped value can make a burst impossible while the only symptom is
% "Timeout, no data available!".
%
% Run this after a failed hc_Image, in the same MATLAB session, so the readback
% reflects the configuration that just failed:
%
%   hc_Image        % fails with the timeout
%   hc_CamState     % shows what the camera was actually set to
%
% Reuses the existing global gCam -- it never re-opens the SDK. It does call
% stopAcq() first, because the per-selector trigger features are not readable
% while acquisition is active.

    global gCam

    if isempty(gCam) || ~isvalid(gCam)
        error(['hc_CamState: no camera connection (global gCam). Open ', ...
               'Experiment_PB_DAQ first so Initialize creates it.']);
    end
    if ~isa(gCam, 'HeliCamInterface')
        error('hc_CamState: gCam is a FakeCamera; there is no hardware state to read.');
    end

    gCam.dumpLockInState();
end
