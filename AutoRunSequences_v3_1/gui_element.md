# GUI Elements For AutoRunSequences_v3_1

This document defines GUI controls and callback wiring for the v3.1 queue layer.

## 1. Main Window (DONE)

Suggested figure name:

- `T1_SemiAuto_Queue_v3_1`

Suggested figure tag:

- `fig_queue_v3_1`

## 2. Queue Table (DONE)

Use a `uitable` for job queue editing and status display.

- Tag: `table_queue_jobs`
- Editable columns:
  - `Enable`
  - `Order`
  - `JobName`
  - `B_set`
  - `T_set`
  - `ProfileName`
- Read-only columns:
  - `Status`
  - `Attempts`
  - `LastResult`
  - `LastTimestamp`

Callbacks:

- `table_queue_jobs_CellEditCallback` 
- `table_queue_jobs_CellSelectionCallback` 

## 3. Job Editing Controls

Basic fields:

- `edit_job_name`
- `edit_job_B_set`
- `edit_job_T_set`
- `checkbox_job_enabled`

Buttons: (DONE)

- `pushbutton_add_job` -> create new job (`v3_1.new_job`, `v3_1.add_job`)
- `pushbutton_clone_job` -> duplicate selected job with new id
- `pushbutton_delete_job` -> remove selected job
- `pushbutton_move_up` -> reorder pending jobs
- `pushbutton_move_down` -> reorder pending jobs
- `pushbutton_capture_v2_profile` -> `v3_1.set_job_profile_from_handles(...)`

## 4. Run Control Buttons (DONE)

- `pushbutton_run_enabled` -> run all enabled jobs in queue order
- `pushbutton_run_selected` -> run selected job(s) only
- `pushbutton_resume_queue` -> load `queue_state.mat` and continue
- `pushbutton_stop_queue` -> graceful stop (`v3_1.request_stop_queue`)
- `pushbutton_stop_all` -> queue + v2.1 stop (`v3_1.request_stop_all`)

## 5. Runtime Job Action Buttons (DONE)

These must be active while queue is running.

- `pushbutton_mark_failed_skip` -> `v3_1.request_current_job_action(...,'mark_failed_skip')`
- `pushbutton_mark_failed_redo` -> `v3_1.request_current_job_action(...,'mark_failed_redo')`
- `pushbutton_redo_selected` -> schedule redo for selected completed/failed job
- `pushbutton_redo_failed` -> schedule redo for all failed jobs

## 6. Campaign/Storage Controls

- `edit_save_root` (text field for queue save root)
- `pushbutton_browse_save_root`
- `text_queue_root` (current run folder path)
- `text_runtime_state` (Idle/Running/Stopping/Stopped/Finished) (DONE)
- `text_current_job` (active `(B,T)` and job name) (DONE)

## 7. Placeholder Control Panel (Optional)

Expose mock behavior toggles for backend placeholder testing:

- `edit_placeholder_set_delay_sec`
- `edit_placeholder_settle_sec`
- `checkbox_force_set_temp_fail`
- `checkbox_force_set_field_fail`
- `checkbox_force_wait_temp_fail`
- `checkbox_force_wait_field_fail`
- `edit_placeholder_temp_offset`
- `edit_placeholder_field_offset`

These map to `runtimeCtx.placeholder` fields consumed by:

- `v3_1.set_temperature_placeholder`
- `v3_1.set_field_placeholder`
- `v3_1.wait_temperature_stable_placeholder`
- `v3_1.wait_field_stable_placeholder`

## 8. Suggested Callback Contract

For each callback, load and save campaign via a single state holder:

1. `campaign = handlesQueue.campaign;`
2. mutate via backend function
3. `handlesQueue.campaign = campaign;`
4. refresh table/status text
5. `guidata(hObject, handlesQueue);`

Long-running run callback (`Run Enabled`/`Resume`) should call:

- `[campaign, report] = v3_1.run_campaign(campaign, runtimeCtx);`

with `runtimeCtx.pullCampaignFcn` configured so runtime button callbacks can update live controls.

## 9. v2.1 Bridge Button (Optional In v2.1 GUI)

If you also add a button in `T1_SemiAuto_ParamInput_v2_1`:

- Tag: `pushbutton_send_to_v3_1_queue`
- Behavior:
  - capture current v2.1 settings
  - send/update selected job profile in v3.1 queue GUI

Backend call target:

- `v3_1.capture_profile_snapshot(handlesAuto)`

## 10. Minimal MVP GUI Set

If you want fastest first GUI pass, implement only:

1. `table_queue_jobs`
2. `pushbutton_add_job`
3. `pushbutton_capture_v2_profile`
4. `pushbutton_run_enabled`
5. `pushbutton_stop_queue`
6. `pushbutton_stop_all`
7. `pushbutton_mark_failed_skip`
8. `pushbutton_mark_failed_redo`
9. `text_runtime_state`
10. `text_current_job`
