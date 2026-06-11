# v3.2 Architecture

## Stack

`v3.2` is now a minimal BT queue plus multi-spot overlay around `v2.2`.

- GUI: `open_v3_2_gui.m`
- single-run wrapper: `t1_semi_auto_program_v3_2.m`
- BT queue backend: `+v3_2/run_tb_queue_minimal.m`
- B-point + spot backend: `+v3_2/run_b_queue_multispot.m`

## Design Choice

This version intentionally follows the tested `v3.1` minimal BT queue pattern instead of the older full campaign/job architecture.

That means:

- one queue row is still one temperature step with a B list
- the outer temperature-control logic still comes from the minimal BT flow
- the new feature is inserted inside each B-point execution as a spot loop
- the currently open `v2.2` GUI config is shared across the run

## Runtime Flow

For each temperature step:

1. optionally set temperature and wait for stabilization
2. iterate the configured B list
3. for each B point:
   - optionally set the magnet and update `B_estimate`
   - resolve the ordered spot list
   - for each spot:
     - move `ImageNVC` fixed XY if needed
     - create the spot folder
     - set `SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE`
     - run one full `v2.2` automation cycle

If no explicit spots are configured, a fallback pseudo-spot representing the current position is used.

## Spot Input Model

The GUI stores spots as plain text lines:

`SpotName, X_V, Y_V`

This keeps the `v3.2` interface close to the simple `v3.1` minimal GUI while still allowing ordered multi-spot runs.

## Save Override Contract

`v3.2` sets appdata key `SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE` before each spot run. `v2.2` then saves directly into that spot folder.

Folder layout is:

- run root
- temperature-step folder
- B-point folder
- spot folder

## Control Flags

Queue-level runtime flags include:

- skip both B/T hardware control (`testModeNoBT`)
- skip temperature control only
- skip magnet control only
- skip first magnet control only

These flags affect hardware actions only. They do not remove the corresponding `T` or `B` queue metadata.
