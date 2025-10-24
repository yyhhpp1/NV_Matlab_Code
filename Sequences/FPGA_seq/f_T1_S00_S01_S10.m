function f_T1_S00_S01_S10
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

t_T1 = d+p+u+m+p+u; %time betweeen two laser pulse for measurements
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
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
T=[100];
DT=[t_R*6+t_T1*3+i*9-200];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('FPGATrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=1;
T=[t_R + i + t_T1 + i + d];
DT=[200];
ConstructSeq(T,DT)


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[0, t_R*5+t_T1*3+i*9-20];
DT=[20, 20];
ConstructSeq(T,DT)

uploadSimplePulse('+X', gSG.FPGAFreq7, gSG.FPGAGain7, gmSEQ.pi, 0)

wait1 = round((u + i + t_R + i + t_T1 - u - p));
wait2 = round((u + i + d));
wait3 = round((u + i + t_R + i + d));
wait4 = round((t_T1 - d - p + i + d));

seq1 = {'+X', wait1, '+X', wait2, '+X', wait3 ,'+X', wait4, '+X'};

ch = complieCHN({seq1});
uploadSimpleProg(char(gmSEQ.name), ch);



ApplyDelays();

