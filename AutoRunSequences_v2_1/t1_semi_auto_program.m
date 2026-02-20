function t1_semi_auto_program(hObject, eventdata, handlesMain, handlesAuto)
% Smart v2.1 orchestration entry point.
% NOTE: t1_semi_auto_run.m is treated as core and is not modified here.

global gSaveDataAve gmSEQ

% Ensure package folders (+plotting, +fitting, +autoplot) are resolvable.
thisDir = fileparts(mfilename('fullpath'));
addpath(thisDir, '-begin');

cfg = config();
cfg.runtime = struct();
if isfield(cfg.smart, 't1fit')
    gmSEQ.T1FitModel = cfg.smart.t1fit.model;
    gmSEQ.T1FitCfg = cfg.smart.t1fit;
end
reset_v2_1_run_state(handlesAuto, cfg);
ctx = build_execution_context(cfg, handlesAuto);
if stop_requested(handlesAuto)
    return;
end
cfg.runtime.runSaveFolder = create_run_save_folder(cfg.paths.saveFolder, ctx.estimatedB_G);
cleanupSave = onCleanup(@() save_end_of_run_snapshots(handlesMain, handlesAuto, cfg)); %#ok<NASGU>

if isempty(ctx.targets)
    error('SmartT1:NoTargetSelected', ...
        'No measurement target is selected. Enable at least one target checkbox.');
end

% Apply preset (readout/CtrGateDur) once at startup when available.
presetSeq = build_preset_step(handlesAuto);
apply_sequence_to_main_gui(presetSeq, handlesMain);
if stop_requested(handlesAuto)
    return;
end
auto_load_user_inputs(hObject, eventdata, handlesMain);
if stop_requested(handlesAuto)
    return;
end

predicted = estimate_resonance_centers(ctx.estimatedB_G, cfg.smart.physics);
allLabels = {'aligned_m1', 'aligned_p1', 'off_m1', 'off_p1'};
requiredLabels = collect_required_resonance_labels(ctx.targets);
odmrLabels = requiredLabels;
if isfield(ctx, 'precal') && isfield(ctx.precal, 'forceMeasureAllFreqs') && ctx.precal.forceMeasureAllFreqs
    odmrLabels = allLabels;
end

freqMap = struct();
rabiCache = struct();
precal = struct('sg1PiNs', struct(), 'sg1FreqMHz', struct(), ...
    'sg2PiNs', struct(), 'sg2FreqMHz', struct(), ...
    'sg1PowDbm', struct(), 'sg2PowDbm', struct());

if ctx.precal.enabled
    disp(['[SmartT1] Precal ODMR labels: ' strjoin(odmrLabels, ', ')]);
    pendingLabels = odmrLabels;
    iW = 0;
    refinedBUsed = false;
    while ~isempty(pendingLabels)
        windows = plan_odmr_windows(pendingLabels, predicted, cfg.smart.odmr);
        if isempty(windows)
            break;
        end
        w = windows(1);
        iW = iW + 1;
        disp(sprintf('[SmartT1] Planned ODMR windows (remaining): %d', numel(windows)));
        if stop_requested(handlesAuto)
            return;
        end

        seq = build_odmr_sequence(w, ctx, handlesAuto, cfg);
        run_one_sequence(seq, handlesMain, handlesAuto, hObject, eventdata, cfg, ...
            sprintf(' [ODMR window %d]', iW));
        if stop_requested(handlesAuto)
            return;
        end

        [fitMap, ok] = fit_odmr_window_from_current_data(w, predicted, cfg.smart.odmr);
        if ~ok
            warning('SmartT1:ODMRWindowFitFallback', ...
                'Using predicted frequencies for failed ODMR window #%d.', iW);
        end
        freqMap = merge_freq_map(freqMap, fitMap);
        update_precal_summary_display(handlesAuto, cfg, ...
            build_precal_summary_text(freqMap, precal, allLabels, odmrLabels, cfg.smart.physics, cfg.smart.odmr));

        if ~refinedBUsed && iW == 1 && ok && isfield(cfg.smart.odmr, 'refineBFromFirstWindow') ...
                && logical(cfg.smart.odmr.refineBFromFirstWindow)
            [BRefinedG, bOk, usedLabels] = backout_true_B_from_first_odmr_window( ...
                w, fitMap, predicted, ctx.estimatedB_G, cfg.smart.physics, cfg.smart.odmr);
            if bOk
                predicted = estimate_resonance_centers(BRefinedG, cfg.smart.physics);
                disp(sprintf('[SmartT1] Refined B from first ODMR: %.3f G -> %.3f G (labels: %s)', ...
                    ctx.estimatedB_G, BRefinedG, strjoin(usedLabels, ', ')));
            else
                disp('[SmartT1] Skipped B refinement from first ODMR (fit quality/consistency not sufficient).');
            end
            refinedBUsed = true;
        end

        pendingLabels = setdiff(pendingLabels, w.labels, 'stable');
    end

    freqMap = fill_missing_freqs(freqMap, allLabels, predicted);
    gmSEQ.SmartFreqMapGHz = freqMap;

    for iL = 1:numel(requiredLabels)
        label = requiredLabels{iL};
        fGHz = get_map_freq(freqMap, label);
        [rabiCache, piNs, fRMHz, pDbm] = calibrate_rabi_path( ...
            'sg1', label, fGHz, ctx, handlesMain, handlesAuto, hObject, eventdata, cfg, rabiCache);
        precal.sg1PiNs.(label) = piNs;
        precal.sg1FreqMHz.(label) = fRMHz;
        precal.sg1PowDbm.(label) = pDbm;
        update_precal_summary_display(handlesAuto, cfg, ...
            build_precal_summary_text(freqMap, precal, allLabels, odmrLabels, cfg.smart.physics, cfg.smart.odmr));
        if stop_requested(handlesAuto)
            return;
        end
    end

    p1Labels = collect_required_sg2_p1_labels(ctx.targets);
    for iL = 1:numel(p1Labels)
        label = p1Labels{iL};
        fGHz = get_map_freq(freqMap, label);
        [rabiCache, piNs, fRMHz, pDbm] = calibrate_rabi_path( ...
            'sg2', label, fGHz, ctx, handlesMain, handlesAuto, hObject, eventdata, cfg, rabiCache);
        precal.sg2PiNs.(label) = piNs;
        precal.sg2FreqMHz.(label) = fRMHz;
        precal.sg2PowDbm.(label) = pDbm;
        update_precal_summary_display(handlesAuto, cfg, ...
            build_precal_summary_text(freqMap, precal, allLabels, odmrLabels, cfg.smart.physics, cfg.smart.odmr));
        if stop_requested(handlesAuto)
            return;
        end
    end

    update_precal_summary_display(handlesAuto, cfg, ...
        build_precal_summary_text(freqMap, precal, allLabels, odmrLabels, cfg.smart.physics, cfg.smart.odmr));
else
    freqMap = predicted;
    gmSEQ.SmartFreqMapGHz = freqMap;
    update_precal_summary_display(handlesAuto, cfg, ...
        'Precal disabled: skip ODMR/Rabi and keep existing main GUI MW settings for T1.');
end

for iT = 1:numel(ctx.targets)
    if stop_requested(handlesAuto)
        break;
    end

    target = ctx.targets(iT);
    if ctx.precal.enabled
        [fSg1, fSg2, labelM1, labelP1] = resolve_target_freqs(target, freqMap);
        switch target.transition
            case 'SQ_0_TO_M1'
                piSg1 = get_map_freq(precal.sg1PiNs, labelM1);
                freqSg1MHz = get_map_freq(precal.sg1FreqMHz, labelM1);
                piSg2 = piSg1;
                freqSg2MHz = freqSg1MHz;
            case 'SQ_0_TO_P1'
                piSg1 = get_map_freq(precal.sg1PiNs, labelP1);
                freqSg1MHz = get_map_freq(precal.sg1FreqMHz, labelP1);
                piSg2 = piSg1;
                freqSg2MHz = freqSg1MHz;
            otherwise % DQ_M1_TO_P1
                piSg1 = get_map_freq(precal.sg1PiNs, labelM1);
                freqSg1MHz = get_map_freq(precal.sg1FreqMHz, labelM1);
                piSg2 = get_map_freq(precal.sg2PiNs, labelP1);
                freqSg2MHz = get_map_freq(precal.sg2FreqMHz, labelP1);
                if ~isfinite(piSg2)
                    piSg2 = get_map_freq(precal.sg1PiNs, labelP1);
                end
                if ~isfinite(freqSg2MHz)
                    freqSg2MHz = get_map_freq(precal.sg1FreqMHz, labelP1);
                end
        end
    else
        [fSg1, fSg2, labelM1, labelP1] = resolve_target_freqs(target, freqMap);
        piSg1 = NaN;
        piSg2 = NaN;
        freqSg1MHz = NaN;
        freqSg2MHz = NaN;
    end

    ctxTarget = ctx;
    if ctx.precal.enabled
        pSg1 = choose_best_precal_power(precal.sg1PowDbm, labelM1, labelP1, target.transition, ctx.power.rabi_sg1_dBm, false);
        pSg2 = choose_best_precal_power(precal.sg2PowDbm, labelM1, labelP1, target.transition, ctx.power.rabi_sg2_dBm, true);
        if ~isfinite(pSg2)
            pSg2 = choose_best_precal_power(precal.sg1PowDbm, labelM1, labelP1, target.transition, ctx.power.rabi_sg2_dBm, true);
        end
        if ~isfinite(pSg1)
            pSg1 = ctx.power.rabi_sg1_dBm;
        end
        if ~isfinite(pSg2)
            pSg2 = ctx.power.rabi_sg2_dBm;
        end

        if isfield(ctx.precal, 'calipi') && isfield(ctx.precal.calipi, 'enabled') && ctx.precal.calipi.enabled
            [piSg1, freqSg1MHz, pSg1, piSg2, freqSg2MHz, pSg2] = ...
                maybe_match_pi_when_one_power_capped(target, labelM1, labelP1, fSg1, fSg2, ...
                piSg1, freqSg1MHz, pSg1, piSg2, freqSg2MHz, pSg2, ...
                ctx, handlesMain, handlesAuto, hObject, eventdata, cfg);
            if stop_requested(handlesAuto)
                break;
            end
        end

        ctxTarget.power.rabi_sg1_dBm = pSg1;
        ctxTarget.power.rabi_sg2_dBm = pSg2;
        if isfield(ctx.precal, 'calipi') && isfield(ctx.precal.calipi, 'enabled') && ctx.precal.calipi.enabled
            ctxTarget.power.sq_p1_calibration_boost_dB = 0;
        end
    end

    [finalRange, roughInfo] = determine_t1_final_range( ...
        target, fSg1, fSg2, piSg1, piSg2, ctxTarget, handlesMain, handlesAuto, hObject, eventdata, cfg);
    if stop_requested(handlesAuto)
        break;
    end
    finalSeq = build_t1_sequence(target, finalRange, fSg1, fSg2, piSg1, piSg2, ctxTarget);
    run_one_sequence(finalSeq, handlesMain, handlesAuto, hObject, eventdata, cfg, ...
        sprintf(' [T1 %s]', target.id));
    if stop_requested(handlesAuto)
        break;
    end

    if ctx.precal.enabled
        fDispM1 = get_map_freq(freqMap, labelM1);
        fDispP1 = get_map_freq(freqMap, labelP1);
    else
        fDispM1 = fSg1;
        fDispP1 = fSg2;
    end

    if isfinite(roughInfo.t1RoughMs)
        roughTail = sprintf('roughT1=%.3fms', roughInfo.t1RoughMs);
    elseif isfield(roughInfo, 'edgeRatio') && isfinite(roughInfo.edgeRatio)
        roughTail = sprintf('roughRatio=%.4f', roughInfo.edgeRatio);
    else
        roughTail = 'rough=NA';
    end
    statusText = sprintf(['%s: f_m1=%.6fGHz f_p1=%.6fGHz | ', ...
        'SG1 pi=%.1fns fR=%.2fMHz P=%.2fdBm | SG2 pi=%.1fns fR=%.2fMHz P=%.2fdBm | %s'], ...
        target.id, fDispM1, fDispP1, ...
        piSg1, freqSg1MHz, ctxTarget.power.rabi_sg1_dBm, ...
        piSg2, freqSg2MHz, ctxTarget.power.rabi_sg2_dBm, roughTail);
    disp(['[SmartT1] ' statusText]);
    update_target_status_display(handlesAuto, cfg, target.id, statusText);
end
end

function ctx = build_execution_context(cfg, hAuto)
ctx = struct();
ctx.estimatedB_G = read_ui_numeric(hAuto, cfg.smart.ui.tags.input.estimatedB, ...
    read_ui_numeric(hAuto, 'setB', cfg.smart.defaultEstimatedB_G));
ctx.nonuniform = logical(read_ui_numeric(hAuto, cfg.smart.ui.tags.input.nonuniform, 0));

ctx.rough = cfg.smart.rough;
ctx.rough.enabled = logical(read_ui_numeric(hAuto, cfg.smart.ui.tags.rough.enable, ctx.rough.enabled));
ctx.rough.repeat = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.rough.repeat, ctx.rough.repeat));
ctx.rough.average = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.rough.average, ctx.rough.average));
ctx.rough.nPoints = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.rough.nPoints, ctx.rough.nPoints));
ctx.rough.maxRetries = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.rough.maxRetries, ctx.rough.maxRetries));
ctx.rough.fitRelErrThreshold = read_ui_numeric(hAuto, cfg.smart.ui.tags.rough.fitRelErr, ctx.rough.fitRelErrThreshold);
ctx.rough.stopPolicy = read_ui_string(hAuto, cfg.smart.ui.tags.rough.stopPolicy, ctx.rough.stopPolicy);
ctx.rough.stopPolicy = canonical_stop_policy(ctx.rough.stopPolicy);
if isfield(cfg.smart.ui.tags.rough, 'stopFactor')
    ctx.rough.stopFactor = read_ui_numeric(hAuto, cfg.smart.ui.tags.rough.stopFactor, ctx.rough.stopFactor);
end
if ~isfinite(ctx.rough.stopFactor) || ctx.rough.stopFactor <= 0
    ctx.rough.stopFactor = 2.0;
