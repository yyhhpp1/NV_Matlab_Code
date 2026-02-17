# AutoRunSequences_v3_1

`v3.1` is a thin automation layer on top of `AutoRunSequences_v2_1`.

## Design Goal

- Keep `v2.1` as the shared core implementation.
- Put only `v3.1`-specific automation hooks/wrappers here.
- Inherit future `v2.1` bug fixes and feature updates automatically.

## What Is In This Folder

- `T1_SemiAuto_ParamInput_v3_1.m`
  - Launches the existing `v2.1` parameter GUI.
  - Rebinds the Start button to call `t1_semi_auto_program_v3_1`.
- `t1_semi_auto_program_v3_1.m`
  - `v3.1` wrapper entrypoint.
  - Delegates execution to `t1_semi_auto_program` from `v2.1`.
  - Intended location for future pre/post automation hooks.
- `+v3_1/`
  - Queue backend architecture (campaign/job model, run loop, stop controls,
    placeholder T/B API, queue state/log generation).
- `instruction_v3_1.md`
  - Functional spec for v3.1 behavior and policies.
- `gui_element.md`
  - GUI control/tag/callback contract for implementing the queue GUI.

## How To Run v3.1

1. In MATLAB, add `AutoRunSequences_v3_1` to path.
2. Start GUI with:

```matlab
T1_SemiAuto_ParamInput_v3_1
```

Do not launch `T1_SemiAuto_ParamInput_v2_1` directly when you want `v3.1` behavior.

## Update Model

- If `v2.1` is updated, `v3.1` inherits those changes automatically because it calls into `v2.1` at runtime.
- Only add files here when you intentionally want `v3.1`-specific behavior.

## Backend Quick Start

Minimal architecture-level (no GUI) usage:

```matlab
addpath('AutoRunSequences_v3_1');
campaign = v3_1.new_campaign();

job = v3_1.new_job('name','B0T0','B',100,'T',300);
job.profile.snapshot = v3_1.capture_profile_snapshot(handlesAuto); % optional
campaign = v3_1.add_job(campaign, job);

runtimeCtx = struct();
runtimeCtx.executeV21 = false;  % architecture dry-run by default

[campaign, report] = v3_1.run_campaign(campaign, runtimeCtx);
```
