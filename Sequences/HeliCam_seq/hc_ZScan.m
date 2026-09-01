function hc_ZScan
% hc_ZScan  Widefield autofocus: hc_Image repeated over a range of objective Z,
% scored for sharpness, with the objective parked at the best-focus position.
%
% The PB program is exactly hc_Image's -- laser in one quarter, CamRef quarter
% train, no MW -- because the swept quantity is the objective position, not any
% pulse timing. hc_Image is called rather than copied so that any change to the
% imaging pulse sequence applies here too.
%
% The sweep axis (From / To / N on the GUI) is objective Z in micrometres, and
% RunSequence_HeliCam writes each point to the Obj_Piezo analog output before
% acquiring, clamped to the safe range in WidefieldConfig (zMinUm/zMaxUm -- an
% out-of-range sweep is refused before anything moves, not clamped).
%
% HOW FOCUS IS SCORED
%
% Each Z's intensity image is scored with a normalised Tenengrad metric --
% mean(gx^2 + gy^2) / mean(|I|)^2 over the valid pixels, gradients from a Sobel
% on a mildly smoothed frame (hc_FocusMetric). Defocus is a low-pass filter, so a
% gradient metric measures exactly what defocus destroys; the division by
% mean(|I|)^2 stops the curve from tracking laser power instead of sharpness.
% axes3 shows that score vs Z live; axes2 shows the image with the scored region
% outlined in cyan.
%
% THE STRIPLINE, AND WHY THE MASK MATTERS
%
% A stripline sits ~50 um above the diamond and casts a dark shadow across the
% field. Its shadow is excluded from the score (hc_FocusMask): pixels below
% focusDarkFrac of the frame's own bright level at ANY Z in the stack are
% dropped, along with hot pixels, and the surviving region is then ERODED by
% focusErodePx.
%
% The erosion is the part that actually matters. The shadow's EDGE is the
% sharpest feature in the whole frame, and it belongs to a plane 50 um above the
% NV layer -- so a gradient score that can still see it peaks when the STRIPLINE
% is in focus, parking the objective ~50 um away from the NVs. Dropping the dark
% pixels alone does not help, because the edge lives at the boundary of the dark
% region. Set focusDarkFrac = 0 for one run to see how far the answer moves; that
% shift is what the mask is buying.
%
% Because the penumbra widens and shifts as the shadow blurs with Z, the mask
% takes the UNION of the shadows across the stack, not their intersection, so the
% same pixel set is scored at every Z and the scores stay comparable.
%
% Selecting hc_ZScan ticks the takeDarkRef checkbox for you: this file sets
% gmSEQ.WFneedsDarkRef at the bottom and LoadSEQ acts on that declaration. It is
% not cosmetic: the mask thresholds |I|, and on the raw scale the ~517 per-pixel
% pedestal dwarfs the light, so without the dark subtraction |I| is nearly
% uniform and the shadow cannot be found at all.
%
% WHERE THE OBJECTIVE ENDS UP
%
% If the score curve has a genuine INTERIOR maximum, the run parks the objective
% at the parabolically interpolated best Z and updates gScan.FixVz, then redraws
% axes2 with the image at that Z. If instead the peak sits on the first or last
% scanned point, focus is outside the range that was scanned -- the run restores
% the starting Z and says which way to extend From/To rather than moving to a
% position it only knows is "the closest we got". A flat curve (low confidence)
% is likewise reported and not acted on. Set focusGoToBest = false in
% WidefieldConfig to always restore instead.
%
% Results are saved to the usual .h5 alongside the image stack: /focus_score,
% every alternative metric under /focus_metrics/, the /focus_mask itself, and
% focus_best_z_um / focus_confidence / focus_peak_interior as root attributes.
% Run hc_FocusCompare on that file to check the metric choice against the
% alternatives offline, or open it in analysis/wf_viewer.py to browse the stack.
%
% Requires ImageNVC -> Start to have been pressed once this session: that is what
% loads EO-Drive.dll and sets eohandle. RunSequence refuses to start the scan
% otherwise, because without them every Z move fails silently and the stack comes
% out as N identical frames -- indistinguishable from a genuinely flat focus curve.

global gmSEQ

% Identical acquisition to hc_Image (also sets the gSG flags and CHN entries).
hc_Image();

% hc_Image derived the sweep scaling from GetScale(gmSEQ.To), which assumes a
% time axis. Here the axis is Z in um, so label it directly. ScaleT must stay 1:
% the best-focus Z read off this axis is commanded straight to the objective.
gmSEQ.ScaleT   = 1;
gmSEQ.ScaleStr = 'Z (\mum)';

% This sequence cannot score focus without a dark reference (see the header), so
% declare that here and let LoadSEQ tick the takeDarkRef box. Declaring it in the
% sequence file rather than naming hc_ZScan in ExperimentFunctionPool keeps the
% shared code free of per-sequence special cases -- same pattern as
% WFcontrastExpr, which hc_Image set above.
gmSEQ.WFneedsDarkRef = true;
end
