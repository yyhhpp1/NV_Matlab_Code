# AutoRunSequences_v2_1

Smart semi-automated NV T1 workflow with:

- target-based measurement selection (`aligned/offaligned` x `SQ m1 / SQ p1 / DQ`)
- ODMR window planning based on estimated resonances
- optional precalibration (`ODMR -> Rabi / Rabi_SG2`)
- rough-T1-driven stop-time correction
- final T1 execution through the existing base runner

This README is written as an operational memory document: if you read only this file later, you should be able to reconstruct how v2.1 works and where to modify it.

## 1. Scope And Constraints

- v2.1 is focused on one-shot smart T1 execution for a fixed environment (B/T already set externally).
- Outer loops over B/T are intentionally out of scope in v2.1.
- Core experimental runner is **not redesigned**:
  - `t1_semi_auto_run.m` is used as-is and treated as base code.
- v2.1 orchestration layer is in:
  - `t1_semi_auto_program.m`
  - `config.m`
  - `T1_SemiAuto_ParamInput_v2_1.m` + `.fig`
- Canonical implementation folders:
  - `+plotting/` for all plotting functions (snake_case)
  - `+fitting/` for all fitting functions (snake_case)
- Root `Plot*.m`, `Fit*.m`, `fit_T1*.m` are compatibility wrappers.
- Legacy entrypoint wrappers are kept for compatibility:
  - `T1_SemiAuto_Program.m` -> `t1_semi_auto_program.m`
  - `T1_SemiAuto_Run.m` -> `t1_semi_auto_run.m`
  - `Auto_LoadUserInputs.m` -> `auto_load_user_inputs.m`
  - `AutoPipelineConfig.m` -> `config.m`

## 2. Supported Sequence Set

v2.1 smart logic uses only:

- `ODMR`
- `Rabi`
- `Rabi_SG2`
- `T1_S00_S01_S10` (SQ paths)
- `T1_S11_S1m1` (DQ path)

Plot/live-fit routing is config-driven via `cfg.plotting` and dispatched by `+autoplot/dispatch.m`.

## 3. High-Level Pipeline

Entry point:

- `t1_semi_auto_program(hObject, eventdata, handlesMain, handlesAuto)`

Execution order:

1. Load cfg from `config.m`.
2. Push T1 fit model settings into `gmSEQ`:
   - `gmSEQ.T1FitModel`
   - `gmSEQ.T1FitCfg`
3. Build execution context from GUI + cfg defaults.
4. Apply one-time preset fields (`readout`, `CtrGateDur`) if present.
5. Predict resonance centers from estimated B (full matrix model).
6. Determine required resonance labels from selected targets.
7. If precalibration enabled:
   - plan ODMR windows for selected labels (or all 4 labels if `cfg.smart.precal.forceMeasureAllFreqs=true`)
   - run ODMR windows iteratively
   - after first fitted ODMR window, backout refined B and re-plan remaining windows from refined prediction
   - fit peaks from measured data
   - fill missing peaks with prediction
   - run MW calibration for required labels:
   - if `cfg.smart.precal.calipi.enabled=true`: run one `PiCal`/`PiCal_SG2` power sweep at target pulse length, fit local quadratic near minimum to pick power (with max-power safety cap), then run `Rabi`/`Rabi_SG2` at that power to get final pi
   - else: run legacy fixed-power `Rabi`/`Rabi_SG2`
   - update unified precal summary display
8. If precalibration disabled:
   - skip ODMR/Rabi
   - use predicted map internally
   - do not overwrite T1 MW fields in sequence builder
9. For each selected target:
   - resolve frequencies (`fSg1`, `fSg2`)
   - run rough T1 policy to determine final range
   - rough fit can use current + previous rough tries (combined fit)
   - run final T1 sequence
   - update optional per-target status text

Stop checks (`stop_requested`) are inserted throughout pipeline boundaries.

## 4. Target Model

Targets are fixed to 6 IDs (`cfg.smart.targets`):

- `aligned_sq_m1` -> group `aligned`, transition `SQ_0_TO_M1`
- `aligned_sq_p1` -> group `aligned`, transition `SQ_0_TO_P1`
- `aligned_dq` -> group `aligned`, transition `DQ_M1_TO_P1`
- `off_sq_m1` -> group `off_aligned`, transition `SQ_0_TO_M1`
- `off_sq_p1` -> group `off_aligned`, transition `SQ_0_TO_P1`
- `off_dq` -> group `off_aligned`, transition `DQ_M1_TO_P1`

Each target has its own T1 parameter set:

- `start`, `stop`, `nPoints`, `repeat`, `average`

Only selected targets (`enabled=1`) are run.

## 5. Resonance Prediction (Important)

