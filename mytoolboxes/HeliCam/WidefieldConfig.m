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
    cfg.ifNo          = 1;        % GigE interface index
    cfg.devNo         = 0;        % device index

    % Note: to disable instruments (FPGA, SRS, ...) for a camera-only check, use
    % InstrumentEnabled.m -- not a flag here.

    % --- Lock-in acquisition (held constant across a sweep) -------------------
    cfg.exposureSeconds       = 4e-6;   % per-quarter-bin integration time t_s
    cfg.nPeriods              = 20;     % LockInTargetTimeConstantNPeriods (effective 2..100)
    cfg.nFrames               = 4;     % AcquisitionBurstFrameCount (4..900)
    cfg.sensitivity           = 1;    % LockInSensitivity p_s (keep 1 so t_s = 1/(4*fRef))
    cfg.coupling              = 'DC';   % 'DC' or 'AC'
    cfg.referenceTimeShiftUs  = 0;   % LockInReferenceTimeShift; phase-align Q1 to PB init edge
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
    cfg.expectedFreqDeviationPct = 5;

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

    % Sensor busy time after each integration window, subtracted from the quarter
    % bin to get the exposure:  exposure = readout - sensorOverheadNs.
    %
    % PB emits exactly the periods the camera consumes -- no surplus -- and the
    % quarter bin equals exposure + overhead exactly, with no extra slack. Both of
    % those were carried as configurable margins while the readIQ timeout was
    % being chased; the cause turned out to be nPeriods = 1 demanding ~2.5 kHz of
    % output frames, and 20 consecutive acquisitions with both margins at zero
    % confirmed neither was doing anything. Removed rather than left as dead
    % knobs. (Verified 2026-07-28, readout = 100 us, nPeriods = 20, nFrames = 10.)
    cfg.sensorOverheadNs = 2000;

    % Subtract the STORED per-pixel dark reference (hc_DarkRef's wf_darkref.mat)
    % from every acquired I/Q before contrast is formed. The C4 carries a large
    % static pedestal (~518 in decoded units) plus fixed-pattern structure; both
    % are removed by this. Silently skipped when no dark reference has been stored.
    %
    % This flag governs ONLY the stored-file path, which is a single slot shared by
    % every settings combination and so can easily be stale -- the pedestal scales
    % with exposure/nPeriods/nFrames. The 'takeDarkRef' checkbox on
    % Experiment_PB_DAQ is the better route: it acquires one fresh laser-off burst
    % at the start of each run, matched to that run's camera settings by
    % construction, and subtracts it regardless of this flag.
    cfg.subtractDarkRef = false;

    % --- Widefield Z stack (hc_ZScan) -----------------------------------------
    % Objective Z travel, in micrometres, that hc_ZScan is allowed to command on
    % the Obj_Piezo analog output. WriteVoltage range-checks only the galvos, so
    % nothing else stops a mistyped sweep from driving the objective into the
    % sample: RunSequence_HeliCam refuses to start when any requested Z falls
    % outside this range. Refusing rather than clamping is deliberate -- a
    % clamped sweep would silently stack several frames at the rail and look
    % like a real Z series.
    cfg.zMinUm = 0;
    cfg.zMaxUm = 100;

    % Settle time after each Z move, in seconds. [] = auto, one full acquisition
    % burst (nPBPeriods x the reference period), so the wait scales with the
    % sequence timing, nPeriods and nFrames rather than being a fixed guess.
    % NOTE: that can be only a few ms at short readouts (e.g. ~6 ms at readout
    % 200 us, nPeriods 2, nFrames 4), which may be well under the piezo's
    % mechanical settling time. Set an explicit value here if the first Z of a
    % stack looks smeared relative to the rest.
    cfg.zSettleSeconds = [];

    % --- Widefield autofocus (hc_ZScan focus metric) --------------------------
    % Scoring the sharpness of each Z so hc_ZScan can report, and park at, the
    % best-focus position. See hc_FocusMask / hc_FocusMetric for the reasoning;
    % hc_FocusConfig resolves these and lets any of them be overridden per-run by
    % setting the same name on gmSEQ.
    %
    % A stripline sits ~50 um above the diamond and casts a dark shadow. Its EDGE
    % is the sharpest feature in the frame and belongs to a plane 50 um off the
    % NV layer, so a gradient score that can see it peaks with the STRIPLINE in
    % focus. Excluding the dark pixels is not enough on its own -- the edge is at
    % the boundary of the dark region, which is why focusErodePx exists.

    % Which score drives the live curve and the parking decision:
    % 'tenengrad' (normalised squared Sobel gradient -- sharpest peak, the
    % default), 'normvar' (var/mean^2, derivative-free and the most noise
    % tolerant), 'brenner', or 'laplacian'. All four are computed and saved
    % whatever this says, so hc_FocusCompare can second-guess the choice offline
    % from a saved file rather than from another hour of beam time.
    cfg.focusMetric = 'tenengrad';

    % A pixel is "in shadow" if its brightness falls below this fraction of the
    % frame's own bright level at ANY Z in the stack. Raise it to cut more
    % aggressively into the penumbra; lower it if the mask is eating real signal.
    % Setting it to 0 disables shadow rejection entirely -- useful exactly once,
    % as the negative control that shows how far the stripline edge pulls the
    % answer (see the hc_ZScan header).
    cfg.focusDarkFrac = 0.35;

    % Percentile of |I| that defines each frame's "bright level". Per-frame, so
    % the threshold above stays scale-free as the frame dims and spreads with
    % defocus. Below 100 so a few hot pixels cannot set the scale.
    cfg.focusBrightPct = 95;

    % Exclude pixels brighter than this multiple of the frame's bright level.
    % A handful of hot pixels would otherwise plant a Z-independent spike in a
    % gradient score and flatten the real peak next to it.
    cfg.focusHotFactor = 3;

    % Pixels of valid-region erosion -- how far back from the shadow boundary the
    % scored region stops. THIS is what keeps the stripline edge out of the score.
    % Floored at 2 by hc_FocusConfig because the 3x3 smooth composed with the 3x3
    % Sobel has a 5x5 footprint, so anything smaller lets the edge leak back in
    % through the filter. Raise it if the shadow's penumbra is broad.
    cfg.focusErodePx = 3;

    % 3x3 binomial pre-smooth before differentiating. Squaring a derivative
    % amplifies pixel noise, and on a dim sample that noise floor can rival the
    % focus contrast. Costs almost no real resolution here.
    cfg.focusSmooth = true;

    % Refuse to trust a mask that kept fewer than this many pixels (or 1% of the
    % frame, whichever is larger): hc_FocusMask falls back to the plain interior
    % and says so, rather than returning a confident number from 40 pixels.
    cfg.focusMinValidPx = 500;

    % Park the objective at the best-focus Z when the run ends -- but only when
    % the peak is a genuine INTERIOR maximum. An argmax sitting on the first or
    % last Z means focus is outside the scanned range, and hc_ZScan restores the
    % starting Z and says which way to extend instead. false = always restore.
    cfg.focusGoToBest = true;

    % Minimum max(F)/median(F) for the curve to count as having a peak at all.
    % A flat curve still has an argmax, and it is noise; below this the run
    % reports "no focus found" and restores Z.
    cfg.focusMinConf = 1.2;

    % --- Readout / display ----------------------------------------------------

    %%%%%% CHANGE ROI TO OVERWRITE ROI BOX %%%%%%%
    % readIQ/getBuffer timeout. This is now the FLOOR, not the whole story:
    % hc_AcqTimeoutMs sizes the actual timeout from the predicted burst duration
    % (nPBPeriods x the real PB program length), so a long measurement is not
    % aborted mid-flight. A fixed 20 s used to cut off any burst that ran longer
    % -- reporting a healthy measurement as "Timeout, no data available!".
    cfg.timeoutMs = 20000;        % minimum getBuffer timeout (ms)

    % Safety factor on the predicted burst duration. 2 = allow the burst to take
    % twice as long as predicted before giving up, which absorbs camera readout,
    % GigE transfer and any period the prediction underestimates.
    cfg.timeoutFactor = 2;

    % Fixed slack added on top, in ms: buffer transfer and GigE latency that do
    % not scale with the burst.
    cfg.timeoutMarginMs = 10000;

    % Hard ceiling on the computed timeout, in ms. Without one, a mis-set
    % quarter bin or frame count could ask MATLAB to block for days on a camera
    % that will never answer. 30 min by default; raise it if a genuine burst is
    % longer than that (hc_AcqTimeoutMs says so when it clamps). Note readIQ
    % blocks for the whole wait and Stop is only polled between sweep points, so
    % this also bounds how long Stop can take to act.
    cfg.timeoutMaxMs = 1800000;
    cfg.roi       = [300,300,1];           % [] -> use frame center; else [xc yc halfwidth] in pixels
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % --- Sensor geometry (used by FakeCamera; real camera reports its own) ----
    cfg.height = 512;
    cfg.width  = 542;
end
