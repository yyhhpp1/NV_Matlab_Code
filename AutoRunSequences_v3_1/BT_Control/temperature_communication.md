# Temperature Communication (Current Implementation)

This document describes how temperature communication currently works in:

- `AutoRunSequences_v3_1/BT_Control/set_temperature_safe.m`
- `AutoRunSequences_v3_1/BT_Control/bf_tc_read_latest_channel.m`
- `AutoRunSequences_v3_1/BT_Control/bf_tc_set_heater4.m`
- `AutoRunSequences_v3_1/BT_Control/bf_tc_read_heater.m`
- `AutoRunSequences_v3_1/BT_Control/bf_tc_set_heater4_verified.m`
- `AutoRunSequences_v3_1/BT_Control/autotune_pid_temperature_range.m`
- `AutoRunSequences_v3_1/BT_Control/overnight_stabilize_temperature.m`

## Scope

Current code supports:

1. Read temperature from Bluefors channels.
2. Set temperature target indirectly by enabling heater control with setpoint + PID.
3. Set heater ON/OFF (heater 4).
4. Set PID values when turning heater ON.
5. Read heater settings/state via `POST /heater`.
6. Verify set PID against queried PID with tolerance/min rules.

Current code now provides:

1. `bf_tc_read_heater(...)` for heater/PID readback.
2. `bf_tc_set_heater4_verified(...)` for set-and-verify flow.
3. `overnight_stabilize_temperature(...)` for fixed-setpoint overnight stabilization (conventional mode).

## Fixed Mapping Used by Current Code

In `set_temperature_safe.m`:

- Control temperature channel: `CH:8`
- Magnet safety temperature channel: `CH:3`
- Heater number: `4`

## Network/API Basics

- Protocol: HTTP (JSON)
- Device address format: `http://<tcIp>:5001/...`
- Implemented endpoints:
  1. `POST /channel/historical-data`
  2. `POST /heater/update`
  3. `POST /heater`

## Read Temperature

Implemented by `bf_tc_read_latest_channel(deviceIP, channelNr, lookbackMin)`.

### Request

`POST http://<tcIp>:5001/channel/historical-data`

Payload:

```json
{
  "channel_nr": 8,
  "start_time": "UTC ISO8601",
  "stop_time": "UTC ISO8601",
  "fields": ["temperature", "timestamp"]
}
```

### Response Handling

- Requires `HTTP 200`.
- Requires top-level `status == "OK"`.
- Requires `measurements.temperature` and `measurements.timestamp`.
- Uses the **latest sample** (last element) as current reading.

Return values:

- `ok` (logical)
- `T_K` (latest temperature in K)
- `tOut` (UTC timestamp string)
- `message`
- `respData` (raw decoded response)

## Set Temperature (Current Meaning)

There is no separate "set temperature" endpoint in current code.

Current implementation sets temperature by:

1. Sending heater ON command (`active=true`) on heater 4.
2. Including target setpoint and PID values in that command.
3. Polling `CH:8` until target is within tolerance for hold time.

This is handled by `set_temperature_safe(TtargetK, cfg)`.

## Set PID Settings (Current Meaning)

PID is set in `bf_tc_set_heater4(deviceIP, true, cfg)` when heater is enabled.

Required fields for ON:

- `cfg.setpointK`
- `cfg.pidP`
- `cfg.pidI`
- `cfg.pidD`

Optional fields for ON:

- `cfg.pidMode` (default `1`)
- `cfg.controlAlgorithm` (integer, optional)

Payload sent:

```json
{
  "heater_nr": 4,
  "active": true,
  "pid_mode": <pidMode>,
  "control_algorithm": <optional integer>,
  "setpoint": <setpointK>,
  "control_algorithm_settings": {
    "proportional": <pidP>,
    "integral": <pidI>,
    "derivative": <pidD>
  }
}
```

## Read PID Settings (Current Status)

Implemented via `bf_tc_read_heater(deviceIP, heaterNr)`.

- Endpoint: `POST /heater`
- Payload:

```json
{
  "heater_nr": 4
}
```

- PID readback source:
  - `control_algorithm_settings.proportional`
  - `control_algorithm_settings.integral`
  - `control_algorithm_settings.derivative`

## Set-and-Verify PID

Implemented via `bf_tc_set_heater4_verified(deviceIP, active, cfgSet, cfgVerify)`.

For `active=true`:

1. Send `/heater/update` with requested PID.
2. Query `/heater` readback.
3. Verify `abs(read-set) <= verifyTol` for P/I/D.
4. Verify readback PID terms are >= `pidMin`.
5. If first attempt fails (set/query/parse/compare) and `verifyRetryWithMinClamp=true`, retry once with
   clamped PID (`max(term, pidMin)`), then re-verify.
6. Set `verbose=true` to print runtime set/query/verify progress.

## Controller Mode Mapping (Conventional vs Step)

Autotune uses canonical internal coefficients `(Kp, Ki, Kd)` and maps them to controller
coefficients based on `cfg.pidControlMode`:

