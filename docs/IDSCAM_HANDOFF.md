# IDS uEye+ Widefield — Work Handoff

State of the IDS uEye+ **U3-3140CP-M** widefield integration in `MATLAB_Code_DF`.
Branch: **`ids_camera`** (branched from `df_with_helicam` at `7eca729f`).

Timing characterisation this is built on:
`C:\Users\60 Oxford M30\Documents\HaopuY\ids_camera_test\CAMERA_FINDINGS.md`
(referenced throughout as "findings sec.N").

---

## Status

**Written and self-tested; never run against the camera.** `ids_SelfTest` passes
with zero failures, but it is hardware-free by construction — it proves the
timing arithmetic, the PB programs and the data plumbing, and proves nothing
about whether the camera sees PB pin 8.

Nothing in this integration has touched hardware yet.

---

## The measurement model

The IDS is **not** a lock-in camera. `ExposureMode` is `[ReadOnly] = Timed` and
`SensorShutterMode` is `[ReadOnly] = Global`, so one trigger buys one exposure
window and one number per pixel. There is no in-pixel demodulation to separate
signal from reference *inside* a frame the way the C4's four quarter bins do.

So the separation moves **between** frames:

```
one PB program run = [ N shots, MW on ][ N shots, MW off ]
                     |<-- SIG frame -->|<-- REF frame -->|
                     ^                 ^
                  CamTrig           CamTrig          (PB pin 8 -> GPIO1 = Line2)
```

MATLAB reads the frames back in pairs:

| | meaning | sign |
|---|---|---|
| `Q(:,:,k)` | SIGNAL frame of pair k (MW on) | raw summed ADU, positive |
| `I(:,:,k)` | REFERENCE frame of pair k (MW off) | raw summed ADU, positive |

`contrast = Q./I`, near 1 with a dip. **Nothing is negated anywhere on this
path** — unlike the HeliCam, where `readIQ` applies a polarity inversion and I/Q
are signed quadrature differences. Every `ids_*` sequence sets
`gmSEQ.WFcontrastExpr = 'Q./I'` accordingly, and the `.h5` records the convention
in its `iq_convention` attribute so a file cannot be read under the wrong one.

### Why PB owns the frame boundary (scheme B1, not the findings' B5)

The findings recommend **B5 + A2 + C1**: PB clocks every shot, the camera divides
by N in hardware (`TriggerDivider`), so the two crystals cannot drift apart.

That does not work here. `PBFunctionPool.m:198-209` wraps the whole program in
**one** hardware `LOOP`, so every shot is identical — and therefore every frame
would be too. Perfect drift immunity, zero contrast.

Writing the block pair into the sequence file gets the same immunity for free.
Every frame boundary is a PB edge, so nothing accumulates and there is no
integration path for drift; each frame is independently commanded. The
0–5.5556 µs trigger quantisation (findings sec.4.5) survives and is harmless: it
displaces the exposure window as a whole, and the window opens and closes inside
a dark guard interval where no light is being collected.

**A2** (Timer0 sync out) and **C1** (`ExposureTriggerMissed`) carry over from the
findings' recommendation unchanged.

---

## The block boundary — where the real constraints live

```
     1.900 ms          1.9611      1.9841    2.000 ms
         |                 |          |         |
GreenAOM ▓▓▓▓|_____________|__________|_________|▓▓▓▓
             └──────── 100 µs dark guard ───────┘

Exposure ▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔|__________|_________|▔▔▔▔
                           └ ends 61 µs into the guard
dead                       |▓▓▓▓▓▓▓▓▓▓|         |
                            └ 23 µs turnaround (findings sec.3.1)
CamTrig                                         |▌
                                  |←15.9 µs────→|
                                   margin, vs 0–5.56 µs quantisation
```

The constraint chain `ids_BlockPlan` enforces:

```
shotTrain  <=  exposure  <=  block - dead - quantum
```

- **Lower bound** — every shot inside the window, or you throw away signal.
- **Upper bound** — the camera becomes busy at `trigger + Q_prev` and must be
  free by `next trigger + Q_next`. Consecutive frames sample the quantisation
  independently, so the worst case is `Q_prev` = a full quantum with `Q_next` = 0.
  One spare quantum (`exposureBackoffQuanta = 1`) removes that failure mode.

Defaults produce: 76 shots × 25 µs + 100 µs guard = **2.000 ms block**, exposure
**1.9611 ms** (353 quanta), margin **15.9 µs = 2.9 quanta**, at **76.9%** of the
sensor's max rate against a 90% ceiling.

