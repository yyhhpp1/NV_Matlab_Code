function smart_relaxation_program_v2_2(hObject, eventdata, handlesMain, handlesAuto)
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
init_analysis_export_state();
ctx = build_execution_context(cfg, handlesAuto);
ctx = apply_high_field_offaligned_policy(ctx, cfg);
ctx = apply_zero_field_single_target_policy(ctx, cfg);
ctx = apply_mw_delivery_range_policy(ctx, cfg);
ctx = apply_sij_all_override_policy(ctx);
if stop_requested(handlesAuto)
    return;
end
tSetK = read_current_t_setpoint_from_v3_context();
saveOverride = read_run_save_folder_override();
if ~isempty(saveOverride)
    cfg.runtime.runSaveFolder = saveOverride;
    if ~isfolder(cfg.runtime.runSaveFolder)
        mkdir(cfg.runtime.runSaveFolder);
    end
else
    cfg.runtime.runSaveFolder = create_run_save_folder(cfg.paths.saveFolder, ctx.estimatedB_G, tSetK);
end
init_report_export_state(cfg);
append_run_decision_event('run_save_folder', sprintf('Using run save folder: %s', cfg.runtime.runSaveFolder));
if isfield(ctx, 'mwDeliverySkipped') && ~isempty(ctx.mwDeliverySkipped)
    append_run_decision_event('mw_delivery_range', sprintf('Skipped targets: %s', strjoin(ctx.mwDeliverySkipped, '; ')));
end
if is_sij_all_enabled(ctx)
    append_run_decision_event('sij_all_override', sprintf('Running T1_Sij_all groups: %s', summarize_target_ids(ctx.targets)));
end
cleanupSave = onCleanup(@() save_end_of_run_snapshots(handlesMain, handlesAuto, cfg)); %#ok<NASGU>

if isempty(ctx.targets)
    error('SmartT1:NoTargetSelected', ...
        'No measurement target is selected. Enable at least one target checkbox.');
end
if isempty(active_measurement_families(ctx))
    error('SmartT1:NoMeasurementFamilySelected', ...
        'Enable at least one measurement family (T1, T2, or T2*).');
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
currentEstimatedB_G = ctx.estimatedB_G;
allLabels = {'aligned_m1', 'aligned_p1', 'off_m1', 'off_p1'};
requiredLabels = collect_required_resonance_labels(ctx.targets);
odmrLabels = requiredLabels;
if isfield(ctx, 'precal') && isfield(ctx.precal, 'forceMeasureAllFreqs') && ctx.precal.forceMeasureAllFreqs
    odmrLabels = allLabels;
end
if should_disable_offaligned_measurement(ctx, cfg)
    odmrLabels = filter_aligned_labels(odmrLabels);
end

freqMap = struct();
rabiCache = struct();
precal = struct('sg1PiNs', struct(), 'sg1PiHalfNs', struct(), 'sg1ThreeHalfPiNs', struct(), ...
    'sg1FreqMHz', struct(), 'sg2PiNs', struct(), 'sg2PiHalfNs', struct(), ...
    'sg2ThreeHalfPiNs', struct(), 'sg2FreqMHz', struct(), ...
    'sg1PowDbm', struct(), 'sg2PowDbm', struct());

if ctx.precal.enabled
    disp(['[SmartT1] Precal ODMR labels: ' strjoin(odmrLabels, ', ')]);
    pendingLabels = odmrLabels;
    iW = 0;
    refinedBUsed = false;
    while ~isempty(pendingLabels)
        odmrCfgRuntime = cfg.smart.odmr;
        odmrCfgRuntime.currentEstimatedB_G = currentEstimatedB_G;
        windows = plan_odmr_windows(pendingLabels, predicted, odmrCfgRuntime);
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
                currentEstimatedB_G = BRefinedG;
                disp(sprintf('[SmartT1] Refined B from first ODMR: %.3f G -> %.3f G (labels: %s)', ...
                    ctx.estimatedB_G, BRefinedG, strjoin(usedLabels, ', ')));
                append_run_decision_event('odmr_b_refine', sprintf('Refined B from %.3f G to %.3f G using labels: %s', ...
                    ctx.estimatedB_G, BRefinedG, strjoin(usedLabels, ', ')));
            else
                disp('[SmartT1] Skipped B refinement from first ODMR (fit quality/consistency not sufficient).');
                append_run_decision_event('odmr_b_refine', 'Skipped B refinement from first ODMR.');
            end
            refinedBUsed = true;
        end

        pendingLabels = setdiff(pendingLabels, w.labels, 'stable');
    end

    freqMap = fill_missing_freqs(freqMap, allLabels, predicted);
    gmSEQ.SmartFreqMapGHz = freqMap;
    [bMeasured, bOk] = estimate_aligned_b_from_outermost_measured(freqMap, odmrLabels, cfg.smart.physics, cfg.smart.odmr);
    if bOk
        set_analysis_measured_b(bMeasured);
    end

    for iL = 1:numel(requiredLabels)
        label = requiredLabels{iL};
        fGHz = get_map_freq(freqMap, label);
        [rabiCache, piNs, piHalfNs, threeHalfPiNs, fRMHz, pDbm] = calibrate_rabi_path( ...
            'sg1', label, fGHz, ctx, handlesMain, handlesAuto, hObject, eventdata, cfg, rabiCache);
        precal.sg1PiNs.(label) = piNs;
        precal.sg1PiHalfNs.(label) = piHalfNs;
        precal.sg1ThreeHalfPiNs.(label) = threeHalfPiNs;
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
        [rabiCache, piNs, piHalfNs, threeHalfPiNs, fRMHz, pDbm] = calibrate_rabi_path( ...
            'sg2', label, fGHz, ctx, handlesMain, handlesAuto, hObject, eventdata, cfg, rabiCache);
        precal.sg2PiNs.(label) = piNs;
        precal.sg2PiHalfNs.(label) = piHalfNs;
        precal.sg2ThreeHalfPiNs.(label) = threeHalfPiNs;
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
        piHalfSg1 = NaN;
        threeHalfPiSg1 = NaN;
        piHalfSg2 = NaN;
        threeHalfPiSg2 = NaN;
        switch target.transition
            case 'SQ_0_TO_M1'
                piSg1 = get_map_freq(precal.sg1PiNs, labelM1);
                piHalfSg1 = get_map_freq(precal.sg1PiHalfNs, labelM1);
                threeHalfPiSg1 = get_map_freq(precal.sg1ThreeHalfPiNs, labelM1);
                freqSg1MHz = get_map_freq(precal.sg1FreqMHz, labelM1);
                piSg2 = piSg1;
                piHalfSg2 = piHalfSg1;
                threeHalfPiSg2 = threeHalfPiSg1;
                freqSg2MHz = freqSg1MHz;
            case 'SQ_0_TO_P1'
                piSg1 = get_map_freq(precal.sg1PiNs, labelP1);
                piHalfSg1 = get_map_freq(precal.sg1PiHalfNs, labelP1);
                threeHalfPiSg1 = get_map_freq(precal.sg1ThreeHalfPiNs, labelP1);
                freqSg1MHz = get_map_freq(precal.sg1FreqMHz, labelP1);
                piSg2 = piSg1;
                piHalfSg2 = piHalfSg1;
                threeHalfPiSg2 = threeHalfPiSg1;
                freqSg2MHz = freqSg1MHz;
            otherwise % DQ_M1_TO_P1
                piSg1 = get_map_freq(precal.sg1PiNs, labelM1);
                piHalfSg1 = get_map_freq(precal.sg1PiHalfNs, labelM1);
                threeHalfPiSg1 = get_map_freq(precal.sg1ThreeHalfPiNs, labelM1);
                freqSg1MHz = get_map_freq(precal.sg1FreqMHz, labelM1);
                piSg2 = get_map_freq(precal.sg2PiNs, labelP1);
                piHalfSg2 = get_map_freq(precal.sg2PiHalfNs, labelP1);
                threeHalfPiSg2 = get_map_freq(precal.sg2ThreeHalfPiNs, labelP1);
                freqSg2MHz = get_map_freq(precal.sg2FreqMHz, labelP1);
                if ~isfinite(piSg2)
                    piSg2 = get_map_freq(precal.sg1PiNs, labelP1);
                end
                if ~isfinite(piHalfSg2)
                    piHalfSg2 = get_map_freq(precal.sg1PiHalfNs, labelP1);
                end
                if ~isfinite(threeHalfPiSg2)
                    threeHalfPiSg2 = get_map_freq(precal.sg1ThreeHalfPiNs, labelP1);
                end
                if ~isfinite(freqSg2MHz)
                    freqSg2MHz = get_map_freq(precal.sg1FreqMHz, labelP1);
                end
        end
        target.fitPulseTimes = struct( ...
            'piHalfSg1Ns', piHalfSg1, ...
            'threeHalfPiSg1Ns', threeHalfPiSg1, ...
            'piHalfSg2Ns', piHalfSg2, ...
            'threeHalfPiSg2Ns', threeHalfPiSg2);
    else
        [fSg1, fSg2, labelM1, labelP1] = resolve_target_freqs(target, freqMap);
        piSg1 = NaN;
        piSg2 = NaN;
        freqSg1MHz = NaN;
        freqSg2MHz = NaN;
        target.fitPulseTimes = struct( ...
            'piHalfSg1Ns', NaN, ...
            'threeHalfPiSg1Ns', NaN, ...
            'piHalfSg2Ns', NaN, ...
            'threeHalfPiSg2Ns', NaN);
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

    if is_sij_all_target(target, ctxTarget)
        [finalRange, roughInfo] = determine_sij_all_final_range( ...
            target, fSg1, fSg2, piSg1, piSg2, ctxTarget, handlesMain, handlesAuto, hObject, eventdata, cfg);
        if stop_requested(handlesAuto)
            break;
        end
        append_run_decision_event('final_range', summarize_sij_all_range_decision(target.id, finalRange, roughInfo));
        finalSeq = build_sij_all_sequence(target, finalRange, fSg1, fSg2, piSg1, piSg2, ctxTarget, roughInfo);
        finalSeq = apply_late_time_points_to_sequence(finalSeq, finalRange, roughInfo, ctxTarget);
        run_one_sequence(finalSeq, handlesMain, handlesAuto, hObject, eventdata, cfg, ...
            sprintf(' [T1 Sij-all %s]', target.id));
        if stop_requested(handlesAuto)
            break;
        end
        append_analysis_entry_for_sij_all(target);

        if ctxTarget.precal.enabled
            fDispM1 = get_map_freq(freqMap, labelM1);
            fDispP1 = get_map_freq(freqMap, labelP1);
        else
            fDispM1 = fSg1;
            fDispP1 = fSg2;
        end
        statusText = sprintf(['T1 Sij-all %s: f_m1=%.6fGHz f_p1=%.6fGHz | ', ...
            'SG1 pi=%.1fns P=%.2fdBm | SG2 pi=%.1fns P=%.2fdBm | %s'], ...
            target.id, fDispM1, fDispP1, piSg1, ctxTarget.power.rabi_sg1_dBm, ...
            piSg2, ctxTarget.power.rabi_sg2_dBm, summarize_sij_all_rough_tail(roughInfo));
        disp(['[SmartT1] ' statusText]);
        update_target_status_display(handlesAuto, cfg, target.id, statusText);
        continue;
    end

    enabledFamilies = active_measurement_families(ctxTarget);
    for iFam = 1:numel(enabledFamilies)
        family = enabledFamilies{iFam};
        familyCfg = ctxTarget.measurements.(family);
        if ~target_supported_by_family(target, familyCfg)
            continue;
        end
        [finalRange, roughInfo] = determine_family_final_range( ...
            family, target, fSg1, fSg2, piSg1, piSg2, ctxTarget, handlesMain, handlesAuto, hObject, eventdata, cfg);
        if stop_requested(handlesAuto)
            break;
        end
        append_run_decision_event('final_range', summarize_final_range_decision(familyCfg.displayName, target.id, finalRange, roughInfo));
        finalSeq = build_family_sequence(family, target, finalRange, fSg1, fSg2, piSg1, piSg2, ctxTarget);
        finalSeq = apply_late_time_points_to_sequence(finalSeq, finalRange, roughInfo, ctxTarget);
        run_one_sequence(finalSeq, handlesMain, handlesAuto, hObject, eventdata, cfg, ...
            sprintf(' [%s %s]', familyCfg.displayName, target.id));
        if stop_requested(handlesAuto)
            break;
        end
        append_analysis_entry_for_target(target, family);

        if ctxTarget.precal.enabled
            fDispM1 = get_map_freq(freqMap, labelM1);
            fDispP1 = get_map_freq(freqMap, labelP1);
        else
            fDispM1 = fSg1;
            fDispP1 = fSg2;
        end

        if isfinite(roughInfo.t1RoughMs)
            roughTail = sprintf('rough%s=%.3fms', familyCfg.displayName, roughInfo.t1RoughMs);
        elseif isfield(roughInfo, 'edgeRatio') && isfinite(roughInfo.edgeRatio)
            roughTail = sprintf('roughRatio=%.4f', roughInfo.edgeRatio);
        else
            roughTail = 'rough=NA';
        end
        statusText = sprintf(['%s %s: f_m1=%.6fGHz f_p1=%.6fGHz | ', ...
            'SG1 pi=%.1fns fR=%.2fMHz P=%.2fdBm | SG2 pi=%.1fns fR=%.2fMHz P=%.2fdBm | %s'], ...
            familyCfg.displayName, target.id, fDispM1, fDispP1, ...
            piSg1, freqSg1MHz, ctxTarget.power.rabi_sg1_dBm, ...
            piSg2, freqSg2MHz, ctxTarget.power.rabi_sg2_dBm, roughTail);
        disp(['[SmartT1] ' statusText]);
        update_target_status_display(handlesAuto, cfg, target.id, statusText);
    end
end
end

function ctx = build_execution_context(cfg, hAuto)
ctx = struct();
ctx.measurements = cfg.smart.measurements;
if isfield(cfg.smart, 'sijAll') && isstruct(cfg.smart.sijAll)
    ctx.sijAll = cfg.smart.sijAll;
else
    ctx.sijAll = struct('enabled', false, 'sequenceName', 'T1_Sij_all');
end
if isfield(cfg.smart.ui.tags, 'measure') && isfield(cfg.smart.ui.tags.measure, 't1SijAll')
    ctx.sijAll.enabled = logical(read_ui_numeric(hAuto, cfg.smart.ui.tags.measure.t1SijAll, ctx.sijAll.enabled));
end
ctx.estimatedB_G = read_ui_numeric(hAuto, cfg.smart.ui.tags.input.estimatedB, ...
    read_ui_numeric(hAuto, 'setB', cfg.smart.defaultEstimatedB_G));
ctx.nonuniform = logical(read_ui_numeric(hAuto, cfg.smart.ui.tags.input.nonuniform, 0));
ctx.addLateTimePoints = logical(read_ui_numeric(hAuto, cfg.smart.ui.tags.input.addLateTimePoints, 0));

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
    targets(i).t2 = resolve_target_family_params(targets(i).t2, cfg.smart.ui.tags.t2.(targets(i).id), hAuto);
    targets(i).t2star = resolve_target_family_params(targets(i).t2star, cfg.smart.ui.tags.t2star.(targets(i).id), hAuto);
end
if isfield(cfg.smart.ui.tags, 'measure')
    families = fieldnames(ctx.measurements);
    for i = 1:numel(families)
        fam = families{i};
        if isfield(cfg.smart.ui.tags.measure, fam)
            ctx.measurements.(fam).enabled = logical(read_ui_numeric(hAuto, ...
                cfg.smart.ui.tags.measure.(fam), ctx.measurements.(fam).enabled));
        end
    end
end
if is_sij_all_enabled(ctx)
    ctx.measurements.t1.enabled = true;
    if isfield(ctx.measurements, 't2')
        ctx.measurements.t2.enabled = false;
    end
    if isfield(ctx.measurements, 't2star')
        ctx.measurements.t2star.enabled = false;
    end
end
ctx.allTargets = targets;
ctx.targets = filter_targets_for_enabled_measurements(targets, ctx.measurements);
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

function p = resolve_target_family_params(p, tags, hAuto)
p.start = read_ui_numeric(hAuto, tags.start, p.start);
p.stop = read_ui_numeric(hAuto, tags.stop, p.stop);
p.nPoints = round(read_ui_numeric(hAuto, tags.nPoints, p.nPoints));
p.repeat = round(read_ui_numeric(hAuto, tags.repeat, p.repeat));
p.average = round(read_ui_numeric(hAuto, tags.average, p.average));
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
    fFitGHz = scalar_numeric_or_nan(get_map_freq(fitMap, label));
    fEstGHz = scalar_numeric_or_nan(get_map_freq(predicted, label));
    if ~(isfinite(fFitGHz) && isfinite(fEstGHz))
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

function ctxOut = apply_high_field_offaligned_policy(ctxIn, cfg)
ctxOut = ctxIn;
if ~should_disable_offaligned_measurement(ctxIn, cfg)
    return;
end
if ~isfield(ctxIn, 'targets') || isempty(ctxIn.targets)
    return;
end

keep = true(1, numel(ctxIn.targets));
removed = {};
for i = 1:numel(ctxIn.targets)
    g = lower(normalize_to_char(safe_struct_field(ctxIn.targets(i), 'group', '')));
    if contains(g, 'off')
        keep(i) = false;
        removed{end+1} = normalize_to_char(safe_struct_field(ctxIn.targets(i), 'id', sprintf('target_%d', i))); %#ok<AGROW>
    end
end

if any(~keep)
    ctxOut.targets = ctxIn.targets(keep);
    cutoff = get_cfg_numeric_with_default(cfg.smart.odmr, 'disableOffAlignedAboveG', 600);
    disp(sprintf('[SmartT1] High-field policy active (|B|>%.1f G): skipping off-aligned targets: %s', ...
        cutoff, strjoin(removed, ', ')));
end
end

function tf = should_disable_offaligned_measurement(ctx, cfg)
tf = false;
if ~isstruct(cfg) || ~isfield(cfg, 'smart') || ~isfield(cfg.smart, 'odmr')
    return;
end
cutoff = get_cfg_numeric_with_default(cfg.smart.odmr, 'disableOffAlignedAboveG', 600);
if ~isfinite(cutoff) || cutoff <= 0
    return;
end
if ~isstruct(ctx) || ~isfield(ctx, 'estimatedB_G') || ~isfinite(ctx.estimatedB_G)
    return;
end
tf = abs(ctx.estimatedB_G) > cutoff;
end

function labelsOut = filter_aligned_labels(labelsIn)
labelsOut = {};
if isempty(labelsIn)
    return;
end
for i = 1:numel(labelsIn)
    lb = normalize_to_char(labelsIn{i});
    if startsWith(lower(lb), 'aligned_')
        labelsOut{end+1} = lb; %#ok<AGROW>
    end
end
labelsOut = unique(labelsOut, 'stable');
end

function ctxOut = apply_zero_field_single_target_policy(ctxIn, cfg)
ctxOut = ctxIn;
if ~is_zero_field_estimate(ctxIn)
    return;
end

target = struct([]);
if isfield(ctxIn, 'allTargets') && ~isempty(ctxIn.allTargets)
    target = find_target_by_id(ctxIn.allTargets, 'aligned_sq_m1');
end
if isempty(target) && isfield(ctxIn, 'targets') && ~isempty(ctxIn.targets)
    target = find_target_by_id(ctxIn.targets, 'aligned_sq_m1');
end
if isempty(target)
    warning('SmartT1:ZeroFieldPolicyMissingTarget', ...
        'B_est=0 policy requested, but aligned_sq_m1 target is unavailable.');
    return;
end

ctxOut.targets = target;
if isfield(ctxOut, 'precal') && isstruct(ctxOut.precal) && ...
        isfield(ctxOut.precal, 'forceMeasureAllFreqs') && logical(ctxOut.precal.forceMeasureAllFreqs)
    ctxOut.precal.forceMeasureAllFreqs = false;
end

disp('[SmartT1] Zero-field policy active (B_est=0): forcing only aligned SQ(0,-1).');
end

function tf = is_zero_field_estimate(ctx)
tf = false;
if ~isstruct(ctx) || ~isfield(ctx, 'estimatedB_G')
    return;
end
B = scalar_numeric_or_nan(ctx.estimatedB_G);
if ~isfinite(B)
    return;
end
tf = abs(B) <= 1e-9;
end

function target = find_target_by_id(targets, id)
target = struct([]);
if isempty(targets)
    return;
end
for i = 1:numel(targets)
    if strcmp(normalize_to_char(targets(i).id), id)
        target = targets(i);
        return;
    end
end
end

function ctxOut = apply_mw_delivery_range_policy(ctxIn, cfg)
ctxOut = ctxIn;
if ~isfield(ctxIn, 'targets') || isempty(ctxIn.targets)
    return;
