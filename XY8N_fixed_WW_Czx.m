function XY8N_fixed_WW_Czx % Janis setup, 9/11/25
%XY8 with total tau_MW is fixed  & disorder wind-unwind sequence for XX & ZZ autocorrelations  

global gmSEQ gSG

gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale((gmSEQ.pi+gmSEQ.interval)*gmSEQ.To);

gmSEQ.TempTau0 = gmSEQ.interval; %TempTau0 is the interval length between pi-pulses during the XY8 
gmSEQ.TempTau1 = gmSEQ.DEERpi; %TempTau1 is the fixed length between first and last half pi --> total MW length as fixed 

%gSG.AWGClockRate = 2; % in GHz. Yuanqi; WL: maybe not necessary for ours?

if strcmp(gmSEQ.meas,'APD')
    gmSEQ.CtrGateDur = 1000;
end

%% parameters 
Wait_p = 0.2e5; % wait time between sequences 
AfterLaser = 1000; % buffer time after laser initialization 
Detect_Window = 5000; % readout laser pulse time 
AfterPi = 500; % buffer time before laser readout; 500 ns in our Rabi case; 200 --> 500, WL 12/19/24
AfterPi2 = gmSEQ.TempTau0; % buffer time between the pi_x and half pi_x between the unwinding step below 
MWbuffer = 20; % buffer time for MW switch - before and after; 20 ns for the Janis setup

XY8Num = round(gmSEQ.m); % number of single pi pulses for XY-8
XY8Length = XY8Num*(gmSEQ.TempTau0+gmSEQ.pi); % TempTau0 is the pulse interval length

wind_t = 10; % disorder winding time 
unwind_t = 10; % disorder unwinding time 

XY8Length_WW = wind_t + gmSEQ.halfpi + XY8Length + gmSEQ.pi + AfterPi2 + gmSEQ.halfpi + unwind_t; % total XY8 sequence + WW sequence  


if XY8Length_WW > gmSEQ.TempTau1 % TempTau1 is the fixed length between first and last half pi
    warning('TempTau1 is shorter than Pulse Length. Please input a longer TempTau1');
end

if strcmp(gmSEQ.meas,'APD')
    gmSEQ.CtrGateDur = 1000;
end

gmSEQ.CHN(1).PBN=PBDictionary('AOM');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T = []; gmSEQ.CHN(1).DT =[];
gmSEQ.CHN(1).T = [Wait_p Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.readout Detect_Window];

Start_Sig_D = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;
gmSEQ.CHN(1).T = [gmSEQ.CHN(1).T Start_Sig_D Start_Sig_D+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.TempTau1+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(1).DT = [gmSEQ.CHN(1).DT gmSEQ.readout Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(2) gmSEQ.CHN(1).T(3)+gmSEQ.readout-1000-gmSEQ.CtrGateDur gmSEQ.CHN(1).T(4)];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise = 2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p+gmSEQ.readout+AfterLaser-MWbuffer, Start_Sig_D+gmSEQ.readout+AfterLaser-MWbuffer]; %switch buffer time = 25 -> 50; 100 in our Rabi case; 50 --> 100, WL 12/19/24; 100 --> 20, WL 4/4/25
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.halfpi+XY8Length_WW+gmSEQ.halfpi+2*MWbuffer gmSEQ.halfpi+XY8Length_WW+gmSEQ.halfpi+2*MWbuffer];
%%%%%%%%%%%%%%%%%%%%

