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
5. Edit save/upload locations:
   - `AutoPipelineConfig.m` -> `cfg.paths.*`

## Slack setup

Set these environment variables before running MATLAB:

- `SLACK_BOT_TOKEN`
- `SLACK_CHANNEL_ID`

Without these, upload calls safely no-op with a console message.
