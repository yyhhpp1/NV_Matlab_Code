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
    cfg.camRefWidthNs  = 100;     % CamRef TTL pulse width (ns)

    % Surplus lock-in periods PB runs beyond the nFrames the camera is asked for.
    % getBuffer only ever returns a COMPLETE burst, so if the camera wants even
    % one more quarter edge than PB delivers -- for lock acquisition, blanking, or
    % a boundary it consumes without emitting a frame -- the burst never finishes
    % and readIQ reports "Timeout, no data available!" with no partial data. The
    % camera stops on its own frame count, so extra edges are harmless.
    cfg.camRefPeriodMargin = 4;

    % Exposure is derived from the quarter bin as
    %     exposure = readout - sensorOverheadNs - exposureMarginNs
    % sensorOverheadNs is the sensor's busy time after each integration window (a
    % property of the camera). exposureMarginNs is deliberate slack on top of it:
    % with margin 0 the quarter bin equals exposure + overhead exactly, so the
    % next CamRef edge arrives the instant the sensor frees up and any jitter or
    % rounding makes the camera miss it. Non-zero margin costs a little signal
    % and buys lock robustness.
    cfg.sensorOverheadNs = 2000;
    cfg.exposureMarginNs = 2000;

    % --- Readout / display ----------------------------------------------------
    cfg.timeoutMs = 20000;        % getBuffer timeout per acquisition
    cfg.roi       = [];           % [] -> use frame center; else [xc yc halfwidth] in pixels

    % --- Sensor geometry (used by FakeCamera; real camera reports its own) ----
    cfg.height = 512;
    cfg.width  = 542;
end