**The guard is the shock absorber.** If `ExposureTriggerMissed` starts firing,
lengthen `cfg.guardNs` before touching anything else.

---

## Files

```
mytoolboxes/IDSCam/
  IDSConfig.m          central config -- twin of WidefieldConfig.m
  IDSCamInterface.m    protocol-compatible wrapper over the Python backend
  FakeIDSCamera.m      synthetic stub, same protocol, no hardware
  ids_acquire.py       harvesters/GenTL backend (configure/arm/fetch/telemetry)
  ids_BlockPlan.m      shot -> block -> exposure, with every constraint checked
  ids_ExposureGrid.m   the 5.5556 us grid + the ROI-width-dependent minimum
  ids_FrameTimeNs.m    findings sec.3 frame-time model, with its accuracy table
  ids_ShotNs.m         shot length accessor (GUI override -> config fallback)
  ids_BuildBlocks.m    builds the SIG/REF block pair into gmSEQ.CHN
  ids_TriggerTest.m    wiring + capability diagnostics
  IDSCamRelease.m      deliberate disconnect
  ids_SelfTest.m       hardware-free check of all of the above
Sequences/IDSCam_seq/
  ids_Image.m  ids_Rabi.m  ids_ODMR.m  ids_T1.m
```

Edits to existing files:

| File | Change |
|---|---|
| `Sequences/GeneralFunctions/PBDictionary.m` | `dummy1` 8 → 9; **`CamTrig` = 8** |
| `RunSequence.m` | dispatch on `IDSCam`; new `RunSequence_IDSCam`; `iq_convention` and `detector` attributes now come from `gWide` |
| `SequencePool.m` | four `ids_*` cases + menu entries |
| `PortMap.m` | commented `'IDSCam'` option under `'meas'` |
| `InstrumentEnabled.m` | `'idscam'` entry |
| `mytoolboxes/HeliCam/hc_TriggerTest.m` | knows about `CamTrig` for clash detection |

**`dummy1` moved off pin 8.** It is a program-length marker, never cabled, but it
is used in ~8 places in `SequencePool.m` — leaving it on pin 8 would have meant
every confocal sequence pulsing the camera's trigger input.

---

## What is reused, and why that is the whole point

`RunSequence_IDSCam` shares every stage downstream of the camera with
`RunSequence_HeliCam`: `gWide`, `AcquireDarkRef`, `DisplayWidefield`,
`SaveWidefieldAve`, `SaveWidefield`, `hc_WFExpr`, `hc_WFContrast`, and
`hc_AcqTimeoutMs` (which despite its prefix is detector-agnostic — it reads four
timeout fields off the config and the span of `gmSEQ.CHN`).

That works because both cameras satisfy the same four-method protocol, and it is
why the integration is ~1500 lines rather than a fork.

---

## Setup

- **MATLAB path must include** `mytoolboxes\IDSCam` and `Sequences\IDSCam_seq`
  (git does not manage the MATLAB path).
- **Python**: R2023b supports 3.9–3.11 in-process only. The machine default
  (`C:\Conda\python.exe`) is **3.13 and will not load**. `IDSConfig.pythonExe`
  points at `C:\Conda\envs\heli_cam_env\python.exe` (3.11.5), which already has
  `harvesters`, `genicam` and `h5py`. A MATLAB session loads Python once and
  cannot swap it — if 3.13 is already loaded, restart.
### Why MATLAB goes through Python at all

MATLAB has no direct route to this camera **on this machine**. Checked, not
assumed:

| Route | Status |
|---|---|
| Image Acquisition Toolbox (`videoinput('gentl',…)`) | **Installed 2026-09-06 and RULED OUT — see below.** |
| An IDS MATLAB API | **Does not exist.** IDS ships C, C++, C# and Python. |
| .NET via `NET.addAssembly` — how the HeliCam works | **Bindings not installed.** The IDS peak tree has extensive C#/.NET *documentation* but no managed assemblies; that component wasn't selected at install time. |
| `loadlibrary` against `ids_peak_comfort_c.dll` | Present (`.dll` + `.lib` + headers), but the header is 20,000 lines and MATLAB's `loadlibrary` needs a supported compiler and chokes on nested structs and function pointers. Fragile. |
| A MEX wrapper | Most native, most work, and C to maintain forever. |

#### IAT was tried properly, and it cannot work (2026-09-06)

The Image Acquisition Toolbox 23.2 and the GenICam Interface support package
were both installed and tested with `ids_ProbeIMAQ`. Result: **the `gentl`
adaptor enumerates zero IDS devices**, while the harvesters backend enumerates
the same camera (serial 4110060870) at the same moment without trouble.

