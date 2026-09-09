function plan = ids_BlockPlan(cfg, shotNs, bReport)
% ids_BlockPlan  Turn a shot length into a validated IDS block/exposure plan.
%
%   plan = ids_BlockPlan(cfg, shotNs)
%   plan = ids_BlockPlan(cfg, shotNs, false)     % silent
%
%   cfg      IDSConfig struct
%   shotNs   duration of ONE shot of the sequence, ns (init + MW + readout +
%            whatever idle the sequence puts between shots)
%
%   plan .shotNs .shotsPerBlock .shotTrainNs .guardNs .blockNs
%        .expoNs .expoQuanta .marginNs .quantumNs .deadNs
%        .sensorFloorNs .rateFraction .frameInfo
%        .triggerTimesNs   [0 blockNs]   -- where the sequence puts CamTrig
%        .programNs        2 * blockNs   -- one PB program run
%
% This is the executable form of the block-boundary timing. Every ids_* sequence
% calls it, and RunSequence_IDSCam calls it again to configure the camera, so
% there is exactly one place where "shot length -> block -> exposure" is decided
% and the sequence and the camera cannot drift apart.
%
% It ERRORS on an impossible plan rather than warning, because every failure mode
% here is silent in the data. An exposure that overruns its block does not look
% wrong -- it drops a trigger, and from that point on every frame in the burst
% has its SIG/REF role inverted.
%
% THE CONSTRAINT CHAIN
%
%   shotTrain  <=  exposure  <=  block - dead - quantum
%
% Lower bound: every shot must be inside the exposure window, or you are
% throwing away signal you paid for.
%
% Upper bound: the camera becomes busy at (trigger + Q_prev) and must be free
% again by (next trigger + Q_next), where Q is the 0..5.5556 us trigger
% quantisation (findings sec.4.5). Consecutive frames sample it independently,
% so the worst case is Q_prev = one full quantum with Q_next = 0. Subtracting one
% quantum makes that case safe rather than merely unlikely.
%
% Both bounds are satisfiable together only if the guard exceeds dead + quantum,
% which is checked first and explicitly.

    if nargin < 3 || isempty(bReport); bReport = true; end

    plan = struct();
    plan.shotNs        = double(shotNs);
    plan.shotsPerBlock = double(getf(cfg, 'shotsPerBlock', 76));
    plan.guardNs       = double(getf(cfg, 'guardNs', 100000));
    W = double(getf(cfg, 'width',  1280));
    H = double(getf(cfg, 'height', 256));
    pxFmt = getf(cfg, 'pixelFormat', 'Mono8');

    if ~isfinite(plan.shotNs) || plan.shotNs <= 0
        error('ids_BlockPlan:BadShot', ...
              'shotNs must be a positive finite number of nanoseconds, got %g.', shotNs);
    end
    if plan.shotsPerBlock < 1
        error('ids_BlockPlan:BadShotCount', ...
              'cfg.shotsPerBlock must be at least 1, got %g.', plan.shotsPerBlock);
    end

    plan.shotTrainNs = plan.shotsPerBlock * plan.shotNs;
    plan.blockNs     = plan.shotTrainNs + plan.guardNs;
    plan.programNs   = 2 * plan.blockNs;               % SIG block + REF block
    plan.triggerTimesNs = [0, plan.blockNs];

    % --- Camera constants ----------------------------------------------------
    [~, ~, gridInfo] = ids_ExposureGrid(0, W);
    plan.quantumNs = gridInfo.quantumNs;               % 5555.5556 ns
    plan.deadNs    = 23000;                            % findings sec.3.1

    % --- Guard must be able to hold the turnaround AND the quantisation ------
    guardNeedNs = plan.deadNs + plan.quantumNs;
    if plan.guardNs <= guardNeedNs
        error('ids_BlockPlan:GuardTooShort', ...
              ['cfg.guardNs = %g ns is not long enough. The block boundary has to ', ...
               'absorb the camera''s %g ns turnaround plus up to %g ns of trigger ', ...
               'quantisation, so the guard must exceed %g ns -- and should exceed it ', ...
               'comfortably, since it is also what keeps the exposure window from ', ...
               'closing on top of a laser pulse. Nothing was configured.'], ...
              plan.guardNs, plan.deadNs, plan.quantumNs, guardNeedNs);
    end

    % --- Exposure: the ceiling, floor-snapped, then backed off ---------------
    expoCeilNs = plan.blockNs - plan.deadNs - plan.quantumNs;
    backoff    = double(getf(cfg, 'exposureBackoffQuanta', 1));
    [~, nQ, expoInfo] = ids_ExposureGrid(expoCeilNs, W, 'floor');
    plan.expoQuanta = nQ - backoff;
    plan.expoNs     = plan.expoQuanta * plan.quantumNs;
    plan.expoInfo   = expoInfo;

    if plan.expoNs < expoInfo.minNs
        error('ids_BlockPlan:ExposureBelowFloor', ...
              ['The plan wants a %g ns exposure but this camera cannot expose ', ...
               'shorter than %g ns at ROI width %d (the minimum scales with WIDTH, ', ...
               'not height: about 36 us + 11.2 ns x W). Lengthen the shot, add ', ...
               'shots, or narrow the ROI. Nothing was configured.'], ...
              plan.expoNs, expoInfo.minNs, W);
    end

    % --- Lower bound: no shot may fall outside the window --------------------
    if plan.expoNs < plan.shotTrainNs
        error('ids_BlockPlan:ExposureClipsShots', ...
              ['The exposure lands at %g ns but the shot train is %g ns long, so ', ...
               'the last %.1f shot(s) of every block would fall outside the ', ...
               'exposure window and be thrown away. Shorten cfg.guardNs (currently ', ...
               '%g ns) or reduce cfg.exposureBackoffQuanta (currently %g). Nothing ', ...
               'was configured.'], ...
              plan.expoNs, plan.shotTrainNs, ...
              (plan.shotTrainNs - plan.expoNs) / plan.shotNs, plan.guardNs, backoff);
    end

    % --- Upper bound: the camera must be free before the next trigger --------
    plan.marginNs = plan.blockNs - plan.expoNs - plan.deadNs;
    if plan.marginNs < plan.quantumNs
        error('ids_BlockPlan:NoQuantisationMargin', ...
              ['Only %g ns of margin between the end of the camera''s busy window ', ...
               'and the next trigger, which is less than one %g ns quantisation ', ...
               'quantum. Consecutive frames sample that quantisation independently, ', ...
               'so triggers WILL be missed intermittently -- and a missed trigger ', ...
               'inverts the SIG/REF role of every frame after it. Raise cfg.guardNs ', ...
               'or cfg.exposureBackoffQuanta. Nothing was configured.'], ...
              plan.marginNs, plan.quantumNs);
    end

    % --- Rate ceiling, against the SENSOR floor only -------------------------
    % Deliberately NOT against the full frame-time model. In the exposure-bound
    % regime the model's answer is exposure + 23 us, which is a quantity this
    % function just chose from the block -- so the ratio would be ~1 by
    % construction and the check would fire on every valid plan. The margin test
    % above is the exact and sufficient condition for that regime.
    %
    % What the 90% rule is actually about is the readout/link floor: a hardware
    % property that cannot be tuned, and the thing you overrun to fall off the
    % sec.4.7 cliff. Near it, trigger loss is erratic and NON-MONOTONIC in rate,
    % and because those measurements used the camera's internal PWM (same clock,
    % static phase) while a PB runs on an independent crystal, the real system
    % will walk into and out of that band as the room temperature changes.
    [~, fi] = ids_FrameTimeNs(W, H, pxFmt, plan.expoNs);
    plan.frameInfo     = fi;
    plan.sensorFloorNs = max(fi.readoutNs, fi.linkNs);
    plan.rateFraction  = plan.sensorFloorNs / plan.blockNs;
    maxFrac = double(getf(cfg, 'maxRateFraction', 0.9));

    % Which of the two SENSOR terms set the floor. Deliberately not fi.bound,
    % which describes the full model including the exposure term -- on a valid
    % plan that is almost always "exposure", and printing it next to the sensor
    % floor would label the number with a term it does not contain.
    if fi.linkNs > fi.readoutNs
        plan.floorBound = 'link';
    else
        plan.floorBound = 'readout';
    end

    if plan.rateFraction > 1
        error('ids_BlockPlan:BlockShorterThanReadout', ...
              ['The block is %g ns but this ROI (%dx%d %s) cannot produce a frame ', ...
               'faster than %g ns (%s-bound). The camera would drop roughly every ', ...
               'other trigger. Crop the height, switch to Mono8, or lengthen the ', ...
               'block. Nothing was configured.'], ...
              plan.blockNs, W, H, char(pxFmt), plan.sensorFloorNs, plan.floorBound);
    end
    if plan.rateFraction > maxFrac
        error('ids_BlockPlan:TooCloseToRateCeiling', ...
              ['The block is %g ns against a %g ns sensor floor -- %.1f%% of the ', ...
               'maximum rate, over the %.0f%% ceiling in cfg.maxRateFraction. That ', ...
               'is inside the band where trigger loss is erratic and non-monotonic, ', ...
               'and a PB on an independent crystal will drift into and out of it as ', ...
               'the room warms. Lengthen the block or crop the ROI. Nothing was ', ...
               'configured.'], ...
              plan.blockNs, plan.sensorFloorNs, 100*plan.rateFraction, 100*maxFrac);
    end

    % --- Report --------------------------------------------------------------
    if bReport
        fprintf(['[IDS] Block plan: %d shots x %g ns = %g ns train + %g ns guard ', ...
                 '= %g ns block.\n'], ...
                plan.shotsPerBlock, plan.shotNs, plan.shotTrainNs, ...
                plan.guardNs, plan.blockNs);
        fprintf(['[IDS]   exposure %g ns (%d quanta of %g ns, %g backed off); ', ...
                 'margin %g ns = %.1f quanta.\n'], ...
                plan.expoNs, plan.expoQuanta, plan.quantumNs, backoff, ...
                plan.marginNs, plan.marginNs / plan.quantumNs);
        fprintf(['[IDS]   ROI %dx%d %s: sensor floor %g ns (%s-bound); block is ', ...
                 '%.1f%% of max rate (ceiling %.0f%%).\n'], ...
                W, H, char(pxFmt), plan.sensorFloorNs, plan.floorBound, ...
                100*plan.rateFraction, 100*maxFrac);
        fprintf(['[IDS]   One PB program = %g ns (SIG block + REF block), ', ...
                 'CamTrig at %g and %g ns.\n'], ...
                plan.programNs, plan.triggerTimesNs(1), plan.triggerTimesNs(2));
    end
end

% --------------------------------------------------------------------------- %
function v = getf(s, name, dflt)
v = dflt;
if isstruct(s) && isfield(s, name) && ~isempty(s.(name))
    v = s.(name);
end
end
