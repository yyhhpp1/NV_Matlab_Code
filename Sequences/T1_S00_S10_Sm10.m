function T1_S00_S10_Sm10
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


% pi time
pi = gmSEQ.pi;
pi2 =gmSEQ.DEERpi;

t_T1 = d+max(pi,pi2)+u+m+pi+u; %time betweeen two laser pulse for measurements
t_R = d+max(pi, pi2)+u; %time betweeen two laser pulse for references

%%%%% Variable sequence length%%%%%%

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=9;
delay = 1000;
T=[...
   t_R+delay,     t_T1+i-r, t_R+i-r,          ...     S0
   t_R+i-r, t_T1+i-r, t_R+i-r,          ...     S1
   t_R+i-r, t_T1+i-r, t_R+i-r           ...     Sm1
   ];       
DT = [r];
DT = repmat(DT, 1, 9);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=9;
T=[...
   t_R, t_T1, t_R,          ...     S0
   t_R, t_T1, t_R,          ...     S1
   t_R, t_T1, t_R           ...     Sm1
   ];       
DT = [i];
DT = repmat(DT, 1, 9);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4; 
T=[...
    t_R+i+t_T1+i+d, u+i+t_R+i+t_T1+i+d, u+i+t_R+i+d, t_T1-d-max(pi, pi2)+i+d
];
DT = [pi, pi, pi, pi];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
T=[...
    t_R+i+t_T1+i+t_R+i+t_R+i+d
];
DT=[pi2];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[0, t_R*7+t_T1*3+i*8];
DT=[20 20];
ConstructSeq(T,DT)

ApplyDelays();

