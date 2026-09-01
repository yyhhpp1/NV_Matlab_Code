# HeliCam widefield — display, statistics and diagnostics

Work log for **2026-08-21 → 2026-08-25**, branch `df_with_helicam`.
All changes are **uncommitted** — the working tree already carried unrelated
in-flight work, so nothing was committed on your behalf.

---

## 1. Headline changes to how data is reduced

**Two changes alter the numbers in every `.h5` from here on. Read this section
before comparing new data against old.**

### I/Q replaced `reference`/`rawsignal`

The two lock-in quadratures are now called what they are.

| was | now |
|---|---|
| `gWide.reference`, `/reference` | `gWide.I`, `/I` |
| `gWide.rawsignal`, `/rawsignal` | `gWide.Q`, `/Q` |
| `gWide.signal` | **deleted** — it was a byte-for-byte duplicate of `rawsignal` that nothing read |

The old names asserted roles the data does not have: neither quadrature is more
"raw" than the other (both are frame-reduced, dark-subtracted, polarity-corrected)
and neither is inherently a normaliser. Which one carries the physics depends
entirely on where a sequence puts the laser and MW.

**Existing files still open.** `hc_LoadIQ` and `hc_DarkIQ` accept both spellings,
and `analysis/wf_viewer.py` falls back to the legacy datasets. New writes only
ever produce `/I`, `/Q`.

### Frames are now SUMMED, not averaged

```matlab
nF = size(I, 3);                 % actual frames returned (readIQ drops nDiscard)
Ij = sum(I, 3) - nF * darkI;     % was: mean(I,3) - darkI
```

So **all I/Q values are ~`nFrames`× larger than before.** This keeps values on a
raw photon-count scale and makes the pass-to-pass scatter the single honest
measure of uncertainty — frame noise is already inside it.

Files record which convention they use:

```
frame_reduction = 'sum'          % absent  =>  pre-2026-08-25 file, holds frame MEANS
iq_convention   = 'I = sum over n_frames of (Q1 - Q3); ... dark-subtracted as
                   n_frames x the per-frame pedestal'
```

The dark reference stays a **per-frame** pedestal — that is what a pedestal
physically is — so the sweep subtracts `nF ×` it. `hc_DarkRef('save')` therefore
divides by `nFrames` when storing a dark captured from `gWide`; without that it
would have been `nFrames`× too large and would have failed silently.

Scale-invariant consumers are unaffected: `hc_FocusMetric` normalises by
`mean(|A|)²`, `hc_FocusMask` by a per-frame percentile.

---

## 2. `hc_ZScan` autofocus

Scores each Z for sharpness and parks the objective at the best-focus position.

- **Metric**: normalised Tenengrad, `mean(gx²+gy²)/mean(|I|)²`, Sobel on a
  3×3-smoothed frame. `normvar`, `brenner` and `laplacian` are computed and saved
  alongside so the choice can be re-judged offline with `hc_FocusCompare`.
- **Stripline mask** (`hc_FocusMask`): per-frame normalise → union of shadows
  across Z → despeckle → **erode**. The erosion is the point: the shadow's *edge*
  is the sharpest feature in the frame and belongs to a plane 50 µm above the NV
  layer, so a gradient score that can see it peaks with the *stripline* in focus.
  Dropping the dark pixels alone does not help — the edge is at the boundary.
- **Parking**: moves to the parabolically interpolated best Z, but **only** on a
  genuine interior peak. An argmax on the first or last point means focus is
  outside the scanned range, so the run restores the starting Z and says which way
  to extend. A flat curve (low `conf`) is likewise reported, not acted on.
- **One pass only** — `Average` is forced to 1 for Z scans and restored on exit
  via `onCleanup`. A Z stack is a measurement of *where* a peak is; repeating the
  sweep does not sharpen it.

Verified in `hc_FocusSelfTest`: with masking, best-Z lands 46.36 µm against a
truth of 47; with masking disabled the peak is pulled **+2.73 µm toward the
stripline**.

