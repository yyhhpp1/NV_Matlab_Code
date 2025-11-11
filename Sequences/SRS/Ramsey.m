function Ramsey
global gmSEQ gSG
gSG.bfixedPow=1;
gSG.bfixedFreq=1;
gSG.bMod='IQ';
gSG.bModSrc='External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

gmSEQ.halfpi = gmSEQ.pi/2;

AfterPi = 500; %2000 --> 500, WL 9/6/25
AfterLaser = 1000; %0.1e6 --> 1000, WL 9/6/25
Wait_p = 1000; %0.1e6 --> 1000, WL 9/6/25
Detect_Window = 5000;

if strcmp(gmSEQ.meas,'APD')
    gmSEQ.CtrGateDur = 1000;
end

% TODO: change the total time
Sig_D_start = Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+AfterPi+Detect_Window+Wait_p;

gmSEQ.CHN(1).PBN=PBDictionary('ctr0');
gmSEQ.CHN(1).NRise=4;
gmSEQ.CHN(1).T=[Wait_p+gmSEQ.readout-1000-gmSEQ.CtrGateDur, ... % Ref_B
    Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+AfterPi, ... % Sig_B
    Sig_D_start+gmSEQ.readout-1000-gmSEQ.CtrGateDur, ... % Ref_D
    Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+AfterPi]; % Sig_D
gmSEQ.CHN(1).DT=[gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur gmSEQ.CtrGateDur];


gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AOM');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
gmSEQ.CHN(numel(gmSEQ.CHN)).T = [Wait_p, ...
    Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+AfterPi, ...
    Sig_D_start, ...
    Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+AfterPi];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT = [gmSEQ.readout Detect_Window gmSEQ.readout Detect_Window];

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('AWGTrig');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser, ...
    Sig_D_start+gmSEQ.readout+AfterLaser];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[500 500]; %2150 --> 500, WL 9/6/25

% Check this point
gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('MWSwitch');
if gmSEQ.m < 400
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20, Sig_D_start+gmSEQ.readout+AfterLaser-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+40, gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+40];
else
    gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=4;
    gmSEQ.CHN(numel(gmSEQ.CHN)).T=[Wait_p+gmSEQ.readout+AfterLaser-20,...
        Wait_p+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m-20, ...
        Sig_D_start+gmSEQ.readout+AfterLaser-20, ... 
        Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m-20];
    gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[gmSEQ.halfpi+40, gmSEQ.halfpi+40, gmSEQ.halfpi+40, gmSEQ.halfpi+40];
end

gmSEQ.CHN(numel(gmSEQ.CHN)+1).PBN=PBDictionary('dummy1');
gmSEQ.CHN(numel(gmSEQ.CHN)).NRise=2;
gmSEQ.CHN(numel(gmSEQ.CHN)).T=[0 Sig_D_start+gmSEQ.readout+AfterLaser+gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+AfterPi+Detect_Window-50];
gmSEQ.CHN(numel(gmSEQ.CHN)).DT=[50 50];

%% AWG
% Initialization
chaseFunctionPool('stopChase',  gmSEQ.MWAWG)

if gSG.ACmodAWG % in AC modulation mode
    WaveForm_1I = [0 gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp;...
        gmSEQ.halfpi+gmSEQ.m gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi gSG.AWGFreq pi gSG.AWGAmp];
    WaveForm_1Q = [0 gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp;...
        gmSEQ.halfpi+gmSEQ.m gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi gSG.AWGFreq pi-pi/2 gSG.AWGAmp];

    WaveForm_1Length = ceil((gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_1PointNum = WaveForm_1Length * gSG.AWGClockRate;

    WaveForm_2I = [0 gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp;...
        gmSEQ.halfpi+gmSEQ.m gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi gSG.AWGFreq 0 gSG.AWGAmp];
    WaveForm_2Q = [0 gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp;...
        gmSEQ.halfpi+gmSEQ.m gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi gSG.AWGFreq -pi/2 gSG.AWGAmp];

    WaveForm_2Length = ceil((gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_2PointNum = WaveForm_2Length * gSG.AWGClockRate;
            
else

    WaveForm_1I = [0 gmSEQ.halfpi 0 pi/2 gSG.AWGAmp;...
           gmSEQ.halfpi+gmSEQ.m gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi 0 3*pi/2 gSG.AWGAmp];
    WaveForm_1Q = [0 gmSEQ.halfpi 0 0 0;];
    
    WaveForm_1Length = ceil((gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_1PointNum = WaveForm_1Length * gSG.AWGClockRate;
    
    % dark sequence
    WaveForm_2I = [0 gmSEQ.halfpi 0 pi/2 gSG.AWGAmp;...
           gmSEQ.halfpi+gmSEQ.m gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi 0 pi/2 gSG.AWGAmp];
    WaveForm_2Q = [0 gmSEQ.halfpi 0 0 0;];
    
    WaveForm_2Length = ceil((gmSEQ.halfpi+gmSEQ.m+gmSEQ.halfpi+PulseGap+gmSEQ.pi+1000) / (16 / gSG.AWGClockRate)) ...
        *(16 / gSG.AWGClockRate);
    WaveForm_2PointNum = WaveForm_2Length * gSG.AWGClockRate;

end
    chaseFunctionPool('createWaveform', WaveForm_1I, gSG.AWGClockRate, WaveForm_1Length, 'Ramsey_I_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', WaveForm_1Q, gSG.AWGClockRate, WaveForm_1Length, 'Ramsey_Q_seg1.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', WaveForm_2I, gSG.AWGClockRate, WaveForm_2Length, 'Ramsey_I_seg2.txt'); pause(0.5);
    chaseFunctionPool('createWaveform', WaveForm_2Q, gSG.AWGClockRate, WaveForm_2Length, 'Ramsey_Q_seg2.txt'); pause(0.5);

    chaseFunctionPool('createSegStruct', 'Ramsey_SegStruct_I.txt', ...
        'Ramsey_I_seg1.txt', WaveForm_1PointNum, 1, 1, ...
        'Ramsey_I_seg2.txt', WaveForm_2PointNum, 1, 1);
    pause(0.5);
    chaseFunctionPool('createSegStruct', 'Ramsey_SegStruct_Q.txt', ...
        'Ramsey_Q_seg1.txt', WaveForm_1PointNum, 1, 1, ...
        'Ramsey_Q_seg2.txt', WaveForm_2PointNum, 1, 1);
    pause(0.5);
    chaseFunctionPool('CreateSegments', gmSEQ.MWAWG, 1, ...
        2, ...
        2047, 2047, 'Ramsey_SegStruct_I.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('CreateSegments', gmSEQ.MWAWG, 2, ...
        2, ...
        2047, 2047, 'Ramsey_SegStruct_Q.txt', 'false');
    pause(1); % this pause seems to be important, otherwise the loading is not right occassionally
    chaseFunctionPool('runChase', gmSEQ.MWAWG, 'false');

ApplyDelays();
