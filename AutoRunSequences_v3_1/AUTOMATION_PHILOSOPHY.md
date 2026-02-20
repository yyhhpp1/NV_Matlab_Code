# Automation Philosophy (v2.1 -> v3.1 -> Reuse)

## 1) Why This Exists

This document defines the core engineering philosophy behind the v2.1 and v3.1 automation layers.

Use it as the design contract for any future automation project, even when:

1. Sweep parameters are different.
2. Sequence families are different.
3. Calibration methods are different.
4. Hardware wrappers are different.

The physics details can change. The automation philosophy should not.

## 2) v2.1 Core Philosophy (Single-Point Smart Execution)

v2.1 is a robust single-run orchestration layer on top of a stable base runner.

Principles:

1. Do not rewrite proven low-level execution loops unless required.
2. Add intelligence in orchestration/config, not in the hardware core.
3. Use prediction -> optional calibration -> adaptive correction -> final execution.
4. Keep every smart decision explainable and auditable.
5. Keep operator override and stop behavior explicit.
6. Prefer config-driven behavior over hardcoded branch logic.
7. Fail safely with fallback values instead of crashing whole run.
8. Preserve backward compatibility through wrappers and stable entrypoints.

Operational meaning:

1. Smart logic should improve outcomes, not hide state.
2. Every correction (frequency, stop-time, retries) must be logged.
3. If smart steps fail, system should degrade gracefully and continue if safe.

## 3) v3.1 Core Philosophy (Campaign-Level Orchestration)

v3.1 adds an outer loop around v2.1 without duplicating v2.1.

Principles:

1. Thin overlay architecture: outer scheduler calls inner proven engine.
2. One queue item = one setpoint + one full run profile snapshot.
3. Queue execution state is explicit, persisted, and resumable.
4. Runtime controls are first-class: reorder pending jobs, mark fail skip/redo, stop modes.
5. Stop semantics are clear:
   - Stop Queue = graceful boundary stop.
   - Stop All = queue stop + core stop signal.
6. Data layout is deterministic:
   - New queue root per run.
   - New run folder per attempt.
   - Queue-level summary log at stop/finish.
7. History is append-only. Redo adds attempts; it does not erase old evidence.

Operational meaning:

1. Campaign orchestration must never silently alter single-run core behavior.
2. User control decisions during runtime must be durable and visible.
3. Logging is not optional; it is part of the control plane.

## 4) Transferable Architecture Pattern

Use this 4-layer model in new projects:

1. `Core Runner Layer`
   - Minimal, stable, deterministic execution engine.
   - Owns hardware timing-critical logic.

2. `Smart Single-Run Layer`
   - Per-run planning, calibration, adaptive policy.
   - Config-driven.

3. `Campaign Layer`
   - Queue/scheduler over setpoints or conditions.
   - Retry/redo/skip/stop/resume logic.

4. `UI/Operator Layer`
   - Edits queue and per-run profiles.
   - Issues runtime control actions.

Rule: dependencies flow downward only. Outer layers call inner layers. Inner layers do not depend on outer queue logic.

## 5) Non-Negotiable Engineering Rules

1. Single source of truth for execution order and status.
2. Explicit state machine (`pending/running/success/failed/skipped/stopped`).
3. Idempotent persistence and log generation.
4. Fallbacks for non-critical failures.
5. Hard fail only for safety or invalid state corruption.
6. Human-readable logs + machine-readable logs.
7. Every automatic decision must be reproducible from saved state.
8. Runtime user actions must not be lost due to stale state overwrite.
9. Keep GUI files thin; keep logic in backend modules.
10. Preserve compatibility wrappers to avoid breaking existing workflows.

## 6) Decision Hierarchy

When implementing automation decisions, prefer this order:

1. Safety constraints.
2. Data integrity and traceability.
3. Deterministic execution.
4. Operator intent.
5. Performance optimization.

If there is conflict, do not sacrifice 1-3 for speed.

## 7) Failure Model and Recovery Philosophy

Failures should be categorized and handled explicitly:

1. Pre-run setpoint/stabilization failure.
2. Calibration/planning failure.
3. Core execution failure.
4. User-declared failure.
5. Logging/checkpoint failure.

For each category define:

1. Continue policy (`skip_job`, `retry`, `abort_campaign`).
2. What gets persisted immediately.
3. What status the operator sees.

## 8) Profile and Config Philosophy

Each run should be reproducible by a frozen profile snapshot.

Rules:

1. Capture profile snapshot at queue bind time.
2. Keep snapshot immutable per attempt.
3. Editing creates a new snapshot revision.
4. Do not rely on ambient GUI state at execution time.

## 9) Observability Philosophy

At minimum, persist:

1. Commanded setpoint values.
2. Attempt index and timestamps.
3. Profile revision/hash.
4. Outcome and error reason.
5. Output artifact paths.

Campaign end should generate a compact summary view for quick triage.

## 10) How To Instruct Future Agents

When starting a new automation project, give the agent this contract:

1. Keep core runner stable.
2. Build smart behavior in orchestration layer.
3. Build campaign scheduler as thin outer loop.
4. Use explicit state machine and checkpointing.
5. Implement graceful fallback and deterministic logs.
6. Keep GUI callback-only, backend logic modular.
7. Prove stop semantics and runtime control behavior.

## 11) Short Prompt Template For New Projects

Use this starter prompt with an agent:

\"Implement automation using the v2.1/v3.1 philosophy: stable core runner, smart single-run orchestration, queue-based campaign overlay, explicit state machine, append-only attempt history, deterministic storage layout, graceful stop queue vs stop all semantics, and callback-thin GUI with backend modules. Keep behavior config-driven and fully logged.\"

