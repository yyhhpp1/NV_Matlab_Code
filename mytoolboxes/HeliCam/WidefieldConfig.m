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
    cfg.useFakeCamera = true;     % true: FakeCamera (no hardware); false: HeliCamInterface
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

    % HeliCam input line the CamRef (PB pin 9) train is wired to. Must match the
    % physical cable. 'FI2' or 'FI3'. Do not use 'FI3' with recordingStartExternal.
    cfg.refSourceSignal = 'FI2';

    % --- PulseBlaster quarter-period train (CamRef -> FI2) --------------------
    % Each lock-in period = 4 quarter bins; PB emits one CamRef edge per bin.
    % quarterBinNs must exceed the per-bin exposure plus ~2 us sensor overhead.
    cfg.quarterBinNs   = 25000;   % Q: spacing between CamRef edges (ns)
    cfg.camRefWidthNs  = 100;     % CamRef TTL pulse width (ns)

    % --- Readout / display ----------------------------------------------------
    cfg.timeoutMs = 20000;        % getBuffer timeout per acquisition
    cfg.roi       = [];           % [] -> use frame center; else [xc yc halfwidth] in pixels

    % --- Sensor geometry (used by FakeCamera; real camera reports its own) ----
    cfg.height = 512;
    cfg.width  = 542;
end
