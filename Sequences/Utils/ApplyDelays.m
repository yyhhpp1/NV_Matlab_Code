function ApplyDelays
global gmSEQ
% aom_delay = 610; % changed to 610 03/24/2022 RT4 Weijie.
%aom_delay = 1040; %ejd 1/4/22 changed from 900 to 500 % changed to 820 10/19/2022 RT4 Weijie. % changed to 1040 9/27/2024 sangha
aom_delay = 200; % 01/31/25 Sangha; hBN1: 500, Zilin: 200 ns; WL: 700 --> 200 ns, 4/3/25
if strcmp(gmSEQ.meas,'APD') 
    detector_delay=-1100+610;
else
    detector_delay=0;
end

FPGA_Delay = 700; 

for i=1:numel(gmSEQ.CHN)
    if gmSEQ.CHN(i).PBN==PBDictionary('GreenAOM')
        gmSEQ.CHN(i).Delays=ones(1,2)*aom_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('ctr0')
        gmSEQ.CHN(i).Delays=ones(1,2)*detector_delay;
    elseif gmSEQ.CHN(i).PBN == PBDictionary('FPGATrig')
        gmSEQ.CHN(i).Delays = ones(1, 2) * FPGA_Delay;
    else
        gmSEQ.CHN(i).Delays=zeros(1,2);
    end
end
end