end
if isfield(ctx.rough, 'stopEstimator')
    ctx.rough.stopEstimator = canonical_rough_stop_estimator(ctx.rough.stopEstimator);
else
    ctx.rough.stopEstimator = 'single_exp';
end
if isfield(ctx.rough, 'ratioThreshold')
    if ~isfinite(ctx.rough.ratioThreshold) || ctx.rough.ratioThreshold <= 0
        ctx.rough.ratioThreshold = 0.1;
    end
else
    ctx.rough.ratioThreshold = 0.1;
end
if isfield(ctx.rough, 'ratioExtendFactor')
    if ~isfinite(ctx.rough.ratioExtendFactor) || ctx.rough.ratioExtendFactor <= 1
        ctx.rough.ratioExtendFactor = 1.5;
    end
else
    ctx.rough.ratioExtendFactor = 1.5;
end

ctx.power = cfg.smart.power;
ctx.power.odmr_dBm = read_ui_numeric(hAuto, cfg.smart.ui.tags.power.odmr, ...
    read_ui_numeric(hAuto, 'MWPowerESR', ctx.power.odmr_dBm));
if isfield(cfg.smart.ui.tags.power, 'odmrP1')
    ctx.power.odmr_p1_dBm = read_ui_numeric(hAuto, cfg.smart.ui.tags.power.odmrP1, ctx.power.odmr_p1_dBm);
else
    ctx.power.odmr_p1_dBm = ctx.power.odmr_dBm;
end
ctx.power.rabi_dBm = read_ui_numeric(hAuto, cfg.smart.ui.tags.power.rabi, ...
    read_ui_numeric(hAuto, 'MWPowerRabi', ctx.power.rabi_dBm));
ctx.power.rabi_sg1_dBm = read_ui_numeric(hAuto, cfg.smart.ui.tags.power.rabiSg1, ctx.power.rabi_dBm);
ctx.power.rabi_sg2_dBm = read_ui_numeric(hAuto, cfg.smart.ui.tags.power.rabiSg2, ctx.power.rabi_dBm);

ctx.precal = cfg.smart.precal;
ctx.precal.enabled = logical(read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.enable, 1));
ctx.precal.rabi.start = read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.rabi.start, ...
    read_ui_numeric(hAuto, 'startRabi', ctx.precal.rabi.start));
ctx.precal.rabi.stop = read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.rabi.stop, ...
    read_ui_numeric(hAuto, 'stopRabi', ctx.precal.rabi.stop));
ctx.precal.rabi.nPoints = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.rabi.nPoints, ...
    read_ui_numeric(hAuto, 'nPtsRabi', ctx.precal.rabi.nPoints)));
ctx.precal.rabi.repeat = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.rabi.repeat, ...
    read_ui_numeric(hAuto, 'RepeatRabi', ctx.precal.rabi.repeat)));
ctx.precal.rabi.average = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.rabi.average, ...
    read_ui_numeric(hAuto, 'maxAveRabi', ctx.precal.rabi.average)));

ctx.precal.odmr.repeat = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.odmr.repeat, ...
    read_ui_numeric(hAuto, 'RepeatESR', ctx.precal.odmr.repeat)));
ctx.precal.odmr.average = round(read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.odmr.average, ...
    read_ui_numeric(hAuto, 'maxAveESR', ctx.precal.odmr.average)));
ctx.precal.odmr.pointsPerMHz = read_ui_numeric(hAuto, cfg.smart.ui.tags.precal.odmr.pointsPerMHz, ...
    ctx.precal.odmr.pointsPerMHz);
if isfield(ctx.precal, 'calipi')
    tagsPrecal = cfg.smart.ui.tags.precal;
    ctx.precal.calipi.enabled = logical(read_ui_numeric(hAuto, tagsPrecal.calipi.enable, ctx.precal.calipi.enabled));
    ctx.precal.calipi.targetPiNs = read_ui_numeric(hAuto, tagsPrecal.calipi.targetPiNs, ctx.precal.calipi.targetPiNs);
    ctx.precal.calipi.powerStartDbm = read_ui_numeric(hAuto, tagsPrecal.calipi.powerStartDbm, ctx.precal.calipi.powerStartDbm);
    ctx.precal.calipi.powerStopDbm = read_ui_numeric(hAuto, tagsPrecal.calipi.powerStopDbm, ctx.precal.calipi.powerStopDbm);
    ctx.precal.calipi.powerNPoints = round(read_ui_numeric(hAuto, tagsPrecal.calipi.powerNPoints, ctx.precal.calipi.powerNPoints));
    if ~isfinite(ctx.precal.calipi.powerNPoints) || ctx.precal.calipi.powerNPoints < 1
        ctx.precal.calipi.powerNPoints = 1;
    end
else
    ctx.precal.calipi = struct('enabled', false, 'targetPiNs', NaN, ...
        'powerStartDbm', NaN, 'powerStopDbm', NaN, 'powerNPoints', 1);
end

targets = cfg.smart.targets;
for i = 1:numel(targets)
    tagSel = cfg.smart.ui.tags.sel.(targets(i).id);
    targets(i).enabled = logical(read_ui_numeric(hAuto, tagSel, targets(i).enabled));
    targets(i).t1 = resolve_target_t1_params(targets(i), cfg.smart.ui.tags.t1.(targets(i).id), hAuto);
end
ctx.targets = targets([targets.enabled]);
end

function t1 = resolve_target_t1_params(target, tags, hAuto)
t1 = target.t1;

% GUI override from explicit per-target tags.
t1.start = read_ui_numeric(hAuto, tags.start, t1.start);
t1.stop = read_ui_numeric(hAuto, tags.stop, t1.stop);
t1.nPoints = round(read_ui_numeric(hAuto, tags.nPoints, t1.nPoints));
t1.repeat = round(read_ui_numeric(hAuto, tags.repeat, t1.repeat));
t1.average = round(read_ui_numeric(hAuto, tags.average, t1.average));

% Backward-compat fallback from legacy fields when dedicated tags are absent.
switch target.id
    case 'aligned_sq_m1'
        t1 = apply_legacy_t1_fields(t1, hAuto, 'startT1', 'stopT1', 'nPtsT1', 'RepeatT1', 'maxAveT1');
    case 'aligned_sq_p1'
        t1 = apply_legacy_t1_fields(t1, hAuto, 'startT12', 'stopT12', 'nPtsT12', 'RepeatT12', 'maxAveT12');
    case 'aligned_dq'
        t1 = apply_legacy_t1_fields(t1, hAuto, 'startT13', 'stopT13', 'nPtsT13', 'RepeatT13', 'maxAveT13');
    case 'off_sq_m1'
        t1 = apply_legacy_t1_fields(t1, hAuto, 'startT1', 'stopT1', 'nPtsT1', 'RepeatT1', 'maxAveT1');
    case 'off_sq_p1'
        t1 = apply_legacy_t1_fields(t1, hAuto, 'startT12', 'stopT12', 'nPtsT12', 'RepeatT12', 'maxAveT12');
    case 'off_dq'
        t1 = apply_legacy_t1_fields(t1, hAuto, 'startT13', 'stopT13', 'nPtsT13', 'RepeatT13', 'maxAveT13');
end
end

function t1 = apply_legacy_t1_fields(t1, hAuto, sTag, eTag, nTag, rTag, aTag)
t1.start = read_ui_numeric(hAuto, sTag, t1.start);
t1.stop = read_ui_numeric(hAuto, eTag, t1.stop);
t1.nPoints = round(read_ui_numeric(hAuto, nTag, t1.nPoints));
t1.repeat = round(read_ui_numeric(hAuto, rTag, t1.repeat));
t1.average = round(read_ui_numeric(hAuto, aTag, t1.average));
end

function out = estimate_resonance_centers(B_G, phys)
B = abs(B_G);
out = struct();

[out.aligned_m1, out.aligned_p1] = solve_nv_resonances_full_matrix(B, 1.0, phys);
[out.off_m1, out.off_p1] = solve_nv_resonances_full_matrix(B, -1/3, phys);
end

function [fM1GHz, fP1GHz] = solve_nv_resonances_full_matrix(B_G, cosTheta, phys)
% Solve spin-1 Hamiltonian in frequency units (GHz) for given B and angle.
D = phys.zeroFieldGHz;
gammaGHzPerG = phys.gammaMHzPerG / 1000;

Sz = diag([1 0 -1]);
Sx = (1/sqrt(2)) * [0 1 0; 1 0 1; 0 1 0];
Sy = (1/sqrt(2)) * [0 -1i 0; 1i 0 -1i; 0 1i 0];

Bz = B_G * cosTheta;
Bx = B_G * sqrt(max(0, 1 - cosTheta^2));
By = 0;

H = D * (Sz^2 - (2/3) * eye(3)) + gammaGHzPerG * (Bx*Sx + By*Sy + Bz*Sz);
[V, E] = eig(H);
evals = real(diag(E));
[evals, idx] = sort(evals, 'ascend');
V = V(:, idx);

% Identify the state that is mostly |ms=0> (basis index 2).
[~, idx0] = max(abs(V(2,:)).^2);
others = setdiff(1:3, idx0);
f1 = abs(evals(others(1)) - evals(idx0));
f2 = abs(evals(others(2)) - evals(idx0));

fM1GHz = min(f1, f2);
fP1GHz = max(f1, f2);
end

function [BRefinedG, ok, usedLabels] = backout_true_B_from_first_odmr_window(window, fitMap, predicted, BSeedG, phys, odmrCfg)
BRefinedG = NaN;
ok = false;
usedLabels = {};

labels = window.labels;
if isempty(labels)
    return;
end

bCandidates = [];
for i = 1:numel(labels)
    label = labels{i};
    fFitGHz = get_map_freq(fitMap, label);
    fEstGHz = get_map_freq(predicted, label);
    if ~isfinite(fFitGHz) || ~isfinite(fEstGHz)
        continue;
    end

    [bNow, bOk] = invert_one_label_to_B(label, fFitGHz, BSeedG, phys, odmrCfg);
    if bOk && isfinite(bNow)
        bCandidates(end+1) = bNow; %#ok<AGROW>
        usedLabels{end+1} = label; %#ok<AGROW>
    end
end

if isempty(bCandidates)
    return;
end

spreadG = max(bCandidates) - min(bCandidates);
maxSpreadG = get_cfg_numeric_with_default(odmrCfg, 'maxBInversionSpreadG', 200);
if numel(bCandidates) > 1 && spreadG > maxSpreadG
    return;
end

BRefinedG = median(bCandidates);
ok = isfinite(BRefinedG) && (BRefinedG >= 0);
end

function [BbestG, ok] = invert_one_label_to_B(label, targetFGHz, BSeedG, phys, odmrCfg)
BbestG = NaN;
ok = false;
if ~isfinite(targetFGHz) || targetFGHz <= 0
    return;
end

bMin = get_cfg_numeric_with_default(odmrCfg, 'bSearchMinG', 0);
bMax = get_cfg_numeric_with_default(odmrCfg, 'bSearchMaxG', max(2000, abs(BSeedG) * 3 + 200));
if ~isfinite(bMin)
    bMin = 0;
end
if ~isfinite(bMax) || bMax <= bMin
    bMax = max(2000, bMin + 100);
end

obj = @(B) (predict_label_frequency_from_B(B, label, phys) - targetFGHz).^2;
try
    BbestG = fminbnd(obj, bMin, bMax);
catch
    return;
end
if ~isfinite(BbestG)
    return;
end

residualMHz = abs(predict_label_frequency_from_B(BbestG, label, phys) - targetFGHz) * 1000;
maxResidualMHz = get_cfg_numeric_with_default(odmrCfg, 'maxBBackoutResidualMHz', 30);
ok = isfinite(residualMHz) && (residualMHz <= maxResidualMHz);
end

function fGHz = predict_label_frequency_from_B(BG, label, phys)
if contains(label, 'aligned')
    cosTheta = 1.0;
else
    cosTheta = -1/3;
end
[fM1, fP1] = solve_nv_resonances_full_matrix(BG, cosTheta, phys);
if endsWith(label, '_m1')
    fGHz = fM1;
else
    fGHz = fP1;
end
end

function v = get_cfg_numeric_with_default(s, fieldName, defaultValue)
v = defaultValue;
if isstruct(s) && isfield(s, fieldName) && isfinite(s.(fieldName))
    v = s.(fieldName);
end
end

function labels = collect_required_resonance_labels(targets)
labels = {};
for i = 1:numel(targets)
    g = targets(i).group;
    switch g
        case 'aligned'
            base = 'aligned';
        otherwise
            base = 'off';
    end

    switch targets(i).transition
        case 'SQ_0_TO_M1'
            labels{end+1} = [base '_m1']; %#ok<AGROW>
        case 'SQ_0_TO_P1'
            labels{end+1} = [base '_p1']; %#ok<AGROW>
        case 'DQ_M1_TO_P1'
            labels{end+1} = [base '_m1']; %#ok<AGROW>
            labels{end+1} = [base '_p1']; %#ok<AGROW>
    end
end
labels = unique(labels, 'stable');
end

function labels = collect_required_sg2_p1_labels(targets)
labels = {};
for i = 1:numel(targets)
    if ~strcmp(targets(i).transition, 'DQ_M1_TO_P1')
        continue;
    end

    if strcmp(targets(i).group, 'aligned')
        labels{end+1} = 'aligned_p1'; %#ok<AGROW>
    else
        labels{end+1} = 'off_p1'; %#ok<AGROW>
    end
end
labels = unique(labels, 'stable');
end

function windows = plan_odmr_windows(labels, predicted, odmrCfg)
if isempty(labels)
    windows = struct([]);
    return;
end

centers = zeros(1, numel(labels));
for i = 1:numel(labels)
    centers(i) = get_map_freq(predicted, labels{i});
end

[centersSorted, idx] = sort(centers);
labelsSorted = labels(idx);
thGHz = odmrCfg.splitThresholdMHz / 1000;

clusters = {};
clusters{1} = 1;
for i = 2:numel(centersSorted)
    if abs(centersSorted(i) - centersSorted(i-1)) <= thGHz
        clusters{end}(end+1) = i; %#ok<AGROW>
    else
        clusters{end+1} = i; %#ok<AGROW>
    end
