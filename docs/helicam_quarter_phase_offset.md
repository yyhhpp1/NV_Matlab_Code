# HeliCam C4 — quarter-period phase offset

Working document for the open issue: light confined to one quarter period produces a
lock-in output of the wrong sign. Contains what we have established, the measurements
needed to complete the support request, and the draft email itself.

Status as of 2026-08-14: unresolved, awaiting Heliotis support.
Verified against the working tree, not against HEAD — several relevant files are modified
and uncommitted.

---

## 0. Before you measure — three things are not in the state this document assumes

**`hc_Image.m` does not currently confine the laser to one quarter.** The working tree has

```matlab
gmSEQ.CHN(numel(gmSEQ.CHN)).T   = 0;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT  = 2*Q;     % laser fills Q1
```

which illuminates **q1 and q2 together** (0 → 100 µs). Committed HEAD has `DT = Q`, which
illuminates q1 alone. Neither is the single-quarter-in-q2 measurement the email describes.
Set the laser explicitly before measuring — see step 5. The docstring and the trailing
`% laser fills Q1` comment are both stale and describe none of these.

**`cfg.subtractDarkRef = false`** in `WidefieldConfig.m`. With this off, `RunSequence` prints
`[Widefield] Dark subtraction: OFF` and performs no subtraction at all. If the dark reference
is being subtracted somewhere else (in `analysis/`, by hand), the email must say so
accurately; if it is not being subtracted at present, the sentence about it must be rewritten.
Resolve this before sending.

**`cfg.expectedFreqDeviationPct = 5`**, not 0. This changes the realized exposure and the
timing-margin argument — the numbers below already account for it.

**The sensor is an S40U running at maximum sensitivity.** Camera type C4.2-S40U, serial
145118, firmware 1.11.0. Manual Table 1.1 gives the S40U a micro-lens array, 55 % fill factor
and a **full well capacity of 125** against 500 for the plain S40; Table 3.1 recommends
`LockInSensitivity` = **20 %** for it. We run 1.0. `LockInSensitivity` is an alias of
`ExposureRatio`, so this is five times the recommended photoreceptive fraction on a sensor
with a quarter of the full well. **Saturation is now a leading candidate and should be tested
before anything else** — see step 0 below.

## 1. The symptom

Running `hc_Image` with the laser gate open only during the second quarter period of the
PulseBlaster pattern, the Q channel comes out **negative**. Eq. 5.54 of the C4 manual
defines `Q = s_β − s_δ`, so light confined to β should make Q positive.

Background subtraction is not responsible — the sign persists with subtraction disabled. The
laser gate has been verified on an oscilloscope against the trigger train itself.

## 2. What the manual establishes

**§5.2.1.4, Eq. 5.54** gives the in-pixel output as

```
s_p[m,n] = s_α + i·s_β − s_γ − i·s_δ
```

so the documented convention is `I = Q1 − Q3`, `Q = Q2 − Q4`, positive on the first-named
quarter. This is what `RunSequence.m` and `HELICAM_HANDOFF.md` already assume. The vendor
agrees with our expectation, which means the discrepancy is real and not a convention
mismatch on our side.

**§5.2.5, External reference** states that with `DivideBy4` the incoming signal is routed
directly to the sensor, each pulse triggering a new quarter period, and that a pulse
arriving while the sensor is busy "is missed and an erroneous shift by a quarter period
introduced."

**§5.2.2** confirms that in external mode the exposed portion of the quarter period "comes
right after the trigger" rather than being centred, which is what our exposure model assumes.

## 3. Ruled out: dropped triggers

The missed-pulse mechanism of §5.2.5 does not fit, for two independent reasons.

**The edge budget is exact.** Both `PBFunctionPool.m` implementations wrap the four-edge
pattern in a hardware `LOOP`/`END_LOOP` — the root one iterating `SEQ.Repeat`, the one in
`mytoolboxes/PulseBlaster` iterating `SEQ.Samples`, and `RunSequence` sets both to the same
value. PulseBlaster therefore emits exactly `4 × (nPeriods + blank) × nFrames` edges with no
surplus. If the sensor ignored one pulse it would end the burst a quarter short of the final
frame and `getBuffer` would block until timeout — the same failure we already debugged when
`nPeriods = 1` silently became 2 in the camera. Bursts complete normally and all frames
arrive, so every pulse is consumed.

