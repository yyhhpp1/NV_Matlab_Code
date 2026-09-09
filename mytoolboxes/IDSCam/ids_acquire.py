"""
ids_acquire -- GenTL/harvesters backend for the IDS uEye+ U3-3140CP-M, driven
from MATLAB through the in-process ``py.`` bridge.

WHY harvesters AND NOT ids_peak
    ids_peak is not installed on this machine and is not needed. Every node this
    integration touches -- TriggerSource, TriggerActivation, ExposureTime,
    LineMode, LineSource, Timer*, Counter*, ExposureTriggerMissed -- is standard
    GenICam, reachable through the GenTL producer that the IDS peak SDK installs
    at ids_u3vgentl/64/ids_u3vgentlk.cti. harvesters + genicam are already
    present in heli_cam_env, which is also the only interpreter on this machine
    inside MATLAB R2023b's supported py. range (3.9-3.11); the machine default
    is 3.13 and will not load.

    The HeliCam side already talks to its camera this way
    (mytoolboxes/HeliCam/hc_ExtTrigAcquire.py), so this is the established
    pattern in this repo rather than a new dependency.

SPLIT OF DUTIES
    MATLAB   owns the PulseBlaster, the sweep, the display and the saving.
    Python   owns the camera: configure, arm, fetch, reduce, write.

    arm() must NOT block -- MATLAB has to start the PB program after the camera
    is armed and before any trigger arrives. So the sequence per sweep point is:

        arm(n_frames)          camera streaming, waiting for CamTrig
        <MATLAB runs PB>
        fetch(timeout, path)   blocks until every frame has arrived
        stop()

FRAME COUNT IS A SAFETY PROPERTY
    fetch() asks for exactly the number of frames PB will trigger. If a trigger
    is missed the last frame never arrives and this times out LOUDLY, rather
    than returning a short-by-one burst whose SIG/REF pairing is silently
    inverted from the miss onward. Never call fetch() with fewer frames than PB
    will trigger.

All entry points return a JSON string, so nothing but text crosses the MATLAB
boundary and no numpy marshalling is involved. Pixel data goes to an HDF5 file
that MATLAB reads with h5read.
"""

from __future__ import annotations

import json
import os
import time

import numpy as np

_H = None          # Harvester
_IA = None         # ImageAcquirer
_STATE = {
    "connected": False,
    "armed": False,
    "width": 0,
    "height": 0,
    "pixel_format": "",
    "missed_counter": None,
    "armed_for": 0,
}


# --------------------------------------------------------------------------- #
# node-map helpers
# --------------------------------------------------------------------------- #

def _nm():
    if _IA is None:
        raise RuntimeError("not connected -- call connect() first")
    return _IA.remote_device.node_map


def _has(name):
    try:
        return getattr(_nm(), name) is not None
    except Exception:
        return False


def _get(name, default=None):
    try:
        return getattr(_nm(), name).value
    except Exception:
        return default


def _set(name, value):
    """Set a node and re-read it. Raises -- for nodes the design depends on."""
    node = getattr(_nm(), name)
    node.value = value
    return node.value


def _try_set(name, value, notes):
    """Set a node, recording the outcome instead of raising.

    For nodes that are optional (the Timer sync output, the missed-trigger
    counter) or that the camera may expose under a different name. The caller
    reports `notes` back to MATLAB so a silently skipped setting is visible
    rather than assumed.
    """
    try:
        got = _set(name, value)
        ok = (got == value)
        notes.append({"node": name, "wanted": _j(value), "got": _j(got), "ok": ok})
        return ok
    except Exception as exc:
        notes.append({"node": name, "wanted": _j(value), "error": str(exc), "ok": False})
        return False


def _j(v):
    """Make a node value JSON-safe."""
    try:
        json.dumps(v)
        return v
    except Exception:
        return str(v)


def _entries(name):
    """Available enum entries for a node, or [] if it is not an enum/absent."""
    try:
        node = getattr(_nm(), name)
        return [e.symbolic for e in node.entries if _usable(e)]
    except Exception:
        return []


