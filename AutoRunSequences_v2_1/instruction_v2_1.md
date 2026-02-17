# Instruction For Agent (v2.1)

## Goal

Build a smarter T1 workflow in `AutoRunSequences_v2_1` so the user does **not** manually pre-program the sequence order each time.

Assume B/T are already set externally. Ignore outer-loop B/T sweep for v2.1.

## User selection model (GUI)

User chooses measurement targets from 2 groups x 3 transitions:

- `aligned`
  - `SQ_0_TO_M1`
  - `SQ_0_TO_P1`
  - `DQ_M1_TO_P1`
- `offaligned`
  - `SQ_0_TO_M1`
  - `SQ_0_TO_P1`
  - `DQ_M1_TO_P1`

User also provides:

1. Estimated magnetic field value (e.g., ~100 G)
2. T1 parameters:
   - preferred: per-target (6 sets)
   - acceptable fallback: legacy v2 three sets (`T1`, `T12`, `T13`) reused by aligned/offaligned
3. Optional checkbox: nonuniform point distribution for T1 sweep
4. Program control buttons: `Start Program` and `Stop Program`

## Sequence scope (only use these for v2.1)

- `ODMR`
- `Rabi`
- `Rabi_SG2`
- `T1_S00_S01_S10`
- `T1_S11_S1m1`

## ODMR planning rules

### Required resonances from selected targets

For each selected `(group, transition)` target:

- `SQ_0_TO_M1` requires that group's `m1` resonance
- `SQ_0_TO_P1` requires that group's `p1` resonance
- `DQ_M1_TO_P1` requires both `m1` and `p1` for that group

This produces up to 4 required resonances total:

- aligned `m1`, aligned `p1`, offaligned `m1`, offaligned `p1`

### Window strategy (no blind full sweep)

1. Predict resonance centers from `B_est`.
2. Build local ODMR windows around only the required resonances.
3. If resonance gap in a candidate combined window is `<= 500 MHz`, allow one combined window.
4. If resonance gap is `> 500 MHz`, split into separate windows.
5. Merge overlapping windows automatically.
6. Track expected peak count per final window:
   - single-resonance window -> expect 1 peak
   - combined `m1/p1` window for one group -> expect 2 peaks
   - merged multi-group window -> expect sum of contributing expected peaks
7. Fit each window and map fitted peaks back to resonance IDs.
8. If a window fit fails, expand that window and retry before considering broader fallback.

## Rabi/T1 orchestration rules

- Frequency sweep is done with SG1 only (ODMR).
- Rabi:
  - use `Rabi` for SG1 frequency path
  - use `Rabi_SG2` for SG2 frequency path
- T1:
  - SQ uses `T1_S00_S01_S10`
  - DQ uses `T1_S11_S1m1`
- Parameter passing must be explicit and transition-specific (never rely on stale GUI state).

## T1 parameter requirements (per target)

Do **not** use one shared T1 parameter set for all targets.

Each of the 6 target entries (`aligned/offaligned x 3 transitions`) must have its own T1 settings:

1. `start`
2. `stop`
3. `nPoints`
4. `Repeat`
5. `Average`

If a target is selected, its own parameter set is mandatory.

Implementation note:

- If per-target GUI controls are missing, backend may temporarily use legacy v2 fields:
  - SQ m1 from `startT1/stopT1/nPtsT1/RepeatT1/maxAveT1`
  - SQ p1 from `startT12/stopT12/nPtsT12/RepeatT12/maxAveT12`
  - DQ from `startT13/stopT13/nPtsT13/RepeatT13/maxAveT13`

## Smart T1 range correction rules

Use a data-driven rough-scan step per selected target:

1. Start from that target's user-provided T1 range/points as the rough-scan seed.
2. Run rough T1 scan and fit `T1_rough`.
3. Validate span using:
   - minimum span = `1.5 * T1_rough`
   - maximum span = `3.0 * T1_rough`
4. If span is outside this range, adjust only `start/stop`.
5. Do **not** change `nPoints`.
6. If `start >= stop`, fix ordering and then enforce span rule.

Every auto-correction must be shown in log/GUI status with:

- original range
- `T1_rough`
- corrected range
- correction reason

## Nonuniform point distribution option

Provide a checkbox to enable smart point distribution for T1 sweep:

- first `1/4` of time range gets half of points
- remaining `3/4` gets half of points

Keep total point count unchanged:

- if odd `nPoints`, use `ceil(n/2)` in first segment and `floor(n/2)` in second segment.

## Rough T1 panel requirements

Add a dedicated rough-T1 control panel in GUI:

- `Enable rough T1 pre-scan` checkbox
- `Rough Npts` (overrides target/user `nPoints` for rough scan only)
- `Max rough-scan retries`
- fit-quality threshold
- stop policy options (first good fit / convergence / max retries)

Do **not** provide rough-scan start/stop input fields in this panel.
Rough scan range seed comes from each selected target's own T1 user inputs.

## Precalibration panel requirements

Add a dedicated precalibration panel:

- Power:
  - ODMR MW power
  - Rabi MW power (shared by SG1 and SG2 by default; optional SG-specific override)
- Unified Rabi scan settings (used by `Rabi` and `Rabi_SG2`):
  - `start`, `stop`, `npts`, `repeat`, `average`
- ODMR scan settings:
  - `repeat`, `average`, `points-per-MHz`

Power consistency rule:

- Shared Rabi power is reused in both T1 SG1/SG2 paths unless SG-specific overrides are provided.

## Precalibration display requirements

GUI should display, per selected target:

- fitted resonance frequency used for that target
- fitted pi-time used
- fitted Rabi frequency
- assigned SG path (`SG1`/`SG2`)
- fit/status indicator

## Internal clarification policy (for agent)

If any measurement-to-sequence mapping is ambiguous, the agent must ask the user before finalizing that branch. This policy is internal to agent behavior.
