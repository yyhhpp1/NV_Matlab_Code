function T1_SemiAuto_Program(hObject, eventdata, handlesMain, handlesAuto)
% Smart v2.1 orchestration entry point.
% NOTE: T1_SemiAuto_Run.m is treated as core and is not modified here.

global gSaveDataAve gmSEQ

cfg = AutoPipelineConfig();
cfg.runtime = struct();
cfg.runtime.runSaveFolder = create_run_save_folder(cfg.paths.saveFolder);
if isfield(cfg.smart, 't1fit')
    gmSEQ.T1FitModel = cfg.smart.t1fit.model;
    gmSEQ.T1FitCfg = cfg.smart.t1fit;
end
ctx = build_execution_context(cfg, handlesAuto);
if stop_requested(handlesAuto)
    return;
end

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
Auto_LoadUserInputs(hObject, eventdata, handlesMain);
if stop_requested(handlesAuto)
    return;
end

predicted = estimate_resonance_centers(ctx.estimatedB_G, cfg.smart.physics);
allLabels = {'aligned_m1', 'aligned_p1', 'off_m1', 'off_p1'};
requiredLabels = collect_required_resonance_labels(ctx.targets);

freqMap = struct();
rabiCache = struct();
precal = struct('sg1PiNs', struct(), 'sg1FreqMHz', struct(), ...
    'sg2PiNs', struct(), 'sg2FreqMHz', struct());

if ctx.precal.enabled
    windows = plan_odmr_windows(requiredLabels, predicted, cfg.smart.odmr);
    disp(['[SmartT1] Precal required labels: ' strjoin(requiredLabels, ', ')]);
    disp(sprintf('[SmartT1] Planned ODMR windows: %d', numel(windows)));
    for iW = 1:numel(windows)
        if stop_requested(handlesAuto)
            return;
        end

        seq = build_odmr_sequence(windows(iW), ctx, handlesAuto, cfg);
        run_one_sequence(seq, handlesMain, handlesAuto, hObject, eventdata, cfg, ...
            sprintf(' [ODMR window %d/%d]', iW, numel(windows)));
        if stop_requested(handlesAuto)
            return;
        end

        [fitMap, ok] = fit_odmr_window_from_current_data(windows(iW), predicted, cfg.smart.odmr);
        if ~ok
            warning('SmartT1:ODMRWindowFitFallback', ...
                'Using predicted frequencies for failed ODMR window #%d.', iW);
        end
        freqMap = merge_freq_map(freqMap, fitMap);
    end

    freqMap = fill_missing_freqs(freqMap, allLabels, predicted);
    gmSEQ.SmartFreqMapGHz = freqMap;

    for iL = 1:numel(requiredLabels)
        label = requiredLabels{iL};
        fGHz = get_map_freq(freqMap, label);
        [rabiCache, piNs, fRMHz] = calibrate_rabi_path( ...
            'sg1', fGHz, ctx, handlesMain, handlesAuto, hObject, eventdata, cfg, rabiCache);
        precal.sg1PiNs.(label) = piNs;
        precal.sg1FreqMHz.(label) = fRMHz;
        if stop_requested(handlesAuto)
            return;
        end
    end

    p1Labels = collect_required_sg2_p1_labels(ctx.targets);
    for iL = 1:numel(p1Labels)
        label = p1Labels{iL};
        fGHz = get_map_freq(freqMap, label);
        [rabiCache, piNs, fRMHz] = calibrate_rabi_path( ...
            'sg2', fGHz, ctx, handlesMain, handlesAuto, hObject, eventdata, cfg, rabiCache);
        precal.sg2PiNs.(label) = piNs;
        precal.sg2FreqMHz.(label) = fRMHz;
        if stop_requested(handlesAuto)
            return;
        end
    end

    update_precal_summary_display(handlesAuto, cfg, ...
        build_precal_summary_text(freqMap, precal, allLabels, requiredLabels));
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

    [finalRange, roughInfo] = determine_t1_final_range( ...
        target, fSg1, fSg2, piSg1, piSg2, ctx, handlesMain, handlesAuto, hObject, eventdata, cfg);
    if stop_requested(handlesAuto)
        break;
    end
    finalSeq = build_t1_sequence(target, finalRange, fSg1, fSg2, piSg1, piSg2, ctx);
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

    statusText = sprintf(['%s: f_m1=%.6fGHz f_p1=%.6fGHz | ', ...
        'SG1 pi=%.1fns fR=%.2fMHz | SG2 pi=%.1fns fR=%.2fMHz | roughT1=%.3fms'], ...
        target.id, fDispM1, fDispP1, ...
        piSg1, freqSg1MHz, piSg2, freqSg2MHz, roughInfo.t1RoughMs);
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

