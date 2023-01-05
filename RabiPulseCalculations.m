%Rabi pulse duration calculations

readout = 10000;
afterlaser = 1000;
MWbuffer = 10;
m = 0;
to = 80;
afterpulse = 500;
ctrgatedur = 400;

MW_T = readout + afterlaser - MWbuffer;
MW_DT = m + 2*MWbuffer;
MW_ET = MW_T + MW_DT;

AOM_T = [0, readout + afterlaser + to + afterpulse];
AOM_DT = [readout, 3000];
AOM_ET = AOM_T + AOM_DT;

ctr0_T = [readout - ctrgatedur - 1000, readout + afterlaser + to + afterpulse];
ctr0_DT = [ctrgatedur, ctrgatedur];
ctr0_ET = ctr0_T + ctr0_DT; 