1. `conventional`:
- sent coefficients interpreted as `(K, Ti, Td)`
- mapping: `K=Kp`, `Ti=Kp/Ki` (bounded), `Td=Kd/Kp`
2. `step`:
- sent coefficients interpreted as `(K1, K2, K3)`
- mapping (manual definition): `K1=100*Kp`, `K2=100*Ki`, `K3=100*Kd`
- scale factor is configurable by `cfg.stepCoeffScale` (default `100`)

## Set Heater ON/OFF

Implemented by `bf_tc_set_heater4(deviceIP, active, cfg)`.

### Heater ON

- Endpoint: `POST /heater/update`
- Payload includes `heater_nr=4`, `active=true`, `pid_mode`, setpoint, PID settings, and optional `control_algorithm`.

### Heater OFF

- Endpoint: `POST /heater/update`
- Payload:

```json
{
  "heater_nr": 4,
  "active": false
}
```

## Read Heater State (Current Status)

Implemented as dedicated readback via `bf_tc_read_heater(...)`.

Command success for write paths still also checks:

1. HTTP response code.
2. API `status == "OK"` in response body.

## Safety Logic in `set_temperature_safe`

Current high-level flow:

1. Magnet gate pre-check (`PS=0` and `STATE=8`) via `mag_z_gate_precheck`.
2. Pre-check `CH:3` against `T_safe_max`.
3. If pre-check CH:3 too high: send heater OFF and abort.
4. Send heater ON with setpoint + PID.
5. During ramp, monitor only `CH:8` and `CH:3`.
6. If runtime CH:3 exceeds limit: heater OFF and abort.
7. If CH:8 settles within `T_tol` for `holdSec`: success, heater remains ON.

## Minimal Function Usage

### Read channel temperature

```matlab
[ok, T8, t8, msg] = bf_tc_read_latest_channel('192.168.0.145', 8, 5);
```

### Heater ON with setpoint and PID

```matlab
cfg = struct('setpointK', 4.2, 'pidP', 1.0, 'pidI', 0.1, 'pidD', 0.0);
[ok, msg] = bf_tc_set_heater4('192.168.0.145', true, cfg);
```

### Heater OFF

```matlab
[ok, msg] = bf_tc_set_heater4('192.168.0.145', false, struct());
```

### Read heater/PID settings

```matlab
[ok, heater, msg] = bf_tc_read_heater('192.168.0.145', 4);
```

### Set and verify heater PID

```matlab
cfgSet = struct('setpointK', 4.2, 'pidP', 1.0, 'pidI', 0.1, 'pidD', 0.0);
cfgVerify = struct('verifyTol', 1e-12, 'pidMin', 0, 'verifyRetryWithMinClamp', true, 'verbose', true);
[ok, msg, out] = bf_tc_set_heater4_verified('192.168.0.145', true, cfgSet, cfgVerify);
```

### Standalone PID autotune over range

```matlab
acfg = struct( ...
    'tcIp', '192.168.0.145', ...
    'pidBounds', struct('Pmin', 0, 'Pmax', 50, 'Imin', 0, 'Imax', 50, 'Dmin', 0, 'Dmax', 50), ...
    'initialPid', struct('P', 1.0, 'I', 0.1, 'D', 0.0), ...
    'pidControlMode', 'step', ...                     % run/validation mode
    'identificationPidControlMode', 'conventional', ... % Stage-B mode
    'pidModeValue', 1, ...
    'identificationPidModeValue', 1, ...
    'stepControlAlgorithm', 2, ...
    'conventionalControlAlgorithm', 1, ...
    'idStepDeltaK', [3.8 0.02; 20 0.05; 80 0.20], ... % scalar | Nx2 schedule | function_handle(T)
    'profileMonotonicMode', 'off', ...               % 'off'|'nondecreasing'|'nonincreasing'
    'profileExtrapolation', 'extrap');
[ok, msg, result] = autotune_pid_temperature_range([3.8 4.2], 3, acfg);
```

Notes:

1. `autotune_profile.csv` stores canonical coefficients `(Kp, Ki, Kd)`.
2. Controller coefficients for selected mode are stored in `result.profile.controllerCoeffNames`
   and applied internally during set-and-verify.
3. Stage A/C/final hold use `pidControlMode`; Stage B (identification) can use
   `identificationPidControlMode` for mixed-mode tuning.

### Overnight fixed-setpoint stabilizer (conventional mode)

```matlab
ocfg = struct( ...
    'tcIp', '192.168.0.145', ...
    'initialPid', struct('P', 0.05, 'I', 250, 'D', 0), ...   % K,Ti,Td
    'pidBounds', struct('Pmin', 0, 'Pmax', 1, 'Imin', 1, 'Imax', 2000, 'Dmin', 0, 'Dmax', 100), ...
    'durationSec', 10*3600, ...
    'verbose', true);
[ok, msg, out] = overnight_stabilize_temperature(0.02, ocfg);
```

### Safe temperature procedure

```matlab
cfg = struct( ...
    'tcIp', '192.168.0.145', ...
    'magIp', '192.168.0.101', ...
    'T_safe_max', 6.0, ...
    'T_tol', 0.02, ...
    'holdSec', 30, ...
    'maxWaitSec', 1800, ...
    'pollSec', 2.0, ...
    'pidP', 1.0, ...
    'pidI', 0.1, ...
    'pidD', 0.0);
[ok, msg, info] = set_temperature_safe(4.2, cfg);
```

