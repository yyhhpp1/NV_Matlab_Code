# MATLAB_Code Operational Memory

Last updated: 2026-06-05

## Session Rules / Preferences

- Do not run `matlab -batch` in this session unless the user explicitly reverses that instruction.
- Prefer text-only checks such as `rg`, `Get-Content`, and `git diff --check`.
- The active workspace is `C:\MATLAB_Code`.

## Version Roles

### AutoRunSequences_v2_2

`AutoRunSequences_v2_2` is the main smart relaxation measurement layer.

Primary entry point:

```matlab
addpath('AutoRunSequences_v2_2');
open_v2_2_gui
```

Important files:

- `AutoRunSequences_v2_2/open_v2_2_gui.m`
- `AutoRunSequences_v2_2/T1_SemiAuto_ParamInput_v2_2.m`
- `AutoRunSequences_v2_2/smart_relaxation_program_v2_2.m`
- `AutoRunSequences_v2_2/config.m`
- `AutoRunSequences_v2_2/t1_semi_auto_run.m`

Responsibilities:

- T1 / T2 / T2* smart relaxation runs.
- Target and family selection.
- ODMR / Rabi / PiCal precalibration.
- Rough scans and final scans.
- Final T1 fit-based early stop.
- T1 Sij-all override.
- Measurement logs, reports, and analysis snippets.

### AutoRunSequences_v3_2

`AutoRunSequences_v3_2` is a queue/campaign layer around v2.2.

Primary entry point:

```matlab
open_v3_2_gui
```

Important files:

- `AutoRunSequences_v3_2/open_v3_2_gui.m`
- `AutoRunSequences_v3_2/+v3_2/run_tb_queue_minimal.m`
- `AutoRunSequences_v3_2/+v3_2/run_b_queue_multispot.m`

Responsibilities:

- Queue temperature steps.
- Queue B-field lists for each temperature.
- Bind to the v2.2 GUI and run it repeatedly.
- Magnet and temperature control.
- Multi-spot execution and spot-specific save routing.

In short: v2.2 runs one smart measurement workflow; v3.2 drives many v2.2 workflows across T/B/spots.

## v3.2 Stop / Resume Behavior

- Use `Stop Queue` to request a graceful stop.
- Use `Clear Stop` before starting another queue run.
- Completed data/logs/reports on disk are preserved.
- The active unfinished B/spot/measurement may be stopped or incomplete.
- Re-running the queue starts from the beginning of the current GUI queue list.
- v3.2 does not currently auto-resume from the last stopped T/B/spot item.
- To continue manually, remove or edit already-completed queue entries before pressing `Run Queue` again.

## v3.2 Skip Controls

Existing skip controls in the v3.2 GUI:

- `Skip temperature control`: skips temperature control globally.
- `Skip magnet control`: skips magnet control globally.
- `Skip first magnet check/control after Run`: skips only the first B-point magnet control.
- `Skip first temperature and magnet control after Run`: newly added; skips temperature control for T step 1 and magnet control for the first B point.

The previous idea of making `Skip first magnet` also skip the initial temperature magnet gate was rolled back.

## v3.2 GUI Resize

`AutoRunSequences_v3_2/open_v3_2_gui.m` was changed so the GUI is resizable:

- Figure `Resize` changed to `on`.
- Existing controls are converted to normalized units by `make_gui_controls_resizable`.

## v2.2 Rough Scan vs Final Early Stop

Rough scan and final early stop are separate systems.

- Rough scan chooses or adjusts the final time range before the final measurement.
- Final early stop stops the final averaging loop once fit relative error is good enough.

The rough scan checkbox is read in `smart_relaxation_program_v2_2.m`:

```matlab
ctx.rough.enabled = logical(read_ui_numeric(...));
```

When rough scan is disabled, `determine_t1_final_range` returns the entered `[start, stop]` range directly.

Important recent fix:

- T1 Sij-all override previously forced `ctxOut.rough.enabled = true`.
- That was removed so the `Enable rough pre-scan` checkbox is respected for Sij-all too.

## v2.2 Final T1 Early Stop

Configuration defaults live in `AutoRunSequences_v2_2/config.m`:

```matlab
cfg.smart.finalT1.autoStopByRelErr = true;
cfg.smart.finalT1.relErrThreshold = 0.07;
cfg.smart.finalT1.minAverageForAutoStop = 3;
```

The v2.2 GUI now has editable final early-stop controls:

- `Final fit auto-stop`
- `Final min avg`
- `Final fit err`

Runtime behavior:

- GUI edits during one active measurement do not affect that measurement.
- Edits apply to the next sequence in the same queue because `run_one_sequence_core` reads current GUI values at sequence start.

The low-level stop check is in `t1_semi_auto_run.m`:

```matlab
maybe_stop_current_t1_on_fit_relerr(handles)
```

It stops only when:

- `gmSEQ.AutoStopT1ByRelErr` is true.
- `gmSEQ.T1FitLastStatus.ok` is true.
- `gmSEQ.T1FitLastStatus.timeScaleRelErr <= gmSEQ.AutoStopT1RelErrThreshold`.
- `gmSEQ.iAverage >= gmSEQ.AutoStopT1MinAverage`.

Important recent fix:

- `T1_Sij_all` was added to the true-T1 sequence gate in `smart_relaxation_program_v2_2.m`.
- Before that fix, the Sij-all legend could show a good relErr while early stop stayed disabled.

