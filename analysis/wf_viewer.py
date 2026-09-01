"""
wf_viewer -- interactive viewer for HeliCam widefield .h5 runs.

Shows the I and Q images for a run plus a third, user-defined quantity, and
lets you pull ROI traces out of them as a function of the swept parameter.
ROIs are drawn directly on the image -- drag a rectangle, click a point, or
draw a freehand outline -- and every ROI appears simultaneously in all three
trace panels so the quantities can be compared for the same region.

The derived quantity is any expression in I and Q typed into the "derived ="
box (or picked from its dropdown): Q/I, I-Q, I+Q, (I-Q)/(I+Q),
sqrt(I**2+Q**2), arctan2(Q,I), ... Most numpy element-wise functions are
available. Q/I is the default. Note MATLAB stores NO derived quantity -- only the two
quadratures -- because which combination carries the physics depends on where
the sequence put the laser and MW. The root attr iq_convention states what I and
Q are for that file.

Datasets were called /reference (I) and /rawsignal (Q) before 2026-08; both
spellings are read, so older files still open.

File layout (written by SaveWidefield / SaveWidefieldAve in RunSequence.m):
    /I            (H, W, N)  mean over frames of (Q1 - Q3)
    /Q            (H, W, N)  mean over frames of (Q2 - Q4)
    /sweep_param  (1, N)
    /dark_I       (H, W)     final file only, when a dark was applied
    /dark_Q       (H, W)     final file only, when a dark was applied
    root attrs: sequence, sweep_unit, exposure_s, n_periods, n_frames,
                dark_subtracted, dark_source, params_json, ...

Both I and Q are already sign-corrected: HeliCamInterface.readIQ negates at decode
(the C4's demodulation weight is the negative of the manual's Eq. 5.54), so no
further sign flip belongs anywhere downstream -- including here.

/dark_I and /dark_Q are ONE frame pair for the whole run: the camera's per-pixel
noise is static at fixed settings, so a single laser-off burst is captured before
the sweep and subtracted from every sweep point and every average pass. They are
stored in the same sign-corrected domain as /I and /Q, so
    raw I = /I + /dark_I
    raw Q = /Q + /dark_Q
recovers the raw pedestal (~517) if you need it. dark_source says where the dark
came from: 'fresh' (this run, matched settings), 'stored' (wf_darkref.mat, may be
stale), or 'none' (nothing subtracted -- the arrays still carry the pedestal).

MATLAB writes HDF5 column-major, so h5py reports these as (N, W, H); they are
transposed back to (H, W, N) on load.

Deleting an ROI -- any of:
    * select it in the list and press Delete (or the button)
    * double-click it in the list
    * right-click it on the image

Run:  python wf_viewer.py [file.h5]
"""

from __future__ import annotations

import json
import os
import sys
import tkinter as tk
import warnings
from tkinter import filedialog, messagebox, ttk

import h5py
import numpy as np
from matplotlib.backends.backend_tkagg import (
    FigureCanvasTkAgg,
    NavigationToolbar2Tk,
)
from matplotlib.figure import Figure
from matplotlib.patches import Polygon, Rectangle
from matplotlib.path import Path
from matplotlib.widgets import LassoSelector, RectangleSelector

# Distinguishable at small size against both the image and the trace panels.
ROI_COLORS = [
    "#e41a1c", "#377eb8", "#4daf4a", "#984ea3",
    "#ff7f00", "#00ced1", "#f781bf", "#a65628",
]

# Third quantity is whatever the user's formula evaluates to.
QUANTITIES = ("I", "Q", "derived")

DEFAULT_FORMULA = "Q/I"

FORMULA_PRESETS = [
    "Q/I",                  # per-pixel ratio of the two quadratures
    "-Q/I",
    "I-Q",
    "I+Q",
    "(I-Q)/(I+Q)",
    "sqrt(I**2+Q**2)",      # lock-in magnitude
    "arctan2(Q,I)",         # lock-in phase (rad)
    "Q",
    "I",
]

