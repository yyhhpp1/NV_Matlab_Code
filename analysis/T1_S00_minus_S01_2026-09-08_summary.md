# NV T₁ from the HeliCam S₀₀ − S₀₁ difference

**Date:** 2026-09-08 · **Sample position:** centre of frame, widefield spot
**Notebook:** `analysis/T1_S00_minus_S01_2026-09-08.ipynb`
**Figures:** `analysis/figs_T1_2026-09-08/`

---

## Headline result

| Quantity | Value |
|---|---|
| **T₁** | **2.228 ± 0.091 ms** |
| **β** (stretch exponent) | **0.924 ± 0.047** |
| ⟨τ⟩ mean relaxation time | 2.311 ± 0.117 ms |
| A (amplitude) | 612.8 ± 5.4 counts |
| R² | 0.99786 |
| Fit region | 25,630 px, bright middle of the frame |

Model: **D(τ) = A·exp[−(τ/T₁)^β]**, all three parameters free.

Plain-exponential reference (β ≡ 1) for comparison: T₁ = 2.212 ± 0.093 ms, R² = 0.99716.

---

## Data

| Run | File | Sequence | Averages |
|---|---|---|---|
| S₀₀ | `hc_T1_S00_R_D_R_2026-9-8_001.h5` | no MW before readout | 5 |
| S₀₁ | `hc_T1_S01_R_D_R_2026-9-8_001.h5` | π pulse before readout | 140 |
| Widefield | `hc_Image_2026-9-8_006.h5` | MW off (2 GHz, −80 dBm) | 7 |

All from `C:\Data\2026-9-8`. Identical 11-point log-spaced delay list, τ = 1 μs … 10 ms,
512 × 542 px, dark-subtracted, stored per-average. MW 2.870 GHz at −7 dBm, 38 μs exposure,
40 frames per point.

The population difference **D(τ,x,y) = I_S00 − I_S01** is formed for every pixel. It starts at full
contrast and relaxes to zero as the mₛ = 0 and mₛ = ±1 populations equilibrate, so it decays with T₁.

---

## 1. Defining the fit region

The ROI is cut from the data, not drawn by hand: box-smooth the first-delay difference image and
keep everything above 50% of its peak. This selects the bright central blob (25,630 px, 9.2% of the
frame, rows 208–390, cols 210–390) and rejects the dark surround where the difference is noise
about zero.

> **[ INSERT `fig1_roi_definition.png` ]**
> S₀₀, S₀₁, and their difference at τ = 1 μs, with the ROI outlined in orange.

> **[ INSERT `fig2_delay_series.png` ]**
> The difference at all 11 delays on a common colour scale — the blob fades into the surround by 10 ms.

---

## 2. The fit

> **[ INSERT `fig3_decay_fit.png` ]**
> ROI-averaged decay with the stretched fit (orange) and the β ≡ 1 reference (grey dashed),
> plus residuals for both. Linear τ axis.

| τ (ms) | data | s.e.m. | stretched fit | resid | β≡1 fit | resid |
|---|---|---|---|---|---|---|
| 0.0010 | 594.83 | 0.76 | 612.35 | −17.52 | 608.23 | −13.40 |
| 0.0025 | 596.15 | 0.77 | 611.69 | −15.54 | 607.82 | −11.67 |
| 0.0063 | 621.99 | 0.79 | 610.14 | 11.85 | 606.77 | 15.22 |
| 0.0158 | 618.34 | 0.79 | 606.53 | 11.81 | 604.16 | 14.18 |
| 0.0398 | 607.25 | 0.77 | 598.16 | 9.09 | 597.65 | 9.60 |
| 0.1000 | 583.93 | 0.75 | 579.00 | 4.93 | 581.60 | 2.33 |
| 0.2512 | 536.89 | 0.70 | 536.48 | 0.41 | 543.17 | −6.28 |
| 0.6310 | 442.78 | 0.62 | 448.72 | −5.95 | 457.46 | −14.68 |
| 1.5850 | 293.36 | 0.51 | 295.30 | −1.94 | 297.17 | −3.80 |
| 3.9814 | 116.55 | 0.34 | 110.83 | 5.72 | 100.55 | 16.00 |
| 10.0010 | 5.83 | 0.18 | 11.16 | −5.33 | 6.61 | −0.78 |

**On β:** 0.924 ± 0.047 is only **1.6σ from 1**, and stretching cuts the rms residual by 13%
(11.15 → 9.70 counts) for one extra parameter. The data are *consistent* with stretching but do not
demand it. Since T₁ in a stretched exponential is a scale parameter rather than the decay's centre
of mass, ⟨τ⟩ = (T₁/β)·Γ(1/β) = 2.311 ms is the number to compare against a plain-exponential T₁
from another run.

---

## 3. Per-pixel maps

Same model fitted independently to every ROI pixel, all three parameters free. All 25,630 converged,
none pinned to a bound.

| | median | IQR |
|---|---|---|
| T₁ | 2.267 ms | 1.722 – 2.877 ms |
| β | 0.952 | 0.909 – 0.997 |
| ⟨τ⟩ | 2.323 ms | 1.792 – 2.911 ms |

> **[ INSERT `fig4_per_pixel_maps.png` ]**
> Maps of A, T₁ and β with their distributions. Only 11 delays constrain three parameters, so the
> per-pixel β is noisy — read the map for structure, the median for the central value.

---

## 4. Main finding: a vertical T₁ gradient

**T₁ rises smoothly from 1.72 ms at the top of the ROI to 2.86 ms at the bottom — a factor of ~1.7
across the region, and 2.6× between the extreme sampled pixels.**

