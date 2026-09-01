function hc_scan_AOM_delay
% hc_Rabi  Widefield lock-in Rabi for the HeliCam C4 (external DivideBy4).
%
% One lock-in period = 4 quarter bins of width Q (ns). PB emits a CamRef edge
% at every quarter boundary (-> HeliCam FI2). Quarter mapping:
%   Q1: ref laser on
%   Q3: readout laser
% The whole period repeats gmSEQ.Repeat times (PB loop) per camera frame.
% Sweep parameter gmSEQ.m = MW on-time (ns); must fit inside one quarter bin.


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

cfg = WidefieldConfig();
Q = hc_QuarterBin(cfg);      % quarter period (ns) = GUI QP field
e = gmSEQ.CtrGateDur;        % CamRef TTL width (ns); NOT clamped to Q/2
u = gmSEQ.post_MW_wait;
d = gmSEQ.post_init_wait;    % delay of MW start into Q2 (ns)
m = gmSEQ.m;

% --- The shift must not push the first laser rise before t = 0 ---------------
% The laser train starts at e - m (see the GreenAOM T below). Once m > e that
% is negative, and PreprocessPBSequence shifts the WHOLE program so the
% earliest event lands on zero (PBFunctionPool.m:87). The shift is common to
% every channel, so the laser/CamRef relationship survives -- but the program
% span becomes 4Q + 1000 + (m - e) instead of a constant, i.e. the lock-in
% period grows with the very parameter being swept. The laser and the frame
% boundary then move together and the delay this sequence exists to measure is
% no longer separable from the sweep. Fail loudly instead.
%
% Checked over the entire sweep vector, not just this point's m, so a bad
% From/To is rejected before the first acquisition rather than N/2 points in.
% Units match: gmSEQ.m is assigned straight from SweepParam (RunSequence.m:1034)
% and this sequence pins gSG.bfixedFreq = 1, so no GHz -> Hz rescale applies.
if isfield(gmSEQ, 'SweepParam') && ~isempty(gmSEQ.SweepParam)
    mAll = gmSEQ.SweepParam(:).';
else
    mAll = m;   % DrawSequence preview before the sweep vector exists
end
assert(max(mAll) <= e, ...
    ['hc_scan_AOM_delay: sweep reaches m = %g ns but the CamRef width is only ' ...
     'e = %g ns. Any m > e starts the laser before t = 0, which stretches the ' ...
     'PB program by (m - e) and makes the lock-in period track the sweep. ' ...
     'Cap the sweep at %g ns, or raise CtrGateDur to at least %g ns.'], ...
    max(mAll), e, e, max(mAll));
assert(min(mAll) >= 0, ...
    ['hc_scan_AOM_delay: sweep reaches m = %g ns. A negative shift moves the ' ...
     'laser later, which this sequence''s Q4 window has no room for.'], min(mAll));

%Laser on time will be derived from d,u,Q and MW length
i1 = Q - d - u;
i2 = Q - e - d - u;

assert(Q-e >= d+u, ...
    'hc_Rabi: Early laser off during exposure. Try shorter exposure or longer quarterperiod');

% --- CamRef quarter-period train: one edge at the start of each quarter -----
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q] + Q/2;
gmSEQ.CHN(1).DT    = e * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 5;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [e, Q, 2*Q, 3*Q + e] - m;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, e + Q/2 + m, Q + Q/2 + m, 2*Q + Q/2 + m, 3*Q + e + Q/2 + m];

gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [Q/2 + m, i2, i1, i1, i2 - Q/2 - m];


% --- Period length marker (4 quarter bins) ----------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

% This sequence MEASURES the green AOM delay, so it must not pre-compensate for
% it: the sweep parameter m is the shift under test. ApplyNoDelays zeroes every
% channel's Delays, which both keeps the measurement honest and creates the
% .Delays field that RunSequence and PBFunctionPool require.
ApplyNoDelays();