For an already-running measurement that started before the fix, immediate manual enable is:

```matlab
global gmSEQ
gmSEQ.AutoStopT1ByRelErr = true;
```

## T1 Sij-all Fit / Plot

The active Sij-all plotter is root-level:

- `PlotT1Data_9curves.m`

Recent behavior:

- It builds contrast curves `data1` through `data6`.
- Current live fit uses `yFit = data1`.
- It calls:

```matlab
[popt, perr, xPlot, yPlot] = fitting.fit_t1(xFit, yFit);
```

- The fit legend now displays fit relative error on a new line:

```text
Ae^{-(x/T)^n}
relErr=...
```

The legend relErr comes from:

```matlab
gmSEQ.T1FitLastStatus.timeScaleRelErr
```

That is the same field used by final T1 early stop.

## Rabi Fit

Active file:

- `AutoRunSequences_v2_2/+fitting/fit_rabi.m`

Current default model in `config.m`:

```matlab
cfg.smart.rabiFit.model = 'cos_exp';
```

The fit input `x` is in ns:

```matlab
x = double(gmSEQ.SweepParam(1:numel(y))); % ns
```

For `cos_exp`, parameters are:

```matlab
p = [amplitude, frequency_per_ns, phase, tau_ns]
```

Current bounds:

```matlab
lb = [0, 0, -pi/2, max(1, span/1000)];
ub = [1, inf, pi/2, max(10*span, 1e3)];
```

For plain `cos`, parameters are:

```matlab
p = [amplitude, frequency_per_ns, phase]
lb = [0, 0, -pi/2];
ub = [1, inf, pi/2];
```

Potential future Rabi-fit upgrade plan:

- Use a free baseline model: `y0 + A*exp(-x/tau)*cos(2*pi*f*x + phi)`.
- Estimate frequency from peaks/troughs or FFT instead of `max(x)/4`.
- Use multi-start fitting.
- Reject fits with poor RMSE, boundary-hugging tau/frequency, tiny fitted contrast, or pi time outside the sweep.
- Show fit diagnostics in the legend/status.

## Docs

Useful docs:

- `AutoRunSequences_v2_2/README.md`
- `AutoRunSequences_v2_2/GUI_MANUAL.md`
- `AutoRunSequences_v2_2/ARCHITECTURE.md`
- `AutoRunSequences_v3_2/README.md`

Basic v2.2 workflow is in `AutoRunSequences_v2_2/GUI_MANUAL.md` under Recommended Basic Workflow.

## Current Session Notes - 2026-06-05

Do not run `matlab -batch` in this session; user explicitly asked not to.

### T1 Sij-all New Rough/Final Interval Policy

Files touched:

- `AutoRunSequences_v2_2/config.m`
- `AutoRunSequences_v2_2/smart_relaxation_program_v2_2.m`

Current Sij-all rough policy:

- Run rough T1 for `SQ_0_TO_M1` and `DQ_M1_TO_P1`.
- Store rough results as `T1_SQm1` and `T1_DQ` in `roughInfo`.
- Define:
  - `t_fast = min(T1_SQm1, T1_DQ)`
  - `t_slow = max(T1_SQm1, T1_DQ)`
- Build final `T1_Sij_all` sweep from three edge-inclusive GUI sweep intervals, avoiding duplicate edges by shifting `FROM2` and `FROM3` to the first point after the previous interval edge.

Current interval definitions in ns:

- Interval 1 target: `[1000, t_fast]`
- Interval 2 target: `(t_fast, min(5*t_fast, t_slow)]`
- Interval 3 target: `(min(5*t_fast, t_slow), 5*t_slow]`

The code nudges `TO1`, `TO2`, and `TO3` so every generated point is an integer. It also writes `SmartCustomSweepParam`, so `t1_semi_auto_run.m` uses the exact custom integer point list instead of relying only on GUI `linspace`.

Current configured point counts:

```matlab
cfg.smart.sijAll.firstIntervalNPoints = 8;
cfg.smart.sijAll.secondIntervalNPoints = 6;
cfg.smart.sijAll.thirdIntervalNPoints = 3;
```

The Sij-all synthetic target now prefers the SQ- target as its base:

```matlab
preferredTransitions = {'SQ_0_TO_M1', 'DQ_M1_TO_P1', 'SQ_0_TO_P1'};
```

This replaced an earlier draft where `n1` and `n2` came from `round(Npts/2)` and `n3 = 2`.

The older `addLateTimePoints` extension now returns immediately if `seq.SmartCustomSweepParam` already exists, so it does not overwrite the new three-interval Sij-all custom sweep.

### Rough/Calibration Screenshot Location

Rough SQ and DQ screenshots are saved by `save_rough_overlay_figure` through `save_main_figure`.

Default base path from config:

```text
C:\Users\dilution_fridge_2\Desktop\T1_SemiAuto_Saves
```

Per-run folder pattern:

```text
Run_B..._T..._yyyymmdd_HHMMSS
```

Rough/precal screenshots go under:

```text
...\Run_...\intermediate_precal_rough\
```

Rough T1 image filenames are based on the data `.txt` name, converted to `.png`, with prefix:

```text
Rough_T1_<original_data_file_name>.png
```

Each rough scan saves a normal sequence-finished screenshot, then saves again after the combined rough-fit overlay is drawn. The final PNG at that path should be the overlay version.

Related command logs are under:

```text
...\Run_...\logs\intermediate_precal_rough\
```