Cause — a GenICam runtime version clash:

| | GenApi DLL |
|---|---|
| MATLAB's `gentl` support package | `GenApi_MD_VC120_v3_1.dll` — **v3.1**, VS2013 |
| IDS peak U3V producer | `GenApi_MD_VC141_v3_5.dll` — **v3.5**, VS2017 |

A GenTL producer is a DLL loaded in-process by the consumer. MathWorks' consumer
brings its own, older GenApi, so the IDS producer's node map cannot bind and the
producer contributes nothing — **with no error message**, which is why it
presents identically to an unplugged camera. Two major revisions and a different
C++ runtime apart; not fixable from MATLAB, because the runtime is bundled and
version-pinned inside the support package with no supported way to redirect it.

`ids_ProbeIMAQ` now detects and reports this automatically, so the next person
to wonder gets the answer in one command rather than an afternoon.

Two traps that made this take longer than it should have, recorded so they don't
recur:

- **The probe originally opened `DeviceIDs{1}`, which is the HeliCam.** The C4
  is on the same adaptor over GigE and enumerates first. It produced a confident
  verdict about the wrong camera — a lock-in camera genuinely has no `Width` or
  `ExposureTime`. Device selection must be by name.
- **`GENICAM_GENTL64_PATH` differs between a Git Bash shell and MATLAB.** Bash
  showed only the Diaphus producer; MATLAB's environment already had all three.
  Read it from inside MATLAB, not from a shell.

Python via `harvesters` needs **zero installation** and follows existing
precedent — `mytoolboxes/HeliCam/hc_ExtTrigAcquire.py` already drives the C4 this
way. Note it does not use the IDS SDK's own API at all: harvesters is a generic
GenTL consumer that loads the `.cti` producer directly, so this code is
vendor-neutral and would work against any GenICam camera.

**If the Python bridge becomes annoying** (the 3.9–3.11 constraint is its main
cost), the clean alternative is to re-run the IDS peak installer with the .NET
component ticked and rewrite `ids_acquire.py` as `NET.addAssembly` calls,
matching `HeliCamInterface`. That is one file. It buys consistency with the
HeliCam path and drops the Python dependency; it costs an installer run on a
working lab PC. Neither route is crash-isolated — `py.` and `NET.addAssembly`
are both in-process.

- **`ids_peak` is deliberately NOT used.** It is not installed on this machine,
  and every node this integration touches is standard GenICam reachable through
  the GenTL producer at
  `C:\Program Files\IDS\ids_peak\ids_u3vgentl\64\ids_u3vgentlk.cti`. The HeliCam
  side already talks to its camera through harvesters.
- **Image Acquisition Toolbox is not installed**, so `videoinput`/`gentl` was
  never an option.
- To select the detector: `PortMap.m` → `case 'meas'` → `path='IDSCam';`
- `IDSConfig.useFakeCamera = true` for a hardware-free code-path test.

### GUI boxes not yet added

Per the no-`.fig`-edits rule, these read `gmSEQ.<field>` with a config fallback.
To expose them, add an edit box with the given Tag and one line in
`getUserInputFromGUI`:

| Tag | Field | Meaning |
|---|---|---|
| `shotNs` | `gmSEQ.shotNs` | shot length (ns); overrides `IDSConfig.shotNs` |

Everything else lives in `IDSConfig.m`.

---

## Next steps, in order

1. ~~Check PB output level against GPIO1's LVTTL receiver.~~ **Done 2026-09-06.**
   The PBESR-PRO-400 outputs **3.3 V**, which is exactly LVTTL — V_IH is 2.0 V,
   so ~1.3 V of margin. No level shifter or divider.
   **Do not put a 50 Ω terminator on this line.** 3.3 V into 50 Ω divides to
   1.65 V at the receiver, below threshold, and the camera then reads exactly
   like an unplugged cable. Drive it unterminated. Edge ringing cannot produce
   spurious frames: the camera is busy for the whole ~2 ms exposure afterwards
   and rejects further edges onto the `ExposureTriggerMissed` counter, where
   they are visible rather than silent.