end

windows = repmat(struct('fromGHz',0,'toGHz',0,'labels',{{}},'labelCentersGHz',[],'expectedPeakCount',0), 1, numel(clusters));
for i = 1:numel(clusters)
    c = clusters{i};
    cFreq = centersSorted(c);
    margin = odmrCfg.windowMarginMHz / 1000;
    f0 = min(cFreq) - margin;
    f1 = max(cFreq) + margin;
    f0 = max(f0, odmrCfg.hardMinGHz);
    f1 = min(f1, odmrCfg.hardMaxGHz);
    windows(i).fromGHz = f0;
    windows(i).toGHz = f1;
    windows(i).labels = labelsSorted(c);
    windows(i).labelCentersGHz = cFreq;
    windows(i).expectedPeakCount = numel(c);
end
end

function seq = build_odmr_sequence(window, ctx, hAuto, cfg)
widthMHz = max((window.toGHz - window.fromGHz) * 1000, 1);
ptsPerMHz = ctx.precal.odmr.pointsPerMHz;
if ~isfinite(ptsPerMHz) || ptsPerMHz <= 0
    ptsPerMHz = cfg.smart.odmr.pointsPerMHz;
end
nPts = round(max(cfg.smart.odmr.minPoints, min(cfg.smart.odmr.maxPoints, ...
    widthMHz * ptsPerMHz)));

seq = struct();
seq.name = 'ODMR';
seq.FROM1 = num2str(window.fromGHz, '%.6f');
seq.TO1 = num2str(window.toGHz, '%.6f');
seq.SweepNPoints = num2str(nPts);
odmrPow = choose_odmr_power_for_window(window, ctx, cfg);
seq.fixPow = num2str(odmrPow);
seq.Repeat = num2str(max(1, round(ctx.precal.odmr.repeat)));
seq.Average = num2str(max(1, round(ctx.precal.odmr.average)));
seq.useSG2 = 0;
seq.bSweep2 = 0;
end

function odmrPow = choose_odmr_power_for_window(window, ctx, cfg)
% Policy:
% 1) For each target label in this ODMR window, choose power from nearest-frequency
%    Rabi memory entry when available.
% 2) If no memory for that label, use GUI-configured ODMR power:
%    m1 -> odmr_dBm, p1 -> odmr_p1_dBm.
% 3) If multiple peaks are scanned in one window, use the highest chosen power.

labels = window.labels;
if isempty(labels)
    odmrPow = ctx.power.odmr_dBm;
    return;
end

if isfield(window, 'labelCentersGHz') && numel(window.labelCentersGHz) == numel(labels)
    fTargets = double(window.labelCentersGHz(:).');
else
    fTargets = repmat((window.fromGHz + window.toGHz) / 2, 1, numel(labels));
end

pList = nan(1, numel(labels));
for i = 1:numel(labels)
    lb = labels{i};
    fGHz = fTargets(i);
    pMem = nearest_rabi_power_from_memory('sg1', fGHz, ctx, cfg);
    if isfinite(pMem)
        pList(i) = pMem;
    else
        pList(i) = default_odmr_power_for_label(lb, ctx);
    end
end

valid = isfinite(pList);
if ~any(valid)
    odmrPow = ctx.power.odmr_dBm;
else
    odmrPow = max(pList(valid)); % multi-peak window: use highest power
end
end

function p = default_odmr_power_for_label(label, ctx)
p = ctx.power.odmr_dBm;
if isfield(ctx.power, 'odmr_p1_dBm') && isfinite(ctx.power.odmr_p1_dBm)
    if ~isempty(regexp(lower(normalize_to_char(label)), '_p1$', 'once'))
        p = ctx.power.odmr_p1_dBm;
    end
end
end

function p = nearest_rabi_power_from_memory(pathName, freqGHz, ctx, cfg)
p = NaN;
if ~isfinite(freqGHz)
    return;
end
rows = collect_calipi_memory_rows(pathName, ctx, cfg); % [freqGHz, powerdBm, piNs]
if isempty(rows)
    return;
end
f = rows(:, 1);
pw = rows(:, 2);
valid = isfinite(f) & isfinite(pw);
f = f(valid);
pw = pw(valid);
if isempty(f)
    return;
end
d = abs(f - freqGHz);
dMin = min(d);
idx = find(d == dMin, 1, 'last'); % prefer the most recently appended memory on ties
p = pw(idx);
end

function [fitMap, ok] = fit_odmr_window_from_current_data(window, predicted, odmrCfg)
global gmSEQ

fitMap = struct();
ok = false;

x = double(gmSEQ.SweepParam) .* gmSEQ.ScaleT;
if isfield(gmSEQ, 'signal') && size(gmSEQ.signal, 1) >= 2
    % Keep internal peak extraction consistent with FitESR/legend:
    % use contrast-like signal/reference rather than raw reference counts.
    ref = double(gmSEQ.signal(1, :));
    sig = double(gmSEQ.signal(2, :));
    y = sig ./ ref;
else
    y = double(gmSEQ.signal(1, :));
end
valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
if numel(x) < 7
    return;
end

% For single-peak ODMR windows, use a local Lorentz fit on pulsed sig/ref
% data (same fit model family as FitESR), without relying on cw-ESR state.
if numel(window.labels) == 1
    [fGHzLorentz, fitOk] = fit_single_odmr_lorentz_center_ghz(x, y, window);
    if fitOk
        fitMap.(window.labels{1}) = fGHzLorentz;
        ok = true;
        return;
    end
end

ySmooth = movmean(y, max(5, 2 * floor(numel(y)/60) + 1));
idx = find(ySmooth(2:end-1) <= ySmooth(1:end-2) & ySmooth(2:end-1) <= ySmooth(3:end)) + 1;
if isempty(idx)
    [~, order] = sort(ySmooth, 'ascend');
    idx = order(1:min(20, numel(order)));
end

minSepGHz = odmrCfg.minPeakSepMHz / 1000;
idx = select_minima_with_spacing(idx, ySmooth, x, minSepGHz, max(window.expectedPeakCount*4, 6));
candFreq = sort(x(idx));
if isempty(candFreq)
    return;
end

used = false(1, numel(candFreq));
for i = 1:numel(window.labels)
    label = window.labels{i};
    ref = get_map_freq(predicted, label);
    avail = find(~used);
    [~, rel] = min(abs(candFreq(avail) - ref));
    pick = avail(rel);
    fitMap.(label) = candFreq(pick);
    used(pick) = true;
end
ok = true;
end

function [fGHz, ok] = fit_single_odmr_lorentz_center_ghz(x, y, window)
fGHz = NaN;
ok = false;

valid = isfinite(x) & isfinite(y);
x = double(x(valid));
y = double(y(valid));
if numel(x) < 7
    return;
end

[x, ord] = sort(x, 'ascend');
y = y(ord);

lorentz = @(p, xv) -p(1) .* (p(2)^2 ./ ((xv - p(3)).^2 + p(2)^2)) + p(4);
amp0 = max(y) - min(y);
if ~isfinite(amp0) || amp0 <= 0
    amp0 = eps;
end
width0 = max((max(x) - min(x)) / 20, 1e-4);
width0 = min(width0, 1e-2);
[~, iMin] = min(y);
loc0 = x(iMin);
bg0 = max(y);

yMin = min(y);
yMax = max(y);
if ~isfinite(yMin); yMin = 0; end
if ~isfinite(yMax); yMax = 1; end
ampUb = max([yMax, 2 * (yMax - yMin), eps]);
bgUb = max([2 * yMax, yMax + abs(yMax) + 1e-6]);

p0 = [amp0, width0, loc0, bg0];
lb = [0, 0, min(x), yMin];
ub = [ampUb, 1e-2, max(x), bgUb];

try
    opts = optimoptions('lsqcurvefit', 'Display', 'off');
    popt = lsqcurvefit(lorentz, p0, x, y, lb, ub, opts);
    c = popt(3);
    if isfinite(c) && c >= window.fromGHz && c <= window.toGHz
        fGHz = c;
        ok = true;
    end
catch
    ok = false;
end
end

function idxOut = select_minima_with_spacing(idxIn, ySmooth, x, minSepGHz, maxKeep)
[~, ord] = sort(ySmooth(idxIn), 'ascend');
idxSorted = idxIn(ord);
idxOut = [];
for i = 1:numel(idxSorted)
    c = idxSorted(i);
    if isempty(idxOut) || all(abs(x(c) - x(idxOut)) >= minSepGHz)
        idxOut(end+1) = c; %#ok<AGROW>
    end
    if numel(idxOut) >= maxKeep
        break;
    end
end
if isempty(idxOut)
    idxOut = idxIn(1:min(numel(idxIn), maxKeep));
end
end

function mapOut = merge_freq_map(mapA, mapB)
mapOut = mapA;
f = fieldnames(mapB);
for i = 1:numel(f)
    mapOut.(f{i}) = mapB.(f{i});
end
end

function mapOut = fill_missing_freqs(mapIn, labels, predicted)
mapOut = mapIn;
for i = 1:numel(labels)
    label = labels{i};
    if ~isfield(mapOut, label) || ~isfinite(mapOut.(label))
        mapOut.(label) = get_map_freq(predicted, label);
    end
end
end

function [fSg1, fSg2, labelM1, labelP1] = resolve_target_freqs(target, freqMap)
if strcmp(target.group, 'aligned')
    labelM1 = 'aligned_m1';
    labelP1 = 'aligned_p1';
else
    labelM1 = 'off_m1';
    labelP1 = 'off_p1';
end

fM1 = get_map_freq(freqMap, labelM1);
fP1 = get_map_freq(freqMap, labelP1);

switch target.transition
    case 'SQ_0_TO_M1'
        fSg1 = fM1;
        fSg2 = fM1;
    case 'SQ_0_TO_P1'
        fSg1 = fP1;
        fSg2 = fP1;
    otherwise % DQ_M1_TO_P1
        fSg1 = fM1;
        fSg2 = fP1;
end
end

function [cache, piNs, rabiFreqMHz, powerDbm] = calibrate_rabi_path(pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg, cache)
if stop_requested(hAuto)
    piNs = NaN;
    rabiFreqMHz = NaN;
    powerDbm = NaN;
    return;
end

key = [pathName '_' normalize_to_char(label) '_' strrep(num2str(freqGHz, '%.6f'), '.', 'p')];
if isfield(cache, key)
    piNs = cache.(key).piNs;
    rabiFreqMHz = cache.(key).rabiFreqMHz;
    powerDbm = safe_cache_field(cache.(key), 'powerDbm', NaN);
    return;
end

useCaliPiMode = isfield(ctx.precal, 'calipi') && isfield(ctx.precal.calipi, 'enabled') && ...
    logical(ctx.precal.calipi.enabled);
if useCaliPiMode
    [piNs, rabiFreqMHz, powerDbm] = calibrate_power_for_target_pi( ...
        pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg);
else
    [piNs, rabiFreqMHz, powerDbm] = calibrate_pi_at_fixed_power( ...
        pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg);
end

cache.(key) = struct('piNs', piNs, 'rabiFreqMHz', rabiFreqMHz, 'powerDbm', powerDbm);
end

function [piNs, rabiFreqMHz, powerDbm] = calibrate_pi_at_fixed_power(pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg)
if strcmp(pathName, 'sg2')
    basePow = ctx.power.rabi_sg2_dBm;
    seqName = 'Rabi_SG2';
else
    basePow = ctx.power.rabi_sg1_dBm;
    seqName = 'Rabi';
end
powerDbm = apply_p1_calibration_power_boost(basePow, label, cfg);

seq = build_power_calibration_sequence(seqName, pathName, freqGHz, powerDbm, ctx);
run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, ...
    sprintf(' [%s %s %s @ %.6fGHz P=%.2fdBm]', seqName, upper(pathName), label, freqGHz, powerDbm));
if stop_requested(hAuto)
    piNs = NaN;
    rabiFreqMHz = NaN;
    return;
end
fitting.fit_rabi(hMain, hAuto, false);
global gmSEQ
piNs = safe_gm_field(gmSEQ, 'RabiFitPi', NaN);
rabiFreqMHz = safe_gm_field(gmSEQ, 'RabiFitFreqMHz', NaN);
end

function [piNs, rabiFreqMHz, powerDbm] = calibrate_power_for_target_pi(pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg)
piNs = NaN;
rabiFreqMHz = NaN;
powerDbm = NaN;
if ~isfield(ctx.precal, 'calipi')
    return;
end

if strcmp(pathName, 'sg2')
    basePow = ctx.power.rabi_sg2_dBm;
else
    basePow = ctx.power.rabi_sg1_dBm;
end

if ~isfield(ctx.precal.calipi, 'targetPiNs') || ~isfinite(ctx.precal.calipi.targetPiNs) || ctx.precal.calipi.targetPiNs <= 0
    targetPiNs = NaN;
else
    targetPiNs = ctx.precal.calipi.targetPiNs;
end

powerDbm = pick_power_from_pical_quadratic(pathName, label, freqGHz, basePow, targetPiNs, ctx, hMain, hAuto, hObject, eventdata, cfg);
if ~isfinite(powerDbm)
    safeMax = get_numeric_field_with_default(ctx.precal.calipi, 'maxSafePowerDbm', inf);
    powerDbm = apply_p1_calibration_power_boost(basePow, label, cfg);
    powerDbm = enforce_power_safety_cap(powerDbm, safeMax, 'PiCal fallback base power');
end

% Step 2: run standard Rabi at the fitted power to get final pi time.
[piNs, rabiFreqMHz] = run_rabi_at_fixed_power(pathName, label, freqGHz, powerDbm, ctx, hMain, hAuto, hObject, eventdata, cfg);
if ~isfinite(piNs)
    warning('SmartT1:PiCalRabiFitFailed', ...
        'Rabi fit after PiCal failed for %s/%s at %.6f GHz (P=%.2f dBm).', ...
        pathName, label, freqGHz, powerDbm);
    return;
end
save_calipi_memory_entry(pathName, freqGHz, powerDbm, piNs, ctx, cfg);
if isfinite(targetPiNs)
    disp(sprintf('[SmartT1] PiCal+Rabi result for %s/%s: targetPi=%.2f ns, pi=%.2f ns at P=%.2f dBm', ...
        pathName, label, targetPiNs, piNs, powerDbm));