end
if ~isfield(cfg.smart, 'mwDelivery') || ~isstruct(cfg.smart.mwDelivery)
    return;
end

minGHz = get_cfg_numeric_with_default(cfg.smart.mwDelivery, 'minGHz', 0.7);
maxGHz = get_cfg_numeric_with_default(cfg.smart.mwDelivery, 'maxGHz', 6.0);
if ~(isfinite(minGHz) && isfinite(maxGHz) && maxGHz > minGHz)
    return;
end

predicted = estimate_resonance_centers(ctxIn.estimatedB_G, cfg.smart.physics);
keep = true(1, numel(ctxIn.targets));
removed = {};
for i = 1:numel(ctxIn.targets)
    target = ctxIn.targets(i);
    [ok, reason] = target_within_mw_delivery_range(target, predicted, minGHz, maxGHz);
    if ~ok
        keep(i) = false;
        removed{end + 1} = sprintf('%s (%s)', ...
            normalize_to_char(safe_struct_field(target, 'id', sprintf('target_%d', i))), reason); %#ok<AGROW>
    end
end

if any(~keep)
    ctxOut.targets = ctxIn.targets(keep);
    msg = sprintf('MW delivery range policy [%.3g, %.3g] GHz skipped: %s', ...
        minGHz, maxGHz, strjoin(removed, '; '));
    disp(['[SmartT1] ' msg]);
    ctxOut.mwDeliverySkipped = removed;
end
end

function [ok, reason] = target_within_mw_delivery_range(target, predicted, minGHz, maxGHz)
ok = true;
reason = '';
[~, ~, labelM1, labelP1] = resolve_target_freqs(target, predicted);
fM1 = get_map_freq(predicted, labelM1);
fP1 = get_map_freq(predicted, labelP1);

switch normalize_to_char(safe_struct_field(target, 'transition', ''))
    case 'SQ_0_TO_M1'
        ok = freq_in_delivery_range(fM1, minGHz, maxGHz);
        if ~ok
            reason = sprintf('0->-1 %.6g GHz outside range', fM1);
        end
    case 'SQ_0_TO_P1'
        ok = freq_in_delivery_range(fP1, minGHz, maxGHz);
        if ~ok
            reason = sprintf('0->+1 %.6g GHz outside range', fP1);
        end
    case 'DQ_M1_TO_P1'
        okM1 = freq_in_delivery_range(fM1, minGHz, maxGHz);
        okP1 = freq_in_delivery_range(fP1, minGHz, maxGHz);
        ok = okM1 && okP1;
        if ~ok
            parts = {};
            if ~okM1
                parts{end + 1} = sprintf('0->-1 %.6g GHz outside range', fM1); %#ok<AGROW>
            end
            if ~okP1
                parts{end + 1} = sprintf('0->+1 %.6g GHz outside range', fP1); %#ok<AGROW>
            end
            reason = strjoin(parts, ', ');
        end
end
end

function ok = freq_in_delivery_range(freqGHz, minGHz, maxGHz)
ok = isfinite(freqGHz) && freqGHz >= minGHz && freqGHz <= maxGHz;
end

function ctxOut = apply_sij_all_override_policy(ctxIn)
ctxOut = ctxIn;
if ~is_sij_all_enabled(ctxIn)
    return;
end

ctxOut.measurements.t1.enabled = true;
if isfield(ctxOut.measurements, 't2')
    ctxOut.measurements.t2.enabled = false;
end
if isfield(ctxOut.measurements, 't2star')
    ctxOut.measurements.t2star.enabled = false;
end
srcTargets = struct([]);
if isfield(ctxIn, 'targets') && ~isempty(ctxIn.targets)
    srcTargets = ctxIn.targets;
end
if isempty(srcTargets)
    ctxOut.targets = srcTargets;
    return;
end
srcTargets = ensure_target_field(srcTargets, 'isSijAll', false);

groups = {'aligned', 'off_aligned'};
targetsOut = struct([]);
for i = 1:numel(groups)
    groupName = groups{i};
    groupTargets = filter_targets_by_group(srcTargets, groupName);
    if isempty(groupTargets)
        continue;
    end
    if group_supports_sij_all(groupTargets)
        baseTarget = choose_sij_all_base_target(groupTargets);
        sijTarget = baseTarget;
        if strcmp(groupName, 'aligned')
            sijTarget.id = 'aligned_sij_all';
        else
            sijTarget.id = 'off_sij_all';
        end
        sijTarget.group = groupName;
        sijTarget.transition = 'DQ_M1_TO_P1';
        sijTarget.enabled = true;
        sijTarget.isSijAll = true;
        targetsOut = append_target_compatible(targetsOut, sijTarget);
    else
        for j = 1:numel(groupTargets)
            targetsOut = append_target_compatible(targetsOut, groupTargets(j));
        end
    end
end

ctxOut.targets = targetsOut;
if isfield(ctxOut, 'precal') && isstruct(ctxOut.precal)
    ctxOut.precal.enabled = true;
    ctxOut.precal.forceMeasureAllFreqs = true;
end

if ~isempty(targetsOut)
    labels = cell(1, numel(targetsOut));
    for i = 1:numel(targetsOut)
        labels{i} = targetsOut(i).id;
    end
    disp(sprintf('[SmartT1] T1 Sij-all override active: running %s only.', strjoin(labels, ', ')));
    append_run_decision_event('sij_all_override', sprintf('Running T1_Sij_all groups: %s', strjoin(labels, ', ')));
end
end

function tf = is_sij_all_enabled(ctx)
tf = isstruct(ctx) && isfield(ctx, 'sijAll') && isstruct(ctx.sijAll) && ...
    isfield(ctx.sijAll, 'enabled') && logical(ctx.sijAll.enabled);
end

function targets = ensure_target_field(targets, fieldName, value)
if isempty(targets) || isfield(targets, fieldName)
    return;
end
for i = 1:numel(targets)
    targets(i).(fieldName) = value;
end
end

function out = append_target_compatible(out, target)
if isempty(out)
    out = target;
    return;
end
outFields = fieldnames(out);
targetFields = fieldnames(target);
missingInTarget = setdiff(outFields, targetFields);
for i = 1:numel(missingInTarget)
    target.(missingInTarget{i}) = [];
end
missingInOut = setdiff(targetFields, outFields);
for i = 1:numel(missingInOut)
    [out.(missingInOut{i})] = deal([]);
end
out(end + 1, 1) = target;
end

function out = filter_targets_by_group(targets, groupName)
out = targets([]);
for i = 1:numel(targets)
    if strcmp(normalize_group_name(safe_struct_field(targets(i), 'group', '')), normalize_group_name(groupName))
        out(end + 1) = targets(i); %#ok<AGROW>
    end
end
end

function target = choose_sij_all_base_target(groupTargets)
target = groupTargets(1);
preferredTransitions = {'SQ_0_TO_M1', 'DQ_M1_TO_P1', 'SQ_0_TO_P1'};
for i = 1:numel(preferredTransitions)
    for j = 1:numel(groupTargets)
        if strcmp(normalize_to_char(groupTargets(j).transition), preferredTransitions{i})
            target = groupTargets(j);
            return;
        end
    end
end
end

function tf = group_supports_sij_all(groupTargets)
tf = false;
hasM1 = false;
hasP1 = false;
for i = 1:numel(groupTargets)
    tr = normalize_to_char(safe_struct_field(groupTargets(i), 'transition', ''));
    if strcmp(tr, 'DQ_M1_TO_P1')
        tf = true;
        return;
    end
    if strcmp(tr, 'SQ_0_TO_M1')
        hasM1 = true;
    elseif strcmp(tr, 'SQ_0_TO_P1')
        hasP1 = true;
    end
end
tf = hasM1 && hasP1;
end

function txt = summarize_target_ids(targets)
if isempty(targets)
    txt = '';
    return;
end
parts = cell(1, numel(targets));
for i = 1:numel(targets)
    parts{i} = normalize_to_char(safe_struct_field(targets(i), 'id', sprintf('target_%d', i)));
end
txt = strjoin(parts, ', ');
end

function out = normalize_group_name(groupName)
g = lower(normalize_to_char(groupName));
if contains(g, 'off')
    out = 'off_aligned';
else
    out = 'aligned';
end
end

function windows = plan_odmr_windows(labels, predicted, odmrCfg)
if isempty(labels)
    windows = struct([]);
    return;
end
labels = unique(labels, 'stable');
keepGroupsSeparate = isfield(odmrCfg, 'keepGroupsSeparate') && logical(odmrCfg.keepGroupsSeparate);
if keepGroupsSeparate && isfield(odmrCfg, 'separateGroupsAboveG')
    bSplit = scalar_numeric_or_nan(odmrCfg.separateGroupsAboveG);
    bNow = NaN;
    if isfield(odmrCfg, 'currentEstimatedB_G')
        bNow = scalar_numeric_or_nan(odmrCfg.currentEstimatedB_G);
    end
    if isfinite(bSplit) && bSplit > 0 && isfinite(bNow) && abs(bNow) < bSplit
        keepGroupsSeparate = false;
    end
end

if keepGroupsSeparate
    alignedLabels = {};
    offLabels = {};
    otherLabels = {};
    for i = 1:numel(labels)
        lb = normalize_to_char(labels{i});
        ll = lower(lb);
        if startsWith(ll, 'aligned_')
            alignedLabels{end+1} = lb; %#ok<AGROW>
        elseif startsWith(ll, 'off_')
            offLabels{end+1} = lb; %#ok<AGROW>
        else
            otherLabels{end+1} = lb; %#ok<AGROW>
        end
    end

    windows = struct([]);
    windows = [windows, build_cluster_windows(alignedLabels, predicted, odmrCfg)]; %#ok<AGROW>
    windows = [windows, build_cluster_windows(offLabels, predicted, odmrCfg)]; %#ok<AGROW>
    windows = [windows, build_cluster_windows(otherLabels, predicted, odmrCfg)]; %#ok<AGROW>
else
    windows = build_cluster_windows(labels, predicted, odmrCfg);
end
end

function windows = build_cluster_windows(labels, predicted, odmrCfg)
if isempty(labels)
    windows = struct([]);
    return;
end
labels = unique(labels, 'stable');

centers = nan(1, numel(labels));
for i = 1:numel(labels)
    centers(i) = scalar_numeric_or_nan(get_map_freq(predicted, labels{i}));
end

valid = isfinite(centers);
labels = labels(valid);
centers = centers(valid);
if isempty(labels)
    windows = struct([]);
    return;
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
    windows(i).expectedPeakCount = estimate_effective_peak_count(cFreq, odmrCfg);
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
intendedPow = choose_odmr_power_for_window(window, ctx, cfg);
odmrPowerOffsetDb = get_cfg_numeric_with_default(cfg.smart.odmr, 'powerOffsetFromIntendedDb', -10);
odmrPow = intendedPow + odmrPowerOffsetDb;
if ~isfinite(odmrPow)
    odmrPow = intendedPow;
end
append_run_decision_event('odmr_power', sprintf('ODMR window [%.6f, %.6f] GHz labels={%s}: intended %.2f dBm, applied %.2f dBm (offset %.2f dB).', ...
    window.fromGHz, window.toGHz, strjoin(window.labels, ', '), intendedPow, odmrPow, odmrPowerOffsetDb));
seq.fixPow = num2str(odmrPow);
fixedPiNs = get_cfg_numeric_with_default(cfg.smart.odmr, 'fixedPiNs', 200);
if isfinite(fixedPiNs) && fixedPiNs > 0
    seq.pi = num2str(round(fixedPiNs), '%.0f');
end
seq.Repeat = num2str(max(1, round(ctx.precal.odmr.repeat)));
seq.Average = num2str(max(1, round(ctx.precal.odmr.average)));
seq.useSG2 = 0;
seq.bSweep2 = 0;
seq.bSweep3 = 0;

% Runtime metadata for live ODMR fit display (not GUI control fields).
seq.meta_odmrExpectedPeakCount = max(1, round(window.expectedPeakCount));
seq.meta_odmrLabels = window.labels;
seq.meta_odmrLabelCentersGHz = window.labelCentersGHz;
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
candFreq = x(idx);
candScore = ySmooth(idx); % lower = deeper minima
[candFreq, ordCand] = sort(candFreq, 'ascend');
candScore = candScore(ordCand);
if isempty(candFreq)
    return;
end

labelRefs = build_label_reference_freqs(window, predicted);
mergeTolGHz = get_odmr_ref_merge_tol_ghz(odmrCfg);
[labelGroup, groupRefs] = group_reference_centers(labelRefs, mergeTolGHz);
nNeed = numel(groupRefs);
maxAssignErrGHz = get_odmr_max_assign_error_ghz(odmrCfg, window);

if numel(candFreq) >= nNeed
    [assignedGroupFreq, assignOk] = assign_peaks_to_labels_monotone(candFreq, candScore, groupRefs, maxAssignErrGHz);
    if assignOk
        for i = 1:numel(window.labels)
            fitMap.(window.labels{i}) = assignedGroupFreq(labelGroup(i));
        end
        ok = true;
        return;
    end
end

% Fallback: greedy assignment for available peaks only.
used = false(1, numel(candFreq));
nAssigned = 0;
assignedGroupFreq = nan(1, nNeed);
for i = 1:nNeed
    ref = groupRefs(i);
    avail = find(~used);
    if isempty(avail)
        break;
    end
    dfAvail = abs(candFreq(avail) - ref);
    [dfBest, rel] = min(dfAvail);
    if ~isfinite(dfBest) || dfBest > maxAssignErrGHz
        continue;
    end
    pick = avail(rel);
    assignedGroupFreq(i) = candFreq(pick);
    used(pick) = true;
    nAssigned = nAssigned + 1;
end

for i = 1:numel(window.labels)
    g = labelGroup(i);
    if g >= 1 && g <= nNeed && isfinite(assignedGroupFreq(g))
        fitMap.(window.labels{i}) = assignedGroupFreq(g);
    end
end

ok = (nAssigned == nNeed);
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

function refs = build_label_reference_freqs(window, predicted)
n = numel(window.labels);
refs = nan(1, n);
for i = 1:n
    refs(i) = get_map_freq(predicted, window.labels{i});
end

if isfield(window, 'labelCentersGHz') && numel(window.labelCentersGHz) == n
    c = double(window.labelCentersGHz(:)).';
    miss = ~isfinite(refs);
    refs(miss) = c(miss);
end

if any(~isfinite(refs))
    if all(~isfinite(refs))
        refs = linspace(window.fromGHz, window.toGHz, n);
    else
        finiteIdx = find(isfinite(refs));
        refs = interp1(finiteIdx, refs(finiteIdx), 1:n, 'linear', 'extrap');
    end
end
refs = refs(:).';
end

function [assignedFreq, ok] = assign_peaks_to_labels_monotone(candFreq, candScore, refs, maxAssignErrGHz)
% Solve ordered peak-to-label assignment:
% choose one strictly increasing peak per label to minimize total cost.
assignedFreq = nan(size(refs));
ok = false;

K = numel(refs);
M = numel(candFreq);
if M < K || K == 0
    return;
end

% Normalize depth score for tie-breaking (lower y = better minima).
score = candScore(:);
if any(isfinite(score))
    sMin = min(score(isfinite(score)));
    sMax = max(score(isfinite(score)));
    if sMax > sMin
        scoreNorm = (score - sMin) ./ (sMax - sMin);
    else
        scoreNorm = zeros(size(score));
    end
else
    scoreNorm = zeros(size(score));
end

% DP state: dp(i+1, j+1) -> min cost using first i candidates for j labels.
dp = inf(M + 1, K + 1);
parent = zeros(M + 1, K + 1); % 0=skip, 1=take
dp(:, 1) = 0;

for i = 1:M
    for j = 0:K
        % Skip candidate i.
        if dp(i, j + 1) < dp(i + 1, j + 1)
            dp(i + 1, j + 1) = dp(i, j + 1);
            parent(i + 1, j + 1) = 0;
        end

        % Take candidate i as label j (1-based label index => j+1 state).
        if j >= 1 && isfinite(dp(i, j))
            dfMHz = abs(candFreq(i) - refs(j)) * 1000;
            if isfinite(maxAssignErrGHz) && maxAssignErrGHz > 0 && ...
                    abs(candFreq(i) - refs(j)) > maxAssignErrGHz
                continue;
            end
            cost = dfMHz + 0.01 * scoreNorm(i); % frequency dominates; depth breaks ties
            if dp(i, j) + cost < dp(i + 1, j + 1)
                dp(i + 1, j + 1) = dp(i, j) + cost;
                parent(i + 1, j + 1) = 1;
            end
        end
    end
end

if ~isfinite(dp(M + 1, K + 1))
    return;
end

selIdx = zeros(1, K);
i = M + 1;
j = K + 1;
while i > 1 && j > 1
    if parent(i, j) == 1
        selIdx(j - 1) = i - 1;
        i = i - 1;
        j = j - 1;
    else
        i = i - 1;
    end
end
if any(selIdx == 0)
    return;
end

assignedFreq = candFreq(selIdx);
ok = all(isfinite(assignedFreq));
end

function maxErrGHz = get_odmr_max_assign_error_ghz(odmrCfg, window)
if isstruct(odmrCfg) && isfield(odmrCfg, 'maxAssignErrorMHz') && isfinite(odmrCfg.maxAssignErrorMHz) ...
        && odmrCfg.maxAssignErrorMHz > 0
    maxErrGHz = odmrCfg.maxAssignErrorMHz / 1000;
else
    % Default: at least 50 MHz, capped by half-window span and margin-based scale.
    spanGHz = max(window.toGHz - window.fromGHz, 0);
    marginGHz = 0.12; % 120 MHz
    maxErrGHz = max(0.05, min(marginGHz, max(spanGHz/2, 0.05)));
end
end

function tolGHz = get_odmr_ref_merge_tol_ghz(odmrCfg)
if isstruct(odmrCfg) && isfield(odmrCfg, 'refMergeTolMHz') && ...
        isfinite(odmrCfg.refMergeTolMHz) && odmrCfg.refMergeTolMHz > 0
    tolGHz = odmrCfg.refMergeTolMHz / 1000;
elseif isstruct(odmrCfg) && isfield(odmrCfg, 'minPeakSepMHz') && ...
        isfinite(odmrCfg.minPeakSepMHz) && odmrCfg.minPeakSepMHz > 0
    tolGHz = odmrCfg.minPeakSepMHz / 1000;
else
    tolGHz = 0.010; % 10 MHz fallback
end
end

function [groupId, groupCenters] = group_reference_centers(refs, tolGHz)
refs = double(refs(:)).';
n = numel(refs);
groupId = nan(1, n);
groupCenters = [];
if n == 0
    return;
end
if ~isfinite(tolGHz) || tolGHz <= 0
    tolGHz = 1e-6;
end

valid = isfinite(refs);
if ~any(valid)
    return;
end

refsValid = refs(valid);
[refsSort, ord] = sort(refsValid, 'ascend');
cid = 0;
tmpGroup = zeros(size(refsSort));
tmpCenter = [];
for i = 1:numel(refsSort)
    if i == 1 || abs(refsSort(i) - refsSort(i-1)) > tolGHz
        cid = cid + 1;
        tmpCenter(cid) = refsSort(i); %#ok<AGROW>
        tmpGroup(i) = cid;
    else
        tmpGroup(i) = cid;
        members = refsSort(tmpGroup == cid);
        tmpCenter(cid) = mean(members);
    end
end

% map sorted valid indices back to original indices
validIdx = find(valid);
for i = 1:numel(ord)
    orig = validIdx(ord(i));
    groupId(orig) = tmpGroup(i);
end
groupCenters = tmpCenter(:).';
end

function nEff = estimate_effective_peak_count(refCentersGHz, odmrCfg)
nEff = 1;
if nargin < 1 || isempty(refCentersGHz)
    return;
end
[~, c] = group_reference_centers(refCentersGHz, get_odmr_ref_merge_tol_ghz(odmrCfg));
if isempty(c)
    nEff = 1;
else
    nEff = max(1, numel(c));
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

function [cache, piNs, piHalfNs, threeHalfPiNs, rabiFreqMHz, powerDbm] = calibrate_rabi_path(pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg, cache)
if stop_requested(hAuto)
    piNs = NaN;
    piHalfNs = NaN;
    threeHalfPiNs = NaN;
    rabiFreqMHz = NaN;
    powerDbm = NaN;
    return;
end

key = [pathName '_' normalize_to_char(label) '_' strrep(num2str(freqGHz, '%.6f'), '.', 'p')];
if isfield(cache, key)
    piNs = cache.(key).piNs;
    piHalfNs = safe_cache_field(cache.(key), 'piHalfNs', NaN);
    threeHalfPiNs = safe_cache_field(cache.(key), 'threeHalfPiNs', NaN);
    rabiFreqMHz = cache.(key).rabiFreqMHz;
    powerDbm = safe_cache_field(cache.(key), 'powerDbm', NaN);
    return;
end

