function f_Cooling
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';%set to no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);


cc2ns = 1000/(384);
ns2cc = 1/cc2ns;

gmSEQ.plotting = 'T1_S00_S01';
gmSEQ.fitting = 'A_Exp_t';


N_0 = 20;
N_c = 1000;
N_p = 100; 
a.cc = 0;
d.cc = 1000; 
u.cc = 1000;
tw.cc = 0;
l1.cc = 10000;
l2.cc = 10000;
l3.cc = 10000;
h.cc = gmSEQ.halfpi;
p.cc = gmSEQ.pi;
g1.percent = 512;
g2.percent = 512;
t1.cc = 8;
t2.cc = 6;

%Time for each cooling cycle
Tc.cc = l.cc + d.cc + 2 * h.cc + 2 * a.cc + u.cc + N_c * (t1.cc + t2.cc);

%Time at the start of readout cycle of init laser
Tr_start.cc = N0 * Tc.cc + tw_cc;

%Time at the start of readout cycle of readout laser
Tr.cc = Ti.cc + l.cc + d.cc + 2 * h.cc + 2*a.cc + u.cc + N_t * (t1.cc + t2.cc);

%Time for the readout cycle
Tr



pre_init_wait = gmSEQ.post_init_wait; %ns



% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = ;

gmSEQ.CHN(1).T = [T_green_1_start, T_green_2_start, T_green_3_start, T_green_4_start];
gmSEQ.CHN(1).DT = [gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur, gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [T_green_1_start, T_green_2_start, T_green_3_start, T_green_4_start];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout, gmSEQ.readout, gmSEQ.readout, gmSEQ.readout];


gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_green_1_start + gmSEQ.readout/2;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = T_green_4_start - T_green_1_start;

%fpga trigger
gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('FPGATrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_green_1_start + gmSEQ.readout + gmSEQ.post_init_wait;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

% gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 11;
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_green_1_start + gmSEQ.readout + gmSEQ.post_init_wait - FPGA_delay;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;



gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_green_4_start + gmSEQ.readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [100, 100];

uploadSimplePulse('+X', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.pi, 0)
uploadSimplePulse('+Xhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 0)
uploadSimplePulse('-Xhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 180)
wait1 = round((gmSEQ.post_init_wait + gmSEQ.post_MW_wait + gmSEQ.readout)*ns2cc);

if gmSEQ.m == 0
    seq1 = {'+X'};
else
%     max_pulse_length = 20000 * cc2ns;
%     N_max_length = fix(gmSEQ.m * cc2ns/max_pulse_length);
%     remain_pulse_length = mod(gmSEQ.m * cc2ns, max_pulse_length);
% 
%     uploadSimplePulse('+Y_long', gSG.FPGAFreq7, gSG.FPGAGain7, max_pulse_length, 90)
%     long_Ys = repmat({'+Y_long'}, 1, N_max_length);
%     if remain_pulse_length < 10 
%         short_Y = {0};
%     else
%         uploadSimplePulse('+Y_short', gSG.FPGAFreq7, gSG.FPGAGain7, remain_pulse_length, 90) 
%         short_Y = {'+Y_short'};
%     end
%     
%     dt=10 * cc2ns;
% 
%     seq1 = [{'+Xhalf', dt,}, ...
%         long_Ys, short_Y, ...
%         {dt, '+Xhalf', wait1, gmSEQ.pi * cc2ns, wait1, '+Xhalf', dt}, ...
%         long_Ys, short_Y, ...
%         {dt, '-Xhalf'}];

    max_pulse_length = 50000;
    N_max_length = fix(gmSEQ.m/max_pulse_length);
    remain_pulse_length = mod(gmSEQ.m, max_pulse_length);

    uploadSimplePulse('+Y_long', gSG.FPGAFreq7, gSG.FPGAGain7, max_pulse_length, 90)
    long_Ys = repmat({'+Y_long'}, 1, N_max_length);
    if remain_pulse_length < 10 
        short_Y = {0};
    else
        uploadSimplePulse('+Y_short', gSG.FPGAFreq7, gSG.FPGAGain7, remain_pulse_length, 90) 
        short_Y = {'+Y_short'};
    end
   
    seq1 = [{'+Xhalf', dt,}, ...
        long_Ys, short_Y, ...
        {dt, '+Xhalf', wait1, gmSEQ.pi, wait1, '+Xhalf', dt}, ...
        long_Ys, short_Y, ...
        {dt, '-Xhalf'}];
end
ch = complieCHN({seq1});
uploadSimpleProg('f_Spin_Locking', ch);


ApplyDelays();
gmSEQ.CHN = ApplyFPGATimeCorrection(gmSEQ.CHN);