"""
hc_ExtTrigAcquire -- acquire one HeliCam C4 burst driven by an EXTERNAL
PulseBlaster reference, with MATLAB running the PB sequence.

Split of duties:
    Python (this script)  configures the camera, arms it, waits for data,
                          decodes I/Q and saves .h5
    MATLAB                runs the PB sequence that supplies the CamRef
                          quarter-period train on FI2 (and gates the laser)

Workflow:
    1. Run this script. It configures the camera and ARMS it, then blocks.
    2. When it prints "ARMED", run the PB sequence in MATLAB, e.g.
           SequencePool('hc_Image'); PBFunctionPool('PreprocessPBSequence', gmSEQ);
           Run_PB_Sequence();
       PB must emit at least the number of CamRef edges printed by this script.
    3. The camera fills its burst, fetch() returns, and the data is saved.

Based on the vendor example c4DemodSimple.py, with these differences (the
vendor example drives its own LED from the camera's internal signal generator
and uses an internal reference, neither of which applies here):

  * External reference, DivideBy4: LockInReferenceFrequencyScaler must be
    "DivideBy4" -- only that value routes the input straight to the sensor so
    each PB edge starts one quarter period. "On" is NOT the same thing.
  * FrameStart trigger stays on Software. FI2 carries the reference train; if
    FrameStart also listened to FI2 the first CamRef edge would both start the
    frame and be consumed as a reference edge.
  * Camera illumination is switched OFF -- the laser is gated by PB.
  * LockInActualTimeConstantNPeriods is read back, because the camera floors
    the effective value at 2 even when 1 is requested (firmware 1.11.0). The
    CamRef edge budget follows the ACTUAL value, not the requested one.

Output .h5 uses the same layout as MATLAB's SaveWidefield, so the result opens
directly in analysis/wf_viewer.py.

Run:  python hc_ExtTrigAcquire.py [-o out.h5]
"""

from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime

import numpy as np
from harvesters.core import Harvester
from packaging.version import parse as parse_version

# --------------------------------------------------------------------------- #
# Acquisition settings -- keep in step with WidefieldConfig.m
# --------------------------------------------------------------------------- #
SENSITIVITY      = 1.0        # LockInSensitivity p_s (1 -> t_s = 1/(4*f_ref))
N_PERIODS        = 20         # LockInTargetTimeConstantNPeriods (effective 2..100)
N_FRAMES         = 4          # AcquisitionBurstFrameCount (4..900)
COUPLING         = "DC"       # 'DC' or 'AC'  (AC costs one extra period/frame)
BLANK_PERIODS    = 0          # LockInTargetBlankDurationNPeriods
EXP_FREQ_DEV_PCT = 0          # LockInExpectedFrequencyDeviation d, %
REF_TIME_SHIFT_US = 0.0       # LockInReferenceTimeShift

# Per-quarter-bin exposure. Must match the PB quarter bin minus ~2 us sensor
# overhead, or the camera will not lock. f_ref is derived from it below.
EXPOSURE_SECONDS = 48e-6

REF_LINE         = "FI2"      # HeliCam input carrying the CamRef train
FETCH_TIMEOUT_S  = 120        # generous: PB is started by hand from MATLAB

T_CLOCK = 12.5e-9             # 80 MHz sensor clock
F_REF_MIN = 306.0             # camera minimum configured reference frequency


def exposure_to_reference_frequency(t_exp, sensitivity=1.0):
    """Nearest valid configured f_ref for a wanted per-quarter exposure.

    Mirrors HeliCamInterface.exposureToReferenceFrequency so both paths land on
    the same grid. Returns (f_ref, n_grid, t_exp_actual).
    """
    n_max = min(65536, int(sensitivity / (F_REF_MIN * 4 * T_CLOCK)))
    n = int(round(t_exp / (sensitivity * T_CLOCK)))
    n = max(146, min(n, n_max))
    f_ref = sensitivity / (n * 4 * T_CLOCK)
    return f_ref, n, sensitivity * n * T_CLOCK


def try_set(nm, name, value):
    """Write a GenICam feature, reporting rather than raising if unsupported."""
    try:
        getattr(nm, name).value = value
        return True
    except Exception as exc:
        print(f"  [warn] could not set {name} = {value!r}: {exc}")
        return False


def try_get(nm, name, default=None):
    try:
        return getattr(nm, name).value
    except Exception:
        return default


def select_device(h):
    h.update()
    n = len(h.device_info_list)
    print(f"{n} device(s) detected:")
    for i, dev in enumerate(h.device_info_list):
        print(f"  {i + 1}) {dev.id_} ({dev.serial_number})")
    if n == 0:
        sys.exit("No HeliCam detected.")
    if n == 1:
        idx = 0
    else:
        idx = int(input("Select a device (0=exit): ")) - 1
        if idx < 0 or idx >= n:
            sys.exit("No device selected.")
    print(f"Using: {h.device_info_list[idx].id_}\n")
    return h.create(idx)


