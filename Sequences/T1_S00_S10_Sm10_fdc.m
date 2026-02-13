function T1_S00_S10_Sm10_fdc
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='LOL';
gSG.bModSrc='External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

if strcmp(gmSEQ.meas,'APD')
    gmSEQ.CtrGateDur = 4000;
end


arr = gmSEQ.SweepParam;
max_index = length(arr);
m = gmSEQ.m;
index_m = find(arr ==m); %find the index of the current t
index_n = 1 + max_index - index_m; %find the index of the differential t
n = arr(index_n); %find the differential t
d = gmSEQ.post_init_wait; %AfterLaser
u = gmSEQ.post_MW_wait; %AfterPulse
% w = 1e6; %initial wait
i = gmSEQ.readout; 
r = gmSEQ.CtrGateDur;


% pi time
pi = gmSEQ.pi;
pi2 =gmSEQ.DEERpi;

t_T1_m = d+max(pi,pi2)+u+m+pi+u; %time betweeen two laser pulse for measurements
t_R = d+max(pi, pi2)+u; %time betweeen two laser pulse for references

t_T1_n = d+max(pi,pi2)+u+n+pi+u;


%%%%% Variable sequence length%%%%%%

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=18;
T=[...
   t_R,     t_T1_m+i-r, t_R+i-r,          ...     S0
   t_R+i-r, t_T1_m+i-r, t_R+i-r,          ...     S1
   t_R+i-r, t_T1_m+i-r, t_R+i-r,           ...     Sm1
   t_R+i-r, t_T1_n+i-r, t_R+i-r,          ...     S0
   t_R+i-r, t_T1_n+i-r, t_R+i-r,          ...     S1
   t_R+i-r, t_T1_n+i-r, t_R+i-r           ...     Sm1
   ];       
DT = [r];
DT = repmat(DT, 1, 18);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=18;
T=[...
   t_R, t_T1_m, t_R,          ...     S0
   t_R, t_T1_m, t_R,          ...     S1
   t_R, t_T1_m, t_R,           ...     Sm1
   t_R, t_T1_n, t_R,          ...     S0
   t_R, t_T1_n, t_R,          ...     S1
   t_R, t_T1_n, t_R           ...     Sm1
   ];       
DT = [i];
DT = repmat(DT, 1, 18);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=8; 
T=[...
    t_R+i+t_T1_m+i+d, u+i+t_R+i+t_T1_m+i+d, u+i+t_R+i+d, t_T1_m-d-max(pi, pi2)+i+d, ...
    u+i+t_R+i+t_T1_n+i+d, u+i+t_R+i+t_T1_n+i+d, u+i+t_R+i+d, t_T1_n-d-max(pi, pi2)+i+d
];
DT = [pi, pi, pi, pi, pi, pi, pi, pi];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[...
    t_R+i+t_T1_m+i+t_R+i+t_R+i+d, ...
    t_T1_m-d-max(pi, pi2)+(i+t_R)*3+i*2+t_T1_m+t_R+i+t_T1_n+i+t_R+i+t_R+i+d
];
DT=[pi2, pi2];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[0, t_R*14+t_T1_m*3+t_T1_n*3+i*16];
DT=[20 20];
ConstructSeq(T,DT)

ApplyDelays();

