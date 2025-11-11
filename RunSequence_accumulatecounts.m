function RunSequence(hObject, eventdata, handles)
[y,Fs] = audioread('WindowsNotify.wav');
global gmSEQ gSG tmax
% CheckIfAlreadyRunning();
gmSEQ.bGo=0; pause(1); %this should stop any lingering RunFirstPoint
disp('Warming up AOM...')

RunFirstPointAndExit(hObject, eventdata, handles);

gmSEQ.bGo=1;
InitializeData(handles);


SignalGeneratorFunctionPool('SetIQ');
disp(strcat('Commencing ',{' '},string(gmSEQ.name), ' sequence...'))
if gSG.bfixedPow && gSG.bfixedFreq
    SignalGeneratorFunctionPool('WritePow');
    SignalGeneratorFunctionPool('WriteFreq');
    gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
    SequencePool(string(gmSEQ.name));
    [signal,reference] = CreateAndSetCounters();   
    
    for i=1:gmSEQ.Average
        gmSEQ.iAverage=i;
        handles.biAverage.String=num2str(gmSEQ.iAverage);
        for j=1:gmSEQ.NSweepParam
            gmSEQ.m=gmSEQ.SweepParam(j);
            SequencePool(string(gmSEQ.name));
            DrawSequence(gmSEQ,hObject, eventdata, handles.axes1);
            for k=1:numel(gmSEQ.CHN)
                gmSEQ.CHN(k).T=gmSEQ.CHN(k).T/1e9;
                gmSEQ.CHN(k).DT=gmSEQ.CHN(k).DT/1e9;
                gmSEQ.CHN(k).Delays=gmSEQ.CHN(k).Delays/1e9;
            end
            PBFunctionPool('PreprocessPBSequence',gmSEQ); % todo: account for ns
            StartCounters(signal,reference);

            Run_PB_Sequence();
            pause(gmSEQ.Repeat*tmax/1e9*1.1);
            ExperimentFunctionPool('PBOFF',hObject, eventdata, handles);
            [sigDatum, refDatum] = ReadCounters(signal,reference);
            if i==1
                gmSEQ.signal(j)=sigDatum;
                gmSEQ.reference(j)=refDatum(1);
                if gmSEQ.bCtr2
                    gmSEQ.reference2(j)=refDatum(2);
                end
            else
                gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;
                if gmSEQ.bCtr2
                    gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;
                end
            end
            % save a backup of the data here in case matlab crashes
            PlotData(handles);
            drawnow;
            if ~gmSEQ.bGo
                break
            end
        end
        if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
            break
        end
    end
    ClearCounters(signal,reference);

elseif isfield(gmSEQ,'bLiO')   
    gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
    SequencePool(string(gmSEQ.name));
    NRead = 2;
    dt=gmSEQ.misc/NRead;
    TimeOut = dt * NRead * 1.1;
    Freq = 1/dt;
    hCounter = SetCounter(NRead+1);
    [~, hPulse] = DigPulseTrainCont(Freq,0.5,10000);
    PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
    SignalGeneratorFunctionPool('WritePow');
    gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
    for i=1:gmSEQ.Average
        for j=1:gmSEQ.NSweepParam
            gSG.Freq=gmSEQ.SweepParam(j);
            SignalGeneratorFunctionPool('WriteFreq');
            status = DAQmxStartTask(hCounter);  DAQmxErr(status);
            status = DAQmxStartTask(hPulse);    DAQmxErr(status);

            DAQmxWaitUntilTaskDone(hCounter,TimeOut);

            DAQmxStopTask(hPulse);

            A = ReadCounter(hCounter,NRead+1);
            DAQmxStopTask(hCounter);
            A = diff(A);
            sigDatum=sum(A)/(NRead * dt);
            
            if i==1
                gmSEQ.signal(j)=sigDatum;
            else
                gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
            end
            PlotData(handles);
            drawnow;
            if ~gmSEQ.bGo
                break
            end
        end
        if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
            break
        end
    end
    DAQmxClearTask(hPulse);
    DAQmxClearTask(hCounter);
    ExperimentFunctionPool('PBOFF',hObject, eventdata, handles);