useCaliPiMode = isfield(ctx.precal, 'calipi') && isfield(ctx.precal.calipi, 'enabled') && ...
    logical(ctx.precal.calipi.enabled);
if useCaliPiMode
    [piNs, piHalfNs, threeHalfPiNs, rabiFreqMHz, powerDbm] = calibrate_power_for_target_pi( ...
        pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg);
else
    [piNs, piHalfNs, threeHalfPiNs, rabiFreqMHz, powerDbm] = calibrate_pi_at_fixed_power( ...
        pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg);
end

cache.(key) = struct('piNs', piNs, 'piHalfNs', piHalfNs, 'threeHalfPiNs', threeHalfPiNs, ...
    'rabiFreqMHz', rabiFreqMHz, 'powerDbm', powerDbm);
end

function [piNs, piHalfNs, threeHalfPiNs, rabiFreqMHz, powerDbm] = calibrate_pi_at_fixed_power(pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg)
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
    piHalfNs = NaN;
    threeHalfPiNs = NaN;
    rabiFreqMHz = NaN;
    return;
end
fitting.fit_rabi(hMain, hAuto, false);
apply_rabi_fit_times_to_main_gui(hMain, pathName);
global gmSEQ
piNs = safe_gm_field(gmSEQ, 'RabiFitPi', NaN);
piHalfNs = safe_gm_field(gmSEQ, 'RabiFitPiHalf', NaN);
threeHalfPiNs = safe_gm_field(gmSEQ, 'RabiFitThreeHalfPi', NaN);
rabiFreqMHz = safe_gm_field(gmSEQ, 'RabiFitFreqMHz', NaN);
end

function [piNs, piHalfNs, threeHalfPiNs, rabiFreqMHz, powerDbm] = calibrate_power_for_target_pi(pathName, label, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg)
piNs = NaN;
piHalfNs = NaN;
threeHalfPiNs = NaN;
rabiFreqMHz = NaN;
powerDbm = NaN;
attemptReports = repmat(struct('attemptIndex', NaN, 'chosenPowerDbm', NaN, 'pick', struct(), ...
    'piNs', NaN, 'piHalfNs', NaN, 'threeHalfPiNs', NaN, 'rabiFreqMHz', NaN, ...
    'piErrorNs', NaN, 'clipReason', '', 'scanStartDbm', NaN, 'scanStopDbm', NaN), 0, 1);
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

safeMax = get_numeric_field_with_default(ctx.precal.calipi, 'maxSafePowerDbm', inf);
safeMin = get_numeric_field_with_default(ctx.precal.calipi, 'minSafePowerDbm', -40);
piMismatchNsThreshold = max(0, get_numeric_field_with_default(ctx.precal.calipi, 'piMismatchNsThreshold', 25));
clipRescanMaxIter = max(0, round(get_numeric_field_with_default(ctx.precal.calipi, 'clipRescanMaxIter', 2)));
clipRescanShiftDb = max(0.5, get_numeric_field_with_default(ctx.precal.calipi, 'clipRescanShiftDb', 4));

calipiCfgLocal = ctx.precal.calipi;
attemptMax = 1 + clipRescanMaxIter;
for iAttempt = 1:attemptMax
    ctxAttempt = ctx;
    ctxAttempt.precal.calipi = calipiCfgLocal;

    [powerDbm, pickReport] = pick_power_from_pical_quadratic(pathName, label, freqGHz, basePow, targetPiNs, ...
        ctxAttempt, hMain, hAuto, hObject, eventdata, cfg);
    if ~isfinite(powerDbm)
        powerDbm = apply_p1_calibration_power_boost(basePow, label, cfg);
        powerDbm = enforce_power_safety_cap(powerDbm, safeMax, 'PiCal fallback base power');
    end

    [repeatBoundaryChoice, repeatBoundaryReason] = repeated_boundary_power_choice(attemptReports, powerDbm, safeMin, safeMax);
    if repeatBoundaryChoice
        prev = attemptReports(end);
        piNs = safe_struct_field(prev, 'piNs', NaN);
        piHalfNs = safe_struct_field(prev, 'piHalfNs', NaN);
        threeHalfPiNs = safe_struct_field(prev, 'threeHalfPiNs', NaN);
        rabiFreqMHz = safe_struct_field(prev, 'rabiFreqMHz', NaN);
        attemptReports(end + 1, 1) = struct( ... %#ok<AGROW>
            'attemptIndex', iAttempt, ...
            'chosenPowerDbm', powerDbm, ...
            'pick', pickReport, ...
            'piNs', piNs, ...
            'piHalfNs', piHalfNs, ...
            'threeHalfPiNs', threeHalfPiNs, ...
            'rabiFreqMHz', rabiFreqMHz, ...
            'piErrorNs', NaN, ...
            'clipReason', repeatBoundaryReason, ...
            'scanStartDbm', get_numeric_field_with_default(calipiCfgLocal, 'powerStartDbm', NaN), ...
            'scanStopDbm', get_numeric_field_with_default(calipiCfgLocal, 'powerStopDbm', NaN));
        disp(sprintf('[SmartT1] PiCal repeated boundary power for %s/%s at %.6f GHz: %.2f dBm (%s). Reusing prior verification Rabi and stopping.', ...
            pathName, label, freqGHz, powerDbm, repeatBoundaryReason));
        break;
    end

    % Step 2: run standard Rabi at the fitted power to get final pi time.
    [piNs, piHalfNs, threeHalfPiNs, rabiFreqMHz] = run_rabi_at_fixed_power(pathName, label, freqGHz, powerDbm, ...
        ctxAttempt, hMain, hAuto, hObject, eventdata, cfg);
    attemptReports(end + 1, 1) = struct( ... %#ok<AGROW>
        'attemptIndex', iAttempt, ...
        'chosenPowerDbm', powerDbm, ...
        'pick', pickReport, ...
        'piNs', piNs, ...
        'piHalfNs', piHalfNs, ...
        'threeHalfPiNs', threeHalfPiNs, ...
        'rabiFreqMHz', rabiFreqMHz, ...
        'piErrorNs', NaN, ...
        'clipReason', '', ...
        'scanStartDbm', get_numeric_field_with_default(calipiCfgLocal, 'powerStartDbm', NaN), ...
        'scanStopDbm', get_numeric_field_with_default(calipiCfgLocal, 'powerStopDbm', NaN));
    if ~isfinite(piNs)
        warning('SmartT1:PiCalRabiFitFailed', ...
            'Rabi fit after PiCal failed for %s/%s at %.6f GHz (P=%.2f dBm).', ...
            pathName, label, freqGHz, powerDbm);
        write_pical_decision_report(cfg, pathName, label, freqGHz, basePow, targetPiNs, safeMin, safeMax, attemptReports, 'verification_rabi_fit_failed');
        append_run_decision_event('pical_result', sprintf('PiCal %s/%s at %.6f GHz failed verification Rabi fit at %.2f dBm.', ...
            pathName, label, freqGHz, powerDbm));
        return;
    end

    if ~(isfinite(targetPiNs) && targetPiNs > 0 && isfinite(piMismatchNsThreshold) && piMismatchNsThreshold > 0)
        break;
    end

    piErrNs = piNs - targetPiNs;
    piErrAbsNs = abs(piErrNs);
    attemptReports(end).piErrorNs = piErrNs;
    isAtMaxClip = isfinite(safeMax) && (powerDbm >= (safeMax - 1e-6));
    scanMinDbm = get_numeric_field_with_default(calipiCfgLocal, 'powerStartDbm', NaN);
    isAtScanMin = isfinite(scanMinDbm) && isfinite(powerDbm) && (powerDbm <= (scanMinDbm + 1e-6));
    isAtMinClip = (isfinite(safeMin) && (powerDbm <= (safeMin + 1e-6))) || isAtScanMin;

    if isAtMaxClip && (piErrNs > piMismatchNsThreshold)
        disp(sprintf('[SmartT1] PiCal mismatch accepted for %s/%s: pi=%.2f ns > target=%.2f ns at max clip %.2f dBm (hard cutoff).', ...
            pathName, label, piNs, targetPiNs, safeMax));
        attemptReports(end).clipReason = 'accepted_max_clip_hard_cutoff';
        break;
    end

    needClipRescanMax = isAtMaxClip && (piErrNs < -piMismatchNsThreshold);
    needFastNonMinRescan = (~isAtMinClip) && (piErrNs < -piMismatchNsThreshold);
    if ~(needClipRescanMax || needFastNonMinRescan)
        if piErrAbsNs > piMismatchNsThreshold
            warning('SmartT1:PiCalPiMismatch', ...
                'PiCal+Rabi mismatch for %s/%s at %.6f GHz: target=%.2f ns, measured=%.2f ns (|err|=%.2f ns, P=%.2f dBm).', ...
                pathName, label, freqGHz, targetPiNs, piNs, piErrAbsNs, powerDbm);
        end
        break;
    end

    % Fast-pi (at max clip, or not at minimum) => PiCal sweep likely too high in power.
    if iAttempt >= attemptMax
        warning('SmartT1:PiCalClipRescanExhausted', ...
            ['PiCal fast-pi rescan exhausted for %s/%s at %.6f GHz. ', ...
            'target=%.2f ns, measured=%.2f ns, P=%.2f dBm (scanMin=%.2f dBm, safeMin=%.2f dBm, safeMax=%.2f dBm).'], ...
            pathName, label, freqGHz, targetPiNs, piNs, powerDbm, scanMinDbm, safeMin, safeMax);
        attemptReports(end).clipReason = 'fast_pi_rescan_exhausted';
        break;
    end

    [newStart, newStop, updated] = shift_calipi_power_window_down( ...
        calipiCfgLocal, targetPiNs, piNs, safeMin, safeMax, clipRescanShiftDb);
    if ~updated
        warning('SmartT1:PiCalClipRescanNotUpdated', ...
            ['PiCal fast-pi policy could not update sweep range for %s/%s at %.6f GHz. ', ...
            'target=%.2f ns, measured=%.2f ns, current range [%.2f, %.2f] dBm.'], ...
            pathName, label, freqGHz, targetPiNs, piNs, ...
            get_numeric_field_with_default(calipiCfgLocal, 'powerStartDbm', NaN), ...
            get_numeric_field_with_default(calipiCfgLocal, 'powerStopDbm', NaN));
        attemptReports(end).clipReason = 'fast_pi_rescan_not_updated';
        break;
    end

    oldStart = get_numeric_field_with_default(calipiCfgLocal, 'powerStartDbm', NaN);
    oldStop = get_numeric_field_with_default(calipiCfgLocal, 'powerStopDbm', NaN);
    calipiCfgLocal.powerStartDbm = newStart;
    calipiCfgLocal.powerStopDbm = newStop;
    if needClipRescanMax
        clipReason = 'max-clip';
    else
        clipReason = 'fast-not-min';
    end
    attemptReports(end).clipReason = clipReason;
    disp(sprintf(['[SmartT1] PiCal fast-pi (%s) for %s/%s: target=%.2f ns, measured=%.2f ns, ', ...
        'rescan range [%.2f, %.2f] -> [%.2f, %.2f] dBm (attempt %d/%d).'], ...
        clipReason, pathName, label, targetPiNs, piNs, oldStart, oldStop, newStart, newStop, iAttempt + 1, attemptMax));
end

save_calipi_memory_entry(pathName, freqGHz, powerDbm, piNs, ctx, cfg);
if isfinite(targetPiNs)
    disp(sprintf('[SmartT1] PiCal+Rabi result for %s/%s: targetPi=%.2f ns, pi=%.2f ns at P=%.2f dBm', ...
        pathName, label, targetPiNs, piNs, powerDbm));
else
    disp(sprintf('[SmartT1] PiCal+Rabi result for %s/%s: pi=%.2f ns at P=%.2f dBm', ...
        pathName, label, piNs, powerDbm));
end
write_pical_decision_report(cfg, pathName, label, freqGHz, basePow, targetPiNs, safeMin, safeMax, attemptReports, 'complete');
append_run_decision_event('pical_result', sprintf('PiCal %s/%s at %.6f GHz -> power %.2f dBm, pi %.2f ns.', ...
    pathName, label, freqGHz, powerDbm, piNs));
end

function [newStart, newStop, updated] = shift_calipi_power_window_down(calipiCfg, targetPiNs, piNs, safeMin, safeMax, baseShiftDb)
newStart = get_numeric_field_with_default(calipiCfg, 'powerStartDbm', NaN);
newStop = get_numeric_field_with_default(calipiCfg, 'powerStopDbm', NaN);
updated = false;
if ~(isfinite(newStart) && isfinite(newStop))
    return;
end
if newStop < newStart
    t = newStart;
    newStart = newStop;
    newStop = t;
end

span = newStop - newStart;
if ~isfinite(span) || span <= 0
    span = max(2, abs(baseShiftDb));
end

shiftFromPi = baseShiftDb;
if isfinite(targetPiNs) && targetPiNs > 0 && isfinite(piNs) && piNs > 0
    shiftFromPi = max(baseShiftDb, 20 * log10(targetPiNs / piNs));
end
shiftDown = max(0.5, shiftFromPi);

startCand = newStart - shiftDown;
stopCand = newStop - shiftDown;

% Keep a non-zero gap below max cap when possible so next fitted power
% is not immediately re-clipped.
if isfinite(safeMax)
    upperLimit = safeMax - 0.1;
    if ~isfinite(upperLimit)
        upperLimit = safeMax;
    end
    if stopCand > upperLimit
        delta = stopCand - upperLimit;
        startCand = startCand - delta;
        stopCand = stopCand - delta;
    end
end

startCand = enforce_power_floor_cap(startCand, safeMin, 'PiCal clip-rescan sweep start');
stopCand = enforce_power_floor_cap(stopCand, safeMin, 'PiCal clip-rescan sweep stop');
if isfinite(safeMax)
    startCand = min(startCand, safeMax);
    stopCand = min(stopCand, safeMax);
end

if stopCand <= startCand + 1e-6
    stopCand = startCand + max(0.5, 0.25 * span);
    if isfinite(safeMax)
        stopCand = min(stopCand, safeMax);
    end
end
if stopCand <= startCand + 1e-6
    return;
end

updated = (abs(startCand - newStart) > 1e-6) || (abs(stopCand - newStop) > 1e-6);
newStart = startCand;
newStop = stopCand;
end

function [tf, reason] = repeated_boundary_power_choice(attemptReports, powerDbm, safeMin, safeMax)
tf = false;
reason = '';
if isempty(attemptReports) || ~isfinite(powerDbm)
    return;
end

prevPower = safe_struct_field(attemptReports(end), 'chosenPowerDbm', NaN);
if ~isfinite(prevPower) || abs(prevPower - powerDbm) >= 1e-6
    return;
end

if isfinite(safeMax) && abs(powerDbm - safeMax) < 1e-6
    tf = true;
    reason = 'repeated_max_clip_same_power';
    return;
end
if isfinite(safeMin) && abs(powerDbm - safeMin) < 1e-6
    tf = true;
    reason = 'repeated_min_clip_same_power';
end
end

function [powerDbm, report] = pick_power_from_pical_quadratic(pathName, label, freqGHz, basePow, targetPiNs, ctx, hMain, hAuto, hObject, eventdata, cfg)
powerDbm = NaN;
report = struct('memoryPredictedPowerDbm', NaN, 'memorySource', '', 'memoryUsed', false, ...
    'initialSweepStartDbm', NaN, 'initialSweepStopDbm', NaN, 'finalSweepStartDbm', NaN, 'finalSweepStopDbm', NaN, ...
    'nPow', NaN, 'scanAttempts', NaN, 'boundaryRescanTriggered', false, 'quadraticFitOk', false, ...
    'fittedPowerDbm', NaN, 'fallbackReason', '', 'xPow', [], 'yContrast', []);
safeMax = get_numeric_field_with_default(ctx.precal.calipi, 'maxSafePowerDbm', inf);
safeMin = get_numeric_field_with_default(ctx.precal.calipi, 'minSafePowerDbm', -40);
quadN = max(3, round(get_numeric_field_with_default(ctx.precal.calipi, 'quadFitNPoints', 5)));
pRef = NaN;
boundaryRescanEnabled = logical(get_numeric_field_with_default(ctx.precal.calipi, 'boundaryRescanEnabled', 1));
boundaryRescanMaxIter = max(0, round(get_numeric_field_with_default(ctx.precal.calipi, 'boundaryRescanMaxIter', 2)));
boundaryEdgeFrac = get_numeric_field_with_default(ctx.precal.calipi, 'boundaryEdgeFrac', 0.2);
if ~isfinite(boundaryEdgeFrac) || boundaryEdgeFrac <= 0 || boundaryEdgeFrac >= 0.5
    boundaryEdgeFrac = 0.2;
end

pStart = get_numeric_field_with_default(ctx.precal.calipi, 'powerStartDbm', basePow);
pStop = get_numeric_field_with_default(ctx.precal.calipi, 'powerStopDbm', basePow);
nPow = max(1, round(get_numeric_field_with_default(ctx.precal.calipi, 'powerNPoints', 1)));

if logical(get_numeric_field_with_default(ctx.precal.calipi, 'useMemoryPrior', 1)) && ...
        isfinite(targetPiNs) && targetPiNs > 0
    [pPred, predSource] = predict_power_from_calipi_memory(pathName, freqGHz, targetPiNs, ctx, cfg);
    if isfinite(pPred)
        pRef = pPred;
        report.memoryPredictedPowerDbm = pPred;
        report.memorySource = predSource;
        report.memoryUsed = true;
        halfSpan = max(0.5, get_numeric_field_with_default(ctx.precal.calipi, 'memoryWindowHalfSpanDb', 4));
        pStart = pPred - halfSpan;
        pStop = pPred + halfSpan;
        disp(sprintf('[SmartT1] PiCal memory prior (%s): Ppred=%.2f dBm -> sweep [%.2f, %.2f] dBm at %.6f GHz', ...
            predSource, pPred, pStart, pStop, freqGHz));
    end
end

pStart = apply_p1_calibration_power_boost(pStart, label, cfg);
pStop = apply_p1_calibration_power_boost(pStop, label, cfg);

pStart = enforce_power_floor_cap(pStart, safeMin, 'PiCal sweep start');
pStart = enforce_power_safety_cap(pStart, safeMax, 'PiCal sweep start');
pStop = enforce_power_floor_cap(pStop, safeMin, 'PiCal sweep stop');
pStop = enforce_power_safety_cap(pStop, safeMax, 'PiCal sweep stop');
if nPow <= 1 || abs(pStop - pStart) < eps
    pStart = apply_p1_calibration_power_boost(basePow, label, cfg);
    pStart = enforce_power_floor_cap(pStart, safeMin, 'PiCal single power');
    pStart = enforce_power_safety_cap(pStart, safeMax, 'PiCal single power');
    pStop = pStart;
    nPow = 1;
end
report.initialSweepStartDbm = pStart;
report.initialSweepStopDbm = pStop;
report.nPow = nPow;

if strcmp(pathName, 'sg2')
    seqName = 'PiCal_SG2';
else
    seqName = 'PiCal';
end
scanAttempt = 0;
xPow = [];
yContrast = [];
while true
    scanAttempt = scanAttempt + 1;
    report.scanAttempts = scanAttempt;
    seq = build_pical_power_sweep_sequence(seqName, pathName, freqGHz, pStart, pStop, nPow, targetPiNs, ctx);
    run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, ...
        sprintf(' [%s %s %s @ %.6fGHz P:[%.2f, %.2f] dBm, scan %d]', ...
        seqName, upper(pathName), label, freqGHz, pStart, pStop, scanAttempt));
    if stop_requested(hAuto)
        return;
    end

    [xPow, yContrast] = extract_rabi_like_contrast_from_current_data();
    if numel(xPow) < 3
        break;
    end

    if ~(boundaryRescanEnabled && nPow >= 3 && scanAttempt <= boundaryRescanMaxIter)
        break;
    end

    [isBoundary, side, iMin, edgePts] = pical_minimum_is_near_boundary(xPow, yContrast, boundaryEdgeFrac);
    if ~isBoundary || ~isfinite(iMin)
        break;
    end

    span = pStop - pStart;
    if ~isfinite(span) || span <= 0
        break;
    end
    center = xPow(iMin);
    pNewStart = center - span / 2;
    pNewStop = center + span / 2;
    pNewStart = enforce_power_floor_cap(pNewStart, safeMin, 'PiCal recentered sweep start');
    pNewStart = enforce_power_safety_cap(pNewStart, safeMax, 'PiCal recentered sweep start');
    pNewStop = enforce_power_floor_cap(pNewStop, safeMin, 'PiCal recentered sweep stop');
    pNewStop = enforce_power_safety_cap(pNewStop, safeMax, 'PiCal recentered sweep stop');

    if pNewStop <= pNewStart + eps
        break;
    end
    if abs(pNewStart - pStart) < 1e-9 && abs(pNewStop - pStop) < 1e-9
        break;
    end

    disp(sprintf('[SmartT1] PiCal boundary min (%s, edgePts=%d): recenter sweep [%.2f, %.2f] -> [%.2f, %.2f] dBm around %.2f dBm', ...
        side, edgePts, pStart, pStop, pNewStart, pNewStop, center));
    report.boundaryRescanTriggered = true;
    pStart = pNewStart;
    pStop = pNewStop;
    pRef = center;
