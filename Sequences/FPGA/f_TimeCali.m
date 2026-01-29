function f_TimeCali
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'IQ';
gSG.bModSrc = 'External';

gmSEQ.plotting = 'Rabi';
gmSEQ.fitting = 'none';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

cc2ns = 1000/(384);
ns2cc = 1/cc2ns;


T_AfterLaser = gmSEQ.post_init_wait;
T_AfterPulse = gmSEQ.post_MW_wait;
T_initial_wait = T_AfterLaser + round(gmSEQ.pi*cc2ns) + T_AfterPulse;


% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 2;
% gmSEQ.CHN(1).T = [gmSEQ.readout - gmSEQ.CtrGateDur - 1000, ...
%     gmSEQ.readout + T_AfterLaser + gmSEQ.To + T_AfterPulse];
gmSEQ.CHN(1).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + round(gmSEQ.pi*cc2ns) + T_AfterPulse];
gmSEQ.CHN(1).DT = [gmSEQ.CtrGateDur, gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + round(gmSEQ.pi*cc2ns) + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout, gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout/2;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = gmSEQ.readout*2+T_AfterPulse/2;

%fpga trigger
gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('FPGATrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 7;
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 1000;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + round(gmSEQ.pi*cc2ns) + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [1000, 1000];


max_pulse_length = 20000;
N_max_length = fix(gmSEQ.pi/max_pulse_length);
remain_pulse_length = mod(gmSEQ.pi, max_pulse_length);

uploadSimplePulse('+Y_long', gSG.FPGAFreq7, gSG.FPGAGain7, max_pulse_length, 90)
long_Ys = repmat({'+Y_long'}, 1, N_max_length);
if remain_pulse_length < 10
    short_Y = {0};
else
    uploadSimplePulse('+Y_short', gSG.FPGAFreq7, gSG.FPGAGain7, remain_pulse_length, 90)
    short_Y = {'+Y_short'};
end

seq1 = [long_Ys, short_Y];

ch = complieCHN({seq1});
uploadSimpleProg('f_TimeCali', ch);


ApplyDelays();
