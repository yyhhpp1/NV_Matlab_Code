function hc_TriggerTest(mode, refLine)
% hc_TriggerTest(mode, refLine)  Minimal check that the PB CamRef signal
% actually reaches the HeliCam.
%
%   mode = 'line'   (default) PURE REGISTER TEST -- no acquisition, no triggers.
%                   Toggles PB CamRef (pin 9) and reads the camera's
%                   LineStatusAll bitfield before/after. Whichever bit flips is
%                   the camera line your cable is on. This is the test to run
%                   first: it cannot time out and cannot disturb camera state.
%   mode = 'manual' Same read-back, but YOU toggle the line (30 s window,
%                   sampled continuously). Use with a function generator or if
%                   PB pin 9 is not the line you want to test.
%   mode = 'record' Arm a burst on one external RecordingStart edge on refLine
%                   ('FI2'/'FI3'), pulse pin 9, see if data arrives. Heavier;
%                   only meaningful once 'line' shows the signal arriving.
%
% Requires the camera already connected (global gCam) -- open Experiment_PB_DAQ
% once so Initialize creates it. Reuses that connection (re-opening C4HdlCLR in
% one MATLAB session crashes the .NET runtime).
%
% Examples:
%   hc_TriggerTest                     % line-status toggle test
%   hc_TriggerTest('manual')           % you create the edges
%   hc_TriggerTest('record','FI3')     % RecordingStart test on FI3

    global gCam

    if nargin < 1 || isempty(mode);    mode    = 'line'; end
    if nargin < 2 || isempty(refLine); refLine = 'FI2';  end

    if isempty(gCam) || ~isvalid(gCam)
        error(['hc_TriggerTest: no camera connection (global gCam). Open ', ...
               'Experiment_PB_DAQ first, or create gCam = HeliCamInterface(0,0).']);
    end
    if ~isa(gCam, 'HeliCamInterface')
        error('hc_TriggerTest: gCam is not a real HeliCamInterface (FakeCamera cannot test wiring).');
    end

    camRefMask = 2^SequencePool('PBDictionary','CamRef');   % PB pin 9

    switch lower(mode)
        case 'line'
            fprintf('--- Line-status toggle test (PB CamRef = pin 9) ---\n');
            PBFunctionPool('PBON', 0);            pause(0.2);
            lo1 = gCam.readLineStatusAll();
            PBFunctionPool('PBON', camRefMask);   pause(0.2);
            hi  = gCam.readLineStatusAll();
            PBFunctionPool('PBON', 0);            pause(0.2);
            lo2 = gCam.readLineStatusAll();

            fprintf('LineStatusAll: low=0x%X  high=0x%X  low=0x%X\n', lo1, hi, lo2);
            changed = bitxor(uint32(lo1), uint32(hi));
            if changed ~= 0
                bits = find(bitget(changed, 1:32)) - 1;
                fprintf('*** SIGNAL SEEN. Bit(s) toggled: %s ***\n', mat2str(bits));
                fprintf('    The camera line carrying that bit is where CamRef is wired.\n');
            else
                fprintf('*** NO CHANGE -- camera did not see PB pin 9 toggle. ***\n');
                fprintf('    Check the cable, the connector, and scope PB pin 9 directly.\n');
            end
            reportLines(gCam);

        case 'manual'
            fprintf('--- Manual toggle test: sampling LineStatusAll for 30 s ---\n');
            base = gCam.readLineStatusAll();
            fprintf('Baseline = 0x%X. Toggle the line now ...\n', base);
            seen = uint32(0); t0 = tic;
            while toc(t0) < 30
                v = gCam.readLineStatusAll();
                seen = bitor(seen, bitxor(uint32(base), uint32(v)));
                pause(0.05);
            end
            if seen ~= 0
                bits = find(bitget(seen, 1:32)) - 1;
                fprintf('*** SIGNAL SEEN. Bit(s) toggled: %s ***\n', mat2str(bits));
            else
                fprintf('*** NO CHANGE detected in 30 s. ***\n');
            end
            reportLines(gCam);

        case 'record'
            fprintf('--- RecordingStart test on %s ---\n', refLine);
            gCam.armExternalRecording(refLine, 4);
            pause(0.3);
            PBFunctionPool('PBON', camRefMask);   pause(0.05);
            PBFunctionPool('PBON', 0);
            ok = gCam.readAfterTrigger(5000);
            try; PBFunctionPool('PBON', 0); catch; end
            if ok
                fprintf('*** TRIGGER DETECTED on %s. ***\n', refLine);
            else
                fprintf('*** NO TRIGGER on %s. ***\n', refLine);
            end

        otherwise
            error('hc_TriggerTest: mode must be ''line'', ''manual'' or ''record''.');
    end
end

% ---------------------------------------------------------------------------- %
function reportLines(cam)
% Per-line status, for reference. Unsupported names are skipped.
    names = {'Line0','Line1','Line2','Line3','RTIO2','RTIO3'};
    out = '';
    for i = 1:numel(names)
        try
            out = [out sprintf('  %s=%d', names{i}, cam.readLineStatus(names{i}))]; %#ok<AGROW>
        catch
        end
    end
    if ~isempty(out); fprintf('Per-line now:%s\n', out); end
end
