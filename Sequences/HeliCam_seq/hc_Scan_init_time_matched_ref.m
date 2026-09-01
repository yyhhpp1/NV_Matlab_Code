function hc_Scan_init_time_matched_ref
% hc_Scan_init_time_matched_ref  Widefield lock-in init-time scan for the
% HeliCam C4 (external DivideBy4), matched-reference layout.
%
% Same geometry as hc_Rabi_matched_ref: one lock-in period = 4 quarter bins of
% width Q (ns), a CamRef edge at every quarter boundary (-> HeliCam FI2), laser
% on in ALL FOUR quarters so every bin sees comparable illumination, and a single
% MW pulse in the tail of Q2. The whole period repeats gmSEQ.Repeat times (PB
% loop) per camera frame.
%
% What differs is which side of that arrangement is swept. In hc_Rabi_matched_ref
% the quarter period is given (GUI QP box) and the laser window is the DERIVED
% quantity, i1 = Q - d - m - u, shrinking as the swept MW time m grows. Here it is
% the other way round:
%
%   sweep parameter gmSEQ.m = laser (init) ON-TIME in ns
%   MW pulse duration       = gmSEQ.pi, fixed
%   quarter period          Q = m + d + p + u, DERIVED
%
% Because the laser fills the quarter in this layout, lengthening it necessarily
% lengthens the quarter -- so the lock-in period grows with the sweep and the GUI
% QP box is not read at all. hc_T1 already works this way (hc_T1.m: Q built from
% its own pulse timings), so this is not a new pattern for the run loop: the PB
% program is rebuilt at every sweep point and hc_AcqTimeoutMs sizes the readIQ
% timeout from the real program length.
%
% ONE CONSEQUENCE WORTH KNOWING. The camera's exposure register is written ONCE
% before the sweep, from gmSEQ.CtrGateDur (RunSequence_HeliCam), and the
% "[Widefield] Quarter bin = ... slack = ..." line printed alongside it comes from
% hc_QuarterBin, i.e. the QP box. Neither describes this sequence: the real
% quarter bin is the Q above and it changes at every point. Those numbers are
% diagnostics only -- the camera locks to the edges PB actually delivers -- but do
% not read the printed slack as if it applied here. The same caveat has always
% applied to hc_T1. The asserts below are what actually protect the run.
%
% Substituting Q = m + d + p + u leaves every expression borrowed from
% hc_Rabi_matched_ref literally unchanged:
%   i1 = Q - d - p - u      == m       (Q2/Q3 laser on-time = the swept value)
%   i2 = Q - e - d - p - u  == m - e   (Q1/Q4, which start after the CamRef pulse)

global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'IQ';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Default axes2/axes3 quantity: I - Q, the difference the lock-in quarters were
% arranged to produce. Preserves what this sequence has always plotted, now as a
% declared default rather than a hardcoded branch in DisplayWidefield. Selecting
% this sequence seeds the 'WFcontrast' GUI box with this string; edit the box
% (even mid-run) to plot something else.
gmSEQ.WFcontrastExpr = '-I./Q';

e = gmSEQ.CtrGateDur;        % CamRef TTL width (ns); NOT clamped to Q/2
u = gmSEQ.post_MW_wait;
d = gmSEQ.post_init_wait;    % dark gap between laser off and MW start (ns)
p = gmSEQ.pi;                % MW pulse duration (ns); fixed, not swept
m = gmSEQ.m;                 % swept laser (init) on-time (ns)

% The quarter period is derived from the sweep point, not read from the QP box.
Q = m + d + p + u;

i1 = Q - d - p - u;
i2 = Q - e - d - p - u;

% s is the margin carried on the Q1/Q4 laser edges (see the GreenAOM block). The
% shortest programmed laser window is i2 - 2*s, and it is a DERIVED width, so it
% shrinks with the sweep without anything else complaining -- at m = e + 2*s it
% reaches zero and below that it goes NEGATIVE, which is not a short pulse but a
% corrupt PB program. Fail at the offending sweep point instead. This binds
% before, and therefore subsumes, the Q-e >= d+m+u check hc_Rabi_matched_ref
% carries.
%
% The floor is PBminNs, not zero. Between m = e+2*s and m = e+2*s+12 the
% arithmetic is perfectly valid and the window is still shorter than the
% PulseBlaster can emit: PreprocessPBSequence only warns there
% (PBFunctionPool.m, "commands less than 12 ns in length"), and a warning at
% sweep point 3 of 40 scrolls past while the run continues to acquire points
% whose laser pulse the hardware never actually produced. Those points are not
% noisy, they are wrong, and nothing downstream marks them. Refuse instead.
s      = 400;
PBminNs = 12;                % PulseBlaster minimum instruction length
assert(i2 - 2*s >= PBminNs, ...
    ['hc_Scan_init_time_matched_ref: shortest laser window came out %g ns ', ...
     '(must be >= %g ns, the PulseBlaster minimum instruction length). The swept ', ...
     'init time m = %g ns has to be at least CtrGateDur (%g ns) + 2*%g ns + %g ns ', ...
     '= %g ns. Raise the sweep''s From, or lower CtrGateDur.'], ...
    i2 - 2*s, PBminNs, m, e, s, PBminNs, e + 2*s + PBminNs);

% Q shrinks with the sweep, so a CamRef width that sat comfortably under Q/2 at
% the QP-box quarter bin can cross it here. Above Q/2 the four pulses at 0, Q, 2Q,
% 3Q run together: no falling edge between them means no rising edge either, PB
% emits 1 rising edge per period instead of 4, and readIQ times out with "no data
% available" while the pulse diagram on axes1 looks perfectly reasonable -- the
% edges are where they should be, it is the gaps that are missing. See
% hc_CamRefWidth for the full account.
%
% Asserted rather than clamped on purpose: e is ALSO the camera exposure source
% (RunSequence_HeliCam), so quietly shortening it here would quietly change the
% integration time the run reports.
assert(e <= Q/2, ...
    ['hc_Scan_init_time_matched_ref: CamRef width %g ns exceeds half the quarter ', ...
     'bin (Q/2 = %g ns) at sweep point m = %g ns. The four reference pulses would ', ...
     'merge into one, leaving PB emitting 1 rising edge per period instead of 4 ', ...
     'and starving the camera. Lower CtrGateDur below %g ns, or raise the sweep''s ', ...
     'From (Q = m + %g ns).'], e, Q/2, m, Q/2, d + p + u);

% --- CamRef quarter-period train: one edge at the start of each quarter -----
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = e * ones(1, 4);

% --- Laser: on in every quarter, MW only in Q2 ------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [e + s, Q, 2*Q, 3*Q + e + s];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [i2 - s, i1, i1 - s, i2 - 2*s];

% --- MW pulse inside Q2 (fixed duration) ------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - p;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = p;

iq_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('SRS1_I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - p - iq_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = p + 2*iq_time;

hp_MW_switch_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitchHP');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - p - hp_MW_switch_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = p + 2 * hp_MW_switch_time;


% --- Period length marker (4 quarter bins) ----------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q-s];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [s, s];

ApplyNoDelays();
