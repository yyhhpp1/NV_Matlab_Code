function hc_Scan_init_time

global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'IQ';        % IQ modulation ON (SRS1_I is gated below)
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Default axes2/axes3 quantity: I - Q, the difference the lock-in quarters were
% arranged to produce. Preserves what this sequence has always plotted, now as a
% declared default rather than a hardcoded branch in DisplayWidefield. Selecting
% this sequence seeds the 'WFcontrast' GUI box with this string; edit the box
% (even mid-run) to plot something else.
gmSEQ.WFcontrastExpr = 'Q';

cfg = WidefieldConfig();
%Q = hc_QuarterBin(cfg);      % quarter period (ns) = GUI QP field
% CamRef TTL width: CtrGateDur as intended, but passed through hc_CamRefWidth so
% it cannot exceed Q/2. The width is yours to choose anywhere below that; above
% it the arithmetic breaks regardless of intent. The four pulses sit at 0, Q, 2Q,
% 3Q, so a width of Q leaves the line high across the boundary -- no falling edge,
% therefore no rising edge -- and PB emits 1 rising edge per period instead of 4.
% That is what timed this sequence out: CtrGateDur was 50 us with Q = 50 us, so
% the camera waited for 4*20*10 = 800 edges and got 200. Note CtrGateDur is also
% the camera exposure source (RunSequence_HeliCam), so a full-quarter exposure and
% a legal reference width cannot both come from it; use cfg.camRefWidthNs if you
% need them decoupled. hc_CamRefWidth prints a warning whenever it clamps.
e = gmSEQ.CtrGateDur;
u = gmSEQ.post_MW_wait;
d = gmSEQ.post_init_wait;    % delay of MW start into Q2 (ns)
p = gmSEQ.halfpi;
m = gmSEQ.m;
Q = e + gmSEQ.readout + d + p + u + m;

%Laser on time will be derived from d,u,Q and MW length
i1 = 2*Q - (d+p+u+m);
i2 = m + Q + Q;

% i1 is a DERIVED pulse width, so it silently goes negative once the swept m
% grows past the room left in three quarters -- and a negative width is not a
% short pulse, it is a corrupt PB program. Fail loudly at the offending sweep
% point instead.
assert(i1 > 0, ['hc_Scan_init_time: init laser length came out %g ns (must be > 0). ', ...
                'post_init_wait + halfpi + post_MW_wait + m = %g ns exceeds 3*Q = %g ns. ', ...
                'Shorten the sweep range or raise QP.'], i1, d+p+u+m, 3*Q);

% --- CamRef quarter-period train: one edge at the start of each quarter -----
gmSEQ.CHN(1).PBN   = PBDictionary('CamRef');
gmSEQ.CHN(1).NRise = 4;
gmSEQ.CHN(1).T     = [0, Q, 2*Q, 3*Q];
gmSEQ.CHN(1).DT    = e * ones(1, 4);

% --- Laser: Q1 (init/reference) and Q4 (readout/signal) ---------------------
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN   = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise   = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 2*Q-m];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [i1, i2];

% --- MW pulse in the dark gap between the two laser pulses ------------------
% Fixed duration (halfpi); m sweeps WHERE this sits, not how long it is. Which
% quarter it lands in therefore moves with m -- worth watching on axes1.
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
gmSEQ.CHN(numel(gmSEQ.CHN)).T       = [0, 4*Q-1000];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT      = [1000, 1000];

ApplyNoDelays();
