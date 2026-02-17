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