def _usable(entry):
    try:
        # genicam access modes: 0 NI, 1 NA, 2 WO, 3 RO, 4 RW
        return entry.node.get_access_mode() in (3, 4)
    except Exception:
        return True


# --------------------------------------------------------------------------- #
# connect / disconnect
# --------------------------------------------------------------------------- #

def connect(cti_path, device_index=0):
    """Open the GenTL producer and create an ImageAcquirer for one device."""
    global _H, _IA

    if _STATE["connected"] and _IA is not None:
        return json.dumps({"ok": True, "reused": True, **_identity()})

    from harvesters.core import Harvester

    if not os.path.isfile(cti_path):
        return json.dumps({
            "ok": False,
            "error": "GenTL producer not found at {}. Is the IDS peak SDK "
                     "installed?".format(cti_path),
        })

    _H = Harvester()
    _H.add_file(cti_path)
    _H.update()

    n = len(_H.device_info_list)
    if n == 0:
        _H.reset()
        _H = None
        return json.dumps({
            "ok": False,
            "error": "GenTL producer loaded but enumerated 0 devices. Check the "
                     "USB3 cable and that no other process (IDS peak Cockpit) "
                     "holds the camera.",
        })
    if device_index >= n:
        info = [str(d) for d in _H.device_info_list]
        _H.reset()
        _H = None
        return json.dumps({
            "ok": False,
            "error": "device_index {} out of range; {} device(s) found".format(
                device_index, n),
            "devices": info,
        })

    # harvesters 1.4 renamed create_image_acquirer -> create.
    _IA = _H.create(int(device_index)) if hasattr(_H, "create") \
        else _H.create_image_acquirer(int(device_index))

    _STATE["connected"] = True
    _STATE["armed"] = False
    return json.dumps({"ok": True, "reused": False, **_identity()})


def _identity():
    return {
        "model": _get("DeviceModelName", "?"),
        "serial": _get("DeviceSerialNumber", "?"),
        "vendor": _get("DeviceVendorName", "?"),
        "firmware": _get("DeviceFirmwareVersion", "?"),
        "temperature_C": _get("DeviceTemperature", None),
        "clock_Hz": _get("DeviceClockFrequency", None),
    }


def disconnect():
    """Release the camera and the producer. Safe to call when already closed."""
    global _H, _IA
    try:
        if _IA is not None:
            try:
                _IA.stop()
            except Exception:
                pass
            _IA.destroy()
    except Exception:
        pass
    _IA = None
    try:
        if _H is not None:
            _H.reset()
    except Exception:
        pass
    _H = None
    _STATE["connected"] = False
    _STATE["armed"] = False
    return json.dumps({"ok": True})


# --------------------------------------------------------------------------- #
# configure
# --------------------------------------------------------------------------- #

