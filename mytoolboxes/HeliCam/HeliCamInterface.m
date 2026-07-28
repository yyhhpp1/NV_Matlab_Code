classdef HeliCamInterface < handle
% HeliCamInterface  MATLAB wrapper for the HeliCam C4 via the C4HdlCLR .NET assembly.
%
% External-reference DivideBy4 lock-in operation, per
% docs/helicam_pulsed_measurement_notes.md. PulseBlaster supplies the quarter-period
% trigger train on FI2 (one edge per quarter bin); the configured reference frequency
% sets only the per-bin exposure, while the effective lock-in period comes from PB.
%
% Camera protocol (shared with FakeCamera):
%   configLockInMode(cfg)          cfg = WidefieldConfig() struct
%   startAcq()                     allocate buffers + software FrameStart
%   [I, Q] = readIQ(timeoutMs)     -> double(H, W, nFrames) each, warmup frames dropped
%   stopAcq()
%   f = readActualRefFrequency()
%
% Data extraction (see notes):
%   reference = mean(I, 3);  signal = -mean(Q, 3);  contrast = signal ./ reference
%
% Reference example: C4Utility/c4hdl/win64-x64/examples/MATLAB/c4DemodSimple.m

    properties (Access = public)
        Height (1,1) double = 512    % sensor height (pixels); updated after first readIQ
        Width  (1,1) double = 542    % sensor width  (pixels); updated after first readIQ
    end

    properties (Access = private)
        c4sys            % heliotis.C4HandlerCLR
        c4if             % interface handle
        c4dev            % device handle
        nDiscard = 0     % warmup frames to drop (firmware dependent)
    end

    methods
        % ------------------------------------------------------------------ %
        function obj = HeliCamInterface(ifNo, devNo)
        % HeliCamInterface(ifNo, devNo)  Connect to interface ifNo, device devNo (default 0,0).

            if nargin < 1 || isempty(ifNo);  ifNo  = 0; end
            if nargin < 2 || isempty(devNo); devNo = 0; end

            if ~NET.isNETSupported
                error('HeliCamInterface:NoNET', '.NET Framework not supported on this platform.');
            end

            NET.addAssembly('C4HdlCLR');
            import C4HdlCLR.*  %#ok<SIMPT>

            obj.c4sys = heliotis.C4HandlerCLR();
            obj.c4sys.reset();

            if obj.c4sys.updateInterfaceList() == 0
                error('HeliCamInterface:NoInterface', 'No GigE interfaces detected.');
            end
            obj.c4if = obj.c4sys.openInterface(ifNo);

            if obj.c4if.updateDeviceList() == 0
                error('HeliCamInterface:NoDevice', 'No HeliCam devices detected.');
            end
            obj.c4dev = obj.c4if.openDevice(devNo);

            obj.nDiscard = obj.warmupDiscardCount();
            fprintf('[HeliCam] Connected: interface %d, device %d (warmup discard %d frames).\n', ...
                    ifNo, devNo, obj.nDiscard);
        end

        % ------------------------------------------------------------------ %
        function configLockInMode(obj, cfg)
        % configLockInMode(cfg)  Configure external-reference DivideBy4 lock-in.
        %   cfg fields (see WidefieldConfig): exposureSeconds, nPeriods, nFrames,
        %   sensitivity, coupling, referenceTimeShiftUs, recordingStartExternal.

            [fRefCfg, nGrid, tExp] = HeliCamInterface.exposureToReferenceFrequency( ...
                cfg.exposureSeconds, cfg.sensitivity);

            % --- RecordingStart trigger (optional one-shot on FI3) ---
            obj.c4dev.writeString("TriggerSelector", "RecordingStart");
            if cfg.recordingStartExternal
                obj.c4dev.writeString("TriggerMode",   "On");
                obj.c4dev.writeString("TriggerSource", "FI3");
            else
                obj.c4dev.writeString("TriggerMode",   "Off");
            end

            % --- FrameStart trigger: software (issued from the sweep loop) ---
            obj.c4dev.writeString("TriggerSelector", "FrameStart");
            obj.c4dev.writeString("TriggerMode",     "On");
            obj.c4dev.writeString("TriggerSource",   "Software");

            % --- Lock-in mode, raw I/Q output ---
            obj.c4dev.writeString("DeviceOperationMode",    "LockInCam");
            obj.c4dev.writeString("Scan3dExtractionMethod", "rawIQ");

            % --- Exposure / integration ---
            obj.c4dev.writeFloat("LockInSensitivity", cfg.sensitivity);          % p_s
            obj.c4dev.writeInteger("LockInExpectedFrequencyDeviation", 0);       % d = 0: PB triggers are phase-stable
            obj.c4dev.writeFloat("LockInTargetReferenceFrequency", fRefCfg);     % sets t_s = p_s/(4*fRef)

            % --- Filter / averaging ---
            obj.c4dev.writeInteger("LockInTargetTimeConstantNPeriods", cfg.nPeriods);
            obj.c4dev.writeString("LockInCoupling", cfg.coupling);
            obj.c4dev.writeInteger("AcquisitionBurstFrameCount", cfg.nFrames);

            % --- External reference: quarter triggers direct from PB ---
            % Input line (FI2/FI3/...) is configurable; must match where CamRef
            % (PB pin 9) is physically wired. Do NOT use FI3 here if
            % recordingStartExternal is on (that also uses FI3).
            refSig = 'FI2';
            if isfield(cfg,'refSourceSignal') && ~isempty(cfg.refSourceSignal)
                refSig = cfg.refSourceSignal;
            end
            obj.c4dev.writeString("LockInReferenceSourceType",      "External");
            obj.c4dev.writeString("LockInReferenceFrequencyScaler", "DivideBy4"); % each PB edge = 1 quarter
            obj.c4dev.writeString("LockInReferenceSourceSignal",    refSig);

            % --- Phase alignment of the quarter grid to PB pulses ---
            obj.c4dev.writeFloat("LockInReferenceTimeShift", cfg.referenceTimeShiftUs); % us, ~5 ns resolution

            actualFreq = obj.c4dev.readFloat("LockInActualReferenceFrequency");
            fprintf(['[HeliCam] Lock-in (DivideBy4) configured: exposure %.3g s ', ...
                     '(n=%d, f_ref %.1f Hz, actual %.1f Hz), %d periods, %d frames.\n'], ...
                    tExp, nGrid, fRefCfg, actualFreq, cfg.nPeriods, cfg.nFrames);
        end

        % ------------------------------------------------------------------ %
        function startAcq(obj)
        % startAcq()  Allocate host-side buffer queue and issue the software FrameStart.

            obj.c4dev.startAcquisition(4);   % 4 host-side queue slots
            obj.c4dev.writeString("TriggerSelector", "FrameStart");
            obj.c4dev.executeCommand("TriggerSoftware");
        end

        % ------------------------------------------------------------------ %
        function v = readLineStatusAll(obj)
        % v = readLineStatusAll()  Bitfield of all digital input line states.
        % Pure register read: no acquisition, no triggers. Toggle a PB pin and
        % watch which bit changes to prove the signal reaches the camera.

            v = double(obj.c4dev.readInteger("LineStatusAll"));
        end

        % ------------------------------------------------------------------ %
        function [s, bitIdx, actualName] = readLineStatus(obj, lineName)
        % [s, bitIdx, actualName] = readLineStatus(lineName)  State of one line,
        % selected by name. lineName e.g. 'Line0'..'Line3', 'FI2', 'RTIO2'.
        %
        %   s          : 0/1 line state
        %   bitIdx     : the LineSelector enum's integer value, which is the bit
        %                position this line occupies in LineStatusAll (NaN if the
        %                camera will not report the enum numerically)
        %   actualName : LineSelector read back after the write. If this differs
        %                from lineName the write did not take -- the name is not
        %                supported and s belongs to some other line.
        %
        % Throws if the camera rejects lineName outright; callers probing for
        % supported names should wrap this in try/catch.

            obj.c4dev.writeString("LineSelector", lineName);
            s = double(obj.c4dev.readInteger("LineStatus"));

            bitIdx = NaN;
            try
                bitIdx = double(obj.c4dev.readInteger("LineSelector"));
            catch
            end

            actualName = lineName;
            try
                actualName = char(string(obj.c4dev.readString("LineSelector")));
            catch
            end
        end

        % ------------------------------------------------------------------ %
        function armExternalRecording(obj, refLine, nFrames)
        % armExternalRecording(refLine, nFrames)  Diagnostic: arm the camera to
        % start a plain intensity burst on a single external RecordingStart edge
        % on refLine ('FI2'/'FI3'). Returns immediately; the camera then waits
        % for the edge. Pair with readAfterTrigger. Use to test whether a TTL on
        % the reference line actually reaches the camera.

            if nargin < 2 || isempty(refLine); refLine = 'FI2'; end
            if nargin < 3 || isempty(nFrames); nFrames = 4;     end

            % TriggerSource/TriggerSelector are NOT writable while acquisition is
            % active (feature doc: "Writable in Acquisition Mode: False"); a
            % leftover acquisition from an earlier timeout makes these writes
            % throw a GenICam NULL-pointer exception. Always stop first.
            obj.stopAcq();

            obj.c4dev.writeString("DeviceOperationMode",    "LockInCam");
            obj.c4dev.writeString("Scan3dExtractionMethod", "Intensity"); % plain image
            obj.c4dev.writeInteger("AcquisitionBurstFrameCount", nFrames);

            % RecordingStart: external edge on refLine
            obj.c4dev.writeString("TriggerSelector", "RecordingStart");
            obj.c4dev.writeString("TriggerMode",     "On");
            obj.c4dev.writeString("TriggerSource",   refLine);
            % FrameStart: software
            obj.c4dev.writeString("TriggerSelector", "FrameStart");
            obj.c4dev.writeString("TriggerMode",     "On");
            obj.c4dev.writeString("TriggerSource",   "Software");

            obj.c4dev.startAcquisition(4);
            obj.c4dev.writeString("TriggerSelector", "FrameStart");
            obj.c4dev.executeCommand("TriggerSoftware");
            fprintf('[HeliCam] Armed: waiting for a RecordingStart edge on %s ...\n', refLine);
        end

        % ------------------------------------------------------------------ %
        function ok = readAfterTrigger(obj, timeoutMs)
        % ok = readAfterTrigger(timeoutMs)  Wait up to timeoutMs for the burst
        % armed by armExternalRecording. Returns true if data arrived (edge
        % detected), false on timeout. Stops acquisition either way.

            if nargin < 2 || isempty(timeoutMs); timeoutMs = 5000; end
            ok = false;
            try
                c4buf = obj.c4dev.getBuffer(timeoutMs);
                try; c4buf.release(); catch; end
                ok = true;
            catch ME
                fprintf('[HeliCam] No data: %s\n', ME.message);
            end
            obj.stopAcq();
        end

        % ------------------------------------------------------------------ %
        function [I, Q] = readIQ(obj, timeoutMs)
        % [I, Q] = readIQ(timeoutMs)  Return I and Q as double(Height, Width, nFrames).
        %
        % Buffer layout: parts 0..N-1 = I frames, parts N..2N-1 = Q frames.
        % Fixed-point decode: mod(raw, 2^15) / 2^2  (per c4DemodSimple.m).
        % The first obj.nDiscard frames (lock-in settling) are dropped.

            if nargin < 2 || isempty(timeoutMs); timeoutMs = 10000; end

            c4buf = obj.c4dev.getBuffer(timeoutMs);
            cleanupBuf = onCleanup(@() c4buf.release());

            nFrames = double(c4buf.readInteger("ChunkPartCount")) / 2;
            partDim = c4buf.getPartDimension(1);
            w = double(partDim(1));
            h = double(partDim(2));
            obj.Width  = w;
            obj.Height = h;

            Iraw = zeros(h, w, nFrames);
            Qraw = zeros(h, w, nFrames);
            for i = 0:(nFrames - 1)
                rawI = uint16(c4buf.getDataPartUint16(i));
                rawQ = uint16(c4buf.getDataPartUint16(i + nFrames));
                Iraw(:,:,i+1) = transpose(reshape(rawI, w, h));
                Qraw(:,:,i+1) = transpose(reshape(rawQ, w, h));
            end

            % Fixed-point decode: strip sign bit, scale by 1/4.
            Iraw = double(mod(Iraw, 2^15)) / 2^2;
            Qraw = double(mod(Qraw, 2^15)) / 2^2;

            % Drop warmup frames.
            nd = min(obj.nDiscard, nFrames - 1);
            I = Iraw(:,:, (nd+1):end);
            Q = Qraw(:,:, (nd+1):end);
        end

        % ------------------------------------------------------------------ %
        function stopAcq(obj)
        % stopAcq()  Stop acquisition; safe to call even if not running.
            try
                obj.c4dev.stopAcquisition();
            catch
            end
        end

        % ------------------------------------------------------------------ %
        function actualFreq = readActualRefFrequency(obj)
        % actualFreq = readActualRefFrequency()  Camera's realized reference frequency (Hz).
            actualFreq = obj.c4dev.readFloat("LockInActualReferenceFrequency");
        end

        % ------------------------------------------------------------------ %
        function delete(obj)
            obj.stopAcq();
            try; obj.c4dev.release(); catch; end
            try; obj.c4if.release();  catch; end
            try; obj.c4sys.reset();   catch; end   % free native device handle
        end
    end

    methods (Access = private)
        function n = warmupDiscardCount(obj)
        % Heliotis' Python example discards 2 frames for firmware <= 1.9.2, none for newer.
            n = 0;
            try
                fw = char(string(obj.c4dev.readString("DeviceFirmwareVersion")));
                v  = sscanf(fw, '%d.%d.%d');
                ref = [1; 9; 2];
                k = min(numel(v), numel(ref));
                le = true;
                for i = 1:k
                    if v(i) < ref(i); le = true;  break;
                    elseif v(i) > ref(i); le = false; break;
                    else; le = (numel(v) <= numel(ref)); end
                end
                if le; n = 2; end
            catch
                n = 2;   % unknown firmware: be conservative
            end
        end
    end

    methods (Static)
        function [fRef, nGrid, tExpActual] = exposureToReferenceFrequency(tExpSeconds, sensitivity)
        % Map a desired per-quarter-bin exposure to the nearest valid configured
        % reference frequency. With d = 0, t_s = sensitivity / (4*fRef) = sensitivity * n * t_c.
        %   fRef       : LockInTargetReferenceFrequency to write (Hz)
        %   nGrid      : grid index n (146..65536 for external reference)
        %   tExpActual : realized exposure (s)

            if nargin < 2 || isempty(sensitivity); sensitivity = 1.0; end
            tClock = 12.5e-9;                          % 80 MHz sensor clock cycle
            fRefMin = 306;                             % camera GenICam minimum (Hz)
            % Largest grid index whose f_ref still satisfies the 306 Hz floor
            % (n=65536 would give ~305.18 Hz, just below the limit).
            nMax = min(65536, floor(sensitivity / (fRefMin * 4 * tClock)));
            nGrid  = round(tExpSeconds / (sensitivity * tClock));
            nGrid  = min(max(nGrid, 146), nMax);       % external-ref usable grid bounds
            fRef   = sensitivity / (nGrid * 4 * tClock);
            tExpActual = sensitivity * nGrid * tClock;

            if abs(tExpActual - tExpSeconds) > tClock
                warning('HeliCamInterface:ExposureSnap', ...
                    'Requested exposure %.4g s snapped to %.4g s (n = %d).', ...
                    tExpSeconds, tExpActual, nGrid);
            end
        end
    end
end
