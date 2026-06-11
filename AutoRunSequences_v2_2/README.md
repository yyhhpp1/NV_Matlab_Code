# AutoRunSequences_v2_2

`v2.2` is the clean, code-generated successor to `AutoRunSequences_v2_1`.

It keeps the lower-level automated measurement flow, but replaces the old GUIDE parameter GUI with a programmatic classic MATLAB GUI and expands the measurement engine from T1-only to a family-aware runner:

- `T1`
- `T2`
- `T2*`

`v2.1` remains the historical baseline. This folder only keeps files used by the `v2.2` runtime.

## Entry Points

- `open_v2_2_gui.m`
  Opens the `v2.2` parameter GUI.
- `T1_SemiAuto_ParamInput_v2_2.m`
  Programmatic classic MATLAB GUI built with `figure`, `uicontrol`, and `uitabgroup`.
- `smart_relaxation_program_v2_2.m`
  Main automation runner. Handles target selection, rough scan logic, final runs, saving, and analysis snippets.

## User Manual

- `GUI_MANUAL.md`
  Field-by-field guide for the `v2.2` GUI, including how to use each panel and what each edit box means.

## Runtime Support Files

- `config.m`
  Central configuration for plotting, fitting, UI tags, defaults, and family-to-sequence mappings.
- `t1_semi_auto_run.m`
  Existing low-level acquisition runner reused by `v2.2`.
- `auto_load_user_inputs.m`
  Existing helper used by the runner before each measurement block.
- `calipi_memory.mat`
  Persisted calibration memory used by the inherited precalibration logic.
- `+autoplot`, `+plotting`, `+fitting`
  Plot/fitting helpers reused by the runner.

## What Changed From v2.1

- No GUIDE `.fig` dependency.
- New family enable controls for `T1`, `T2`, and `T2*`.
- Per-target timing controls for all three families.
- `T2` and `T2*` are restricted to the four SQ-style categories:
  - aligned `0 -> -1`
  - aligned `0 -> +1`
  - off-aligned `0 -> -1`
  - off-aligned `0 -> +1`
- DQ remains available for `T1` only.
- Config-driven sequence mapping by measurement family and transition.
- Family-aware rough search:
  - `T1`: fit-based rough scale estimate
  - `T2`: fit-based rough scale estimate
  - `T2*`: edge-ratio rough scale estimate
- Optional run-folder override support so `v3.2` can route outputs into spot-specific folders.
- Per-sequence command logs are written under the current run folder in `logs/`, with rough and PiCal logs routed into `logs/intermediate_precal_rough/`.
- Structured text reports are written under `reports/`:
  - `reports/spot/v2_2_run_summary.txt`
  - `reports/measurements/final/`
  - `reports/measurements/intermediate_precal_rough/`
  - `reports/pical/`
  - `reports/failures/`

## Typical Use

```matlab
addpath('AutoRunSequences_v2_2');
hFig = open_v2_2_gui();
```

Attach the `v2.2` GUI to the main experiment GUI, configure enabled targets and measurement families, then press `Start Program`.

## Interactive Layout Editing

You can tune the code-generated GUI layout interactively:

```matlab
open_v2_2_gui('layout_edit', true)
```

This opens the normal `v2.2` GUI plus a companion layout editor window that lets you:

- select tagged controls from a list
- edit `x`, `y`, `width`, and `height`
- nudge controls in small steps
- save persistent layout overrides
- reset one control or the whole GUI back to default positions

Saved overrides are stored in:

- `T1_SemiAuto_ParamInput_v2_2_layout.mat`

To clear saved layout overrides on launch:

```matlab
open_v2_2_gui('reset_layout', true)
```

## Saved State

The GUI stores its own state in:

- `T1_SemiAuto_ParamInput_v2_2_state.mat`

This state file is created by the `v2.2` GUI itself and is not copied from `v2.1`.

## Notes

- Sequence hookups for `T1`, `T2`, and `T2*` live in `config.m`.
- `T2` and `T2*` reuse the same outer automation workflow as `T1`; only the family policy and sequence mapping differ.
- `v3.2` can inject a run-save override through appdata so each spot writes directly into its own folder.
- The `reports/` tree is meant to explain what `v2.2` chose:
  - per-measurement reports summarize sequence settings, fit outputs, and linked analysis entries
  - PiCal reports capture memory prior, sweep bounds, fitted power, and verification-Rabi results
  - failure reports are only written when a sequence throws