def configure(camera):
    """External-reference DivideBy4 lock-in, camera illumination off."""
    nm = camera.remote_device.node_map
    f_ref, n_grid, t_exp = exposure_to_reference_frequency(EXPOSURE_SECONDS, SENSITIVITY)

    # --- Triggers ---
    # RecordingStart off: recording begins with the software FrameStart.
    try_set(nm, "TriggerSelector", "RecordingStart")
    try_set(nm, "TriggerMode", "Off")
    # FrameStart on Software. NOT FI2 -- that line carries the reference train.
    try_set(nm, "TriggerSelector", "FrameStart")
    try_set(nm, "TriggerMode", "On")
    try_set(nm, "TriggerSource", "Software")

    # --- Lock-in core ---
    try_set(nm, "DeviceOperationMode", "LockInCam")
    try_set(nm, "Scan3dExtractionMethod", "rawIQ")
    try_set(nm, "LockInSensitivity", SENSITIVITY)
    try_set(nm, "LockInTargetTimeConstantNPeriods", N_PERIODS)
    try_set(nm, "LockInTargetBlankDurationNPeriods", BLANK_PERIODS)
    try_set(nm, "LockInCoupling", COUPLING)
    try_set(nm, "LockInExpectedFrequencyDeviation", EXP_FREQ_DEV_PCT)
    try_set(nm, "LockInTargetReferenceFrequency", f_ref)
    try_set(nm, "AcquisitionBurstFrameCount", N_FRAMES)

    # --- External reference from PulseBlaster ---
    try_set(nm, "LockInReferenceSourceType", "External")
    # DivideBy4 is the only setting that routes each incoming pulse straight
    # through as one quarter-period trigger; everything else averages the input.
    try_set(nm, "LockInReferenceFrequencyScaler", "DivideBy4")
    try_set(nm, "LockInReferenceSourceSignal", REF_LINE)
    try_set(nm, "LockInReferenceTimeShift", REF_TIME_SHIFT_US)

    # --- Camera illumination OFF: PB gates the laser ---
    try_set(nm, "LightControllerSelector", "LightController0")
    if not try_set(nm, "LightControllerSource", "Off"):
        # Older firmware may not expose 'Off'; at least stop modulating.
        try_set(nm, "SignalGeneratorModulationMode", "Off")
        try_set(nm, "SignalGeneratorAmplitude", 0.0)

    # --- Read back what the camera actually holds ---
    actual_f = try_get(nm, "LockInActualReferenceFrequency", float("nan"))
    n_per_act = try_get(nm, "LockInActualTimeConstantNPeriods", N_PERIODS)
    n_blank_act = try_get(nm, "LockInActualBlankDurationNPeriods", BLANK_PERIODS)

    print("Camera configured:")
    print(f"  exposure          {t_exp * 1e6:.2f} us  (n={n_grid}, "
          f"f_ref {f_ref:.1f} Hz, actual {actual_f:.1f} Hz)")
    print(f"  periods/frame     target {N_PERIODS} -> ACTUAL {n_per_act}"
          f"   blank target {BLANK_PERIODS} -> ACTUAL {n_blank_act}")
    if n_per_act != N_PERIODS:
        print(f"  [note] camera overrode the period count; the edge budget "
              f"below follows the ACTUAL value {n_per_act}.")
    print(f"  frames            {N_FRAMES}")
    print(f"  coupling          {try_get(nm, 'LockInCoupling')}")
    print(f"  reference         {try_get(nm, 'LockInReferenceSourceType')} / "
          f"{try_get(nm, 'LockInReferenceFrequencyScaler')} on "
          f"{try_get(nm, 'LockInReferenceSourceSignal')}")

    # AC coupling reserves the first period of each frame for the background.
    ac_extra = 1 if str(try_get(nm, "LockInCoupling", "DC")).upper() == "AC" else 0
    periods_needed = (int(n_per_act) + int(n_blank_act) + ac_extra) * N_FRAMES
    edges_needed = 4 * periods_needed
    print(f"\n  PB must supply {periods_needed} lock-in periods "
          f"= {edges_needed} CamRef edges on {REF_LINE}.")
    return {
        "exposure_s": t_exp,
        "f_ref": f_ref,
        "n_periods": int(n_per_act),
        "n_blank": int(n_blank_act),
        "n_frames": N_FRAMES,
        "coupling": str(try_get(nm, "LockInCoupling", COUPLING)),
        "periods_needed": periods_needed,
        "edges_needed": edges_needed,
    }


