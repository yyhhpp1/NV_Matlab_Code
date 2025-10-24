function T1_S11_S1m1
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='LOL';
gSG.bModSrc='External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

if strcmp(gmSEQ.meas,'APD')
    gmSEQ.CtrGateDur = 4000;
end

m = gmSEQ.m;
d = gmSEQ.post_init_wait; %AfterLaser
u = gmSEQ.post_MW_wait; %AfterPulse
% w = 1e6; %initial wait
i = gmSEQ.readout; 
r = gmSEQ.CtrGateDur;
p = gmSEQ.pi;
p2 = gmSEQ.DEERpi;

t_T1 = d+p+u+m+p+u;
t_R = d+p+u;

%%%%% Variable sequence length%%%%%%

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=6;
T=[t_R,t_T1+i-r,t_R+i-r,t_R+i-r,t_T1+i-r,t_R+i-r];
DT = [r];
DT = repmat(DT, 1, 6);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
T=[t_R,t_T1,t_R,t_R,t_T1,t_R];
DT=[i,i,i,i,i,i];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5;
T=[t_R+i+d, u+m, u+i+d, u+i+d+p+u+i+d, u+m+p+u+i+d];
DT=[p];
DT = repmat(DT, 1, 5);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
T=[t_R*3 + i*4 + t_T1*2 - p - u];
DT=[p];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[0, t_R*3+t_T1*2+i*5-20];
DT=[20 20];
ConstructSeq(T,DT)

ApplyDelays();

