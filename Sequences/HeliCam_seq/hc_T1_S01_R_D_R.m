function hc_T1_S01_R_D_R

% Each exposure
% Q1: S00
% Q2: Ref
% Q3: Dark
% Q4: Ref

global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';        % no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Default axes2/axes3 quantity: I - Q, the difference the lock-in quarters were
% arranged to produce. Preserves what this sequence has always plotted, now as a
% declared default rather than a hardcoded branch in DisplayWidefield. Selecting
% this sequence seeds the 'WFcontrast' GUI box with this string; edit the box
% (even mid-run) to plot something else.
gmSEQ.WFcontrastExpr = 'I';

r = gmSEQ.CtrGateDur;        % exposure
i = gmSEQ.readout;           % init tome (ns)
p = gmSEQ.pi;                % pi pulse duration (ns); 0 for plain S00 T1
m = gmSEQ.m;                 % swept dark wait (ns)
d = gmSEQ.post_init_wait;
u = gmSEQ.post_MW_wait;
q = 50; %buffer for iq and hp switch

Q = i + d + m + p + u;


% --- CamRef quarter-period train --------------------------------------------
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, Q*2, Q*3];
gmSEQ.CHN(1).DT    = r * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 2*Q+r+d];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [2*Q-d, Q-r-d+i];

% --- Pi pulse for S01 ------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T     = 4*Q-p-u;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT    = p;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN = PBDictionary('SRS1_I');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T     = 4*Q-p-u-q;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT    = p+2*q;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN = PBDictionary('MWSwitchHP');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T     = 4*Q-p-u-q;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT    = p+2*q;

% --- Period length marker ---------------------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, Q*4-1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();
