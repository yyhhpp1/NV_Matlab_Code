function T1_S00_S01_S10_spectator_noise
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
post_p2 = 200; % post p2 delay

t_T1 = d+p+u+m+p+u+p2+post_p2; %time betweeen two laser pulse for measurements
t_R = d+p+u; %time betweeen two laser pulse for references

%%%%% Variable sequence length%%%%%%

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=9;
T=[...
   t_R,     t_T1+i-r, t_R+i-r,          ...     S00
   t_R+i-r, t_T1+i-r, t_R+i-r,          ...     S01
   t_R+i-r, t_T1+i-r, t_R+i-r          ...     S10
   ];       
DT = [r];
DT = repmat(DT, 1, 9);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=9;
T=[...
   t_R, t_T1, t_R,          ...     S00
   t_R, t_T1, t_R,          ...     S01
   t_R, t_T1, t_R          ...     S10
   ];       
DT = [i];
DT = repmat(DT, 1, 9);
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=5;
T=[...
   t_R+i+t_T1+i+d,                    ...     S00
   u+i+t_R+i+d+p+u+m+p2+post_p2, u+i+d,          ...     S01
   u+i+t_R+i+d+p2+post_p2, u+m+p+u+i+d          ...     S10
   ];       
DT = [p];
DT = repmat(DT, 1, 5);
ConstructSeq(T,DT)

% depolarization / state inversion pulse on spectator group
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch2');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=3;
T=[...
   t_R+i+d, t_T1-d-p2+i*3+t_R*3+d,     ...     S00 and S01
   t_T1-d-p2+i*3+t_R*3+d    % S10
   ];       
DT = [p2];
DT = repmat(DT, 1, 3);
ConstructSeq(T,DT)


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[0, t_R*5+t_T1*3+i*9-20];
DT=[20 20];
ConstructSeq(T,DT)

ApplyDelays();

