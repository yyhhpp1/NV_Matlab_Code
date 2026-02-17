function cfg = config()
% Smart T1 configuration for AutoRunSequences_v2_1.

cfg = struct();

cfg.paths.saveFolder = 'C:\Users\dilution_fridge_2\Desktop\T1_SemiAuto_Saves';

% Plot routing used by t1_semi_auto_run (do not modify core runner).
cfg.plotting = struct();
cfg.plotting.maxCtrToPlot = 24;
cfg.plotting.default = struct('plotFunction', 'plotting.plot_data', 'liveFitFunction', '');
cfg.plotting.rules = { ...
    'ODMR', 'plotting.plot_rabi_data', 'fitting.fit_esr'; ...
    'Rabi', 'plotting.plot_rabi_data', 'fitting.fit_rabi'; ...
    'Rabi_SG2', 'plotting.plot_rabi_data', 'fitting.fit_rabi'; ...
    'T1_S00_S01_S10', 'plotting.plot_t1_data_method4', ''; ...
    'T1_S11_S1m1', 'plotting.plot_t1_data_method3', '' ...
};

cfg.smart = struct();
cfg.smart.enabled = true;

cfg.smart.physics = struct();
cfg.smart.physics.zeroFieldGHz = 2.877;
cfg.smart.physics.gammaMHzPerG = 2.8025;

% ODMR window planner.
cfg.smart.odmr = struct();
cfg.smart.odmr.splitThresholdMHz = 200;
cfg.smart.odmr.windowMarginMHz = 40;
cfg.smart.odmr.minPoints = 51;
cfg.smart.odmr.maxPoints = 601;
cfg.smart.odmr.pointsPerMHz = 2.0;
cfg.smart.odmr.minPeakSepMHz = 5;
cfg.smart.odmr.maxRetriesPerWindow = 2;
cfg.smart.odmr.retryExpandFactor = 1.6;
cfg.smart.odmr.hardMinGHz = 0.7;
cfg.smart.odmr.hardMaxGHz = 6;

% Rough-scan controls.
cfg.smart.rough = struct();
cfg.smart.rough.enabled = true;
cfg.smart.rough.repeat = 1;
cfg.smart.rough.average = 1;
cfg.smart.rough.nPoints = 0; % 0 => use target/user nPoints
cfg.smart.rough.maxRetries = 2;
cfg.smart.rough.fitRelErrThreshold = 0.6;
cfg.smart.rough.stopPolicy = 'max_retries'; % first_good | max_retries
cfg.smart.rough.stopFactor = 3.0; % auto-correct stop target = start + stopFactor*T1
cfg.smart.rough.minSpanFactor = 2;
cfg.smart.rough.maxSpanFactor = 3.5;
cfg.smart.rough.maxStopNs = 1e9+1000; % hard cap for rough/final stop (ns). inf for no cap

% T1 fit model selector.
% model options:
%   'single_exp'     => A*exp(-r*x)
%   'stretched_exp'  => A*exp(-(r*x)^n)
cfg.smart.t1fit = struct();
cfg.smart.t1fit.model = 'stretched_exp';
cfg.smart.t1fit.nLower = 0.1;
cfg.smart.t1fit.nUpper = 1.0;
cfg.smart.t1fit.amplitudeUpper = 1.0;

% Rabi fit selector.
% model options:
%   'cos'      => A*cos(2*pi*f*x + phi) + 1 - A
%   'cos_exp'  => A*exp(-x/tau)*cos(2*pi*f*x + phi) + 1 - A
cfg.smart.rabiFit = struct();
cfg.smart.rabiFit.model = 'cos_exp';
cfg.smart.rabiFit.minPointsCos = 4;      % nParam(3)+1
cfg.smart.rabiFit.minPointsCosExp = 5;   % nParam(4)+1

% ESR fit guard.
cfg.smart.esrFit = struct();
cfg.smart.esrFit.minPoints = 5;          % nParam(4)+1

% Precalibration powers.
cfg.smart.power = struct();
cfg.smart.power.odmr_dBm = -15;
cfg.smart.power.rabi_dBm = -10;
cfg.smart.power.rabi_sg1_dBm = cfg.smart.power.rabi_dBm;
cfg.smart.power.rabi_sg2_dBm = cfg.smart.power.rabi_dBm;

% Unified precalibration scan settings.
cfg.smart.precal = struct();
cfg.smart.precal.rabi = struct('start', 0, 'stop', 400, 'nPoints', 40, 'repeat', 5, 'average', 5);
cfg.smart.precal.odmr = struct('repeat', 5, 'average', 5, 'pointsPerMHz', cfg.smart.odmr.pointsPerMHz);

% UI tag map (if tags exist in .fig, they override defaults below).
cfg.smart.ui = struct();
cfg.smart.ui.tags = build_ui_tag_map();

% Default target table (used when GUI checkboxes are not yet available).
cfg.smart.targets = default_target_table();