end
report.finalSweepStartDbm = pStart;
report.finalSweepStopDbm = pStop;
report.xPow = xPow;
report.yContrast = yContrast;

if numel(xPow) < 3
    warning('SmartT1:PiCalDataTooSmall', ...
        'PiCal data too small for quadratic fit (%s/%s @ %.6f GHz).', pathName, label, freqGHz);
    powerDbm = apply_p1_calibration_power_boost(basePow, label, cfg);
    powerDbm = enforce_power_floor_cap(powerDbm, safeMin, 'PiCal fallback base power');
    powerDbm = enforce_power_safety_cap(powerDbm, safeMax, 'PiCal fallback base power');
    report.fallbackReason = 'data_too_small';
    report.fittedPowerDbm = powerDbm;
    return;
end

[pFit, fitOk] = fit_quadratic_power_near_minimum(xPow, yContrast, quadN, pRef);
if ~fitOk || ~isfinite(pFit)
    warning('SmartT1:PiCalQuadraticFitFailed', ...
        'PiCal quadratic fit failed for %s/%s at %.6f GHz. Falling back to sampled minimum.', ...
        pathName, label, freqGHz);
    iMin = pick_local_min_index(xPow, yContrast, pRef, quadN);
    pFit = xPow(iMin);
    report.fallbackReason = 'quadratic_fit_failed_sampled_minimum';
end
report.quadraticFitOk = logical(fitOk && isfinite(pFit));
pFit = min(max(pFit, min(xPow)), max(xPow));
pFit = enforce_power_floor_cap(pFit, safeMin, 'PiCal fitted power');
pFit = enforce_power_safety_cap(pFit, safeMax, 'PiCal fitted power');
powerDbm = pFit;
report.fittedPowerDbm = powerDbm;
disp(sprintf('[SmartT1] PiCal fitted power for %s/%s at %.6f GHz: %.2f dBm', ...
    pathName, label, freqGHz, powerDbm));
end

function [isBoundary, side, iMin, edgePts] = pical_minimum_is_near_boundary(xPow, yContrast, edgeFrac)
isBoundary = false;
side = 'none';
iMin = NaN;
edgePts = 1;
if numel(xPow) < 3 || isempty(yContrast)
    return;
end
[~, iMin] = min(yContrast);
edgeFrac = min(max(edgeFrac, 0), 0.49);
edgePts = max(1, ceil(edgeFrac * (numel(xPow) - 1)));
if iMin <= edgePts
    isBoundary = true;
    side = 'low';
elseif iMin >= (numel(xPow) - edgePts + 1)
    isBoundary = true;
    side = 'high';
end
end

function [piNs, piHalfNs, threeHalfPiNs, rabiFreqMHz] = run_rabi_at_fixed_power(pathName, label, freqGHz, powerDbm, ctx, hMain, hAuto, hObject, eventdata, cfg)
piNs = NaN;
piHalfNs = NaN;
threeHalfPiNs = NaN;
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
apply_rabi_fit_times_to_main_gui(hMain, pathName);
global gmSEQ
piNs = safe_gm_field(gmSEQ, 'RabiFitPi', NaN);
rabiFreqMHz = safe_gm_field(gmSEQ, 'RabiFitFreqMHz', NaN);
piHalfNs = safe_gm_field(gmSEQ, 'RabiFitPiHalf', NaN);
threeHalfPiNs = safe_gm_field(gmSEQ, 'RabiFitThreeHalfPi', NaN);
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
seq.bSweep3 = 0;
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

function pOut = enforce_power_floor_cap(pIn, minSafe, whatLabel)
pOut = pIn;
if isfinite(minSafe) && pOut < minSafe
    warning('SmartT1:PowerFloorCap', '%s raised from %.2f dBm to %.2f dBm.', whatLabel, pOut, minSafe);
    pOut = minSafe;
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

tolNs = get_numeric_field_with_default(ctx.precal.calipi, 'memoryTargetPiToleranceNs', NaN);
if ~(isfinite(tolNs) && tolNs > 0)
    tolNs = get_numeric_field_with_default(ctx.precal.calipi, 'piMismatchNsThreshold', NaN);
end
if isfinite(tolNs) && tolNs > 0
    targetMask = abs(piNs - targetPiNs) <= tolNs;
    if ~any(targetMask)
        source = 'memory_pi_mismatch_rejected';
        return;
    end
    fGHz = fGHz(targetMask);
    pDbm = pDbm(targetMask);
    piNs = piNs(targetMask);
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
seq.bSweep3 = 0;
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
familyLabel = measurement_display_name_from_target(target);
familyPrefix = measurement_file_prefix_from_target(target);
familyId = safe_struct_field(target, 'runFamilyId', 't1');
fitCfg = select_rough_fit_cfg_for_family(cfg, familyId);
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
    familyId = safe_struct_field(targetRough, 'runFamilyId', familyId);
    roughSeq = build_family_sequence(familyId, targetRough, rangeRough, fSg1, fSg2, piSg1, piSg2, ctx);
    roughSeq.Repeat = num2str(max(1, ctx.rough.repeat));
    roughSeq.Average = num2str(max(1, ctx.rough.average));

    run_one_sequence(roughSeq, hMain, hAuto, hObject, eventdata, cfg, ...
        sprintf(' [Rough %s %s try %d]', familyLabel, target.id, iTry));
    if stop_requested(hAuto)
        finalRange = rangeRough;
        return;
    end

    overlay_previous_rough_points(hMain, roughHist.xDisp, roughHist.y);
    [t1Ms, relErr, curData, fitCurve, edgeRatio] = estimate_relaxation_from_current_data( ...
        familyId, target.transition, roughHist.xMs, roughHist.y, ctx.rough, fitCfg);
    if ~isempty(curData.xMs)
        roughHist.xMs = [roughHist.xMs; curData.xMs(:)];
        roughHist.xDisp = [roughHist.xDisp; curData.xDisp(:)];
        roughHist.y = [roughHist.y; curData.y(:)];
    end
    overlay_combined_rough_fit(hMain, fitCurve.xPlotMs, fitCurve.yPlot, t1Ms, relErr, familyLabel);
    save_rough_overlay_figure(hMain, hAuto, cfg, ...
        sprintf(' [Rough %s %s try %d]', familyLabel, target.id, iTry), familyPrefix);

    roughInfo.t1RoughMs = t1Ms;
    roughInfo.fitRelErr = relErr;
    roughInfo.edgeRatio = edgeRatio;

    % Display policy:
    % - Prefer current-try-only rough metric for UI feedback per iteration.
    % - Fall back to combined metric only when current-try fit is unavailable.
    t1MsDisplay = NaN;
    edgeRatioDisplay = NaN;
    if strcmpi(ctx.rough.stopEstimator, 'edge_ratio')
        if numel(curData.y) >= 2 && isfinite(curData.y(1)) && isfinite(curData.y(end))
            edgeRatioDisplay = abs(curData.y(end)) / max(abs(curData.y(1)), eps);
        end
    else
        [t1MsDisplay, ~] = estimate_relaxation_from_xy(familyId, curData.xMs, curData.y, ctx.rough, fitCfg);
    end
    if ~isfinite(t1MsDisplay)
        t1MsDisplay = t1Ms;
    end
    if ~isfinite(edgeRatioDisplay)
        edgeRatioDisplay = edgeRatio;
    end

    if isfinite(t1MsDisplay)
        update_rough_t1_display(hAuto, cfg, t1MsDisplay, iTry, familyLabel);
    elseif isfinite(edgeRatioDisplay)
        update_rough_ratio_display(hAuto, cfg, edgeRatioDisplay, iTry, familyLabel);
    end
    drawnow;
    if strcmpi(ctx.rough.stopEstimator, 'edge_ratio')
        if isfinite(edgeRatio) && edgeRatio <= ctx.rough.ratioThreshold
            break;
        end
    elseif isfinite(t1Ms)
        if strcmpi(ctx.rough.stopPolicy, 'first_good') && relErr <= ctx.rough.fitRelErrThreshold
            break;
        end
        % In max_retries mode, stop early if the CURRENT rough stop is already valid.
        if strcmpi(ctx.rough.stopPolicy, 'max_retries')
            stopNow = rangeRough(2);
            stopMinNow = start0 + ctx.rough.minSpanFactor * t1Ms * 1e6;
            stopMaxNow = start0 + ctx.rough.maxSpanFactor * t1Ms * 1e6;
            if stopNow >= stopMinNow && stopNow <= stopMaxNow
                disp(sprintf(['[SmartT1] Rough stop accepted early for %s at try %d: ', ...
                    'stop=%.4f ns in [%.4f, %.4f] ns (T1=%.4f ms).'], ...
                    target.id, iTry, stopNow, stopMinNow, stopMaxNow, t1Ms));
                break;
            end
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

function [t1Ms, relErr] = estimate_t1_from_xy(xMs, y, roughCfg, t1FitCfg)
t1Ms = NaN;
relErr = inf;

if nargin < 1 || isempty(xMs) || nargin < 2 || isempty(y)
    return;
end
if nargin < 3 || ~isstruct(roughCfg)
    roughCfg = struct('stopEstimator', 'single_exp');
end
if nargin < 4 || ~isstruct(t1FitCfg)
    t1FitCfg = struct();
end

xFit = xMs(:);
yFit = y(:);
valid = isfinite(xFit) & isfinite(yFit);
xFit = xFit(valid);
yFit = yFit(valid);
if numel(xFit) < 6
    return;
end

fitModel = 'single_exp';
if strcmpi(roughCfg.stopEstimator, 'stretched_div_n')
    fitModel = 'stretched_exp';
end
[popt, perr] = run_t1_fit_with_model(xFit, yFit, fitModel, t1FitCfg);

rate = popt(1);
if ~(isfinite(rate) && rate > 0)
    return;
end

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

function [tauMs, relErr] = estimate_relaxation_from_xy(familyId, xMs, y, roughCfg, fitCfg)
if nargin < 1 || isempty(familyId)
    familyId = 't1';
end
if any(strcmpi(familyId, {'t2', 't2star'}))
    [tauMs, relErr] = estimate_t2_from_xy(xMs, y, roughCfg, fitCfg);
else
    [tauMs, relErr] = estimate_t1_from_xy(xMs, y, roughCfg, fitCfg);
end
end

function fitCfg = select_rough_fit_cfg_for_family(cfg, familyId)
fitCfg = struct();
if nargin < 1 || ~isstruct(cfg) || ~isfield(cfg, 'smart')
    return;
end

roughFitFamily = '';
if nargin >= 2 && isfield(cfg.smart, 'measurements') && isfield(cfg.smart.measurements, familyId)
    roughFitFamily = lower(normalize_to_char(safe_struct_field(cfg.smart.measurements.(familyId), 'roughFitFamily', '')));
end

if strcmp(roughFitFamily, 't2_stretched') || any(strcmpi(familyId, {'t2', 't2star'}))
    if isfield(cfg.smart, 't2fit') && isstruct(cfg.smart.t2fit)
        fitCfg = cfg.smart.t2fit;
        return;
    end
end

if isfield(cfg.smart, 't1fit') && isstruct(cfg.smart.t1fit)
    fitCfg = cfg.smart.t1fit;
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

function [tauMs, relErr, curData, fitCurve, edgeRatio] = estimate_relaxation_from_current_data( ...
    familyId, transition, histXMs, histY, roughCfg, fitCfg)
if nargin < 1 || isempty(familyId)
    familyId = 't1';
end
if any(strcmpi(familyId, {'t2', 't2star'}))
    [tauMs, relErr, curData, fitCurve, edgeRatio] = estimate_t2_from_current_data( ...
        familyId, transition, histXMs, histY, roughCfg, fitCfg);
else
    [tauMs, relErr, curData, fitCurve, edgeRatio] = estimate_t1_from_current_data( ...
        transition, histXMs, histY, roughCfg, fitCfg);
end
end

function [tauMs, relErr] = estimate_t2_from_xy(xMs, y, roughCfg, fitCfg)
tauMs = NaN;
relErr = inf;

if nargin < 2 || isempty(xMs) || isempty(y)
    return;
end
if nargin < 3 || ~isstruct(roughCfg)
    roughCfg = struct('stopEstimator', 'single_exp');
end
if strcmpi(roughCfg.stopEstimator, 'edge_ratio')
    return;
end
if nargin < 4 || ~isstruct(fitCfg)
    fitCfg = struct();
end

xFit = xMs(:);
yFit = y(:);
valid = isfinite(xFit) & isfinite(yFit);
xFit = xFit(valid);
yFit = yFit(valid);
if numel(xFit) < 4
    return;
end

[popt, perr] = fitting.fit_t2_stretched(xFit, yFit, fitCfg);
tauMs = popt(1);
if ~(isfinite(tauMs) && tauMs > 0)
    tauMs = NaN;
    return;
end
if numel(perr) >= 1 && isfinite(perr(1))
    relErr = perr(1) / max(abs(tauMs), eps);
end
end

function [tauMs, relErr, curData, fitCurve, edgeRatio] = estimate_t2_from_current_data( ...
    familyId, transition, histXMs, histY, roughCfg, fitCfg)
global gmSEQ
tauMs = NaN;
relErr = inf;
curData = struct('xMs', [], 'xDisp', [], 'y', []);
fitCurve = struct('xPlotMs', [], 'yPlot', []);
edgeRatio = NaN;

if nargin < 3 || isempty(histXMs)
    histXMs = [];
end
if nargin < 4 || isempty(histY)
    histY = [];
end
if nargin < 5 || ~isstruct(roughCfg)
    roughCfg = struct('stopEstimator', 'single_exp');
end
if nargin < 6 || ~isstruct(fitCfg)
    fitCfg = struct();
end
if ~isfield(gmSEQ, 'signal') || isempty(gmSEQ.signal)
    return;
end

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1));
if isempty(signal)
    return;
end

xMs = double(gmSEQ.SweepParam(1:size(signal, 2))) * 1e-6;
xDisp = double(gmSEQ.SweepParam(1:size(signal, 2))) .* safe_gm_field(gmSEQ, 'ScaleT', 1e-6);

try
    [y, xMs, xDisp] = extract_t2_like_contrast(signal, xMs, xDisp);
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

    if numel(xFit) < 4
        return;
    end

    [popt, perr, xPlotMs, yPlot] = fitting.fit_t2_stretched(xFit, yFit, fitCfg);
    fitCurve.xPlotMs = xPlotMs;
    fitCurve.yPlot = yPlot;
    tauMs = popt(1);
    if isfinite(tauMs) && tauMs > 0 && numel(perr) >= 1 && isfinite(perr(1))
        relErr = perr(1) / max(abs(tauMs), eps);
    elseif ~(isfinite(tauMs) && tauMs > 0)
        tauMs = NaN;
    end
catch
end
end

function [y, xMs, xDisp] = extract_t2_like_contrast(signal, xMs, xDisp)
if size(signal, 1) >= 4
    refB = signal(1, :);
    sigB = signal(2, :);
    refD = signal(3, :);
    sigD = signal(4, :);
    sig = sigB - sigD;
    ref = (refB + refD) / 2;
else
    sig = signal(min(2, size(signal, 1)), :);
    ref = signal(1, :);
end
y = sig ./ ref;
valid = isfinite(xMs) & isfinite(y);
xMs = xMs(valid);
xDisp = xDisp(valid);
y = y(valid);
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

function overlay_combined_rough_fit(handlesMain, xPlotMs, yPlot, tauMs, relErr, familyLabel)
if ~isfield(handlesMain, 'axes3') || ~isgraphics(handlesMain.axes3, 'axes')
    return;
end
global gmSEQ
ax = handlesMain.axes3;
delete(findobj(ax, 'Tag', 'rough_combined_fit'));
if nargin < 4 || isempty(xPlotMs) || isempty(yPlot)
    return;
end
if nargin < 6 || isempty(familyLabel)
    familyLabel = 'Relaxation';
end
scaleT = safe_gm_field(gmSEQ, 'ScaleT', 1e-6);
xPlotDisp = xPlotMs .* (scaleT / 1e-6);
if isfinite(tauMs)
    label = sprintf('Rough %s fit: tau=%.4f ms (relErr=%.3f)', familyLabel, tauMs, relErr);
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

function save_rough_overlay_figure(handlesMain, handlesAuto, cfg, suffix, familyPrefix)
global gSaveDataAve
if isempty(gSaveDataAve) || ~isstruct(gSaveDataAve) || ~isfield(gSaveDataAve, 'file')
    return;
end
if nargin < 5 || isempty(familyPrefix)
    familyPrefix = 'T1';
end
save_main_figure(handlesMain, handlesAuto, gSaveDataAve.file, cfg, ...
    ['. Current sequence is finished.' suffix], ['Rough_' familyPrefix '_'], default_intermediate_artifact_subfolder());
end

function seq = build_t1_sequence(target, range, fSg1, fSg2, piSg1, piSg2, ctx)
tStart = range(1);
tStop = range(2);
n = max(3, round(target.t1.nPoints));
n1 = n;
n2 = 0;
split = tStart + (tStop - tStart)/4;
[powLabelSg1, powLabelSg2] = get_t1_power_labels(target);
[halfPiNs, deerPiNs, deerTNs] = get_sequence_pulse_times(target, piSg1, piSg2);

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
                seq.halfpi = num2str(halfPiNs, '%.0f');
            end
            if isfinite(deerTNs) && deerTNs > 0
                seq.DEERt = num2str(deerTNs, '%.0f');
            end
            if isfinite(deerPiNs) && deerPiNs > 0
                seq.DEERpi = num2str(deerPiNs, '%.0f');
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
                seq.halfpi = num2str(halfPiNs, '%.0f');
            end
            if isfinite(deerTNs) && deerTNs > 0
                seq.DEERt = num2str(deerTNs, '%.0f');
            end
            if isfinite(deerPiNs) && deerPiNs > 0
                seq.DEERpi = num2str(deerPiNs, '%.0f');
            elseif ~isfinite(piSg2) || piSg2 <= 0
                seq.DEERpi = num2str(100, '%.0f');
            else
                seq.DEERpi = num2str(piSg2, '%.0f');
            end
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

function families = active_measurement_families(ctx)
families = {};
if ~isfield(ctx, 'measurements') || ~isstruct(ctx.measurements)
    families = {'t1'};
    return;
end
names = {'t1', 't2', 't2star'};
for i = 1:numel(names)
    name = names{i};
    if isfield(ctx.measurements, name) && isfield(ctx.measurements.(name), 'enabled') && ...
            logical(ctx.measurements.(name).enabled)
        families{end + 1} = name; %#ok<AGROW>
    end
end
end

function targetsOut = filter_targets_for_enabled_measurements(targetsIn, measurements)
if nargin < 2 || ~isstruct(measurements)
    targetsOut = targetsIn([targetsIn.enabled]);
    return;
end
keep = false(1, numel(targetsIn));
for i = 1:numel(targetsIn)
    if ~targetsIn(i).enabled
        continue;
    end
    keep(i) = target_supported_by_any_enabled_family(targetsIn(i), measurements);
end
targetsOut = targetsIn(keep);
end

function tf = target_supported_by_any_enabled_family(target, measurements)
tf = false;
familyNames = fieldnames(measurements);
for i = 1:numel(familyNames)
    familyCfg = measurements.(familyNames{i});
    if isfield(familyCfg, 'enabled') && logical(familyCfg.enabled) && target_supported_by_family(target, familyCfg)
        tf = true;
        return;
    end
end
end

function tf = target_supported_by_family(target, familyCfg)
tf = true;
if isfield(familyCfg, 'supportedTargetIds') && ~isempty(familyCfg.supportedTargetIds)
    tf = any(strcmp(target.id, familyCfg.supportedTargetIds));
end
end

function [finalRange, roughInfo] = determine_family_final_range(family, target, fSg1, fSg2, piSg1, piSg2, ctx, hMain, hAuto, hObject, eventdata, cfg)
targetFamily = target;
if isfield(target, family)
    targetFamily.t1 = target.(family);
end
targetFamily.runFamilyId = family;
targetFamily.runFamilyDisplay = safe_struct_field(ctx.measurements.(family), 'displayName', upper(family));
ctxFamily = ctx;
if isfield(ctxFamily.measurements, family) && isfield(ctxFamily.measurements.(family), 'roughStopEstimator')
    ctxFamily.rough.stopEstimator = ctxFamily.measurements.(family).roughStopEstimator;
end
[finalRange, roughInfo] = determine_t1_final_range( ...
    targetFamily, fSg1, fSg2, piSg1, piSg2, ctxFamily, hMain, hAuto, hObject, eventdata, cfg);
