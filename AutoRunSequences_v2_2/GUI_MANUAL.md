# v2.2 GUI Manual

This manual explains how to use the `AutoRunSequences_v2_2` GUI and what each control means.

Main entry point:

```matlab
open_v2_2_gui
```

The GUI is a lower-level automation tool. Its job is to:

1. Read the measurement plan from the `v2.2` parameter window.
2. Optionally run precalibration.
3. For each enabled target and enabled measurement family, run a rough scan if requested.
4. Choose or correct the final time span.
5. Run the final sequence and save the figures.

During a run, `v2.2` also writes one command-output log per sequence into the current run folder under `logs/`. Rough and PiCal-type runs are placed under `logs/intermediate_precal_rough/`.

`v2.2` now also writes structured debugging reports under `reports/`:

- `reports/spot/v2_2_run_summary.txt`
- `reports/measurements/final/`
- `reports/measurements/intermediate_precal_rough/`
- `reports/pical/`
- `reports/failures/`

These are meant to explain what the automation decided, not just what printed to the command window.

## Before You Start

Make sure:

- the main experiment GUI is open
- the pulse sequence names in [config.m](/c:/MATLAB_Code/AutoRunSequences_v2_2/config.m) are correct for your setup
- the `T1`, `T2`, and `T2*` mappings in `config.m` point to the right sequences
- your microwave channels and laser path are already configured on the main setup

Important target support:

- `T1` supports:
  - aligned `SQ-`
  - aligned `SQ+`
  - aligned `DQ`
  - off-aligned `SQ-`
  - off-aligned `SQ+`
  - off-aligned `DQ`
- `T2` supports:
  - aligned `SQ-`
  - aligned `SQ+`
  - off-aligned `SQ-`
  - off-aligned `SQ+`
- `T2*` supports:
  - aligned `SQ-`
  - aligned `SQ+`
  - off-aligned `SQ-`
  - off-aligned `SQ+`

DQ is `T1`-only in `v2.2`.

## GUI Layout

The window is split into three main areas:

- top `Program Control` bar
- left `Configuration` column
- right `Timing` tabs for `T1`, `T2`, and `T2*`

## Program Control

### `Start Program`

Starts the automation run using the current GUI values.

What happens after pressing it:

1. The GUI state is read.
2. Enabled targets are collected.
3. Enabled measurement families are collected.
4. Optional precalibration runs first.
5. The enabled measurements run one by one.

### `Stop Program`

Requests a graceful stop. The automation checks this flag between major steps and stops as soon as it is safe.

### Top note

The note reminds you that `T1`, `T2`, and `T2*` sequence names are not hardcoded in the GUI. They come from `config.m`.

## Left Column

### 1. Measurement Families

This panel decides which kinds of relaxation measurements will run.

#### `Enable T1`

Runs the `T1` workflow for every enabled target that supports `T1`.

#### `Enable T2`

Runs the `T2` workflow for every enabled SQ target.

`T2` uses the same rough-then-final logic as `T1`, but its sequence selection comes from the `T2` mapping in `config.m`.

#### `Enable T2*`

Runs the `T2*` workflow for every enabled SQ target.

`T2*` roughing uses edge-ratio logic by default instead of relying only on a fit.

### 2. Targets + Globals

This panel chooses which transitions you want to measure and sets a few global options.

#### Target checkboxes

Each checkbox enables one measurement target:

- `Aligned SQ-`
- `Aligned SQ+`
- `Aligned DQ (T1)`
- `Off-aligned SQ-`
- `Off-aligned SQ+`
- `Off-aligned DQ (T1)`

If a target is checked:

- it participates in `T1` if `T1` is enabled
- it participates in `T2` only if that target is an SQ target
- it participates in `T2*` only if that target is an SQ target

#### `Estimated B (G)`

Your best estimate of the magnetic field in gauss.

This value is used to:

- predict ODMR resonance locations before fitting
- plan the ODMR sweep windows used during precalibration
- name save folders and annotate run context

If this number is badly wrong, the initial ODMR planning may be less reliable.

#### `Nonuniform points (first quarter gets half)`

Changes the sweep grid used for the final family sequence.

When enabled:

- the first quarter of the time span gets half of the points
- the rest of the span gets the remaining points

This gives denser sampling at short delay times, where the curve often changes fastest.

