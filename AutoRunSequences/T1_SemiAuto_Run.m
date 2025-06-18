function T1_SemiAuto_Run(hObject, eventdata, handles)
[y,Fs] = audioread('ExptCompleted.mp3');
BackupFile = 'C:\MATLAB_Code\Data\TempDataBackup\Temp.mat';
global gmSEQ gSG tmax hCPS

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

if gSG.bfixedPow && gSG.bfixedFreq %pulsed seq
    CreateSavePath_Ave()
   
    
    numPDChan=0;
    
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
                if gmSEQ.ctrN<=24 %do not plot if too many counter gates
                    %PlotData(handles,raw_j);
                
                    if strcmp(gmSEQ.name,'Rabi')
                        PlotRabiData(handles,raw_j);
                        FitRabi(handles);
                    elseif strcmp(gmSEQ.name,'T1_S00_S01_S10_S11_darkRef')
                        PlotT1Data(handles,raw_j)
                    end
                end
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
            [~, hCounter] = SetNCounters(0,NN,'/Dev2/PFI13',gmSEQ.NSweepParam*gSG.sweepRate);
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
            FitESR(handles);
            drawnow;
            DAQmxClearTask(hCounter);
            DAQmxClearTask(hPulse);
            DAQmxClearTask(hScan);
            if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                break
            end
            SaveIgorText_Average(handles);
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
    
    gmSEQ.refCounts=Track('Init');
    SignalGeneratorFunctionPool('SetMod');
    SignalGeneratorFunctionPool('WritePow');
    gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
    gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
    CreateCaliLog(hObject, eventdata, handles);
    
    gmSEQ.bTomo = gmSEQ.Alternate;
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
                
                Calibration(hObject, eventdata, handles)
                SequencePool(string(gmSEQ.name));
                
                if gSG.ACmodAWG
                    gSG.Freq = gmSEQ.SweepParam(j)-str2double(get(handles.AWGFreq, 'String'))*1e9;
                else
                    gSG.Freq = gmSEQ.SweepParam(j);
                end
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
                PlotData(handles,raw_j);
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
grid on;
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
    
    grid on;
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

function PlotESRData(handles)
global gmSEQ

cmp = tab10(20);
colors = {cmp(1,:),cmp(2,:)};
plot(handles.axes2, single(gmSEQ.SweepParam)*gmSEQ.ScaleT, single(gmSEQ.signal(1, :)),'-', ...
            'color', colors{1},...
            'LineWidth', 0.5,...
            'DisplayName', 'data')
hold(handles.axes2, 'on');
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
hold(handles.axes2, 'off')

function FitESR(handles)
global gmSEQ
x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
y = double(gmSEQ.signal(1, :));

lorentz = @(p,x) - p(1) * (p(2)^2 ./ ((x - p(3)).^2 + p(2)^2)) + p(4);
% p1 is amp, p2 is width, p3 is loc, p4 is bg

amp0 = max(y) - min(y); 
width0 = 5e-3; %GHz
loc0 = x(y == min(y));
bg0 = max(y);
p0 = [amp0, width0, loc0, bg0];
lb = [0, 0, min(x), min(y)];
ub = [max(y), 1e-2, max(x), max(y)*2];