end

function tf = is_sij_all_target(target, ctx)
tf = is_sij_all_enabled(ctx) && isstruct(target) && isfield(target, 'isSijAll') && logical(target.isSijAll);
end

function [finalRange, roughInfo] = determine_sij_all_final_range(target, fSg1, fSg2, piSg1, piSg2, ctx, hMain, hAuto, hObject, eventdata, cfg)
roughInfo = struct('t1RoughMs', NaN, 'fitRelErr', NaN, 'edgeRatio', NaN, ...
    'nRuns', 0, 'stopEstimator', ctx.rough.stopEstimator, ...
    'sq', struct(), 'dq', struct(), 'chosen', '', ...
    'tSQm1Ms', NaN, 'tDQMs', NaN, 'sijAllIntervals', struct('enabled', false));

sqTarget = target;
sqTarget.id = [target.id '_sq_rough'];
sqTarget.transition = 'SQ_0_TO_M1';
sqTarget.runFamilyId = 't1';
sqTarget.runFamilyDisplay = 'T1_SQ';

dqTarget = target;
dqTarget.id = [target.id '_dq_rough'];
dqTarget.transition = 'DQ_M1_TO_P1';
dqTarget.runFamilyId = 't1';
dqTarget.runFamilyDisplay = 'T1_DQ';

[rangeSQ, infoSQ] = determine_t1_final_range( ...
    sqTarget, fSg1, fSg2, piSg1, piSg2, ctx, hMain, hAuto, hObject, eventdata, cfg);
roughInfo.sq = infoSQ;
if stop_requested(hAuto)
    finalRange = rangeSQ;
    return;
end

[rangeDQ, infoDQ] = determine_t1_final_range( ...
    dqTarget, fSg1, fSg2, piSg1, piSg2, ctx, hMain, hAuto, hObject, eventdata, cfg);
roughInfo.dq = infoDQ;
if stop_requested(hAuto)
    finalRange = rangeDQ;
    return;
end

tSQ = safe_struct_field(infoSQ, 't1RoughMs', NaN);
tDQ = safe_struct_field(infoDQ, 't1RoughMs', NaN);
roughInfo.tSQm1Ms = tSQ;
roughInfo.tDQMs = tDQ;
roughInfo.sijAllIntervals = build_sij_all_interval_plan_from_rough(tSQ, tDQ);
if isfinite(tSQ) && isfinite(tDQ)
    if tDQ >= tSQ
        finalRange = rangeDQ;
        roughInfo.t1RoughMs = tDQ;
        roughInfo.fitRelErr = safe_struct_field(infoDQ, 'fitRelErr', NaN);
        roughInfo.edgeRatio = safe_struct_field(infoDQ, 'edgeRatio', NaN);
        roughInfo.nRuns = safe_struct_field(infoSQ, 'nRuns', 0) + safe_struct_field(infoDQ, 'nRuns', 0);
        roughInfo.chosen = 'DQ';
    else
        finalRange = rangeSQ;
        roughInfo.t1RoughMs = tSQ;
        roughInfo.fitRelErr = safe_struct_field(infoSQ, 'fitRelErr', NaN);
        roughInfo.edgeRatio = safe_struct_field(infoSQ, 'edgeRatio', NaN);
        roughInfo.nRuns = safe_struct_field(infoSQ, 'nRuns', 0) + safe_struct_field(infoDQ, 'nRuns', 0);
        roughInfo.chosen = 'SQ';
    end
elseif isfinite(tDQ)
    finalRange = rangeDQ;
    roughInfo.t1RoughMs = tDQ;
    roughInfo.fitRelErr = safe_struct_field(infoDQ, 'fitRelErr', NaN);
    roughInfo.edgeRatio = safe_struct_field(infoDQ, 'edgeRatio', NaN);
    roughInfo.nRuns = safe_struct_field(infoSQ, 'nRuns', 0) + safe_struct_field(infoDQ, 'nRuns', 0);
    roughInfo.chosen = 'DQ';
elseif isfinite(tSQ)
    finalRange = rangeSQ;
    roughInfo.t1RoughMs = tSQ;
    roughInfo.fitRelErr = safe_struct_field(infoSQ, 'fitRelErr', NaN);
    roughInfo.edgeRatio = safe_struct_field(infoSQ, 'edgeRatio', NaN);
    roughInfo.nRuns = safe_struct_field(infoSQ, 'nRuns', 0) + safe_struct_field(infoDQ, 'nRuns', 0);
    roughInfo.chosen = 'SQ';
else
    spanSQ = abs(rangeSQ(2) - rangeSQ(1));
    spanDQ = abs(rangeDQ(2) - rangeDQ(1));
    if spanDQ >= spanSQ
        finalRange = rangeDQ;
        roughInfo.chosen = 'DQ_range';
    else
        finalRange = rangeSQ;
        roughInfo.chosen = 'SQ_range';
    end
    roughInfo.nRuns = safe_struct_field(infoSQ, 'nRuns', 0) + safe_struct_field(infoDQ, 'nRuns', 0);
end

disp(sprintf('[SmartT1] T1 Sij-all rough choice for %s: SQ=%.4f ms, DQ=%.4f ms, chosen=%s.', ...
    target.id, tSQ, tDQ, roughInfo.chosen));
append_run_decision_event('sij_all_rough_choice', sprintf('%s SQ=%.6g ms DQ=%.6g ms chosen=%s', ...
    target.id, tSQ, tDQ, roughInfo.chosen));
end

function plan = build_sij_all_interval_plan_from_rough(tSQm1Ms, tDQMs)
plan = struct('enabled', false, 'tFastNs', NaN, 'tSlowNs', NaN, ...
    'tMidNs', NaN, 'tEndNs', NaN);
if ~(isfinite(tSQm1Ms) && tSQm1Ms > 0 && isfinite(tDQMs) && tDQMs > 0)
    return;
end

tFastNs = min(tSQm1Ms, tDQMs) * 1e6;
tSlowNs = max(tSQm1Ms, tDQMs) * 1e6;
plan.enabled = true;
plan.tFastNs = tFastNs;
plan.tSlowNs = tSlowNs;
plan.tMidNs = min(5 * tFastNs, tSlowNs);
plan.tEndNs = 5 * tSlowNs;
end

function seq = build_family_sequence(family, target, range, fSg1, fSg2, piSg1, piSg2, ctx)
tStart = range(1);
tStop = range(2);
params = target.(family);
n = max(3, round(params.nPoints));
n1 = n;
n2 = 0;
split = tStart + (tStop - tStart)/4;
[powLabelSg1, powLabelSg2] = get_t1_power_labels(target);
[halfPiNs, deerPiNs, deerTNs] = get_sequence_pulse_times(target, piSg1, piSg2);

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
seq.name = resolve_family_sequence_name(ctx, family, target.transition);
seq.useSG2 = double(strcmp(target.transition, 'DQ_M1_TO_P1'));
if ctx.precal.enabled
    cfgLocal = power_boost_cfg_from_ctx(ctx);
    powSg1 = apply_p1_calibration_power_boost(ctx.power.rabi_sg1_dBm, powLabelSg1, cfgLocal);
    powSg2 = apply_p1_calibration_power_boost(ctx.power.rabi_sg2_dBm, powLabelSg2, cfgLocal);
    seq.fixPow = num2str(powSg1);
    seq.fixFreq = num2str(fSg1, '%.8f');
    seq.fixPow2 = num2str(powSg2);
    if strcmp(target.transition, 'DQ_M1_TO_P1')
        seq.fixFreq2 = num2str(fSg2, '%.8f');
    end
    if isfinite(piSg1) && piSg1 > 0
        seq.pi = num2str(piSg1, '%.0f');
        seq.halfpi = num2str(halfPiNs, '%.0f');
    end
    if isfinite(deerTNs) && deerTNs > 0
        seq.DEERt = num2str(deerTNs, '%.0f');
    end
    if isfinite(deerPiNs) && deerPiNs > 0
        seq.DEERpi = num2str(deerPiNs, '%.0f');
    elseif seq.useSG2
        if ~isfinite(piSg2) || piSg2 <= 0
            piSg2 = 100;
        end
        seq.DEERpi = num2str(piSg2, '%.0f');
    end
end

seq.Repeat = num2str(max(1, round(params.repeat)));
seq.Average = num2str(max(1, round(params.average)));
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

function seq = build_sij_all_sequence(target, range, fSg1, fSg2, piSg1, piSg2, ctx, roughInfo)
if nargin < 8 || ~isstruct(roughInfo)
    roughInfo = struct();
end
tStart = range(1);
tStop = range(2);
params = target.t1;
n = max(3, round(params.nPoints));
n1 = n;
n2 = 0;
split = tStart + (tStop - tStart)/4;
[powLabelSg1, powLabelSg2] = get_t1_power_labels(target);
threeIntervalPlan = safe_struct_field(roughInfo, 'sijAllIntervals', struct('enabled', false));

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
        disp(sprintf(['[SmartT1] Sij-all grid adjusted for integer points: ', ...
            'start=%.0f, split=%.0f, stop=%.0f, n1=%d, n2=%d'], ...
            round(tStart), round(split), round(tStop), n1, n2));
    end
else
    tStop = align_stop_to_integer_points(tStart, tStop, n);
end

seq = struct();
seq.name = safe_struct_field(ctx.sijAll, 'sequenceName', 'T1_Sij_all');
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
        seq.DEERt = num2str(1.5 * piSg1, '%.0f');
    end
    if isfinite(piSg2) && piSg2 > 0
        seq.DEERpi = num2str(piSg2, '%.0f');
    else
        seq.DEERpi = num2str(100, '%.0f');
    end
end

seq.Repeat = num2str(max(1, round(params.repeat)));
seq.Average = num2str(max(1, round(params.average)));
[seq, threeIntervalApplied] = apply_sij_all_three_interval_sweep(seq, target, threeIntervalPlan, ctx);
if threeIntervalApplied
    return;
end
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

function [seq, applied] = apply_sij_all_three_interval_sweep(seq, target, plan, ctx)
applied = false;
if ~isstruct(plan) || ~isfield(plan, 'enabled') || ~logical(plan.enabled)
    return;
end
if ~isstruct(target)
    return;
end

n1 = max(2, round(safe_struct_field(ctx.sijAll, 'firstIntervalNPoints', 8)));
n2 = max(2, round(safe_struct_field(ctx.sijAll, 'secondIntervalNPoints', 6)));
n3MinDefault = safe_struct_field(ctx.sijAll, 'thirdIntervalNPoints', 4);
n3Min = max(1, round(safe_struct_field(ctx.sijAll, 'thirdIntervalMinNPoints', n3MinDefault)));
[from1, to1, from2, to2, from3, to3, customPts, n3, ok] = ...
    compute_sij_all_integer_three_interval_sweep(plan, n1, n2, n3Min);
if ~ok
    return;
end

seq.bSweep2 = 1;
seq.FROM1 = num2str(from1, '%.12g');
seq.TO1 = num2str(to1, '%.12g');
seq.SweepNPoints = num2str(n1);
seq.FROM2 = num2str(from2, '%.12g');
seq.TO2 = num2str(to2, '%.12g');
seq.SweepNPoints2 = num2str(n2);
seq.bSweep3 = 1;
seq.bSweep3log = 0;
seq.FROM3 = num2str(from3, '%.12g');
seq.TO3 = num2str(to3, '%.12g');
seq.SweepNPoints3 = num2str(n3);
seq.SmartCustomSweepParam = customPts;

append_run_decision_event('sij_all_three_interval', sprintf([ ...
    '%s FROM1=%.12g TO1=%.12g N1=%d FROM2=%.12g TO2=%.12g N2=%d ', ...
    'FROM3=%.12g TO3=%.12g N3=%d'], ...
    normalize_to_char(safe_struct_field(seq, 'name', 'T1_Sij_all')), ...
    from1, to1, n1, from2, to2, n2, from3, to3, n3));
applied = true;
end

function [from1, to1, from2, to2, from3, to3, customPts, n3, ok] = compute_sij_all_integer_three_interval_sweep(plan, n1, n2, n3Min)
from1 = 1000;
to1 = NaN;
from2 = NaN;
to2 = NaN;
from3 = NaN;
to3 = NaN;
customPts = [];
n3 = max(1, round(n3Min));
ok = false;

tFast = round(safe_struct_field(plan, 'tFastNs', NaN));
tMid = round(safe_struct_field(plan, 'tMidNs', NaN));
tEnd = round(safe_struct_field(plan, 'tEndNs', NaN));
if ~(isfinite(tFast) && tFast > from1 && isfinite(tMid) && isfinite(tEnd) && tEnd > 0)
    return;
end

to1 = align_stop_to_integer_points(from1, tFast, n1);
tMid = max(tMid, to1 + n2);
to2 = align_exclusive_stop_to_integer_points(to1, tMid, n2);
from2 = first_point_after_inclusive_edge(to1, to2, n2);
n3Estimate = ceil((1 - to2 / tEnd) * 11);
if ~isfinite(n3Estimate)
    n3Estimate = n3;
end
n3 = max(max(1, n3Estimate), n3);
tEnd = max(tEnd, to2 + n3);
to3 = align_exclusive_stop_to_integer_points(to2, tEnd, n3);
from3 = first_point_after_inclusive_edge(to2, to3, n3);

pts1 = linspace(from1, to1, n1);
pts2 = linspace(from2, to2, n2);
pts3 = linspace(from3, to3, n3);
customPts = unique(enforce_integer_time_points([pts1 pts2 pts3]), 'stable');
expectedN = n1 + n2 + n3;
ok = numel(customPts) == expectedN && all(isfinite(customPts)) && all(abs(customPts - round(customPts)) < 1e-9);
end

function stopOut = align_exclusive_stop_to_integer_points(leftEdge, stopIn, nPts)
leftEdge = round(leftEdge);
if nPts < 1
    stopOut = leftEdge;
    return;
end
span = max(round(stopIn) - leftEdge, nPts);
step = max(1, ceil(span / nPts));
stopOut = leftEdge + step * nPts;
end

function firstPt = first_point_after_inclusive_edge(leftEdge, rightEdge, nPts)
if nPts < 1
    firstPt = round(rightEdge);
    return;
end
step = (round(rightEdge) - round(leftEdge)) / nPts;
firstPt = round(leftEdge) + step;
end

function seq = apply_late_time_points_to_sequence(seq, range, roughInfo, ctx)
if ~isstruct(ctx) || ~isfield(ctx, 'addLateTimePoints') || ~logical(ctx.addLateTimePoints)
    return;
end
if isfield(seq, 'SmartCustomSweepParam') && ~isempty(seq.SmartCustomSweepParam)
    return;
end
seqName = normalize_to_char(safe_struct_field(seq, 'name', ''));
if ~startsWith(seqName, 'T1_')
    return;
end
if nargin < 3 || ~isstruct(roughInfo) || ~isfield(roughInfo, 't1RoughMs') || ~isfinite(roughInfo.t1RoughMs)
    return;
end

t1Ns = double(roughInfo.t1RoughMs) * 1e6;
if ~(isfinite(t1Ns) && t1Ns > 0)
    return;
end

startNs = 0;
if nargin >= 2 && numel(range) >= 1 && isfinite(range(1))
    startNs = double(range(1));
end
extraRaw = startNs + [4 5 6] .* t1Ns;
extra = enforce_integer_time_points(extraRaw);
extra = extra(isfinite(extra) & extra >= 0);
if numel(extra) ~= 3
    return;
end

base = sequence_sweep_points(seq);
custom = unique(enforce_integer_time_points([base(:).' extra(:).']), 'stable');

seq.bSweep3 = 1;
seq.bSweep3log = 0;
seq.FROM3 = num2str(extra(1), '%.12g');
seq.TO3 = num2str(extra(end), '%.12g');
seq.SweepNPoints3 = '3';
seq.SmartCustomSweepParam = custom;
append_run_decision_event('add_late_time_points', sprintf('%s late time points added at %.12g, %.12g, %.12g ns', ...
    seqName, extra(1), extra(2), extra(3)));
end

function pts = enforce_integer_time_points(pts)
pts = double(pts);
valid = isfinite(pts);
pts(valid) = round(pts(valid));
end

function pts = sequence_sweep_points(seq)
if isfield(seq, 'SmartCustomSweepParam') && ~isempty(seq.SmartCustomSweepParam)
    pts = double(seq.SmartCustomSweepParam(:).');
    pts = unique(pts, 'stable');
    return;
end

from1 = str2double(normalize_to_char(safe_struct_field(seq, 'FROM1', '0')));
to1 = str2double(normalize_to_char(safe_struct_field(seq, 'TO1', '0')));
n1 = max(1, round(str2double(normalize_to_char(safe_struct_field(seq, 'SweepNPoints', '1')))));
if isfinite(from1) && isfinite(to1)
    pts = linspace(from1, to1, n1);
else
    pts = [];
end

if isfield(seq, 'bSweep2') && logical(normalize_to_numeric(seq.bSweep2, 0))
    from2 = str2double(normalize_to_char(safe_struct_field(seq, 'FROM2', '')));
    to2 = str2double(normalize_to_char(safe_struct_field(seq, 'TO2', '')));
    n2 = max(1, round(str2double(normalize_to_char(safe_struct_field(seq, 'SweepNPoints2', '1')))));
    if isfinite(from2) && isfinite(to2)
        pts = [pts linspace(from2, to2, n2)]; %#ok<AGROW>
    end
end

if isfield(seq, 'bSweep3') && logical(normalize_to_numeric(seq.bSweep3, 0))
    from3 = str2double(normalize_to_char(safe_struct_field(seq, 'FROM3', '')));
    to3 = str2double(normalize_to_char(safe_struct_field(seq, 'TO3', '')));
    n3 = max(1, round(str2double(normalize_to_char(safe_struct_field(seq, 'SweepNPoints3', '1')))));
    if isfinite(from3) && isfinite(to3)
        pts = [pts linspace(from3, to3, n3)]; %#ok<AGROW>
    end
end
pts = unique(pts, 'stable');
end

function seqName = resolve_family_sequence_name(ctx, family, transition)
seqName = '';
if isfield(ctx, 'measurements') && isfield(ctx.measurements, family)
    familyCfg = ctx.measurements.(family);
    if isfield(familyCfg, 'sequenceByTransition') && isfield(familyCfg.sequenceByTransition, transition)
        seqName = familyCfg.sequenceByTransition.(transition);
    end
end
if isempty(seqName)
    switch family
        case 't2'
            if any(strcmp(transition, {'SQ_0_TO_M1', 'SQ_0_TO_P1'}))
                seqName = 'T2_S00_S01_S10';
            end
        case 't2star'
            if any(strcmp(transition, {'SQ_0_TO_M1', 'SQ_0_TO_P1'}))
                seqName = 'T2Star_S00_S01_S10';
            end
        otherwise
            if strcmp(transition, 'DQ_M1_TO_P1')
                seqName = 'T1_S11_S1m1';
            else
                seqName = 'T1_S00_S01_S10';
            end
    end
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

function [halfPiNs, deerPiNs, deerTNs] = get_sequence_pulse_times(target, piSg1, piSg2)
halfPiNs = NaN;
deerPiNs = NaN;
deerTNs = NaN;

if isfield(target, 'fitPulseTimes') && isstruct(target.fitPulseTimes)
    halfPiNs = safe_struct_field(target.fitPulseTimes, 'piHalfSg1Ns', NaN);
    deerTNs = safe_struct_field(target.fitPulseTimes, 'threeHalfPiSg1Ns', NaN);
end

if ~isfinite(halfPiNs) || halfPiNs <= 0
    if isfinite(piSg1) && piSg1 > 0
        halfPiNs = piSg1 / 2;
    end
end
if ~isfinite(deerTNs) || deerTNs <= 0
    if isfinite(piSg1) && piSg1 > 0
        deerTNs = 1.5 * piSg1;
    end
end
if ~isfinite(deerPiNs) || deerPiNs <= 0
    if isfinite(piSg2) && piSg2 > 0
        deerPiNs = piSg2;
    end
end
end

function cfgOut = power_boost_cfg_from_ctx(ctx)
cfgOut = struct('smart', struct('power', struct('sq_p1_calibration_boost_dB', 0)));
if isfield(ctx, 'power') && isfield(ctx.power, 'sq_p1_calibration_boost_dB') && ...
        isfinite(ctx.power.sq_p1_calibration_boost_dB)
    cfgOut.smart.power.sq_p1_calibration_boost_dB = ctx.power.sq_p1_calibration_boost_dB;
end
end

function apply_rabi_fit_times_to_main_gui(handlesMain, pathName)
global gmSEQ

piNs = safe_gm_field(gmSEQ, 'RabiFitPi', NaN);
piHalfNs = safe_gm_field(gmSEQ, 'RabiFitPiHalf', NaN);
threeHalfPiNs = safe_gm_field(gmSEQ, 'RabiFitThreeHalfPi', NaN);

if strcmp(pathName, 'sg2')
    if isfield(handlesMain, 'DEERpi') && isfinite(piNs) && piNs > 0
        set_control_value(handlesMain.DEERpi, num2str(piNs, '%.0f'));
    end
    return;
end

if isfield(handlesMain, 'pi') && isfinite(piNs) && piNs > 0
    set_control_value(handlesMain.pi, num2str(piNs, '%.0f'));
end
if isfield(handlesMain, 'halfpi') && isfinite(piHalfNs) && piHalfNs > 0
    set_control_value(handlesMain.halfpi, num2str(piHalfNs, '%.0f'));
end
if isfield(handlesMain, 'DEERt') && isfinite(threeHalfPiNs) && threeHalfPiNs > 0
    set_control_value(handlesMain.DEERt, num2str(threeHalfPiNs, '%.0f'));
end
end

function run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, suffix)
global gSaveDataAve gmSEQ
if stop_requested(hAuto)
    return;