ctx.power = cfg.smart.power;
ctx.power.odmr_dBm = read_ui_numeric(hAuto, cfg.smart.ui.tags.power.odmr, ...
    read_ui_numeric(hAuto, 'MWPowerESR', ctx.power.odmr_dBm));
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

windows = repmat(struct('fromGHz',0,'toGHz',0,'labels',{{}},'expectedPeakCount',0), 1, numel(clusters));
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
seq.fixPow = num2str(ctx.power.odmr_dBm);
seq.Repeat = num2str(max(1, round(ctx.precal.odmr.repeat)));
seq.Average = num2str(max(1, round(ctx.precal.odmr.average)));
seq.useSG2 = 0;
seq.bSweep2 = 0;
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

function [cache, piNs, rabiFreqMHz] = calibrate_rabi_path(pathName, freqGHz, ctx, hMain, hAuto, hObject, eventdata, cfg, cache)
if stop_requested(hAuto)
    piNs = NaN;
    rabiFreqMHz = NaN;
    return;
end

key = [pathName '_' strrep(num2str(freqGHz, '%.6f'), '.', 'p')];
if isfield(cache, key)
    piNs = cache.(key).piNs;
    rabiFreqMHz = cache.(key).rabiFreqMHz;
    return;
end

seq = struct();
if strcmp(pathName, 'sg2')
    seq.name = 'Rabi_SG2';
    seq.FROM1 = num2str(ctx.precal.rabi.start);
    seq.TO1 = num2str(ctx.precal.rabi.stop);
    seq.SweepNPoints = num2str(max(3, round(ctx.precal.rabi.nPoints)));
    seq.fixPow2 = num2str(ctx.power.rabi_sg2_dBm);
    seq.fixFreq2 = num2str(freqGHz, '%.8f');
    seq.Repeat = num2str(max(1, round(ctx.precal.rabi.repeat)));
    seq.Average = num2str(max(1, round(ctx.precal.rabi.average)));
    seq.useSG2 = 1;
else
    seq.name = 'Rabi';
    seq.FROM1 = num2str(ctx.precal.rabi.start);
    seq.TO1 = num2str(ctx.precal.rabi.stop);
    seq.SweepNPoints = num2str(max(3, round(ctx.precal.rabi.nPoints)));
    seq.fixPow = num2str(ctx.power.rabi_sg1_dBm);
    seq.fixFreq = num2str(freqGHz, '%.8f');
    seq.Repeat = num2str(max(1, round(ctx.precal.rabi.repeat)));
    seq.Average = num2str(max(1, round(ctx.precal.rabi.average)));
    seq.useSG2 = 0;
end

run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, ...
    sprintf(' [Rabi %s @ %.6fGHz]', upper(pathName), freqGHz));
if stop_requested(hAuto)
    piNs = NaN;
    rabiFreqMHz = NaN;
    return;
end

if stop_requested(hAuto)
    piNs = NaN;
    rabiFreqMHz = NaN;
    return;