def configure(cfg_json):
    """Apply ROI, pixel format, exposure, trigger, sync out and telemetry.

    Everything here must happen with acquisition STOPPED: trigger and line nodes
    are not writable while streaming, and attempting it raises a GenICam
    null-pointer exception rather than a clean error.
    """
    cfg = json.loads(cfg_json)
    notes = []

    try:
        _IA.stop()
    except Exception:
        pass
    _STATE["armed"] = False

    # --- free-run first, so ROI writes are not fighting an armed trigger -----
    _try_set("TriggerMode", "Off", notes)
    _try_set("AcquisitionMode", "Continuous", notes)

    # --- ROI. Offsets to 0 before sizing, or a large offset blocks a large
    # width/height; then re-apply (centred when not given). ------------------
    _try_set("OffsetX", 0, notes)
    _try_set("OffsetY", 0, notes)
    w = int(cfg["width"])
    h = int(cfg["height"])
    _set("Width", w)
    _set("Height", h)

    ox = cfg.get("offsetX", None)
    oy = cfg.get("offsetY", None)
    wmax = _get("WidthMax", w)
    hmax = _get("HeightMax", h)
    if ox is None:
        ox = int((wmax - w) // 2)
    if oy is None:
        oy = int((hmax - h) // 2)
    # Offsets snap to an increment; let the camera round rather than guessing.
    _try_set("OffsetX", int(ox), notes)
    _try_set("OffsetY", int(oy), notes)

    _set("PixelFormat", str(cfg["pixelFormat"]))

    # --- Gain. Digital-only on this sensor, so 1.0 always. -------------------
    _try_set("GainSelector", "DigitalAll", notes)
    _try_set("Gain", float(cfg.get("gain", 1.0)), notes)

    # --- Exposure. MATLAB has already snapped to the 5.5556 us grid; read the
    # camera's own minimum back so a disagreement is visible, not silent. -----
    expo_us = float(cfg["exposureNs"]) / 1000.0
    try:
        expo_min = getattr(_nm(), "ExposureTime").min
    except Exception:
        expo_min = None
    _set("ExposureTime", expo_us)
    expo_got = _get("ExposureTime")

    # --- Trigger in (scheme B1): one edge per frame, no divider -------------
    _try_set("TriggerSelector", "ExposureStart", notes)
    _set("TriggerSource", str(cfg["triggerLine"]))
    _try_set("TriggerActivation", str(cfg.get("triggerActivation", "RisingEdge")), notes)
    _try_set("TriggerDivider", int(cfg.get("triggerDivider", 1)), notes)
    _try_set("TriggerDelay", 0.0, notes)

    # The trigger line is bidirectional (GPIO1/GPIO2 are LVTTL) and does not
    # necessarily come up as an input. Set it explicitly -- an output-mode line
    # will never see the PB edge and the failure looks exactly like a bad cable.
    _try_set("LineSelector", str(cfg["triggerLine"]), notes)
    _try_set("LineMode", "Input", notes)

    _set("TriggerMode", "On")

    # --- Sync out (scheme A2): Timer0 off ExposureStart -> a line ------------
    if bool(cfg.get("enableSyncOut", False)):
        _try_set("TimerSelector", "Timer0", notes)
        _try_set("TimerTriggerSource", "ExposureStart", notes)
        _try_set("TimerDelay", float(cfg.get("syncOutDelayUs", 0.0)), notes)
        _try_set("TimerDuration", float(cfg.get("syncOutWidthUs", 10.0)), notes)
        _try_set("LineSelector", str(cfg.get("syncOutLine", "Line3")), notes)
        _try_set("LineMode", "Output", notes)
        _try_set("LineSource", "Timer0Active", notes)

    # --- Missed-trigger counter (scheme C1) ---------------------------------
    # The counter core is verified on internal events, but ExposureTriggerMissed
    # specifically was never tested as a source -- so this is _try_set
    # throughout and the caller is told whether it actually took.
    _STATE["missed_counter"] = None
    if bool(cfg.get("enableMissedCounter", False)):
        ctr = str(cfg.get("missedCounter", "Counter1"))
        ok = _try_set("CounterSelector", ctr, notes)
        ok = _try_set("CounterEventSource", "ExposureTriggerMissed", notes) and ok
        # Reset per burst. A reset SOURCE is used rather than a reset command
        # because AcquisitionStart is guaranteed to happen exactly once per arm().
        ok = _try_set("CounterResetSource", "AcquisitionStart", notes) and ok
        if ok:
            _STATE["missed_counter"] = ctr

    _STATE["width"] = int(_get("Width", w))
    _STATE["height"] = int(_get("Height", h))
    _STATE["pixel_format"] = str(_get("PixelFormat", cfg["pixelFormat"]))

    return json.dumps({
        "ok": True,
        "width": _STATE["width"],
        "height": _STATE["height"],
        "offsetX": _get("OffsetX"),
        "offsetY": _get("OffsetY"),
        "pixelFormat": _STATE["pixel_format"],
        "exposureNs": None if expo_got is None else expo_got * 1000.0,
        "exposureMinNs": None if expo_min is None else expo_min * 1000.0,
        "triggerSource": _get("TriggerSource"),
        "triggerMode": _get("TriggerMode"),
        "triggerDivider": _get("TriggerDivider"),
        "missedCounter": _STATE["missed_counter"],
        "notes": notes,
    })


# --------------------------------------------------------------------------- #
# arm / fetch / stop
# --------------------------------------------------------------------------- #

def arm(n_frames):
    """Start streaming and return immediately, with the camera waiting on CamTrig.

    Buffers are announced generously (n_frames + 8). Announcing fewer buffers
    than the burst will produce makes frames land nowhere and the count come up
    silently short -- a documented way to get a bogus result out of this camera
    (CAMERA_FINDINGS.md, "Two gotchas for reruns").
    """
    n = int(n_frames)
    try:
        _IA.stop()
    except Exception:
        pass

    _IA.num_buffers = max(n + 8, 16)
    _IA.start(run_as_thread=True) if _accepts_thread() else _IA.start()
    _STATE["armed"] = True
    _STATE["armed_for"] = n
    return json.dumps({"ok": True, "armed_for": n, "num_buffers": _IA.num_buffers})


def _accepts_thread():
    try:
        import inspect
        return "run_as_thread" in inspect.signature(_IA.start).parameters
    except Exception:
        return False


def fetch(timeout_ms, out_path):
    """Block until n frames have arrived, then write them to HDF5.

    Returns ok=False with n_got on a timeout rather than raising, so MATLAB can
    report the diagnosis (including the missed-trigger count) instead of a bare
    exception.
    """
    if not _STATE["armed"]:
        return json.dumps({"ok": False, "error": "fetch() called before arm()"})

    # The count arm() was given, NOT one recovered from num_buffers: that is
    # max(n + 8, 16), so for any burst under 8 frames it does not invert back to
    # n and this would silently fetch the wrong number. Asking for the wrong
    # number is the one mistake this whole path is built to make impossible.
    return _fetch_n(int(_STATE["armed_for"]), float(timeout_ms), str(out_path))


def fetch_n(n_frames, timeout_ms, out_path):
    """As fetch(), with the frame count stated explicitly."""
    if not _STATE["armed"]:
        return json.dumps({"ok": False, "error": "fetch() called before arm()"})
    return _fetch_n(int(n_frames), float(timeout_ms), str(out_path))


def _fetch_n(n, timeout_ms, out_path):
    import h5py

    H = _STATE["height"]
    W = _STATE["width"]
    frames = np.zeros((n, H, W), dtype=np.uint16)

    deadline = time.time() + timeout_ms / 1000.0
    got = 0
    incomplete = 0
    frame_ids = []
    timestamps = []
    err = None

    try:
        while got < n:
            remain = deadline - time.time()
            if remain <= 0:
                err = ("timed out after {:.1f} s with {} of {} frames. Either PB "
                       "did not run, the camera never saw a CamTrig edge on the "
                       "configured line, or a trigger was missed.").format(
                           timeout_ms / 1000.0, got, n)
                break
            with _IA.fetch(timeout=remain) as buf:
                comp = buf.payload.components[0]
                if getattr(buf, "is_complete", lambda: True)() is False:
                    incomplete += 1
                data = comp.data
                # Mono10/Mono10p arrive 16-bit; Mono8 8-bit. Upcast so the
                # stored dtype does not depend on the pixel format.
                frames[got] = np.asarray(data, dtype=np.uint16).reshape(
                    int(comp.height), int(comp.width))
                frame_ids.append(int(getattr(buf, "frame_id", -1)))
                timestamps.append(int(getattr(buf, "timestamp_ns", 0)))
                got += 1
    except Exception as exc:
        err = "{}: {}".format(type(exc).__name__, exc)

    missed = _read_missed()

    # Write whatever arrived. A partial burst is still worth looking at when
    # diagnosing, and MATLAB decides whether to use it.
    try:
        if os.path.exists(out_path):
            os.remove(out_path)
        with h5py.File(out_path, "w") as f:
            f.create_dataset("frames", data=frames[:got], compression="gzip",
                             compression_opts=1)
            f.attrs["n_frames"] = got
            f.attrs["height"] = H
            f.attrs["width"] = W
            f.attrs["pixel_format"] = _STATE["pixel_format"]
            if frame_ids:
                f.create_dataset("frame_id", data=np.asarray(frame_ids, dtype=np.int64))
            if timestamps:
                f.create_dataset("timestamp_ns",
                                 data=np.asarray(timestamps, dtype=np.int64))
    except Exception as exc:
        return json.dumps({
            "ok": False,
            "error": "acquired {} frames but could not write {}: {}".format(
                got, out_path, exc),
            "n_got": got,
            "missed_triggers": missed,
        })

    # FrameID gaps mean frames were dropped in DELIVERY. They are a different
    # fault from a missed trigger -- a missed trigger leaves FrameID contiguous,
    # because the frame was never started -- so both are reported separately.
    gaps = 0
    if len(frame_ids) > 1:
        d = np.diff(np.asarray(frame_ids))
        gaps = int(np.sum(d[d > 0] - 1))

    return json.dumps({
        "ok": err is None and got == n,
        "error": err,
        "n_got": got,
        "n_wanted": n,
        "incomplete_buffers": incomplete,
        "frame_id_gaps": gaps,
        "missed_triggers": missed,
        "path": out_path,
    })


def _read_missed():
    """Current value of the ExposureTriggerMissed counter, or None."""
    ctr = _STATE.get("missed_counter")
    if not ctr:
        return None
    try:
        _set("CounterSelector", ctr)
        return int(_get("CounterValue", -1))
    except Exception:
        return None


def stop():
    try:
        _IA.stop()
    except Exception:
        pass
    _STATE["armed"] = False
    return json.dumps({"ok": True})


# --------------------------------------------------------------------------- #
# diagnostics (ids_TriggerTest)
# --------------------------------------------------------------------------- #

def line_status():
    """Per-line mode/status, plus the enum entries the camera actually offers.

    Used by ids_TriggerTest to answer, in order: is the line an input, does it
    see the PB edge, and is ExposureTriggerMissed available as a counter source.
    """
    out = {"ok": True, "lines": [], "trigger_sources": _entries("TriggerSource"),
           "line_sources": _entries("LineSource"),
           "counter_event_sources": _entries("CounterEventSource"),
           "event_selectors": _entries("EventSelector"),
           "exposure_modes": _entries("ExposureMode")}
    for name in ("Line0", "Line1", "Line2", "Line3"):
        try:
            _set("LineSelector", name)
            out["lines"].append({
                "line": name,
                "mode": _get("LineMode"),
                "status": _get("LineStatus"),
                "format": _get("LineFormat"),
                "source": _get("LineSource"),
            })
        except Exception as exc:
            out["lines"].append({"line": name, "error": str(exc)})
    try:
        out["line_status_all"] = _get("LineStatusAll")
    except Exception:
        out["line_status_all"] = None
    return json.dumps(out)


def sample_line(line_name, n_samples, interval_s):
    """Poll one line's LineStatus, returning how often it read high.

    ids_TriggerTest uses this while PB toggles CamTrig: a line that never
    changes is either not wired, not an input, or not being driven.
    """
    try:
        _set("LineSelector", str(line_name))
        _try_set("LineMode", "Input", [])
    except Exception as exc:
        return json.dumps({"ok": False, "error": str(exc)})

    n = int(n_samples)
    high = 0
    seen = set()
    for _ in range(n):
        v = _get("LineStatus", None)
        if v:
            high += 1
        seen.add(bool(v))
        if interval_s > 0:
            time.sleep(float(interval_s))
    return json.dumps({
        "ok": True,
        "line": line_name,
        "samples": n,
        "high": high,
        "toggled": len(seen) > 1,
    })


def node_info(name):
    """Access mode, value and entries for one node -- for interactive probing."""
    try:
        node = getattr(_nm(), name)
    except Exception as exc:
        return json.dumps({"ok": False, "error": str(exc), "available": False})
    info = {"ok": True, "available": True, "node": name}
    for attr in ("value", "min", "max", "inc", "unit"):
        try:
            info[attr] = _j(getattr(node, attr))
        except Exception:
            pass
    ent = _entries(name)
    if ent:
        info["entries"] = ent
    return json.dumps(info)
