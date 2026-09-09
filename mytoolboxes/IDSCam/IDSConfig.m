function cfg = IDSConfig()
% IDSConfig  Central config for IDS uEye+ U3-3140CP-M widefield acquisition.
%
% Twin of WidefieldConfig.m, for the plain-intensity camera rather than the
% HeliCam C4 lock-in. Same principle: everything lives here so the first-pass
% workflow needs no GUIDE .fig surgery.
%
% ACQUISITION MODEL -- read this before changing any number below.
%
% The IDS is NOT a lock-in camera. ExposureMode is [ReadOnly] = Timed and
% SensorShutterMode is [ReadOnly] = Global, so one trigger buys exactly one
% exposure window and one number per pixel. There is no in-pixel demodulation to
% separate signal from reference inside a frame, the way the C4's four quarter
% bins do. So the separation moves OUT of the frame and BETWEEN frames:
%
%   one PB program run = [ N shots, MW on ][ N shots, MW off ]
%                        |<-- SIG frame -->|<-- REF frame -->|
%
% PB emits one CamTrig rising edge at the start of each block (PB pin 8 ->
% physical GPIO1 = GenICam Line2). The camera integrates the whole block. MATLAB
% then reads the frames back in pairs:
%
%   I(:,:,k) = REF frame of pair k      (MW off -- the normaliser)
%   Q(:,:,k) = SIG frame of pair k      (MW on  -- the measurement)
%   contrast = Q ./ I                   (formed on demand, never stored)
%
% Note this is a DIFFERENT convention from the HeliCam path, where I and Q are
% quadrature DIFFERENCES and readIQ applies a polarity inversion. Here both are
% raw summed ADU, both positive, and nothing is negated anywhere. The natural
% display expression is therefore 'Q./I' (near 1 with a dip), not 'I'.
%
% WHY PB OWNS THE FRAME BOUNDARY (scheme B1, not B5)
%
% CAMERA_FINDINGS.md sec.6 recommends B5 -- PB clocks every shot and the camera
% divides by N in hardware (TriggerDivider) so the two crystals cannot drift
% apart. That does not work here: PBFunctionPool wraps the whole program in ONE
% hardware LOOP, so every shot is identical and therefore every frame would be
% identical too. Perfect drift immunity, zero contrast.
%
% Writing the block pair into the sequence file instead gets the same immunity
% for free. Every frame boundary is a PB edge, so nothing accumulates and there
% is no integration path for drift -- each frame is independently commanded. The
% 0..5.5556 us trigger quantisation (findings sec.4.5) survives, and is harmless:
% it displaces the exposure window as a whole, and the window opens and closes
% inside a dark guard interval where no light is being collected.
%
% See docs/IDSCAM_HANDOFF.md for the full timing diagram.

    % --- Camera backend -------------------------------------------------------
    % true: FakeIDSCamera (synthetic, no hardware, exercises the whole
    % RunSequence_IDSCam path); false: IDSCamInterface against the real camera.
    cfg.useFakeCamera = true;

    % Python interpreter MATLAB loads for the acquisition backend.
    %
    % MUST be 3.9-3.11: that is what R2023b's in-process py. bridge supports.
    % The machine default (C:\Conda\python.exe) is 3.13 and will NOT load.
    % heli_cam_env is 3.11.5 and already carries harvesters + genicam + h5py,
    % which is the whole dependency list -- ids_peak is deliberately NOT used
    % (it is not installed here, and every node this integration touches is
    % standard GenICam reachable through the GenTL producer).
    cfg.pythonExe = 'C:\Conda\envs\heli_cam_env\python.exe';

    % GenTL producer for USB3 Vision. Shipped by the IDS peak SDK installer.
    cfg.ctiPath = 'C:\Program Files\IDS\ids_peak\ids_u3vgentl\64\ids_u3vgentlk.cti';

    % Which enumerated device, when more than one is attached. 0 = first.
    cfg.deviceIndex = 0;

    % --- Region of interest ---------------------------------------------------
    % Frame time is dominated by HEIGHT; width matters much less for readout but
    % a lot for USB bandwidth at Mono10 (findings sec.4.1). Cropping height is the
    % cheap way to go faster.
    %
    %   1280x1024 -> 5.80 ms      1280x256 -> 1.54 ms (Mono8)
    %   1280x512  -> 3.34 ms      1280x64  -> 0.47 ms (Mono8)
    cfg.width     = 1280;
    cfg.height    = 256;
    cfg.offsetX   = [];      % [] = centre horizontally
    cfg.offsetY   = [];      % [] = centre vertically

    % 'Mono8', 'Mono10' or 'Mono10p'. Mono10 costs USB bandwidth on wide ROIs
    % (1280x256 goes 1.54 -> 1.67 ms) and buys 2 bits that the shot noise of an
    % accumulated widefield frame will usually swamp. Mono8 unless you have
    % checked you need otherwise.
    cfg.pixelFormat = 'Mono8';

    % --- Shot --------------------------------------------------------------
    % One shot = one NV init/manipulate/read cycle. Its length is held FIXED
    % across a sweep, with the swept quantity (MW duration, dark wait, ...)
    % absorbed into the trailing idle rather than added to the shot.
    %
    % That is not a stylistic choice. If the shot stretched with the sweep, so
    % would the block, the exposure, the frame rate and the dark pedestal -- the
    % camera would need reconfiguring at every point and the pedestal
    % subtraction would be right at exactly one of them. Holding the shot fixed
    % makes every sweep point the same measurement with one thing changed, which
    % is the same reasoning behind the existing Rabi_fixMWDutyCycle /
    % T1_..._fixDutyCycle sequences on the confocal side.
    %
    % Overridable per run from a GUI box: see ids_ShotNs.
    cfg.shotNs = 25000;      % 25 us

    % Green pulse at the start of each shot. Does double duty: it reads out the
    % previous shot and re-initialises for this one, which is standard for
    % widefield and is why there is only one laser pulse per shot.
    cfg.laserNs = 5000;      % 5 us

    % CamTrig TTL width (ns). Wide enough to be unmissable -- this camera has NO
    % debouncer and NO trigger filter (findings sec.2.5), so there is no input
    % latency to fear, but equally no glitch rejection, and a narrow pulse buys
    % nothing. Must stay well under the guard interval.
    cfg.camTrigWidthNs = 2000;

    % --- Block plan -----------------------------------------------------------
    % shotsPerBlock is bounded by PB INSTRUCTION MEMORY, not by the camera: the
    % sequence writes every shot's edges explicitly, at roughly 4 instructions per
    % shot per block pair. Check your PBESR-PRO's depth before raising it.
    % ids_BlockPlan validates the whole plan and refuses an impossible one.
    cfg.shotsPerBlock = 76;

    % Dark guard at the END of each block: laser off, MW off, nothing happening.
    % This is where the exposure window is allowed to close and where the
    % camera's 23 us turnaround is absorbed, so no optical pulse is ever clipped
    % by a frame boundary. It is the shock absorber for the whole timing plan --
    % if ExposureTriggerMissed starts firing, lengthen THIS before touching
    % anything else.
    %
    % Must comfortably exceed 23 us (dead time) + 5.556 us (trigger quantisation).
    cfg.guardNs = 100000;    % 100 us

    % Exposure is set to (block - guard slack), snapped DOWN to the camera's
    % 5.5556 us grid, then backed off by this many further grid quanta.
    %
    % 1, not 0, and the reason is not conservatism. Consecutive frames carry
    % INDEPENDENT quantisation offsets Q in [0, 5.5556] us. The camera must be
    % free at (next trigger + Q_next) having become busy at (this trigger +
    % Q_prev), so the worst case eats up to a full quantum of margin. One spare
    % quantum removes that failure mode outright.
    cfg.exposureBackoffQuanta = 1;

    % --- Frames ---------------------------------------------------------------
    % Number of SIG/REF frame pairs per acquisition burst. The camera is asked
    % for exactly 2*framePairs frames and PB is looped exactly framePairs times,
    % so the trigger count and the frame count match by construction.
    %
    % That equality is a safety property, not bookkeeping: if a trigger IS
    % missed, the last frame never arrives and the fetch times out LOUDLY,
    % instead of completing with the SIG/REF assignment silently inverted for
    % every frame after the miss. Never request fewer frames than PB triggers.
    cfg.framePairs = 10;

    % --- Trigger in (scheme B1) -----------------------------------------------
    % 'Line2' = physical GPIO1, 'Line3' = physical GPIO2. Both LVTTL and
    % bidirectional; Line0 is the opto-coupled input and is deliberately NOT
    % used (us-scale, asymmetric, temperature-dependent switching).
    %
    % LEVELS: the PBESR-PRO-400 outputs 3.3 V (confirmed 2026-09-06), which is
    % exactly LVTTL. V_IH is 2.0 V, so there is ~1.3 V of margin and no level
    % shifter or divider is wanted.
    %
    % DO NOT put a 50 ohm terminator on this line. A 3.3 V source into 50 ohm
    % divides to 1.65 V at the receiver -- BELOW the 2.0 V threshold -- and the
    % camera then sees nothing at all, which is indistinguishable from an
    % unplugged cable. Drive the LVTTL input unterminated. The 2 us pulse width
    % below is orders of magnitude longer than any settling on a bench-length
    % cable, and edge ringing cannot produce spurious frames because the camera
    % is busy for the whole ~2 ms exposure afterwards and rejects further edges
    % (they land on the ExposureTriggerMissed counter instead, where they are
    % visible).
    cfg.triggerLine       = 'Line2';
    cfg.triggerActivation = 'RisingEdge';

    % TriggerDivider stays 1: PB emits exactly one edge per frame, so there is
    % nothing to divide. Raising this reinstates scheme B5 and will silently
    % break the SIG/REF alternation -- do not, unless you have also restructured
    % the sequence files.
    cfg.triggerDivider = 1;

    % --- Sync out (scheme A2) -------------------------------------------------
    % Timer0 fires off ExposureStart and drives a pulse onto a line, giving a
    % scope a hard mark for when the exposure window ACTUALLY opened, at 1 us
    % resolution -- finer than the 5.5556 us grid the window itself sits on.
    % This is the time-zero reference for the optical exposure-window sweep
    % (findings sec.7 item 5). Diagnostic only; nothing in the run depends on it.
    cfg.enableSyncOut   = true;
    cfg.syncOutLine     = 'Line3';   % physical GPIO2
    cfg.syncOutDelayUs  = 0;
    cfg.syncOutWidthUs  = 10;

    % --- Missed-trigger telemetry (scheme C1) ---------------------------------
    % ExposureTriggerMissed is detected in hardware but has no routable output,
    % so it is read back either as an asynchronous GenICam event or as a hardware
    % counter. The counter is used here: one register read after each burst,
    % accumulated in hardware, and it cannot itself be dropped the way a queued
    % event can (EventDropped is a real entry in this camera's EventSelector).
    %
    % Its job is DIAGNOSIS, not detection -- the frame-count equality above is
    % what detects a miss. This separates "too close to the rate ceiling" from
    % "the camera never saw Line2" from "PB did not run", three faults that
    % otherwise present identically as a fetch timeout.
    %
    % NOTE: the counter core is verified on internal events (findings sec.2.3)
    % but ExposureTriggerMissed specifically was never tested as a source. If
    % ids_TriggerTest reports the node unavailable, set this false and rely on
    % the timeout.
    cfg.enableMissedCounter = true;
    cfg.missedCounter       = 'Counter1';

    % --- Gain / black level ---------------------------------------------------
    % Keep at 1.0. There is NO analog gain on this sensor (GainSelector offers
    % only DigitalAll); digital gain scales read noise with signal and so buys
    % exactly zero NV sensitivity. Get SNR from exposure and accumulation.
    % There is also no BlackLevel node, so check you are not clipping at the low
    % end rather than trying to offset it away.
    cfg.gain = 1.0;

    % --- Rate ceiling ---------------------------------------------------------
    % Fraction of the camera's maximum frame rate the plan is allowed to use.
    % Above ~0.9 you enter the band where trigger loss is erratic and
    % non-monotonic in rate (findings sec.4.7). Those measurements used the
    % camera's internal PWM, which shares its clock, so the phase was static; a
    % PB on an independent crystal will WALK into and out of that band as the
    % room temperature changes. Intermittent, temperature-correlated frame loss
    % that looks exactly like a physics artifact.
    cfg.maxRateFraction = 0.9;

    % --- Acquisition timeout --------------------------------------------------
    % Consumed by hc_AcqTimeoutMs, which despite the hc_ prefix is detector-
    % agnostic: it reads only these four fields and the span of gmSEQ.CHN.
    cfg.timeoutMs       = 20000;      % floor
    cfg.timeoutFactor   = 2;          % x predicted burst duration
    cfg.timeoutMarginMs = 10000;      % + readout / USB transfer
    cfg.timeoutMaxMs    = 1800000;    % hard cap

    % --- Display --------------------------------------------------------------
    % ROI for the axes3 trace: [xc yc halfwidth] in pixels, or [] for a
    % frame-centre square.
    cfg.roi = [];

    % --- Dark reference -------------------------------------------------------
    % Stored per-pixel pedestal, used when the GUI takeDarkRef box is unticked.
    % The IDS has no BlackLevel control, so the pedestal is whatever the sensor
    % gives; it scales with exposure, so a stored one is only valid at the
    % exposure it was taken at.
    cfg.darkRefFile = fullfile(fileparts(mfilename('fullpath')), 'ids_darkref.mat');

    % Scratch file the Python backend writes each burst into, and MATLAB reads
    % back. Lives outside the project so it never lands in git.
    cfg.burstFile = fullfile(tempdir, 'ids_burst.h5');
end
