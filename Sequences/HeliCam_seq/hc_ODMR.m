function hc_ODMR
% hc_ODMR  Widefield lock-in pulsed ODMR for the HeliCam C4 (external DivideBy4).
%
% Identical quarter-bin layout to hc_Rabi, but the MW duration is FIXED at the
% pi pulse length; the swept quantity gmSEQ.m is the MW FREQUENCY (GHz), which
% the HeliCam RunSequence branch applies to the signal generator per point.
% Quarter mapping:
%   Q1: init / reference laser (GreenAOM)
%   Q2: pi pulse (fixed), dark otherwise
%   Q3: dark
%   Q4: readout / signal laser (GreenAOM)
% The whole period repeats gmSEQ.Repeat times (PB loop) per camera frame.

global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 0;
gSG.bMod = 'IQ';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Default axes2/axes3 quantity: I - Q, the difference the lock-in quarters were
% arranged to produce. Preserves what this sequence has always plotted, now as a
% declared default rather than a hardcoded branch in DisplayWidefield. Selecting
% this sequence seeds the 'WFcontrast' GUI box with this string; edit the box
% (even mid-run) to plot something else.
gmSEQ.WFcontrastExpr = 'I';

cfg = WidefieldConfig();
Q = hc_QuarterBin(cfg);      % quarter period (ns) = GUI QP field
e = gmSEQ.CtrGateDur;        % CamRef TTL width (ns); NOT clamped to Q/2
u = gmSEQ.post_MW_wait;
d = gmSEQ.post_init_wait;    % delay of MW start into Q2 (ns)
p = gmSEQ.pi;

%Laser on time will be derived from d,u,Q and MW length
i1 = 2*Q - d - p - u;
i2 = Q - d;
i3 = Q - e - 2*d;

assert(Q-e >= d+p+u, ...
    'hc_Rabi: Early laser off during exposure. Try shorter exposure or longer quarterperiod');

% --- CamRef quarter-period train: one edge at the start of each quarter -----
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = e * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 2*Q, 3*Q + e + d];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [i1, i2, i3];

% --- MW pulse inside Q2 (swept duration) ------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = i1 + d;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = p;

iq_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('SRS1_I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = i1 + d - iq_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = p + 2*iq_time;

hp_MW_switch_time = 20;
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('MWSwitchHP');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = i1 + d - hp_MW_switch_time;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = p + hp_MW_switch_time;


% --- Period length marker (4 quarter bins) ----------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();

