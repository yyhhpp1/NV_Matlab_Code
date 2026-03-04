# AutoRunSequences_v3_1 Instruction (Spec Only, No Code Yet)

## 1. Purpose

`v3.1` adds an outer automation layer on top of `v2.1` to run a queued campaign over multiple temperature and magnetic-field setpoints.

Each queue item is one `(B_i, T_i)` job with its own `v2.1` measurement configuration.

## 2. Core Requirement

Support a queue where users can:

1. Add multiple `(B, T)` jobs.
2. Attach a custom `v2.1` config/profile to each job.
3. Reorder jobs before running.
4. Re-run failed or selected jobs without losing history.
5. During running, change pending-job order and declare the current job failed with `skip` or `redo` intent.
6. Start each queue run in a new folder, with each `v2.1` run saved in its own run folder.

## 3. Scope

In scope for `v3.1`:

1. Queue management UI and data model.
2. Per-job `v2.1` profile capture and restore.
3. Execution orchestration across queue items.
4. Checkpoint/resume and job history.
5. Placeholder hooks for setting and stabilizing `T` and `B`.

Out of scope for this task:

1. Real temperature controller driver integration.
2. Real magnet power supply driver integration.
3. Refactor of `v2.1` core logic.

## 4. Architecture Principle

`v3.1` remains a thin overlay.

1. `v2.1` stays the execution core for a single measurement run.
2. `v3.1` controls campaign flow and calls into `v2.1`.
3. New `v2.1` bug fixes/features should automatically propagate to `v3.1` unless explicitly overridden.

## 5. User Stories

1. Queue heterogeneous jobs:
   - `(B0,T0)`: aligned SQ(0,-1), rough enabled, precal enabled.
   - `(B1,T1)`: aligned SQ(0,+1) + aligned DQ, rough disabled, precal enabled.
   - `(B2,T2)`: all 6 targets with full smart features enabled.
2. Capture current `v2.1` GUI settings into queue item `(B_i,T_i)`.
3. Reorder queue by move up/down or drag-style ordering.
4. Re-run one job or all failed jobs.
5. Resume after interruption from last unfinished queue item.

## 6. UX Concept

Recommended UI split:

1. Keep current `v2.1` GUI as-is for detailed profile editing.
2. Add a new `v3.1` Campaign Queue GUI.
3. Add a bridge action:
   - In `v2.1`: `Capture Current Config -> Queue Item`.
   - Or in `v3.1`: `Import Current v2.1 Settings`.

Queue table minimum columns:

1. `Enable`
2. `Order`
3. `JobName`
4. `B_set`
5. `T_set`
6. `ProfileName`
7. `Status`
8. `Attempts`
9. `LastResult`
10. `LastTimestamp`

Queue actions:

1. `Add Job`
2. `Capture v2.1 Config`
3. `Edit Job`
4. `Clone Job`
5. `Move Up`
6. `Move Down`
7. `Delete`
8. `Run Enabled`
9. `Run Selected`
10. `Stop Queue` (graceful)
11. `Stop All` (queue + v2.1 core stop)
12. `Redo Selected`
13. `Redo Failed`
14. `Resume`
15. `Mark Current Failed -> Skip`
16. `Mark Current Failed -> Redo`

Runtime interaction rules:

1. Reorder is allowed for `pending` jobs while campaign is running.
2. Current `running` job cannot be physically moved until it finishes.
3. `Mark Current Failed` is a latched user intent; it does not hard-interrupt `v2.1` by itself.

## 7. Data Model (Draft)

Each queue item (job) stores:

1. `id` (stable unique key)
2. `enabled` (bool)
3. `order` (int)
4. `name` (string)
5. `setpoint.B` (double, unit documented)
6. `setpoint.T` (double, unit documented)
7. `profile.snapshot` (struct of `v2.1` parameters for this job)
8. `runtime.retry.maxAttempts` (int)
9. `runtime.retry.policy` (`skip_job` | `abort_campaign`)
10. `runtime.timeout.settleSec` (double)
11. `status.state` (`pending|running|success|failed|skipped|stopped`)
12. `status.attemptCount` (int)
13. `history` (array of attempt records)
14. `status.userDeclaredFailed` (bool, default false)
15. `status.userFailAction` (`none|skip|redo`)