**The timing has margin.** At a 50 µs quarter period with `LockInTargetReferenceFrequency`
5208.33 Hz and d = 5, Eq. 5.63 gives a sensor busy time of
1/(4 × 5208.33 × 1.05) = **45.7 µs**, leaving 4.3 µs before the next trigger, of which the
"<2 µs" hardware overhead of §5.2.2 consumes at most half. The next trigger should never
arrive early.

Note that the console line `[Widefield] … slack 0 ns` understates this: `slackNs` in
`RunSequence.m` is computed from the requested exposure without applying d, so it reports the
d = 0 case regardless of what is actually written to the camera.

## 4. What remains

Two candidates, both budget-neutral — they relabel which pulse is α without changing how
many pulses are consumed:

1. The camera's α-counter starts at a different phase than we assume, or the demodulation
   window is pipelined two quarters behind the trigger that opened it.
2. The decoded `rawIQ` polarity is inverted relative to Eq. 5.54 — more light in α producing
   a *lower* count.

**These two are not distinguishable by any experiment using quarter-aligned light.** Negating
both I and Q and rotating the quarter grid by two are the same linear map on the four bins.
The four-placement table below will give a self-consistent answer either way, and the
correction is identical for both.

What we *can* and must establish locally is whether the offset is **stable** — across
repeated bursts, and across a camera power cycle. A calibration constant that silently
rotates between sessions would be worse than the present bug.

## 5. Derived configuration

For readout 50000 ns, nPeriods 20, nFrames 4, with `WidefieldConfig` as it currently stands.
These should match the console banner exactly; if any row disagrees, something upstream has
changed and the email needs revisiting.

| Quantity | Value | Source |
| --- | --- | --- |
| Quarter period Q | 50 µs | `gmSEQ.readout` |
| Lock-in period | 200 µs | 4Q |
| CamRef rising edges | 0, 50, 100, 150 µs | `hc_Image.m` |
| CamRef TTL width | 25 µs (50% duty) | `hc_CamRefWidth.m`, auto = Q/2 |
| Requested exposure | 48 µs | readout − `sensorOverheadNs` (2000 ns) |
| `LockInTargetReferenceFrequency` | 5208.33 Hz | 1/(4 × 48 µs), grid index n = 3840, exact |
| `LockInExpectedFrequencyDeviation` | 5 % | `cfg.expectedFreqDeviationPct` |
| Realized sensor busy time | 45.7 µs | Eq. 5.63, 1/(4 × 5208.33 × 1.05) |
| Edge budget | 320 (80 loops × 4) | 4 × (20 + 0 + 0) × 4 |
| Output frame rate | 250 Hz | 1/(20 × 200 µs) |
| Burst duration | 16 ms | 4 × 20 × 200 µs |
| Warmup frames discarded | 0 (firmware > 1.9.2) | `HeliCamInterface.warmupDiscardCount` |

One timing caveat worth checking on the scope: `ApplyDelays` gives GreenAOM a 200 ns
compensation, and `PBFunctionPool` applies it as `T − Delays(1)` — the PB edge fires 200 ns
*early* so the light lands at the nominal time. With `T = 0` that asks for an event at
−200 ns, which is not obviously well-defined. Placing the laser away from `T = 0` avoids the
question entirely, which is another reason for the offsets used in step 5.

## 6. Measurement checklist

### Step 0 — the saturation test, before anything else

Re-acquire the same image at reduced optical power — a neutral-density filter, or a lower AOM
drive level — changing nothing else. If the inversion weakens or the image comes back the
right way up, it is saturation on the S40U and there is no phase problem to report.

Reduce **optical power**, not `cfg.sensitivity`. Lowering the sensitivity does not simply
shorten the exposure: `HeliCamInterface.exposureToReferenceFrequency` derives the reference
frequency from it, and at sensitivity 0.2 with a 48 µs target the grid index hits its bound
and `f_ref` clamps to the 306 Hz floor — a sensor busy time of roughly 780 µs against a 50 µs
quarter period. Every trigger would then arrive while the sensor is busy, and the burst would
starve into a `readIQ` timeout. Reducing the light changes no timing at all.

### Session 1 — camera identity

