function t1_semi_auto_run(hObject, eventdata, handles, handles2)
%[y,Fs] = audioread('ExptCompleted.mp3');
BackupFile = 'C:\MATLAB_Code\Data\TempDataBackup\Temp.mat';
global gmSEQ gSG gSG2 tmax hCPS
cfg = config();

% default setting
gmSEQ.bRaman = 0;
gmSEQ.bRandom = 0;
gmSEQ.bGo = 1;
gmSEQ.bExp = 1; % experiment status tag
getUserInputFromGUI(handles);
SequencePool(string(gmSEQ.name))
InitializeData(handles);


disp(strcat('Commencing ',{' '},string(gmSEQ.name), ' sequence...'))
set(handles.runningText,'string','Running')
drawnow;

if gSG.bfixedFreq % pulsed sequence (supports fixed-power and swept-power)
    CreateSavePath_Ave()
   
    
    numPDChan=0;
    
    gmSEQ.dataN = gmSEQ.ctrN;
    
    %append the voltage data to the counts data. Hence we need to expand
    %the counts array by the corresponding voltage channels to read.
    %TODO: store voltage data to a separate file
    gmSEQ.signal_Ave = NaN(gmSEQ.dataN*(numPDChan+1), gmSEQ.NSweepParam);
    gmSEQ.signal = NaN(gmSEQ.dataN*(numPDChan+1), gmSEQ.NSweepParam);
    
    %%% if use fpga this is not needed, freq and amp will be imported
    %%% through the sequence_name.m
    %%% TODO: add a button for turning on the FPGA. If using FPGA, skip the
    %%% following lines
    
    SignalGeneratorFunctionPool('SetMod');
    SignalGeneratorFunctionPool('WritePow');
    SignalGeneratorFunctionPool('WriteFreq');
    gSG.bOn=1;  SignalGeneratorFunctionPool('RFOnOff');
    
    if handles.useSG2.Value
        SignalGeneratorFunctionPool2('SetMod');
        SignalGeneratorFunctionPool2('WritePow');
        SignalGeneratorFunctionPool2('WriteFreq');
        gSG2.bOn=1;  SignalGeneratorFunctionPool2('RFOnOff');
    end
    
    
    try
        %DAQmxResetDevice('Dev1');
        [~, hCounter0] = SetNCounters(0,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        %         [~, hCounter1] = SetNCounters(1,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        %         [~, hCounter2] = SetNCounters(2,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        %         [~, hCounter3] = SetNCounters(3,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        
        for i=1:gmSEQ.Average
            gmSEQ.iAverage=i;
            handles.biAverage.String=num2str(gmSEQ.iAverage);
            % disp("Running the round " + num2str(i))
            raw_j=1;
            iwarmup=1;
            
            randomList = randperm(gmSEQ.NSweepParam); % Shuffle the input, added by Weijie 04/20/2022
            
            while raw_j<=gmSEQ.NSweepParam
                % gmSEQ.refCounts=Track('Run');
                if gmSEQ.bRandom
                    j = randomList(raw_j);  % Shuffle the input, added by Weijie 04/20/2022
                else
                    j = raw_j;
                end

                gmSEQ.m=gmSEQ.SweepParam(j); % Manually change the sweep range here.
                if strcmp(gmSEQ.name, 'Special Cooling')
                    disp(['    gmSEQ.m = ', num2str(gmSEQ.m)]);
                end

                % Support power-swept pulsed sequences (e.g., PiCal/PiCal_SG2):
                % when frequency is fixed but power is not fixed, apply the
                % current sweep point to SG output power before running PB.
                if ~gSG.bfixedPow && gSG.bfixedFreq
                    if handles.useSG2.Value
                        gSG2.Pow = gmSEQ.SweepParam(j);
                        SignalGeneratorFunctionPool2('WritePow');
                    else
                        gSG.Pow = gmSEQ.SweepParam(j);
                        SignalGeneratorFunctionPool('WritePow');
                    end

                    % Power sweep should be displayed directly in dBm.
                    if strcmp(gmSEQ.name, 'PiCal') || strcmp(gmSEQ.name, 'PiCal_SG2') || strcmp(gmSEQ.name, 'CaliPi')
                        gmSEQ.ScaleT = 1;
                        gmSEQ.ScaleStr = 'dBm';
                    end
                end
                
                if gmSEQ.bTomo
                    %none
                else
                    SequencePool(string(gmSEQ.name));
                    DrawSequence(gmSEQ,hObject, eventdata, handles.axes1);
                    for k=1:numel(gmSEQ.CHN)
                        gmSEQ.CHN(k).T=gmSEQ.CHN(k).T/1e9;
                        gmSEQ.CHN(k).DT=gmSEQ.CHN(k).DT/1e9;
                        gmSEQ.CHN(k).Delays=gmSEQ.CHN(k).Delays/1e9;
                    end
                    PBFunctionPool('PreprocessPBSequence',gmSEQ); % todo: account for ns
                              
                  
                    %%%
                    StartCounters(hCounter0);
                    if gmSEQ.measPD;StartCounters(hCounterPD0);end
                    %                     StartCounters(hCounter2);
                    %                     StartCounters(hCounter3);

                    %handles.fpga_ack_str = msg;
                    pause(0.1)
                    Run_PB_Sequence();
                    
                    [~, vec0] = ReadCountersN(hCounter0,(1*gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                    %                     [~, vec2] = ReadCountersN(hCounter2,(1*gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                    %                     [~, vec3] = ReadCountersN(hCounter3,(1*gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                    DAQmxStopTask(hCounter0);
                    
                 
                    %                     DAQmxStopTask(hCounter2);
                    %                     DAQmxStopTask(hCounter3);
                    %%%
                    
                    %vec = [0 0 0];
                    sigDatum0 = ProcessData(vec0);
                    %                     sigDatum2 = ProcessData(vec2);
                    %                     sigDatum3 = ProcessData(vec3);
                    %                     sigDatum = sigDatum0+sigDatum1+sigDatum2+sigDatum3;
                    
                    
                    
                    sigDatum = sigDatum0;
                    for k = 1:gmSEQ.ctrN
                        gmSEQ.signal_Ave(k, j) = sigDatum(k);
                        if i == 1
                            gmSEQ.signal(k, j) = sigDatum(k);
                            gmSEQ.signal(gmSEQ.signal == 0) = NaN;
                        else
                            gmSEQ.signal(k, j) = (gmSEQ.signal(k, j)*(i-1)+sigDatum(k))/i;
                        end
                    end
                    
                    

                end
                
                % save a backup of the data here in case matlab crashes
                TemporarySave(BackupFile);
                autoplot.dispatch(handles, handles2, raw_j, gmSEQ.name, gmSEQ.ctrN, cfg.plotting);
                drawnow;
                
                if ~gmSEQ.bGo
                    break
                end
                if (gmSEQ.bWarmUpAOM && iwarmup==3)||~gmSEQ.bWarmUpAOM||i~=1||raw_j~=1
                    raw_j=raw_j+1;
                elseif gmSEQ.bWarmUpAOM
                    iwarmup=iwarmup+1;
                end
                
            end
            
            SaveIgorText_Average(handles);
            SaveIgorText(handles);
            maybe_stop_current_t1_on_fit_relerr(handles);
            
            if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                break
            end
        end
        ClearCounters(hCounter0);
        %         ClearCounters(hCounter2);
        %         ClearCounters(hCounter3);
    catch ME
        KillAllTasks; %kill all niDAQ tasks
        set(handles.runningText,'string','Error!')
        gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
        if handles.useSG2.Value; gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff'); end
        rethrow(ME);
    end
    if gmSEQ.bTrack
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
    end
    
    
elseif isfield(gmSEQ,'bLiO')   % activates for ESR
    CreateSavePath_Ave()
    gmSEQ.dataN = gmSEQ.ctrN;
    gmSEQ.signal_Ave = NaN(gmSEQ.dataN, gmSEQ.NSweepParam);
    gmSEQ.signal = NaN(gmSEQ.dataN, gmSEQ.NSweepParam);
    SequencePool(string(gmSEQ.name));
    gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
    gSG.sweepDev=(gmSEQ.SweepParam(gmSEQ.NSweepParam)-gmSEQ.SweepParam(1))/2;
    gSG.Freq=(gmSEQ.SweepParam(gmSEQ.NSweepParam)+gmSEQ.SweepParam(1))/2;
    SignalGeneratorFunctionPool('WriteFreq');
    if gSG.Pow > -10%%%%%%
        error("Too large MW power. ")
    end
    SignalGeneratorFunctionPool('WritePow');
    SignalGeneratorFunctionPool('SetMod');
    PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM')+2^SequencePool('PBDictionary','MWSwitch'));
    
    try
        [vec, NN]=MakeSweepVector();
        
        gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
        for i=1:gmSEQ.Average
            
            % tracking disable
            %gmSEQ.refCounts=Track('Run');
            %%%%% Pulse Train %%%%%
            [~, hPulse] = DigPulseTrainCont(gmSEQ.NSweepParam*gSG.sweepRate,0.5,NN);
            hCPS.hPulse=hPulse;
            %%%%% Analog write %%%%
            [ ~, hScan ] = DAQmxFunctionPool('WriteAnalogVoltage',PortMap('SG ext mod'),vec, NN,gmSEQ.NSweepParam*gSG.sweepRate);
            hCPS.hScan=hScan;
            %%%%% Create counting channel %%%%
            [~, hCounter] = SetNCounters(0,NN,'/Dev1/PFI13',gmSEQ.NSweepParam*gSG.sweepRate);
            hCPS.hCounter=hCounter;
            gmSEQ.iAverage=i;
            handles.biAverage.String=num2str(gmSEQ.iAverage);
            status = DAQmxStartTask(hScan);  DAQmxErr(status);            status = DAQmxStartTask(hCounter);  DAQmxErr(status);
            status = DAQmxStartTask(hPulse);    DAQmxErr(status);
            
            [~, A] = ReadCountersN(hCounter,NN, gmSEQ.misc*1.1);
            pause(0.5)
            
            DAQmxStopTask(hCounter);
            DAQmxStopTask(hScan);
            DAQmxStopTask(hPulse);
            if gmSEQ.bAAR==1
                gmSEQ.signal_Ave(1,:) = ProcessData(A);
                if i==1
                    gmSEQ.signal(1,:) = ProcessData(A);
                else
                    gmSEQ.signal(1,:) = (gmSEQ.signal(1,:)*(i-1)+ProcessData(A))/i;
                end
            else
                gmSEQ.signal(1,:) = ProcessData(A);
                gmSEQ.signal_Ave(1,:) = ProcessData(A);
            end
            
            TemporarySave(BackupFile);
            PlotESRData(handles);
            FitESR(handles, handles2);
            drawnow;
            DAQmxClearTask(hCounter);
            DAQmxClearTask(hPulse);
            DAQmxClearTask(hScan);
            
            SaveIgorText_Average(handles);
            
            if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                break
            end
            
            
        end
    catch ME
        KillAllTasks;
        gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
        %gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff');
        set(handles.runningText,'string','Error!')
        rethrow(ME);
    end
    if ~gmSEQ.bTrack
        ExperimentFunctionPool('PBOFF',hObject, eventdata, handles);
    end
    gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
    
elseif gSG.bfixedPow && ~gSG.bfixedFreq % for ODMR
    CreateSavePath_Ave()
    
    %gmSEQ.refCounts=Track('Init');
    SignalGeneratorFunctionPool('SetMod');
    SignalGeneratorFunctionPool('WritePow');
    gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
    gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
    %CreateCaliLog(hObject, eventdata, handles);
    
    %gmSEQ.bTomo = gmSEQ.Alternate;
    gmSEQ.bTomo = false;
    if gmSEQ.bTomo
        gmSEQ.dataN = 3*gmSEQ.ctrN;
        disp("Tomographical measurement ongoing...")
    else
        gmSEQ.dataN = gmSEQ.ctrN;
    end
    gmSEQ.signal_Ave = NaN(gmSEQ.dataN, gmSEQ.NSweepParam);
    gmSEQ.signal = NaN(gmSEQ.dataN, gmSEQ.NSweepParam);
    
    if gmSEQ.bRandom
        disp("Random measurement ongoing...")
    end
    
    try
        [~, hCounter] = SetNCounters(0,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        for i=1:gmSEQ.Average
            gmSEQ.iAverage=i;
            handles.biAverage.String=num2str(gmSEQ.iAverage);
            raw_j=1;
            iwarmup=1;
            
            randomList = randperm(gmSEQ.NSweepParam); % Shuffle the input, added by Weijie 04/20/2022
            
            while raw_j<=gmSEQ.NSweepParam
                %  gmSEQ.refCounts=Track('Run');
                if gmSEQ.bRandom
                    j = randomList(raw_j);  % Shuffle the input, added by Weijie 04/20/2022
                else
                    j = raw_j;
                end
                
                %Calibration(hObject, eventdata, handles)
                SequencePool(string(gmSEQ.name));

                gSG.Freq = gmSEQ.SweepParam(j);

                %
                SignalGeneratorFunctionPool('WriteFreq');
                % SignalGeneratorFunctionPool('WritePow');
                % gmSEQ.m=gmSEQ.SweepParam(j);
                
                SequencePool(string(gmSEQ.name));
                DrawSequence(gmSEQ,hObject, eventdata, handles.axes1);
                for k=1:numel(gmSEQ.CHN)
                    gmSEQ.CHN(k).T=gmSEQ.CHN(k).T/1e9;
                    gmSEQ.CHN(k).DT=gmSEQ.CHN(k).DT/1e9;
                    gmSEQ.CHN(k).Delays=gmSEQ.CHN(k).Delays/1e9;
                end
                PBFunctionPool('PreprocessPBSequence',gmSEQ); % todo: account for ns
                StartCounters(hCounter);
                
                Run_PB_Sequence();
                %pause(gmSEQ.Repeat*tmax/1e9*1.1);
                %ExperimentFunctionPool('PBOFF',hObject, eventdata, handles);
                [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                DAQmxStopTask(hCounter);
                sigDatum = ProcessData(vec);
                
                for k = 1:gmSEQ.ctrN
                    gmSEQ.signal_Ave(k, j) = sigDatum(k);
                    if i == 1
                        gmSEQ.signal(k, j) = sigDatum(k);
                    else
                        gmSEQ.signal(k, j) = (gmSEQ.signal(k, j)*(i-1)+sigDatum(k))/i;
                    end
                end
                
                % save a backup of the data here in case matlab crashes
                TemporarySave(BackupFile);
                autoplot.dispatch(handles, handles2, raw_j, gmSEQ.name, gmSEQ.ctrN, cfg.plotting);
                drawnow;
                if ~gmSEQ.bGo
                    break
                end
                if (gmSEQ.bWarmUpAOM && iwarmup==2)||~gmSEQ.bWarmUpAOM||i~=1||raw_j~=1
                    raw_j=raw_j+1;
                elseif gmSEQ.bWarmUpAOM
                    iwarmup=iwarmup+1;
                end
                
            end
            SaveIgorText(handles);
            SaveIgorText_Average(handles);
            maybe_stop_current_t1_on_fit_relerr(handles);
            
            if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                break
            end
        end
        
        ClearCounters(hCounter);
    catch ME
        KillAllTasks;
        gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
        set(handles.runningText,'string','Error!')
        rethrow(ME);
    end
end

gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
if handles.useSG2.Value; gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff'); end
gmSEQ.bGo = 0;
gmSEQ.bExp = 0;
SaveIgorText(handles);

disp('Experiment completed!')
set(handles.runningText,'string','Stopped')

%turn on laser
PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM'));
%sound(y,Fs);

function getUserInputFromGUI(handles)
global gmSEQ

% for two sweeping range, with option for log10 sampling
% Add by C. Zu on 9/29/2020
if get(handles.bSweep1log,'Value')
    gmSEQ.SweepParam=round(logspace(log10(gmSEQ.From),log10(gmSEQ.To),gmSEQ.N));
    gmSEQ.SweepParam = unique(gmSEQ.SweepParam,'first'); %remove repeating elements
else
    gmSEQ.SweepParam=linspace(gmSEQ.From,gmSEQ.To,gmSEQ.N);
end

if (gmSEQ.bSweep2)
    if (gmSEQ.bSweep2log)
        gmSEQ.SweepParam=round([gmSEQ.SweepParam logspace(log10(gmSEQ.From2),log10(gmSEQ.To2),gmSEQ.N2)]);
        gmSEQ.SweepParam = unique(gmSEQ.SweepParam,'first'); %remove repeating elements
    else
        gmSEQ.SweepParam=[gmSEQ.SweepParam linspace(gmSEQ.From2,gmSEQ.To2,gmSEQ.N2)];
    end
end

if (gmSEQ.bSweep3)
    if (gmSEQ.bSweep3log)
        gmSEQ.SweepParam=round([gmSEQ.SweepParam logspace(log10(gmSEQ.From3),log10(gmSEQ.To3),gmSEQ.N3)]);
        gmSEQ.SweepParam = unique(gmSEQ.SweepParam,'first'); %remove repeating elements
    else
        gmSEQ.SweepParam=[gmSEQ.SweepParam linspace(gmSEQ.From3,gmSEQ.To3,gmSEQ.N3)];
    end
end

if strcmp(gmSEQ.name, 'T1_S00_S01_S10_S11_S1m1') || strcmp(gmSEQ.name, 'T1_S11_S1m1')
    gmSEQ.SweepParam = unique(round(gmSEQ.SweepParam,-3),'first'); %remove repeating elements
else
    gmSEQ.SweepParam = unique(gmSEQ.SweepParam,'first');
end

% Customized in the input data here
% DEER ODMR Weijie 04/19/2022
gmSEQ.bCust = get(handles.useCustPoints,'Value');
if gmSEQ.bCust
    % gmSEQ.SweepParam = [linspace(0.900,0.928, 15), linspace(0.930,0.969,40), linspace(0.970, 1.018, 25), linspace(1.020, 1.069, 51),  linspace(1.070, 1.100, 16)];
    aaa = linspace(6,206,51);
    aaa(end) = [];
    bbb = linspace(206,606,21);
    gmSEQ.SweepParam = [aaa bbb];
    % gmSEQ.SweepParam = [linspace(50, 20050, 5), linspace(40000, 100000, 4), linspace(150000, 400000, 6), linspace(500000, 800000, 4)];
    % Seq F 100 ns
    % gmSEQ.SweepParam = [linspace(0, 20, 6), linspace(30, 60, 4), linspace(80, 200, 7), linspace(240, 400, 5)];
    % Seq F 200 ns
    % gmSEQ.SweepParam = [linspace(0, 10, 6), linspace(15, 30, 4), linspace(40, 100, 7), linspace(120, 200, 5)];
    % Seq F 300 ns
    % gmSEQ.SweepParam = [linspace(0, 6, 4), linspace(10, 30, 6), linspace(40, 90, 6), linspace(110, 150, 3)];
    % Seq G 100 ns
    % gmSEQ.SweepParam = [linspace(0, 6, 4), linspace(10, 30, 6), linspace(40, 200, 9)];
    % Cory 100 ns
    % gmSEQ.SweepParam = [linspace(0, 5, 6), linspace(6, 20, 8), linspace(30, 80, 6)];
    
    disp("Customized input, GUI values are overwritten.")
end
if isfield(gmSEQ, 'SmartCustomSweepParam') && ~isempty(gmSEQ.SmartCustomSweepParam)
    gmSEQ.SweepParam = round(double(gmSEQ.SmartCustomSweepParam(:).'));
    gmSEQ.SweepParam = unique(gmSEQ.SweepParam, 'stable');
    disp("Smart custom input, GUI sweep values are overwritten.")
end

function InitializeData(handles)
global gmSEQ
gmSEQ.NSweepParam=length(gmSEQ.SweepParam);
gmSEQ.signal=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference2=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference3=NaN(1,gmSEQ.NSweepParam);

gmSEQ.bGo=1;
gmSEQ.bGoAfterAvg=1;
for i=1:numel(gmSEQ.CHN)
    if gmSEQ.CHN(i).PBN==SequencePool('PBDictionary','ctr0')
        gmSEQ.ctrN=gmSEQ.CHN(i).NRise;
    end
end

function Run_PB_Sequence
% function RunPBSequence

PBesrInit(); %initialize PBesr
% sets the clock frequency. for PBESR-PRO-400, it's 400MHz
% for PBESR-PRO-333, it's 333.3MHz
PBesrSetClock(500);

PBesrStart(); %start pulsing. it will start pulse sequence which were progammed/loaded to PBESR card before.

PBesrClose(); %close PBesr
%set status to 0, implement in the future
status = 0;

function [status, task] = SetNCounters(varargin)
%varargin(1) is the number of total samples
%varargin(2) is the source of gating
%varargin(3) is the frequency of the gating to expect
% Initialize DAQ
global gmSEQ hCPS
if strcmp(gmSEQ.meas,'SPCM')
    if isfield(gmSEQ,'bLiO')
        [status, task ] = DAQmxFunctionPool('SetCounter',varargin{2},varargin{1});
    else
        [status, task ] = DAQmxFunctionPool('SetGatedNCounter',varargin{2},varargin{1});
    end
    
elseif strcmp(gmSEQ.meas,'APD')
    numCHNtoCreate = 1;
    [status, task ] = DAQmxFunctionPool('CreateAIChannel',varargin{3},varargin{2},varargin{4}, numCHNtoCreate);
end
hCPS.hCounter=task;

function PlotData(handles,raw_j)
global gmSEQ

% Implement the special case and ESR later
for i = 1:gmSEQ.dataN
    if gmSEQ.dataN == 1
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(i, :)),'-', ...
            'color', [0, 0, 1],'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i))
    else
        plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT,single(gmSEQ.signal(i, :)),'-', ...
            'color', [0, (i-1)/(gmSEQ.dataN - 1), 1-(i-1)/(gmSEQ.dataN - 1)],'LineWidth', 0.5, 'DisplayName', sprintf('signal %d', i))
    end
    if i == 1
        hold(handles.axes2, 'on')
    end
end
grid(handles.axes2, 'on');
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);

% don't rescale x axis of the plots if num of sweep param is set to 1
if length(gmSEQ.SweepParam) ~= 1
    xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
end

if get(handles.bShowLegend,'Value')
    legend(handles.axes2)
end

% draw vertical dashed line to indicate where is the current measruement
if raw_j~=0 %do not draw for ESR where raw_j = 0
    xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
end
hold(handles.axes2, 'off')


if ~isfield(gmSEQ,'bLiO')&&gmSEQ.ctrN~=1 % Do not plot ESR
    % Remove NaN (empty data)
    for i = 1:gmSEQ.dataN
        signal(i,:) = gmSEQ.signal(i, ~isnan(gmSEQ.signal(i,:)));
    end
    
    
    if gmSEQ.ctrN==2
        
        sig = signal(2,:);
        ref = signal(1,:);
        data = sig./ref;
        ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
        sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
        rel_err = sqrt(ref_err.^2 + sig_err.^2);
        data_err = rel_err .* data;
        
    elseif gmSEQ.ctrN==12
        
        sig_B = signal(3,:);
        ref_B = signal(7,:);
        sig_D = signal(5,:);
        ref_D = signal(1,:);
        [data, data_err] = ContrastDiff(ref_B, ref_D,sig_B, sig_D, gmSEQ.iAverage);
        
    else
        data = zeros(size(signal(1,:)));
        data_err = data;
    end
    
    errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data, data_err,'-g')
    
    grid(handles.axes3, 'on');
    set(handles.axes3,'FontSize',8);
    ylabel(handles.axes3, 'Fluorescence contrast');
    xlabel(handles.axes3, gmSEQ.ScaleStr);
    if length(gmSEQ.SweepParam) ~= 1
        xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
    end
    if raw_j~=0
        xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
    end
end

function StartCounters(task)
DAQmxStartTask(task);

function [status,A] = ReadCountersN(task,samps,timeout)
global gmSEQ

if strcmp(gmSEQ.meas,'SPCM')
    [status, A]= DAQmxReadCounterU32(task, samps, timeout, zeros(1,samps), samps, libpointer('int32Ptr',0) );
elseif strcmp(gmSEQ.meas,'APD')
    numCHNtoRead = 1;
    [status, A] = DAQmxFunctionPool('ReadAnalogVoltage',task, samps, timeout, numCHNtoRead);
end
DAQmxErr(status);

function ClearCounters(task)
DAQmxClearTask(task);

function TemporarySave(BackupFile)
global gSG gmSEQ

% convert relevant globals to a bigger structure
BackupExp.gmSEQ=gmSEQ;
BackupExp.gSG=gSG;
%save the data in matlab binary format
save(BackupFile,'BackupExp');

function [vec, NN] = MakeSweepVector
global gSG gmSEQ
vecA=-1:(2/(gmSEQ.NSweepParam-1)):1;

vec=[vecA fliplr(vecA)];

vec=repmat(vec,1,ceil(gSG.sweepRate*gmSEQ.misc/2));
if strcmp(gmSEQ.meas,'SPCM')
    vec=[vec(1) vec];
end
NN=length(vec);

function sigDatum = ProcessData(RawData)
global gmSEQ gSG
if strcmp(gmSEQ.meas,'SPCM')
    % for ESR
    if isfield(gmSEQ,'bLiO')
        AA=diff(RawData);
        sigDatum=zeros(1,gmSEQ.NSweepParam);
        samps=gmSEQ.misc*gSG.sweepRate;
        AA=reshape(AA,[gmSEQ.NSweepParam samps]);
        AA(:,2:2:(samps))=flipud(AA(:,2:2:(samps)));
        for i=1:gmSEQ.NSweepParam
            sigDatum(i)=sum(AA(i,:))/(samps);
        end
    else
        if 1
            %RawData1 = diff(RawData); %use if DAQ generate sample at the rising edge
            RawData1 = diff([0 RawData]); %use if DAQ generate sample at the falling edge
            
            % if save raw box is checked, then save raw data to csv (will be overwritten)
%             if gmSEQ.saveRaw
%                 csvwrite('D:\RawData.csv', RawData1);
%             end
            
            
            sigDatum = NaN(1, gmSEQ.ctrN);
            for i = 1:gmSEQ.ctrN
                sigDatum(i)=sum(RawData1(i:gmSEQ.ctrN:end));
            end
        else %use when daq is sampling at both rising and falling edge of the gate pulse
            RawData2 = diff(RawData);
            sigDatum = NaN(1, gmSEQ.ctrN);
            for i = 1:gmSEQ.ctrN
                sigDatum(i)=sum(RawData2(2*i:gmSEQ.ctrN*2:end));
            end
        end
        
    end
elseif strcmp(gmSEQ.meas,'APD')
    if isfield(gmSEQ,'bLiO')
        sigDatum=zeros(1,gmSEQ.NSweepParam);
        samps=gmSEQ.misc*gSG.sweepRate;
        RawData=reshape(RawData,[gmSEQ.NSweepParam samps]);
        RawData(:,2:2:(samps))=flipud(RawData(:,2:2:(samps)));
        for i=1:gmSEQ.NSweepParam
            sigDatum(i)=sum(RawData(i,:))/(samps);
        end
    else
        sigDatum = NaN(1, gmSEQ.ctrN);
        for i = 1:gmSEQ.ctrN
            sigDatum(i)=sum(RawData(i:gmSEQ.ctrN:end))/(length(RawData)/gmSEQ.ctrN);
        end
    end
    
end

function CreateSavePath_Ave()
global gSaveDataAve gmSEQ
now = clock;
date = [num2str(now(1)),'-',num2str(now(2)),'-',num2str(round(now(3)))];
fullPath=fullfile('D:\Data\',date,'\');
if ~exist(fullPath,'dir')
    mkdir(fullPath);
end
gSaveDataAve.path = fullPath;

gSaveDataAve.file = ['_' date '_Ave.txt'];
name=regexprep(gmSEQ.name,'\W',''); % rewrite the sequence name without spaces/weird characters
%File name and prompt
B=fullfile(gSaveDataAve.path, strcat(name, gSaveDataAve.file));
file = strcat(name, gSaveDataAve.file);

%Prevent overwriting
mfile = strrep(B,'.txt','*');
mfilename = strrep(gSaveDataAve.file,'.txt','');

A = ls(char(mfile));
ImgN = 0;
for f = 1:size(A,1)
    sImgN = sscanf(A(f,:),strcat(name, string(mfilename), '_%d.txt'));
    if ~isempty(sImgN)
        if sImgN > ImgN
            ImgN = sImgN;
        end
    end
end
ImgN = ImgN + 1;
gSaveDataAve.file = strrep(file,'.txt',sprintf('_%03d.txt',ImgN));

function maybe_stop_current_t1_on_fit_relerr(handles)
global gmSEQ

if ~isfield(gmSEQ, 'AutoStopT1ByRelErr') || ~logical(gmSEQ.AutoStopT1ByRelErr)
    return;
end
if ~isfield(gmSEQ, 'T1FitLastStatus') || ~isstruct(gmSEQ.T1FitLastStatus)
    return;
end

st = gmSEQ.T1FitLastStatus;
if ~isfield(st, 'ok') || ~st.ok
    return;
end
if ~isfield(st, 'timeScaleRelErr') || ~isfinite(st.timeScaleRelErr)
    return;
end

thr = 0.05;
if isfield(gmSEQ, 'AutoStopT1RelErrThreshold') && isfinite(gmSEQ.AutoStopT1RelErrThreshold)
    thr = gmSEQ.AutoStopT1RelErrThreshold;
end
minAvg = 3;
if isfield(gmSEQ, 'AutoStopT1MinAverage') && isfinite(gmSEQ.AutoStopT1MinAverage)
    minAvg = max(1, round(gmSEQ.AutoStopT1MinAverage));
end
if ~isfield(gmSEQ, 'iAverage') || ~isfinite(gmSEQ.iAverage) || gmSEQ.iAverage < minAvg
    return;
end

if st.timeScaleRelErr <= thr
    gmSEQ.bGo = 0;
    gmSEQ.bGoAfterAvg = 0; % stop current sequence gracefully
    disp(sprintf('[SmartT1] Final T1 auto-stop: relErr=%.4f <= %.4f', st.timeScaleRelErr, thr));
    if isfield(handles, 'runningText') && isgraphics(handles.runningText, 'uicontrol')
        handles.runningText.String = 'Stopping (fit relErr reached)';
    end
end


