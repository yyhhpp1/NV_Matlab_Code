function expoNs = hc_MinExposureNs(sensitivity)
% hc_MinExposureNs  Shortest per-quarter-bin exposure the HeliCam C4 accepts (ns).
%
%   expoNs = hc_MinExposureNs()             % sensitivity 1 (the usual case)
%   expoNs = hc_MinExposureNs(sensitivity)  % p_s other than 1
%
% Deliberately NOT a literal. The exposure is never written to the camera as a
% time: it is written as a target reference frequency f_ref = p_s/(4*n*t_c), and
% that GenICam node has a hard ceiling (~134228 Hz). The shortest legal exposure
% is therefore whatever the smallest grid index n under that ceiling gives -- a
% quantity owned by HeliCamInterface.exposureToReferenceFrequency, not by
% whoever is printing a warning about it.
%
% This asks that function for an impossibly short exposure and reports what it
% clamped to, so the floor quoted in a message and the floor actually applied to
% the hardware cannot disagree. RunSequence previously carried the floor as the
% literal 1825 ns (n = 146) in four separate places, and that value is ILLEGAL on
% this camera: it maps to 136986.30 Hz, above the ceiling, so a gate short enough
% to reach the floor killed the run with a GenICam exception rather than clamping.
% The true floor at p_s = 1 is 1875 ns (n = 150).

    if nargin < 1 || isempty(sensitivity); sensitivity = 1.0; end

    % A 0 s request is out of range by construction, and the snap warning that
    % provokes is noise here -- the whole point of the call is to be clamped.
    ws = warning('off', 'HeliCamInterface:ExposureSnap');
    restoreWarn = onCleanup(@() warning(ws));   %#ok<NASGU>

    [~, ~, tExp] = HeliCamInterface.exposureToReferenceFrequency(0, sensitivity);
    expoNs = tExp * 1e9;
end