| correlation with | T₁ | β |
|---|---|---|
| amplitude A | −0.07 | −0.31 |
| **row (vertical position)** | **+0.82** | +0.32 |
| column (horizontal) | −0.24 | −0.16 |

This is not an SNR artefact. The obvious suspect — dim pixels fitting badly — would show as a
correlation between A and T₁, and there is none (−0.07): A peaks in the middle of the blob while T₁
climbs monotonically down the frame. β drifts far less over the same span (0.934 → 0.969), so the
*rate* is what varies across the field of view while the stretching is close to a global property.

> **[ INSERT `fig5_row_profiles.png` ]**
> Median T₁ and β per sensor row, interquartile bands. Same row axis — the difference in slope is the point.

### Ten single pixels across the gradient

One pixel per equally-spaced row down the ROI's centre column (col 298), each with its own fit:

| # | row | A | T₁ (ms) | β | SNR |
|---|---|---|---|---|---|
| 1 | 212 | 443 | 1.20 ± 0.10 | 0.96 | 6.0 |
| 2 | 231 | 594 | 1.40 ± 0.05 | 0.92 | 7.2 |
| 3 | 251 | 703 | 1.52 ± 0.08 | 0.92 | 6.1 |
| 4 | 270 | 815 | 1.86 ± 0.07 | 0.84 | 6.1 |
| 5 | 289 | 886 | 2.21 ± 0.06 | 0.89 | 5.1 |
| 6 | 309 | 876 | 2.53 ± 0.11 | 0.96 | 4.6 |
| 7 | 328 | 768 | 2.59 ± 0.10 | 0.99 | 4.5 |
| 8 | 347 | 712 | 3.63 ± 0.18 | 0.92 | 4.5 |
| 9 | 367 | 483 | 2.56 ± 0.19 | 1.08 | 4.0 |
| 10 | 386 | 422 | 3.10 ± 0.21 | 1.15 | 3.5 |

> **[ INSERT `fig6_ten_pixels_overview.png` ]**
> Where the ten pixels sit on the T₁ map, and their decays scaled by each pixel's own amplitude.

> **[ INSERT `fig7_ten_pixels_fits.png` ]**
> Each sampled pixel with its own fit, at its own amplitude. Panels run top to bottom of the ROI.

Caveats on these ten: pixel 9 breaks the monotonic rise (2.56 ms between neighbours at 3.63 and
3.10) — ordinary single-pixel noise at SNR 4. Pixels 9 and 10 return β > 1, a *compressed*
exponential, which is not physically expected; three free parameters on 11 noisy points is simply
underdetermined at the ROI's dim bottom edge. Do not read those as measurements of stretching.

---

## 5. Alignment with the widefield image

`hc_Image_2026-9-8_006.h5` is the same camera and the same 512 × 542 grid, so it compares
pixel-for-pixel with no registration step.

| | |
|---|---|
| widefield half-max spot | centroid (285.9, 311.0), 28,873 px |
| T₁ fit ROI | centroid (298.3, 297.9), 25,630 px |
| centroid offset | 18 px |
| **ROI inside the widefield spot** | **91.8%** |
| corr(widefield, S₀₀−S₀₁ at τ₁) | 0.97 full-frame, 0.84 within ROI |

The fit region is the bright core of the widefield spot, sitting slightly below-left of the spot's
own centre. Absolute counts are *not* comparable between the two — the widefield sums 10 frames per
point against the T₁ runs' 40 — so only spatial correspondence is read off.

> **[ INSERT `fig8_widefield_alignment.png` ]**
> Widefield fluorescence, the first-delay difference, and the fitted T₁ map — same coordinate system,
> same ROI outline on all three.

### Does brightness predict T₁?

Partly. Raw corr(brightness, T₁) = −0.49, but brightness and row are themselves correlated (−0.36):
the spot dims towards the bottom of the frame, exactly where T₁ is longest. Partial correlations
separate them:

- **Vertical position dominates** — holding brightness fixed barely touches it, +0.82 → +0.79.
- **Brightness is secondary but real** — holding row fixed weakens it by roughly a quarter,
  −0.49 → −0.36. Reduced, not gone.

> **[ INSERT `fig9_brightness_vs_t1.png` ]**
> Median T₁ per widefield-brightness bin, interquartile band.

The shape matters more than the coefficient. T₁ falls steeply from ~3.4 ms at the dim edge of the
ROI to ~2.0 ms by about 1400 counts, then goes **flat** — the whole bright core fits the same ~2 ms
regardless of brightness. The long-T₁ tail in the per-pixel histogram is the ROI's dim rim, not a
gradual trend across the core.

---

## Open items

1. **S₀₀ is under-averaged.** 5 averages against S₀₁'s 140. The files are stored per-average so the
   subtraction is valid, but S₀₀ carries most of the noise, and the fit residuals show systematic
   ±15-count structure far above the 0.8-count s.e.m. Re-running S₀₀ to comparable depth would
   tighten the T₁ error bar and settle whether that residual structure is noise or a real departure
   from the model.
2. **The ROI threshold is a judgement call.** Tightening it above 50% of peak would drop the dim rim,
   pull the per-pixel median toward 2 ms and shrink the spread. Which is right depends on whether the
   rim pixels are measuring the sample or the edge of the illumination.
3. **What drives the vertical gradient?** It tracks position on the sample, not signal strength or
   brightness. Candidates worth separating: MW field inhomogeneity across the stripline, a real
   sample gradient, or an optical/collection asymmetry.
