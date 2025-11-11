function f_XY8_fdc
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';%set to no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

tp = gmSEQ.interval;
two_tp = num2str(2 * tp);
tp = num2str(tp);
fpga_delay = 700;

arr = gmSEQ.SweepParam;
max_index = length(arr);
m = gmSEQ.m;
index_m = find(arr ==m); %find the index of the current t
index_n = 1 + max_index - index_m; %find the index of the differential t
n = arr(index_n); %find the differential t that fixed the duty cycle



pre_init_wait = gmSEQ.post_init_wait + gmSEQ.post_MW_wait;


seq_len_m = round(((str2double(two_tp) + gmSEQ.pi) * 8 * m + gmSEQ.halfpi * 2) * 2.6)+1;
seq_len_n = round(((str2double(two_tp) + gmSEQ.pi) * 8 * n + gmSEQ.halfpi * 2) * 2.6)+1;

T_green_1_start = pre_init_wait;
T_green_2_start = T_green_1_start + gmSEQ.readout + gmSEQ.post_init_wait + gmSEQ.post_MW_wait + seq_len_m;
T_green_3_start = T_green_2_start + gmSEQ.readout + pre_init_wait + gmSEQ.pi * 3;
T_green_4_start = T_green_3_start + gmSEQ.readout + gmSEQ.post_init_wait + gmSEQ.post_MW_wait + seq_len_n;


% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 4;

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
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_green_1_start + gmSEQ.readout + gmSEQ.post_init_wait-fpga_delay;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

% gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 11;
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_green_1_start + gmSEQ.readout + gmSEQ.post_init_wait-fpga_delay;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;


gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_green_4_start + gmSEQ.readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [100, 100];



uploadSimplePulse('+X', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.pi, 0)
uploadSimplePulse('+Y', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.pi, 90)
uploadSimplePulse('+Xhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 0)
uploadSimplePulse('-Xhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 180)

wait1 = round((gmSEQ.post_init_wait + gmSEQ.post_MW_wait + gmSEQ.readout) / 2.6);


loop_str_m = ['loop(' num2str(m) ',' '[' tp ',+X,' two_tp ',+Y,' two_tp ',+X,' two_tp ',+Y,' two_tp ',+Y,' two_tp ',+X,' two_tp ',+Y,' two_tp ',+X,' tp '])'];
loop_str_n = ['loop(' num2str(n) ',' '[' tp ',+X,' two_tp ',+Y,' two_tp ',+X,' two_tp ',+Y,' two_tp ',+Y,' two_tp ',+X,' two_tp ',+Y,' two_tp ',+X,' tp '])'];

seq1 = {'+Xhalf',loop_str_m, '+Xhalf', wait1, '+X', wait1, '+Xhalf', loop_str_n, '-Xhalf'};
ch = complieCHN({seq1});
uploadSimpleProg('f_XY8_fdc', ch);


ApplyDelays();