# Names a formula may use. Restricted so a typo fails with a clear message
# instead of doing something surprising -- a convenience guard for interactive
# typing, not a security sandbox.
_FORMULA_FUNCS = {
    n: getattr(np, n) for n in (
        "abs", "sqrt", "log", "log10", "log2", "exp", "sin", "cos", "tan",
        "arcsin", "arccos", "arctan", "arctan2", "hypot", "sign", "square",
        "clip", "maximum", "minimum", "power", "real", "imag", "angle",
        "nan_to_num", "floor", "ceil", "round",
    )
}
_FORMULA_CONSTS = {"pi": np.pi, "e": np.e, "nan": np.nan, "inf": np.inf}


def evaluate_formula(expr: str, I: np.ndarray, Q: np.ndarray,
                     mask_small_I: bool = True) -> np.ndarray:
    """Evaluate a user formula in terms of I and Q, returning a float array.

    Non-finite results become NaN so a divide-by-zero cannot set the colour
    scale for the whole frame. With mask_small_I, pixels where |I| is
    negligible are also dropped: after dark subtraction I sits near zero on
    unlit pixels, and any ratio-like formula explodes there while staying
    finite, which no inf check would catch.
    """
    expr = (expr or "").strip()
    if not expr:
        raise ValueError("formula is empty")
    if "__" in expr:
        raise ValueError("'__' is not allowed in a formula")

    ns = {"I": I, "Q": Q, **_FORMULA_FUNCS, **_FORMULA_CONSTS}
    with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
        out = eval(compile(expr, "<formula>", "eval"), {"__builtins__": {}}, ns)

    out = np.asarray(out, dtype=float)
    if out.shape != I.shape:
        # A scalar (e.g. "1") broadcasts; anything else is a mistake.
        if out.ndim == 0:
            out = np.broadcast_to(out, I.shape).copy()
        else:
            raise ValueError(
                f"formula produced shape {out.shape}, expected {I.shape}")

    out[~np.isfinite(out)] = np.nan
    if mask_small_I:
        scale = np.nanpercentile(np.abs(I), 99)
        if not np.isfinite(scale) or scale == 0:
            scale = 1.0
        out[np.abs(I) < 1e-6 * scale] = np.nan
    return out


# --------------------------------------------------------------------------- #
# Data
# --------------------------------------------------------------------------- #
class WideRun:
    """One loaded widefield .h5 run."""

    def __init__(self, path: str):
        self.path = path
        with h5py.File(path, "r") as h:
            # Current names first, then the pre-rename ones so old runs load.
            self.I = self._read(h, "/I")
            if self.I is None:
                self.I = self._read(h, "/reference")
                self.Q = self._read(h, "/rawsignal")
            else:
                self.Q = self._read(h, "/Q")
            sweep = np.asarray(h["/sweep_param"][...]).ravel() \
                if "/sweep_param" in h else None
            self.attrs = {k: v for k, v in h.attrs.items()}

        if self.I is None:
            raise ValueError(
                "neither /I nor legacy /reference found -- not a widefield file?")
        if self.Q is None:
            self.Q = np.full_like(self.I, np.nan)

        self.H, self.W, self.N = self.I.shape

        if sweep is None or sweep.size != self.N:
            sweep = np.arange(self.N, dtype=float)
        self.sweep = sweep

        # Derived quantity is recomputed on demand from the current formula and
        # cached, since the slider redraws the image far more often than the
        # formula changes.
        self._derived_key = None
        self._derived = None

    def derived(self, formula: str, mask_small_I: bool = True) -> np.ndarray:
        key = (formula, mask_small_I)
        if key != self._derived_key:
            self._derived = evaluate_formula(formula, self.I, self.Q, mask_small_I)
            self._derived_key = key
        return self._derived

    @staticmethod
    def _read(h, name):
        if name not in h:
            return None
        # (N, W, H) as h5py sees MATLAB's column-major (H, W, N).
        return np.transpose(np.asarray(h[name][...], dtype=float), (2, 1, 0))

    def attr(self, key, default=None):
        v = self.attrs.get(key, default)
        if isinstance(v, np.ndarray):
            v = v.ravel()[0] if v.size == 1 else v
        if isinstance(v, bytes):
            v = v.decode(errors="replace")
        return v

    @property
    def sweep_unit(self) -> str:
        u = self.attr("sweep_unit", "") or ""
        # MATLAB writes TeX like '{\mu}s'; make it readable in a plain label.
        return str(u).replace("{\\mu}", "u").replace("{", "").replace("}", "")

    def summary(self) -> str:
        bits = [f"{self.attr('sequence', '?')}",
                f"{self.H}x{self.W}, {self.N} pt"]
        for key, label, fmt in (
            ("exposure_s", "exp", "{:.3g}s"),
            ("n_periods", "nPer", "{:.0f}"),
            ("n_frames", "nFr", "{:.0f}"),
            ("average", "Ave", "{:.0f}"),
        ):
            v = self.attr(key)
            if v is not None:
                bits.append(f"{label} {fmt.format(float(v))}")
        dark = self.attr("dark_subtracted")
        if dark is not None:
            bits.append("dark-sub ON" if float(dark) else "dark-sub OFF")
        else:
            bits.append("dark-sub ?")
        cpl = None
        try:
            cpl = json.loads(self.attr("params_json", "{}")).get("coupling")
        except Exception:
            pass
        if cpl:
            bits.append(f"{cpl}")
        return " | ".join(bits)