2. ~~`ids_TriggerTest`~~ **Done 2026-09-06. All green:**
   - `TriggerSource` offers `Line2`; Line2 is already `Input` / `LVTTL`  → B1 ok
   - `ExposureTriggerMissed` available as a `CounterEventSource`         → C1 ok
   - `Timer0Active` routable to a line                                    → A2 ok
   - `ExposureMode` entries = `Timed` only — B2 still dead, so the
     between-frames architecture remains the right one
   - `ids_TriggerTest('toggle')`: PB low → 0/20 samples high, PB high →
     20/20 high. **The trigger path PB pin 8 → GPIO1 → Line2 is proven.**
3. **`ids_SelfTest`** — should stay at 0 failures.
4. **`ids_Image` with `useFakeCamera = true`** — exercises the whole
   `RunSequence_IDSCam` path with no hardware.
5. **`ids_Image` on real hardware.** Two frames per PB run, `Q./I` flat at 1.
   That is the proof the block pair, the trigger line and the SIG/REF pairing all
   work.
6. **The optical exposure-window sweep** (findings sec.7 item 5). Needs only PB +
   AOM + camera, and `cfg.enableSyncOut` already routes `Timer0Active` to GPIO2
   as the time-zero mark.

---

## Known gaps and caveats

- **Never run against hardware.** Everything below the MATLAB/Python boundary is
  written from the GenICam spec and the findings document, not from a working
  session. Expect node-name surprises on first contact; `ids_acquire.configure`
  reports every optional node that did not take, rather than skipping silently.
- ~~`ExposureTriggerMissed` as a counter source is unverified.~~ **Verified
  2026-09-06** by `ids_TriggerTest`: available as a `CounterEventSource` *and* as
  a GenICam event. The counter is used (an event queue can drop events; this
  camera even lists `EventDropped`). Scheme C1 is live. Closes findings open
  question #4's telemetry half.
- **GPIO2 / Line3 reads HIGH and is currently an `Input`.** `cfg.enableSyncOut`
  will switch it to `Output` for the A2 sync pulse. Before enabling it, confirm
  nothing external is driving GPIO2 — an input floating high through a pull-up is
  expected and harmless, but a driven line would put the camera's output stage
  into contention with whatever is driving it.
- **The frame-time model under-predicts at 256×256 by 3.5%** — the unsafe
  direction. Eight of the other ROIs land inside 0.5%. Part of what the 90% rate
  ceiling is paying for; another reason not to raise `cfg.maxRateFraction`.
- **`ids_T1` has unmatched MW duty** between blocks, so MW-dependent heating does
  not divide out. The fix is a spectator pulse in the reference block, which
  needs a second signal generator. `ids_T1_matched_ref` does not exist.
- **`shotsPerBlock` is bounded by PB instruction memory**, roughly 4 instructions
  per shot per block pair. The PBESR-PRO's depth has not been checked; at 76
  shots the program is ~600 instructions. If you need far more shots per frame,
  that is where `TriggerDivider` (scheme B5) comes back, stacked on a program
  that already contains the block pair.
- **`ApplyDelays` shifts the whole program 200 ns** (the GreenAOM advance, then
  `PBFunctionPool.m:86` re-zeroes the earliest event). Harmless — it preserves
  the within-run trigger gap exactly and makes the run-to-run gap 200 ns longer,
  which is slack, not debt. Documented in `ids_BuildBlocks.m`.
- **No stored dark reference yet.** With `takeDarkRef` unticked, nothing is
  subtracted and the frames carry the full pedestal (this sensor has no
  `BlackLevel` node). `RunSequence_IDSCam` says so loudly rather than falling
  back to the HeliCam's `wf_darkref.mat`.

---

## Design decisions worth not re-litigating

- **Signal/reference alternate between frames, not within one.** Forced by
  `ExposureMode = Timed` being read-only. Scheme B2 is dead.
- **PB emits one trigger per block, not per shot.** Per-shot triggering plus a
  camera-side divider makes every frame identical (see above).
- **The shot length is fixed across a sweep**, with the swept quantity absorbed
  into the trailing idle. Otherwise the block, exposure, frame rate and dark
  pedestal all move with the sweep, and one dark reference would be correct at
  exactly one point. Same reasoning as the existing `*_fixDutyCycle` sequences.
- **Frame count == trigger count, always.** This is a safety property: a missed
  trigger then means the last frame never arrives and the fetch times out
  loudly, instead of completing with the SIG/REF assignment inverted from the
  miss onward. Never request fewer frames than PB triggers.
- **The missed-trigger counter is diagnosis, not detection.** The frame-count
  equality detects. C1 separates "too close to the rate ceiling" from "the camera
  never saw Line2" from "PB did not run" — three faults that otherwise present
  identically as a timeout, which is exactly the ambiguity that cost the HeliCam
  integration significant time.