elseif gSG.bfixedPow && ~gSG.bfixedFreq
    SignalGeneratorFunctionPool('WritePow');
    gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
    [signal,reference] = CreateAndSetCounters();   
    SequencePool(string(gmSEQ.name));
    DrawSequence(gmSEQ,hObject, eventdata, handles.axes1);
    for k=1:numel(gmSEQ.CHN)
        gmSEQ.CHN(k).T=gmSEQ.CHN(k).T/1e9;
        gmSEQ.CHN(k).DT=gmSEQ.CHN(k).DT/1e9;
        gmSEQ.CHN(k).Delays=gmSEQ.CHN(k).Delays/1e9;
    end
    gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
    for i=1:gmSEQ.Average
        gmSEQ.iAverage=i;
        handles.biAverage.String=num2str(gmSEQ.iAverage);
        for j=1:gmSEQ.NSweepParam
            gSG.Freq=gmSEQ.SweepParam(j);
            SignalGeneratorFunctionPool('WriteFreq');

            PBFunctionPool('PreprocessPBSequence',gmSEQ); % todo: account for ns
            
            DAQmxStartTask(signal);
            DAQmxStartTask(reference);     
            Run_PB_Sequence();
            pause(gmSEQ.Repeat*tmax/1e9*1.1);
            sigDatum=DAQmxFunctionPool('ReadCounterScalar',signal);
            refDatum=DAQmxFunctionPool('ReadCounterScalar',reference);
            if i==1
                gmSEQ.signal(j)=sigDatum;
                gmSEQ.reference(j)=refDatum;
            else
                gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum)/i;
            end
            % save a backup of the data here in case matlab crashes
            PlotData(handles);
            drawnow;
            if ~gmSEQ.bGo
                break
            end
        end
        if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
            break
        end
    end
    DAQmxClearTask(signal);
    DAQmxClearTask(reference);
end
gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
gmSEQ.bGo=0;
disp('Experiment completed!')
sound(y,Fs);
%SaveData;

function InitializeData(handles)

global gmSEQ

gmSEQ.Repeat=str2double(get(handles.Repeat,'String'));


if get(handles.bAverage,'Value')
    gmSEQ.Average=str2double(get(handles.Average,'String'));
else
    gmSEQ.Average=1;
end

gmSEQ.SweepParam=gmSEQ.From:(gmSEQ.To-gmSEQ.From)/(gmSEQ.N-1):gmSEQ.To;
gmSEQ.NSweepParam=length(gmSEQ.SweepParam);

gmSEQ.signal=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference2=NaN(1,gmSEQ.NSweepParam);
gmSEQ.bGo=1;
gmSEQ.bGoAfterAvg=1;


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

function [signal, reference]=CreateAndSetCounters()
% Initialize DAQ
global gmSEQ
[ status, ~, signal ] = DAQmxCreateTask([]);
DAQmxErr(status);

[ status, ~, reference(1) ] = DAQmxCreateTask([]);
DAQmxErr(status);

DAQmxFunctionPool('SetGatedCounter',signal,'Dev1/ctr0','/Dev1/PFI8','/Dev1/PFI9');
DAQmxFunctionPool('SetGatedCounter',reference(1),'Dev1/ctr1','/Dev1/PFI8','/Dev1/PFI4');

gmSEQ.bCtr2=0;
ctr2=SequencePool('PBDictionary','ctr2');
for i=1:numel(gmSEQ.CHN)
    if gmSEQ.CHN(i).PBN==ctr2
        [ status, ~, reference(2) ] = DAQmxCreateTask([]);
        DAQmxErr(status);
        gmSEQ.bCtr2=1;
        DAQmxFunctionPool('SetGatedCounter',reference(2),'Dev1/ctr2','/Dev1/PFI8','/Dev1/PFI6');
        break
    end
end


function PlotData(handles)
global gmSEQ ScaleT ScaleStr

%axes(handles.axes2); %cla;
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference),'-b','LineStyle','--')
hold(handles.axes2, 'on')
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.signal),'-r')
if gmSEQ.bCtr2
    plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference2),'-m','LineStyle','--')
end
 set(handles.axes2,'FontSize',8);
 ylabel(handles.axes2, 'Fluorescence counts');
 xlabel(handles.axes2, ScaleStr);
 xlim(handles.axes2, [gmSEQ.SweepParam(1)*ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*ScaleT]);
hold(handles.axes2, 'off')

if ~isfield(gmSEQ,'bLiO')
    %axes(handles.axes3);% cla;
    if gmSEQ.bCtr2
        data=(gmSEQ.signal(~isnan(gmSEQ.signal))-gmSEQ.reference2(~isnan(gmSEQ.reference2)))./(gmSEQ.reference(~isnan(gmSEQ.reference))-gmSEQ.reference2(~isnan(gmSEQ.reference2)));
    else
        data=gmSEQ.signal(~isnan(gmSEQ.signal))./gmSEQ.reference(~isnan(gmSEQ.reference));
    end
    
    plot(handles.axes3, gmSEQ.SweepParam(1:length(data)).*ScaleT,data,'-g')
    set(handles.axes3,'FontSize',8);
    ylabel(handles.axes3, 'Fluorescence contrast');
    xlabel(handles.axes3, ScaleStr);
    xlim(handles.axes3, [gmSEQ.SweepParam(1)*ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*ScaleT]);