# --------------------------------------------------------------------------- #
# ROIs
# --------------------------------------------------------------------------- #
class Roi:
    """An ROI as a boolean pixel mask, so freehand shapes work like boxes do."""

    _next_id = 1

    def __init__(self, mask: np.ndarray, kind: str, color: str, verts=None):
        self.mask = mask
        self.kind = kind
        self.color = color
        self.verts = verts          # outline for freehand ROIs
        self.id = Roi._next_id
        Roi._next_id += 1
        self.patch = None

        rows = np.flatnonzero(np.any(mask, axis=1))
        cols = np.flatnonzero(np.any(mask, axis=0))
        if rows.size and cols.size:
            self.r0, self.r1 = int(rows[0]), int(rows[-1]) + 1
            self.c0, self.c1 = int(cols[0]), int(cols[-1]) + 1
        else:
            self.r0 = self.r1 = self.c0 = self.c1 = 0
        self.npix = int(mask.sum())

    # -- constructors -- #
    @classmethod
    def from_box(cls, r0, r1, c0, c1, kind, color, H, W):
        r0 = max(0, min(int(r0), H - 1))
        c0 = max(0, min(int(c0), W - 1))
        r1 = max(r0 + 1, min(int(r1), H))
        c1 = max(c0 + 1, min(int(c1), W))
        mask = np.zeros((H, W), dtype=bool)
        mask[r0:r1, c0:c1] = True
        return cls(mask, kind, color)

    @classmethod
    def from_verts(cls, verts, color, H, W):
        """Freehand outline -> mask via point-in-polygon over the frame."""
        yy, xx = np.mgrid[0:H, 0:W]
        pts = np.column_stack((xx.ravel(), yy.ravel()))
        mask = Path(verts).contains_points(pts).reshape(H, W)
        if not mask.any():
            return None
        return cls(mask, "free", color, verts=np.asarray(verts))

    @property
    def label(self) -> str:
        if self.kind == "point":
            return (f"#{self.id} pt ({(self.c0 + self.c1) // 2},"
                    f"{(self.r0 + self.r1) // 2})")
        if self.kind == "free":
            return f"#{self.id} free {self.npix}px"
        return f"#{self.id} rect {self.c1 - self.c0}x{self.r1 - self.r0}"

    def fits(self, H, W) -> bool:
        return self.mask.shape == (H, W)

    def contains(self, r: int, c: int) -> bool:
        if not (0 <= r < self.mask.shape[0] and 0 <= c < self.mask.shape[1]):
            return False
        return bool(self.mask[r, c])

    def trace(self, stack: np.ndarray) -> np.ndarray:
        if self.npix == 0:
            return np.full(stack.shape[2], np.nan)
        sub = stack[self.mask, :]                      # (npix, N)
        with warnings.catch_warnings():                # all-NaN ROI is legal
            warnings.simplefilter("ignore", RuntimeWarning)
            return np.nanmean(sub, axis=0)

    def stats(self, stack: np.ndarray, j: int):
        if self.npix == 0:
            return np.nan, np.nan
        sub = stack[self.mask, j]
        if np.all(np.isnan(sub)):
            return np.nan, np.nan
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", RuntimeWarning)
            return float(np.nanmean(sub)), float(np.nanstd(sub))

    def make_patch(self):
        if self.kind == "free" and self.verts is not None:
            return Polygon(self.verts, closed=True, fill=False,
                           edgecolor=self.color, linewidth=1.6)
        return Rectangle((self.c0 - 0.5, self.r0 - 0.5),
                         self.c1 - self.c0, self.r1 - self.r0,
                         fill=False, edgecolor=self.color, linewidth=1.6)


