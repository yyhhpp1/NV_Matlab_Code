# HeliCam Pulsed Measurement Notes

This note describes the lock-in acquisition mode for HeliCam C4 widefield pulsed NV
measurements and gives MATLAB-style example code using the C4Hdl CLR wrapper conventions
shown in `C4Utility/c4hdl/win64-x64/examples/MATLAB/c4DemodSimple.m`.

All sequences here assume **external reference control**: PulseBlaster (PB) supplies the
quarter-period trigger train directly, and the camera is run with
`LockInReferenceFrequencyScaler = "DivideBy4"`. In that mode the configured reference
frequency no longer sets the bin spacing — it only sets the per-bin exposure. The bin
spacing (and hence the effective lock-in period) is whatever PB delivers. This decoupling is
what makes both fixed-timing (Rabi) and swept-wait (T1) sequences clean.

The examples assume the non-camera hardware is already handled:

- PulseBlaster sequences are generated elsewhere.
- SRS / MW source configuration is generated elsewhere.
- The examples focus on camera configuration, acquisition, and data extraction.

## Lock-In Mode

Use lock-in mode when the pulse sequence is periodic and the four operations
(init / MW / dark / readout) can each be placed in one of the four quarter bins of a period.

```text
PB quarter-period triggers (DivideBy4): one TTL edge per quarter bin

  trig   trig   trig   trig
   |      |      |      |
   Q1  |  Q2  |  Q3  |  Q4
```

The camera does not return `Q1`, `Q2`, `Q3`, `Q4` independently. It returns two differential
images per lock-in frame:

```text
I = Q1 - Q3
Q = Q2 - Q4
```

For Rabi, a useful mapping is:

```text
Q1: init / reference laser
Q2: MW pulse, dark otherwise
Q3: dark
Q4: readout / signal laser
```

Then, because Q2 and Q3 carry no light:

```text
reference ~= I  = Q1 - Q3 ~=  Q1   (polarized / bright reference PL)
signal    ~= -Q = Q4 - Q2 ~=  Q4   (spin-dependent readout PL)
contrast  = signal ./ reference
```

In steady state the Q4 readout laser also re-polarizes the NV for the next period's Q1, so
Q1 is a bright/polarized reference and Q4 is the post-MW projection — i.e. the standard
normalized contrast, with the dark Q2/Q3 bins providing common-mode background subtraction.

### Reference triggering (external, DivideBy4)

```text
LockInReferenceSourceType      = "External"
LockInReferenceFrequencyScaler = "DivideBy4"   <-- each PB pulse = one quarter trigger
LockInReferenceSourceSignal    = "FI2"          (recommended input line)
```

With `DivideBy4`, frequency synthesis inside the camera is disabled and **every** reference
trigger edge starts a new quarter period of demodulation. Each quarter boundary is therefore
hardware-locked to PB (single clock), eliminating the camera-vs-PB drift that occurs with
`"Off"`, where the camera free-runs an internally synthesized quarter clock seeded once before
the burst. For pulsed NV this is the configuration to use.

Do **not** use `"Off"`: that mode takes the input as the period rate, internally multiplies by
four, and free-runs the quarter clock — the Q1..Q4 boundaries are then not locked to your
laser/MW pulses.

### Exposure / integration time per quarter bin

In external mode the exposure per bin is decoupled from the trigger spacing. After each
quarter trigger the sensor integrates for a fixed window `t_s` and then idles until the next
trigger:

```text
t_s = p_s / (4 * f_ref_cfg * (1 + d/100%))
```

where `p_s = LockInSensitivity`, `f_ref_cfg = LockInTargetReferenceFrequency`,
`d = LockInExpectedFrequencyDeviation`.

With `p_s = 1` and `d = 0` this reduces to

```text
t_s = 1 / (4 * f_ref_cfg) = n * t_c ,   t_c = 12.5 ns (80 MHz sensor clock)
```

so the exposure is **fixed and tunable** purely through the configured reference frequency,
which lands on the discrete grid `f_ref_cfg = 1 / (n * 4 * t_c)`, `n in {146, ..., 65536}`.

```text
Want t_s = 4 us  ->  n = 320  ->  f_ref_cfg = 62.5 kHz  ->  t_s = 4.000 us exactly
```

Because the bin spacing comes from PB, `t_s` stays identical across an entire sweep regardless
of how the wait or MW time changes. This keeps per-point signal level, background, and noise
uniform, so the points are directly comparable.

### Why expectedFrequencyDeviation = 0

