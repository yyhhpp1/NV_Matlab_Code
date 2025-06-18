function T1_Test_Charge
%fdc stands for fixed duty cycle
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='LOL';
gSG.bModSrc='External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);


arr = gmSEQ.SweepParam;
max_index = length(arr);
m = gmSEQ.m;
index_m = find(arr ==m); %find the index of the current t
index_n = 1 + max_index - index_m; %find the index of the differential t
n = arr(index_n); %find the differential t

d = m; %AfterLaser
u = gmSEQ.post_MW_wait; % wait time for charge to reach equlibrium
i = gmSEQ.readout; 
r = gmSEQ.CtrGateDur;
p = gmSEQ.pi;

To = arr(end)+arr(1);

%%%%% Variable sequence length%%%%%%

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
T=[d,i-2*r,u,i-2*r];
DT=[r,r,r,r];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('GreenAOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[d,u];
DT=[i,i];
ConstructSeq(T,DT)

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
T=[0 d+u+2*i-r];
DT=[20 20];
ConstructSeq(T,DT)

ApplyDelays();