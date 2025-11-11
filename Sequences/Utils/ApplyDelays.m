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

AWG_Delay = 46; % 2GHz sampling rate
% AWG_Delay = 53/gSG.AWGClockRate+14; % Need further testing

% LaserAWG_Delay = 53/gSG2.LaserAWGClockRate+14; % for 0.1GHz , delay = [(53*(1/SamplingRate)) + 14] ns

MW2_Delay = 26;

for i=1:numel(gmSEQ.CHN)
    if gmSEQ.CHN(i).PBN==PBDictionary('AOM')
        gmSEQ.CHN(i).Delays=ones(1,2)*aom_delay;
    elseif gmSEQ.CHN(i).PBN==PBDictionary('ctr0')
        gmSEQ.CHN(i).Delays=ones(1,2)*detector_delay;
    elseif gmSEQ.CHN(i).PBN == PBDictionary('AWGTrig') % Yuanqi Lyu, for AWG.
        gmSEQ.CHN(i).Delays = ones(1, 2) * AWG_Delay;
    elseif gmSEQ.CHN(i).PBN == PBDictionary('AWGTrig2') 
        gmSEQ.CHN(i).Delays = ones(1, 2) * AWG_Delay;
    elseif gmSEQ.CHN(i).PBN == PBDictionary('AWGTrig3') 
        gmSEQ.CHN(i).Delays = ones(1, 2) * (AWG_Delay+MW2_Delay);
    elseif gmSEQ.CHN(i).PBN == PBDictionary('MWSwitch3') 
        gmSEQ.CHN(i).Delays = ones(1, 2) * MW2_Delay;
    else
        gmSEQ.CHN(i).Delays=zeros(1,2);
    end
end
end