`LockInExpectedFrequencyDeviation` (d) is a jitter margin: it artificially shortens the busy
window so an early-arriving trigger is not missed, at the cost of a shorter exposure and
reduced signal amplitude. Any `d > 0` scales the exposure down by `1/(1 + d/100%)` — e.g.
`d = 5%` gives `t_s = 3.81 us` instead of 4 us. Because the trigger train here is PB-derived
and phase-stable, triggers never arrive early, so the margin buys nothing and only costs
amplitude. Set `d = 0`.

### Phase alignment (LockInReferenceTimeShift)

Even with DivideBy4, the exposure window starts right after each trigger (not centered), so the
Q1 boundary must be phased onto the PB init pulse. `LockInReferenceTimeShift`
(alias `TriggerDelay[Reference]`) delays the external reference with ~5 ns resolution
(feature `Inc = 0.015 us`) over `0 .. 489.6 us`. Make it a tunable knob and set it so the
exposed slice of each bin overlaps the intended laser/MW window. `TriggerActivation[Reference]`
selects the rising/falling edge.

### Hardware limits (external reference)

```text
exposure t_s (p_s=1, d=0):  1.825 us .. 819.2 us   (n * 12.5 ns, n = 146 .. 65536)
configured f_ref (exposure setter):  ~137 kHz .. ~305 Hz   on the 1/(n*4*t_c) grid
quarter-trigger spacing:     PB-limited (must exceed t_s + ~2 us sensor overhead)
effective lock-in period:    set by PB; NO 305 Hz floor under external DivideBy4
max wait / max period:       PB- and physics-limited, not camera-limited
LockInTargetTimeConstantNPeriods (demod periods/frame): 1 .. 100
LockInTargetBlankDurationNPeriods (blank periods/frame): 0 .. 100
AcquisitionBurstFrameCount:  4 .. 900
LockInReferenceTimeShift:    0 .. 489.6 us, ~5 ns resolution (Inc 0.015 us)
LockInSensitivity (p_s):     0.0 .. 1.0
LockInExpectedFrequencyDeviation (d): 0 .. 100 %
LockInCoupling:              DC (default) or AC
```

Note: the 305 Hz internal-grid floor applies only to the *configured* reference frequency
(the exposure setter). The effective period — the time PB spaces between Q1 triggers — is not
bounded by the camera, so long T1 waits are reachable that the internal-reference scheme could
not produce.

### Trigger logic

```text
FrameStart trigger:     software trigger (c4dev.executeCommand("TriggerSoftware"))
                        Burst acquisition is initiated from the MATLAB sweep loop.

RecordingStart trigger: optional one-shot PB TTL on FI3.
                        Default TriggerMode="Off" (camera records immediately after
                        FrameStart). Set TriggerMode="On" + TriggerSource="FI3" when tight
                        hardware synchronisation to PB is required.

Reference trigger:      continuous PB quarter-period train on FI2 (DivideBy4): one edge at the
                        start of each quarter bin (Q1, Q2, Q3, Q4). It runs throughout the
                        whole burst and defines the bin boundaries. Use a separate PB pin from
                        the RecordingStart one-shot.
```

## Example 1: Fixed-timing Lock-In Rabi (sweep MW in PB only)

Fixed exposure (4 us) and fixed, uniform quarter-trigger spacing. Camera is configured **once**;
only the PB MW-on-time changes per point.

