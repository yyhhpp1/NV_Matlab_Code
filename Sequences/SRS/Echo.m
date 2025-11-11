function Echo
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

AfterPi = 500; % hBN1: 500; Zilin: 2000; WL: 100 --> 500, 4/2/25
AfterLaser = 1000; % hBN1: 1000; Zilin: 0.05e6; WL: 100 --> 1000, 4/2/25
Wait_p = 0.02e6; % hBN: 0.02e6; Zilin: 0.01e6; WL: 100 --> 0.02e6, 4/2/25
Detect_Window = 5000; 

Sig_D_start = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p; %WL: hBN1: PulseGap = 30 ns, need here too? 4/2/25

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Wait_p+gmSEQ.readout-1000-gmSEQ.CtrGateDur, ...
    Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi, ...
    Sig_D_start+gmSEQ.readout-1000-gmSEQ.CtrGateDur, ... 
    Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi];
if strcmp(gmSEQ.meas,'SPCM')
    gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];
elseif strcmp(gmSEQ.meas,'APD')
    gmSEQ.CHN(1).DT=[1000 1000 1000 1000];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p, Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi, ...
    Sig_D_start, Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout Detect_Window gmSEQ.readout Detect_Window];
%

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AWGTrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser, ...
    Sig_D_start+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = repelem(gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+200, 2); %WL: hBN1 - fixed as [7000 7000]


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
if gmSEQ.m/2 < 200
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+40];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=6;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2-20, ...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2-20, ...
        Sig_D_start+gmSEQ.readout+AfterLaser-20, ... 
        Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2-20, ...
        Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+40, ... 
    gmSEQ.halfpi+40, gmSEQ.pi+40, gmSEQ.halfpi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+AfterPi+Detect_Window-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[50 50];

% gmSEQ.MWAWG = 1;
% disp(gmSEQ.MWAWG)

%% AWG
% Initialization
chaseFunctionPool('stopChase',  gmSEQ.MWAWG)

if gSG.ACmodAWG % in AC modulation mode; % phase = 0 --> +X; pi/2 --> +Y; pi --> -X, 3*pi/2 --> -Y 
    WaveForm_1I = [0 gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp;... % X 
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp; ... % Y
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp]; % -X
    WaveForm_1Q = [0 gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi gSG.AWGFreq pi/2-pi/2 gSG.AWGAmp; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi gSG.AWGFreq pi-pi/2 gSG.AWGAmp];

    WaveForm_1Length = ceil((gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_1PointNum = WaveForm_1Length * gSG.AWGClockRate;

    WaveForm_2I = [0 gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp;... % X 
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi gSG.AWGFreq pi/2 gSG.AWGAmp; ... % Y 
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp]; % X
    WaveForm_2Q = [0 gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi gSG.AWGFreq pi/2-pi/2 gSG.AWGAmp; ...
        gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi gSG.AWGFreq 0-pi/2 gSG.AWGAmp];

    WaveForm_2Length = ceil((gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_2PointNum = WaveForm_2Length * gSG.AWGClockRate;
            
else
    WaveForm_1I = [0 gmSEQ.halfpi 0 pi/2 gSG.AWGAmp;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 3*pi/2 gSG.AWGAmp];
    WaveForm_1Q = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.AWGAmp];
    
    WaveForm_1Length = ceil((gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_1PointNum = WaveForm_1Length * gSG.AWGClockRate;
    
    % dark sequence
    WaveForm_2I = [0 gmSEQ.halfpi 0 pi/2 gSG.AWGAmp;...
           gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi 0 pi/2 gSG.AWGAmp];
    WaveForm_2Q = [0 gmSEQ.halfpi 0 0 0;...
        gmSEQ.halfpi+gmSEQ.m/2 gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi 0 pi/2 gSG.AWGAmp];
    
    WaveForm_2Length = ceil((gmSEQ.halfpi+gmSEQ.m/2+gmSEQ.pi+gmSEQ.m/2+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_2PointNum = WaveForm_2Length * gSG.AWGClockRate;

end
chaseFunctionPool('createWaveform', WaveForm_1I, gSG.AWGClockRate, WaveForm_1Length, 'Echo_I_seg1.txt'); pause(0.5); %WL: no need to set the AWG clock rate = 2 GHz as done in the hBN1? 4/2/25 
chaseFunctionPool('createWaveform', WaveForm_1Q, gSG.AWGClockRate, WaveForm_1Length, 'Echo_Q_seg1.txt'); pause(0.5);
chaseFunctionPool('createWaveform', WaveForm_2I, gSG.AWGClockRate, WaveForm_2Length, 'Echo_I_seg2.txt'); pause(0.5);
chaseFunctionPool('createWaveform', WaveForm_2Q, gSG.AWGClockRate, WaveForm_2Length, 'Echo_Q_seg2.txt'); pause(0.5);

chaseFunctionPool('createSegStruct', 'Echo_SegStruct_I.txt', ...
    'Echo_I_seg1.txt', WaveForm_1PointNum, 1, 1, ...
    'Echo_I_seg2.txt', WaveForm_2PointNum, 1, 1);
pause(0.5);
chaseFunctionPool('createSegStruct', 'Echo_SegStruct_Q.txt', ...
    'Echo_Q_seg1.txt', WaveForm_1PointNum, 1, 1, ...
    'Echo_Q_seg2.txt', WaveForm_2PointNum, 1, 1);
pause(0.5);
chaseFunctionPool('CreateSegments', gmSEQ.MWAWG, 1, ...
    2, ...
    2047, 2047, 'Echo_SegStruct_I.txt', 'false');
pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
chaseFunctionPool('CreateSegments', gmSEQ.MWAWG, 2, ...
    2, ...
    2047, 2047, 'Echo_SegStruct_Q.txt', 'false');
pause(1); % this pause seems to be important, otherwise the loading is not right occassionally

chaseFunctionPool('runChase', gmSEQ.MWAWG, 'false');

ApplyDelays();