v2.1 uses a **full spin-1 Hamiltonian solve** (not simple angular projection) for estimated centers:

- aligned: `cos(theta)=1`
- off-axis group: `cos(theta)=-1/3`

Implementation:

- `estimate_resonance_centers`
- `solve_nv_resonances_full_matrix`

Output labels:

- `aligned_m1`, `aligned_p1`, `off_m1`, `off_p1`

## 6. ODMR Window Planning

Window planner:

- `plan_odmr_windows(labels, predicted, cfg.smart.odmr)`

Behavior:

- builds windows only around required labels
- sorts predicted centers
- clusters by separation threshold:
  - if adjacent gap `<= splitThresholdMHz`, keep in same cluster/window
  - else split into separate windows
- each window includes `windowMarginMHz` on both sides
- clips to hard bounds `[hardMinGHz, hardMaxGHz]`
- each window tracks expected peak count = number of labels in cluster

Default ODMR cfg (`config.m`):

- `splitThresholdMHz = 200`
- `windowMarginMHz = 40`
- `minPoints = 51`
- `maxPoints = 601`
- `pointsPerMHz = 2.0`
- `minPeakSepMHz = 5`
- `hardMinGHz = 0.7`
- `hardMaxGHz = 6`

Note:

- `maxRetriesPerWindow` and `retryExpandFactor` are present in cfg, but current code path does not actively use them for iterative window refits.

## 7. ODMR Peak Extraction

For each ODMR run:

- read current data from `gmSEQ`
- smooth trace (`movmean`)
- find local minima candidates
- enforce min spacing (`minPeakSepMHz`)
- assign candidate frequencies to expected labels by nearest predicted center

If fit/assignment fails:

- window falls back to predicted centers for missing labels via `fill_missing_freqs`.

## 8. Precalibration (ODMR + MW Calibration)

Controlled by GUI checkbox:

- tag: `chk_enable_precal`

If enabled:

- SG1 calibration is run for all required labels.
- SG2 calibration is run only for p1 labels needed by DQ targets.
- optional ODMR-only full-peak check via `cfg.smart.precal.forceMeasureAllFreqs`.
- final T1 sequences use the same label-based SG power rule as calibration (including `sq_p1_calibration_boost_dB` when applicable).
- results stored in:
  - `precal.sg1PiNs`, `precal.sg1FreqMHz`
  - `precal.sg2PiNs`, `precal.sg2FreqMHz`
  - `precal.sg1PowDbm`, `precal.sg2PowDbm`
- unified summary display written to `txt_precal_summary`.
- if outermost measured ODMR peaks exist, summary appends `B(aligned from outermost)=... G`.

If disabled:

- no ODMR or Rabi is run
- summary display shows disabled status
- T1 builder leaves MW fix fields unchanged so main GUI settings remain in effect.

## 9. SG Frequency/PI Routing Rules

Frequency mapping (`resolve_target_freqs`):

- SQ m1: `fSg1=f_m1`, `fSg2=f_m1`
- SQ p1: `fSg1=f_p1`, `fSg2=f_p1`
- DQ: `fSg1=f_m1`, `fSg2=f_p1`

T1 sequence mapping:

- SQ transitions use sequence `T1_S00_S01_S10`
- DQ transition uses `T1_S11_S1m1`
- for DQ with precal enabled:
  - `fixFreq = m1`
  - `fixFreq2 = p1`
  - `DEERpi` comes from SG2 p1 pi (fallback SG1 p1 if SG2 unavailable)

## 10. Rough T1 Policy

Function:

- `determine_t1_final_range(...)`

Key rules implemented:

- start is never reduced below 0 and is kept fixed by policy
- rough scan can override point count via `edit_rough_npts`
- each rough retry runs real T1 sequence
- rough fit can use aggregated data from previous tries + current try
- previous rough-try points are overlaid in gray markers
- combined rough fit is overlaid as a dashed line
- latest rough result is displayed immediately:
  - `txt_rough_t1_ms = "Rough T1: xxx ms"` (overwrites previous)
- retry span update uses `stopFactor*T1rough` (ms -> ns)
- span is rounded to nearest 1000 (time unit used by sequence fields, ns in this setup)
- stop is aligned so sweep points remain integer-grid-consistent where possible
- optional cap:
  - `cfg.smart.rough.maxStopNs` clips rough and final stop

Final correction rule after rough fit:

- compute window:
  - lower bound = `start + minSpanFactor*T1rough`
  - upper bound = `start + maxSpanFactor*T1rough`
- if original stop is inside this window -> keep stop
- otherwise -> set stop to `start + stopFactor*T1rough`
- when auto-correcting stop:
  - round span to nearest 1000
  - align stop to integer-point grid