Max_length = 2*Wait_p +  2*gmSEQ.readout + Detect_Window*2 + 2*(AfterLaser+AfterPi+gmSEQ.halfpi+XY8Length_WW+gmSEQ.halfpi);% total sequence time 
Max_length2 = gmSEQ.CHN(1).T(4) + Detect_Window;

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
%gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 gmSEQ.CHN(1).T(2*(gmSEQ.PulseNum+2)+2)+Wait_p];
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Max_length2-200];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[200 200];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AWGTrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2; % use 8 pi/2 P1 pulse spacing 10us away to mix P1
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[gmSEQ.CHN(1).T(1)+gmSEQ.readout+AfterLaser gmSEQ.CHN(1).T(3)+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[250 250];

% for MW_AWG
if gSG.ACmodAWG 
    
    % in AC modulation mode ==> phase = 0 --> +X; pi/2 --> +Y; pi --> -X, 3*pi/2 --> -Y

    % array info: start t (after triggered), end t, freq, phase, amplitude 

    % +X pi/2 pulse 

    C_1 = [0 gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp]; 
    C_2 = [0 gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp];

   
    if XY8Num>0

        % winding (free-evolution) -X pi/2 pulse 

        C_1 = [C_1; ...
            gmSEQ.halfpi+wind_t gmSEQ.halfpi+wind_t+gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp]; 
        C_2 = [C_1; ...
            gmSEQ.halfpi+wind_t gmSEQ.halfpi+wind_t+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp];


        % XY-8 sequence: N-pi pulses  

        for zz = 1:XY8Num
            if ( (mod(zz,8) == 1) || (mod(zz,8) == 3) || (mod(zz,8) == 6) || (mod(zz,8) == 0)) % X
                C_1 = [C_1; ...
                    2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2 2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp];
                C_2 = [C_2; ...
                    2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2 2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2+gmSEQ.pi gSG.AWGFreq -pi/2 gSG.AWGAmp];
            else % Y
                C_1 = [C_1; ...
                    2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2 2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp];
                C_2 = [C_2; ...
                    2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2 2*gmSEQ.halfpi+wind_t+(zz-1)*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.interval/2+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp];
            end
        end

        % +X pi pulse

        C_1 = [C_1;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi) 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi gSG.AWGFreq 0 gSG.AWGAmp];
        C_2 = [C_2;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi) 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi gSG.AWGFreq -pi/2 gSG.AWGAmp];


        % -X pi/2 pulse 

        C_1 = [C_1;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
        C_2 = [C_2;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp];        
       
       
        % unwinding (free-evolution) - final +- X pi/2 pulse for differential measurement

        % X: dark
        D_1 = [C_1;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
        D_2 = [C_2;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t+gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp];      
       
        % -X: bright
        C_1 = [C_1;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t+gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
        C_2 = [C_2;...
                2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t 2*gmSEQ.halfpi+wind_t+XY8Num*(gmSEQ.interval+gmSEQ.pi)+gmSEQ.pi+AfterPi2+gmSEQ.halfpi+unwind_t+gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp];      
 

    else

        % N = 0 case 

        D_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp]; % X
        D_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp];
       
        C_1 = [C_1; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp]; % -X
        C_2 = [C_2; ...
            gmSEQ.halfpi 2*gmSEQ.halfpi gSG.AWGFreq pi/2 gSG.AWGAmp];
    
    end
       
   
else
%DC modulation
end
       
    Length2_2 = round(gmSEQ.halfpi+XY8Length_WW+gmSEQ.halfpi+1000);
    Length2_3 = round(gmSEQ.halfpi+XY8Length_WW+gmSEQ.halfpi+1000);
    clkRate2 = 2e9;
 
    Total2_2 = ceil(Length2_2*clkRate2/1e9/16)*16;
    Total2_3 = ceil(Length2_3*clkRate2/1e9/16)*16;
   
    chaseFunctionPool('stopChase', gmSEQ.MWAWG); pause(0.3);
    chaseFunctionPool('setClkRate', gmSEQ.MWAWG, clkRate2); pause(0.3);

    chaseFunctionPool('createWaveform', C_1, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch1_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', C_2, gSG.AWGClockRate, Length2_2, 'wave_AWG_ch2_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_1, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch1_seg3.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', D_2, gSG.AWGClockRate, Length2_3, 'wave_AWG_ch2_seg3.txt'); pause(0.5);
   
    chaseFunctionPool('createSegStruct', 'SegStruct_ch1.txt', 'wave_AWG_ch1_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch1_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'SegStruct_ch2.txt', 'wave_AWG_ch2_seg2.txt', Total2_2, 1, 1, ...
         'wave_AWG_ch2_seg3.txt', Total2_3, 1, 1);
    pause(0.5);
   
    chaseFunctionPool('CreateSegments', gmSEQ.MWAWG, 1, 2, 2047, 2047, 'SegStruct_ch1.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', gmSEQ.MWAWG, 2, 2, 2047, 2047, 'SegStruct_ch2.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', gmSEQ.MWAWG, 'false');

ApplyDelays();