end

function [ValidCMD] = ValidateCMD(CMD,ClockTime)
% checks the CMD structure for erroneously short instruction delays due to
% rounding errors in building the pulse sequence via matlab
a = 1;

for k=1:size(CMD,1)
    if CMD{k,4} > 1 %1 ns is the minimum time
        
        if CMD{k,4} < (1e9*5*ClockTime) % if we find a short delay, we must implement it
            %warning('Pulse Blaster Sequence specified needs short delays.  This is not yet implemented!');
            
            % SHORT DELAY PRIMER
            % jhodges, 18 July 2008
            %
            % By setting bits 21-23 on the pulse blaster we can invoke
            % delays that are shorter than the minimum instruction time for
            % a CONTINUE command (5 clock cycles)
            %
            % SHORT Delays only work for the 4 BNC lines on the output of
            % the pulse blaster.  These correspond to PB0 - PB3, or bits
            % 0 - 3.  You cannot specify which of the 4 BNCs drive high.
            
            % Note that the flags should be set such that bits 21-23 are
            % only set high when the BNCs are in use and should be set to
            % 000 = 0xE00000 when the lines are not in use
            %
            % The following code, which will run in the Spin Core Pulse Interpreter,\
            % has these possible behaviors:
            % 0xFFFFFF, 500ns, LOOP, 100000 //start loop
            % 0x*00000, 100ns //all lines low
            % 0x600008, 20ns // Bit3 short pulse, 3 clock cycles
            % 0x000008, 100ns //all lines low again
            % 0x000000, 100ns, END_LOOP
            % 0x000000, 100ns
            % 0x000000, 100ns, STOP
            %
            % If *=E, that is setting all bits high, then the instruction
            % on the third line does not produce only 3 clock cycles on bit
            % 3, but produces and extra pulse
            %
            % If *=0, the pulse program works as expected with a short, 3
            % cycle pulse on bit3
            
            
            % Short delays should already be CONTINUE commands from the
            % preceeding logic
            Delay = CMD{k,4};
            ClockPeriods = round(Delay/ClockTime/1e9);
            % find the binary representation of ClockPeriods
            CPBinary = dec2bin(ClockPeriods,3);
            CPBinary = CPBinary(length(CPBinary)-2:end);
            ShortBitFlag = 2^21*str2num(CPBinary(3)) + ...
                2^22*str2num(CPBinary(2)) + ...
                2^23*str2num(CPBinary(1));
            
            % now we bit-wise or the ShortBitFlags with the original
            % instruction
            CMD{k,1} = bitor(CMD{k,1},ShortBitFlag);
            CMD{k,2} = 'CONTINUE';
            CMD{k,4} = 6*1e9*ClockTime;
            CMD{k,5} = ' '; %flag option should be null
        else
            CMD{k,5} = 'ON'; % ON sets bits 21-23 high
        end
        
        % Due to a peculiarity in the PB to CMD logic, we can end up
        % having LONG_DELAY types with only 1 multiplier.  These should be
        % made into continue delays
        if strcmp(CMD{k,2},'LONG_DELAY') && CMD{k,3} == 1
            CMD{k,2} = 'CONTINUE';
            CMD{k,3} = 0;
        end
        
        % Update the ValidCMD with this CMD
        for kk=1:size(CMD,2),
            ValidCMD{a,kk} = CMD{k,kk};
        end
        a = a+1;
    end
end
function Load_PB_Sequence()

global gmSEQ

ClockTime = 1/500e6;


CMD = ValidateCMD(gmSEQ,ClockTime);


s = CMD2PBI(CMD);
Ncmd = size(CMD,1);

PBesrInit(); %initialize PBesr

% sets the clock frequency. for PBESR-PRO-400, it's 400MHz
% for PBESR-PRO-333, it's 333.3MHz
PBesrSetClock(500);

PBesrStartProgramming(); % enter the programming mode

% Loop over all commands
for cmd = 1:Ncmd
    flag = CMD{cmd,1};
    flag_option = CMD{cmd,5};
    inst = char(CMD{cmd,2});
    inst_arg = CMD{cmd,3};
    length = CMD{cmd,4};
    % give the instruction to the PB
    PBstatus = PBesrInstruction(flag, flag_option, inst, inst_arg, length);
    if PBstatus < 0
        warning('Invalid PulseBlaster Instruction (Line %d)\nCMD = [%d]\t[%s]\t[%d]\t[%g]\t[%s]',cmd,flag,inst,inst_arg,length,flag_option);
    end
