# AutoRunSequences_v2

This folder is a self-contained refactor of `AutoRunSequences` with the same runtime entry points, but cleaner experiment orchestration.

## What changed

- `T1_SemiAuto_Program.m` is now config-driven.
- Added `AutoPipelineConfig.m` to control:
  - step order,
  - step parameter mapping,
  - per-step fit hook function,
  - per-sequence live plotting behavior.
- Periodic and end-of-step screenshot save/upload now use shared path config values.
- `slack_upload_v2.py` no longer stores Slack secrets in source code.

## Primary edit points for future experiments

1. Edit step order:
   - `AutoPipelineConfig.m` -> `cfg.stepOrder`
2. Edit which GUI fields map to sequence parameters:
   - `AutoPipelineConfig.m` -> `cfg.steps.<StepId>.uiStringMap`
3. Edit fit routine used for a step:
   - `AutoPipelineConfig.m` -> `cfg.steps.<StepId>.fitFunction`
4. Edit live plotting for each sequence:
   - `AutoPipelineConfig.m` -> `cfg.plotting.rules`
   - dispatcher implementation: `+autoplot/dispatch.m`
5. Edit top-level (T, B) automation:
   - `AutoPipelineConfig.m` -> `cfg.outerAutomation`
   - scheduler implementation: `+autoloop/run_schedule.m`
   - GUI start button now enters outer scheduler, which calls `T1_SemiAuto_Program` as inner flow.
6. Edit save/upload locations:
   - `AutoPipelineConfig.m` -> `cfg.paths.*`

## Outer Automation (Setpoint Loop)

`cfg.outerAutomation` controls the optional outer loop:

- `enabled`: set `true` to run the schedule loop.
- `schedule`: struct array with fields:
  - `temperature`
  - `magneticField`
  - `label` (used for logs and optional figure-title prefix)
  - `settleSec` (optional wait after setting T/B)
- `temperatureHook`: function name for setting temperature (default: `set_temperature`)
- `magneticFieldHook`: function name for setting field (default: `set_magnetic_fields`)
- `allowMissingHooks`: if `true`, missing hooks warn and continue.
- `stopOnSetpointError`: if `true`, any setpoint apply error aborts the run.
- `autoPrefixFigureTitle`: if `true` and `use_title` is checked, prefixes title with setpoint label.

Execution model when enabled:
1. Apply temperature hook for setpoint `i`
2. Apply magnetic-field hook for setpoint `i`
3. Run full inner semi-auto flow (`cfg.stepOrder`)
4. Continue to setpoint `i+1` until done or Stop is pressed

## Slack setup

Set these environment variables before running MATLAB:

- `SLACK_BOT_TOKEN`
- `SLACK_CHANNEL_ID`

Without these, upload calls safely no-op with a console message.