```matlab
function result = ExampleWidefieldRabiLockIn(c4dev, rabiTimesNs)
% HeliCam C4 fixed-timing lock-in Rabi acquisition (external DivideBy4).
%
% Assumptions:
%   - c4dev is already opened using C4HandlerCLR/openInterface/openDevice.
%   - PB programming for each rabiTimesNs(j) is done elsewhere.
%   - PB provides a uniform quarter-period trigger train on FI2 (DivideBy4).
%   - Optional PB RecordingStart is on FI3.
%
% Output:
%   result.reference/signal/contrast(height,width,j)
%   result.rawI/rawQ(height,width,frame,j)

    % --- Fixed acquisition design ---
    exposureSeconds      = 4e-6;     % per-quarter-bin integration time (tunable, fixed for sweep)
    quarterSpacingSeconds = 25e-6;   % PB-set spacing between quarter triggers (-> 10 kHz period)
    nPeriods             = 100;      % demod periods per output frame
    nFrames              = 60;       % output lock-in frames per acquisition
    sensitivity          = 1.0;      % p_s; keep at 1 so t_s = 1/(4*f_ref_cfg)
    coupling             = "DC";     % use AC only if saturation demands it
    referenceTimeShiftUs = 0.0;      % phase-align Q1 boundary to PB init edge; tune as needed
    recordingStartExternal = false;

    [fRefCfg, nGrid, tExpActual] = exposureToReferenceFrequency(exposureSeconds);

    configureLockInCamera(c4dev, fRefCfg, nPeriods, nFrames, sensitivity, ...
        coupling, referenceTimeShiftUs, recordingStartExternal);

    actualRefFrequency = c4dev.readFloat("LockInActualReferenceFrequency");
    fprintf("Configured f_ref (exposure setter): %.3f Hz (n = %d)\n", fRefCfg, nGrid);
    fprintf("Actual    f_ref: %.3f Hz\n", actualRefFrequency);
    fprintf("Exposure per quarter bin t_s: %.3g s\n", tExpActual);
    fprintf("PB quarter-trigger spacing: %.3g s\n", quarterSpacingSeconds);

    % startAcquisition argument is host-side buffer queue depth, not frame count.
    c4dev.startAcquisition(4);
    cleanupObj = onCleanup(@() safeStopAcquisition(c4dev));

    for j = 1:numel(rabiTimesNs)
        % External code programs PB for this rabi time:
        %   FI2: uniform quarter triggers at quarterSpacingSeconds (Q1..Q4)
        %   Q1: init/reference laser   (right after its trigger, within t_s)
        %   Q2: MW pulse of duration rabiTimesNs(j) ns (dark otherwise)
        %   Q3: dark
        %   Q4: readout/signal laser   (right after its trigger, within t_s)
        programPulseBlasterForLockInRabi(rabiTimesNs(j));

        % FrameStart -> (RecordingStart) -> record burst.
        c4dev.writeString("TriggerSelector", "FrameStart");
        c4dev.executeCommand("TriggerSoftware");

        startPulseBlaster();   % sends the quarter-trigger train (+ optional RecordingStart)

        c4buf = c4dev.getBuffer(10000); % timeout in ms
        cleanupBuf = onCleanup(@() c4buf.release());

        [I, Q] = readRawIQBuffer(c4buf);
        [Iuse, Quse] = discardFirmwareWarmupFrames(c4dev, I, Q);

        reference = mean(Iuse, 3);
        signal    = -mean(Quse, 3);
        contrast  = signal ./ reference;

        result.reference(:, :, j) = reference;
        result.signal(:, :, j)    = signal;
        result.contrast(:, :, j)  = contrast;
        result.rawI(:, :, :, j)   = I;
        result.rawQ(:, :, :, j)   = Q;

        clear cleanupBuf
    end
end
```

## Example 2: Swept-wait Lock-In T1 (exposure fixed, effective period set by PB)

For T1, the exposure stays fixed (4 us) and the **configured reference frequency stays fixed**
— it only sets the exposure. The swept dark wait is carried entirely by the PB trigger spacing:
the Q3->Q4 gap grows with `tau`, so the *effective* lock-in period (1/T_ref) decreases per
point even though the configured reference frequency does not change. The camera is configured
**once**; only the PB trigger timing changes per point.

This removes the internal-reference ~1.6 ms wait ceiling: the maximum reachable wait is bounded
by PB and NV physics, not by the camera.