end

isRough = is_rough_sequence_suffix(suffix);
cmdText = '';
stoppedByAutoGui = false;
tStartDn = now;
tStartTic = tic;
try
    cmdText = evalc('stoppedByAutoGui = run_one_sequence_core(seq, hMain, hAuto, hObject, eventdata, cfg, suffix, isRough);');
catch ME
    reportText = getReport(ME, 'extended', 'hyperlinks', 'off');
    if isempty(cmdText)
        cmdText = reportText;
    else
        cmdText = sprintf('%s\n%s', cmdText, reportText);
    end
    write_sequence_command_log(cfg, seq, suffix, isRough, cmdText, 'error', ME.message);
    write_sequence_measurement_report(cfg, seq, suffix, isRough, 'error', ME.message, tStartDn, toc(tStartTic));
    write_measurement_failure_report(cfg, seq, suffix, isRough, ME, tStartDn, toc(tStartTic));
    if ~isempty(cmdText)
        fprintf('%s', cmdText);
    end
    rethrow(ME);
end

if stoppedByAutoGui
    statusText = 'stopped';
else
    statusText = 'success';
end
write_sequence_command_log(cfg, seq, suffix, isRough, cmdText, statusText, '');
write_sequence_measurement_report(cfg, seq, suffix, isRough, statusText, '', tStartDn, toc(tStartTic));
if ~isempty(cmdText)
    fprintf('%s', cmdText);
end
end

function policy = read_final_t1_autostop_policy(cfg, hAuto)
policy = struct( ...
    'autoStopByRelErr', false, ...
    'relErrThreshold', 0.05, ...
    'minAverageForAutoStop', 3);

if isfield(cfg, 'smart') && isfield(cfg.smart, 'finalT1') && isstruct(cfg.smart.finalT1)
    src = cfg.smart.finalT1;
    if isfield(src, 'autoStopByRelErr')
        policy.autoStopByRelErr = logical(src.autoStopByRelErr);
    end
    if isfield(src, 'relErrThreshold') && isfinite(src.relErrThreshold)
        policy.relErrThreshold = src.relErrThreshold;
    end
    if isfield(src, 'minAverageForAutoStop') && isfinite(src.minAverageForAutoStop)
        policy.minAverageForAutoStop = max(1, round(src.minAverageForAutoStop));
    end
end

if isfield(cfg, 'smart') && isfield(cfg.smart, 'ui') && ...
        isfield(cfg.smart.ui, 'tags') && isfield(cfg.smart.ui.tags, 'finalT1') && ...
        isstruct(cfg.smart.ui.tags.finalT1)
    tags = cfg.smart.ui.tags.finalT1;
    if isfield(tags, 'enable')
        policy.autoStopByRelErr = logical(read_ui_numeric(hAuto, tags.enable, policy.autoStopByRelErr));
    end
    if isfield(tags, 'relErr')
        policy.relErrThreshold = read_ui_numeric(hAuto, tags.relErr, policy.relErrThreshold);
    end
    if isfield(tags, 'minAverage')
        policy.minAverageForAutoStop = read_ui_numeric(hAuto, tags.minAverage, policy.minAverageForAutoStop);
    end
end

if ~isfinite(policy.relErrThreshold) || policy.relErrThreshold <= 0
    policy.relErrThreshold = 0.05;
end
if ~isfinite(policy.minAverageForAutoStop) || policy.minAverageForAutoStop < 1
    policy.minAverageForAutoStop = 3;
end
policy.minAverageForAutoStop = max(1, round(policy.minAverageForAutoStop));
end

function stoppedByAutoGui = run_one_sequence_core(seq, hMain, hAuto, hObject, eventdata, cfg, suffix, isRough)
global gSaveDataAve gmSEQ

isTrueT1 = isfield(seq, 'name') && ...
    (strcmp(seq.name, 'T1_S00_S01_S10') || strcmp(seq.name, 'T1_S11_S1m1') || ...
    strcmp(seq.name, 'T1_Sij_all'));
finalT1Stop = read_final_t1_autostop_policy(cfg, hAuto);
autoStopEnabled = finalT1Stop.autoStopByRelErr;
autoStopThr = finalT1Stop.relErrThreshold;
autoStopMinAvg = finalT1Stop.minAverageForAutoStop;
gmSEQ.AutoStopT1ByRelErr = autoStopEnabled && isTrueT1 && ~isRough;
gmSEQ.AutoStopT1RelErrThreshold = autoStopThr;
gmSEQ.AutoStopT1MinAverage = autoStopMinAvg;

% Push optional ODMR live-fit metadata into gmSEQ for fitting.fit_esr().
if isfield(seq, 'meta_odmrExpectedPeakCount')
    gmSEQ.ESRFitExpectedPeakCount = max(1, round(normalize_to_numeric(seq.meta_odmrExpectedPeakCount, 1)));
else
    gmSEQ.ESRFitExpectedPeakCount = 1;
end
if isfield(seq, 'meta_odmrLabels') && iscell(seq.meta_odmrLabels)
    gmSEQ.ESRFitWindowLabels = seq.meta_odmrLabels;
else
    gmSEQ.ESRFitWindowLabels = {};
end
if isfield(seq, 'meta_odmrLabelCentersGHz')
    gmSEQ.ESRFitLabelCentersGHz = double(seq.meta_odmrLabelCentersGHz(:)).';
else
    gmSEQ.ESRFitLabelCentersGHz = [];
end

% Internal runtime metadata is not a main-GUI control.
for metaField = {'meta_odmrExpectedPeakCount', 'meta_odmrLabels', 'meta_odmrLabelCentersGHz'}
    if isfield(seq, metaField{1})
        seq = rmfield(seq, metaField{1});
    end
end

apply_sequence_to_main_gui(seq, hMain);
if stop_requested(hAuto)
    stoppedByAutoGui = true;
    return;
end

auto_load_user_inputs(hObject, eventdata, hMain);
if stop_requested(hAuto)
    stoppedByAutoGui = true;
    return;
end

t1_semi_auto_run(hObject, eventdata, hMain, hAuto);
stoppedByAutoGui = stop_requested(hAuto);

fileNamePrefix = '';
if isRough
    fileNamePrefix = rough_measurement_prefix_from_suffix(suffix);
end

savedImagePath = '';
if ~isempty(gSaveDataAve) && isstruct(gSaveDataAve) && isfield(gSaveDataAve, 'file')
    if stoppedByAutoGui
        statusSuffix = ['. Sequence stopped by Auto GUI' suffix];
    else
        statusSuffix = ['. Current sequence is finished.' suffix];
    end
    savedImagePath = save_main_figure(hMain, hAuto, gSaveDataAve.file, cfg, statusSuffix, fileNamePrefix, ...
        choose_sequence_artifact_subfolder(seq, isRough));
end
log_notion_sequence_event(seq, suffix, savedImagePath, stoppedByAutoGui);
end

function tf = is_rough_sequence_suffix(suffix)
tf = contains(lower(normalize_to_char(suffix)), '[rough ');
end

function prefix = rough_measurement_prefix_from_suffix(suffix)
raw = lower(normalize_to_char(suffix));
if contains(raw, '[rough t2*')
    prefix = 'Rough_T2Star_';
elseif contains(raw, '[rough t2')
    prefix = 'Rough_T2_';
else
    prefix = 'Rough_T1_';
end
end

function write_sequence_command_log(cfg, seq, suffix, isRough, cmdText, statusText, errMsg)
if nargin < 5 || isempty(cmdText)
    return;
end
logPath = sequence_command_log_path(cfg, seq, suffix, isRough);
if isempty(logPath)
    return;
end
header = build_sequence_command_log_header(seq, suffix, statusText);
footer = build_sequence_command_log_footer(statusText, errMsg);
write_text_file_local(logPath, [header cmdText footer]);
end

function write_sequence_measurement_report(cfg, seq, suffix, isRough, statusText, errMsg, startedDn, elapsedSec)
reportPath = sequence_measurement_report_path(cfg, seq, suffix, isRough);
if isempty(reportPath)
    return;
end
txt = build_sequence_measurement_report_text(cfg, seq, suffix, isRough, statusText, errMsg, startedDn, elapsedSec);
write_text_file_local(reportPath, txt);
end

function write_measurement_failure_report(cfg, seq, suffix, isRough, ME, startedDn, elapsedSec)
if nargin < 5 || isempty(ME)
    return;
end
reportPath = measurement_failure_report_path(cfg, seq, suffix, isRough);
if isempty(reportPath)
    return;