% Legacy fallback: old UI B field estimate.
cfg.smart.defaultEstimatedB_G = 100;

end

function t = build_ui_tag_map()
t = struct();

% Selection checkboxes.
t.sel.aligned_sq_m1 = 'chk_aligned_sq_m1';
t.sel.aligned_sq_p1 = 'chk_aligned_sq_p1';
t.sel.aligned_dq = 'chk_aligned_dq';
t.sel.off_sq_m1 = 'chk_off_sq_m1';
t.sel.off_sq_p1 = 'chk_off_sq_p1';
t.sel.off_dq = 'chk_off_dq';

% Global inputs.
t.input.estimatedB = 'edit_estimated_B_G';
t.input.nonuniform = 'chk_smart_point_distribution';

% Rough panel.
t.rough.enable = 'chk_enable_rough_scan';
t.rough.repeat = 'edit_rough_repeat';
t.rough.average = 'edit_rough_average';
t.rough.nPoints = 'edit_rough_npts';
t.rough.maxRetries = 'edit_rough_max_retries';
t.rough.fitRelErr = 'edit_rough_fit_relerr';
t.rough.stopPolicy = 'popup_rough_stop_policy';
t.rough.stopFactor = 'edit_rough_stop_factor';

% Precalibration powers.
t.power.odmr = 'edit_odmr_power';
t.power.rabi = 'edit_rabi_power';
t.power.rabiSg1 = 'edit_rabi_sg1_power';
t.power.rabiSg2 = 'edit_rabi_sg2_power';

% Unified precalibration scan settings.
t.precal.enable = 'chk_enable_precal';
t.precal.rabi.start = 'edit_precal_rabi_start';
t.precal.rabi.stop = 'edit_precal_rabi_stop';
t.precal.rabi.nPoints = 'edit_precal_rabi_npts';
t.precal.rabi.repeat = 'edit_precal_rabi_repeat';
t.precal.rabi.average = 'edit_precal_rabi_average';
t.precal.odmr.repeat = 'edit_precal_odmr_repeat';
t.precal.odmr.average = 'edit_precal_odmr_average';
t.precal.odmr.pointsPerMHz = 'edit_precal_odmr_points_per_mhz';

% Unified display fields.
t.display.precalSummary = 'txt_precal_summary';
t.display.roughT1 = 'txt_rough_t1_ms';

% Per-target T1 fields.
t.t1.aligned_sq_m1 = target_t1_tags('aligned_sq_m1');
t.t1.aligned_sq_p1 = target_t1_tags('aligned_sq_p1');
t.t1.aligned_dq = target_t1_tags('aligned_dq');
t.t1.off_sq_m1 = target_t1_tags('off_sq_m1');
t.t1.off_sq_p1 = target_t1_tags('off_sq_p1');
t.t1.off_dq = target_t1_tags('off_dq');

% Per-target status display text tags.
t.status.aligned_sq_m1 = 'txt_status_aligned_sq_m1';
t.status.aligned_sq_p1 = 'txt_status_aligned_sq_p1';
t.status.aligned_dq = 'txt_status_aligned_dq';
t.status.off_sq_m1 = 'txt_status_off_sq_m1';
t.status.off_sq_p1 = 'txt_status_off_sq_p1';
t.status.off_dq = 'txt_status_off_dq';
end

function out = target_t1_tags(prefix)
out = struct();
out.start = ['edit_' prefix '_start'];
out.stop = ['edit_' prefix '_stop'];
out.nPoints = ['edit_' prefix '_npts'];
out.repeat = ['edit_' prefix '_repeat'];
out.average = ['edit_' prefix '_average'];
end

function targets = default_target_table()
targets = [ ...
    mk_target('aligned_sq_m1', 'aligned', 'SQ_0_TO_M1', true,  0.005, 5, 40, 5, 10), ...
    mk_target('aligned_sq_p1', 'aligned', 'SQ_0_TO_P1', false, 0.005, 5, 40, 5, 10), ...
    mk_target('aligned_dq',    'aligned', 'DQ_M1_TO_P1', false, 0.005, 8, 50, 5, 10), ...
    mk_target('off_sq_m1',     'off_aligned', 'SQ_0_TO_M1', false, 0.005, 5, 40, 5, 10), ...
    mk_target('off_sq_p1',     'off_aligned', 'SQ_0_TO_P1', false, 0.005, 5, 40, 5, 10), ...
    mk_target('off_dq',        'off_aligned', 'DQ_M1_TO_P1', false, 0.005, 8, 50, 5, 10) ...
];
end

function t = mk_target(id, group, transition, enabled, tStart, tStop, nPoints, repeat, average)
t = struct();
t.id = id;
t.group = group;
t.transition = transition;
t.enabled = enabled;
t.t1 = struct( ...
    'start', tStart, ...
    'stop', tStop, ...
    'nPoints', nPoints, ...
    'repeat', repeat, ...
    'average', average);
end