**Bug found and fixed:** `RestoreZ` called a bare `WriteVoltage`, which is private
to `ImageFunctionPool`. It threw, its own `catch` swallowed it, and **every Z stack
left the objective parked at the last sweep point** behind a warning that looked
like a hardware fault.

---

## 3. Live display

### Flexible display expression

axes2 and axes3 now plot any expression over `I` and `Q`, resolved fresh on every
update from one place ([RunSequence.m](../RunSequence.m), `DisplayWidefield`), so
the two axes can never disagree.

| GUI tag | widget | role |
|---|---|---|
| `WFContrast` | edit box | the expression |
| `overwriteExpr` | checkbox | does the box override the sequence's default? |

Precedence: **box (only while `overwriteExpr` is ticked)** → `gmSEQ.WFcontrastExpr`
declared by the sequence file → `'I'`. Selecting a sequence *seeds* the box with
that sequence's declaration, so its choice is visible rather than hidden — except
while the override is ticked, when your typed expression is protected.

- Operators auto-vectorise: `I/Q` becomes `I./Q`, so it means a per-pixel ratio
  rather than a matrix solve.
- Nothing you type can break a run: syntax errors, undefined names, wrong-sized
  results, `Inf`/`NaN` all fall back to `I` and mark the axis label.
- The axes2 title shows the source — `I (GUI)` vs `I (sequence)` — which is how
  you tell whether the box is actually being read.

> **Trap that cost real time:** the tag is `WFContrast` with a capital C.
> `isfield` is case-sensitive, and a mismatched spelling makes the box **silently
> inert** — no error, just the sequence default every time. If you rename a Tag in
> GUIDE, change it in `hc_WFExpr` and in `LoadSEQ` too.

### axes3 persists, and carries error bars

- The curve is drawn for **every point that has data**, not `1:jCurve`. `j` resets
  each Average pass and `plot` clears the axes, so the curve used to appear wiped
  at the start of pass 2. The data was never lost, only undrawn.
- A **red vertical line** marks the sweep point just acquired — needed now that
  the curve no longer has a growing right-hand end.
- **Error bars** = SEM of the mean over Average passes, from Welford running
  statistics (`roiN`, `roiMean`, `roiM2`, three `1×N` vectors ≈ 1 kB). Bars appear
  from pass 2.

Welford rather than `Σv`/`Σv²`: the naive `(S2 − S1²/n)/(n−1)` subtracts two
nearly equal large numbers and can return a negative variance. Welford
accumulates products of deviations, so `M2 ≥ 0` by construction.

The three-scalar form also replaced an `Average × N` matrix that, at
`Average = 99999`, was **16.8 MB written to disk at every sweep point** —
`TemporarySave` serialises the whole of `gWide` each point.

### Not adopted

A percentile-based fixed colour scale for axes2 was implemented and **reverted**
at your request. Worth recording why it looked wrong: for `-I/Q` the 1st–99th
percentile band *is* ±2.5, but that band is the **noise floor** — 5.4% of pixels
have `|Q| < 1` where the ratio explodes, and 98% of pixels are noise. The scale
faithfully measured the noise and stretched the colormap across it.

If you want a readable ratio image, the lever is masking small denominators before
forming the ratio (what `wf_viewer.py` already does), not the colour limits.

---

## 4. Timeouts and stopping

`readIQ`'s timeout is now derived from the burst instead of asserted:

```
timeout = max(cfg.timeoutMs, burst × cfg.timeoutFactor + cfg.timeoutMarginMs)
burst   = nPBPeriods × real PB program span      % measured from CHN
```

The program span is read from `gmSEQ.CHN`, **not** computed as `4 × quarter bin`,
so `hc_T1`'s composite period is handled correctly — and `hc_T1` is exactly the
sequence whose bursts get long. A 360 s burst now gets a 730 s timeout instead of
being killed at a fixed 20 s and reported as `Timeout, no data available!`.

**Consequence:** `readIQ` blocks for the whole wait and `gmSEQ.bGo` is only polled
*between* sweep points, so a longer timeout means a longer worst-case Stop delay.
`cfg.timeoutMaxMs` (30 min default) bounds it.