end
FitRabi(hMain, hAuto, false);
global gmSEQ
piNs = safe_gm_field(gmSEQ, 'RabiFitPi', NaN);
rabiFreqMHz = safe_gm_field(gmSEQ, 'RabiFitFreqMHz', NaN);

cache.(key) = struct('piNs', piNs, 'rabiFreqMHz', rabiFreqMHz);
end

function [finalRange, roughInfo] = determine_t1_final_range(target, fSg1, fSg2, piSg1, piSg2, ctx, hMain, hAuto, hObject, eventdata, cfg)
roughInfo = struct('t1RoughMs', NaN, 'fitRelErr', NaN, 'nRuns', 0);
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

    [t1Ms, relErr] = estimate_t1_from_current_data(target.transition);
    roughInfo.t1RoughMs = t1Ms;
    roughInfo.fitRelErr = relErr;
    if isfinite(t1Ms)
        update_rough_t1_display(hAuto, cfg, t1Ms);
    end
    if isfinite(t1Ms)
        if strcmpi(ctx.rough.stopPolicy, 'first_good') && relErr <= ctx.rough.fitRelErrThreshold
            break;
        end
    end

    % Retry policy: keep start fixed, only extend stop to 2*T1 (ms->ns).
    if isfinite(t1Ms) && t1Ms > 0
        span = 2 * t1Ms * 1e6;
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

if ~isfinite(roughInfo.t1RoughMs)
    finalRange = [start0, stop0];
    return;
end

% Policy:
% 1) Keep start fixed.
% 2) If stop is within [start+1.5*T1, start+3*T1], keep stop.
% 3) Otherwise set stop to start+2*T1.
stopMin = start0 + ctx.rough.minSpanFactor * roughInfo.t1RoughMs * 1e6;
stopMax = start0 + ctx.rough.maxSpanFactor * roughInfo.t1RoughMs * 1e6;
stopTarget = start0 + 2 * roughInfo.t1RoughMs * 1e6;

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

function [t1Ms, relErr] = estimate_t1_from_current_data(transition)
global gmSEQ
t1Ms = NaN;
relErr = inf;

if ~isfield(gmSEQ, 'signal') || isempty(gmSEQ.signal)
    return;
end

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1));
if isempty(signal)
    return;
end

    % gmSEQ.SweepParam is programmed in ns from GUI/main sequence fields.
    % fit_T1_func expects x in ms, so convert directly ns->ms here instead
    % of using gmSEQ.ScaleT (which is display-unit dependent).
    x = double(gmSEQ.SweepParam(1:size(signal, 2))) * 1e-6;
if numel(x) < 6
    return;
end

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
    valid = isfinite(x) & isfinite(y);
    x = x(valid);
    y = y(valid);
    if numel(x) < 6
        return;
    end

    [popt, perr] = fit_T1_func(x, y);
    rate = popt(1);
    if isfinite(rate) && rate > 0
        t1Ms = 1 / rate;
        relErr = perr(1) / max(abs(rate), eps);
    end
catch
    t1Ms = NaN;
    relErr = inf;
end
end

function seq = build_t1_sequence(target, range, fSg1, fSg2, piSg1, piSg2, ctx)
tStart = range(1);
tStop = range(2);
n = max(3, round(target.t1.nPoints));
n1 = n;
n2 = 0;
split = tStart + (tStop - tStart)/4;

if ctx.nonuniform
    n1 = max(2, ceil(n/2));
    n2 = max(1, floor(n/2));
    [split, tStop] = align_nonuniform_grid(tStart, split, tStop, n1, n2);
else
    tStop = align_stop_to_integer_points(tStart, tStop, n);
end