else
    disp(sprintf('[SmartT1] PiCal+Rabi result for %s/%s: pi=%.2f ns at P=%.2f dBm', ...
        pathName, label, piNs, powerDbm));
end
end

function powerDbm = pick_power_from_pical_quadratic(pathName, label, freqGHz, basePow, targetPiNs, ctx, hMain, hAuto, hObject, eventdata, cfg)
powerDbm = NaN;
safeMax = get_numeric_field_with_default(ctx.precal.calipi, 'maxSafePowerDbm', inf);
quadN = max(3, round(get_numeric_field_with_default(ctx.precal.calipi, 'quadFitNPoints', 5)));
pRef = NaN;

pStart = get_numeric_field_with_default(ctx.precal.calipi, 'powerStartDbm', basePow);
pStop = get_numeric_field_with_default(ctx.precal.calipi, 'powerStopDbm', basePow);
nPow = max(1, round(get_numeric_field_with_default(ctx.precal.calipi, 'powerNPoints', 1)));

if logical(get_numeric_field_with_default(ctx.precal.calipi, 'useMemoryPrior', 1)) && ...
        isfinite(targetPiNs) && targetPiNs > 0
    [pPred, predSource] = predict_power_from_calipi_memory(pathName, freqGHz, targetPiNs, ctx, cfg);
    if isfinite(pPred)
        pRef = pPred;
        halfSpan = max(0.5, get_numeric_field_with_default(ctx.precal.calipi, 'memoryWindowHalfSpanDb', 4));
        pStart = pPred - halfSpan;
        pStop = pPred + halfSpan;
        disp(sprintf('[SmartT1] PiCal memory prior (%s): Ppred=%.2f dBm -> sweep [%.2f, %.2f] dBm at %.6f GHz', ...
            predSource, pPred, pStart, pStop, freqGHz));
    end
end

pStart = apply_p1_calibration_power_boost(pStart, label, cfg);
pStop = apply_p1_calibration_power_boost(pStop, label, cfg);

pStart = enforce_power_safety_cap(pStart, safeMax, 'PiCal sweep start');
pStop = enforce_power_safety_cap(pStop, safeMax, 'PiCal sweep stop');
if nPow <= 1 || abs(pStop - pStart) < eps
    pStart = apply_p1_calibration_power_boost(basePow, label, cfg);
    pStart = enforce_power_safety_cap(pStart, safeMax, 'PiCal single power');
    pStop = pStart;
    nPow = 1;
end

if strcmp(pathName, 'sg2')
    seqName = 'PiCal_SG2';
else
    seqName = 'PiCal';
end
    seq = build_pical_power_sweep_sequence(seqName, pathName, freqGHz, pStart, pStop, nPow, targetPiNs, ctx);
run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, ...
    sprintf(' [%s %s %s @ %.6fGHz P:[%.2f, %.2f] dBm]', seqName, upper(pathName), label, freqGHz, pStart, pStop));
if stop_requested(hAuto)
    return;
end

[xPow, yContrast] = extract_rabi_like_contrast_from_current_data();
if numel(xPow) < 3
    warning('SmartT1:PiCalDataTooSmall', ...
        'PiCal data too small for quadratic fit (%s/%s @ %.6f GHz).', pathName, label, freqGHz);
    powerDbm = apply_p1_calibration_power_boost(basePow, label, cfg);
    powerDbm = enforce_power_safety_cap(powerDbm, safeMax, 'PiCal fallback base power');
    return;
end

[pFit, fitOk] = fit_quadratic_power_near_minimum(xPow, yContrast, quadN, pRef);
if ~fitOk || ~isfinite(pFit)
    warning('SmartT1:PiCalQuadraticFitFailed', ...
        'PiCal quadratic fit failed for %s/%s at %.6f GHz. Falling back to sampled minimum.', ...
        pathName, label, freqGHz);
    iMin = pick_local_min_index(xPow, yContrast, pRef, quadN);
    pFit = xPow(iMin);
end
pFit = min(max(pFit, min(xPow)), max(xPow));
pFit = enforce_power_safety_cap(pFit, safeMax, 'PiCal fitted power');
powerDbm = pFit;
disp(sprintf('[SmartT1] PiCal fitted power for %s/%s at %.6f GHz: %.2f dBm', ...
    pathName, label, freqGHz, powerDbm));
end

function [piNs, rabiFreqMHz] = run_rabi_at_fixed_power(pathName, label, freqGHz, powerDbm, ctx, hMain, hAuto, hObject, eventdata, cfg)
piNs = NaN;
rabiFreqMHz = NaN;
if strcmp(pathName, 'sg2')
    seqName = 'Rabi_SG2';
else
    seqName = 'Rabi';
end
seq = build_power_calibration_sequence(seqName, pathName, freqGHz, powerDbm, ctx);
run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, ...
    sprintf(' [%s %s %s @ %.6fGHz P=%.2fdBm]', seqName, upper(pathName), label, freqGHz, powerDbm));
if stop_requested(hAuto)
    return;
end
fitting.fit_rabi(hMain, hAuto, false);
global gmSEQ
piNs = safe_gm_field(gmSEQ, 'RabiFitPi', NaN);
rabiFreqMHz = safe_gm_field(gmSEQ, 'RabiFitFreqMHz', NaN);
end

function seq = build_pical_power_sweep_sequence(seqName, pathName, freqGHz, pStart, pStop, nPow, targetPiNs, ctx)
seq = struct();
seq.name = seqName;
seq.FROM1 = num2str(pStart);
seq.TO1 = num2str(pStop);
seq.SweepNPoints = num2str(max(1, round(nPow)));
seq.Repeat = num2str(max(1, round(ctx.precal.rabi.repeat)));
seq.Average = num2str(max(1, round(ctx.precal.rabi.average)));
seq.bSweep2 = 0;
if isfinite(targetPiNs) && targetPiNs > 0
    seq.pi = num2str(targetPiNs, '%.0f');
end
if strcmp(pathName, 'sg2')
    seq.useSG2 = 1;
    seq.fixFreq2 = num2str(freqGHz, '%.8f');
else
    seq.useSG2 = 0;
    seq.fixFreq = num2str(freqGHz, '%.8f');
end
end

function [xPow, yContrast] = extract_rabi_like_contrast_from_current_data()
global gmSEQ
xPow = [];
yContrast = [];
if ~isfield(gmSEQ, 'signal') || ~isfield(gmSEQ, 'SweepParam')
    return;
end
signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1));
if size(signal, 1) < 2 || isempty(signal)
    return;
end
sig = signal(2, :);
ref = signal(1, :);
y = sig ./ ref;
x = double(gmSEQ.SweepParam(1:numel(y)));
valid = isfinite(x) & isfinite(y);
x = x(valid);
y = y(valid);
if isempty(x)
    return;
end
[xPow, ord] = sort(x(:), 'ascend');
yContrast = y(ord);
end

function [pFit, ok] = fit_quadratic_power_near_minimum(xPow, yContrast, nFitPts, pRef)
pFit = NaN;
ok = false;
n = numel(xPow);
if n < 3
    return;
end
iMin = pick_local_min_index(xPow, yContrast, pRef, nFitPts);
nWin = min(n, max(3, round(nFitPts)));
half = floor(nWin/2);
i0 = max(1, iMin - half);
i1 = min(n, i0 + nWin - 1);
i0 = max(1, i1 - nWin + 1);
xw = xPow(i0:i1);
yw = yContrast(i0:i1);
if numel(unique(xw)) < 3
    return;
end
p = polyfit(xw, yw, 2);
a = p(1);
b = p(2);
if ~isfinite(a) || ~isfinite(b) || a <= 0
    return;
end
pFit = -b / (2*a);
ok = isfinite(pFit);
end

function iMin = pick_local_min_index(xPow, yContrast, pRef, nFitPts)
n = numel(xPow);
if n <= 1
    iMin = 1;
    return;
end
if nargin < 3 || ~isfinite(pRef)
    [~, iMin] = min(yContrast);
    return;
end

[~, iRef] = min(abs(xPow - pRef));
nSearch = min(n, max(3, round(nFitPts)));
half = floor(nSearch/2);
i0 = max(1, iRef - half);
i1 = min(n, i0 + nSearch - 1);
i0 = max(1, i1 - nSearch + 1);

[~, idx] = min(yContrast(i0:i1));
iMin = i0 + idx - 1;
end

function pOut = enforce_power_safety_cap(pIn, maxSafe, whatLabel)
pOut = pIn;
if isfinite(maxSafe) && pOut > maxSafe
    warning('SmartT1:PowerSafetyCap', '%s capped from %.2f dBm to %.2f dBm.', whatLabel, pOut, maxSafe);
    pOut = maxSafe;
end
end

function v = get_numeric_field_with_default(s, fieldName, defaultValue)
v = defaultValue;
if isstruct(s) && isfield(s, fieldName) && isfinite(s.(fieldName))
    v = s.(fieldName);
end
end

function [pPred, source] = predict_power_from_calipi_memory(pathName, freqGHz, targetPiNs, ctx, cfg)
pPred = NaN;
source = 'none';
if ~isfinite(freqGHz) || ~isfinite(targetPiNs) || targetPiNs <= 0
    return;
end

rows = collect_calipi_memory_rows(pathName, ctx, cfg);
if isempty(rows)
    return;
end

fGHz = rows(:, 1);
pDbm = rows(:, 2);
piNs = rows(:, 3);
valid = isfinite(fGHz) & isfinite(pDbm) & isfinite(piNs) & (piNs > 0);
fGHz = fGHz(valid);
pDbm = pDbm(valid);
piNs = piNs(valid);
if isempty(fGHz)
    return;
end

% Normalize every memory point to the requested target pi using
% pi ~ 1/sqrt(P):  P_target(dBm) = P_meas(dBm) + 20*log10(pi_meas/pi_target).
pTargetDbm = pDbm + 20 * log10(piNs ./ targetPiNs);

% Use local neighborhood in frequency to reduce bias from distant/outlier points.
[~, ord] = sort(abs(fGHz - freqGHz), 'ascend');
k = min(numel(ord), 6);
idxLocal = ord(1:k);
fLoc = fGHz(idxLocal);
pLoc = pTargetDbm(idxLocal);

if numel(pLoc) >= 2 && numel(unique(fLoc)) >= 2
    c = polyfit(fLoc, pLoc, 1);
    pPred = polyval(c, freqGHz);
    source = 'memory_local_linear';
else
    [~, iNear] = min(abs(fLoc - freqGHz));
    pPred = pLoc(iNear);
    source = 'memory_nearest';
end

if isfinite(pPred)
    pMin = min(pTargetDbm) - 6;
    pMax = max(pTargetDbm) + 6;
    pPred = min(max(pPred, pMin), pMax);
end
end

function rows = collect_calipi_memory_rows(pathName, ctx, cfg)
rows = [];
fieldName = 'sg1';
if strcmp(pathName, 'sg2')
    fieldName = 'sg2';
end

if isfield(ctx, 'precal') && isfield(ctx.precal, 'calipi') && ...
        isfield(ctx.precal.calipi, 'defaultMemory') && ...
        isstruct(ctx.precal.calipi.defaultMemory) && ...
        isfield(ctx.precal.calipi.defaultMemory, fieldName)
    defaultRows = double(ctx.precal.calipi.defaultMemory.(fieldName));
    if ~isempty(defaultRows) && size(defaultRows, 2) >= 3
        rows = [rows; defaultRows(:, 1:3)]; %#ok<AGROW>
    end
elseif isfield(cfg, 'smart') && isfield(cfg.smart, 'precal') && ...
        isfield(cfg.smart.precal, 'calipi') && isfield(cfg.smart.precal.calipi, 'defaultMemory') && ...
        isstruct(cfg.smart.precal.calipi.defaultMemory) && isfield(cfg.smart.precal.calipi.defaultMemory, fieldName)
    defaultRows = double(cfg.smart.precal.calipi.defaultMemory.(fieldName));
    if ~isempty(defaultRows) && size(defaultRows, 2) >= 3
        rows = [rows; defaultRows(:, 1:3)]; %#ok<AGROW>
    end
end

memFile = get_calipi_memory_file(ctx, cfg);
if ~isempty(memFile) && exist(memFile, 'file')
    try
        s = load(memFile, 'mem');
        if isfield(s, 'mem') && isstruct(s.mem) && isfield(s.mem, fieldName)
            memRows = double(s.mem.(fieldName));
            if ~isempty(memRows) && size(memRows, 2) >= 3
                rows = [rows; memRows(:, 1:3)]; %#ok<AGROW>
            end
        end
    catch ME
        warning('SmartT1:PiCalMemoryLoadFailed', 'Failed to load PiCal memory file (%s): %s', memFile, ME.message);
    end
end

if isempty(rows)
    return;
end
rows = rows(all(isfinite(rows), 2) & rows(:, 3) > 0, :);
end

function save_calipi_memory_entry(pathName, freqGHz, powerDbm, piNs, ctx, cfg)
if ~isfinite(freqGHz) || ~isfinite(powerDbm) || ~isfinite(piNs) || piNs <= 0
    return;
end

fieldName = 'sg1';
if strcmp(pathName, 'sg2')
    fieldName = 'sg2';
end

memFile = get_calipi_memory_file(ctx, cfg);
if isempty(memFile)
    return;
end

mem = struct('sg1', [], 'sg2', []);
if exist(memFile, 'file')
    try
        s = load(memFile, 'mem');
        if isfield(s, 'mem') && isstruct(s.mem)
            mem = s.mem;
            if ~isfield(mem, 'sg1'); mem.sg1 = []; end
            if ~isfield(mem, 'sg2'); mem.sg2 = []; end
        end
    catch
        % Keep fresh struct fallback.
    end
end

arr = mem.(fieldName);
if isempty(arr)
    arr = zeros(0, 3);
end
arr = double(arr);
if size(arr, 2) < 3
    arr(:, end+1:3) = NaN;
elseif size(arr, 2) > 3
    arr = arr(:, 1:3);
end
arr = [arr; [freqGHz, powerDbm, piNs]];
arr = arr(all(isfinite(arr), 2) & arr(:, 3) > 0, :);

