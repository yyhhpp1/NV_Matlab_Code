function f_Cooling_v1
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';%set to no modulation
gSG.bModSrc = 'External';
[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);
gmSEQ.plotting = 'Coooling';


N_c = 1000;
N_0 = 20;
N_p = 100; 
g1 = 512;
g2 = 512;
gY = 512;
f = 2000; 

% All time are in clock cycle
a = 0;
u = 1000;
r = 1000;
tw = 0;
l0 = 10000;
l1 = 10000;
l2 = 10000;
l3 = 10000;
d0 = 1000;
d1 = 1000;
d2 = 1000;
d3 = 1000;
h = 2;
t1 = 8;
t2 = 6;

%Time for one cooling cycle
tc = l1 + d1 + h + a + N_c * (t1 + t2) + a + h + u;
%Time for all cooling cycle
Tc = tc * N_0;
%Time for one probing cycle
Tp = l2 + d2 + h + a + N_p * (t1 + t2) + a + h + u + l3;
%Time for one experiment
Tm = d3 + l0 + d0 + Tc + tw + Tp;

%There will be 4 experiments in total corresponds for cooling,
%cooling_diff, heating, heating_diff

%Start time for init pulse for experiment 1: cooling
T1 = Tm * 0 + d3;
%Start time for init pulse for experiment 2: cooling_diff
T2 = Tm * 1 + d3;
%Start time for init pulse for experiment 3: heating
T3 = Tm * 2 + d3;
%Start time for init pulse for experiment 4: heating_diff
T4 = Tm * 3 + d3;

% Laser on time for one of the experiments
T_laser_in_N0 = (0:N_0-1) * Tc + l0 + d0; %[l0+d0, Tc+l0+d0, ...(N_0-1)Tc+l0+d0]
T_laser_one_expt = [...
    0 ...
    T_laser_in_N0 ...
    l0+d0+Tc*N_0+tw ...
    l0+d0+Tc*N_0+tw+Tp-l3 ...
    ];
% Laser one time for all the experiments
T_laser = [...
    T1+T_laser_one_expt ...
    T2+T_laser_one_expt ...
    T3+T_laser_one_expt ...
    T4+T_laser_one_expt ...
    ];

% Reference readout at the end of l0 laser and signal readout at the
% start of l3 laser
T_readout = repmat([d3+l0-r, Tm-l3], 1, 4) + [0, 0, Tm, Tm, 2*Tm, 2*Tm, 3*Tm, 3*Tm];


% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 8;
gmSEQ.CHN(1).T = T_readout;
gmSEQ.CHN(1).DT = repmat(r,1,8);

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 4 * (1 + N_0 + 2);
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_laser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = repmat([l0 repmat(l1, 1, N_c) [l2, l3]], 1, 4);


gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = d3;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = Tm*4-d3;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('FPGATrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = d3;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, Tm*4-100];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [100, 100];

% FPGA sequence

uploadSimplePulse('X1', f, g1, t1, 0)   %t1 pulse
uploadSimplePulse('X2', f, g2, t2, 180) %t2 pulse
uploadSimplePulse('Y1', f, gY, h, 90)   %+yhalf
uploadSimplePulse('Y2', f, gY, h, 270)  %-yhalf

% seq1 = [...
%      'l0+d0, loop(N_0, [ l1+d1, Y1, a, loop(N_c, [X1, X2]), a, Y2, u]), tw+l2+d2, Y1, a, loop(N_t, [X1, X2]), a, Y2, u+l3,' ...
%      'l0+d0, loop(N_0, [ l1+d1, Y1, a, loop(N_c, [X1, X2]), a, Y2, u]), tw+l2+d2, Y1, a, loop(N_t, [X1, X2]), a, Y1, u+l3,' ...
%      'l0+d0, loop(N_0, [ l1+d1, Y1, a, loop(N_c, [X1, X2]), a, Y2, u]), tw+l2+d2, Y2, a, loop(N_t, [X1, X2]), a, Y1, u+l3,' ...
%      'l0+d0, loop(N_0, [ l1+d1, Y1, a, loop(N_c, [X1, X2]), a, Y2, u]), tw+l2+d2, Y2, a, loop(N_t, [X1, X2]), a, Y2, u+l3,' ...
%      ];

Expt1 = sprintf('%d+%d, loop(%d, [ %d+%d, Y1, %d, loop(%d, [X1, X2]), %d, Y2, %d]), %d+%d+%d, Y1, %d, loop(%d, [X1, X2]), %d, Y2, %d+%d', ...
    l0, d0, N_0, l1, d1, a, N_c, a, u, tw, l3, d3, a, N_p, a, u, l3);
Expt2 = sprintf('%d+%d, loop(%d, [ %d+%d, Y1, %d, loop(%d, [X1, X2]), %d, Y2, %d]), %d+%d+%d, Y1, %d, loop(%d, [X1, X2]), %d, Y1, %d+%d', ...
    l0, d0, N_0, l1, d1, a, N_c, a, u, tw, l3, d3, a, N_p, a, u, l3);
Expt3 = sprintf('%d+%d, loop(%d, [ %d+%d, Y1, %d, loop(%d, [X1, X2]), %d, Y2, %d]), %d+%d+%d, Y2, %d, loop(%d, [X1, X2]), %d, Y1, %d+%d', ...
    l0, d0, N_0, l1, d1, a, N_c, a, u, tw, l3, d3, a, N_p, a, u, l3);
Expt4 = sprintf('%d+%d, loop(%d, [ %d+%d, Y1, %d, loop(%d, [X1, X2]), %d, Y2, %d]), %d+%d+%d, Y2, %d, loop(%d, [X1, X2]), %d, Y2, %d+%d', ...
    l0, d0, N_0, l1, d1, a, N_c, a, u, tw, l3, d3, a, N_p, a, u, l3);

seq1 = [Expt1, ', ', Expt2, ', ', Expt3, ', ', Expt4];

ch = complieCHN({{seq1}});
uploadSimpleProg(char(gmSEQ.name), ch);

ApplyDelays();
gmSEQ.CHN = ApplyFPGATimeCorrection(gmSEQ.CHN);