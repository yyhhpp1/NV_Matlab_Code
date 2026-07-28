# HeliCam Widefield — Work Handoff

State of the HeliCam C4 widefield lock-in integration in `MATLAB_Code_DF`.
Branch: **`df_with_helicam`** (remote `yyhhpp1/NV_Matlab_Code`).

---

## Current blocker

`readIQ` times out: the camera configures successfully but never returns data.

Last observed run (`hc_Image`):
```
[HeliCam] Connected: interface 0, device 0 (warmup discard 0 frames).
[HeliCam] Lock-in (DivideBy4) configured: exposure 0.000817 s
          (n=65359, f_ref 306.0 Hz, actual 306.0 Hz), 1 periods, 4 frames.
Error using HeliCamInterface/readIQ
Message: Timeout, no data available!
```

Interpretation: the camera is waiting for reference edges on its input line and
not getting what it needs. **Unverified assumption: that PB pin 9 (`CamRef`) is
physically cabled to the camera input the code selects (`FI2` by default).**

### Next step — run the minimal trigger test

```matlab
Experiment_PB_DAQ      % opens once; Initialize creates global gCam
hc_TriggerTest         % default 'line' mode
```

`hc_TriggerTest` (mode `'line'`) toggles PB pin 9 and reads the camera's
`LineStatusAll` register. No acquisition, no triggers — it cannot time out and
cannot disturb camera state.

Decision tree:

| Result | Meaning | Action |
|---|---|---|
| `SIGNAL SEEN. Bit(s) toggled: [n]` | camera sees PB pin 9 | identify which input that bit is; set `cfg.refSourceSignal` to match (`'FI2'`/`'FI3'`), retest `hc_Image` |
| `NO CHANGE` | signal never reaches camera | scope PB pin 9 (does it pulse?), check cable + connector |

Other modes: `hc_TriggerTest('manual')` samples 30 s while you toggle the line
yourself; `hc_TriggerTest('record','FI3')` arms a real RecordingStart burst.

### If wiring turns out fine

Then the reference *rate/lock* is the suspect. `LockInExpectedFrequencyDeviation`
is currently hardcoded to `0` in `HeliCamInterface.configLockInMode` (strict lock).
Allowing 5–10 % lets the camera tolerate the exposure-grid snap. That is the next
lever, not yet tried.

Also sanity-check the `readout` GUI value: `f_ref` landed on the 306 Hz floor,
which means `readout` was ≳ 819 µs. If ~100 µs was intended, that field is wrong.

---

## Hard constraints (do not violate)

1. **No GUI / `.fig` edits.** The user edits GUIDE layouts manually. Provide
   backend only. When a GUI control is needed, implement the backend to read
   `gmSEQ.<field>` with an `isfield` + fallback default, and *tell* the user what
   widget/tag to add plus the one line for `getUserInputFromGUI`.
2. **Do not modify PulseBlaster low-level code** (`mytoolboxes/PulseBlaster/`,
   `PBFunctionPool.m`). The PB looping is believed correct.
3. **Never re-open the C4 SDK in one MATLAB session.** Creating a second
   `C4HandlerCLR` / calling `reset()`/`openDevice` on a held device crashes the
   .NET runtime (`0xe0434352`) and MATLAB cannot catch it. `Initialize` reuses an
   existing valid `gCam`. To release deliberately: `HeliCamRelease`.
4. Camera features like `TriggerSource`/`TriggerSelector` are **not writable
   while acquisition is active** (GenICam NULL-pointer exception). Call
   `stopAcq()` before writing them.

---

## Lab PC setup

- Windows 11, MATLAB R2023b.
- **MATLAB path must include** `mytoolboxes\HeliCam` and `Sequences\HeliCam_seq`
  (git does not manage the MATLAB path).
- HeliCam SDK (`C4HdlCLR.dll`) installed separately — not in this repo.
- Camera and PC must share a subnet (resolved: camera moved onto `192.168.0.x`).
- To select the detector: `PortMap.m` → `case 'meas'` → `path='HeliCam';`
- To run with FPGA/SRS absent: set them `false` in `InstrumentEnabled.m`.
- `WidefieldConfig.m` → `useFakeCamera = false` for real hardware, `true` for a
  hardware-free code-path test.

---

## Architecture

Detector routing: `RunSequence` dispatches to `RunSequence_HeliCam` when
`gmSEQ.meas == 'HeliCam'`, bypassing all NI-DAQ counter logic (`ctrN = 1`).

