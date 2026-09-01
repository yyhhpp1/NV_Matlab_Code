function hc_T1
% hc_T1  Widefield lock-in T1 for the HeliCam C4 (external DivideBy4).
%
% Exposure (Q1/Q4 quarter width) is fixed; the swept dark wait gmSEQ.m is
% carried by the Q2+Q3 gap, so the effective lock-in period grows with tau
% while the per-bin exposure stays constant. Quarter mapping:
%   Q1: init / reference laser (GreenAOM), optional pi pulse after init
%   Q2: dark (first half of the wait)
%   Q3: dark (second half of the wait)
%   Q4: readout / signal laser (GreenAOM)
% CamRef edges at [0, Q1, Q1+m/2, Q1+m]; period repeats gmSEQ.Repeat times.
% Sweep parameter gmSEQ.m = dark wait (ns).
%
% See docs/helicam_pulsed_measurement_notes.md (Example 2).

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
gmSEQ.WFcontrastExpr = 'I-Q';

r = gmSEQ.CtrGateDur;   % CamRef TTL width (ns)
i = gmSEQ.readout;           % init/readout laser duration (ns)
p = gmSEQ.pi;                % pi pulse duration (ns); 0 for plain S00 T1
m = gmSEQ.m;                 % swept dark wait (ns)
d = gmSEQ.post_init_wait;
u = gmSEQ.post_MW_wait;

Q = r+i+d+p+u+m;


% --- CamRef quarter-period train --------------------------------------------
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, Q*2, Q*3];
gmSEQ.CHN(1).DT    = r * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 3;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [r, r+(i+d+p+u+m), r+(i+d+p+u+m)+(r+i+d+p+u+m)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [i, r+i, r+i];

% --- Optional pi pulse in Q1, right after init ------------------------------
if p > 0
    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN = PBDictionary('MWSwitch');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T     = r+i+d+m;
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT    = p;

    gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN = PBDictionary('MWSwitchHP');
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T     = r+i+d+m-100;
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT    = p+200;
end

% --- Period length marker ---------------------------------------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, Q*4-1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyDelays();
