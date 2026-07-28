function cfg = WidefieldConfig()
% WidefieldConfig  Central config for HeliCam C4 widefield lock-in acquisition.
%
% All HeliCam / widefield parameters live here so the first-pass workflow needs
% no GUIDE .fig surgery. Edit the values below; RunSequence and
% ExperimentFunctionPool read this struct at the start of a HeliCam run.
%
% Acquisition model (see docs/helicam_pulsed_measurement_notes.md):
%   External-reference DivideBy4 lock-in. PulseBlaster supplies the quarter-period
%   trigger train on CamRef -> HeliCam FI2; each PB edge starts one quarter bin.
%   The configured reference frequency sets ONLY the per-bin exposure
%   t_s = sensitivity / (4 * f_ref * (1 + d/100)); the effective lock-in period
%   is whatever PB delivers. Exposure is therefore specified directly here as
%   exposureSeconds and converted to the nearest valid f_ref by HeliCamInterface.

    % --- Camera backend -------------------------------------------------------
    cfg.useFakeCamera = false;     % true: FakeCamera (no hardware); false: HeliCamInterface
    cfg.ifNo          = 0;        % GigE interface index
    cfg.devNo         = 0;        % device index

    % Note: to disable instruments (FPGA, SRS, ...) for a camera-only check, use
    % InstrumentEnabled.m -- not a flag here.

    % --- Lock-in acquisition (held constant across a sweep) -------------------
    cfg.exposureSeconds       = 4e-6;   % per-quarter-bin integration time t_s
    cfg.nPeriods              = 20;     % LockInTargetTimeConstantNPeriods (1..100)
    cfg.nFrames               = 60;     % AcquisitionBurstFrameCount (4..900)
    cfg.sensitivity           = 1.0;    % LockInSensitivity p_s (keep 1 so t_s = 1/(4*fRef))
    cfg.coupling              = 'DC';   % 'DC' or 'AC'
    cfg.referenceTimeShiftUs  = 0.0;    % LockInReferenceTimeShift; phase-align Q1 to PB init edge
    cfg.recordingStartExternal = false; % kept false: RecordingStart unused on this setup

    % Blank periods per frame (LockInTargetBlankDurationNPeriods, 0..100). Every
    % blank period costs another 4 CamRef edges per frame, so a nonzero value
    % here silently multiplies the edge budget PB has to supply. Written
    % explicitly (not left at whatever the camera has stored) so the budget in
    % RunSequence_HeliCam is the truth.
    cfg.blankPeriods = 0;

    % LockInExpectedFrequencyDeviation d, in percent (0..100). A jitter margin:
    % it shortens the busy window by 1/(1 + d/100) so an early trigger is not
    % missed, at the cost of exposure. 0 is right in principle for a PB-derived
    % train, but if the camera refuses to lock, 5-10 lets it tolerate the
    % exposure-grid snap. Raising this REDUCES the realized exposure.
    cfg.expectedFreqDeviationPct = 0;

    % HeliCam input line the CamRef train is wired to. Must match the physical
    % cable. 'FI2' or 'FI3'. Do not use 'FI3' with recordingStartExternal.
    % Verified 2026-07-28 by hc_TriggerTest('identify'): the CamRef pin toggles
    % FI2 (LineStatusAll bit 25), so 'FI2' is correct for this setup.
    cfg.refSourceSignal = 'FI2';

    % --- PulseBlaster quarter-period train (CamRef -> FI2) --------------------
    % Each lock-in period = 4 quarter bins; PB emits one CamRef edge per bin.
    % quarterBinNs must exceed the per-bin exposure plus ~2 us sensor overhead.
    cfg.quarterBinNs   = 25000;   % Q: spacing between CamRef edges (ns)

    % CamRef TTL pulse width (ns). [] = auto, half the quarter bin -> a ~50% duty
    % reference square wave, which is how an external lock-in reference is
    % normally driven. The previous fixed 100 ns is only 0.1% duty in a 100 us
    % bin, narrow enough that the camera input may filter it out entirely -- and
    % an ignored reference train is indistinguishable from a wiring fault: both
    % give a readIQ timeout with no data. Any explicit value is clamped to Q/2 by
    % hc_CamRefWidth. Set e.g. 100 to reproduce the old behaviour.
    cfg.camRefWidthNs  = [];

    % Surplus lock-in periods PB runs beyond what the camera consumes.
    %
    % STATUS: not the fix for the original readIQ timeout -- that was nPeriods = 1
    % demanding ~2.5 kHz of output frames. This margin has never been tested
    % alone, so it is NOT known to be necessary. It is kept as insurance, not as
    % a proven requirement.
    %
    % Why keep it: the camera's frame count (AcquisitionBurstFrameCount, over
    % GenICam) and PB's period count (the LOOP instruction) are set by unrelated
    % mechanisms and nothing enforces that they agree. With an exact fit the run
    % succeeds only if the camera consumes exactly 4*nPeriods*nFrames edges AND
    % starts on the very first one -- making a race between startAcq() and
    % Run_PB_Sequence(). Losing that race produces "Timeout, no data available!"
    % intermittently, which is expensive to diagnose. getBuffer only returns a
    % COMPLETE burst, so there is no partial data to inspect when it happens.
    % Cost is ~4 periods (~1.6 ms at readout = 100 us) per sweep point, and
    % surplus edges cannot corrupt data: the camera stops at its own frame count.
    %
    % To retire it, set 0 and confirm over ~10 consecutive runs -- a single
    % success does not disprove a race.
    cfg.camRefPeriodMargin = 4;

    % Exposure is derived from the quarter bin as
    %     exposure = readout - sensorOverheadNs - exposureMarginNs
    % sensorOverheadNs is the sensor's busy time after each integration window (a
    % property of the camera). exposureMarginNs is deliberate slack on top of it:
    % with margin 0 the quarter bin equals exposure + overhead exactly, so the
    % next CamRef edge arrives the instant the sensor frees up.
    %
    % STATUS: exposureMarginNs was also speculative, added while chasing the
    % timeout that turned out to be nPeriods = 1. Unlike camRefPeriodMargin it has
    % a REAL ONGOING COST: at readout = 100 us it throws away 2 us of every 98,
    % about 2% of signal on every measurement, which matters for NV contrast.
    % Worth testing at 0 -- if frames still return, the signal is free.
    cfg.sensorOverheadNs = 2000;
    cfg.exposureMarginNs = 2000;

    % --- Readout / display ----------------------------------------------------
    cfg.timeoutMs = 20000;        % getBuffer timeout per acquisition
    cfg.roi       = [];           % [] -> use frame center; else [xc yc halfwidth] in pixels

    % --- Sensor geometry (used by FakeCamera; real camera reports its own) ----
    cfg.height = 512;
    cfg.width  = 542;
end