Use it when:

- short-time dynamics matter more than late-time detail
- you want better early-time shape without increasing total point count

Leave it off when you want a standard uniform spacing.

### 3. Rough Search

This panel controls the automatic rough pre-scan used to choose a better final stop time.

#### `Enable rough pre-scan`

If checked, the program runs one or more rough scans before the final scan.

Purpose:

- estimate the characteristic decay scale
- decide whether the current stop time is too short or too long
- correct the final stop if needed

If unchecked, the final scan uses the `Start` and `Stop` values exactly as entered, except for minor safety/grid corrections.

#### `Rough N`

Number of points used in the rough scan.

Special behavior:

- if `Rough N = 0`, the runner reuses the target’s normal `Npts`
- if `Rough N >= 3`, the rough scan uses that value instead

Use a smaller number for a fast rough estimate.

#### `Repeat`

Sequence repeat count used during the rough scan.

Larger values:

- improve rough-scan signal quality
- slow the rough stage down

#### `Average`

Number of averages used during the rough scan.

Larger values improve robustness but make the rough stage longer.

#### `Max retries`

Maximum number of rough-scan attempts.

If the first rough scan does not satisfy the stopping rule, the program can expand the time span and try again, up to this many times.

#### `Fit err`

Relative-error threshold for accepting a fit-based rough estimate.

Used mainly for `T1` and `T2`.

Smaller value:

- stricter fit quality requirement
- may force more retries

Larger value:

- accepts noisier rough fits
- may finish faster but with less confidence

#### `Stop mode`

How the rough search decides when to stop retrying.

Available values:

- `first_good`
  - stop as soon as one rough attempt is good enough
- `max_retries`
  - allow retries until the stop span is judged acceptable or the retry limit is reached

`max_retries` is usually the safer choice when the initial time scale is uncertain.

#### `Stop factor`

Target multiplier used to set the final stop after a successful rough estimate.

Conceptually:

- final stop is moved toward `start + stopFactor * decay_time`

For example:

- `Stop factor = 3` means the final stop aims for about three decay constants beyond the start

Larger values give a longer final sweep. Smaller values give a shorter, faster sweep.

#### Rough note

The note in the panel summarizes the default family policy:

- `T2` uses fit-based roughing with the `T2` stretched-fit path
- `T2*` uses edge-ratio roughing by default

Implementation note:

- `T2` rough scans use the Echo-style contrast extraction and the `fit_t2_stretched` fitter
- `T2*` rough scans use the same stretched fitter when a fit-based rough mode is selected in config

### 4. Precalibration + Power

This panel controls optional ODMR and Rabi calibration steps before the final relaxation measurements.

If precalibration is enabled, the runner can:

- locate the relevant resonances with ODMR
- run Rabi measurements
- estimate pi times
- estimate fitted `pi/2` and `3pi/2` pulse times from the Rabi fit
- optionally adjust microwave power to target a desired pi pulse

#### `Enable precalibration`

Master enable for the precalibration stage.

If checked:

- ODMR runs first
- Rabi calibration runs as needed
- the measured resonance frequencies and pi times feed into the later family sequences

If unchecked:

- the runner skips ODMR and Rabi precalibration
- the main GUI’s current microwave settings are used instead

#### `Find MW power for target pi`

Enables the PiCal logic that searches microwave power to reach a desired pi time.

When enabled, the runner can sweep microwave power and try to find the power that produces the target pi pulse length.

#### `ODMR`

Default ODMR microwave power in dBm.

Used for ODMR-based resonance finding.

#### `ODMR P1`

ODMR power used for `+1`-style resonances in dBm.

This lets you treat the `+1` resonance differently if needed.

#### `Rabi base`

Base microwave power in dBm for Rabi-related operations.

This is the general starting point before more specific SG values are used.

#### `Rabi SG1`

Microwave power in dBm for SG1-driven Rabi operations.

#### `Rabi SG2`

Microwave power in dBm for SG2-driven Rabi operations.

This matters mainly for DQ-related or dual-source logic.

#### `Target pi`

Desired pi-pulse length in ns for the power-search calibration.

If `Find MW power for target pi` is enabled, the program tries to find a microwave power that gives this pi time.