maxRows = max(10, round(get_numeric_field_with_default(ctx.precal.calipi, 'maxMemoryRows', 400)));
if size(arr, 1) > maxRows
    arr = arr(end-maxRows+1:end, :);
end
mem.(fieldName) = arr;

try
    folder = fileparts(memFile);
    if ~isempty(folder) && ~exist(folder, 'dir')
        mkdir(folder);
    end
    save(memFile, 'mem');
catch ME
    warning('SmartT1:PiCalMemorySaveFailed', 'Failed to save PiCal memory file (%s): %s', memFile, ME.message);
end
end

function memFile = get_calipi_memory_file(ctx, cfg)
memFile = '';
if isfield(ctx, 'precal') && isfield(ctx.precal, 'calipi') && isfield(ctx.precal.calipi, 'memoryFile')
    memFile = ctx.precal.calipi.memoryFile;
elseif isfield(cfg, 'smart') && isfield(cfg.smart, 'precal') && ...
        isfield(cfg.smart.precal, 'calipi') && isfield(cfg.smart.precal.calipi, 'memoryFile')
    memFile = cfg.smart.precal.calipi.memoryFile;
else
    memFile = fullfile(fileparts(mfilename('fullpath')), 'calipi_memory.mat');
end
if isstring(memFile)
    memFile = char(memFile);
end
end

function seq = build_power_calibration_sequence(seqName, pathName, freqGHz, powerDbm, ctx)
seq = struct();
seq.name = seqName;
seq.FROM1 = num2str(ctx.precal.rabi.start);
seq.TO1 = num2str(ctx.precal.rabi.stop);
seq.SweepNPoints = num2str(max(3, round(ctx.precal.rabi.nPoints)));
seq.Repeat = num2str(max(1, round(ctx.precal.rabi.repeat)));
seq.Average = num2str(max(1, round(ctx.precal.rabi.average)));
seq.bSweep2 = 0;
if strcmp(pathName, 'sg2')
    seq.useSG2 = 1;
    seq.fixPow2 = num2str(powerDbm);
    seq.fixFreq2 = num2str(freqGHz, '%.8f');
else
    seq.useSG2 = 0;
    seq.fixPow = num2str(powerDbm);
    seq.fixFreq = num2str(freqGHz, '%.8f');
end
end

function out = safe_cache_field(s, fieldName, defaultValue)
out = defaultValue;
if isstruct(s) && isfield(s, fieldName) && ~isempty(s.(fieldName))
    out = s.(fieldName);
end
end

function p = choose_best_precal_power(powMap, labelM1, labelP1, transition, defaultPow, useP1ForDQ)
p = defaultPow;
switch transition
    case 'SQ_0_TO_M1'
        cand = get_map_freq(powMap, labelM1);
    case 'SQ_0_TO_P1'
        cand = get_map_freq(powMap, labelP1);
    otherwise
        if useP1ForDQ
            cand = get_map_freq(powMap, labelP1);
        else
            cand = get_map_freq(powMap, labelM1);
        end
end
if isfinite(cand)
    p = cand;
end
end

function [piSg1, freqSg1MHz, pSg1, piSg2, freqSg2MHz, pSg2] = ...
    maybe_match_pi_when_one_power_capped(target, labelM1, labelP1, fSg1, fSg2, ...
    piSg1, freqSg1MHz, pSg1, piSg2, freqSg2MHz, pSg2, ...
    ctx, hMain, hAuto, hObject, eventdata, cfg)

if ~strcmp(target.transition, 'DQ_M1_TO_P1')
    return;
end
if ~isfield(ctx, 'precal') || ~isfield(ctx.precal, 'pi_match')
    return;
end

pm = ctx.precal.pi_match;
if ~isfield(pm, 'enabled') || ~logical(pm.enabled)
    return;
end

tolNs = get_numeric_field_with_default(pm, 'tolNs', 10);
maxIter = max(1, round(get_numeric_field_with_default(pm, 'maxIter', 3)));
minSafe = get_numeric_field_with_default(pm, 'minSafePowerDbm', -40);
maxSafeCommon = get_numeric_field_with_default(ctx.precal.calipi, 'maxSafePowerDbm', inf);
maxSafeSg1 = get_numeric_field_with_default(ctx.precal.calipi, 'maxSafePowerDbmSg1', maxSafeCommon);
maxSafeSg2 = get_numeric_field_with_default(ctx.precal.calipi, 'maxSafePowerDbmSg2', maxSafeCommon);

if ~isfinite(piSg1) || ~isfinite(piSg2) || ~isfinite(pSg1) || ~isfinite(pSg2)
    return;
end
if piSg1 <= 0 || piSg2 <= 0 || ~isfinite(fSg1) || ~isfinite(fSg2)
    return;
end
if abs(piSg1 - piSg2) <= tolNs
    return;
end

atCap1 = isfinite(maxSafeSg1) && (pSg1 >= maxSafeSg1);
atCap2 = isfinite(maxSafeSg2) && (pSg2 >= maxSafeSg2);
if xor(atCap1, atCap2) == 0
    return;
end

if atCap1
    anchorPi = piSg1;
    adjustPath = 'sg2';
    adjustLabel = labelP1;
    adjustFreqGHz = fSg2;
    adjustPi = piSg2;
    adjustFreqMHz = freqSg2MHz;
    adjustPow = pSg2;
    adjustMaxSafe = maxSafeSg2;
else
    anchorPi = piSg2;
    adjustPath = 'sg1';
    adjustLabel = labelM1;
    adjustFreqGHz = fSg1;
    adjustPi = piSg1;
    adjustFreqMHz = freqSg1MHz;
    adjustPow = pSg1;
    adjustMaxSafe = maxSafeSg1;
end

disp(sprintf('[SmartT1] PI-MATCH start (%s): pi1=%.2f ns @ %.2f dBm, pi2=%.2f ns @ %.2f dBm', ...
    target.id, piSg1, pSg1, piSg2, pSg2));

% Intent policy: when one SG is capped, only reduce the other SG power.
if adjustPi >= (anchorPi + tolNs)
    disp(sprintf(['[SmartT1] PI-MATCH skip (%s): non-capped %s already slower ', ...
        '(pi=%.2f ns) than capped anchor (pi=%.2f ns). Reduce-only policy cannot improve.'], ...
        target.id, upper(adjustPath), adjustPi, anchorPi));
    return;
end

for iIter = 1:maxIter
    if stop_requested(hAuto)
        return;
    end
    if ~isfinite(anchorPi) || ~isfinite(adjustPi) || anchorPi <= 0 || adjustPi <= 0
        break;
    end

    pTarget = adjustPow + 20 * log10(adjustPi / anchorPi);
    % Reduce-only policy on the non-capped channel.
    pNew = min(pTarget, adjustPow);
    if ~isfinite(pNew)
        break;
    end
    pNew = max(pNew, minSafe);
    if isfinite(adjustMaxSafe)
        pNew = min(pNew, adjustMaxSafe);
    end

    if abs(pNew - adjustPow) < 1e-9
        break;
    end

    [piNew, freqNewMHz] = run_rabi_at_fixed_power(adjustPath, adjustLabel, adjustFreqGHz, pNew, ctx, hMain, hAuto, hObject, eventdata, cfg);
    if ~isfinite(piNew) || piNew <= 0
        break;
    end

    adjustPow = pNew;
    adjustPi = piNew;
    adjustFreqMHz = freqNewMHz;
    errNs = abs(adjustPi - anchorPi);
    disp(sprintf('[SmartT1] PI-MATCH iter %d (%s): P=%.2f dBm, pi=%.2f ns, err=%.2f ns', ...
        iIter, upper(adjustPath), adjustPow, adjustPi, errNs));

    if errNs <= tolNs
        break;
    end

    atBoundary = (adjustPow <= minSafe) || (isfinite(adjustMaxSafe) && adjustPow >= adjustMaxSafe);
    if atBoundary
        break;
    end
end

if strcmp(adjustPath, 'sg2')
    piSg2 = adjustPi;
    freqSg2MHz = adjustFreqMHz;
    pSg2 = adjustPow;
else
    piSg1 = adjustPi;
    freqSg1MHz = adjustFreqMHz;
    pSg1 = adjustPow;
end

disp(sprintf('[SmartT1] PI-MATCH done (%s): pi1=%.2f ns @ %.2f dBm, pi2=%.2f ns @ %.2f dBm', ...
    target.id, piSg1, pSg1, piSg2, pSg2));
end

function [finalRange, roughInfo] = determine_t1_final_range(target, fSg1, fSg2, piSg1, piSg2, ctx, hMain, hAuto, hObject, eventdata, cfg)
roughInfo = struct('t1RoughMs', NaN, 'fitRelErr', NaN, 'edgeRatio', NaN, ...
    'nRuns', 0, 'stopEstimator', ctx.rough.stopEstimator);
start0 = target.t1.start;
stop0 = target.t1.stop;
if ~isfinite(start0)
    start0 = 0;
end
start0 = max(0, start0); % never move start below 0

if ~isfinite(stop0)
    stop0 = start0 + 1;
end
if stop0 <= start0
    % Keep start fixed and rebuild a minimal valid span.
    stop0 = start0 + max(1e-6, abs(stop0 - start0) + 1e-6);
end

maxStopCap = inf;
if isfield(ctx.rough, 'maxStopNs') && isfinite(ctx.rough.maxStopNs) && ctx.rough.maxStopNs > 0
    maxStopCap = ctx.rough.maxStopNs;
end
if isfinite(maxStopCap) && maxStopCap <= start0
    maxStopCap = start0 + 1;
end

if ~ctx.rough.enabled
    if isfinite(maxStopCap)
        stop0 = min(stop0, maxStopCap);
    end
    finalRange = [start0, stop0];
    return;
end

if stop_requested(hAuto)
    finalRange = [start0, stop0];
    return;
end

rangeRough = [start0, stop0];
roughHist = struct('xMs', [], 'xDisp', [], 'y', []);
for iTry = 1:max(1, ctx.rough.maxRetries)
    if stop_requested(hAuto)
        finalRange = rangeRough;
        return;
    end

    roughInfo.nRuns = iTry;
    targetRough = target;
    if isfinite(ctx.rough.nPoints) && ctx.rough.nPoints >= 3
        targetRough.t1.nPoints = round(ctx.rough.nPoints);
    end
    roughSeq = build_t1_sequence(targetRough, rangeRough, fSg1, fSg2, piSg1, piSg2, ctx);
    roughSeq.Repeat = num2str(max(1, ctx.rough.repeat));
    roughSeq.Average = num2str(max(1, ctx.rough.average));

    run_one_sequence(roughSeq, hMain, hAuto, hObject, eventdata, cfg, ...
        sprintf(' [Rough T1 %s try %d]', target.id, iTry));
    if stop_requested(hAuto)
        finalRange = rangeRough;
        return;
    end

    overlay_previous_rough_points(hMain, roughHist.xDisp, roughHist.y);
    [t1Ms, relErr, curData, fitCurve, edgeRatio] = estimate_t1_from_current_data( ...
        target.transition, roughHist.xMs, roughHist.y, ctx.rough, cfg.smart.t1fit);
    if ~isempty(curData.xMs)
        roughHist.xMs = [roughHist.xMs; curData.xMs(:)];
        roughHist.xDisp = [roughHist.xDisp; curData.xDisp(:)];
        roughHist.y = [roughHist.y; curData.y(:)];
    end
    overlay_combined_rough_fit(hMain, fitCurve.xPlotMs, fitCurve.yPlot, t1Ms, relErr);
    save_rough_overlay_figure(hMain, hAuto, cfg, ...
        sprintf(' [Rough T1 %s try %d]', target.id, iTry));

    roughInfo.t1RoughMs = t1Ms;
    roughInfo.fitRelErr = relErr;
    roughInfo.edgeRatio = edgeRatio;
    if isfinite(t1Ms)
        update_rough_t1_display(hAuto, cfg, t1Ms);
    elseif isfinite(edgeRatio)
        update_rough_ratio_display(hAuto, cfg, edgeRatio);
    end
    if strcmpi(ctx.rough.stopEstimator, 'edge_ratio')
        if isfinite(edgeRatio) && edgeRatio <= ctx.rough.ratioThreshold
            break;
        end
    elseif isfinite(t1Ms)
        if strcmpi(ctx.rough.stopPolicy, 'first_good') && relErr <= ctx.rough.fitRelErrThreshold
            break;
        end
    end

    % Retry policy:
    % - fit modes: extend stop to stopFactor*Tmetric (ms->ns)
    % - edge-ratio mode: extend current span multiplicatively.
    if strcmpi(ctx.rough.stopEstimator, 'edge_ratio')
        span = max(rangeRough(2) - rangeRough(1), 1) * ctx.rough.ratioExtendFactor;
    elseif isfinite(t1Ms) && t1Ms > 0
        span = ctx.rough.stopFactor * t1Ms * 1e6;
    else
        span = max(rangeRough(2) - rangeRough(1), 1);
    end
    span = round_span_to_1000(span);
    stopTry = start0 + span;
    stopTry = align_stop_to_integer_points(start0, stopTry, max(2, round(targetRough.t1.nPoints)));
    if isfinite(maxStopCap) && stopTry > maxStopCap
        stopTry = maxStopCap;
        disp(sprintf('[SmartT1] Rough stop clipped by cfg.maxStopNs for %s: %.4f ns', ...
            target.id, maxStopCap));
    end
    rangeRough = [start0, stopTry];
end

if strcmpi(ctx.rough.stopEstimator, 'edge_ratio')
    finalRange = rangeRough;
    return;
end

if ~isfinite(roughInfo.t1RoughMs)
    finalRange = [start0, stop0];
    return;
end

% Policy:
% 1) Keep start fixed.
% 2) If stop is within [start+1.5*T1, start+3*T1], keep stop.
% 3) Otherwise set stop to start+stopFactor*T1.
stopMin = start0 + ctx.rough.minSpanFactor * roughInfo.t1RoughMs * 1e6;
stopMax = start0 + ctx.rough.maxSpanFactor * roughInfo.t1RoughMs * 1e6;
stopTarget = start0 + ctx.rough.stopFactor * roughInfo.t1RoughMs * 1e6;