seq = struct();
switch target.transition
    case {'SQ_0_TO_M1', 'SQ_0_TO_P1'}
        seq.name = 'T1_S00_S01_S10';
        seq.useSG2 = 0;
        if ctx.precal.enabled
            seq.fixPow = num2str(ctx.power.rabi_sg1_dBm);
            seq.fixFreq = num2str(fSg1, '%.8f');
            seq.fixPow2 = num2str(ctx.power.rabi_sg2_dBm);
            if isfinite(piSg1) && piSg1 > 0
                seq.pi = num2str(piSg1, '%.0f');
                seq.halfpi = num2str(piSg1 / 2, '%.0f');
            end
        end
    otherwise
        seq.name = 'T1_S11_S1m1';
        seq.useSG2 = 1;
        if ctx.precal.enabled
            seq.fixPow = num2str(ctx.power.rabi_sg1_dBm);
            seq.fixFreq = num2str(fSg1, '%.8f');
            seq.fixPow2 = num2str(ctx.power.rabi_sg2_dBm);
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

function run_one_sequence(seq, hMain, hAuto, hObject, eventdata, cfg, suffix)
global gSaveDataAve
if stop_requested(hAuto)
    return;
end

apply_sequence_to_main_gui(seq, hMain);
if stop_requested(hAuto)
    return;
end

Auto_LoadUserInputs(hObject, eventdata, hMain);
if stop_requested(hAuto)
    return;
end

T1_SemiAuto_Run(hObject, eventdata, hMain, hAuto);
if stop_requested(hAuto)
    return;
end

fileNamePrefix = '';
if contains(lower(normalize_to_char(suffix)), '[rough t1')
    fileNamePrefix = 'Rough_T1_';
end

save_and_maybe_upload_main_figure(hMain, hAuto, gSaveDataAve.file, cfg, ...
    ['. Current sequence is finished.' suffix], fileNamePrefix);
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

function save_and_maybe_upload_main_figure(handlesMain, handlesAuto, runFileName, cfg, statusSuffix, fileNamePrefix)
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

imwrite(getframe(handlesMain.figure1).cdata, imagePath);

% Slack upload is optional and should be skipped when disabled.
enableSlack = false;
if isfield(handlesAuto, 'slackUploadFlag')
    hSlackFlag = handlesAuto.slackUploadFlag;
    if isgraphics(hSlackFlag, 'uicontrol') && isprop(hSlackFlag, 'Value')
        enableSlack = logical(get(hSlackFlag, 'Value'));
    end
end
if ~enableSlack
    return;
end

message = '';
if isfield(handlesAuto, 'slackUploadText')
    hSlackText = handlesAuto.slackUploadText;
    if isgraphics(hSlackText, 'uicontrol') && isprop(hSlackText, 'String')
        message = normalize_to_char(get(hSlackText, 'String'));
    end
end
message = [message statusSuffix];
scriptFolder = cfg.paths.slackScriptFolder;
keepCount = int32(cfg.slack.defaultKeep);

try
    if count(py.sys.path, scriptFolder) == 0
        insert(py.sys.path, int32(0), scriptFolder);
    end
    py.slack_upload_v2.upload_and_cleanup(imagePath, message, keepCount);
catch ME
    warning('SmartT1:SlackUploadFailed', 'Slack upload failed: %s', ME.message);
end
end

function runFolder = create_run_save_folder(baseFolder)
if nargin < 1 || isempty(baseFolder)
    baseFolder = pwd;
end
if ~exist(baseFolder, 'dir')
    mkdir(baseFolder);
end

stamp = datestr(now, 'yyyymmdd_HHMMSS');
runFolder = fullfile(baseFolder, ['Run_' stamp]);
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

function msg = build_precal_summary_text(freqMap, precal, labels, measuredLabels)
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
    if ~isfinite(fGHz) || ~isfinite(pi1)
        lines{i} = sprintf('%s: not measured', label);
    elseif isfinite(pi2)
        lines{i} = sprintf('%s: f=%.6f GHz, pi=%.1f ns (SG1), %.1f ns (SG2)', label, fGHz, pi1, pi2);
    else
        lines{i} = sprintf('%s: f=%.6f GHz, pi=%.1f ns', label, fGHz, pi1);
    end
end
msg = strjoin(lines, sprintf('\n'));
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