Already known: **C4.2-S40U, serial 145118, firmware 1.11.0.** Steps 1–3 are only needed if you
want to confirm them independently.

1. Start a **fresh** MATLAB with no GUI open and no `gCam`.
2. Run `hc_ListDevices()`. The printed device name gives the model and serial.
3. **Restart MATLAB.** `hc_ListDevices` opens the SDK itself, and C4HdlCLR cannot be opened
   twice in one session without crashing the .NET runtime.

### Preparation

4. In `WidefieldConfig.m`, confirm `cfg.subtractDarkRef = false` (it already is). This makes
   `gWide.reference` and `-gWide.rawsignal` hold absolute decoded levels rather than
   differences. Note whatever value you found, and restore it at step 15.
5. In `hc_Image.m`, set the laser to sit **inside q2 only**:

   ```matlab
   gmSEQ.CHN(numel(gmSEQ.CHN)).T   = 1*Q + Q/4;   % 62.5 us
   gmSEQ.CHN(numel(gmSEQ.CHN)).DT  = Q/2;         % 62.5 -> 87.5 us
   ```

   This sits comfortably inside q2 (50 → 100 µs) and inside the camera's exposure window
   (50 → 95.7 µs), with margin at both ends for the 200 ns AOM compensation. Filling the
   quarter exactly (`T = 1*Q`, `DT = Q`) also works but leaves no margin at the boundaries.
   **Whatever you use here must be what the email describes.**
6. In the GUI: readout 50000, nPeriods 20, nFrames 4, Average 1, sequence `hc_Image`.
7. `diary('C:\Data\helicam_support.txt')`.

### Dark measurement

8. Block the light completely. Run one acquisition.
9. Copy these console lines:
   - `[Widefield] Quarter bin = … ns; exposure = … ns` — expect 50000 and 48000
   - `[HeliCam] Lock-in (DivideBy4) configured: … f_ref 5208.3 Hz, actual ___ Hz …`
   - `[HeliCam]   ref line FI2, ACTUAL periods ___ + blank ___, deviation 5% …`
   - the two `LockInActual…NPeriods` lines that `configLockInMode` prints just after

   If a line beginning `[Widefield] Edge budget CORRECTED` appears, the camera is not using
   20 periods; both the budget arithmetic and the dropped-triggers argument need updating
   with the real number.
10. Read the dark levels:

    ```matlab
    global gWide
    roiR = 200:300; roiC = 200:300;          % same pixels for dark and lit
    I = gWide.reference(:,:,1);
    Q = -gWide.rawsignal(:,:,1);             % absolute only while subtractDarkRef = false
    fprintf('frame:  I = %8.2f   Q = %8.2f\n', mean(I(:),'omitnan'), mean(Q(:),'omitnan'));
    fprintf('ROI:    I = %8.2f   Q = %8.2f\n', ...
            mean(I(roiR,roiC),'all','omitnan'), mean(Q(roiR,roiC),'all','omitnan'));
    ```

    Choose an ROI that will be brightly illuminated later, and use the same pixels for both
    measurements.
11. Run `gCam.readActualRefFrequency()`. This post-burst value is the one to quote — the
    number printed at step 9 was sampled before any trigger train existed. ~5000 Hz means the
    camera is tracking the train; 5208 Hz means it is echoing the configured value.
12. Run `gCam.dumpLockInState()`. Gives the firmware version and the full appendix readback.

### Illuminated measurement

13. Unblock the light. Run one acquisition and repeat the snippet from step 10. Confirm Q
    came out below the dark level.
14. Repeat ten times, recording the sign and magnitude each time. Then power-cycle the
    camera, restart MATLAB, and measure once more. Record what was actually observed —
    "stable across 10 repeats and a power cycle" or "varies between bursts".

### Cleanup

15. `diary off`, and restore `cfg.subtractDarkRef` and the `hc_Image.m` laser placement to
    whatever they were before step 4.

### Optional but recommended

16. Repeat step 13 with the laser at each quarter, keeping `DT = Q/2` and shifting `T` by one
    quarter each time, recording both I and Q. This is the four-placement table support will
    ask for, and it shows whether the offset is a clean two-quarter rotation or something
    messier.

    | Laser in | `T` | Expected if no offset | Observed I | Observed Q |
    | --- | --- | --- | --- | --- |
    | q1 | `Q/4` | +I, Q ≈ 0 | | |
    | q2 | `1*Q + Q/4` | I ≈ 0, +Q | | negative |
    | q3 | `2*Q + Q/4` | −I, Q ≈ 0 | | |
    | q4 | `3*Q + Q/4` | I ≈ 0, −Q | | |