newStart = start0; % start must remain unchanged
newStop = stop0;
reason = 'within_range';
if stop0 < stopMin || stop0 > stopMax
    newStop = stopTarget;
    if stop0 < stopMin
        reason = 'too_short';
    else
        reason = 'too_long';
    end
end

nPts = max(2, round(target.t1.nPoints));
% Only force integer grid when stop is auto-corrected.
if ~strcmp(reason, 'within_range')
    spanCorr = round_span_to_1000(newStop - newStart);
    newStop = newStart + spanCorr;
    newStop = align_stop_to_integer_points(newStart, newStop, nPts);
end
if isfinite(maxStopCap) && newStop > maxStopCap
    newStop = maxStopCap;
    disp(sprintf('[SmartT1] Final stop clipped by cfg.maxStopNs for %s: %.4f ns', ...
        target.id, maxStopCap));
end
finalRange = [newStart, newStop];

if ~strcmp(reason, 'within_range')
    disp(sprintf(['[SmartT1] Stop correction for %s (%s): start=%.4f, stop %.4f -> %.4f, ', ...
        'T1rough=%.4fms, nPts=%d'], ...
        target.id, reason, start0, stop0, newStop, roughInfo.t1RoughMs, nPts));
end
end

function [t1Ms, relErr, curData, fitCurve, edgeRatio] = estimate_t1_from_current_data( ...
    transition, histXMs, histY, roughCfg, t1FitCfg)
global gmSEQ
t1Ms = NaN;
relErr = inf;
curData = struct('xMs', [], 'xDisp', [], 'y', []);
fitCurve = struct('xPlotMs', [], 'yPlot', []);
edgeRatio = NaN;

if nargin < 2 || isempty(histXMs)
    histXMs = [];
end
if nargin < 3 || isempty(histY)
    histY = [];
end
if nargin < 4 || ~isstruct(roughCfg)
    roughCfg = struct('stopEstimator', 'single_exp');
end
if nargin < 5 || ~isstruct(t1FitCfg)
    t1FitCfg = struct();
end

if ~isfield(gmSEQ, 'signal') || isempty(gmSEQ.signal)
    return;
end

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1));
if isempty(signal)
    return;
end

% gmSEQ.SweepParam is programmed in ns from GUI/main sequence fields.
% fitting.fit_t1 expects x in ms, so convert directly ns->ms here.
xMs = double(gmSEQ.SweepParam(1:size(signal, 2))) * 1e-6;
xDisp = double(gmSEQ.SweepParam(1:size(signal, 2))) .* safe_gm_field(gmSEQ, 'ScaleT', 1e-6);

try
    switch transition
        case {'SQ_0_TO_M1', 'SQ_0_TO_P1'}
            if size(signal,1) >= 5
                sig = signal(2,:) - signal(5,:);
                ref = (signal(1,:) + signal(4,:))/2;
            else
                sig = signal(min(2,size(signal,1)),:);
                ref = signal(1,:);
            end
        otherwise % DQ
            if size(signal,1) >= 5
                sig = signal(2,:) - signal(5,:);
                ref = (signal(1,:) + signal(4,:))/2;
            else
                sig = signal(min(2,size(signal,1)),:);
                ref = signal(1,:);
            end
    end

    y = sig ./ ref;
    valid = isfinite(xMs) & isfinite(y);
    xMs = xMs(valid);
    xDisp = xDisp(valid);
    y = y(valid);
    curData.xMs = xMs(:);
    curData.xDisp = xDisp(:);
    curData.y = y(:);

    xFit = [histXMs(:); xMs(:)];
    yFit = [histY(:); y(:)];
    validFit = isfinite(xFit) & isfinite(yFit);
    xFit = xFit(validFit);
    yFit = yFit(validFit);

    if strcmpi(roughCfg.stopEstimator, 'edge_ratio')
        if numel(y) >= 2 && isfinite(y(1)) && isfinite(y(end))
            edgeRatio = abs(y(end)) / max(abs(y(1)), eps);
        end
        return;
    end

    if numel(xFit) < 6
        return;
    end

    fitModel = 'single_exp';
    if strcmpi(roughCfg.stopEstimator, 'stretched_div_n')
        fitModel = 'stretched_exp';
    end
    [popt, perr, xPlotMs, yPlot] = run_t1_fit_with_model(xFit, yFit, fitModel, t1FitCfg);
    fitCurve.xPlotMs = xPlotMs;
    fitCurve.yPlot = yPlot;

    rate = popt(1);
    if isfinite(rate) && rate > 0
        baseT1Ms = 1 / rate;
        relBase = perr(1) / max(abs(rate), eps);
        if strcmpi(roughCfg.stopEstimator, 'stretched_div_n')
            n = NaN;
            nErr = NaN;
            if numel(popt) >= 3 && isfinite(popt(3))
                n = popt(3);
            end
            if numel(perr) >= 3 && isfinite(perr(3))
                nErr = perr(3);
            end
            if isfinite(n) && n > 0
                t1Ms = baseT1Ms / n;
                relN = 0;
                if isfinite(nErr)
                    relN = nErr / max(abs(n), eps);
                end
                relErr = sqrt(relBase.^2 + relN.^2);
            end
        else
            t1Ms = baseT1Ms;
            relErr = relBase;
        end
    end
catch
    t1Ms = NaN;
    relErr = inf;
end
end

function [popt, perr, xPlot, yPlot] = run_t1_fit_with_model(x, y, modelName, t1FitCfg)
global gmSEQ

prevModel = '';
if isfield(gmSEQ, 'T1FitModel')
    prevModel = gmSEQ.T1FitModel;
end
prevCfg = struct();
if isfield(gmSEQ, 'T1FitCfg') && isstruct(gmSEQ.T1FitCfg)
    prevCfg = gmSEQ.T1FitCfg;
end
cleanupObj = onCleanup(@() restore_t1_fit_model(prevModel, prevCfg)); %#ok<NASGU>

gmSEQ.T1FitModel = modelName;
gmSEQ.T1FitCfg = t1FitCfg;
[popt, perr, xPlot, yPlot] = fitting.fit_t1(x, y);
end

function restore_t1_fit_model(prevModel, prevCfg)
global gmSEQ
gmSEQ.T1FitModel = prevModel;
gmSEQ.T1FitCfg = prevCfg;
end

function outPow = apply_p1_calibration_power_boost(basePow, labelOrLabels, cfg)
outPow = basePow;
boost = 0;
if isfield(cfg, 'smart') && isfield(cfg.smart, 'power') && ...
        isfield(cfg.smart.power, 'sq_p1_calibration_boost_dB') && ...
        isfinite(cfg.smart.power.sq_p1_calibration_boost_dB)
    boost = cfg.smart.power.sq_p1_calibration_boost_dB;
end
if boost == 0
    return;
end
if is_p1_calibration_label(labelOrLabels)
    outPow = basePow + boost;
end
end

function tf = is_p1_calibration_label(labelOrLabels)
tf = false;
if iscell(labelOrLabels)
    for i = 1:numel(labelOrLabels)
        s = lower(strtrim(normalize_to_char(labelOrLabels{i})));
        if ~isempty(regexp(s, '_p1$', 'once'))
            tf = true;
            return;
        end
    end
else
    s = lower(strtrim(normalize_to_char(labelOrLabels)));
    tf = ~isempty(regexp(s, '_p1$', 'once'));
end
end

function overlay_previous_rough_points(handlesMain, xPrevDisp, yPrev)
if nargin < 3 || isempty(xPrevDisp) || isempty(yPrev)
    return;
end
if ~isfield(handlesMain, 'axes3') || ~isgraphics(handlesMain.axes3, 'axes')
    return;
end
ax = handlesMain.axes3;
delete(findobj(ax, 'Tag', 'rough_prev_points'));
hold(ax, 'on');
plot(ax, xPrevDisp, yPrev, ...
    'LineStyle', 'none', ...
    'Marker', 'o', ...
    'MarkerSize', 4, ...
    'Color', [0.55 0.55 0.55], ...
    'DisplayName', 'Prev rough tries', ...
    'Tag', 'rough_prev_points');
if isfield(handlesMain, 'bShowLegend') && get(handlesMain.bShowLegend, 'Value')
    legend(ax, 'Location', 'best');
end
hold(ax, 'off');
end

function overlay_combined_rough_fit(handlesMain, xPlotMs, yPlot, t1Ms, relErr)
if ~isfield(handlesMain, 'axes3') || ~isgraphics(handlesMain.axes3, 'axes')
    return;
end
global gmSEQ
ax = handlesMain.axes3;
delete(findobj(ax, 'Tag', 'rough_combined_fit'));
if nargin < 4 || isempty(xPlotMs) || isempty(yPlot)
    return;
end
scaleT = safe_gm_field(gmSEQ, 'ScaleT', 1e-6);
xPlotDisp = xPlotMs .* (scaleT / 1e-6);
if isfinite(t1Ms)
    label = sprintf('Rough combined fit: T1=%.4f ms (relErr=%.3f)', t1Ms, relErr);
else
    label = 'Rough combined fit';
end
hold(ax, 'on');
plot(ax, xPlotDisp, yPlot, ...
    'LineStyle', '--', ...
    'LineWidth', 1.0, ...
    'Color', [0.10 0.55 0.10], ...
    'DisplayName', label, ...
    'Tag', 'rough_combined_fit');
if isfield(handlesMain, 'bShowLegend') && get(handlesMain.bShowLegend, 'Value')
    legend(ax, 'Location', 'best');
end
hold(ax, 'off');
end

function save_rough_overlay_figure(handlesMain, handlesAuto, cfg, suffix)
global gSaveDataAve
if isempty(gSaveDataAve) || ~isstruct(gSaveDataAve) || ~isfield(gSaveDataAve, 'file')
    return;
end
save_main_figure(handlesMain, handlesAuto, gSaveDataAve.file, cfg, ...
    ['. Current sequence is finished.' suffix], 'Rough_T1_');
end

function seq = build_t1_sequence(target, range, fSg1, fSg2, piSg1, piSg2, ctx)
tStart = range(1);
tStop = range(2);
n = max(3, round(target.t1.nPoints));
n1 = n;
n2 = 0;
split = tStart + (tStop - tStart)/4;
[powLabelSg1, powLabelSg2] = get_t1_power_labels(target);

if ctx.nonuniform
    n1 = max(2, ceil(n/2));
    n2 = max(1, floor(n/2));
    targetSpan = round_span_to_1000(tStop - tStart);
    [splitSolve, stopSolve, okSolve] = solve_nonuniform_span_grid(tStart, targetSpan, n1, n2, split);
    if okSolve
        split = splitSolve;
        tStop = stopSolve;
    else
        [split, tStop] = align_nonuniform_grid(tStart, split, tStop, n1, n2);
        tStop = tStart + round_span_to_1000(tStop - tStart);
    end
    [split, tStop, nudged] = force_integer_grid_nonuniform(tStart, split, tStop, n1, n2);
    if nudged
        disp(sprintf(['[SmartT1] Smart-distribution grid adjusted for integer points: ', ...
            'start=%.0f, split=%.0f, stop=%.0f, n1=%d, n2=%d'], ...
            round(tStart), round(split), round(tStop), n1, n2));
    end
else
    tStop = align_stop_to_integer_points(tStart, tStop, n);
end

seq = struct();
switch target.transition
    case {'SQ_0_TO_M1', 'SQ_0_TO_P1'}
        seq.name = 'T1_S00_S01_S10';
        seq.useSG2 = 0;
        if ctx.precal.enabled
            cfgLocal = power_boost_cfg_from_ctx(ctx);
            powSg1 = apply_p1_calibration_power_boost(ctx.power.rabi_sg1_dBm, powLabelSg1, cfgLocal);
            powSg2 = apply_p1_calibration_power_boost(ctx.power.rabi_sg2_dBm, powLabelSg2, cfgLocal);
            seq.fixPow = num2str(powSg1);
            seq.fixFreq = num2str(fSg1, '%.8f');
            seq.fixPow2 = num2str(powSg2);
            if isfinite(piSg1) && piSg1 > 0
                seq.pi = num2str(piSg1, '%.0f');
                seq.halfpi = num2str(piSg1 / 2, '%.0f');
            end
        end
    otherwise
        seq.name = 'T1_S11_S1m1';
        seq.useSG2 = 1;
        if ctx.precal.enabled
            cfgLocal = power_boost_cfg_from_ctx(ctx);
            powSg1 = apply_p1_calibration_power_boost(ctx.power.rabi_sg1_dBm, powLabelSg1, cfgLocal);
            powSg2 = apply_p1_calibration_power_boost(ctx.power.rabi_sg2_dBm, powLabelSg2, cfgLocal);
            seq.fixPow = num2str(powSg1);
            seq.fixFreq = num2str(fSg1, '%.8f');
            seq.fixPow2 = num2str(powSg2);
            seq.fixFreq2 = num2str(fSg2, '%.8f');
            if isfinite(piSg1) && piSg1 > 0
                seq.pi = num2str(piSg1, '%.0f');
                seq.halfpi = num2str(piSg1 / 2, '%.0f');
            end
            if ~isfinite(piSg2) || piSg2 <= 0
                piSg2 = 100;
            end
            seq.DEERpi = num2str(piSg2, '%.0f');
        end
end

seq.Repeat = num2str(max(1, round(target.t1.repeat)));
seq.Average = num2str(max(1, round(target.t1.average)));

if ctx.nonuniform
    seq.bSweep2 = 1;
    seq.FROM1 = num2str(tStart);
    seq.TO1 = num2str(split);
    seq.SweepNPoints = num2str(n1);
    seq.FROM2 = num2str(split);
    seq.TO2 = num2str(tStop);
    seq.SweepNPoints2 = num2str(n2);
else
    seq.bSweep2 = 0;
    seq.FROM1 = num2str(tStart);
    seq.TO1 = num2str(tStop);
    seq.SweepNPoints = num2str(n);
end
end

function [labelSg1, labelSg2] = get_t1_power_labels(target)
if isfield(target, 'group') && strcmp(target.group, 'aligned')
    base = 'aligned';
else
    base = 'off';
end