[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(lorentz, p0, x, y, lb, ub);
res = y - lorentz(popt, x);
dof = length(y) - length(popt);
mse = sum(res.^2) / dof;
pcov = mse * inv(jacob' * jacob);
perr = full(sqrt(diag(pcov)));

loc = popt(3) * 1000; %MHz
loc_err = perr(3) * 1000; %MHz
contrast = popt(1)/popt(4)*100;
width = popt(2) * 1000; %MHz
width_err = perr(2) * 1000; %MHz
fit_text = sprintf('Freqency = %.2f ± %.2f MHz\nContrast = %.1f %%\nWidth = %.2f ± %.2f MHz',...
    loc, loc_err, contrast, width, width_err);

hold(handles.axes2, 'on');

x_plot = linspace(x(1),x(end),301);
y_plot = lorentz(popt, x_plot);
plot(handles.axes2, x_plot, y_plot, 'DisplayName', fit_text)

if get(handles.bShowLegend,'Value')
    legend(handles.axes2, 'Location', 'best')
end
hold(handles.axes2, 'off');   

function PlotRabiData(handles,raw_j)
global gmSEQ

%dataN is number of counters
cmp = tab10(20);
colors = {cmp(1,:),cmp(2,:),cmp(3,:)};

for i = 1:gmSEQ.ctrN 
    plot(handles.axes2,...
        single(gmSEQ.SweepParam*gmSEQ.ScaleT),...
        single(gmSEQ.signal(i, :)),'-', ...
        'color', colors{i},...
        'LineWidth', 0.5,...
        'DisplayName', sprintf('signal %d', i))
    if i == 1
       hold(handles.axes2, 'on')
    end
end

grid on;
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);
xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);

if get(handles.bShowLegend,'Value')
    legend(handles.axes2)
end

% draw vertical dashed line to indicate where is the current measruement
xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes2, 'off')

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1)); %remove nan values
sig = signal(2,:);
ref = signal(1,:);
data = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;

errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data, data_err,...
    'LineStyle', '-', ...
    'Marker', 'o',...
    'Color', colors{3})
hold(handles.axes3, "on");
grid(handles.axes3, "on");
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Contrast');
xlabel(handles.axes3, gmSEQ.ScaleStr);
xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes3, "off")

function FitRabi(handles)
global gmSEQ
cmp = tab10(20);

signal = gmSEQ.signal(:, ~any(isnan(gmSEQ.signal), 1)); %remove nan values
sig = signal(2,:);
ref = signal(1,:);
data = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;

x = double(gmSEQ.SweepParam); %ns
y = data;

if length(x) == length(y)

func = @(p,x) p(1)*cos(2*pi*p(2)*x+p(3))+1-p(1);
% p1 is amp, p2 is freq, p3 phase


amp0 = max(y) - min(y);
%pi_0 = x(C == min(C));
pi0 = max(x)/4;
freq0 = 1/(2*pi0);
phi0 = -0.01;

p0 = [amp0, freq0, phi0];
lb = [0, 0, -pi/2];
ub = [1, inf, pi/2];

opts = optimoptions('lsqcurvefit', 'Display', 'off');
[popt, ~, ~, ~, ~, ~, jacob] = lsqcurvefit(func, p0, x, y, lb, ub, opts);
res = y - func(popt, x);
dof = length(y) - length(popt);
mse = sum(res.^2) / dof;
pcov = mse * inv(jacob' * jacob);
perr = full(sqrt(diag(pcov)));

phi = popt(3); %rad
phi_err = perr(3); %rad
contrast = popt(1)*2*100;
contrast_err = perr(1)*2*100;
freq = popt(2) * 1000; %MHz
freq_err = perr(2) * 1000; %MHz
piTime = (pi - phi)/(2*pi*popt(2));
% piTime_err = sqrt((1/(2*pi*popt(2)))^2*phi_err+((pi-phi)/(2*pi*popt(2)^2))^2*perr(2));
piTime_err = 1/(2*pi*popt(2))*sqrt(perr(3)^2 + (pi - phi)^2/(popt(2)^2)*perr(2)^2);
piHalfTime = (pi/2 - phi)/(2*pi*popt(2));
piHalfTime_err =  1/(2*pi*popt(2))*sqrt(perr(3)^2 + (pi/2 - phi)^2/(popt(2)^2)*perr(2)^2);
fit_text = sprintf('Pi Time = %.1f ± %.1f ns\nPi/2 Time = %.1f ± %.1f ns\nFreq = %.2f ± %.2f MHz\nC = %.1f ± %.1f%%',...
    piTime, piTime_err, piHalfTime, piHalfTime_err, freq, freq_err, contrast, contrast_err);

hold(handles.axes3, 'on');

x_plot = linspace(x(1),x(end),301);
y_plot = func(popt, x_plot);
plot(handles.axes3, x_plot*gmSEQ.ScaleT, y_plot, 'DisplayName', fit_text,...
    'Color', cmp(4,:), 'LineStyle', '-.')

if get(handles.bShowLegend,'Value')
    legend(handles.axes3, 'Location', 'best')
end
hold(handles.axes3, 'off');

end

function PlotT1Data(handles,raw_j)
global gmSEQ

%dataN is number of counters
cmp = tab10(10);
colors = {cmp(1,:),cmp(2,:),cmp(3,:),cmp(4,:),cmp(5,:),cmp(6,:)};
labels = ["S00","S01","S10","S11","RefB","RefD"];
ctrShow = [2,5,8,11];%S00, S01, S10, S11
refB_mean = (gmSEQ.signal(1, :)+gmSEQ.signal(4, :)+gmSEQ.signal(7, :)+gmSEQ.signal(10, :))/4;
refD_mean = (gmSEQ.signal(3, :)+gmSEQ.signal(6, :)+gmSEQ.signal(9, :)+gmSEQ.signal(12, :))/4;
ct = 1;
for i = ctrShow
    plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(gmSEQ.signal(i, :)),'-', ...
        'color', colors{ct},...
        'LineWidth', 0.5,...
        'DisplayName', labels(ct))
    
    if ct == 1; hold(handles.axes2, 'on'); end
    ct = ct + 1;
