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
  - Active minimal queue backends:
    - `open_b_queue_minimal_gui`, `run_b_queue_minimal`
    - `open_tb_queue_minimal_gui`, `run_tb_queue_minimal`
    - stop/clear helpers and placeholder set/wait APIs.
- `legacy_t1_queue_v3_1/`
  - Archived `T1_SemiAuto_Queue_v3_1` campaign/job queue implementation and helpers.
  - Not part of active v3.1 workflow.
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

## Minimal B-Queue (Today)

If you only need a queue of B-field points with v2.1 runs:

### GUI

```matlab
addpath('AutoRunSequences_v3_1');
addpath('AutoRunSequences_v3_1/BT_Control');
v3_1.open_b_queue_minimal_gui
```

In the GUI:
1. Open `T1_SemiAuto_ParamInput_v2_1` first.
2. Click `Auto Detect v2.1 GUI`.
3. Enter B list in kG.
4. Click `Run Queue`.
5. Use `Stop Queue` to request stop.

### Script

```matlab
addpath('AutoRunSequences_v3_1');
addpath('AutoRunSequences_v3_1/BT_Control');

% hFigAuto should be your open T1_SemiAuto_ParamInput_v2_1 figure handle.
runtimeCtx = struct( ...
    'hFigAuto', hFigAuto, ...
    'mode', 'driven', ...          % final magnet mode
    'bEstimateScale', 1000, ...    % v2.1 B_estimate is in G
    'writeStartLog', true, ...
    'verbose', true);

out = v3_1.run_b_queue_minimal([0.2 0.5 1.0], runtimeCtx);   % kG list
disp(out.startLogPath);                                       % CSV start log
```

Stop / clear stop:

```matlab
v3_1.request_stop_b_queue_minimal(struct('hFigAuto', hFigAuto));
v3_1.clear_stop_b_queue_minimal(struct('hFigAuto', hFigAuto));
```