- do not change `nPoints`

Logs are emitted for stop corrections and clip events.

## 11. Nonuniform Point Distribution

Controlled by:

- `chk_smart_point_distribution`

When enabled:

- first quarter of span gets half the points
- remaining three-quarters gets half the points
- uses:
  - `n1 = ceil(n/2)`
  - `n2 = floor(n/2)`
- total span is rounded to nearest 1000 first
- split/stop are solved against integer-step constraints for both segments
- if exact rounded-span solve is impossible, stop is nudged slightly to enforce integer-point grids.

When disabled:

- single linear segment from start to aligned stop.

## 12. Units

Important unit handling:

- T1 sequence fields (`start/stop`) are treated as ns in this workflow.
- Rough-T1 fit converts `gmSEQ.SweepParam` ns -> ms before fitting.
- `fitting.fit_t1` expects x in ms.
- ODMR frequencies are GHz.
- Rabi pi is ns.

## 13. T1 Fit Models

Selector in cfg:

- `cfg.smart.t1fit.model = 'single_exp'` or `'stretched_exp'`

Implemented models:

- single exponential:
  - `y = A * exp(-r*x)`
  - params `[r, A]`
- stretched exponential:
  - `y = A * exp(-(r*x)^n)`
  - params `[r, A, n]`
  - bounds use `cfg.smart.t1fit.nLower/nUpper`

Files:

- `+fitting/fit_t1.m` (dispatcher + status)
- `+fitting/fit_t1_stretched.m` (stretched model)

Fit guards:

- single model requires at least 3 valid points
- stretched model requires at least 4 valid points
- if insufficient points or fit failure:
  - returns empty fit curve
  - stores status in `gmSEQ.T1FitLastStatus`
  - plotting shows informative legend text

Robustness details:

- covariance uses `pinv(full(J'*J))` to avoid sparse/rcond issues
- initial guess and amplitude bounds are auto-sanitized.

## 14. Plot Routing

Config is in `cfg.plotting`:

- per-sequence plot function
- optional live fit function

Dispatcher:

- `+autoplot/dispatch.m`

Behavior:

- fallback to default plot function if missing
- warn once per missing/failing function key
- skip plotting when `ctrN > maxCtrToPlot`

Default v2.1 mapping:

- `ODMR` -> `plotting.plot_rabi_data` + `fitting.fit_esr`
- `Rabi` -> `plotting.plot_rabi_data` + `fitting.fit_rabi`
- `Rabi_SG2` -> `plotting.plot_rabi_data` + `fitting.fit_rabi`
- `T1_S00_S01_S10` -> `plotting.plot_t1_data_method4`
- `T1_S11_S1m1` -> `plotting.plot_t1_data_method3`

## 15. Program Stop Behavior

Stop button callback (`pushbutton_stopProg_Callback`) does:

- GUI stop flag: `pushbutton_stopProg.UserData = 1`
- global run flags:
  - `gmSEQ.bGo = 0`
  - `gmSEQ.bGoAfterAvg = 0`
  - `gmSEQ.bExp = 0`

`t1_semi_auto_program` checks stop state before/after major stages.
`t1_semi_auto_run` loop checks `gmSEQ.bGo`/`gmSEQ.bGoAfterAvg` and exits current acquisition loop at the next check.

## 16. Figure Saving

After each sequence run (`run_one_sequence`):

- GUI figure is saved inside a per-run timestamp folder under `cfg.paths.saveFolder`
- run folder name includes estimated field from GUI, e.g. `Run_120p00G_YYYYMMDD_HHMMSS`
- if suffix indicates rough T1, filename gets `Rough_T1_` prefix
- rough tries are re-saved after rough overlays are drawn (previous points + combined fit)
- at run end, final snapshots are also written:
  - `MainGUI_Final.png`
  - `AutoGUI_v2_1_Final.png`

## 16.1 GUI Rewrite Behavior

- Main experiment GUI is rewritten per sequence step via `apply_sequence_to_main_gui(...)`.
- Auto-run parameter GUI (`T1_SemiAuto_ParamInput_v2_1`) is not rewritten with corrected rough stop values.

## 17. GUI State Persistence

GUI state is restored on open and saved on close:

- file: `AutoRunSequences_v2_1/T1_SemiAuto_ParamInput_v2_1_state.mat`
- path derived from `mfilename('fullpath')` so it stays in v2_1 folder

Saved fields:

- all uicontrol `String`/`Value` entries in the v2.1 param GUI handles struct.

## 18. GUI Tag Reference (Backend-Critical)

Authoritative map is generated in `config.m` (`build_ui_tag_map`).
Detailed checklist is in:

- `GUI_ELEMENTS_v2_1.md`

Most critical tags:

- run control:
  - `pushbutton_startProg`
  - `pushbutton_stopProg`
- target checkboxes:
  - `chk_aligned_sq_m1`, `chk_aligned_sq_p1`, `chk_aligned_dq`
  - `chk_off_sq_m1`, `chk_off_sq_p1`, `chk_off_dq`
- rough:
  - `chk_enable_rough_scan`, `edit_rough_npts`, `edit_rough_repeat`,
    `edit_rough_average`, `edit_rough_max_retries`, `edit_rough_fit_relerr`,
    `popup_rough_stop_policy`, `edit_rough_stop_factor`
- precal:
  - `chk_enable_precal`, `edit_odmr_power`, `edit_rabi_power`
  - `edit_precal_rabi_start/stop/npts/repeat/average`
  - `edit_precal_odmr_repeat/average/points_per_mhz`
  - `chk_precal_find_power_for_pi`
  - `edit_precal_target_pi_ns`
  - `edit_precal_power_start_dbm`, `edit_precal_power_stop_dbm`, `edit_precal_power_npts`
- displays:
  - `txt_precal_summary`
  - `txt_rough_t1_ms`

Per-target T1 input tags are also defined and consumed for all 6 targets.

## 19. Config Reference (Current Defaults)

See `config.m` for exact values. Main sections:

- `cfg.paths`
  - `saveFolder`
- `cfg.plotting`
  - `maxCtrToPlot`, `default`, `rules`
- `cfg.smart.physics`
  - `zeroFieldGHz`, `gammaMHzPerG`
- `cfg.smart.odmr`
  - split/margin/points/spacing/hard bounds
  - first-window B refinement knobs:
  - `refineBFromFirstWindow`, `bSearchMinG`, `bSearchMaxG`, `maxBBackoutResidualMHz`, `maxBInversionSpreadG`
- `cfg.smart.rough`
  - enable/repeat/average/nPoints/retries/fit quality/policy/span factors/stopFactor/maxStopNs
- `cfg.smart.t1fit`
  - `model`, stretched bounds, amplitude bound
- `cfg.smart.power`
  - ODMR/Rabi power defaults
- `cfg.smart.precal`
  - Rabi/ODMR precal defaults
  - `forceMeasureAllFreqs`: if `true`, precal ODMR always measures all 4 labels (`aligned_m1`, `aligned_p1`, `off_m1`, `off_p1`) even when some T1 targets are unchecked; MW calibration remains target-driven
  - `calipi`: target-pi power calibration knobs (`enabled`, `targetPiNs`, `powerStartDbm`, `powerStopDbm`, `powerNPoints`, `maxSafePowerDbm`, `quadFitNPoints`)
- `cfg.smart.ui.tags`
  - GUI tag map
- `cfg.smart.targets`
  - 6-target default table

## 20. Launch / Usage Notes

Typical operator flow:

1. Open main experiment GUI (`Experimental_PB_DAQ` workflow).
2. Open `T1_SemiAuto_ParamInput_v2_1`.
3. Select targets.
4. Enter estimated B.
5. Set per-target T1 parameters.
6. Choose rough scan + nonuniform options as needed.
7. Set precal power/scan fields; choose whether to enable precal.
8. Click `Start Program`.
9. Monitor:
   - `txt_precal_summary`
   - `txt_rough_t1_ms`
   - optional per-target status texts
10. Click `Stop Program` to request stop.

## 21. Known Practical Caveats

- ODMR peak extraction is minima-based and lightweight; it is not a full multi-Lorentzian global fit.
- `cfg.smart.odmr.maxRetriesPerWindow` and `retryExpandFactor` are currently legacy knobs (not active in the current planning/fit loop).
- If GUI tags are missing, backend falls back to cfg defaults and legacy fields where implemented.

## 22. File Guide

Core v2.1 logic:

- `config.m`
- `t1_semi_auto_program.m`
- `T1_SemiAuto_ParamInput_v2_1.m`
- `+autoplot/dispatch.m`
- `+fitting/fit_t1.m`
- `+fitting/fit_t1_stretched.m`
- `+plotting/plot_t1_data_method3.m`
- `+plotting/plot_t1_data_method4.m`

Spec and integration docs:

- `instruction_v2_1.md`
- `GUI_ELEMENTS_v2_1.md`

## 23. Change-Safety Reminder

Keep `t1_semi_auto_run.m` compatibility intact unless explicitly doing base-code refactor work.
Most behavior should be changed via:

- cfg values (`config.m`)
- orchestration logic (`t1_semi_auto_program.m`)
- GUI tags/callbacks (`T1_SemiAuto_ParamInput_v2_1.*`)