**Immediate stop is not possible in the current architecture.** MATLAB is
single-threaded: while blocked inside `getBuffer` the GUI event queue is not
serviced, so the Stop callback never *runs*. Ctrl+C does not interrupt a blocking
.NET call and a timer cannot preempt one.

- **Practical lever:** make each burst short. `burst = (nPeriods + blank) ×
  nFrames × period`. Cutting `nFrames` and raising `Average` keeps the same total
  photons while giving Stop a chance every burst.
- **`hc_TimeoutProbe`** was written to settle whether an interruptible acquisition
  is buildable. It answers one question: is a timed-out `getBuffer`
  non-destructive? If yes, the wait can be chunked with `drawnow` between chunks.
  **Needs a hardware run.**

---

## 5. Sequence fixes

### `hc_Scan_init_time` — readIQ timeout, diagnosed

CamRef width was `CtrGateDur` = 50 µs with a quarter of 50 µs, so the four pulses
ran **contiguously**: the line never went low, so there was no rising edge, and PB
emitted **1 edge per period instead of 4**. The camera wanted 800 edges and got
200.

`hc_CamRefWidth` now takes an optional explicit width — your `CtrGateDur` is
honoured up to `Q/2` and **warns** when it clamps, instead of either silently
breaking or silently substituting.

> `CtrGateDur` does two jobs in the pulsed sequences: camera exposure source *and*
> CamRef TTL width. Those want opposite things — max light wants exposure ≈ `Q`,
> a working reference train needs width ≤ `Q/2`. **You cannot have both from one
> field.** `cfg.camRefWidthNs` exists if you want them decoupled.

Also fixed: `quarterBinNsUsed` defaulted to `gmSEQ.readout` with a stale
three-sequence exception list, and *wrote that back* over `gmSEQ.quarterBinNs` —
so the pulse diagram at `LoadSEQ` showed the real QP while the run silently used
`readout`. Now `hc_QuarterBin` unconditionally.

### Registered

`hc_T1_S00_R_D_R` and `hc_T1_S01_R_D_R` added to both the `SequencePool` dispatch
and the dropdown. All nine `hc_*` entries verified to dispatch and build a valid
PB program.

---

## 6. Two open physics questions

### Bit 15 of the raw camera word

`readIQ` decodes with `mod(raw, 2^15)/4`, which **discards bit 15**. If that is a
sign bit, a negative quadrature cannot be represented:

| true value | decodes to |
|---|---|
| +100 | −25 ✓ |
| **−100** | **−8167** ← pinned at the rail (2¹⁵/4 = 8192) |
| −30000 | −692 ← reads as *small* |

This explains "Q saturates in my new sequence but not in Rabi": `hc_Rabi`'s
quadratures are both positive, so it never exercises the broken branch.
`hc_T1_D_S01_Rb_S00`'s `Q = S01 − S00` is physically negative.

**Fingerprint:** `|Q| ≈ 8191.75` exactly, and *unchanged* when you halve exposure
or `nPeriods`. Real saturation would scale with light.

**Not fixed**, because what bit 15 means is an unanswered question in your own
docs (`helicam_polarity_inversion.md:169`, `helicam_quarter_phase_offset.md:389`
both ask Heliotis whether the mask discards "a sign or overflow flag"). Changing
the decode blind would corrupt all existing Rabi data.

**Test to settle it:** run `hc_Image` twice, laser in Q1 only, then Q3 only.
Physically `I` should be equal and opposite. If two's-complement decoding gives
the same `|I|` both times, bit 15 is a sign bit.

### Dark reference is stale for period-changing sweeps

`AcquireDarkRef` runs **once**, at `SweepParam(1)`. For `hc_Rabi`/`hc_ODMR` the
period is fixed by QP, so one dark serves every point. For `hc_T1`,
`hc_T1_D_S01_Rb_S00` and `hc_Scan_init_time` the swept parameter **is part of the
quarter length**, so every point has a different period and the same dark is
subtracted from all of them.