switch target.transition
    case 'SQ_0_TO_M1'
        labelSg1 = [base '_m1'];
        labelSg2 = [base '_m1'];
    case 'SQ_0_TO_P1'
        labelSg1 = [base '_p1'];
        labelSg2 = [base '_p1'];
    otherwise % DQ_M1_TO_P1
        labelSg1 = [base '_m1'];
        labelSg2 = [base '_p1'];
end
end

function cfgOut = power_boost_cfg_from_ctx(ctx)
cfgOut = struct('smart', struct('power', struct('sq_p1_calibration_boost_dB', 0)));
if isfield(ctx, 'power') && isfield(ctx.power, 'sq_p1_calibration_boost_dB') && ...
        isfinite(ctx.power.sq_p1_calibration_boost_dB)
    cfgOut.smart.power.sq_p1_calibration_boost_dB = ctx.power.sq_p1_calibration_boost_dB;
end
end

function run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, suffix)
global gSaveDataAve gmSEQ
if stop_requested(hAuto)
    return;
end

isRough = contains(lower(normalize_to_char(suffix)), '[rough t1');
isTrueT1 = isfield(seq, 'name') && ...
    (strcmp(seq.name, 'T1_S00_S01_S10') || strcmp(seq.name, 'T1_S11_S1m1'));
autoStopEnabled = false;
autoStopThr = 0.05;
autoStopMinAvg = 3;
if isfield(cfg, 'smart') && isfield(cfg.smart, 'finalT1')
    if isfield(cfg.smart.finalT1, 'autoStopByRelErr')
        autoStopEnabled = logical(cfg.smart.finalT1.autoStopByRelErr);
    end
    if isfield(cfg.smart.finalT1, 'relErrThreshold') && isfinite(cfg.smart.finalT1.relErrThreshold)
        autoStopThr = cfg.smart.finalT1.relErrThreshold;
    end
    if isfield(cfg.smart.finalT1, 'minAverageForAutoStop') && isfinite(cfg.smart.finalT1.minAverageForAutoStop)
        autoStopMinAvg = max(1, round(cfg.smart.finalT1.minAverageForAutoStop));
    end
end
gmSEQ.AutoStopT1ByRelErr = autoStopEnabled && isTrueT1 && ~isRough;
gmSEQ.AutoStopT1RelErrThreshold = autoStopThr;
gmSEQ.AutoStopT1MinAverage = autoStopMinAvg;

apply_sequence_to_main_gui(seq, hMain);
if stop_requested(hAuto)
    return;
end

auto_load_user_inputs(hObject, eventdata, hMain);
if stop_requested(hAuto)
    return;
end

t1_semi_auto_run(hObject, eventdata, hMain, hAuto);
stoppedByAutoGui = stop_requested(hAuto);

fileNamePrefix = '';
if isRough
    fileNamePrefix = 'Rough_T1_';
end

if ~isempty(gSaveDataAve) && isstruct(gSaveDataAve) && isfield(gSaveDataAve, 'file')
    if stoppedByAutoGui
        statusSuffix = ['. Sequence stopped by Auto GUI' suffix];
    else
        statusSuffix = ['. Current sequence is finished.' suffix];
    end
    save_main_figure(hMain, hAuto, gSaveDataAve.file, cfg, statusSuffix, fileNamePrefix);
end

if stoppedByAutoGui
    return;
end
end

function seq = build_preset_step(h)
seq = struct();

% Legacy zone-based preset path (if those controls exist).
hasZoneControls = isfield(h, 'zone1_radio_button') || ...
    isfield(h, 'zone2_radio_button') || ...
    isfield(h, 'zone3_radio_button');
if hasZoneControls
    if is_true_control_selected(h, 'zone1_radio_button')
        seq.readout = get_control_string(h, 'initZ1');
        seq.CtrGateDur = get_control_string(h, 'readoutZ1');
    elseif is_true_control_selected(h, 'zone2_radio_button')
        seq.readout = get_control_string(h, 'initZ2');
        seq.CtrGateDur = get_control_string(h, 'readoutZ2');
    elseif is_true_control_selected(h, 'zone3_radio_button')
        seq.readout = get_control_string(h, 'initZ3');
        seq.CtrGateDur = get_control_string(h, 'readoutZ3');
    end
    return;
end

% Zone-free GUI path: only set fields if explicitly provided.
if isfield(h, 'readout')
    seq.readout = get_control_string(h, 'readout');
elseif isfield(h, 'initReadout')
    seq.readout = get_control_string(h, 'initReadout');
end

if isfield(h, 'CtrGateDur')
    seq.CtrGateDur = get_control_string(h, 'CtrGateDur');
elseif isfield(h, 'readoutDur')
    seq.CtrGateDur = get_control_string(h, 'readoutDur');
end
end

function apply_sequence_to_main_gui(seq, handlesMain)
global gmSEQ
fields = fieldnames(seq);
for i = 1:numel(fields)
    fieldName = fields{i};
    value = seq.(fieldName);

    if strcmp(fieldName, 'name')
        handlesMain.sequence.Value = 1;
        handlesMain.sequence.String = {value};
        gmSEQ.name = {value};
        continue;
    end

    if ~isfield(handlesMain, fieldName)
        warning('SmartT1:MissingMainControl', ...
            'Main GUI control "%s" does not exist. Skipping.', fieldName);
        continue;
    end

    set_control_value(handlesMain.(fieldName), value);
end
end

function set_control_value(hCtrl, value)
if ~isgraphics(hCtrl, 'uicontrol')
    return;
end

style = get(hCtrl, 'Style');
switch style
    case {'edit', 'text'}
        set(hCtrl, 'String', normalize_to_char(value));
    case {'checkbox', 'radiobutton', 'togglebutton', 'popupmenu', 'slider'}
        set(hCtrl, 'Value', normalize_to_numeric(value, 0));
    otherwise
        if isprop(hCtrl, 'String')
            set(hCtrl, 'String', normalize_to_char(value));
        elseif isprop(hCtrl, 'Value')
            set(hCtrl, 'Value', normalize_to_numeric(value, 0));
        end
end
end

function txt = get_control_string(handlesStruct, controlName)
if ~isfield(handlesStruct, controlName)
    error('SmartT1:MissingControl', ...
        'Control "%s" not found in T1 parameter GUI handles.', controlName);
end

h = handlesStruct.(controlName);
if ~isgraphics(h, 'uicontrol')
    error('SmartT1:InvalidControl', ...
        'Control "%s" is not a valid uicontrol.', controlName);
end

if isprop(h, 'String')
    txt = normalize_to_char(get(h, 'String'));
else
    txt = num2str(get(h, 'Value'));
end
end

function tf = is_true_control_selected(handlesStruct, controlName)
tf = false;
if ~isfield(handlesStruct, controlName)
    return;
end
h = handlesStruct.(controlName);
if ~isgraphics(h, 'uicontrol')
    return;
end
if isprop(h, 'Value')
    tf = logical(get(h, 'Value'));
end
end

function save_main_figure(handlesMain, handlesAuto, runFileName, cfg, statusSuffix, fileNamePrefix)
saveFolder = cfg.paths.saveFolder;
if isfield(cfg, 'runtime') && isstruct(cfg.runtime) && ...
        isfield(cfg.runtime, 'runSaveFolder') && ~isempty(cfg.runtime.runSaveFolder)
    saveFolder = cfg.runtime.runSaveFolder;
end
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

rawName = normalize_to_char(runFileName);
if isempty(rawName)
    rawName = ['AutoRun_' datestr(now, 'yyyymmdd_HHMMSS') '.txt'];
end
if nargin >= 6
    pfx = normalize_to_char(fileNamePrefix);
else
    pfx = '';
end
if ~isempty(pfx) && ~startsWith(rawName, pfx)
    rawName = [pfx rawName];
end
% if handlesAuto.use_title.Value
%     rawName = [normalize_to_char(handlesAuto.figTitle.String) rawName];
% end
imageName = strrep(rawName, '.txt', '.png');
imagePath = fullfile(saveFolder, imageName);

mainFig = resolve_figure_handle(handlesMain, {'figure1', 'output'});
if isempty(mainFig) || ~isgraphics(mainFig, 'figure')
    warning('SmartT1:SaveMainFigureHandleMissing', 'Cannot resolve main GUI figure handle for saving.');
    return;
end
drawnow;
imwrite(getframe(mainFig).cdata, imagePath);

% Also save AutoRun v2.1 GUI snapshot alongside each sequence snapshot.
autoImagePath = strrep(imagePath, '.png', '_AutoGUI_v2_1.png');
save_auto_gui_snapshot(handlesAuto, autoImagePath);
end

function save_end_of_run_snapshots(handlesMain, handlesAuto, cfg)
saveFolder = cfg.paths.saveFolder;
if isfield(cfg, 'runtime') && isstruct(cfg.runtime) && ...
        isfield(cfg.runtime, 'runSaveFolder') && ~isempty(cfg.runtime.runSaveFolder)
    saveFolder = cfg.runtime.runSaveFolder;
end
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

try
    mainFig = resolve_figure_handle(handlesMain, {'figure1', 'output'});
    if ~isempty(mainFig) && isgraphics(mainFig, 'figure')
        drawnow;
        frameMain = getframe(mainFig);
        if isfield(frameMain, 'cdata') && ~isempty(frameMain.cdata)
            imwrite(frameMain.cdata, fullfile(saveFolder, 'MainGUI_Final.png'));
        end
    end
catch ME
    warning('SmartT1:FinalMainGuiSaveFailed', 'Final main GUI save failed: %s', ME.message);
end

try
    save_auto_gui_snapshot(handlesAuto, fullfile(saveFolder, 'AutoGUI_v2_1_Final.png'));
catch ME
    warning('SmartT1:FinalAutoGuiSaveFailed', 'Final auto GUI save failed: %s', ME.message);
end
end

function save_auto_gui_snapshot(handlesAuto, imagePath)
autoFig = resolve_figure_handle(handlesAuto, {'figure1', 'output', 'pushbutton_startProg', 'pushbutton_stopProg'});
if isempty(autoFig) || ~isgraphics(autoFig, 'figure')
    warning('SmartT1:SaveAutoGuiHandleMissing', 'Cannot resolve AutoRun v2.1 GUI figure handle for saving.');
    return;
end
drawnow;
frameAuto = getframe(autoFig);
if isfield(frameAuto, 'cdata') && ~isempty(frameAuto.cdata)
    imwrite(frameAuto.cdata, imagePath);
else
    warning('SmartT1:SaveAutoGuiFrameEmpty', 'AutoRun v2.1 GUI frame is empty; skip saving.');
end
end

function figH = resolve_figure_handle(handlesStruct, candidateFields)
figH = [];
if nargin < 1 || isempty(handlesStruct) || ~isstruct(handlesStruct)
    return;
end
if nargin < 2 || isempty(candidateFields)
    candidateFields = {'figure1', 'output'};
end

for i = 1:numel(candidateFields)
    fn = candidateFields{i};
    if ~isfield(handlesStruct, fn)
        continue;
    end
    h = handlesStruct.(fn);
    if isempty(h) || ~ishandle(h)
        continue;
    end
    if isgraphics(h, 'figure')
        figH = h;
        return;
    end
    try
        anc = ancestor(h, 'figure');
        if ~isempty(anc) && isgraphics(anc, 'figure')
            figH = anc;
            return;
        end
    catch
    end
end
end

function tag = format_b_est_tag(B_G)
if ~isfinite(B_G)
    tag = 'NAG';
    return;
end
val = num2str(B_G, '%.2f');
val = strrep(val, '-', 'm');
val = strrep(val, '.', 'p');
tag = [val 'G'];
end

function runFolder = create_run_save_folder(baseFolder, estimatedB_G)
if nargin < 1 || isempty(baseFolder)
    baseFolder = pwd;
end
if nargin < 2
    estimatedB_G = NaN;
end
if ~exist(baseFolder, 'dir')
    mkdir(baseFolder);
end

stamp = datestr(now, 'yyyymmdd_HHMMSS');
bTag = format_b_est_tag(estimatedB_G);
runFolder = fullfile(baseFolder, ['Run_' bTag '_' stamp]);
if exist(runFolder, 'dir')
    k = 1;
    while exist([runFolder '_' num2str(k)], 'dir')
        k = k + 1;
    end
    runFolder = [runFolder '_' num2str(k)];
end
mkdir(runFolder);
disp(['[SmartT1] Figure save folder for this run: ' runFolder]);
end

function [BoutG, ok, info] = estimate_aligned_b_from_outermost_measured(freqMap, measuredLabels, phys, odmrCfg)
BoutG = NaN;
ok = false;
info = struct('lowLabel', '', 'lowFreqGHz', NaN, 'highLabel', '', 'highFreqGHz', NaN);
if isempty(measuredLabels)
    return;
end

labels = {};
freqs = [];
for i = 1:numel(measuredLabels)
    lb = measuredLabels{i};
    f = get_map_freq(freqMap, lb);
    if isfinite(f)
        labels{end+1} = lb; %#ok<AGROW>
        freqs(end+1) = f; %#ok<AGROW>
    end
end
if numel(freqs) < 2
    return;
end

[lowFreq, idxLow] = min(freqs);
[highFreq, idxHigh] = max(freqs);
if ~isfinite(lowFreq) || ~isfinite(highFreq) || highFreq <= lowFreq
    return;
end

info.lowLabel = labels{idxLow};
info.highLabel = labels{idxHigh};
info.lowFreqGHz = lowFreq;
info.highFreqGHz = highFreq;

bMin = get_cfg_numeric_with_default(odmrCfg, 'bSearchMinG', 0);
bMax = get_cfg_numeric_with_default(odmrCfg, 'bSearchMaxG', 2000);
if ~isfinite(bMin)
    bMin = 0;
end
if ~isfinite(bMax) || bMax <= bMin
    bMax = max(2000, bMin + 100);
end

obj = @(B) aligned_pair_cost(B, lowFreq, highFreq, phys);
try
    BoutG = fminbnd(obj, bMin, bMax);
catch
    return;
end
if ~isfinite(BoutG)
    return;
end

[fM1, fP1] = solve_nv_resonances_full_matrix(BoutG, 1.0, phys);
residualMHz = max(abs([fM1 - lowFreq, fP1 - highFreq])) * 1000;
maxResidualMHz = get_cfg_numeric_with_default(odmrCfg, 'maxBBackoutResidualMHz', 30);
ok = residualMHz <= maxResidualMHz;
end