end

plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refB_mean),'-', ...
        'color', colors{5},...
        'LineWidth', 0.5,...
        'DisplayName', labels(5))
plot(handles.axes2,...
        single(gmSEQ.SweepParam)*gmSEQ.ScaleT,...
        single(refD_mean),'-', ...
        'color', colors{6},...
        'LineWidth', 0.5,...
        'DisplayName', labels(6))



grid on;
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, gmSEQ.ScaleStr);
xlim(handles.axes2, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);

% draw vertical dashed line to indicate where is the current measruement
xline(handles.axes2, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes2, 'off')

for jj = 1:length(gmSEQ.signal(:,1))
    signal(jj,:) = gmSEQ.signal(jj, ~isnan(gmSEQ.signal(jj,:)));
end

refB00 = signal(1,:);
sig00 = signal(2,:);
refD00 = signal(3,:);
refB01 = signal(4,:);
sig01 = signal(5,:);
refD01 = signal(6,:);
refB10 = signal(7,:);
sig10 = signal(8,:);
refD10 = signal(9,:);
refB11 = signal(10,:);
sig11 = signal(11,:);
refD11 = signal(12,:);

%S00-S01
sig = sig00 - sig01;
ref = (refB00+refB01)/2 - (refD00+refD01)/2;
data1 = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * ref);
sig_err = 1./sqrt(gmSEQ.iAverage * sig);
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data1_err = rel_err .* data1;


%S11-S10
sig = sig11 - sig10;
ref = (refB10+refB11)/2 - (refD10+refD11)/2;
data2 = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data2_err = rel_err .* data2;



errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data1, data1_err,...
    'LineStyle', '-',...
    'Marker', 'o',...
    'Color', cmp(7,:),...
    'DisplayName', 'S00-S01')
hold(handles.axes3, "on");
errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data2)).*gmSEQ.ScaleT, data2, data2_err,...
    'LineStyle', '-',...
    'Marker', 'square',...
    'Color', cmp(10,:),...
    'DisplayName', 'S11-S10')

grid(handles.axes3, "on");
set(handles.axes3,'FontSize',8);
ylabel(handles.axes3, 'Contrast');
xlabel(handles.axes3, gmSEQ.ScaleStr);
xlim(handles.axes3, [gmSEQ.SweepParam(1)*gmSEQ.ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*gmSEQ.ScaleT]);
xline(handles.axes3, single(gmSEQ.SweepParam(raw_j))*gmSEQ.ScaleT,'--', 'color','r','HandleVisibility','off')
hold(handles.axes3, "off")

if get(handles.bShowLegend,'Value')
    legend(handles.axes2, 'Location', 'best')
    legend(handles.axes3, 'Location', 'best')
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