Campaign-level state:

1. `campaignId`
2. `createdAt`
3. `lastSavedAt`
4. `currentJobId`
5. `isRunning`
6. `stopRequested`
7. `jobs` (ordered array)
8. `runtimeControl.stopMode` (`none|stop_queue|stop_all`)
9. `runtimeControl.currentJobAction` (`none|mark_failed_skip|mark_failed_redo`)

## 8. Execution Flow (Per Job)

For each enabled job in order:

1. Mark job `running`.
2. Apply placeholder setpoint calls:
   - `set_temperature_placeholder(T_set)`
   - `set_field_placeholder(B_set)`
3. Apply placeholder stabilization calls:
   - `wait_temperature_stable_placeholder(...)`
   - `wait_field_stable_placeholder(...)`
4. Restore this job's `v2.1` profile snapshot.
5. Launch one `v2.1` run.
6. Record outputs, timestamps, and run status.
7. On failure, follow retry policy.

Runtime-control overlays:

1. If user reorders queue during execution, only `pending` jobs are reordered.
2. If user triggers `Mark Current Failed -> Skip`, set a latch and let current `v2.1` run finish; then force job final state to `failed`, do not auto-retry, continue to next pending job.
3. If user triggers `Mark Current Failed -> Redo`, set a latch and let current `v2.1` run finish; then force job final state to `failed` and enqueue a redo attempt (same job id, new attempt record).
4. If `Stop Queue` is requested, do not start a new job after current `v2.1` run returns.
5. If `Stop All` is requested, set queue stop and also forward stop to `v2.1` core stop path immediately.

## 8.1 Data Storage Layout

Queue root policy:

1. Each time user starts a queue run, create a new queue root folder.
2. Suggested naming: `Queue_<yyyyMMdd_HHmmss>_<campaignId>`.

Per-run policy:

1. For each `v2.1` execution attempt, create a dedicated run folder under that queue root.
2. Suggested path shape:
   - `<queue_root>/Runs/Job_<order>_<jobId>/Attempt_<attemptIdx>/`
3. Store figures from that `v2.1` run in its run folder.

Queue-root files:

1. `queue_state.mat` for checkpoint/resume.
2. `queue_attempt_log.csv` for attempt-level trace.
3. `final_sq_dq_log.csv` for queue-level final (non-rough) SQ/DQ summary.

## 9. Placeholder API Contract (No Hardware Yet)

Define stub contracts now so hardware integration can replace internals later:

1. `set_temperature_placeholder(T_target)` -> `{ok, message}`
2. `set_field_placeholder(B_target)` -> `{ok, message}`
3. `wait_temperature_stable_placeholder(T_target, cfg)` -> `{ok, actualT, message}`
4. `wait_field_stable_placeholder(B_target, cfg)` -> `{ok, actualB, message}`

Current expected behavior:

1. Deterministic mock success/failure modes for testing.
2. Configurable delay to emulate settling.

## 10. Profile Capture Rules

`v3.1` must capture job-specific `v2.1` settings including:

1. Target enable flags (6 targets).
2. Per-target T1 parameters (`start, stop, nPoints, repeat, average`).
3. Rough scan options.
4. Precal options and power settings.
5. Smart options that affect sequence generation.

Capture mode:

1. Snapshot is immutable per queued attempt.
2. Editing a job creates a new snapshot revision.

## 11. Reorder / Redo Behavior

Reorder:

1. Order index is authoritative.
2. Reorder updates only queue metadata, not attempt history.
3. While running, reorder applies only to `pending` jobs; `running` job is position-locked.

Redo:

1. Redo does not overwrite old attempt records.
2. Redo appends a new attempt entry under same job `id`.
3. Optional mode: clone as a new job if user wants independent branching.
4. User can request redo during active run by `Mark Current Failed -> Redo`; redo is scheduled after active run returns.