When PiCal memory prior is enabled, `v2.2` now only trusts saved PiCal memory rows whose recorded pi time is already close to this target. The absolute tolerance is controlled in `config.m` by `cfg.smart.precal.calipi.memoryTargetPiToleranceNs`.

#### `PiCal t0`

Start of the Rabi sweep, in ns, used during pi-time calibration.

#### `PiCal t1`

Stop of the Rabi sweep, in ns, used during pi-time calibration.

#### `PiCal N`

Number of points in the Rabi sweep used for pi-time calibration.

#### `PiCal rep`

Repeat count for the Rabi sweep used during pi-time calibration.

#### `PiCal avg`

Average count for the Rabi sweep used during pi-time calibration.

Rabi-fit pulse updates:

- after a successful SG1 Rabi fit, `v2.2` writes the fitted `pi` time to `pi`, the fitted `pi/2` time to `halfpi`, and the fitted `3pi/2` time to `DEERt`
- after a successful SG2 Rabi fit, `v2.2` updates `DEERpi` using the fitted `pi` time from that SG2 fit

#### `ODMR rep`

Repeat count for ODMR during precalibration.

#### `ODMR avg`

Average count for ODMR during precalibration.

#### `Pts/MHz`

ODMR frequency density, in points per MHz.

Larger values:

- give finer ODMR sampling
- increase scan time

#### `P start`

Starting microwave power in dBm for the PiCal power sweep.

#### `P stop`

Ending microwave power in dBm for the PiCal power sweep.

#### `P npts`

Number of tested power values in the PiCal power sweep.

### 5. Run Displays

This panel is read-only during normal use.

#### `Rough display`

Shows the current rough-search result.

Examples:

- rough `T1` estimate in ms
- rough `T2` estimate in ms
- rough `T2*` edge ratio

#### Precal summary box

Shows the current ODMR and Rabi calibration summary.

Typical contents:

- measured resonance frequency
- pi time
- chosen power

#### Per-target status boxes

Each status box shows progress or recent result text for one target.

This is useful for tracking which target/family just finished or failed.

## Right Column: Timing Tabs

The right side has three tabs:

- `T1`
- `T2`
- `T2*`

Each row corresponds to one target supported by that family.

Each row has the same five editable timing fields.

## Meaning of the Timing Fields

### `Start`

Beginning of the sweep range.

Meaning:

- the shortest delay time used in that measurement family

For these relaxation-family rows, the runner uses the GUI values as sequence sweep limits and internally treats them on the native sequence time scale. In the current automation logic, the sweep limits are passed into the sequence builder in ns, and rough-fit display values are converted to ms for reporting.

Practical rule:

- enter the delay range expected by the target sequence mapping in your setup
- keep `Start` at or near zero unless your sequence needs a nonzero minimum delay

### `Stop`

End of the sweep range.

Meaning:

- the longest delay time used in the final scan, unless rough search auto-corrects it

If rough search is enabled:

- the rough stage may keep this stop
- or replace it with a corrected value if the span is too short or too long

If rough search is disabled:

- the final scan uses this entered stop directly, aside from small grid-alignment corrections

### `Npts`

Number of sweep points for the final measurement.

Larger values:

- give a denser curve
- increase measurement time

If `Nonuniform points` is enabled, the total point count still comes from this field, but the distribution is reshaped.

### `Repeat`

Per-point repeat count for the final family sequence.

Larger values improve signal quality but increase runtime.

### `Average`

Number of averages for the final family sequence.

Larger values reduce noise but increase runtime.

## Family-Specific Notes

### T1 tab

Includes both SQ and DQ rows.

Use this when measuring longitudinal relaxation.

Rough-search behavior:

- fit-based decay estimate
- final stop may be corrected to land near a useful multiple of the rough time constant

### T2 tab

Includes only SQ rows.

Use this when measuring coherent decay with the sequence mapped to the `T2` family in `config.m`.

Rough-search behavior:

- fit-based, similar in spirit to `T1`

### T2* tab

Includes only SQ rows.

Use this when measuring inhomogeneous dephasing with the sequence mapped to the `T2*` family in `config.m`.

Rough-search behavior:

- edge-ratio based by default
- the automation looks at how much the signal has fallen by the end of the range and expands the span if needed

## Recommended Basic Workflow

### Fast setup workflow

1. Open the main experiment GUI.
2. Open `v2.2`:

```matlab
open_v2_2_gui
```

3. In `Measurement Families`, enable the families you want.
4. In `Targets + Globals`, check the targets you want.
5. Set `Estimated B (G)`.
6. Decide whether to use `Nonuniform points`.
7. In `Rough Search`, enable rough pre-scan if the proper time scale is not known.
8. In `Precalibration + Power`, decide whether to run ODMR/Rabi calibration first.
9. In the `T1`, `T2`, and `T2*` tabs, enter the sweep parameters for each enabled row.
10. Press `Start Program`.

### When to enable rough search

Enable rough search when:

- you do not know the correct stop time yet
- the decay time may vary with field or temperature
- you want the automation to choose a better span before the final run

Disable rough search when:

- you already know the correct time window
- you want the exact entered range without rough scouting

### When to enable precalibration

Enable precalibration when:

- frequencies may have shifted
- you want fresh ODMR and Rabi calibration
- you want pi-power targeting

Disable precalibration when:

- the main GUI is already tuned
- you only want a quick run using the existing instrument state

## Example Usage Patterns

### Example 1: Quick T1 only

- enable `T1`
- disable `T2`
- disable `T2*`
- select one SQ or DQ target
- disable precalibration if frequencies are already known
- disable rough search if your stop time is already good

### Example 2: Unknown T2 timescale

- enable `T2`
- select one or more SQ targets
- enable rough pre-scan
- use modest `Rough N`, `Repeat`, and `Average`
- give an initial `Stop` that is plausible but not guaranteed

The runner will rough the span first, then run the final `T2`.

### Example 3: T2* scouting

- enable `T2*`
- select SQ targets
- enable rough pre-scan
- start with a conservative short stop

The edge-ratio logic will expand the window if the signal has not decayed enough by the end of the rough scan.

## Saved State

The GUI saves its control state to:

- `T1_SemiAuto_ParamInput_v2_2_state.mat`

That means your last-used values can be restored the next time you open the GUI.

## Debugging Outputs

When a run is saved into a folder, the most useful debugging files are:

- `analysis_add_entry_snippet.txt`
  - analysis snippet for downstream bookkeeping
- `AutoGUI_v2_1_Final.png`
  - final state of the `v2.2` GUI
- `logs/`
  - raw command-window capture for each sequence run
- `reports/measurements/...`
  - compact report per sequence with sequence fields, fit summary, and matching analysis entry
- `reports/pical/`
  - one report per PiCal decision path, including memory prior and sweep bounds
- `reports/spot/v2_2_run_summary.txt`
  - high-level index for the whole `v2.2` run inside that save folder
- `reports/failures/`
  - only created when a sequence throws an exception

## Layout Editor

If the GUI layout needs manual adjustment on your MATLAB installation, use:

```matlab
open_v2_2_gui('layout_edit', true)
```

This opens a companion layout editor so you can adjust control positions and save persistent overrides.

To clear saved layout overrides:

```matlab
open_v2_2_gui('reset_layout', true)
```

## Important Notes and Caveats

- Sequence hookups live in [config.m](/c:/MATLAB_Code/AutoRunSequences_v2_2/config.m).
- The GUI does not decide the pulse sequence details by itself.
- `T2` and `T2*` only support SQ-style targets in `v2.2`.
- DQ is intentionally `T1`-only.
- Rough displays are reported in user-facing summary text, while the internal sequence timing is handled using the sequence builder’s expected numeric scale.
- If your measurements behave oddly, the first things to check are:
  - target selection
  - family enable checkboxes
  - sequence mapping in `config.m`
  - precalibration power settings
  - timing ranges in the right-side tabs

## Related Files

- [README.md](/c:/MATLAB_Code/AutoRunSequences_v2_2/README.md)
- [ARCHITECTURE.md](/c:/MATLAB_Code/AutoRunSequences_v2_2/ARCHITECTURE.md)
- [config.m](/c:/MATLAB_Code/AutoRunSequences_v2_2/config.m)
- [T1_SemiAuto_ParamInput_v2_2.m](/c:/MATLAB_Code/AutoRunSequences_v2_2/T1_SemiAuto_ParamInput_v2_2.m)
- [smart_relaxation_program_v2_2.m](/c:/MATLAB_Code/AutoRunSequences_v2_2/smart_relaxation_program_v2_2.m)
