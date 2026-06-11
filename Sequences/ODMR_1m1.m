function ODMR_1m1

% init into 0, pi from 0 to -1 on SG3, pi from -1 to 1 on SG1, then pi form
% 1 to 0 on SG2

global gmSEQ gSG gSG2 gSG3
gSG.bfixedPow = 1;
gSG.bfixedFreq = 0;
gSG.bMod = 'LOL';%set to no modulation
gSG.bModSrc = 'External';

gSG2.bfixedPow = 1;
gSG2.bfixedFreq = 1;
gSG2.bMod = 'LOL';%set to no modulation
gSG2.bModSrc = 'External';

gSG3.bfixedPow = 1;
gSG3.bfixedFreq = 1;
gSG3.bMod = 'LOL';%set to no modulation
gSG3.bModSrc = 'External';

gmSEQ.ScaleStr = "GHz";
gmSEQ.ScaleT = 1e-9;

T_AfterLaser = gmSEQ.post_init_wait;
T_AfterPulse = gmSEQ.post_MW_wait;
T_initial_wait = T_AfterLaser + gmSEQ.To + T_AfterPulse;

p = gmSEQ.pi;
p2 = gmSEQ.DEERpi; 
post_p = 200;
post_p3 = 200;

p3 = gmSEQ.P1Pulse;

% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 2;
% gmSEQ.CHN(1).T = [gmSEQ.readout - gmSEQ.CtrGateDur - 1000, ...
%     gmSEQ.readout + T_AfterLaser + gmSEQ.To + T_AfterPulse];
gmSEQ.CHN(1).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + p + post_p + p3 + post_p3 + p2 + T_AfterPulse];
gmSEQ.CHN(1).DT = [gmSEQ.CtrGateDur, gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch3');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = p;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser + p + post_p + p3 + post_p3 ;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = p2;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser + p + post_p;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = p3;


gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + p + post_p + p3 + post_p3 + p2 + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout, gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.To + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [1000, 1000];

ApplyDelays();

