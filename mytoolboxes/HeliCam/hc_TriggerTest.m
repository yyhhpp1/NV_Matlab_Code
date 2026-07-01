function hc_TriggerTest(refLine, mode)
% hc_TriggerTest(refLine, mode)  Minimal check that a TTL edge on the camera's
% reference input is actually detected by the HeliCam.
%
% It arms the camera to begin a plain intensity burst on ONE external
% RecordingStart edge on refLine ('FI2' or 'FI3'), then looks for a rising edge
% on the PB CamRef pin (pin 9). If the buffer returns -> the edge reached the
% camera (wiring/line OK). If it times out -> no edge got through.
%
%   refLine : 'FI2' (default) or 'FI3' -- the camera input your CamRef cable is on
%   mode    : 'auto'   (default) pulse PB pin 9 automatically, then read
%             'manual' arm and wait 30 s while YOU create the edge (function
%                      generator / physical toggle / your own PB pulse)
%
% Requires the camera already connected (global gCam) -- e.g. open
% Experiment_PB_DAQ once so Initialize creates it. Reuses that connection
% (re-opening C4HdlCLR in one MATLAB session crashes the .NET runtime).
%
% Examples:
%   hc_TriggerTest('FI2')            % auto-pulse pin 9, check FI2
%   hc_TriggerTest('FI3','auto')     % same, check FI3
%   hc_TriggerTest('FI2','manual')   % arm, then toggle the line yourself

    global gCam

    if nargin < 1 || isempty(refLine); refLine = 'FI2';  end
    if nargin < 2 || isempty(mode);    mode    = 'auto'; end

    if isempty(gCam) || ~isvalid(gCam)
        error(['hc_TriggerTest: no camera connection (global gCam). Open ', ...
               'Experiment_PB_DAQ first, or create gCam = HeliCamInterface(0,0).']);
    end
    if ~isa(gCam, 'HeliCamInterface')
        error('hc_TriggerTest: gCam is not a real HeliCamInterface (FakeCamera cannot test wiring).');
    end

    camRefMask = 2^SequencePool('PBDictionary','CamRef');   % PB pin 9

    gCam.armExternalRecording(refLine, 4);

    switch lower(mode)
        case 'auto'
            pause(0.3);                       % let the arm settle
            PBFunctionPool('PBON', camRefMask);   % CamRef high  -> rising edge
            pause(0.05);
            PBFunctionPool('PBON', 0);            % CamRef low
            ok = gCam.readAfterTrigger(5000);
        case 'manual'
            fprintf(['>> Create a rising edge on %s now (function generator / ', ...
                     'physical toggle / PB pulse). 30 s window ...\n'], refLine);
            ok = gCam.readAfterTrigger(30000);
        otherwise
            error('hc_TriggerTest: mode must be ''auto'' or ''manual''.');
    end

    % Leave the CamRef line low.
    try; PBFunctionPool('PBON', 0); catch; end

    if ok
        fprintf('*** TRIGGER DETECTED on %s -- reference wiring OK. ***\n', refLine);
    else
        fprintf(['*** NO TRIGGER on %s -- edge did not reach the camera. ', ...
                 'Check the cable, the connector (FI2 vs FI3), and that PB pin 9 ', ...
                 'is the CamRef output. ***\n'], refLine);
    end
end
