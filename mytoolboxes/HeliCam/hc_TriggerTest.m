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
%   mode = 'identify' Answers "which line is that?" after 'line' shows a bit
%                   moving. Holds the CamRef pin low, then high, probing every
%                   plausible LineSelector name each time, and reports which
%                   named line follows the pin -- that name is what
%                   cfg.refSourceSignal must be set to. Also a pure register
%                   test: no acquisition, no timeout risk.
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
%   hc_TriggerTest('identify')         % name the line that carries CamRef
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
                fprintf('*** NO CHANGE -- camera did not see PB pin %d toggle. ***\n', camRefPin);
                fprintf('    Check the cable, the connector, and scope PB pin %d directly.\n', ...
                        camRefPin);
            end
            reportLines(gCam);

        case 'identify'
            % 'line' proves the signal arrives and names the LineStatusAll BIT.
            % This names the LINE, which is what LockInReferenceSourceSignal
            % (cfg.refSourceSignal) needs. Probe every plausible LineSelector
            % entry with the pin held low, then held high, and report which one
            % follows the pin.
            fprintf('--- Identify the camera line carrying PB pin %d ---\n', camRefPin);
            cand = candidateLineNames();

            PBFunctionPool('PBON', 0);            pause(0.2);
            loAll = gCam.readLineStatusAll();
            lo    = probeLines(gCam, cand);
            PBFunctionPool('PBON', camRefMask);   pause(0.2);
            hiAll = gCam.readLineStatusAll();
            hi    = probeLines(gCam, cand);
            PBFunctionPool('PBON', 0);            pause(0.2);

            changed = bitxor(uint32(loAll), uint32(hiAll));
            bits = find(bitget(changed, 1:32)) - 1;
            fprintf('LineStatusAll: low=0x%X  high=0x%X  -> bit(s) %s\n', ...
                    loAll, hiAll, mat2str(bits));

            fprintf('\n%-12s %-6s %-4s %-4s %s\n', 'NAME', 'BIT', 'LOW', 'HIGH', 'NOTE');
            hits = {};
            for i = 1:numel(cand)
                nm = cand{i};
                if ~lo(i).supported
                    continue   % camera rejected or ignored this name
                end
                note = '';
                if lo(i).state ~= hi(i).state
                    note = '<== FOLLOWS THE PIN';
                    hits{end+1} = nm; %#ok<AGROW>
                end
                if ~isnan(lo(i).bit) && ismember(lo(i).bit, bits) && isempty(note)
                    note = '(matches the toggled bit)';
                end
                bitStr = 'n/a';
                if ~isnan(lo(i).bit); bitStr = sprintf('%d', lo(i).bit); end
                fprintf('%-12s %-6s %-4d %-4d %s\n', nm, bitStr, ...
                        lo(i).state, hi(i).state, note);
            end

            fprintf('\n');
            if isempty(hits)
                fprintf(['*** No named line followed the pin. The bit moved but no probed\n', ...
                         '    name maps to it -- the name list in candidateLineNames() is\n', ...
                         '    incomplete for this camera. Check the connector label.\n']);
            elseif numel(hits) == 1
                fprintf('*** CamRef arrives on camera line ''%s''. ***\n', hits{1});
                fprintf('    Set cfg.refSourceSignal = ''%s''; in WidefieldConfig.m\n', hits{1});
            else
                fprintf('*** Multiple lines followed the pin: %s ***\n', strjoin(hits, ', '));
                fprintf('    They are likely aliases; prefer the FIx name for refSourceSignal.\n');
            end

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
            error(['hc_TriggerTest: mode must be ''line'', ''identify'', ', ...
                   '''manual'' or ''record''.']);
    end
end

% ---------------------------------------------------------------------------- %
function names = candidateLineNames()
% Plausible LineSelector entries. Unsupported names are detected and skipped, so
% over-listing is free; a missing name is what costs an answer.
    names = [ ...
        arrayfun(@(k) sprintf('Line%d', k), 0:7, 'UniformOutput', false), ...
        arrayfun(@(k) sprintf('FI%d',   k), 0:4, 'UniformOutput', false), ...
        arrayfun(@(k) sprintf('FO%d',   k), 0:4, 'UniformOutput', false), ...
        arrayfun(@(k) sprintf('RTIO%d', k), 0:3, 'UniformOutput', false), ...
        {'Software', 'Trigger', 'TriggerInput', 'SyncIn', 'SyncOut'}];
end

% ---------------------------------------------------------------------------- %
function out = probeLines(cam, names)
% Read every candidate line once. out(i).supported is false when the camera
% rejects the name OR silently ignores the write (LineSelector reads back as
% something else) -- in the latter case the state belongs to another line and
% would otherwise be reported as a false match.
    out = repmat(struct('supported', false, 'state', 0, 'bit', NaN), 1, numel(names));
    for i = 1:numel(names)
        try
            [s, bitIdx, actual] = cam.readLineStatus(names{i});
            if ~strcmpi(strtrim(actual), names{i})
                continue
            end
            out(i).supported = true;
            out(i).state     = s;
            out(i).bit       = bitIdx;
        catch
        end
    end
end

% ---------------------------------------------------------------------------- %
function reportPinMap(camRefPin)
% State which PB pin CamRef resolves to, and warn if another logical channel in
% PBDictionary shares it. A shared pin means an unrelated sequence channel drives
% the camera reference line (and ApplyDelays mis-tags that channel as CamRef).
    names = {'ctr0','dummy1','GreenAOM','RedAOM','MWSwitch','+X','-X','+Y','-Y', ...
             'PD','MWSwitch2','MWSwitch3','CamTrig'};
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
