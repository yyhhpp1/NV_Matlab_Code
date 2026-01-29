function f_Spin_Locking_tomo
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';%set to no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);


cc2ns = 1000/(384);
ns2cc = 1/cc2ns;
%cc2ns = 1;


dt= 0;


gmSEQ.plotting = 'T1_S00_S01';
gmSEQ.fitting = 'A_Exp_t';

pre_init_wait = gmSEQ.post_init_wait + gmSEQ.post_MW_wait;


seq_len = round((gmSEQ.halfpi * 2 + gmSEQ.m + dt * 2) * cc2ns);


T_green_1_start = pre_init_wait;
T_green_2_start = T_green_1_start + gmSEQ.readout + pre_init_wait + seq_len;
T_green_3_start = T_green_2_start + gmSEQ.readout + pre_init_wait + round(gmSEQ.pi * cc2ns);
T_green_4_start = T_green_3_start + gmSEQ.readout + pre_init_wait + seq_len;



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
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_green_1_start + gmSEQ.readout + gmSEQ.post_init_wait;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;
% 
% gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 7;
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_green_1_start + gmSEQ.readout + gmSEQ.post_init_wait;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 1000;



gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_green_4_start + gmSEQ.readout];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [100, 100];

uploadSimplePulse('+X', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.pi, 0)
uploadSimplePulse('+Xhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 0)
uploadSimplePulse('-Xhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 180)
uploadSimplePulse('+Yhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 90)
uploadSimplePulse('-Yhalf', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.halfpi, 270)
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

    max_pulse_length = 20000;
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
   
    dt = 0;
    seq1 = [{'+Xhalf', dt,}, ...
        long_Ys, short_Y, ...
        {dt, '+Xhalf', wait1, gmSEQ.pi, wait1, '+Xhalf', dt}, ...
        long_Ys, short_Y, ...
        {dt, '+Yhalf'}];
end
ch = complieCHN({seq1});
uploadSimpleProg('f_Spin_Locking_tomo', ch);


ApplyDelays();
