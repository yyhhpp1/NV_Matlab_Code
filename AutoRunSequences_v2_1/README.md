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
  - `T1_SemiAuto_Run.m` is used as-is and treated as base code.
- v2.1 orchestration layer is in:
  - `T1_SemiAuto_Program.m`
  - `AutoPipelineConfig.m`
  - `T1_SemiAuto_ParamInput_v2_1.m` + `.fig`

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

- `T1_SemiAuto_Program(hObject, eventdata, handlesMain, handlesAuto)`

Execution order:

1. Load cfg from `AutoPipelineConfig.m`.
2. Push T1 fit model settings into `gmSEQ`:
   - `gmSEQ.T1FitModel`
   - `gmSEQ.T1FitCfg`
3. Build execution context from GUI + cfg defaults.
4. Apply one-time preset fields (`readout`, `CtrGateDur`) if present.
5. Predict resonance centers from estimated B (full matrix model).
6. Determine required resonance labels from selected targets.
7. If precalibration enabled:
   - plan ODMR windows for required labels only
   - run ODMR on each window
   - fit peaks from measured data
   - fill missing peaks with prediction
   - run Rabi (SG1) for required labels
   - run Rabi_SG2 only for DQ p1 labels
   - update unified precal summary display
8. If precalibration disabled:
   - skip ODMR/Rabi
   - use predicted map internally
   - do not overwrite T1 MW fields in sequence builder
9. For each selected target:
   - resolve frequencies (`fSg1`, `fSg2`)
   - run rough T1 policy to determine final range
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

Default ODMR cfg (`AutoPipelineConfig.m`):

- `splitThresholdMHz = 200`
- `windowMarginMHz = 20`
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

## 8. Precalibration (ODMR + Rabi)

Controlled by GUI checkbox:

- tag: `chk_enable_precal`

If enabled:

- SG1 Rabi is run for all required labels.
- SG2 Rabi is run only for p1 labels needed by DQ targets.
- results stored in:
  - `precal.sg1PiNs`, `precal.sg1FreqMHz`
  - `precal.sg2PiNs`, `precal.sg2FreqMHz`
- unified summary display written to `txt_precal_summary`.

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
- each rough retry runs real T1 sequence and fits current data
- latest rough result is displayed immediately:
  - `txt_rough_t1_ms = "Rough T1: xxx ms"` (overwrites previous)
- retry span update uses `2*T1rough` (ms -> ns)
- span is rounded to nearest 1000 (time unit used by sequence fields, ns in this setup)
- stop is aligned so sweep points remain integer-grid-consistent where possible
- optional cap:
  - `cfg.smart.rough.maxStopNs` clips rough and final stop

Final correction rule after rough fit:

- compute window:
  - lower bound = `start + 1.5*T1rough`
  - upper bound = `start + 3.0*T1rough`
- if original stop is inside this window -> keep stop
- otherwise -> set stop to `start + 2*T1rough`
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
- split/stop are aligned to integer-point grids for both segments.

When disabled:

- single linear segment from start to aligned stop.

## 12. Units

Important unit handling:

- T1 sequence fields (`start/stop`) are treated as ns in this workflow.
- Rough-T1 fit converts `gmSEQ.SweepParam` ns -> ms before fitting.
- `fit_T1_func` expects x in ms.
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

- `fit_T1_func.m` (dispatcher + status)
- `fit_T1_stretched_func.m` (stretched model)

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

- `ODMR` -> `PlotRabiData` + `FitESR`
- `Rabi` -> `PlotRabiData` + `FitRabi`
- `Rabi_SG2` -> `PlotRabiData` + `FitRabi`
- `T1_S00_S01_S10` -> `PlotT1Data_method4`
- `T1_S11_S1m1` -> `PlotT1Data_method3`

## 15. Program Stop Behavior

Stop button callback (`pushbutton_stopProg_Callback`) does:

- GUI stop flag: `pushbutton_stopProg.UserData = 1`
- global run flags:
  - `gmSEQ.bGo = 0`
  - `gmSEQ.bGoAfterAvg = 0`
  - `gmSEQ.bExp = 0`

`T1_SemiAuto_Program` checks stop state before/after major stages.
`T1_SemiAuto_Run` loop checks `gmSEQ.bGo`/`gmSEQ.bGoAfterAvg` and exits current acquisition loop at the next check.

## 16. Figure Saving And Slack

After each sequence run (`run_one_sequence`):

- GUI figure is saved to `cfg.paths.saveFolder`
- if suffix indicates rough T1, filename gets `Rough_T1_` prefix

Slack upload:

- optional, gated by GUI `slackUploadFlag`
- disabled path returns early (no script-path use)
- enabled path uses `slack_upload_v2.py` and cfg keep count.

## 17. GUI State Persistence

GUI state is restored on open and saved on close:

- file: `AutoRunSequences_v2_1/T1_SemiAuto_ParamInput_v2_1_state.mat`
- path derived from `mfilename('fullpath')` so it stays in v2_1 folder

Saved fields:

- all uicontrol `String`/`Value` entries in the v2.1 param GUI handles struct.

## 18. GUI Tag Reference (Backend-Critical)

Authoritative map is generated in `AutoPipelineConfig.m` (`build_ui_tag_map`).
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
    `popup_rough_stop_policy`
- precal:
  - `chk_enable_precal`, `edit_odmr_power`, `edit_rabi_power`
  - `edit_precal_rabi_start/stop/npts/repeat/average`
  - `edit_precal_odmr_repeat/average/points_per_mhz`
- displays:
  - `txt_precal_summary`
  - `txt_rough_t1_ms`

Per-target T1 input tags are also defined and consumed for all 6 targets.

## 19. Config Reference (Current Defaults)

See `AutoPipelineConfig.m` for exact values. Main sections:

- `cfg.paths`
  - `saveFolder`
  - `slackScriptFolder`
- `cfg.slack`
  - `defaultKeep`
- `cfg.plotting`
  - `maxCtrToPlot`, `default`, `rules`
- `cfg.smart.physics`
  - `zeroFieldGHz`, `gammaMHzPerG`
- `cfg.smart.odmr`
  - split/margin/points/spacing/hard bounds
- `cfg.smart.rough`
  - enable/repeat/average/nPoints/retries/fit quality/policy/span factors/maxStopNs
- `cfg.smart.t1fit`
  - `model`, stretched bounds, amplitude bound
- `cfg.smart.power`
  - ODMR/Rabi power defaults
- `cfg.smart.precal`
  - Rabi/ODMR precal defaults
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

- `AutoPipelineConfig.m`
- `T1_SemiAuto_Program.m`
- `T1_SemiAuto_ParamInput_v2_1.m`
- `+autoplot/dispatch.m`
- `fit_T1_func.m`
- `fit_T1_stretched_func.m`
- `PlotT1Data_method3.m`
- `PlotT1Data_method4.m`

Spec and integration docs:

- `instruction_v2_1.md`
- `GUI_ELEMENTS_v2_1.md`

## 23. Change-Safety Reminder

Keep `T1_SemiAuto_Run.m` compatibility intact unless explicitly doing base-code refactor work.
Most behavior should be changed via:

- cfg values (`AutoPipelineConfig.m`)
- orchestration logic (`T1_SemiAuto_Program.m`)
- GUI tags/callbacks (`T1_SemiAuto_ParamInput_v2_1.*`)
