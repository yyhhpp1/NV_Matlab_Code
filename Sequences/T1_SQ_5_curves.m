function T1_SQ_5_curves
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
p_sg1 = gmSEQ.pi; %0 to -1
p_sg2 = gmSEQ.DEERpi; % 0 to +1
p = p_sg1;

t_T1 = d+p+u+m+p+u; %time betweeen two laser pulse for measurements
t_R = d+p+u; %time betweeen two laser pulse for references

%%%%% Variable sequence length%%%%%%

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=15;
T=[...
   t_R,     t_T1+i-r, t_R+i-r,          ...     0,0
   t_R+i-r, t_T1+i-r, t_R+i-r,          ...     0,-1
   t_R+i-r, t_T1+i-r, t_R+i-r           ...     0,+1
   t_R+i-r, t_T1+i-r, t_R+i-r,          ...     -1,0
   t_R+i-r, t_T1+i-r, t_R+i-r           ...     +1,0
   ];       
DT = [r];
DT = repmat(DT, 1, 15);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=15;
T=[...
   t_R, t_T1, t_R,          ...     
   t_R, t_T1, t_R,          ...     
   t_R, t_T1, t_R,          ...
   t_R, t_T1, t_R,          ...     
   t_R, t_T1, t_R,          ...     
   ];       
DT = [i];
DT = repmat(DT, 1, 15);
ConstructSeq(T,DT)

t_P1 = t_R + i + d; %time for first pulse in one expt
t_P2 = t_R + i + d + p + u + m; %time for second pulse in one expt
t_Pr = t_R + i + d + p + u + m + p + u + i + d; %time for ref pulse in one expt
t_Expt = t_R + i + t_T1 + i + t_R +i; %time for one full T1 experiments

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=7;
T=[...
                                     t_Pr + t_Expt*0, ...     0,0
                    t_P2 + t_Expt*1, t_Pr + t_Expt*1, ...     0,-1
                                     t_Pr + t_Expt*2, ...     0,+1
   t_P1 + t_Expt*3,                  t_Pr + t_Expt*3, ...     -1,0
                                     t_Pr + t_Expt*4, ...     +1,0

   ];
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = repmat([p_sg1], 1, 7);

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[...
   ...     0,0
   ...     0,-1
   t_P2 + t_Expt*2, ...     0,+1
   ...     -1,0
   t_P1 + t_Expt*4, ...     +1,0
   ];
gmSEQ.CHN(numel(gmSEQ.CHN)).T = T;
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = repmat([p_sg2], 1, 2);

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[0, t_R*10+t_T1*5+i*14-20];
DT=[20 20];
ConstructSeq(T,DT)

ApplyDelays();