end

% Last command is to stop the outputs
flag = 0; % set all lines low
PBesrInstruction(flag, flag_option, 'CONTINUE', 0, 100);
PBesrInstruction(flag, flag_option, 'STOP', 0, 100);

PBesrStopProgramming(); % exit the programming mode

PBesrClose(); %close PBesr
%set status to 0, implement in the future

status = 0;


function task = SetCounter(N)
DAQmx_Val_Volts= 10348; % measure volts
DAQmx_Val_Rising = 10280; % Rising
DAQmx_Val_FiniteSamps = 10178; % Finite Samples
DAQmx_Val_CountUp = 10128; % Count Up
DAQmx_Val_CountDown = 10124; % Count Down
DAQmx_Val_GroupByChannel = 0; % Group per channel
DAQmx_Val_ContSamps =10123; % Continuous Samples

[ status, ~, task ] = DAQmxCreateTask([]);

DAQmxErr(status);
status = DAQmxCreateCICountEdgesChan(task,'Dev1/ctr0','',...
    DAQmx_Val_Rising , 0, DAQmx_Val_CountUp);

DAQmxErr(status);
status = DAQmxCfgSampClkTiming(task,'/Dev1/PFI13',1.0,...
    DAQmx_Val_Rising,DAQmx_Val_FiniteSamps ,N);
DAQmxErr(status);

function readArray = ReadCounter(task,N)
numSampsPerChan = N;
timeout = 0;
%readArray = libpointer('int64Ptr',zeros(1,N));
readArray = zeros(1,N);
arraySizeInSamps = N;
sampsPerChanRead = libpointer('int32Ptr',0);

[status, readArray]= DAQmxReadCounterF64(task, numSampsPerChan,...
    timeout, readArray, arraySizeInSamps, sampsPerChanRead );
DAQmxErr(status);

function StartCounters(signal,reference)
global gmSEQ
    DAQmxStartTask(signal);
    DAQmxStartTask(reference(1));
    if gmSEQ.bCtr2
        DAQmxStartTask(reference(2));
    end

function [sigDatum, refDatum] = ReadCounters(signal,reference)
global gmSEQ
    
    refDatum(1)=DAQmxFunctionPool('ReadCounterScalar',reference(1));
    if gmSEQ.bCtr2
        refDatum(2)=DAQmxFunctionPool('ReadCounterScalar',reference(2));
    end
    sigDatum=DAQmxFunctionPool('ReadCounterScalar',signal);
function ClearCounters(signal,reference)
global gmSEQ
    DAQmxClearTask(signal);
    DAQmxClearTask(reference(1));
    if gmSEQ.bCtr2
        DAQmxClearTask(reference(2));
    end
% function CheckIfAlreadyRunning
% global gmSEQ
% if gmSEQ.bGo
% 	return
% end
function RunFirstPointAndExit(hObject, eventdata, handles)
global gSG gmSEQ
ExperimentFunctionPool('LoadSEQ',hObject, eventdata, handles, handles.axes1)
gmSEQ.bGo=1;
SignalGeneratorFunctionPool('SetIQ');
if isfield(gmSEQ,'bLiO')   
    PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
    SignalGeneratorFunctionPool('WritePow');
    gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
    gSG.Freq=gmSEQ.m;
    SignalGeneratorFunctionPool('WriteFreq');
    while gmSEQ.bGo
        pause(.1);
        drawnow;
    end
else
    %if gSG.bfixedPow && gSG.bfixedFreq
    SignalGeneratorFunctionPool('WritePow');
    SignalGeneratorFunctionPool('WriteFreq');
    gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
    for k=1:numel(gmSEQ.CHN)
        gmSEQ.CHN(k).T=gmSEQ.CHN(k).T/1e9;
        gmSEQ.CHN(k).DT=gmSEQ.CHN(k).DT/1e9;
        gmSEQ.CHN(k).Delays=gmSEQ.CHN(k).Delays/1e9;
    end
    gmSEQ.Repeat=1e6;
    for j=1:4
        PBFunctionPool('PreprocessPBSequence',gmSEQ);
        Run_PB_Sequence;
        for i=1:5
            pause(1);
        end
    end
end
    gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
    ExperimentFunctionPool('PBOFF',hObject, eventdata, handles);
%SaveData;