## 7. Where each blank comes from

| Blank in the email | Step |
| --- | --- |
| Model / serial | known: C4.2-S40U, 145118 |
| Firmware version | known: 1.11.0 |
| `LockInActualTimeConstantNPeriods`, `LockInActualBlankDurationNPeriods` | 9, or `gCam.readActualPeriods()` |
| `LockInActualReferenceFrequency` | 11 (not 9), or `gCam.readActualRefFrequency()` |
| Decoded I and Q, dark | 10 |
| Decoded I and Q, illuminated | 13 |
| Laser gate timing | 5 |
| Dark-subtraction sentence | see §0 |
| Reproducibility statement | 14 |
| Appendix readback | 12 |
| Name, group, institution | — |

Two things to check before sending. If the illuminated Q lands near zero rather than a modest
amount below dark, we are clipping at the floor and the magnitude is an artifact — that is a
different diagnosis and the email needs rewriting. And if step 12 reports firmware ≤ 1.9.2,
`HeliCamInterface` discards 2 of the 4 frames, so the email's claim that all four are
averaged is wrong.

---

## 8. Draft email

> **Superseded for sending.** `helicam_polarity_inversion.md` is the document to send: it
> leads with the measured image, which is stronger evidence than the argument below, and it
> puts the saturation question first. This draft is kept because it states the quarter-phase
> framing and the edge-budget argument more fully.

**To:** support@heliotis.ch
**Subject:** C4 external DivideBy4 — quarter-period assignment offset by two quarters with no dropped triggers

Dear Heliotis support,

We are using a heliCam C4 [model / serial: ___], firmware [___], for widefield lock-in
imaging of NV centres in diamond, driven from MATLAB via C4HdlCLR. We have a quarter-period
phase problem we cannot resolve from the manual and would appreciate your help.

### External trigger pattern

A PulseBlaster supplies the quarter-period trigger train on FI2. Per lock-in period it emits
four rising edges at 0, 50, 100 and 150 µs, each a 25 µs TTL pulse (50% duty, 0–5 V), so the
quarter period is Q = 50 µs and the lock-in period is 200 µs. The train is phase-stable and
jitter-free; we have verified it on an oscilloscope. The generator is idle-low before the
burst, emits exactly 320 edges per acquisition (80 hardware loop iterations × 4), then stops.

### Complete camera configuration

Every feature below is written explicitly before each acquisition; nothing else is touched.

| Feature | Value |
| --- | --- |
| `DeviceOperationMode` | `LockInCam` |
| `Scan3dExtractionMethod` | `rawIQ` |
| `TriggerSelector` = `RecordingStart` → `TriggerMode` | `Off` |
| `TriggerSelector` = `FrameStart` → `TriggerMode` | `On` |
| `TriggerSelector` = `FrameStart` → `TriggerSource` | `Software` |
| `LockInSensitivity` | 1.0 |
| `LockInExpectedFrequencyDeviation` | 5 (%) |
| `LockInTargetReferenceFrequency` | 5208.33 Hz |
| `LockInTargetTimeConstantNPeriods` | 20 |
| `LockInTargetBlankDurationNPeriods` | 0 |
| `LockInCoupling` | `DC` |
| `AcquisitionBurstFrameCount` | 4 |
| `LockInReferenceSourceType` | `External` |
| `LockInReferenceFrequencyScaler` | `DivideBy4` |
| `LockInReferenceSourceSignal` | `FI2` |
| `LockInReferenceTimeShift` | 0.0 µs |

We do not use the internal signal generator or LED module, and we do not set ROI, binning,
`ReverseX/Y`, `Rotation` or pixel format.

The reference frequency of 5208.33 Hz is chosen to give a nominal exposure of 48 µs —
deliberately shorter than the 50 µs quarter period the PulseBlaster delivers — following the
guidance in §5.2.5 that the external trigger, not the configured frequency, sets the
effective reference frequency. With `LockInExpectedFrequencyDeviation` = 5, Eq. 5.63 gives a
realized sensor busy time of 45.7 µs.