```matlab
function result = ExampleWidefieldT1LockIn(c4dev, waitTimesSeconds)
% HeliCam C4 swept-wait lock-in T1 acquisition (external DivideBy4).
%
% The wait is carried by PB quarter-trigger spacing; exposure is fixed.
%
% Quarter-bin mapping:
%   Q1: init / reference laser  (polarized bright reference)
%   Q2: dark   (part of the wait)
%   Q3: dark   (part of the wait)
%   Q4: readout / signal laser  (after the wait)
%
% Output:
%   result.reference/signal/contrast(height,width,j)
%   result.rawI/rawQ(height,width,frame,j)
%   result.wait(j)

    % --- Fixed camera design (held constant over the whole sweep) ---
    exposureSeconds      = 4e-6;     % per-quarter-bin integration time (fixed)
    nPeriods             = 20;       % demod periods/frame (frame time grows with wait)
    nFrames              = 60;       % output lock-in frames per acquisition
    sensitivity          = 1.0;      % p_s = 1  -> t_s = 1/(4*f_ref_cfg)
    coupling             = "DC";
    referenceTimeShiftUs = 0.0;      % phase-align Q1 to PB init edge; tune as needed
    recordingStartExternal = true;   % T1 usually wants tight PB sync

    [fRefCfg, nGrid, tExpActual] = exposureToReferenceFrequency(exposureSeconds);

    % Configure ONCE outside the loop: nothing on the camera changes per wait time.
    configureLockInCamera(c4dev, fRefCfg, nPeriods, nFrames, sensitivity, ...
        coupling, referenceTimeShiftUs, recordingStartExternal);

    fprintf("Configured f_ref (fixed exposure setter): %.3f Hz (n = %d)\n", fRefCfg, nGrid);
    fprintf("Exposure per quarter bin t_s (fixed): %.3g s\n", tExpActual);

    c4dev.startAcquisition(4);
    cleanupObj = onCleanup(@() safeStopAcquisition(c4dev));

    overheadSeconds = 2e-6;  % sensor busy overhead after exposure, per quarter bin

    for j = 1:numel(waitTimesSeconds)
        tauWait = waitTimesSeconds(j);

        % Each quarter gap must exceed t_s + overhead; the wait is split across Q2+Q3,
        % so the per-gap requirement is trivially met for any realistic T1 wait.
        if tauWait < 2 * (tExpActual + overheadSeconds)
            warning("Wait %.3g s is short; consider folding it into a single dark gap.", tauWait);
        end

        % External code programs PB for this wait:
        %   FI2 quarter triggers placed so that
        %     Q1 (init) -> [dark Q2] -> [dark Q3, total Q2+Q3 ~= tauWait] -> Q4 (readout)
        %   The effective period T_ref = sum of the four quarter gaps grows with tauWait,
        %   but f_ref_cfg (exposure) is unchanged.
        %   The same period structure repeats nPeriods times within each frame.
        programPulseBlasterForLockInT1(tauWait);

        c4dev.writeString("TriggerSelector", "FrameStart");
        c4dev.executeCommand("TriggerSoftware");

        startPulseBlaster();   % RecordingStart one-shot (FI3) + quarter-trigger train (FI2)

        c4buf = c4dev.getBuffer(20000); % longer timeout: frames are longer at large wait
        cleanupBuf = onCleanup(@() c4buf.release());

        [I, Q] = readRawIQBuffer(c4buf);
        [Iuse, Quse] = discardFirmwareWarmupFrames(c4dev, I, Q);

        reference = mean(Iuse, 3);
        signal    = -mean(Quse, 3);
        contrast  = signal ./ reference;

        result.reference(:, :, j) = reference;
        result.signal(:, :, j)    = signal;
        result.contrast(:, :, j)  = contrast;
        result.rawI(:, :, :, j)   = I;
        result.rawQ(:, :, :, j)   = Q;
        result.wait(j)            = tauWait;

        clear cleanupBuf
    end
end
```

## Camera Configuration

```matlab
function configureLockInCamera(c4dev, fRefCfg, nPeriods, nFrames, sensitivity, ...
    coupling, referenceTimeShiftUs, recordingStartExternal)
% Configure the C4 for external-reference DivideBy4 lock-in operation.
% fRefCfg sets the per-bin exposure only (bin spacing comes from PB).

    % --- RecordingStart ---
    c4dev.writeString("TriggerSelector", "RecordingStart");
    if recordingStartExternal
        c4dev.writeString("TriggerMode", "On");
        c4dev.writeString("TriggerSource", "FI3");
    else
        c4dev.writeString("TriggerMode", "Off");
    end

    % --- FrameStart is software ---
    c4dev.writeString("TriggerSelector", "FrameStart");
    c4dev.writeString("TriggerMode", "On");
    c4dev.writeString("TriggerSource", "Software");

    % --- Lock-in mode and raw I/Q output ---
    c4dev.writeString("DeviceOperationMode", "LockInCam");
    c4dev.writeString("Scan3dExtractionMethod", "rawIQ");

    % --- Exposure / integration ---
    c4dev.writeFloat("LockInSensitivity", sensitivity);             % p_s
    c4dev.writeInteger("LockInExpectedFrequencyDeviation", 0);      % d = 0: PB triggers are stable
    c4dev.writeFloat("LockInTargetReferenceFrequency", fRefCfg);    % sets t_s = p_s/(4*fRefCfg)

    % --- Filter / averaging ---
    c4dev.writeInteger("LockInTargetTimeConstantNPeriods", nPeriods);
    c4dev.writeString("LockInCoupling", coupling);
    c4dev.writeInteger("AcquisitionBurstFrameCount", nFrames);

    % --- External reference, quarter triggers direct from PB ---
    c4dev.writeString("LockInReferenceSourceType", "External");
    c4dev.writeString("LockInReferenceFrequencyScaler", "DivideBy4"); % each PB pulse = 1 quarter
    c4dev.writeString("LockInReferenceSourceSignal", "FI2");

    % --- Phase alignment of the quarter grid to PB pulses (tunable) ---
    c4dev.writeFloat("LockInReferenceTimeShift", referenceTimeShiftUs); % us, ~5 ns resolution
end

function [fRef, nGrid, tExpActual] = exposureToReferenceFrequency(tExpSeconds)
% Map a desired per-quarter-bin exposure to the nearest valid configured reference
% frequency, assuming p_s = 1 and d = 0 so that t_s = 1/(4*fRef) = n*t_c.
%
%   tExpSeconds : desired exposure (s)
%   fRef        : configured LockInTargetReferenceFrequency (Hz)
%   nGrid       : grid index n
%   tExpActual  : realized exposure (s)

    tClock = 12.5e-9;                 % 80 MHz sensor clock cycle
    nGrid  = round(tExpSeconds / tClock);
    nGrid  = min(max(nGrid, 146), 65536);  % external-ref usable grid bounds
    fRef   = 1 / (nGrid * 4 * tClock);
    tExpActual = nGrid * tClock;      % = p_s/(4*fRef) at p_s=1, d=0

    if abs(tExpActual - tExpSeconds) > tClock
        warning("Requested exposure %.4g s snapped to %.4g s (n = %d).", ...
            tExpSeconds, tExpActual, nGrid);
    end
end
```

