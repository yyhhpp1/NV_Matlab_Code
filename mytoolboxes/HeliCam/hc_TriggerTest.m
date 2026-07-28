function hc_TriggerTest(mode, refLine, pinOverride)
% hc_TriggerTest(mode, refLine, pinOverride)  Minimal check that the PB CamRef
% signal actually reaches the HeliCam.
%
%   mode = 'line'   (default) PURE REGISTER TEST -- no acquisition, no triggers.
%                   Toggles the PB CamRef pin (whatever PBDictionary('CamRef')
%                   resolves to -- the test PRINTS it, do not assume) and reads
%                   the camera's LineStatusAll bitfield before/after. Whichever
%                   bit flips is the camera line your cable is on. This is the
%                   test to run first: it cannot time out and cannot disturb
%                   camera state.
%   mode = 'manual' Same read-back, but YOU toggle the line (30 s window,
%                   sampled continuously). Use with a function generator or if
%                   the CamRef pin is not the line you want to test.
%   mode = 'record' Arm a burst on one external RecordingStart edge on refLine
%                   ('FI2'/'FI3'), pulse the CamRef pin, see if data arrives.
%                   Heavier; only meaningful once 'line' shows the signal
%                   arriving.
%
%   pinOverride     Optional PB pin number to toggle INSTEAD of
%                   PBDictionary('CamRef'). Use it to test a candidate pin when
%                   you are unsure which output the camera coax is on, without
%                   editing the dictionary. Diagnostic only -- it does not change
%                   what the sequences drive.
%
% Requires the camera already connected (global gCam) -- open Experiment_PB_DAQ
% once so Initialize creates it. Reuses that connection (re-opening C4HdlCLR in
% one MATLAB session crashes the .NET runtime).
%
% Examples:
%   hc_TriggerTest                     % line-status toggle test, dictionary pin
%   hc_TriggerTest('line',[],9)        % same test, force PB pin 9
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

    % Resolve the CamRef pin from the dictionary -- never assume a pin number.
    camRefPin = SequencePool('PBDictionary','CamRef');
    reportPinMap(camRefPin);
    if nargin >= 3 && ~isempty(pinOverride)
        camRefPin = pinOverride;
        fprintf('[override] Toggling PB pin %d instead of the dictionary CamRef pin.\n', ...
                camRefPin);
    end
    camRefMask = 2^camRefPin;

    switch lower(mode)
        case 'line'
            fprintf('--- Line-status toggle test (PB CamRef = pin %d, mask 0x%X) ---\n', ...
                    camRefPin, camRefMask);
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
            fprintf('--- RecordingStart test on %s (PB pin %d) ---\n', refLine, camRefPin);
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
function reportPinMap(camRefPin)
% State which PB pin CamRef resolves to, and warn if another logical channel in
% PBDictionary shares it. A shared pin means an unrelated sequence channel drives
% the camera reference line (and ApplyDelays mis-tags that channel as CamRef).
    names = {'ctr0','dummy1','GreenAOM','RedAOM','MWSwitch','+X','-X','+Y','-Y', ...
             'PD','MWSwitch2','MWSwitch3'};
    clash = {};
    for i = 1:numel(names)
        try
            if SequencePool('PBDictionary', names{i}) == camRefPin
                clash{end+1} = names{i}; %#ok<AGROW>
            end
        catch
        end
    end
    fprintf('[PBDictionary] CamRef -> PB pin %d.\n', camRefPin);
    if ~isempty(clash)
        fprintf(2, ['[PBDictionary] WARNING: pin %d is also mapped to: %s.\n', ...
                    '   That channel and CamRef drive the same physical output, and\n', ...
                    '   ApplyDelays will treat it as CamRef. Give CamRef its own pin.\n'], ...
                camRefPin, strjoin(clash, ', '));
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
