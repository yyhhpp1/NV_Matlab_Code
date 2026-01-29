function f_FPGA_delay
global gmSEQ gSG
gSG.bfixedPow = 1;
gSG.bfixedFreq = 1;
gSG.bMod = 'LOL';%set to no modulation
gSG.bModSrc = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

t1 = 10000;

gmSEQ.CHN(1).PBN = PBDictionary('ctr0');
gmSEQ.CHN(1).NRise = 2;
gmSEQ.CHN(1).T = [t1, t1 + gmSEQ.readout + gmSEQ.m+ gmSEQ.post_init_wait];
gmSEQ.CHN(1).DT = [gmSEQ.CtrGateDur, gmSEQ.CtrGateDur];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [t1, t1 + gmSEQ.readout + gmSEQ.m+ gmSEQ.post_init_wait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout, gmSEQ.readout];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('FPGATrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = t1 + gmSEQ.readout + gmSEQ.post_init_wait;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = 100;

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN) ).NRise = 1;
gmSEQ.CHN(numel(gmSEQ.CHN) ).T = [t1];
gmSEQ.CHN(numel(gmSEQ.CHN) ).DT = [gmSEQ.readout*2 + gmSEQ.pi + gmSEQ.m+ gmSEQ.post_init_wait];

gmSEQ.CHN(numel(gmSEQ.CHN) + 1).PBN = PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [0, ...
    t1+ gmSEQ.readout + gmSEQ.pi + gmSEQ.m+ gmSEQ.post_init_wait];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [20, 20];

uploadSimplePulse('+X', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.pi, 0)
seq1 = {'+X'};
ch = complieCHN({seq1});
uploadSimpleProg('f_FPGA_delay', ch);


ApplyDelays();
