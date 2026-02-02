function f_FPGA_clock_test
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

t0 = 5000;
T_AfterLaser = gmSEQ.post_init_wait;
T_AfterPulse = gmSEQ.post_MW_wait;
T_initial_wait = T_AfterLaser + gmSEQ.pi*cc2ns + T_AfterPulse;
wait_cc = gmSEQ.m;
loop_n = 3e6;
%wait = loop_n * cc2ns * 400;
wait = wait_cc * cc2ns;


% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 2;
gmSEQ.CHN(1).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout+ T_AfterLaser + wait + gmSEQ.pi*cc2ns + T_AfterPulse];
gmSEQ.CHN(1).DT = [gmSEQ.CtrGateDur, gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout+ T_AfterLaser + wait + gmSEQ.pi*cc2ns + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout + wait , gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout/2;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = gmSEQ.readout + T_AfterLaser + wait + gmSEQ.pi*cc2ns + T_AfterPulse;

%fpga trigger
gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('FPGATrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

% % fpga trig dup
% gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 5;
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;
% 
% % time that we read counter
% gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 7;
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout+ T_AfterLaser + gmSEQ.m+ gmSEQ.pi + T_AfterPulse;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 1000;
% 
% % time that we want the pi pulse
% gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = 6;
% gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
% gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.m;
% gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 1000;


gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + wait + gmSEQ.pi*cc2ns + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [1000, 1000];

uploadSimplePulse('+X', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.pi, 0)
uploadSimplePulse('+X_fake', 100, 1,  200, 0)


seq1 = {wait_cc,'+X'};
%seq1 = {['loop(' num2str(loop_n) ',' '[' num2str(200) ', +X_fake])'],'+X'};
ch = complieCHN({seq1});
uploadSimpleProg('f_FPGA_clock_test', ch);


ApplyDelays();
gmSEQ.CHN = ApplyFPGATimeCorrection(gmSEQ.CHN);
