function PiCal
global gmSEQ gSG
gSG.bfixedPow = 0;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL'; % set to no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(10);

T_AfterLaser = gmSEQ.post_init_wait;
T_AfterPulse = gmSEQ.post_MW_wait;
T_initial_wait = T_AfterLaser + gmSEQ.pi + T_AfterPulse;

% Pulse Blaster
gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 2;
gmSEQ.CHN(1).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.pi + T_AfterPulse];
gmSEQ.CHN(1).DT = [gmSEQ.CtrGateDur, gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T_initial_wait + gmSEQ.readout + T_AfterLaser;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = gmSEQ.pi;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [T_initial_wait, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.pi + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout, gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    T_initial_wait + gmSEQ.readout + T_AfterLaser + gmSEQ.pi + T_AfterPulse];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [1000, 1000];

ApplyDelays();
