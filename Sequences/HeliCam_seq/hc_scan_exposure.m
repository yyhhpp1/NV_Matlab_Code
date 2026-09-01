function hc_scan_exposure
% hc_scan_exposure  Widefield lock-in exposure scan for the HeliCam C4.
%
% Same 4-quarter lock-in structure as hc_Rabi_matched_ref -- PB emits a CamRef
% edge at every quarter boundary (-> HeliCam FI2), Q1 is the reference laser and
% Q4 the readout laser, and the whole period repeats gmSEQ.Repeat times per
% camera frame. Two things are swapped:
%
%   MW on-time  : FIXED at gmSEQ.pi (the GUI pi box), not swept.
%   Sweep param : gmSEQ.m = the ctr gate, i.e. the CamRef TTL width e (ns).
%
% The ctr gate is the camera's exposure source: RunSequence turns it into the
% integration time as expo = CtrGateDur - sensorOverheadNs (RunSequence.m, the
% ConfigureExposure local function), so sweeping it sweeps exposure linearly.
%
% THIS SEQUENCE IS NAMED IN RunSequence. The camera's exposure register is
% normally written once, before the sweep, so widening the CamRef pulse alone
% would change the trigger width and nothing else -- the scan would come out
% flat. RunSequence therefore recognises 'hc_scan_exposure' by name and, at every
% sweep point, reconfigures the camera from gmSEQ.CtrGateDur (set below) and
% takes a fresh dark reference to match. Renaming this file means renaming it
% there too.
%
% Display quantity: -I./Q .* sqrt(abs(Q)) -- the lock-in contrast times the
% square root of the collected charge, i.e. an SNR figure. It rises as
% sqrt(exposure) while shot-noise-limited and rolls over once background and
% dark current take over; the knee is the exposure this measurement exists to
% find.

global gmSEQ gSG
gSG.bfixedPow = 1;
% bfixedFreq = 1 is REQUIRED, not cosmetic: RunSequence multiplies the whole
% sweep vector by 1e9 when it is 0 (a GHz -> Hz rescale for hc_ODMR), which would
% turn a ns gate sweep into seconds.
gSG.bfixedFreq = 1;
gSG.bMod = 'IQ';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Default axes2/axes3 quantity. abs() inside the sqrt because Q goes negative
% wherever the lock-in phase is wrong (shadow, unlit pixels) and a complex image
% is not plottable; RunSequence prints a per-point warning with the count of such
% pixels so they are never mistaken for signal. Selecting this sequence seeds the
% 'WFcontrast' GUI box with this string; edit the box (even mid-run) to plot
% something else.
gmSEQ.WFcontrastExpr = '(Q+I)./Q.*sqrt(abs(I))';  % (sig - ref) / ref * sqrt(sig)

% A stale dark is worse here than anywhere else: the pedestal accumulates during
% the exposure, and the exposure is the swept quantity, so a single stored dark
% is correct at exactly one point of the sweep. Declaring this ticks the GUI
% takeDarkRef box, which is what enables the per-point dark capture.
gmSEQ.WFneedsDarkRef = true;

cfg = WidefieldConfig();
Q = hc_QuarterBin(cfg);      % quarter period (ns) = GUI QP field
e = gmSEQ.m;                 % SWEPT: ctr gate = CamRef TTL width (ns)
u = gmSEQ.post_MW_wait;
d = gmSEQ.post_init_wait;    % delay of MW start into Q2 (ns)
m = gmSEQ.pi;                % FIXED: MW on-time from the GUI pi box

% Keep the exposure source in step with the swept gate. RunSequence reads this
% field -- not gmSEQ.m -- when it reconfigures the camera for this point, so the
% PB pulse width and the integration time can never drift apart.
gmSEQ.CtrGateDur = e;

s = 400;                     % AOM edge guard, used below and in the sweep guard

%Laser on time will be derived from d,u,Q and MW length
i1 = Q - d - m - u;
i2 = Q - e - d - m - u;

% --- Whole-sweep guard ------------------------------------------------------
% Checked over the entire sweep vector, not just this point's e, so a bad From/To
% is rejected before the first acquisition rather than N/2 points in. The isfield
% fallback is required: LoadSEQ calls SequencePool twice to draw the axes1
% preview, potentially before SweepParam exists.
if isfield(gmSEQ, 'SweepParam') && ~isempty(gmSEQ.SweepParam)
    eAll = gmSEQ.SweepParam(:).';
else
    eAll = e;   % DrawSequence preview before the sweep vector exists
end

assert(min(eAll) >= 12, ...
    ['hc_scan_exposure: sweep reaches e = %g ns, below the 12 ns PulseBlaster ' ...
     'minimum instruction length. Raise the From value.'], min(eAll));

% The binding upper limit. It subsumes e < Q: a gate that reaches the next
% quarter boundary merges the four CamRef pulses into ONE, so the camera sees 1
% rising edge per period instead of 4 and readIQ simply times out (see
% hc_CamRefWidth.m). Subtracting 2*s on top keeps i2 - 2*s positive, i.e. no
% GreenAOM width goes negative at the top of the sweep.
eMax = Q - d - m - u - 2*s;
assert(max(eAll) <= eMax, ...
    ['hc_scan_exposure: sweep reaches e = %g ns but the gate must stay under ' ...
     '%g ns (= Q %g - post_init_wait %g - pi %g - post_MW_wait %g - 2*%g AOM ' ...
     'guard). A gate that long swallows the next quarter boundary, leaving 1 ' ...
     'CamRef edge per period instead of 4 -- the camera then never completes a ' ...
     'frame and readIQ times out. Cap the sweep, or raise the QP box.'], ...
    max(eAll), eMax, Q, d, m, u, s);

assert(Q-e >= d+m+u, ...
    'hc_scan_exposure: Early laser off during exposure. Try shorter exposure or longer quarterperiod');

% --- CamRef quarter-period train: one edge at the start of each quarter -----
% The EDGES stay at [0, Q, 2Q, 3Q] for every point -- only the widths sweep. That
% is deliberate: the external reference frequency the camera locks to must not
% track the swept parameter, or the exposure change and a period change would be
% inseparable in the result.
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = e * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [e + s, Q, 2*Q, 3*Q + e + s];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [i2 - s, i1, i1 - s, i2 - 2*s];

% --- MW pulse inside Q2 (FIXED at pi) ---------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - m;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = m;

iq_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('SRS1_I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - m - iq_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = m + 2*iq_time;

hp_MW_switch_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitchHP');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - m - hp_MW_switch_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = m + 2 * hp_MW_switch_time;


% --- Period length marker (4 quarter bins) ----------------------------------
% Constant 4*Q span at every point. The lock-in period must not track the sweep,
% for the same reason the CamRef edges do not.
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q-s];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [s, s];

ApplyNoDelays();
