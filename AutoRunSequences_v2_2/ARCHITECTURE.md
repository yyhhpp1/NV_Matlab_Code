# v2.2 Architecture

## Structure

`v2.2` is intentionally narrow:

- GUI layer: `T1_SemiAuto_ParamInput_v2_2.m`
- launcher: `open_v2_2_gui.m`
- orchestration: `smart_relaxation_program_v2_2.m`
- inherited low-level runner: `t1_semi_auto_run.m`
- config and helper packages: `config.m`, `+autoplot`, `+plotting`, `+fitting`

## Measurement Model

Each enabled target can now carry separate parameter blocks for:

- `t1`
- `t2`
- `t2star`

Supported target families are intentionally different:

- `T1` supports SQ and DQ targets.
- `T2` supports aligned/off-aligned `SQ-` and `SQ+` targets only.
- `T2*` supports aligned/off-aligned `SQ-` and `SQ+` targets only.

The runner resolves the enabled families, then executes:

1. Target setup and precalibration.
2. Rough-span estimation for that family.
3. Final sequence build with corrected stop value.
4. Save figures, snippets, and GUI screenshot.

## Rough Search Policy

- `T1` uses the inherited fit-based stop estimator.
- `T2` rough fitting now uses the Echo/Ramsey-style stretched fit path via `fitting.fit_t2_stretched`.
- `T2*` keeps edge-ratio expansion logic by default, but when a fit-based rough mode is selected it also uses `fitting.fit_t2_stretched`.

The family policy is declared in `config.m` under `cfg.smart.measurements`.

## Sequence Routing

Sequence selection is config-driven:

- measurement family
- transition

This keeps the automation layer generic and lets the user wire the actual pulse sequence names in one place.

## Save Routing

If no override is present, `v2.2` creates its normal run folder.

If appdata key `SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE` is set, `v2.2` writes directly into that folder. `v3.2` uses this to keep multi-spot runs clean.