# --------------------------------------------------------------------------- #
# GUI
# --------------------------------------------------------------------------- #
class Viewer(tk.Tk):
    def __init__(self, initial: str | None = None):
        super().__init__()
        self.title("Widefield viewer")
        self.geometry("1500x900")

        self.run: WideRun | None = None
        self.rois: list[Roi] = []
        self._color_i = 0
        self._formula_ok = DEFAULT_FORMULA   # last formula that evaluated cleanly

        self._build()
        if initial:
            self.load(initial)

    # -- layout ------------------------------------------------------------ #
    def _build(self):
        top = ttk.Frame(self, padding=(6, 4))
        top.pack(side=tk.TOP, fill=tk.X)
        ttk.Button(top, text="Open .h5", command=self.on_open).pack(side=tk.LEFT)
        self.file_lbl = ttk.Label(top, text="no file loaded")
        self.file_lbl.pack(side=tk.LEFT, padx=10)

        body = ttk.Frame(self)
        body.pack(fill=tk.BOTH, expand=True)

        # ---- left: image ---- #
        left = ttk.Frame(body)
        left.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        self.fig_img = Figure(figsize=(6, 5.6), layout="constrained")
        self.ax_img = self.fig_img.add_subplot(111)
        self.canvas_img = FigureCanvasTkAgg(self.fig_img, master=left)
        self.canvas_img.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        NavigationToolbar2Tk(self.canvas_img, left).update()
        self.im = None
        self.cbar = None

        ctr = ttk.Frame(left, padding=(6, 2))
        ctr.pack(fill=tk.X)

        ttk.Label(ctr, text="Show:").grid(row=0, column=0, sticky="w")
        self.qty = tk.StringVar(value="I")
        self._qty_buttons = {}
        for i, q in enumerate(QUANTITIES):
            b = ttk.Radiobutton(ctr, text=q, value=q, variable=self.qty,
                                command=self.on_quantity)
            b.grid(row=0, column=1 + i, sticky="w", padx=2)
            self._qty_buttons[q] = b
        self._qty_buttons["derived"].config(text=f"derived ({DEFAULT_FORMULA})")

        # ---- user-defined derived quantity ---- #
        fr = ttk.Frame(ctr)
        fr.grid(row=0, column=4, columnspan=4, sticky="ew", padx=(14, 0))
        ttk.Label(fr, text="derived =").pack(side=tk.LEFT)
        self.formula = tk.StringVar(value=DEFAULT_FORMULA)
        self.formula_box = ttk.Combobox(fr, textvariable=self.formula, width=18,
                                        values=FORMULA_PRESETS, exportselection=False)
        self.formula_box.pack(side=tk.LEFT, padx=3)
        self.formula_box.bind("<Return>", lambda _e: self.on_formula())
        self.formula_box.bind("<<ComboboxSelected>>", lambda _e: self.on_formula())
        ttk.Button(fr, text="Apply", width=6,
                   command=self.on_formula).pack(side=tk.LEFT)
        self.mask_small = tk.BooleanVar(value=True)
        ttk.Checkbutton(fr, text="mask |I|~0", variable=self.mask_small,
                        command=self.on_formula).pack(side=tk.LEFT, padx=(6, 0))

        ttk.Label(ctr, text="Draw:").grid(row=1, column=0, sticky="w", pady=(4, 0))
        self.mode = tk.StringVar(value="rect")
        for i, (val, txt) in enumerate((("rect", "rectangle"),
                                        ("point", "point"),
                                        ("free", "freehand"))):
            ttk.Radiobutton(ctr, text=txt, value=val, variable=self.mode,
                            command=self._sync_mode).grid(row=1, column=1 + i,
                                                          sticky="w", padx=2,
                                                          pady=(4, 0))
        ttk.Label(ctr, text="pt half-size:").grid(row=1, column=4, sticky="e",
                                                  padx=(10, 2), pady=(4, 0))
        self.pt_half = tk.IntVar(value=3)
        # exportselection is off on the list below; the spinbox must not steal
        # the selection either, or Delete has nothing to act on.
        ttk.Spinbox(ctr, from_=0, to=64, width=4, exportselection=False,
                    textvariable=self.pt_half).grid(row=1, column=5, sticky="w",
                                                    pady=(4, 0))

        ttk.Label(ctr, text="Sweep pt:").grid(row=2, column=0, sticky="w", pady=(6, 0))
        self.jvar = tk.IntVar(value=0)
        self.jscale = ttk.Scale(ctr, from_=0, to=0, orient=tk.HORIZONTAL,
                                command=self._on_slider)
        self.jscale.grid(row=2, column=1, columnspan=5, sticky="ew", pady=(6, 0))
        ctr.columnconfigure(3, weight=1)
        self.jlbl = ttk.Label(ctr, text="-")
        self.jlbl.grid(row=2, column=6, columnspan=2, sticky="w", padx=6, pady=(6, 0))

        self.robust = tk.BooleanVar(value=True)
        ttk.Checkbutton(ctr, text="robust colour scale (1-99%)",
                        variable=self.robust,
                        command=self.redraw_image).grid(row=3, column=0, columnspan=4,
                                                        sticky="w", pady=(4, 0))

        # ---- right: traces + ROI list ---- #
        right = ttk.Frame(body, width=560)
        right.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

        self.fig_tr = Figure(figsize=(6, 7), layout="constrained")
        self.axes_tr = self.fig_tr.subplots(3, 1, sharex=True)
        self.canvas_tr = FigureCanvasTkAgg(self.fig_tr, master=right)
        self.canvas_tr.get_tk_widget().pack(fill=tk.BOTH, expand=True)
        NavigationToolbar2Tk(self.canvas_tr, right).update()

        rl = ttk.Frame(right, padding=(6, 4))
        rl.pack(fill=tk.X)
        ttk.Label(rl, text="ROIs -- mean +/- std at current sweep pt "
                           "(Delete key / double-click / right-click on image "
                           "to remove):").pack(anchor="w")
        # exportselection=False: a Tk listbox otherwise gives up its selection
        # as soon as another widget claims it, so the highlighted row silently
        # stops being "selected" and Delete appears to do nothing.
        self.roi_list = tk.Listbox(rl, height=6, activestyle="none",
                                   selectmode=tk.EXTENDED, exportselection=False)
        self.roi_list.pack(fill=tk.X, pady=2)
        self.roi_list.bind("<<ListboxSelect>>", lambda _e: self._draw_patches(True))
        self.roi_list.bind("<Double-Button-1>", lambda _e: self.on_delete())
        for key in ("<Delete>", "<BackSpace>"):
            self.roi_list.bind(key, lambda _e: self.on_delete())
            self.bind(key, lambda _e: self.on_delete())

        btns = ttk.Frame(rl)
        btns.pack(fill=tk.X)
        ttk.Button(btns, text="Delete selected",
                   command=self.on_delete).pack(side=tk.LEFT)
        ttk.Button(btns, text="Clear all",
                   command=self.on_clear).pack(side=tk.LEFT, padx=4)
        ttk.Button(btns, text="Export traces CSV",
                   command=self.on_export).pack(side=tk.LEFT, padx=4)

        self.status = ttk.Label(self, text="Open a widefield .h5 to begin.",
                                relief=tk.SUNKEN, anchor="w", padding=(6, 2))
        self.status.pack(side=tk.BOTTOM, fill=tk.X)

        self.rect_sel = RectangleSelector(
            self.ax_img, self._on_rect, useblit=True, button=[1],
            minspanx=2, minspany=2, spancoords="pixels", interactive=False,
            props=dict(facecolor="none", edgecolor="yellow", linewidth=1.4),
        )
        self.lasso_sel = LassoSelector(
            self.ax_img, self._on_lasso, button=[1],
            props=dict(color="yellow", linewidth=1.4),
        )
        self._sync_mode()
        self.canvas_img.mpl_connect("button_press_event", self._on_click)

    # -- loading ----------------------------------------------------------- #
    def on_open(self):
        path = filedialog.askopenfilename(
            title="Open widefield .h5",
            initialdir=r"C:\Data",
            filetypes=[("HDF5", "*.h5"), ("All files", "*.*")],
        )
        if path:
            self.load(path)

    def load(self, path: str):
        try:
            run = WideRun(path)
        except Exception as exc:
            messagebox.showerror("Load failed", f"{path}\n\n{exc}")
            return

        self.run = run
        self.file_lbl.config(text=f"{os.path.basename(path)}   [{run.summary()}]")
        self.jscale.config(to=max(run.N - 1, 0))
        self.jvar.set(0)
        self.jscale.set(0)
        # Keep ROIs across loads so the same region can be compared between
        # runs; drop any whose frame size no longer matches.
        self.rois = [r for r in self.rois if r.fits(run.H, run.W)]
        for r in self.rois:
            r.patch = None
        self._reset_image_axes()
        self._qty_buttons["derived"].config(text=f"derived ({self._formula_ok})")
        self.redraw_image()
        self.redraw_traces()
        self.refresh_roi_list()
        self.status.config(text=f"Loaded {path}")

    # -- image ------------------------------------------------------------- #
    def _j(self) -> int:
        if self.run is None:
            return 0
        return int(max(0, min(self.jvar.get(), self.run.N - 1)))

    def _on_slider(self, _val):
        if self.run is None:
            return
        self.jvar.set(int(float(_val)))
        self.redraw_image()
        self.refresh_roi_list()
        self._draw_sweep_marker()

    def stack(self, quantity: str) -> np.ndarray:
        """Pixel stack for a quantity; 'derived' comes from the user formula."""
        if quantity == "I":
            return self.run.I
        if quantity == "Q":
            return self.run.Q
        return self.run.derived(self._formula_ok, self.mask_small.get())

    def qty_label(self, quantity: str) -> str:
        return self._formula_ok if quantity == "derived" else quantity

    def on_quantity(self):
        self.redraw_image()
        self.refresh_roi_list()

    def on_formula(self):
        """Validate the typed formula, then rebuild everything that uses it."""
        if self.run is None:
            self._formula_ok = self.formula.get().strip() or DEFAULT_FORMULA
            return
        expr = self.formula.get().strip()
        try:
            evaluate_formula(expr, self.run.I, self.run.Q, self.mask_small.get())
        except Exception as exc:
            # Keep showing the last good result rather than blanking the view.
            messagebox.showerror(
                "Bad formula",
                f"{expr!r}\n\n{type(exc).__name__}: {exc}\n\n"
                f"Use I and Q, e.g. {', '.join(FORMULA_PRESETS[:4])}")
            self.formula.set(self._formula_ok)
            return

        self._formula_ok = expr
        self._qty_buttons["derived"].config(text=f"derived ({expr})")
        # Looking at the derived panel is the common reason to edit a formula.
        if self.qty.get() != "derived":
            self.qty.set("derived")
        self.redraw_image()
        self.redraw_traces()
        self.refresh_roi_list()
        self.status.config(text=f"derived = {expr}")

    def _reset_image_axes(self):
        """Tear down the image AND its colorbar so the next redraw rebuilds both.

        A colorbar occupies a separate axes owned by the figure, so clearing
        the image axes alone leaves it behind; without removing it here each
        load would add another one.
        """
        if self.cbar is not None:
            try:
                self.cbar.remove()
            except Exception:
                pass            # already gone (figure cleared, axes removed)
            self.cbar = None
        self.im = None
        self.ax_img.clear()
        for r in self.rois:
            r.patch = None      # patches died with the axes

    def redraw_image(self):
        if self.run is None:
            return
        q = self.qty.get()
        j = self._j()
        img = self.stack(q)[:, :, j]

        if self.robust.get():
            lo, hi = np.nanpercentile(img, [1, 99])
            if not np.isfinite(lo) or not np.isfinite(hi) or lo == hi:
                lo, hi = np.nanmin(img), np.nanmax(img)
        else:
            lo, hi = np.nanmin(img), np.nanmax(img)

        if self.im is None:
            # Drop any leftover colorbar first: it lives in its own axes, which
            # ax.clear() does not touch, so recreating one per load stacks them
            # up and squeezes the image.
            self._reset_image_axes()
            self.im = self.ax_img.imshow(img, origin="upper", interpolation="nearest",
                                         cmap="magma", vmin=lo, vmax=hi)
            self.cbar = self.fig_img.colorbar(self.im, ax=self.ax_img)
            self.ax_img.set_xlabel("x (px)")
            self.ax_img.set_ylabel("y (px)")
            for r in self.rois:
                r.patch = None
        else:
            self.im.set_data(img)
            self.im.set_clim(lo, hi)

        unit = self.run.sweep_unit
        self.ax_img.set_title(
            f"{self.qty_label(q)}   sweep {j + 1}/{self.run.N} "
            f"= {self.run.sweep[j]:g} {unit}")
        self.jlbl.config(text=f"{j + 1}/{self.run.N}  ({self.run.sweep[j]:g} {unit})")

        self._draw_patches()
        self.canvas_img.draw_idle()

    def _draw_patches(self, redraw=False):
        """(Re)attach ROI outlines; selected ones are drawn heavier."""
        selected = self._selected_ids()
        for r in self.rois:
            if r.patch is None or r.patch.axes is None:
                r.patch = r.make_patch()
                self.ax_img.add_patch(r.patch)
            hot = r.id in selected
            r.patch.set_linewidth(3.0 if hot else 1.6)
            r.patch.set_linestyle("-" if hot else "--" if r.kind == "free" else "-")
        if redraw:
            self.canvas_img.draw_idle()

    # -- ROI creation ------------------------------------------------------ #
    def _next_color(self) -> str:
        c = ROI_COLORS[self._color_i % len(ROI_COLORS)]
        self._color_i += 1
        return c

    def _sync_mode(self):
        m = self.mode.get()
        self.rect_sel.set_active(m == "rect")
        self.lasso_sel.set_active(m == "free")

    def _on_rect(self, eclick, erelease):
        if self.run is None or self.mode.get() != "rect":
            return
        if None in (eclick.xdata, eclick.ydata, erelease.xdata, erelease.ydata):
            return
        c0, c1 = sorted((eclick.xdata, erelease.xdata))
        r0, r1 = sorted((eclick.ydata, erelease.ydata))
        self._add(Roi.from_box(round(r0), round(r1) + 1, round(c0), round(c1) + 1,
                               "rect", self._next_color(), self.run.H, self.run.W))

    def _on_lasso(self, verts):
        if self.run is None or self.mode.get() != "free":
            return
        if verts is None or len(verts) < 3:
            self.status.config(text="Freehand ROI needs at least 3 points.")
            return
        roi = Roi.from_verts(verts, self._next_color(), self.run.H, self.run.W)
        if roi is None:
            self.status.config(text="Freehand outline enclosed no pixels.")
            return
        self._add(roi)

    def _on_click(self, event):
        if self.run is None or event.inaxes is not self.ax_img:
            return
        if event.xdata is None or event.ydata is None:
            return
        c, r = int(round(event.xdata)), int(round(event.ydata))

        # Right-click deletes whatever ROI is under the cursor -- the most
        # direct route, no list selection involved.
        if event.button == 3:
            for roi in reversed(self.rois):
                if roi.contains(r, c):
                    self._remove([roi])
                    self.status.config(text=f"Deleted {roi.label}")
                    return
            self.status.config(text="Right-click landed outside every ROI.")
            return

        if event.button == 1 and self.mode.get() == "point":
            h = int(self.pt_half.get())
            self._add(Roi.from_box(r - h, r + h + 1, c - h, c + h + 1,
                                   "point", self._next_color(),
                                   self.run.H, self.run.W))

    def _add(self, roi: Roi):
        self.rois.append(roi)
        self._draw_patches(True)
        self.redraw_traces()
        self.refresh_roi_list()
        self.status.config(text=f"Added {roi.label}  ({roi.npix} px)")

    # -- ROI list / removal ------------------------------------------------ #
    def _selected_ids(self) -> set[int]:
        return {self.rois[i].id for i in self.roi_list.curselection()
                if i < len(self.rois)}

    def refresh_roi_list(self):
        sel = list(self.roi_list.curselection())
        self.roi_list.delete(0, tk.END)
        if self.run is None:
            return
        j = self._j()
        stack = self.stack(self.qty.get())
        for i, r in enumerate(self.rois):
            m, s = r.stats(stack, j)
            self.roi_list.insert(tk.END, f"{r.label}   {m:.6g} +/- {s:.3g}")
            self.roi_list.itemconfig(i, fg=r.color)
        for i in sel:
            if i < self.roi_list.size():
                self.roi_list.selection_set(i)

    def _remove(self, doomed: list[Roi]):
        for roi in doomed:
            if roi.patch is not None and roi.patch.axes is not None:
                roi.patch.remove()
            if roi in self.rois:
                self.rois.remove(roi)
        self.canvas_img.draw_idle()
        self.redraw_traces()
        self.refresh_roi_list()

    def on_delete(self):
        idx = self.roi_list.curselection()
        if not idx:
            self.status.config(
                text="Nothing selected -- click an ROI in the list first, "
                     "or right-click it on the image.")
            return
        doomed = [self.rois[i] for i in idx if i < len(self.rois)]
        self._remove(doomed)
        self.status.config(text=f"Deleted {len(doomed)} ROI(s)")

    def on_clear(self):
        self._remove(list(self.rois))
        self.status.config(text="Cleared all ROIs")

    # -- traces ------------------------------------------------------------ #
    def redraw_traces(self):
        for ax in self.axes_tr:
            ax.clear()
        if self.run is None:
            self.canvas_tr.draw_idle()
            return

        x = self.run.sweep
        style = dict(marker="o", markersize=4, linewidth=1.2)
        if self.run.N == 1:
            style = dict(marker="o", markersize=7, linestyle="none")

        for ax, q in zip(self.axes_tr, QUANTITIES):
            for r in self.rois:
                ax.plot(x, r.trace(self.stack(q)),
                        color=r.color, label=r.label, **style)
            ax.set_ylabel(self.qty_label(q), fontsize=9)
            ax.grid(alpha=0.3)

        self.axes_tr[-1].set_xlabel(f"sweep parameter ({self.run.sweep_unit})")
        if self.rois:
            self.axes_tr[0].legend(fontsize=7, ncol=2, loc="best")
        else:
            self.axes_tr[0].set_title(
                "drag a rectangle, click a point, or draw freehand on the image",
                fontsize=9)
        self._draw_sweep_marker()

    def _draw_sweep_marker(self):
        """Vertical line tying the trace panels to the displayed sweep point."""
        if self.run is None or self.run.N <= 1:
            self.canvas_tr.draw_idle()
            return
        xj = self.run.sweep[self._j()]
        for ax in self.axes_tr:
            for ln in list(getattr(ax, "_sweep_marker", [])):
                try:
                    ln.remove()
                except Exception:
                    pass
            ax._sweep_marker = [ax.axvline(xj, color="0.5", linestyle="--",
                                           linewidth=1, zorder=0)]
        self.canvas_tr.draw_idle()

    # -- export ------------------------------------------------------------ #
    def on_export(self):
        if self.run is None or not self.rois:
            messagebox.showinfo("Nothing to export", "Load a file and add an ROI.")
            return
        path = filedialog.asksaveasfilename(
            title="Export ROI traces",
            defaultextension=".csv",
            initialfile=os.path.splitext(os.path.basename(self.run.path))[0] + "_roi.csv",
            filetypes=[("CSV", "*.csv")],
        )
        if not path:
            return

        cols = [self.run.sweep]
        names = [f"sweep_{self.run.sweep_unit or 'idx'}"]
        for r in self.rois:
            for q in QUANTITIES:
                cols.append(r.trace(self.stack(q)))
                names.append(f"roi{r.id}_{q}")
        # Record the formula: 'derived' alone would not say what was computed.
        header = f"# derived = {self._formula_ok}\n" + ",".join(names)
        try:
            np.savetxt(path, np.column_stack(cols), delimiter=",",
                       header=header, comments="")
        except Exception as exc:
            messagebox.showerror("Export failed", str(exc))
            return
        self.status.config(text=f"Exported {len(self.rois)} ROI(s) to {path}")


def main():
    initial = sys.argv[1] if len(sys.argv) > 1 else None
    Viewer(initial).mainloop()


if __name__ == "__main__":
    main()
