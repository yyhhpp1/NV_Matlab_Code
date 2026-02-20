# BT_Control (Standalone)

Standalone high-level Z-magnet control (not integrated with v3.1 queue runner).

## Entry Point

- `set_z_magnet_mode.m`
- `run_b_field_queue_v2_1.m`
- `request_stop_b_field_queue.m`
- `clear_stop_b_field_queue.m`
- `set_temperature_safe.m`
- `bf_tc_read_latest_channel.m`
- `bf_tc_set_heater4.m`
- `mag_z_gate_precheck.m`

## Usage

```matlab
addpath('AutoRunSequences_v3_1/BT_Control');

% Driven final mode at 1200 kG
[ok, msg, info] = set_z_magnet_mode(1200, 'driven');

% Persistent mode at 850 kG with custom timing/ramp config
cfg = struct( ...
    'pollSec', 0.25, ...
    'verbose', true);
[ok, msg, info] = set_z_magnet_mode(850, 'persistent', cfg);

% Safe temperature set example (CH8 control, CH3 safety, heater 4)
tcfg = struct( ...
    'tcIp', '192.168.0.145', ...
    'magIp', '192.168.0.101', ...
    'T_safe_max', 6.0, ...
    'T_tol', 0.02, ...
    'holdSec', 30, ...
    'maxWaitSec', 1800, ...
    'pollSec', 2.0, ...
    'pidP', 1.0, ...
    'pidI', 0.1, ...
    'pidD', 0.0, ...
    'verbose', true);
[okT, msgT, infoT] = set_temperature_safe(4.2, tcfg);

% Minimal B queue (targets in kG):
cfgQ = struct( ...
    'hFigAuto', hFigAuto, ...      % T1_SemiAuto_ParamInput_v2_1 figure handle
    'mode', 'driven', ...          % final magnet mode
    'magnetCfg', struct('verbose', true), ...
    'bEstimateScale', 1000, ...    % B_estimate is in G: B_estimate = kG * 1000
    'writeStartLog', true, ...
    'verbose', true);
out = run_b_field_queue_v2_1([0.2 0.5 1.0], cfgQ);
disp(out.startLogPath);            % CSV with v2.1 start timestamps per B

% Stop queue request:
request_stop_b_field_queue(struct('hFigAuto', hFigAuto));
```

## Defaults

- Endpoint: `192.168.0.101:7185`
- Mode input: `'driven'` or `'persistent'` (final mode after motion)
- Units forced to `kG` (`CONF:FIELD:UNITS 0`) each call by default
- Zero-first behavior is always enabled

## Behavior Summary

1. Queries `PERSistent?` to determine starting mode.
2. If starting persistent, sends `PS 1`, waits `hsHeatUpMinBufferSec` (default 30 s), then checks heater transition.
3. Sends `ZERO` and waits `STATE? == 8`.
4. Ramps to target and waits `STATE? == 2` (unless target is `0` and duplicate second ramp is skipped).
5. Applies buffer wait (`psOffBufferSec`) after each completed ramp stage:
   - after down-ramp to zero (`STATE? == 8`)
   - after up-ramp to target (`STATE? == 2`, when executed)
6. Applies final requested mode:
   - `driven`: send `PS 1`, wait `hsHeatUpMinBufferSec` (default 30 s), then verify transition.
   - `persistent`: send `PS 0`, wait `hsCoolDownMinBufferSec` (default 30 s), then wait `PERSistent? == 1`.
7. Fails on timeout, quench (`STATE 7`), external rampdown (`STATE 11`), parse errors, or non-zero `SYST:ERR?`.

## Extra Config Fields

- `skipSecondRampIfTargetZero` (default: `true`)
- `waitPersistentBy` (default: `'pers_query'`)
- `psOffBufferSec` (default: `10`, applied after every completed ramp stage)
- `hsHeatUpMinBufferSec` (default: `30`, minimum wait after `PS 1`)
- `hsCoolDownMinBufferSec` (default: `30`, minimum wait after `PS 0`)

## Fixed Internal Settings

The program intentionally does not take these from `cfg`:

- `rampTimeoutSec = 1800`
- `zeroTimeoutSec = 1800`
- `heaterTimeoutSec = 120`
- `persistentTimeoutSec = 800`
- `rampRatekGPerMin` is not set by this program

## Temperature Safety Policy (set_temperature_safe)

- Pre-check magnet gate uses Z magnet `PS?` and `STATE?`; requires `PS=0` and `STATE=8`.
- If pre-check magnet gate fails: abort and keep heater state unchanged.
- Pre-check CH:3 (`T_safe_max`) is enforced before heater ON.
- If pre-check CH:3 is high: send heater 4 OFF (`active=false`) and abort.
- During ramp: monitor CH:8 and CH:3 only (no magnet-gate recheck).
- If CH:3 rises above threshold during ramp: heater OFF and abort.
- On successful stabilization: heater remains ON.