Measured on `hc_T1_D_S01_Rb_S00_2026-8-22_Ave_050_001.h5` (a null test —
continuous laser, no MW, so everything is artifact):

- dim pixels drift **−0.25 counts/ms** of added quarter, R² = 0.89
- bright pixels drift **+0.21 counts/ms** — opposite sign, so *not* the dark
  reference; light-dependent, consistent with incomplete reset between quarters
- ~62% of the residual spatial variance is row/column fixed pattern, surviving
  the dark subtraction

The code comment claiming the choice of sweep point "does not matter" is
**falsified by this data**.

Also: the dark is a **single burst** while the data is averaged over `Average`
passes, so at `Average = 10` the dark carries ~3.2× more noise than the data it is
subtracted from — it becomes the dominant noise source.

---

## 7. New files

`mytoolboxes/HeliCam/`

| file | purpose |
|---|---|
| `hc_FocusMask.m` | stripline-shadow rejection |
| `hc_FocusMetric.m` | Tenengrad + 3 alternatives |
| `hc_FocusPeak.m` | interpolated peak, interior test, confidence |
| `hc_FocusConfig.m` | resolves focus knobs (gmSEQ > WidefieldConfig > default) |
| `hc_FocusCompare.m` | offline metric shootout on a saved `.h5` |
| `hc_FocusSelfTest.m` | hardware-free correctness test |
| `hc_Quantile.m` | percentile without the Statistics Toolbox |
| `hc_LoadIQ.m` | one loader; reads new and legacy names |
| `hc_DarkIQ.m` | same for dark-reference structs |
| `hc_WFExpr.m` | resolves the display expression |
| `hc_WFContrast.m` | evaluates it, never throws |
| `hc_AcqTimeoutMs.m` | burst-aware readIQ timeout |
| `hc_TimeoutProbe.m` | is a timed-out getBuffer recoverable? |

**Constraint respected throughout:** no Image Processing Toolbox, no Statistics
Toolbox — neither is used anywhere else in this repo. And no `.fig` edits; GUI
widgets were described for you to add, never modified.

---

## 8. Verification

Twelve suites, all passing, `checkcode` clean on every touched file. Only
`hc_FocusSelfTest.m` lives in the repo; the rest are in the session scratchpad and
will not survive.

`hc_FocusSelfTest` · `test_framesum` · `test_errorbar` · `test_marker` ·
`test_display_fix` · `test_override` · `test_wfexpr` · `test_seed` ·
`test_iq_rename` · `test_timeout` · `test_ave_restore` · `test_focus_integration`

**Not verified — needs hardware:** the Z moves themselves, the `takeDarkRef` tick
through the real GUI, whether Tenengrad is the right metric on your sample, and
`hc_TimeoutProbe`.

---

## 9. Open items

| item | note |
|---|---|
| **`hc_T1` is not registered** | the `.m` exists and declares `'I-Q'`, but there is no `case 'hc_T1'` in `SequencePool`. It *was* registered earlier; a restructure replaced that slot. Left alone in case retiring it was deliberate. |
| **`quarter_bin_ns` is wrong** for sequences that derive their own `Q` | it reports the QP box. Fix would be to read the quarter from the CamRef edge spacing in `CHN`, as `hc_AcqTimeoutMs` already does. |
| **Unclamped CamRef width** in `hc_Rabi`, `hc_T1`, `hc_ODMR` | one QP change from the `hc_Scan_init_time` timeout. One line each: `hc_CamRefWidth(cfg, Q, gmSEQ.CtrGateDur)`. Deliberately untouched. |
| **Bit-15 decode** | needs the Q1-only vs Q3-only test before changing. |
| **Dark reference per sweep point** | for period-changing sequences; would remove the −0.25 counts/ms drift. |
| **`hc_TimeoutProbe`** | needs one hardware run to decide if interruptible acquisition is buildable. |
| **Sequence header comments** | `hc_Image` says "laser in Q1 only" but has `DT = 2*Q`; `hc_T1` and the new `hc_T1_S0*_R_D_R` headers describe quarter layouts their code does not implement. |