Declare-failed during run:

1. `Mark Current Failed -> Skip` means treat current attempt as failed and move on after current `v2.1` call exits.
2. `Mark Current Failed -> Redo` means treat current attempt as failed and append another attempt for the same `(B_i,T_i)` job.
3. Both actions are soft controls unless user also presses `Stop All`.

## 12. Stop, Resume, and Checkpoint

Stop:

1. `Stop Queue` sets a global queue stop flag and allows current `v2.1` measurement to finish.
2. After current job returns, campaign transitions to `stopped` without launching the next job.
3. `Stop All` performs `Stop Queue` and also sends stop to `v2.1` core (same effect as pressing v2.1 stop control).
4. `Stop All` is the only stop mode intended to interrupt the active `v2.1` run.

Resume:

1. Restore campaign state from checkpoint file.
2. Continue from first unfinished enabled job.

Checkpoint save triggers:

1. Queue modification
2. Job start
3. Job end
4. Stop request
5. Error transition

Queue-end summary generation:

1. When queue finishes normally, generate/update `final_sq_dq_log.csv`.
2. When queue is stopped by user (`Stop Queue` or `Stop All`), also generate/update `final_sq_dq_log.csv` using completed runs so far.
3. Summary generation should be idempotent and not duplicate rows for the same run artifact.

## 13. Logging and Traceability

For each attempt, store:

1. `jobId`, `attemptIdx`
2. Commanded `(B_set, T_set)`
3. Placeholder measured/returned `(B_actual, T_actual)` if available
4. Start/end timestamps
5. `v2.1` profile hash or revision id
6. Outcome (`success|failed|skipped|stopped`)
7. Error text when failed
8. Output data path / run folder

Queue-level final SQ/DQ summary (`final_sq_dq_log.csv`):

1. Include final measurements only (exclude rough figures).
2. Include SQ and DQ records for each `(B,T)` where final figure exists.
3. Each row should include:
   - `campaignId`
   - `jobId`
   - `attemptIdx`
   - `B_set`
   - `T_set`
   - `sequenceName`
   - `date`
   - `aveFigureName` (the figure filename used as Ave/final output)
   - `figurePath`
4. Sequence names should reflect the actual v2.1 sequence, e.g. `T1_S00_S01_S10` (SQ) and `T1_S11_S1m1` (DQ).

## 14. Error Handling Policy

Failures can occur at:

1. Setpoint stage
2. Stabilization stage
3. `v2.1` run stage
4. Save/checkpoint stage
5. User-declared failure during run

Policy options per campaign or job:

1. `skip_job` and continue next enabled job.
2. `abort_campaign` immediately.

## 15. Non-Goals (Explicit)

1. No change to `v2.1` physics model logic in this phase.
2. No new fitting model in this phase.
3. No hardware-specific command protocol in this phase.

## 16. Suggested Deliverables for Next Coding Phase

1. `v3.1` queue GUI skeleton.
2. Queue state `.mat` schema and persistence helpers.
3. `v2.1` config snapshot capture/restore utilities.
4. Outer campaign runner with placeholder T/B hooks.
5. Stop/resume and redo operations.

## 17. Acceptance Criteria (Spec-Level)

1. User can define at least 3 jobs with different `(B,T)` and different `v2.1` profiles.
2. User can reorder jobs and run in new order.
3. User can re-run one failed job without deleting prior attempt history.
4. Campaign can stop and resume from checkpoint.
5. `v3.1` still executes actual measurement via `v2.1` core path.
6. During running, user can reorder `pending` jobs.
7. During running, user can mark current job failed as `skip` or `redo`.
8. `Stop Queue` waits for active `v2.1` run to finish; `Stop All` also stops `v2.1` core.
9. Each queue start creates a unique queue root folder, and each `v2.1` run writes figures to its own run folder.
10. On queue finish or user stop, queue root contains `final_sq_dq_log.csv` listing final (not rough) SQ/DQ results by sequence name, date, and ave figure name for each `(B,T)`.

