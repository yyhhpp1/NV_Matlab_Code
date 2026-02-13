function f_knill_rabi
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';%set to no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

T_AfterLaser = 5000;
T_AfterPulse = 2000;
T_initial_wait = T_AfterLaser + T_AfterPulse;
fpga_delay = 700;
clk = 2.6;

% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 2;
% gmSEQ.CHN(1).T = [gmSEQ.readout - gmSEQ.CtrGateDur - 1000, ...
%     gmSEQ.readout + T_AfterLaser + gmSEQ.To + T_AfterPulse];
gmSEQ.CHN(1).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.To*5*clk + T_AfterPulse];
gmSEQ.CHN(1).DT = [gmSEQ.CtrGateDur, gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = gmSEQ.readout*2+T_AfterPulse/2;

%fpga trigger
gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 10;
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser - fpga_delay;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 11;
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser - fpga_delay;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.To*5*clk + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout, gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.To*5*clk + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [1000, 1000];


phase_offset = 15;
uploadSimplePulse('+X0', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.m, 0);
uploadSimplePulse('+X0_2', gSG.FPGAFreq6, gSG.FPGAGain6, gmSEQ.m, phase_offset);
uploadSimplePulse('+X30', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.m, 30);
uploadSimplePulse('+X30_2', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.m, 30+phase_offset);
uploadSimplePulse('+X90', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.m, 90);
uploadSimplePulse('+X90_2', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.m, 90+phase_offset);




% uploadPeriodicPulse('pX', gSG.FPGAFreq7, 0, 0)
seq1 = {'+X30', '+X0', '+X90', '+X0', '+X30'};
seq2 = {'+X30_2', '+X0_2', '+X90_2', '+X0_2', '+X30_2'};
%seq2 = {'pX'};
ch = complieCHN({seq1,seq2});
uploadSimpleProg('f_knill_rabi', ch);

ApplyDelays();