## Shared Helpers

```matlab
function [I, Q] = readRawIQBuffer(c4buf)
% Return I and Q as [height, width, nFrames].

    nParts  = c4buf.readInteger("ChunkPartCount");
    nFrames = nParts / 2;

    frameDimension = c4buf.getPartDimension(1);
    width  = frameDimension(1);
    height = frameDimension(2);

    I = zeros(height, width, nFrames);
    Q = zeros(height, width, nFrames);

    for i = 0:(nFrames - 1)
        rawI = uint16(c4buf.getDataPartUint16(i));
        rawQ = uint16(c4buf.getDataPartUint16(i + nFrames));

        I(:, :, i + 1) = transpose(reshape(rawI, width, height));
        Q(:, :, i + 1) = transpose(reshape(rawQ, width, height));
    end

    % Same fixed-point conversion used by c4DemodSimple.m.
    I = double(mod(I, 2^15)) / 2^2;
    Q = double(mod(Q, 2^15)) / 2^2;
end

function [Iuse, Quse] = discardFirmwareWarmupFrames(c4dev, I, Q)
% Older firmware can produce initial frames lacking information.
% Heliotis' Python example discards 2 frames for firmware <= 1.9.2 and none for newer.
% Verify the exact feature name in the CLR wrapper before relying on this.

    try
        fw = string(c4dev.readString("DeviceFirmwareVersion"));
        nDiscard = firmwareLessOrEqual(fw, "1.9.2") * 2;
    catch
        nDiscard = 0;
    end
    if size(I, 3) > nDiscard
        Iuse = I(:, :, (nDiscard + 1):end);
        Quse = Q(:, :, (nDiscard + 1):end);
    else
        Iuse = I;
        Quse = Q;
    end
end

function safeStopAcquisition(c4dev)
    try
        c4dev.stopAcquisition();
    catch
    end
end

function tf = firmwareLessOrEqual(firmwareVersion, referenceVersion)
% Minimal placeholder for semantic version comparison.
    fw  = sscanf(firmwareVersion, "%d.%d.%d");
    ref = sscanf(referenceVersion, "%d.%d.%d");
    n = min(numel(fw), numel(ref));
    tf = false;
    for i = 1:n
        if fw(i) < ref(i)
            tf = true;  return
        elseif fw(i) > ref(i)
            tf = false; return
        end
    end
    tf = numel(fw) <= numel(ref);
end

function programPulseBlasterForLockInRabi(~)
% Stub: implemented by existing PulseBlaster sequence infrastructure.
% Uniform quarter triggers on FI2; MW swept inside Q2.
end

function programPulseBlasterForLockInT1(~)
% Stub: implemented by existing PulseBlaster sequence infrastructure.
% Quarter triggers on FI2 with Q2+Q3 gap carrying the swept wait.
end

function startPulseBlaster()
% Stub: implemented by existing PulseBlaster sequence infrastructure.
end
```