end
lines = { ...
    '==== v2.2 Measurement Failure Report ====', ...
    sprintf('StartedAt: %s', datestr(startedDn, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('FinishedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('ElapsedSec: %.6f', max(0, double(elapsedSec))), ...
    sprintf('SequenceName: %s', safe_seq_name(seq)), ...
    sprintf('Suffix: %s', normalize_to_char(suffix)), ...
    sprintf('ArtifactClass: %s', measurement_artifact_class_name(isRough, seq)), ...
    sprintf('ErrorMessage: %s', normalize_to_char(ME.message)), ...
    '', ...
    '---- begin stack ----', ...
    getReport(ME, 'extended', 'hyperlinks', 'off'), ...
    '---- end stack ----'};
write_text_file_local(reportPath, sprintf('%s\n', lines{:}));
end

function reportPath = sequence_measurement_report_path(cfg, seq, suffix, isRough)
reportPath = '';
baseFolder = report_root_folder(cfg);
if isempty(baseFolder)
    return;
end
subfolderName = choose_sequence_artifact_subfolder(seq, isRough);
reportFolder = fullfile(baseFolder, 'measurements');
if isempty(subfolderName)
    reportFolder = fullfile(reportFolder, 'final');
else
    reportFolder = fullfile(reportFolder, subfolderName);
end
ensure_folder_exists_local(reportFolder);
stem = sequence_command_log_stem(seq, suffix, isRough);
if isempty(stem)
    stem = ['measurement_' datestr(now, 'yyyymmdd_HHMMSS_FFF')];
end
reportPath = fullfile(reportFolder, [sanitize_log_token(stem) '__report.txt']);
end

function reportPath = measurement_failure_report_path(cfg, seq, suffix, isRough)
reportPath = '';
baseFolder = report_root_folder(cfg);
if isempty(baseFolder)
    return;
end
reportFolder = fullfile(baseFolder, 'failures');
ensure_folder_exists_local(reportFolder);
stem = sequence_command_log_stem(seq, suffix, isRough);
if isempty(stem)
    stem = ['measurement_' datestr(now, 'yyyymmdd_HHMMSS_FFF')];
end
reportPath = fullfile(reportFolder, [sanitize_log_token(stem) '__failure.txt']);
end

function txt = build_sequence_measurement_report_text(cfg, seq, suffix, isRough, statusText, errMsg, startedDn, elapsedSec)
global gSaveDataAve gmSEQ
finishedDn = now;
saveString = extract_save_string_stem(gSaveDataAve);
analysisLines = matching_analysis_entry_lines(saveString);
fitLines = current_fit_summary_lines_for_sequence(seq);
spotCtxLines = current_spot_context_lines();
decisionLines = get_run_decision_event_lines();
seqLines = struct_scalar_summary_lines(seq, 'SequenceFields');
logPath = sequence_command_log_path(cfg, seq, suffix, isRough);
lines = { ...
    '==== v2.2 Measurement Report ====', ...
    sprintf('StartedAt: %s', datestr(startedDn, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('FinishedAt: %s', datestr(finishedDn, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('ElapsedSec: %.6f', max(0, double(elapsedSec))), ...
    sprintf('SequenceName: %s', safe_seq_name(seq)), ...
    sprintf('Suffix: %s', normalize_to_char(suffix)), ...
    sprintf('Status: %s', normalize_to_char(statusText)), ...
    sprintf('ArtifactClass: %s', measurement_artifact_class_name(isRough, seq)), ...
    sprintf('RunSaveFolder: %s', current_run_save_folder(cfg)), ...
    sprintf('SequenceLogPath: %s', logPath), ...
    sprintf('SaveString: %s', saveString)}.';
if isfield(gmSEQ, 'AnalysisMeasuredB') && isfinite(gmSEQ.AnalysisMeasuredB)
    lines{end + 1} = sprintf('MeasuredB_G: %.12g', gmSEQ.AnalysisMeasuredB); %#ok<AGROW>
end
if ~isempty(strtrim(normalize_to_char(errMsg)))
    lines{end + 1} = sprintf('Error: %s', normalize_to_char(errMsg)); %#ok<AGROW>
end
lines{end + 1} = ''; %#ok<AGROW>
lines = [lines; spotCtxLines(:); {''}; seqLines(:); {''}; fitLines(:); {''}; analysisLines(:); {''}; decisionLines(:)]; %#ok<AGROW>
txt = sprintf('%s\n', lines{:});
end

function lines = current_spot_context_lines()
lines = {'SpotContext:'};
ctx = read_spot_report_context();
if ~isstruct(ctx) || isempty(fieldnames(ctx))
    lines{end + 1} = '  none'; %#ok<AGROW>
    return;
end
fields = {'tSetK', 'targetBkG', 'spotName', 'spotOrder', 'spotX_V', 'spotY_V', ...
    'tbStepIndex', 'bIndex', 'nBTotal', 'spotIndex', 'nSpotTotal', ...
    'skipTemperatureControl', 'skipFieldControl', 'testModeNoBT'};
for i = 1:numel(fields)
    f = fields{i};
    if isfield(ctx, f)
        lines{end + 1} = sprintf('  %s: %s', f, summarize_report_value(ctx.(f))); %#ok<AGROW>
    end
end
end

function write_v2_run_summary_report(cfg)
reportRoot = report_root_folder(cfg);
if isempty(reportRoot)
    return;
end
spotFolder = fullfile(reportRoot, 'spot');
ensure_folder_exists_local(spotFolder);
reportPath = fullfile(spotFolder, 'v2_2_run_summary.txt');
write_text_file_local(reportPath, build_v2_run_summary_report_text(cfg));
end

function txt = build_v2_run_summary_report_text(cfg)
global gmSEQ
lines = { ...
    '==== v2.2 Run Summary ====', ...
    sprintf('GeneratedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('RunStartedAt: %s', normalize_to_char(safe_struct_field(gmSEQ, 'ReportRunStartedAt', ''))), ...
    sprintf('RunSaveFolder: %s', current_run_save_folder(cfg)), ...
    sprintf('AnalysisSnippetPath: %s', fullfile(current_run_save_folder(cfg), 'analysis_add_entry_snippet.txt')), ...
    sprintf('FinalAutoGuiPath: %s', fullfile(current_run_save_folder(cfg), 'AutoGUI_v2_1_Final.png')), ...
    ''}.';
spotCtxLines = current_spot_context_lines();
decisionLines = get_run_decision_event_lines();
analysisLines = all_analysis_entry_lines();
fitLines = current_fit_summary_lines_for_sequence(struct('name', 'RUN_SUMMARY'));
folderLines = { ...
    'ReportFolders:', ...
    sprintf('  spot: %s', fullfile(report_root_folder(cfg), 'spot')), ...
    sprintf('  measurements/final: %s', fullfile(report_root_folder(cfg), 'measurements', 'final')), ...
    sprintf('  measurements/%s: %s', default_intermediate_artifact_subfolder(), ...
        fullfile(report_root_folder(cfg), 'measurements', default_intermediate_artifact_subfolder())), ...
    sprintf('  pical: %s', fullfile(report_root_folder(cfg), 'pical')), ...
    sprintf('  failures: %s', fullfile(report_root_folder(cfg), 'failures'))};
lines = [lines; spotCtxLines(:); {''}; fitLines(:); {''}; analysisLines(:); {''}; decisionLines(:); {''}; folderLines(:)]; %#ok<AGROW>
txt = sprintf('%s\n', lines{:});
end

function lines = all_analysis_entry_lines()
global gmSEQ
lines = {'AllAnalysisEntries:'};
if isempty(gmSEQ) || ~isstruct(gmSEQ) || ~isfield(gmSEQ, 'AnalysisEntries') || isempty(gmSEQ.AnalysisEntries)
    lines{end + 1} = '  none'; %#ok<AGROW>
    return;
end
for i = 1:numel(gmSEQ.AnalysisEntries)
    e = gmSEQ.AnalysisEntries(i);
    lines{end + 1} = sprintf('  [%d] save=%s family=%s group=%s sequence=%s spin=%s date=%s nArg=%s', ...
        i, normalize_to_char(safe_struct_field(e, 'saveString', '')), ...
        normalize_to_char(safe_struct_field(e, 'family', '')), ...
        normalize_to_char(safe_struct_field(e, 'group', '')), ...
        normalize_to_char(safe_struct_field(e, 'sequence', '')), ...
        normalize_to_char(safe_struct_field(e, 'spin', '')), ...
        normalize_to_char(safe_struct_field(e, 'date', '')), ...
        summarize_report_value(safe_struct_field(e, 'nArg', NaN))); %#ok<AGROW>
end
end

function lines = struct_scalar_summary_lines(s, titleLine)
lines = {sprintf('%s:', normalize_to_char(titleLine))};
if nargin < 1 || ~isstruct(s) || isempty(fieldnames(s))
    lines{end + 1} = '  none'; %#ok<AGROW>
    return;
end
fields = sort(fieldnames(s));
for i = 1:numel(fields)
    f = fields{i};
    lines{end + 1} = sprintf('  %s: %s', f, summarize_report_value(s.(f))); %#ok<AGROW>
end
end

function lines = current_fit_summary_lines_for_sequence(seq)
global gmSEQ
lines = {'FitSummary:'};
if isempty(gmSEQ) || ~isstruct(gmSEQ)
    lines{end + 1} = '  none'; %#ok<AGROW>
    return;
end
seqName = upper(strtrim(safe_seq_name(seq)));
if strcmp(seqName, 'ODMR')
    fitFields = {'ESRFitFreq', 'ESRFitFreqAllMHz'};
elseif any(strcmp(seqName, {'RABI', 'RABI_SG2', 'PICAL', 'PICAL_SG2', 'CALIPI'}))
    fitFields = {'RabiFitPi', 'RabiFitPiHalf', 'RabiFitThreeHalfPi', 'RabiFitFreqMHz', 'RabiFitContrastPct'};
elseif strcmp(seqName, 'RUN_SUMMARY')
    fitFields = {'ESRFitFreq', 'ESRFitFreqAllMHz', 'RabiFitPi', 'RabiFitPiHalf', 'RabiFitThreeHalfPi', ...
        'RabiFitFreqMHz', 'RabiFitContrastPct', 'T1FitT1', 'T1FitRelErr', 'T1FitBeta', 'T1FitModelUsed'};
else
    fitFields = {'T1FitT1', 'T1FitRelErr', 'T1FitBeta', 'T1FitModelUsed'};
end
added = false;
for i = 1:numel(fitFields)
    f = fitFields{i};
    if isfield(gmSEQ, f)
        lines{end + 1} = sprintf('  %s: %s', f, summarize_report_value(gmSEQ.(f))); %#ok<AGROW>
        added = true;
    end
end
if any(strcmp(seqName, {'RUN_SUMMARY', 'T1_S00_S01_S10', 'T1_S11_S1m1', 'ECHO', 'RAMSEY', ''})) && ...
        isfield(gmSEQ, 'T1FitLastStatus') && isstruct(gmSEQ.T1FitLastStatus)
    lines{end + 1} = sprintf('  T1FitLastStatus.ok: %s', summarize_report_value(safe_struct_field(gmSEQ.T1FitLastStatus, 'ok', []))); %#ok<AGROW>
    lines{end + 1} = sprintf('  T1FitLastStatus.msg: %s', summarize_report_value(safe_struct_field(gmSEQ.T1FitLastStatus, 'msg', ''))); %#ok<AGROW>
    added = true;
end
if any(strcmp(seqName, {'RUN_SUMMARY', 'RABI', 'RABI_SG2', 'PICAL', 'PICAL_SG2', 'CALIPI'})) && ...
        isfield(gmSEQ, 'RabiFitLastStatus') && isstruct(gmSEQ.RabiFitLastStatus)
    lines{end + 1} = sprintf('  RabiFitLastStatus.ok: %s', summarize_report_value(safe_struct_field(gmSEQ.RabiFitLastStatus, 'ok', []))); %#ok<AGROW>
    lines{end + 1} = sprintf('  RabiFitLastStatus.msg: %s', summarize_report_value(safe_struct_field(gmSEQ.RabiFitLastStatus, 'msg', ''))); %#ok<AGROW>
    added = true;
end
if any(strcmp(seqName, {'RUN_SUMMARY', 'ODMR'})) && isfield(gmSEQ, 'ESRFitLastStatus') && isstruct(gmSEQ.ESRFitLastStatus)
    lines{end + 1} = sprintf('  ESRFitLastStatus.ok: %s', summarize_report_value(safe_struct_field(gmSEQ.ESRFitLastStatus, 'ok', []))); %#ok<AGROW>
    lines{end + 1} = sprintf('  ESRFitLastStatus.msg: %s', summarize_report_value(safe_struct_field(gmSEQ.ESRFitLastStatus, 'msg', ''))); %#ok<AGROW>
    added = true;
end
if ~added
    lines{end + 1} = '  none'; %#ok<AGROW>
end
end

function lines = matching_analysis_entry_lines(saveString)
global gmSEQ
lines = {'AnalysisEntriesForSaveString:'};
if isempty(saveString) || ~isfield(gmSEQ, 'AnalysisEntries') || isempty(gmSEQ.AnalysisEntries)
    lines{end + 1} = '  none'; %#ok<AGROW>
    return;
end
added = false;
for i = 1:numel(gmSEQ.AnalysisEntries)
    e = gmSEQ.AnalysisEntries(i);
    if ~strcmp(normalize_to_char(safe_struct_field(e, 'saveString', '')), saveString)
        continue;
    end
    lines{end + 1} = sprintf('  [%d] family=%s group=%s sequence=%s spin=%s date=%s nArg=%s', ...
        i, normalize_to_char(safe_struct_field(e, 'family', '')), ...
        normalize_to_char(safe_struct_field(e, 'group', '')), ...
        normalize_to_char(safe_struct_field(e, 'sequence', '')), ...
        normalize_to_char(safe_struct_field(e, 'spin', '')), ...
        normalize_to_char(safe_struct_field(e, 'date', '')), ...
        summarize_report_value(safe_struct_field(e, 'nArg', NaN))); %#ok<AGROW>
    added = true;
end
if ~added
    lines{end + 1} = '  none'; %#ok<AGROW>
end
end

function baseFolder = report_root_folder(cfg)
baseFolder = current_run_save_folder(cfg);
if isempty(baseFolder)
    baseFolder = '';
    return;
end
baseFolder = fullfile(baseFolder, 'reports');
ensure_folder_exists_local(baseFolder);
end

function saveFolder = current_run_save_folder(cfg)
saveFolder = cfg.paths.saveFolder;
if isfield(cfg, 'runtime') && isstruct(cfg.runtime) && ...
        isfield(cfg.runtime, 'runSaveFolder') && ~isempty(cfg.runtime.runSaveFolder)
    saveFolder = cfg.runtime.runSaveFolder;
end
end

function ensure_folder_exists_local(pathIn)
if isempty(pathIn)
    return;
end
if ~exist(pathIn, 'dir')
    mkdir(pathIn);
end
end

function name = safe_seq_name(seq)
name = '';
if isstruct(seq) && isfield(seq, 'name')
    name = normalize_to_char(seq.name);
end
end

function out = measurement_artifact_class_name(isRough, seq)
subfolderName = choose_sequence_artifact_subfolder(seq, isRough);
if isempty(subfolderName)
    out = 'final';
else
    out = subfolderName;
end
end

function out = summarize_report_value(v)
if isnumeric(v) || islogical(v)
    if isempty(v)
        out = '[]';
    elseif isscalar(v)
        if islogical(v)
            out = ternary_text(logical(v), 'true', 'false');
        elseif isfinite(double(v))
            out = num2str(double(v), '%.12g');
        else
            out = 'NaN';
        end
    else
        vv = double(v(:));
        vvFinite = vv(isfinite(vv));
        headN = min(numel(vv), 5);
        headTxt = strtrim(sprintf(' %.6g', vv(1:headN)));
        if isempty(vvFinite)
            rangeTxt = 'all_nonfinite';
        else
            rangeTxt = sprintf('min=%.6g max=%.6g', min(vvFinite), max(vvFinite));
        end
        out = sprintf('[%dx%d numeric] %s first={%s}', size(v,1), size(v,2), rangeTxt, headTxt);
    end
elseif ischar(v) || (isstring(v) && isscalar(v))
    out = normalize_to_char(v);
elseif iscell(v)
    if isempty(v)
        out = '{}';
    else
        preview = cell(1, min(numel(v), 4));
        for i = 1:numel(preview)
            preview{i} = summarize_report_value(v{i});
        end
        out = sprintf('{%s%s}', strjoin(preview, ', '), ternary_text(numel(v) > numel(preview), ', ...', ''));
    end
elseif isstruct(v)
    out = sprintf('[struct fields=%s]', strjoin(fieldnames(v), ', '));
else
    out = class(v);
end
out = normalize_to_char(out);
end

function append_run_decision_event(kind, msg)
global gmSEQ
if isempty(gmSEQ) || ~isstruct(gmSEQ)
    gmSEQ = struct();
end
entry = struct('time', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'), ...
    'kind', normalize_to_char(kind), ...
    'message', normalize_to_char(msg));
if ~isfield(gmSEQ, 'ReportDecisionEvents') || isempty(gmSEQ.ReportDecisionEvents)
    gmSEQ.ReportDecisionEvents = entry;
else
    gmSEQ.ReportDecisionEvents(end + 1) = entry; %#ok<AGROW>
end
end

function lines = get_run_decision_event_lines()
global gmSEQ
lines = {'DecisionEvents:'};
if isempty(gmSEQ) || ~isstruct(gmSEQ) || ~isfield(gmSEQ, 'ReportDecisionEvents') || isempty(gmSEQ.ReportDecisionEvents)
    lines{end + 1} = '  none'; %#ok<AGROW>
    return;
end
for i = 1:numel(gmSEQ.ReportDecisionEvents)
    e = gmSEQ.ReportDecisionEvents(i);
    lines{end + 1} = sprintf('  [%s] (%s) %s', ...
        normalize_to_char(safe_struct_field(e, 'time', '')), ...
        normalize_to_char(safe_struct_field(e, 'kind', '')), ...
        normalize_to_char(safe_struct_field(e, 'message', ''))); %#ok<AGROW>
end
end

function txt = summarize_final_range_decision(familyName, targetId, finalRange, roughInfo)
tail = '';
if nargin >= 4 && isstruct(roughInfo)
    if isfield(roughInfo, 't1RoughMs') && isfinite(roughInfo.t1RoughMs)
        tail = sprintf(', roughMs=%.6g', roughInfo.t1RoughMs);
    elseif isfield(roughInfo, 'edgeRatio') && isfinite(roughInfo.edgeRatio)
        tail = sprintf(', edgeRatio=%.6g', roughInfo.edgeRatio);
    end
end
txt = sprintf('%s %s final range [%.6g, %.6g] ns%s', ...
    normalize_to_char(familyName), normalize_to_char(targetId), ...
    finalRange(1), finalRange(min(numel(finalRange), 2)), tail);
end

function txt = summarize_sij_all_range_decision(targetId, finalRange, roughInfo)
sqMs = NaN;
dqMs = NaN;
chosen = '';
if isstruct(roughInfo)
    if isfield(roughInfo, 'sq') && isstruct(roughInfo.sq)
        sqMs = safe_struct_field(roughInfo.sq, 't1RoughMs', NaN);
    end
    if isfield(roughInfo, 'dq') && isstruct(roughInfo.dq)
        dqMs = safe_struct_field(roughInfo.dq, 't1RoughMs', NaN);
    end
    chosen = normalize_to_char(safe_struct_field(roughInfo, 'chosen', ''));
end
txt = sprintf('T1 Sij-all %s final range [%.6g, %.6g] ns, SQrough=%.6g ms, DQrough=%.6g ms, chosen=%s', ...
    normalize_to_char(targetId), finalRange(1), finalRange(min(numel(finalRange), 2)), sqMs, dqMs, chosen);
end

function txt = summarize_sij_all_rough_tail(roughInfo)
sqMs = NaN;
dqMs = NaN;
chosen = '';
if isstruct(roughInfo)
    if isfield(roughInfo, 'sq') && isstruct(roughInfo.sq)
        sqMs = safe_struct_field(roughInfo.sq, 't1RoughMs', NaN);
    end
    if isfield(roughInfo, 'dq') && isstruct(roughInfo.dq)
        dqMs = safe_struct_field(roughInfo.dq, 't1RoughMs', NaN);
    end
    chosen = normalize_to_char(safe_struct_field(roughInfo, 'chosen', ''));
end
txt = sprintf('roughSQ=%.3fms roughDQ=%.3fms chosen=%s', sqMs, dqMs, chosen);
end

function ctx = read_spot_report_context()
ctx = struct();
try
    if isappdata(0, 'SMART_V2_2_SPOT_REPORT_CONTEXT')
        ctx = getappdata(0, 'SMART_V2_2_SPOT_REPORT_CONTEXT');
    end
catch
    ctx = struct();
end
end

function write_pical_decision_report(cfg, pathName, label, freqGHz, basePow, targetPiNs, safeMin, safeMax, attemptReports, statusText)
reportRoot = report_root_folder(cfg);
if isempty(reportRoot)
    return;
end
folderOut = fullfile(reportRoot, 'pical');
ensure_folder_exists_local(folderOut);
spotCtx = read_spot_report_context();
spotStem = sanitize_log_token(normalize_to_char(safe_struct_field(spotCtx, 'spotName', 'spot')));
fileStem = sprintf('%s_%s_%s_%s_%s', ...
    datestr(now, 'yyyymmdd_HHMMSS_FFF'), sanitize_log_token(pathName), sanitize_log_token(label), ...
    sanitize_log_token(num2str(freqGHz, '%.6f')), spotStem);
pathOut = fullfile(folderOut, [fileStem '.txt']);
write_text_file_local(pathOut, build_pical_decision_report_text(pathName, label, freqGHz, basePow, targetPiNs, safeMin, safeMax, attemptReports, statusText));
end

function txt = build_pical_decision_report_text(pathName, label, freqGHz, basePow, targetPiNs, safeMin, safeMax, attemptReports, statusText)
spotCtxLines = current_spot_context_lines();
lines = { ...
    '==== v2.2 PiCal Decision Report ====', ...
    sprintf('GeneratedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('Status: %s', normalize_to_char(statusText)), ...
    sprintf('PathName: %s', normalize_to_char(pathName)), ...
    sprintf('Label: %s', normalize_to_char(label)), ...
    sprintf('FreqGHz: %.12g', freqGHz), ...
    sprintf('BasePowerDbm: %.12g', basePow), ...
    sprintf('TargetPiNs: %s', summarize_report_value(targetPiNs)), ...
    sprintf('SafeMinPowerDbm: %s', summarize_report_value(safeMin)), ...
    sprintf('SafeMaxPowerDbm: %s', summarize_report_value(safeMax)), ...
    ''}.';
lines = [lines; spotCtxLines(:); {''}; {'Attempts:'}]; %#ok<AGROW>
if isempty(attemptReports)
    lines{end + 1} = '  none'; %#ok<AGROW>
else
    for i = 1:numel(attemptReports)
        a = attemptReports(i);
        lines{end + 1} = sprintf('  Attempt %d:', i); %#ok<AGROW>
        lines{end + 1} = sprintf('    chosenPowerDbm: %s', summarize_report_value(safe_struct_field(a, 'chosenPowerDbm', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    piNs: %s', summarize_report_value(safe_struct_field(a, 'piNs', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    piHalfNs: %s', summarize_report_value(safe_struct_field(a, 'piHalfNs', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    threeHalfPiNs: %s', summarize_report_value(safe_struct_field(a, 'threeHalfPiNs', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    rabiFreqMHz: %s', summarize_report_value(safe_struct_field(a, 'rabiFreqMHz', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    piErrorNs: %s', summarize_report_value(safe_struct_field(a, 'piErrorNs', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    clipReason: %s', normalize_to_char(safe_struct_field(a, 'clipReason', ''))); %#ok<AGROW>
        lines{end + 1} = sprintf('    scanStartDbm: %s', summarize_report_value(safe_struct_field(a, 'scanStartDbm', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    scanStopDbm: %s', summarize_report_value(safe_struct_field(a, 'scanStopDbm', NaN))); %#ok<AGROW>
        pick = safe_struct_field(a, 'pick', struct());
        lines{end + 1} = sprintf('    memoryUsed: %s', summarize_report_value(safe_struct_field(pick, 'memoryUsed', false))); %#ok<AGROW>
        lines{end + 1} = sprintf('    memoryPredictedPowerDbm: %s', summarize_report_value(safe_struct_field(pick, 'memoryPredictedPowerDbm', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    memorySource: %s', normalize_to_char(safe_struct_field(pick, 'memorySource', ''))); %#ok<AGROW>
        lines{end + 1} = sprintf('    initialSweep: [%s, %s]', ...
            summarize_report_value(safe_struct_field(pick, 'initialSweepStartDbm', NaN)), ...
            summarize_report_value(safe_struct_field(pick, 'initialSweepStopDbm', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    finalSweep: [%s, %s]', ...
            summarize_report_value(safe_struct_field(pick, 'finalSweepStartDbm', NaN)), ...
            summarize_report_value(safe_struct_field(pick, 'finalSweepStopDbm', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    scanAttempts: %s', summarize_report_value(safe_struct_field(pick, 'scanAttempts', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    boundaryRescanTriggered: %s', summarize_report_value(safe_struct_field(pick, 'boundaryRescanTriggered', false))); %#ok<AGROW>
        lines{end + 1} = sprintf('    quadraticFitOk: %s', summarize_report_value(safe_struct_field(pick, 'quadraticFitOk', false))); %#ok<AGROW>
        lines{end + 1} = sprintf('    fittedPowerDbm: %s', summarize_report_value(safe_struct_field(pick, 'fittedPowerDbm', NaN))); %#ok<AGROW>
        lines{end + 1} = sprintf('    fallbackReason: %s', normalize_to_char(safe_struct_field(pick, 'fallbackReason', ''))); %#ok<AGROW>
        lines{end + 1} = sprintf('    xPow: %s', summarize_report_value(safe_struct_field(pick, 'xPow', []))); %#ok<AGROW>
        lines{end + 1} = sprintf('    yContrast: %s', summarize_report_value(safe_struct_field(pick, 'yContrast', []))); %#ok<AGROW>
    end
end
txt = sprintf('%s\n', lines{:});
end

function logPath = sequence_command_log_path(cfg, seq, suffix, isRough)
logPath = '';
baseFolder = cfg.paths.saveFolder;
if isfield(cfg, 'runtime') && isstruct(cfg.runtime) && ...
        isfield(cfg.runtime, 'runSaveFolder') && ~isempty(cfg.runtime.runSaveFolder)
    baseFolder = cfg.runtime.runSaveFolder;
end
if isempty(baseFolder)
    return;
end
subfolderName = choose_sequence_artifact_subfolder(seq, isRough);
logFolder = fullfile(baseFolder, 'logs');
if ~isempty(subfolderName)
    logFolder = fullfile(logFolder, subfolderName);
end
if ~exist(logFolder, 'dir')
    mkdir(logFolder);
end
stem = sequence_command_log_stem(seq, suffix, isRough);
if isempty(stem)
    stem = ['sequence_' datestr(now, 'yyyymmdd_HHMMSS_FFF')];
end
logPath = fullfile(logFolder, [sanitize_log_token(stem) '.log']);
end

function stem = sequence_command_log_stem(seq, suffix, isRough)
global gSaveDataAve
stem = '';
if ~isempty(gSaveDataAve) && isstruct(gSaveDataAve) && isfield(gSaveDataAve, 'file')
    [~, stem0, ~] = fileparts(normalize_to_char(gSaveDataAve.file));
    stem = stem0;
end
if isempty(stem)
    seqName = '';
    if isstruct(seq) && isfield(seq, 'name')
        seqName = normalize_to_char(seq.name);
    end
    if isempty(seqName)
        seqName = 'sequence';
    end
    stem = sprintf('%s_%s', seqName, datestr(now, 'yyyymmdd_HHMMSS_FFF'));
end
if isRough
    pfx = rough_measurement_prefix_from_suffix(suffix);
    if ~isempty(pfx) && ~startsWith(stem, pfx)
        stem = [pfx stem];
    end
end
end

function txt = build_sequence_command_log_header(seq, suffix, statusText)
seqName = '';
if isstruct(seq) && isfield(seq, 'name')
    seqName = normalize_to_char(seq.name);
end
lines = { ...
    '==== Sequence Command Output Log ====', ...
    sprintf('StartedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('SequenceName: %s', seqName), ...
    sprintf('StatusTarget: %s', normalize_to_char(statusText)), ...
    sprintf('Suffix: %s', normalize_to_char(suffix)), ...
    '---- begin captured output ----', ...
    ''};
txt = sprintf('%s\n', lines{:});
end

function txt = build_sequence_command_log_footer(statusText, errMsg)
lines = { ...
    '', ...
    '---- end captured output ----', ...
    sprintf('FinishedAt: %s', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    sprintf('Status: %s', normalize_to_char(statusText))};
if ~isempty(strtrim(normalize_to_char(errMsg)))
    lines{end + 1} = sprintf('Error: %s', normalize_to_char(errMsg)); %#ok<AGROW>
end
txt = sprintf('%s\n', lines{:});
end

function write_text_file_local(pathOut, txt)
[fid, msg] = fopen(pathOut, 'w');
if fid < 0
    warning('SmartT1:SequenceLogOpenFailed', 'Cannot open sequence command log "%s": %s', pathOut, msg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s', normalize_to_char(txt));
end

function out = sanitize_log_token(in)
out = regexprep(normalize_to_char(in), '[^a-zA-Z0-9_\-\.]', '_');
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
if isstruct(gmSEQ) && isfield(gmSEQ, 'SmartCustomSweepParam')
    gmSEQ = rmfield(gmSEQ, 'SmartCustomSweepParam');
end
clear_unspecified_optional_sweep_rows(seq, handlesMain);
fields = fieldnames(seq);
for i = 1:numel(fields)
    fieldName = fields{i};
    value = seq.(fieldName);

    if strcmp(fieldName, 'SmartCustomSweepParam')
        gmSEQ.SmartCustomSweepParam = value;
        continue;
    end

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

function clear_unspecified_optional_sweep_rows(seq, handlesMain)
optionalSweepControls = {'bSweep2', 'bSweep3'};
for iCtrl = 1:numel(optionalSweepControls)
    ctrlName = optionalSweepControls{iCtrl};
    if isfield(seq, ctrlName) || ~isfield(handlesMain, ctrlName)
        continue;
    end
    set_control_value(handlesMain.(ctrlName), 0);
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

function imagePath = save_main_figure(handlesMain, handlesAuto, runFileName, cfg, statusSuffix, fileNamePrefix, subfolderName)
imagePath = '';
saveFolder = cfg.paths.saveFolder;
if isfield(cfg, 'runtime') && isstruct(cfg.runtime) && ...
        isfield(cfg.runtime, 'runSaveFolder') && ~isempty(cfg.runtime.runSaveFolder)
    saveFolder = cfg.runtime.runSaveFolder;
end
if nargin >= 7
    relSub = normalize_to_char(subfolderName);
else
    relSub = '';
end
if ~isempty(relSub)
    saveFolder = fullfile(saveFolder, relSub);
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
    imagePath = '';
    return;
end
drawnow;
imwrite(getframe(mainFig).cdata, imagePath);
end

function subfolderName = choose_sequence_artifact_subfolder(seq, isRough)
subfolderName = '';
if nargin >= 2 && logical(isRough)
    subfolderName = default_intermediate_artifact_subfolder();
    return;
end
seqName = '';
if nargin >= 1 && isstruct(seq) && isfield(seq, 'name')
    seqName = normalize_to_char(seq.name);
end
if is_intermediate_sequence_name(seqName)
    subfolderName = default_intermediate_artifact_subfolder();
end
end

function tf = is_intermediate_sequence_name(seqName)
name = upper(strtrim(normalize_to_char(seqName)));
tf = any(strcmp(name, {'PICAL', 'PICAL_SG2', 'CALIPI'}));
end

function out = default_intermediate_artifact_subfolder()
out = 'intermediate_precal_rough';
end

function log_notion_sequence_event(seq, suffix, imagePath, stoppedByAutoGui)
global gSaveDataAve gmSEQ

ctx = [];
try
    if isappdata(0, 'V3_1_NOTION_UPLOAD_CONTEXT')
        ctx = getappdata(0, 'V3_1_NOTION_UPLOAD_CONTEXT');
    end
catch
    ctx = [];
end
if ~isstruct(ctx) || ~isfield(ctx, 'enabled') || ~logical(ctx.enabled)
    return;
end

spoolPath = strtrim(char(string(safe_struct_field(ctx, 'spoolPath', ''))));
if isempty(spoolPath)
    return;
end
queueLogPath = strtrim(char(string(safe_struct_field(ctx, 'queueLogPath', ''))));

seqName = '';
if isstruct(seq) && isfield(seq, 'name')
    seqName = normalize_to_char(seq.name);
end
if isempty(seqName) && isstruct(gmSEQ) && isfield(gmSEQ, 'name')
    seqName = normalize_to_char(gmSEQ.name);
end

saveString = '';
if isstruct(gSaveDataAve) && isfield(gSaveDataAve, 'file')
    saveString = extract_save_string_stem(gSaveDataAve);
elseif isstruct(gmSEQ) && isfield(gmSEQ, 'AnalysisSaveString')
    saveString = normalize_to_char(gmSEQ.AnalysisSaveString);
end

fit = struct();
fit.esrFreqAllMHz = [];
fit.rabiPiNs = NaN;
fit.rabiFreqMHz = NaN;
fit.t1Ms = NaN;
fit.t1RelErr = NaN;
fit.t1Model = '';
if isstruct(gmSEQ)
    if isfield(gmSEQ, 'ESRFitFreqAllMHz')
        fit.esrFreqAllMHz = safe_numeric_row(gmSEQ.ESRFitFreqAllMHz);
    end
    if isfield(gmSEQ, 'RabiFitPi')
        fit.rabiPiNs = normalize_to_numeric(gmSEQ.RabiFitPi, NaN);
    end
    if isfield(gmSEQ, 'RabiFitFreqMHz')
        fit.rabiFreqMHz = normalize_to_numeric(gmSEQ.RabiFitFreqMHz, NaN);
    end
    if isfield(gmSEQ, 'T1FitT1')
        fit.t1Ms = normalize_to_numeric(gmSEQ.T1FitT1, NaN);
    end
    if isfield(gmSEQ, 'T1FitRelErr')
        fit.t1RelErr = normalize_to_numeric(gmSEQ.T1FitRelErr, NaN);
    end
    if isfield(gmSEQ, 'T1FitModelUsed')
        fit.t1Model = normalize_to_char(gmSEQ.T1FitModelUsed);
    end
end

payload = struct();
payload.sequence_name = seqName;
payload.status = ternary_text(stoppedByAutoGui, 'stopped', 'finished');
payload.suffix = normalize_to_char(suffix);
payload.save_string = saveString;
payload.figure_path = normalize_to_char(imagePath);
payload.tb_step_index = normalize_to_numeric(safe_struct_field(ctx, 'tbStepIndex', NaN), NaN);
payload.b_item_index = normalize_to_numeric(safe_struct_field(ctx, 'bItemIndex', NaN), NaN);
payload.target_B_kG = normalize_to_numeric(safe_struct_field(ctx, 'targetBkG', NaN), NaN);
payload.B_set_G = normalize_to_numeric(safe_struct_field(ctx, 'bEstimateG', NaN), NaN);
payload.B_meas_G = normalize_to_numeric(safe_struct_field(gmSEQ, 'AnalysisMeasuredB', NaN), NaN);
payload.T_K = normalize_to_numeric(safe_struct_field(ctx, 'tSetK', NaN), NaN);
payload.run_root = normalize_to_char(safe_struct_field(ctx, 'runRoot', ''));
payload.fit = fit;

ev = struct();
ev.op = 'sequence_finished';
ev.parentPageKey = normalize_to_char(safe_struct_field(ctx, 'parentPageKey', ''));
ev.timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
ev.payload = payload;

[okSpool, msgSpool] = append_jsonl_event(spoolPath, ev);
if okSpool
    append_notion_queue_log_row(queueLogPath, 'queued', 'sequence_finished', seqName, saveString, payload.figure_path, 'queued by MATLAB');
else
    append_notion_queue_log_row(queueLogPath, 'error', 'sequence_finished', seqName, saveString, payload.figure_path, msgSpool);
end
end

function [ok, msg] = append_jsonl_event(spoolPath, ev)
ok = false;
msg = '';
[folderPath, ~, ~] = fileparts(spoolPath);
if ~isempty(folderPath) && exist(folderPath, 'dir') ~= 7
    [mkOk, mkMsg, mkId] = mkdir(folderPath);
    if ~mkOk
        msg = sprintf('Cannot create spool folder "%s": %s (%s)', folderPath, mkMsg, mkId);
        return;
    end
end
[fid, fopenMsg] = fopen(spoolPath, 'a');
if fid < 0
    msg = sprintf('Cannot open spool "%s": %s', spoolPath, fopenMsg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
fprintf(fid, '%s\n', jsonencode(ev));
ok = true;
end

function append_notion_queue_log_row(queueLogPath, status, op, seqName, saveString, figurePath, msg)
if isempty(queueLogPath)
    return;
end
[folderPath, ~, ~] = fileparts(queueLogPath);
if ~isempty(folderPath) && exist(folderPath, 'dir') ~= 7
    mkdir(folderPath);
end
needHeader = exist(queueLogPath, 'file') ~= 2;
[fid, fopenMsg] = fopen(queueLogPath, 'a');
if fid < 0
    warning('SmartT1:NotionQueueLogOpenFailed', 'Cannot open queue log "%s": %s', queueLogPath, fopenMsg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>
if needHeader
    fprintf(fid, 'timestamp,status,op,sequence_name,save_string,figure_path,message\n');
end
line = strjoin({ ...
    csv_quote(datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF')), ...
    csv_quote(normalize_to_char(status)), ...
    csv_quote(normalize_to_char(op)), ...
    csv_quote(normalize_to_char(seqName)), ...
    csv_quote(normalize_to_char(saveString)), ...
    csv_quote(normalize_to_char(figurePath)), ...
    csv_quote(normalize_to_char(msg))}, ',');
fprintf(fid, '%s\n', line);
end

function out = csv_quote(token)
raw = normalize_to_char(token);
raw = strrep(raw, '"', '""');
out = ['"' raw '"'];
end

function out = safe_numeric_row(v)
if isempty(v)
    out = [];
    return;
end
try
    vv = double(v(:)).';
    vv = vv(isfinite(vv));
    out = vv;
catch
    out = [];
end
end

function out = ternary_text(cond, a, b)
if logical(cond)
    out = a;
else
    out = b;
end
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

% Main GUI is already saved after each sequence in save_main_figure().
% Skip end-of-run main GUI save to avoid duplicate final snapshots.

try
    save_auto_gui_snapshot(handlesAuto, fullfile(saveFolder, 'AutoGUI_v2_1_Final.png'));
catch ME
    warning('SmartT1:FinalAutoGuiSaveFailed', 'Final auto GUI save failed: %s', ME.message);
end

try
    write_analysis_add_entry_snippet(saveFolder);
catch ME
    warning('SmartT1:AnalysisSnippetSaveFailed', 'Analysis snippet save failed: %s', ME.message);
end

try
    write_v2_run_summary_report(cfg);
catch ME
    warning('SmartT1:RunSummarySaveFailed', 'v2.2 run summary save failed: %s', ME.message);
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

function tag = format_t_set_tag(T_K)
if ~isfinite(T_K)
    tag = 'NAK';
    return;
end
val = num2str(T_K, '%.2f');
val = strrep(val, '-', 'm');
val = strrep(val, '.', 'p');
tag = [val 'K'];
end

function T_K = read_current_t_setpoint_from_v3_context()
T_K = NaN;
try
    if isappdata(0, 'V3_1_NOTION_UPLOAD_CONTEXT')
        ctxV3 = getappdata(0, 'V3_1_NOTION_UPLOAD_CONTEXT');
        T_K = normalize_to_numeric(safe_struct_field(ctxV3, 'tSetK', NaN), NaN);
    end
catch
    T_K = NaN;
end
end

function runFolder = read_run_save_folder_override()
runFolder = '';
try
    if isappdata(0, 'SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE')
        runFolder = char(string(getappdata(0, 'SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE')));
    end
catch
    runFolder = '';
end
end

function runFolder = create_run_save_folder(baseFolder, estimatedB_G, tSetK)
if nargin < 1 || isempty(baseFolder)
    baseFolder = pwd;
end
if nargin < 2
    estimatedB_G = NaN;
end
if nargin < 3
    tSetK = NaN;
end
if ~exist(baseFolder, 'dir')
    mkdir(baseFolder);
end

stamp = datestr(now, 'yyyymmdd_HHMMSS');
bTag = format_b_est_tag(estimatedB_G);
if isfinite(tSetK)
    tTag = format_t_set_tag(tSetK);
    runFolder = fullfile(baseFolder, ['Run_' bTag '_' tTag '_' stamp]);
else
    runFolder = fullfile(baseFolder, ['Run_' bTag '_' stamp]);
end
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

alignedOnly = filter_aligned_labels(measuredLabels);
if isempty(alignedOnly)
    return;
end

labels = {};
freqs = [];
for i = 1:numel(alignedOnly)
    lb = alignedOnly{i};
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
    set_display_control_string(handlesAuto, cfg.smart.ui.tags.display.roughT1, 'Rough: --');
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
        'RabiFitPi', 'RabiFitPiErr', ...
        'RabiFitPiHalf', 'RabiFitPiHalfErr', ...
        'RabiFitThreeHalfPi', 'RabiFitThreeHalfPiErr', ...
        'RabiFitFreqMHz', 'RabiFitFreqErrMHz', 'RabiFitContrastPct', ...
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

function init_analysis_export_state()
global gmSEQ
gmSEQ.AnalysisEntries = struct('date', {}, 'nArg', {}, 'group', {}, 'family', {}, 'sequence', {}, 'spin', {}, 'saveString', {});
gmSEQ.AnalysisMeasuredB = NaN;
gmSEQ.AnalysisDate = current_date_string();
gmSEQ.AnalysisSaveString = '';
end

function init_report_export_state(cfg)
global gmSEQ
if isempty(gmSEQ) || ~isstruct(gmSEQ)
    gmSEQ = struct();
end
gmSEQ.ReportRunStartedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
gmSEQ.ReportRunSaveFolder = current_run_save_folder(cfg);
gmSEQ.ReportDecisionEvents = struct('time', {}, 'kind', {}, 'message', {});
rootFolder = report_root_folder(cfg);
if isempty(rootFolder)
    return;
end
ensure_folder_exists_local(fullfile(rootFolder, 'spot'));
ensure_folder_exists_local(fullfile(rootFolder, 'measurements', 'final'));
ensure_folder_exists_local(fullfile(rootFolder, 'measurements', default_intermediate_artifact_subfolder()));
ensure_folder_exists_local(fullfile(rootFolder, 'pical'));
ensure_folder_exists_local(fullfile(rootFolder, 'failures'));
end

function set_analysis_measured_b(BG)
global gmSEQ
if isfinite(BG)
    gmSEQ.AnalysisMeasuredB = BG;
end
end

function append_analysis_entry_for_target(target, family)
global gmSEQ gSaveDataAve
if ~isstruct(target) || ~isfield(target, 'transition')
    return;
end
if nargin < 2 || isempty(family)
    family = 't1';
end

[seqName, spinLabel, ok] = map_transition_to_analysis_tokens(target.transition, family);
if ~ok
    return;
end

groupName = map_group_to_analysis_token(safe_struct_field(target, 'group', ''));
nArg = extract_ave_number_from_run_file(gSaveDataAve);
if ~isfinite(nArg)
    % Missing Ave_xxx token -> skip this entry.
    return;
end

entry = struct();
entry.date = current_date_string();
entry.nArg = nArg;
entry.group = groupName;
entry.family = normalize_to_char(family);
entry.sequence = seqName;
entry.spin = spinLabel;
entry.saveString = extract_save_string_stem(gSaveDataAve);
gmSEQ.AnalysisSaveString = entry.saveString;

if ~isfield(gmSEQ, 'AnalysisEntries') || ~isstruct(gmSEQ.AnalysisEntries)
    gmSEQ.AnalysisEntries = entry;
else
    gmSEQ.AnalysisEntries(end+1) = entry; %#ok<AGROW>
end
end

function append_analysis_entry_for_sij_all(target)
global gmSEQ gSaveDataAve
if ~isstruct(target)
    return;
end
nArg = extract_ave_number_from_run_file(gSaveDataAve);
if ~isfinite(nArg)
    return;
end

entry = struct();
entry.date = current_date_string();
entry.nArg = nArg;
entry.group = map_group_to_analysis_token(safe_struct_field(target, 'group', ''));
entry.family = 't1';
entry.sequence = 'T1_Sij_all';
entry.spin = 'all';
entry.saveString = extract_save_string_stem(gSaveDataAve);
gmSEQ.AnalysisSaveString = entry.saveString;

if ~isfield(gmSEQ, 'AnalysisEntries') || ~isstruct(gmSEQ.AnalysisEntries)
    gmSEQ.AnalysisEntries = entry;
else
    gmSEQ.AnalysisEntries(end+1) = entry; %#ok<AGROW>
end
end

function out = extract_save_string_stem(gSaveDataAve)
out = '';
if nargin < 1 || isempty(gSaveDataAve) || ~isstruct(gSaveDataAve) || ~isfield(gSaveDataAve, 'file')
    return;
end
raw = normalize_to_char(gSaveDataAve.file);
if isempty(raw)
    return;
end
[~, stem, ~] = fileparts(raw);
out = normalize_to_char(stem);
end

function nArg = extract_ave_number_from_run_file(gSaveDataAve)
nArg = NaN;
if nargin < 1 || isempty(gSaveDataAve) || ~isstruct(gSaveDataAve) || ~isfield(gSaveDataAve, 'file')
    return;
end
fileStr = normalize_to_char(gSaveDataAve.file);
if isempty(fileStr)
    return;
end

% Parse "...Ave_xxx..." token (case-insensitive); use last match if multiple.
tok = regexp(fileStr, '(?i)Ave[_-]?(\d+)', 'tokens');
if isempty(tok)
    return;
end
try
    nArg = str2double(tok{end}{1});
    if ~isfinite(nArg)
        nArg = NaN;
    else
        nArg = round(nArg);
    end
catch
    nArg = NaN;
end
end

function write_analysis_add_entry_snippet(saveFolder)
global gmSEQ
if ~isfield(gmSEQ, 'AnalysisEntries') || isempty(gmSEQ.AnalysisEntries)
    return;
end
if nargin < 1 || isempty(saveFolder)
    saveFolder = pwd;
end
if ~exist(saveFolder, 'dir')
    mkdir(saveFolder);
end

outFile = fullfile(saveFolder, 'analysis_add_entry_snippet.txt');
fid = fopen(outFile, 'w');
if fid < 0
    warning('SmartT1:AnalysisSnippetOpenFailed', 'Cannot open analysis snippet file: %s', outFile);
    return;
end
cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>

if isfield(gmSEQ, 'AnalysisMeasuredB') && isfinite(gmSEQ.AnalysisMeasuredB)
    fprintf(fid, 'B = %.6f;\n', gmSEQ.AnalysisMeasuredB);
else
    fprintf(fid, 'B = NaN; %% measured B unavailable\n');
end

entries = gmSEQ.AnalysisEntries;
for i = 1:numel(entries)
    e = entries(i);
    if ~isfield(e, 'sequence') || isempty(e.sequence) || ...
            ~isfield(e, 'spin') || isempty(e.spin)
        continue;
    end
    dStr = safe_struct_field(e, 'date', current_date_string());
    nArg = round(safe_struct_field(e, 'nArg', 0));
    gStr = safe_struct_field(e, 'group', 'Aligned');
    seqStr = e.sequence;
    spinStr = e.spin;
    fprintf(fid, 'data.add_entry(''%s'', %d, B, T, ''%s'', ''%s'', ''%s'');\n', ...
        dStr, nArg, gStr, seqStr, spinStr);
end
end

function [seqName, spinLabel, ok] = map_transition_to_analysis_tokens(transition, family)
seqName = '';
spinLabel = '';
ok = true;
if nargin < 2 || isempty(family)
    family = 't1';
end
cfg = config();
if isfield(cfg.smart, 'measurements') && isfield(cfg.smart.measurements, family) && ...
        isfield(cfg.smart.measurements.(family), 'sequenceByTransition') && ...
        isfield(cfg.smart.measurements.(family).sequenceByTransition, transition)
    seqName = cfg.smart.measurements.(family).sequenceByTransition.(transition);
end
switch normalize_to_char(transition)
    case 'SQ_0_TO_M1'
        if isempty(seqName), seqName = 'T1_S00_S01_S10'; end
        spinLabel = '0m1';
    case 'SQ_0_TO_P1'
        if isempty(seqName), seqName = 'T1_S00_S01_S10'; end
        spinLabel = '0p1';
    case 'DQ_M1_TO_P1'
        if isempty(seqName)
            if any(strcmpi(family, {'t2', 't2star'}))
                ok = false;
                return;
            end
            seqName = 'T1_S11_S1m1';
        end
        spinLabel = 'm1p1';
    otherwise
        ok = false;
end
end

function groupName = map_group_to_analysis_token(groupIn)
g = lower(normalize_to_char(groupIn));
if contains(g, 'off')
    groupName = 'OffAligned';
else
    groupName = 'Aligned';
end
end

function out = current_date_string()
v = datevec(now);
out = sprintf('%d-%d-%d', v(1), v(2), v(3));
end

function label = measurement_display_name_from_target(target)
label = 'T1';
if isstruct(target) && isfield(target, 'runFamilyDisplay') && ~isempty(target.runFamilyDisplay)
    label = normalize_to_char(target.runFamilyDisplay);
elseif isstruct(target) && isfield(target, 'runFamilyId')
    switch normalize_to_char(target.runFamilyId)
        case 't2'
            label = 'T2';
        case 't2star'
            label = 'T2*';
        otherwise
            label = 'T1';
    end
end
end

function prefix = measurement_file_prefix_from_target(target)
prefix = 'T1';
if isstruct(target) && isfield(target, 'runFamilyId')
    switch normalize_to_char(target.runFamilyId)
        case 't2'
            prefix = 'T2';
        case 't2star'
            prefix = 'T2Star';
        otherwise
            prefix = 'T1';
    end
end
end

function out = safe_struct_field(s, fieldName, defaultValue)
out = defaultValue;
if isstruct(s) && isfield(s, fieldName)
    out = s.(fieldName);
end
end

function update_precal_summary_display(handlesAuto, cfg, msg)
if ~isfield(cfg.smart.ui.tags, 'display') || ...
        ~isfield(cfg.smart.ui.tags.display, 'precalSummary')
    return;
end
tag = cfg.smart.ui.tags.display.precalSummary;
set_display_control_string(handlesAuto, tag, msg);
end

function update_rough_t1_display(handlesAuto, cfg, roughT1Ms, iTry, familyLabel)
if ~isfield(cfg.smart.ui.tags, 'display') || ...
        ~isfield(cfg.smart.ui.tags.display, 'roughT1')
    return;
end
if nargin < 5 || isempty(familyLabel)
    familyLabel = 'T1';
end
if nargin >= 4 && isfinite(iTry) && iTry >= 1
    msg = sprintf('Rough %s (try %d): %.4f ms', familyLabel, round(iTry), roughT1Ms);
else
    msg = sprintf('Rough %s: %.4f ms', familyLabel, roughT1Ms);
end
tag = cfg.smart.ui.tags.display.roughT1;
set_display_control_string(handlesAuto, tag, msg);
end

function update_rough_ratio_display(handlesAuto, cfg, edgeRatio, iTry, familyLabel)
if ~isfield(cfg.smart.ui.tags, 'display') || ...
        ~isfield(cfg.smart.ui.tags.display, 'roughT1')
    return;
end
if nargin < 5 || isempty(familyLabel)
    familyLabel = 'T2*';
end
if nargin >= 4 && isfinite(iTry) && iTry >= 1
    msg = sprintf('Rough %s ratio (try %d): %.4f', familyLabel, round(iTry), edgeRatio);
else
    msg = sprintf('Rough %s ratio: %.4f', familyLabel, edgeRatio);
end
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

function out = scalar_numeric_or_nan(v)
% Convert possibly empty/non-scalar/non-numeric input into one numeric scalar.
out = NaN;
if isempty(v)
    return;
end
if isnumeric(v) || islogical(v)
    vv = double(v(:));
    vv = vv(isfinite(vv));
    if ~isempty(vv)
        out = vv(1);
    end
    return;
end
if ischar(v) || isstring(v)
    tmp = str2double(char(string(v)));
    if isfinite(tmp)
        out = tmp;
    end
    return;
end
try
    tmp = str2double(char(string(v)));
    if isfinite(tmp)
        out = tmp;
    end
catch
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