def acquire(camera, timeout=FETCH_TIMEOUT_S):
    """Arm, wait for PB to drive the burst, return raw (I, Q) as (frames,H,W)."""
    nm = camera.remote_device.node_map
    n_frames = nm.AcquisitionBurstFrameCount.value
    height = nm.Height.value
    width = nm.Width.value

    camera.start()
    nm.TriggerSelector.value = "FrameStart"
    nm.TriggerSoftware.execute()

    print("\n" + "=" * 62)
    print("  ARMED -- run the PulseBlaster sequence in MATLAB now.")
    print(f"  Waiting up to {timeout} s for the burst to complete...")
    print("=" * 62 + "\n")

    try:
        with camera.fetch(timeout=timeout) as buffer:
            # Components are ordered I frames first, then Q frames. The decode
            # matches c4DemodSimple: strip the sign bit, scale by 1/4.
            data = np.array(
                [c.data % 2**15 // 4 for c in buffer.payload.components]
            ).reshape(2, n_frames, height, width)
    except Exception as exc:
        camera.stop()
        raise RuntimeError(
            f"No data within {timeout} s ({exc}). Did the PB sequence run, and "
            f"did it supply enough CamRef edges on {REF_LINE}?"
        ) from exc

    camera.stop()
    return data[0].astype(float), data[1].astype(float)


def save_h5(path, ref2d, raw2d, meta):
    """Write in MATLAB SaveWidefield's layout so wf_viewer.py can open it.

    MATLAB writes HDF5 column-major, so its (H, W, N) arrays are seen by h5py
    as (N, W, H). wf_viewer transposes (2,1,0) on load, so the datasets are
    stored here already in that (N, W, H) order.
    """
    import h5py

    ref = ref2d.T[None, :, :]      # (H,W) -> (1,W,H)
    raw = raw2d.T[None, :, :]

    with h5py.File(path, "w") as f:
        f.create_dataset("reference", data=ref, compression="gzip", compression_opts=4)
        f.create_dataset("rawsignal", data=raw, compression="gzip", compression_opts=4)
        f.create_dataset("sweep_param", data=np.zeros((1, 1)))
        f.attrs["sequence"] = "hc_ExtTrig"
        f.attrs["sweep_unit"] = "idx"
        f.attrs["derived"] = "contrast = rawsignal ./ reference"
        f.attrs["exposure_s"] = meta["exposure_s"]
        f.attrs["n_periods"] = meta["n_periods"]
        f.attrs["n_frames"] = meta["n_frames"]
        f.attrs["sensitivity"] = SENSITIVITY
        f.attrs["average"] = 1
        f.attrs["dark_subtracted"] = 0
        f.attrs["coupling"] = meta["coupling"]
        f.attrs["f_ref_Hz"] = meta["f_ref"]
        f.attrs["camref_edges"] = meta["edges_needed"]
        f.attrs["acquired"] = datetime.now().isoformat(timespec="seconds")
    print(f"Saved {path}")


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[1])
    ap.add_argument("-o", "--out", default=None, help="output .h5 path")
    ap.add_argument("--timeout", type=float, default=FETCH_TIMEOUT_S,
                    help="seconds to wait for the burst (default %(default)s)")
    ap.add_argument("--plot", action="store_true", help="show I/Q and RMS plots")
    args = ap.parse_args()

    h = Harvester()
    cti = os.environ.get("DIAPHUS_GENTL64_FILE")
    if not cti:
        sys.exit("DIAPHUS_GENTL64_FILE is not set; cannot locate the GenTL producer.")
    h.add_file(cti)

    camera = select_device(h)
    try:
        meta = configure(camera)
        raw_i, raw_q = acquire(camera, timeout=args.timeout)

        # Firmware <= 1.9.2 emits unusable initial frames; newer does not.
        fw = camera.remote_device.node_map.DeviceFirmwareVersion.value
        n_discard = 0 if parse_version(fw) > parse_version("1.9.2") else 2
        print(f"Firmware {fw} -> discarding {n_discard} warm-up frame(s).")
        I = raw_i[n_discard:]
        Q = raw_q[n_discard:]
        print(f"Got {I.shape[0]} usable frames of {I.shape[1]}x{I.shape[2]}")
        print(f"  I: mean {I.mean():+.4g}  std {I.std():.4g}")
        print(f"  Q: mean {Q.mean():+.4g}  std {Q.std():.4g}")

        # Match MATLAB: reference = mean(I), rawsignal = -mean(Q).
        ref2d = I.mean(axis=0)
        raw2d = -Q.mean(axis=0)

        out = args.out
        if out is None:
            stamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
            day = datetime.now().strftime("%Y-%-m-%-d") if os.name != "nt" \
                else datetime.now().strftime("%Y-%#m-%#d")
            folder = os.path.join(r"C:\Data", day)
            os.makedirs(folder, exist_ok=True)
            out = os.path.join(folder, f"hc_ExtTrig_{stamp}.h5")
        save_h5(out, ref2d, raw2d, meta)

        if args.plot:
            import matplotlib.pyplot as plt
            fig, ax = plt.subplots(1, 2, figsize=(11, 4.5), layout="constrained")
            for a, img, t in zip(ax, (ref2d, raw2d), ("mean I", "-mean Q")):
                im = a.imshow(img, cmap="magma")
                a.set_title(t)
                fig.colorbar(im, ax=a)
            plt.show()
    finally:
        try:
            camera.stop()
        except Exception:
            pass
        camera.destroy()
        h.reset()


if __name__ == "__main__":
    main()