function v = aligned_pair_cost(BG, lowFreqGHz, highFreqGHz, phys)
[fM1, fP1] = solve_nv_resonances_full_matrix(BG, 1.0, phys);
v = (fM1 - lowFreqGHz).^2 + (fP1 - highFreqGHz).^2;
end

function msg = build_precal_summary_text(freqMap, precal, labels, measuredLabels, phys, odmrCfg)
lines = cell(1, numel(labels));
for i = 1:numel(labels)
    label = labels{i};
    if ~any(strcmp(measuredLabels, label))
        lines{i} = sprintf('%s: not measured', label);
        continue;
    end

    fGHz = get_map_freq(freqMap, label);
    pi1 = get_map_freq(precal.sg1PiNs, label);
    pi2 = get_map_freq(precal.sg2PiNs, label);
    p1 = get_map_freq(precal.sg1PowDbm, label);
    p2 = get_map_freq(precal.sg2PowDbm, label);
    if ~isfinite(fGHz)
        lines{i} = sprintf('%s: not measured', label);
    elseif ~isfinite(pi1)
        lines{i} = sprintf('%s: f=%.6f GHz, pi: not measured', label, fGHz);
    elseif isfinite(pi2) && isfinite(p1) && isfinite(p2)
        lines{i} = sprintf('%s: f=%.6f GHz, pi=%.1f ns @ %.2f dBm (SG1), %.1f ns @ %.2f dBm (SG2)', ...
            label, fGHz, pi1, p1, pi2, p2);
    elseif isfinite(pi2)
        lines{i} = sprintf('%s: f=%.6f GHz, pi=%.1f ns (SG1), %.1f ns (SG2)', label, fGHz, pi1, pi2);
    elseif isfinite(p1)
        lines{i} = sprintf('%s: f=%.6f GHz, pi=%.1f ns @ %.2f dBm', label, fGHz, pi1, p1);
    else
        lines{i} = sprintf('%s: f=%.6f GHz, pi=%.1f ns', label, fGHz, pi1);
    end
end
[BFromOuterG, bOk, outerInfo] = estimate_aligned_b_from_outermost_measured(freqMap, measuredLabels, phys, odmrCfg);
if bOk
    lines{end+1} = sprintf('B(aligned from outermost)=%.3f G (%s %.6f GHz, %s %.6f GHz)', ...
        BFromOuterG, outerInfo.lowLabel, outerInfo.lowFreqGHz, outerInfo.highLabel, outerInfo.highFreqGHz);
end
msg = strjoin(lines, sprintf('\n'));
end

function reset_v2_1_run_state(handlesAuto, cfg)
global gmSEQ

% Clear displayed status from the previous run.
update_precal_summary_display(handlesAuto, cfg, '');
if isfield(cfg.smart.ui.tags, 'display') && isfield(cfg.smart.ui.tags.display, 'roughT1')
    set_display_control_string(handlesAuto, cfg.smart.ui.tags.display.roughT1, 'Rough T1: -- ms');
end

if isfield(cfg.smart.ui.tags, 'status') && isstruct(cfg.smart.ui.tags.status)
    statusNames = fieldnames(cfg.smart.ui.tags.status);
    for i = 1:numel(statusNames)
        tag = cfg.smart.ui.tags.status.(statusNames{i});
        set_display_control_string(handlesAuto, tag, '');
    end
end

% Clear stale precal/fit cache fields from the previous run.
if isstruct(gmSEQ)
    clearFields = { ...
        'SmartFreqMapGHz', ...
        'RabiFitPi', 'RabiFitFreqMHz', ...
        'T1FitT1', 'T1FitRelErr', 'T1FitBeta', 'T1FitModelUsed' ...
    };
    for i = 1:numel(clearFields)
        f = clearFields{i};
        if isfield(gmSEQ, f)
            gmSEQ = rmfield(gmSEQ, f);
        end
    end
end

drawnow;
end

function update_precal_summary_display(handlesAuto, cfg, msg)
if ~isfield(cfg.smart.ui.tags, 'display') || ...
        ~isfield(cfg.smart.ui.tags.display, 'precalSummary')
    return;
end
tag = cfg.smart.ui.tags.display.precalSummary;
set_display_control_string(handlesAuto, tag, msg);
end

function update_rough_t1_display(handlesAuto, cfg, roughT1Ms)
if ~isfield(cfg.smart.ui.tags, 'display') || ...
        ~isfield(cfg.smart.ui.tags.display, 'roughT1')
    return;
end
msg = sprintf('Rough T1: %.4f ms', roughT1Ms);
tag = cfg.smart.ui.tags.display.roughT1;
set_display_control_string(handlesAuto, tag, msg);
end

function update_rough_ratio_display(handlesAuto, cfg, edgeRatio)
if ~isfield(cfg.smart.ui.tags, 'display') || ...
        ~isfield(cfg.smart.ui.tags.display, 'roughT1')
    return;
end
msg = sprintf('Rough ratio: %.4f', edgeRatio);
tag = cfg.smart.ui.tags.display.roughT1;
set_display_control_string(handlesAuto, tag, msg);
end

function set_display_control_string(handlesStruct, tag, msg)
if ~isfield(handlesStruct, tag)
    return;
end
h = handlesStruct.(tag);
if isgraphics(h, 'uicontrol') && isprop(h, 'String')
    if contains(msg, sprintf('\n'))
        h.String = regexp(msg, '\r\n|\n', 'split');
    else
        h.String = msg;
    end
end
end

function update_target_status_display(handlesAuto, cfg, targetId, msg)
if ~isfield(cfg.smart.ui.tags.status, targetId)
    return;
end
tag = cfg.smart.ui.tags.status.(targetId);
if ~isfield(handlesAuto, tag)
    return;
end
h = handlesAuto.(tag);
if isgraphics(h, 'uicontrol') && isprop(h, 'String')
    h.String = msg;
end
end

function out = read_ui_numeric(handlesStruct, controlName, defaultValue)
if nargin < 3
    defaultValue = NaN;
end

if ~isfield(handlesStruct, controlName)
    out = defaultValue;
    return;
end

h = handlesStruct.(controlName);
if ~isgraphics(h, 'uicontrol')
    out = defaultValue;
    return;
end

style = '';
if isprop(h, 'Style')
    style = get(h, 'Style');
end
if any(strcmp(style, {'checkbox', 'radiobutton', 'togglebutton', 'slider'}))
    raw = get(h, 'Value');
elseif isprop(h, 'String')
    raw = get(h, 'String');
else
    raw = get(h, 'Value');
end

tmp = str2double(normalize_to_char(raw));
if isnan(tmp)
    out = defaultValue;
else
    out = tmp;
end
end

function out = read_ui_string(handlesStruct, controlName, defaultValue)
if nargin < 3
    defaultValue = '';
end
if ~isfield(handlesStruct, controlName)
    out = defaultValue;
    return;
end
h = handlesStruct.(controlName);
if ~isgraphics(h, 'uicontrol')
    out = defaultValue;
    return;
end
style = '';
if isprop(h, 'Style')
    style = get(h, 'Style');
end

if strcmp(style, 'popupmenu') && isprop(h, 'String') && isprop(h, 'Value')
    items = get(h, 'String');
    idx = get(h, 'Value');
    if iscell(items) && idx >= 1 && idx <= numel(items)
        out = normalize_to_char(items{idx});
    else
        out = normalize_to_char(items);
    end
elseif isprop(h, 'String')
    out = normalize_to_char(get(h, 'String'));
else
    out = normalize_to_char(get(h, 'Value'));
end
if isempty(out)
    out = defaultValue;
end
end

function out = safe_gm_field(s, fieldName, defaultValue)
if isfield(s, fieldName) && ~isempty(s.(fieldName)) && isfinite(s.(fieldName))
    out = s.(fieldName);
else
    out = defaultValue;
end
end

function out = canonical_stop_policy(in)
s = lower(strtrim(normalize_to_char(in)));
if contains(s, 'max')
    out = 'max_retries';
else
    out = 'first_good';
end
end

function out = canonical_rough_stop_estimator(in)
s = lower(strtrim(normalize_to_char(in)));
switch s
    case {'single_exp', 'single', 'single_exponential'}
        out = 'single_exp';
    case {'stretched_div_n', 'stretched', 'stretched_exp_div_n', 'stretched_exponential_div_n'}
        out = 'stretched_div_n';
    case {'edge_ratio', 'ratio', 'first_last_ratio'}
        out = 'edge_ratio';
    otherwise
        out = 'single_exp';
end
end

function out = get_map_freq(s, fieldName)
if isfield(s, fieldName)
    out = s.(fieldName);
else
    out = NaN;
end
end

function out = normalize_to_char(in)
if iscell(in)
    if isempty(in)
        out = '';
    else
        out = normalize_to_char(in{1});
    end
elseif isstring(in)
    out = char(in);
elseif isnumeric(in)
    out = num2str(in);
elseif ischar(in)
    out = in;
else
    out = char(string(in));
end
end

function out = normalize_to_numeric(in, defaultValue)
if isnumeric(in)
    out = in;
    return;
end
tmp = str2double(normalize_to_char(in));
if isnan(tmp)
    out = defaultValue;
else
    out = tmp;
end
end

function stopOut = align_stop_to_integer_points(startIn, stopIn, nPts)
% Preserve start and choose stop so linear sweep points lie on integer grid
% when start is integer.
if nPts < 2
    stopOut = round(stopIn);
    return;
end

span = max(stopIn - startIn, 1e-6);
if abs(startIn - round(startIn)) < 1e-9
    % Use ceil so integer-grid quantization never shrinks the requested stop.
    step = max(1, ceil(span / (nPts - 1)));
    stopOut = startIn + step * (nPts - 1);
else
    % If start is non-integer, full integer-grid guarantee is impossible
    % without changing start (disallowed), so keep start fixed and round stop.
    stopOut = round(stopIn);
end
end

function [splitOut, stopOut] = align_nonuniform_grid(startIn, splitIn, stopIn, n1, n2)
% Enforce integer-grid points for both segments in smart distribution mode.
splitOut = splitIn;
stopOut = stopIn;

if n1 >= 2
    splitOut = align_stop_to_integer_points(startIn, splitIn, n1);
else
    splitOut = round(splitIn);
end

if n2 >= 2
    stopOut = align_stop_to_integer_points(splitOut, stopIn, n2);
else
    stopOut = splitOut;
end
end

function spanOut = round_span_to_1000(spanIn)
% Round span to nearest 1000 in current time unit.
spanOut = round(spanIn / 1000) * 1000;
if ~isfinite(spanOut) || spanOut <= 0
    spanOut = 1000;
end
end

function [splitOut, stopOut, ok] = solve_nonuniform_span_grid(startIn, spanTarget, n1, n2, splitPref)
% Solve two-segment integer-grid constraints with exact total span.
% Ensures:
%   split = start + a*(n1-1), a integer >=1 (for n1>=2)
%   stop  = split + b*(n2-1), b integer >=1 (for n2>=2)
%   stop-start = spanTarget (exact, e.g. multiple of 1000)
splitOut = splitPref;
stopOut = startIn + spanTarget;
ok = false;

if ~isfinite(spanTarget) || spanTarget <= 0
    return;
end
if n1 < 2 || n2 < 2
    return;
end

m1 = n1 - 1;
m2 = n2 - 1;
S = round(spanTarget);

% Need exact integer solution to m1*a + m2*b = S, with a,b >= 1.
d = gcd(m1, m2);
if mod(S, d) ~= 0
    return;
end

m1r = m1 / d;
m2r = m2 / d;
Sr = S / d;

[g, invM1, ~] = gcd(m1r, m2r);
if g ~= 1
    return;
end

% One congruence class: a = aBase + k*m2r
aBase = mod(invM1 * mod(Sr, m2r), m2r);
if aBase == 0
    aBase = m2r;
end

aMin = 1;
aMax = floor((S - m2) / m1);
if aMax < aMin
    return;
end

kMin = ceil((aMin - aBase) / m2r);
kMax = floor((aMax - aBase) / m2r);
if kMin > kMax
    return;
end

% Prefer split near 1/4 of range by default.
if isfinite(splitPref)
    aPref = round((splitPref - startIn) / m1);
else
    aPref = round((S / 4) / m1);
end
kStar = round((aPref - aBase) / m2r);
kStar = min(max(kStar, kMin), kMax);

a = aBase + kStar * m2r;
b = (S - m1 * a) / m2;
if a < 1 || b < 1 || abs(b - round(b)) > 1e-9
    return;
end
b = round(b);

splitOut = startIn + m1 * a;
stopOut = splitOut + m2 * b;
ok = (stopOut - startIn) == S;
end

function [splitOut, stopOut, changed] = force_integer_grid_nonuniform(startIn, splitIn, stopIn, n1, n2)
% Final guard: if start is integer, force integer-grid points for both
% nonuniform segments by nudging split/stop via integer steps.
splitOut = splitIn;
stopOut = stopIn;
changed = false;

if abs(startIn - round(startIn)) > 1e-9
    % With non-integer start, exact integer points are impossible without
    % changing start (disallowed by policy).
    return;
end

if n1 >= 2
    m1 = n1 - 1;
    step1 = round((splitOut - startIn) / m1);
    step1 = max(1, step1);
    splitOut = startIn + m1 * step1;
else
    splitOut = round(splitOut);
end

if n2 >= 2
    m2 = n2 - 1;
    step2 = round((stopOut - splitOut) / m2);
    step2 = max(1, step2);
    stopOut = splitOut + m2 * step2;
else
    stopOut = splitOut;
end

changed = (abs(splitOut - splitIn) > 1e-9) || (abs(stopOut - stopIn) > 1e-9);
end

function tf = stop_requested(handlesAuto)
tf = false;
if nargin < 1 || isempty(handlesAuto) || ~isstruct(handlesAuto)
    return;
end
if ~isfield(handlesAuto, 'pushbutton_stopProg')
    return;
end
h = handlesAuto.pushbutton_stopProg;
if ~(ishandle(h) || isgraphics(h))
    return;
end

try
    ud = get(h, 'UserData');
    if isempty(ud)
        tf = false;
    else
        tf = logical(ud);
    end
catch
    tf = false;
end
end
