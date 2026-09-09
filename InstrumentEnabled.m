function tf = InstrumentEnabled(name)
% InstrumentEnabled  Central enable/disable switchboard for lab instruments.
%
% Set an entry to false to skip that instrument's initialization and all of its
% runtime calls, so the rest of the system still runs when a box is absent or
% intentionally unused (e.g. bench-testing the camera with FPGA and SRS off).
%
%   tf = InstrumentEnabled('srs')   % main SRS signal generator (gSG)
%
% Recognized names: 'fpga', 'srs', 'srs2', 'srs3', 'pulseblaster', 'nidaq',
% 'camera'. Unknown names default to enabled (true) so existing code is unaffected.

switch lower(name)
    case 'fpga';          tf = false;
    case 'srs';           tf = true;   % main SRS SG386 (gSG)
    case 'srs2';          tf = false;   % second signal generator (gSG2)
    case 'srs3';          tf = false;   % third signal generator (gSG3)
    case 'pulseblaster';  tf = true;
    case 'nidaq';         tf = true;   % NI-DAQ counters / KillAllTasks
    case 'camera';        tf = true;   % HeliCam widefield detector
    case 'idscam';        tf = false;   % IDS uEye+ widefield intensity camera
    otherwise;            tf = true;   % unknown -> enabled (no surprise breakage)
end
