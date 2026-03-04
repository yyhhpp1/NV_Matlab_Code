# Agent Brief: Smart T1 Experiment (v2.1 Core + v3.1 Queue)

## 1) Goal Of The Experiment

The experiment automates NV-center T1 measurements across spin transitions, and (in v3.1) across a queue of magnetic field `B` and temperature `T` setpoints.

Core scientific/operational objective:
- Measure T1 robustly for selected transitions (`SQ 0->-1`, `SQ 0->+1`, `DQ -1<->+1`) under aligned and off-axis conditions.
- Use automatic ODMR + Rabi pre-calibration to set frequencies and pi-times before final T1 scans.
- Use rough-T1 scans to adapt final T1 stop time, so final scans are efficient and stable.
- In v3.1, run many `(B_i, T_i)` jobs with per-job v2.1 configuration snapshots, with queue controls (`reorder`, `mark failed skip/redo`, `stop queue`, `stop all`).

## 2) System Structure (What Calls What)

- `AutoRunSequences_v2_1/` is the execution core for one measurement run.
  - Main orchestrator: `AutoRunSequences_v2_1/t1_semi_auto_program.m`
  - Runner used by orchestrator: `AutoRunSequences_v2_1/t1_semi_auto_run.m`
- `AutoRunSequences_v3_1/` is a thin outer layer.
  - Wrapper entrypoint: `AutoRunSequences_v3_1/t1_semi_auto_program_v3_1.m`
  - Queue backend: `AutoRunSequences_v3_1/+v3_1/*.m`

Design intent:
- Keep v2.1 as shared core.
- Add only queue/campaign orchestration in v3.1.
- v2.1 bug fixes/features should propagate to v3.1 automatically.

## 3) Saved Experimental GUI Figures And Artifacts

### 3.1 v2.1 Per-run figure folder

At each v2.1 run start, a run folder is created by:
- `create_run_save_folder(...)` in `AutoRunSequences_v2_1/t1_semi_auto_program.m`

Folder naming:
- `Run_<Btag>_<yyyymmdd_HHMMSS>` under `cfg.paths.saveFolder`
- `cfg.paths.saveFolder` default is in `AutoRunSequences_v2_1/config.m`

### 3.2 Main experimental GUI figure snapshots (saved)

For each executed sequence, main GUI snapshot is saved as PNG:
- Source function: `save_main_figure(...)`
- File name: derived from sequence output text file name (`gSaveDataAve.file`) with `.txt -> .png`
- Location: current v2.1 run folder

For rough T1 attempts, PNG name gets prefix:
- `Rough_T1_<original_name>.png`

So sequence PNGs include (examples):
- `...ODMR...png`
- `...Rabi...png`
- `...Rabi_SG2...png`
- `...T1_S00_S01_S10...png`
- `...T1_S11_S1m1...png`
- Rough versions prefixed with `Rough_T1_...png`

### 3.3 Auto GUI snapshot (saved)

At end of v2.1 run, one Auto GUI snapshot is saved:
- `AutoGUI_v2_1_Final.png`
- Location: same v2.1 run folder

Note:
- Current code saves main GUI snapshots per sequence.
- It does **not** save per-sequence Auto GUI snapshots anymore.

### 3.4 Non-figure but related output in v2.1 run folder

- `analysis_add_entry_snippet.txt`
  - generated at end of run
  - contains add-entry lines for downstream analysis (SQ/DQ final runs)

### 3.5 v3.1 queue-level artifacts

Each queue start creates a queue root:
- `Queue_<yyyyMMdd_HHmmss>_<campaignId>`

Queue root files:
- `queue_state.mat`
- `queue_attempt_log.csv`
- `final_sq_dq_log.csv`

Per-attempt folder shape:
- `Runs/Job_<order>_<jobId>/Attempt_<attemptIdx>/`

Important current behavior:
- v2.1 figures are still saved by v2.1 to its own run folder (`cfg.paths.saveFolder`) unless explicitly redirected.
- Queue logs track attempts/final SQ-DQ summary; ensure figure collection/copy policy is aligned with your active branch if you require figures physically inside each attempt folder.

## 4) Experiment Flow Summary

Single run (v2.1):
1. Read GUI + config.
2. Predict resonances from estimated B.
3. Optional precal: ODMR windows -> peak fit/assignment -> Rabi/PiCal calibration.
4. For each selected target: rough T1 (optional) -> final T1.
5. Save per-sequence GUI PNGs and end-of-run artifacts.

Queue run (v3.1):
1. For each enabled job `(B, T)`: set/wait placeholders for T/B.
2. Apply job-specific v2.1 snapshot.
3. Execute one v2.1 run.
4. Record attempt history and queue logs.
5. Honor runtime controls (stop/reorder/fail skip/fail redo).

## 5) Terms For New Agents

- "Rough T1": fast exploratory T1 used to adapt final stop time.
- "Final T1": production-quality T1 for logging/analysis.
- "PiCal": power sweep to target a desired pi-time before final Rabi confirmation.
- "Merged ODMR window": one ODMR scan containing multiple nearby peaks; fitter must preserve correct peak count and transition mapping.

## 6) If You Are Extending To Another Project

Keep this philosophy:
- Separate inner measurement core (single run) from outer campaign/queue orchestration.
- Keep all policy/config in one place; avoid hardcoding in run logic.
- Save artifacts per run with deterministic naming.
- Preserve traceability: every final figure should map to `(B, T, sequence, attempt)`.
- Make stop/retry/fail actions explicit state transitions, not implicit side effects.
