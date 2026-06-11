# AutoRunSequences_v3_2

`v3.2` is now built on top of the tested `v3.1` minimal BT queue flow, not on the older full campaign architecture.

The active workflow is:

1. set one temperature step
2. run one B point
3. for that `(T, B)` point, run `v2.2` at spot 1
4. move to spot 2 and run `v2.2` again
5. continue until all spots are done, then advance to the next B point

## Entry Points

- `open_v3_2_gui.m`
  Opens the minimal BT multi-spot GUI.
- `t1_semi_auto_program_v3_2.m`
  Thin wrapper that ensures `v2.2` is on path and delegates one run to `smart_relaxation_program_v2_2`.

## Active Files

- `open_v3_2_gui.m`
- `t1_semi_auto_program_v3_2.m`
- `+v3_2/run_tb_queue_minimal.m`
- `+v3_2/run_b_queue_multispot.m`
- `+v3_2/master_db_append_rows.m`
- `+v3_2/new_spot.m`
- `+v3_2/move_to_spot.m`
- `+v3_2/read_current_image_spot.m`
- `+v3_2/request_stop_queue_minimal.m`
- `+v3_2/clear_stop_queue_minimal.m`

## GUI Workflow

```matlab
addpath('AutoRunSequences_v3_2');
open_v3_2_gui
```

Then:

1. Add one or more queue steps with `T`, `PID`, and `B list`.
2. Bind the open `v2.2` GUI.
3. Optionally bind `ImageNVC`.
4. Enter spot lines in the spot editor as:
   `SpotName, X_V, Y_V`
5. Use `Import Current Spot` if you want to append the current `ImageNVC` fixed position.
6. Run the queue.

If the spot editor is empty, `v3.2` uses the current laser position and does not try to move `ImageNVC`.

Like the `v3.1` minimal BT queue, this workflow uses the currently open `v2.2` GUI configuration for the whole queue run. It does not store separate per-step `v2.2` snapshots.

## Save Layout

`v3.2` creates one run root per queue execution under `AutoRunSequences_v3_2_Saves` by default.

Inside that root, each B point and spot gets its own folder. `v2.2` writes directly into the spot folder through the `SMART_V2_2_RUN_SAVE_FOLDER_OVERRIDE` appdata hook, so screenshots and figures stay separated by spot.

The queue-level `master_db.csv` is updated immediately after each spot finishes. It now records:

- `measurement_family` (`T1`, `T2`, `T2*`)
- `group` (`Aligned`, `OffAligned`)
- `measurement_type`
- `spot_name`
- `spot_order`
- `spot_folder`

Each spot folder also gets `matlab_command_output.log`, which captures the command-window output produced during that specific spot's move, `v2.2` run, and spot-level post-processing. This is meant for debugging after the run if a spot looks wrong.

If an `ImageNVC` GUI is bound, `v3.2` now:

- moves to the requested spot using the `Fix` path
- triggers one normal `ImageNVC` scan using the GUI's existing scan settings
- reapplies `Fix` so the crosshair marks the measured spot again
- then launches `v2.2`

Each spot folder also gets:

- `ImageNVC_GUI.png`
  - screenshot of the bound `ImageNVC` GUI after the scan and after the `Fix` crosshair is restored, before the `v2.2` run begins

Inside each spot folder, `v2.2` also writes per-sequence logs under `logs/`, so individual ODMR, PiCal, Rabi, rough, and final relaxation runs can be inspected separately.

Each spot folder now also gets a structured `reports/` tree:

- `reports/spot/queue_spot_summary.txt`
  - queue-facing summary for that `(T, B, spot)` item
- `reports/spot/v2_2_run_summary.txt`
  - `v2.2` summary of measurement decisions and exported analysis rows
- `reports/measurements/final/`
  - one compact report per final measurement run
- `reports/measurements/intermediate_precal_rough/`
  - reports for rough scans and precal intermediate runs
- `reports/pical/`
  - PiCal decision reports with memory-prior, sweep-range, and verification-Rabi details
- `reports/failures/`
  - spot-level and sequence-level failure reports when something aborts

Each spot folder now also gets its own `temperature_history/` subfolder. The lookback window used for that save is:

- `max(actual time spent on this spot, tempHistoryCfg.maxLoopbackHours)`

If `tempHistoryCfg.maxLoopbackHours` is not set, `tempHistoryCfg.lookbackHours` is used as the fallback lower bound.

## Runtime Options

The GUI supports:

- `Test mode: skip B/T hardware control`
- `Skip temperature control`
- `Skip magnet control`
- `Skip first magnet check/control`
- `Run TrackZ after each temperature change`

These are queue-level controls. They do not change the queued `T` and `B` values shown in the GUI; they only change whether hardware actions are executed.

## Notes

- `ImageNVC` spot motion uses fixed `FixVx/FixVy` moves only.
- `v3.1` itself is left untouched and still provides the BT control backend that `v3.2` reuses.
- The older `v3.2` campaign-style files are no longer the intended architecture for this version.
- The intended debugging flow after a suspicious run is:
  - read `reports/spot/queue_spot_summary.txt`
  - check `matlab_command_output.log`
  - inspect the relevant file in `reports/measurements/...`
  - inspect `reports/pical/` if the issue involved ODMR/Rabi/PiCal decisions