Readback after configuration: `LockInActualTimeConstantNPeriods` = [___],
`LockInActualBlankDurationNPeriods` = [___], `LockInActualReferenceFrequency` = [___] Hz.
A complete feature readback is appended below.

### Acquisition procedure

`startAcquisition(4)` → `TriggerSoftware` on `FrameStart` → wait 1 s → start the PulseBlaster
train → `getBuffer(20000 ms)`. The buffer returns 2N parts, N = 4 I-frames followed by 4
Q-frames, decoded as in your `c4DemodSimple` example, `mod(raw, 2^15) / 2^2`, then averaged
over the 4 frames per pixel. Our firmware requires no warmup-frame discard, so all 4 frames
are used.

### Measurement and observation

We pulse a 520 nm laser so that light reaches the sensor during exactly one quarter period per
lock-in period, with no other illumination. The laser gate is high from [___] to [___] µs —
that is, entirely within the interval between the second and third rising edges of each group
of four. We confirmed this on an oscilloscope against the trigger train.

[State here exactly how the dark reference is handled — see §0 before writing this sentence.]

Per Eq. 5.54 (§5.2.1.4), light confined to quarter β should make Q = s_β − s_δ **positive**.
We consistently measure it **negative**, with a magnitude consistent with the light level.
Decoded values, dark versus illuminated: I = [___] → [___], Q = [___] → [___]. The result is
[reproducible across N repeated acquisitions and a camera power cycle / variable between
bursts — state which].

The data are consistent with the camera's α/β/γ/δ assignment being rotated by exactly two
quarter periods relative to our trigger pattern — or, equivalently and indistinguishably from
our side, with the decoded `rawIQ` polarity being inverted relative to Eq. 5.54.

### We can rule out dropped triggers

§5.2.5 notes that a trigger arriving while the sensor is busy is missed, "introducing an
erroneous shift by a quarter period." We do not believe that is the cause here, for two
reasons.

First, the edge budget is exact. The camera consumes
4 × (`LockInActualTimeConstantNPeriods` + `LockInActualBlankDurationNPeriods`) ×
`AcquisitionBurstFrameCount` = 4 × 20 × 4 = 320 quarter-period triggers, and the PulseBlaster
emits exactly 320 — no surplus. If the sensor ignored even one pulse, the final frame could
never complete and `getBuffer` would block until timeout. We have previously observed
precisely that failure when our budget was one period short. In these measurements the burst
completes normally and all frames arrive, so every pulse is being consumed.

Second, the timing has margin by construction: per Eq. 5.63 the sensor is busy for 45.7 µs,
plus the hardware overhead of <2 µs given in §5.2.2, against a quarter period of 50 µs. The
next trigger should never arrive early.

The offset therefore appears to be in the assignment of quarters, not in the counting of them.

### Questions

1. With `External` + `DivideBy4`, what determines which incoming pulse the sensor treats as
   quarter α? Is the phase reset at recording start, at every `FrameStart`, or not at all
   between bursts? In our sequence the software `FrameStart` is issued about one second before
   the first external pulse arrives — does the sensor treat that first pulse as α?
2. Is there a fixed pipeline delay, in quarter periods, between the trigger that opens a
   quarter period and the integration window attributed to it?
3. Can the current quarter phase be read back or set explicitly from the host? If not, is
   there a recommended way to establish it — a known-phase calibration input, or a status
   signal on RTIO2/RTIO3 marking the period boundary?
4. Can you confirm the polarity of the `rawIQ` output specifically: does more light in α
   *raise* the decoded I value, and more light in β *raise* the decoded Q value? What does
   bit 15 represent, given your examples mask it with `mod(raw, 2^15)`?
5. `LockInReferenceTimeShift` appears in the GenICam feature set but not in the manual. What
   is its definition, unit, range and resolution, and can it shift by a full quarter period or
   only within one?
6. Would driving `RecordingStart` externally from the same pulse generator give us a
   deterministic quarter phase? If so, what timing relationship should that edge have to the
   quarter-period train?

We can supply a .hdat measurement with metadata and an oscilloscope capture of the trigger
train against the laser gate.

Thank you,
[Name]
[Group, institution]

**Appendix: full feature readback**
[paste `gCam.dumpLockInState()` output]
