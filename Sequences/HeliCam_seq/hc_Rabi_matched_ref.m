function hc_Rabi_matched_ref
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

%Laser on time will be derived from d,u,Q and MW length
i1 = Q - d - m - u;
i2 = Q - e - d - m - u;

assert(Q-e >= d+m+u, ...
    'hc_Rabi: Early laser off during exposure. Try shorter exposure or longer quarterperiod');

% --- CamRef quarter-period train: one edge at the start of each quarter -----
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = e * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
s = 400;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [e + s, Q, 2*Q, 3*Q + e + s];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [i2 - s, i1, i1 - s, i2 - 2*s];

% --- MW pulse inside Q2 (swept duration) ------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - gmSEQ.m;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = m;

iq_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('SRS1_I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - gmSEQ.m - iq_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = m + 2*iq_time;

hp_MW_switch_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitchHP');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = 2*Q - u - gmSEQ.m - hp_MW_switch_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = m + 2 * hp_MW_switch_time;


% --- Period length marker (4 quarter bins) ----------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q-s];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [s, s];

ApplyNoDelays();
