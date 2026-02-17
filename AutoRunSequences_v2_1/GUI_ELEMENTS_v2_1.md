# GUI Elements For `AutoRunSequences_v2_1`

This file defines the GUI controls expected by the v2.1 backend.
Create these in `T1_SemiAuto_ParamInput.fig` (GUIDE/App Designer equivalent) with the exact tags.

## Selection Panel

- style: `checkbox`, tag: `chk_aligned_sq_m1`, label: `aligned SQ_0_TO_M1`
- style: `checkbox`, tag: `chk_aligned_sq_p1`, label: `aligned SQ_0_TO_P1`
- style: `checkbox`, tag: `chk_aligned_dq`, label: `aligned DQ_M1_TO_P1`
- style: `checkbox`, tag: `chk_off_sq_m1`, label: `offaligned SQ_0_TO_M1`
- style: `checkbox`, tag: `chk_off_sq_p1`, label: `offaligned SQ_0_TO_P1`
- style: `checkbox`, tag: `chk_off_dq`, label: `offaligned DQ_M1_TO_P1`

## Global Inputs

- style: `edit`, tag: `edit_estimated_B_G`, label: `Estimated B (G)`
- style: `checkbox`, tag: `chk_smart_point_distribution`, label: `Smart point distribution (1/4 gets 1/2 points)`

## Program Control Buttons

- style: `pushbutton`, tag: `pushbutton_startProg`, label: `Start Program`
  - callback function in `.m`: `pushbutton_startProg_Callback`
- style: `pushbutton`, tag: `pushbutton_stopProg`, label: `Stop Program`
  - callback function in `.m`: `pushbutton_stopProg_Callback`
  - `UserData` is used as stop flag (`0` run, `1` stop requested)

## Rough T1 Panel

- style: `checkbox`, tag: `chk_enable_rough_scan`, label: `Enable rough T1 pre-scan`
- style: `edit`, tag: `edit_rough_npts`, label: `Rough Npts`
- style: `edit`, tag: `edit_rough_repeat`, label: `Rough Repeat`
- style: `edit`, tag: `edit_rough_average`, label: `Rough Average`
- style: `edit`, tag: `edit_rough_max_retries`, label: `Rough Max Retries`
- style: `edit`, tag: `edit_rough_fit_relerr`, label: `Rough Fit RelErr Threshold`
- style: `popupmenu`, tag: `popup_rough_stop_policy`, label: `Rough Stop Policy`
  - options: `first_good`, `max_retries`

No rough start/stop entries are needed. Rough scan uses each target's T1 range as seed.
`edit_rough_npts` overrides the target/user `npts` only during rough scan.

## Precalibration Panel

- style: `checkbox`, tag: `chk_enable_precal`, label: `Enable precalibration`
  - checked: run ODMR + Rabi precal
  - unchecked: skip precal and use main GUI values (`fixFreq`, `fixFreq2`, `DEERpi`) directly for T1
- style: `edit`, tag: `edit_odmr_power`, label: `ODMR MW Power (dBm)`
- style: `edit`, tag: `edit_rabi_power`, label: `Rabi MW Power (dBm, shared SG1/SG2)`

Unified Rabi scan fields (used by both `Rabi` and `Rabi_SG2`):

- style: `edit`, tag: `edit_precal_rabi_start`, label: `Rabi Start`
- style: `edit`, tag: `edit_precal_rabi_stop`, label: `Rabi Stop`
- style: `edit`, tag: `edit_precal_rabi_npts`, label: `Rabi Npts`
- style: `edit`, tag: `edit_precal_rabi_repeat`, label: `Rabi Repeat`
- style: `edit`, tag: `edit_precal_rabi_average`, label: `Rabi Average`

ODMR precal fields:

- style: `edit`, tag: `edit_precal_odmr_repeat`, label: `ODMR Repeat`
- style: `edit`, tag: `edit_precal_odmr_average`, label: `ODMR Average`
- style: `edit`, tag: `edit_precal_odmr_points_per_mhz`, label: `ODMR Points/MHz`

Power coupling rule in backend:

- `edit_rabi_power` is reused in T1 SG1 and SG2 paths by default.
- If optional tags `edit_rabi_sg1_power` and `edit_rabi_sg2_power` exist, they override the shared value.

## Per-Target T1 Panel (Required)

Use per-target T1 inputs for all 6 targets.
Each target must include 5 fields:

- `start` (style: `edit`)
- `stop` (style: `edit`)
- `npts` (style: `edit`)
- `repeat` (style: `edit`)
- `average` (style: `edit`)

### aligned SQ_0_TO_M1

- `edit_aligned_sq_m1_start`
- `edit_aligned_sq_m1_stop`
- `edit_aligned_sq_m1_npts`
- `edit_aligned_sq_m1_repeat`
- `edit_aligned_sq_m1_average`

### aligned SQ_0_TO_P1

- `edit_aligned_sq_p1_start`
- `edit_aligned_sq_p1_stop`
- `edit_aligned_sq_p1_npts`
- `edit_aligned_sq_p1_repeat`
- `edit_aligned_sq_p1_average`

### aligned DQ_M1_TO_P1

- `edit_aligned_dq_start`
- `edit_aligned_dq_stop`
- `edit_aligned_dq_npts`
- `edit_aligned_dq_repeat`
- `edit_aligned_dq_average`

### offaligned SQ_0_TO_M1

- `edit_off_sq_m1_start`
- `edit_off_sq_m1_stop`
- `edit_off_sq_m1_npts`
- `edit_off_sq_m1_repeat`
- `edit_off_sq_m1_average`

### offaligned SQ_0_TO_P1

- `edit_off_sq_p1_start`
- `edit_off_sq_p1_stop`
- `edit_off_sq_p1_npts`
- `edit_off_sq_p1_repeat`
- `edit_off_sq_p1_average`

### offaligned DQ_M1_TO_P1

- `edit_off_dq_start`
- `edit_off_dq_stop`
- `edit_off_dq_npts`
- `edit_off_dq_repeat`
- `edit_off_dq_average`

## Precalibration Result Display

Use one multi-line display box (instead of 6 per-target precal strings):

- style: `edit` (recommended, inactive), tag: `txt_precal_summary`
  - set `Enable=inactive`
  - set `Max > 1` so multi-line text is shown
  - backend writes 4 lines:
    - `aligned_m1` peak frequency + pi
    - `aligned_p1` peak frequency + pi
    - `off_m1` peak frequency + pi
    - `off_p1` peak frequency + pi

## Rough T1 Display

Add one display field for last rough-fit result:

- style: `text` or `edit` (inactive), tag: `txt_rough_t1_ms`
  - backend writes: target id + rough T1 in ms (+ fit relative error)

## Per-Target Run Status (Optional)

If you still want per-target progress strings, keep these optional tags:

- `txt_status_aligned_sq_m1`
- `txt_status_aligned_sq_p1`
- `txt_status_aligned_dq`
- `txt_status_off_sq_m1`
- `txt_status_off_sq_p1`
- `txt_status_off_dq`