```
mytoolboxes/HeliCam/
  HeliCamInterface.m   C4HdlCLR .NET wrapper (external-ref DivideBy4 lock-in)
  FakeCamera.m         synthetic stub, same protocol
  WidefieldConfig.m    central config (exposure, nFrames, ROI, refSourceSignal, ...)
  HeliCamRelease.m     deliberate disconnect + clear gCam
  hc_TriggerTest.m     wiring / trigger diagnostics
Sequences/HeliCam_seq/
  hc_Image.m           laser in Q1 only -> I = Q1 is a plain image (alignment)
  hc_Rabi.m            MW duration swept in Q2
  hc_T1.m              Q2+Q3 carry the swept dark wait
  hc_ODMR.m            fixed pi in Q2; sweep is MW frequency
InstrumentEnabled.m    per-instrument enable/disable switchboard
RunSequence.m          RunSequence_HeliCam, DisplayWidefield, SaveWidefield
```

Two distinct globals:
- **`gCam`** — the camera *object* (hardware handle, persists for the session).
- **`gWide`** — the acquired *data* struct (`reference`, `rawsignal`, `signal`,
  each `H×W×N`), rebuilt every run.

### Measurement model (see `docs/helicam_pulsed_measurement_notes.md`)

External-reference **DivideBy4**: PB emits one `CamRef` edge per quarter bin, so
every edge starts a new quarter of demodulation and the camera is hardware-locked
to PB. Quarter mapping: Q1 init/reference laser, Q2 MW, Q3 dark, Q4 readout.

```
I = Q1 - Q3   ->  reference = mean(I)
Q = Q2 - Q4   ->  signal    = -mean(Q)
contrast = signal ./ reference     (derived, never stored)
```

Timing wiring in `RunSequence_HeliCam`:
- `nPeriods = 1`; `nFrames = max(4, GUI Repeat)`; `Repeat = Samples = nFrames`.
- One PB run = one lock-in period (`CamRef` `NRise = 4`), so **CamRef edges per
  camera run = 4 × nFrames**.
- `Average` = outer repeat of the whole acquisition (running-averaged into `gWide`).
- Exposure tracks the GUI `readout`: `exposure = readout − 2 µs` (sensor
  overhead), floored at 1.825 µs. Exposure and quarter spacing are *decoupled* —
  `readout` sets PB spacing, exposure sets the integration window.

### Camera limits

| Quantity | Range |
|---|---|
| exposure (`n × 12.5 ns`) | 1.825 µs … ~817 µs (`n` = 146 … 65359) |
| configured `f_ref` | **≥ 306 Hz** (hard GenICam minimum) … ~137 kHz |
| `nPeriods` | 1 … 100 |
| `nFrames` | 4 … 900 |
| effective lock-in period | set by PB — **no camera floor** |

`f_ref` bounds the *exposure*, not the reference rate: the PB trigger spacing can
be arbitrarily long (that is what makes long T1 waits reachable).

### Data output

Per run, `SaveWidefield` writes HDF5 into the dated `CreateSavePath_Ave` folder
(`_###` collision-safe):

```
/reference    [H×W×N]  mean(I)
/rawsignal    [H×W×N]  -mean(Q)
/sweep_param  [N]
root attrs: sequence, sweep_unit, exposure_s, n_periods, n_frames,
            sensitivity, quarter_bin_ns, average, mw_*, params_json
```

Contrast is **derived on read** (`rawsignal ./ reference`), deliberately not
stored. `TemporarySave` also puts `gWide` in `Temp.mat` for crash recovery.

Display (`DisplayWidefield`): `axes2` = image at the current point (raw `I` for
`hc_Image`, contrast otherwise) with a red ROI box; `axes3` = ROI-mean vs sweep.
`axes1` remains the PB pulse diagram.

### Note on `hc_Image` and the sweep axis

`hc_Image` ignores `gmSEQ.m` — the sweep parameter is inert. Set sweep **N = 1**
for a single image; N > 1 just repeats the same acquisition N times.

---

## Solved along the way (don't re-debug these)

- GigE subnet mismatch → camera moved onto the PC's subnet.
- `0xe0434352` crash on GUI reopen → reuse `gCam`, never re-open the SDK.
- `gmSEQ.meas` undefined when opening only `Experiment_PB_DAQ` → now set in
  `Initialize` and defensively in `RunSequence`.
- FPGA/SRS absent → `InstrumentEnabled.m` switchboard.
- `nFrames` ignored the GUI → now `nFrames = GUI Repeat`.
- Exposure stuck at 4 µs → now tracks `readout`.
- `f_ref 305.18 Hz < 306 Hz` GenICam error → grid index capped at `n = 65359`.
- GenICam NULL pointer on arm → `stopAcq()` before writing trigger features.
