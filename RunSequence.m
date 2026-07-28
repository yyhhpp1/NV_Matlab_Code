function RunSequence(hObject, eventdata, handles)
%[y,Fs] = audioread('ExptCompleted.mp3');
BackupFile = 'C:\MATLAB_Code\Data\TempDataBackup\Temp.mat';
global gmSEQ gSG tmax hCPS gSG2 gSG3 fpga

% Ensure the detector is set (normally done in Initialize). RunSequence routes
% on this, so guarantee it exists even if Initialize order/state differs.
if ~isfield(gmSEQ,'meas') || isempty(gmSEQ.meas)
    gmSEQ.meas = PortMap('meas');
end

%%% init fpga
%connect to fpga if not already connected
% Skip the FPGA preamble when FPGA is disabled (InstrumentEnabled) or for
% HeliCam widefield (hc_*) runs, which never use the FPGA.
if InstrumentEnabled('fpga') && ~strcmp(gmSEQ.meas,'HeliCam')
    Set_FPGA_GUI_buttons(handles, 'on')
    if isempty(fpga.client_socket)
        fpga = FPGA_AWG_Client(handles);
        msg = fpga.connect(PortMap('FPGA Host'),PortMap('FPGA Port'));
        handles.fpga_ack_str.String = msg;
    end

    fpga.delete_all_envelope_data();
    fpga.delete_all_waveform_cfg();
    fpga.delete_all_programs();
    % set trigger
    fpga.set_trigger_mode('external');
end


% default setting
gmSEQ.bRaman = 0;
gmSEQ.bGo = 1;
gmSEQ.bExp = 1; % experiment status tag
getUserInputFromGUI(handles);
SequencePool(string(gmSEQ.name))
InitializeData(handles);


disp(strcat('Commencing ',{' '},string(gmSEQ.name), ' sequence...'))
set(handles.runningText,'string','Running')
drawnow;

% HeliCam widefield lock-in detector: image-based acquisition path.
% Diverts from the NI-DAQ counter branches below (no ctr0 / ReadCountersN).
if strcmp(gmSEQ.meas,'HeliCam')
    RunSequence_HeliCam(hObject, eventdata, handles);
    return
end

gmSEQ.bRandom = 0;  % Shuffle the input, added by Weijie 04/20/2022

if gSG.bfixedFreq % pulsed sequence (supports fixed-power and swept-power)
    CreateSavePath_Ave()
    
    %gmSEQ.bTomo = gmSEQ.Alternate;
    gmSEQ.bTomo = 0;
    if gmSEQ.bTomo
        gmSEQ.dataN = gmSEQ.Ntomo*gmSEQ.ctrN;
        disp("Tomographical measurement ongoing...")
    else
        gmSEQ.dataN = gmSEQ.ctrN;
    end
    
    numPDChan=0;
    if gmSEQ.measPD
        if strcmp(gmSEQ.meas2,'PD0')
            numPDChan = numPDChan+1;
        end
        if strcmp(gmSEQ.meas3,'PD1')
            numPDChan = numPDChan+1;
        end
    end
    
    %append the voltage data to the counts data. Hence we need to expand
    %the counts array by the corresponding voltage channels to read.
    %TODO: store voltage data to a separate file
    gmSEQ.signal_Ave = NaN(gmSEQ.dataN*(numPDChan+1), gmSEQ.NSweepParam);
    gmSEQ.signal = NaN(gmSEQ.dataN*(numPDChan+1), gmSEQ.NSweepParam);
    
    %%% if use fpga this is not needed, freq and amp will be imported
    %%% through the sequence_name.m
    %%% TODO: add a button for turning on the FPGA. If using FPGA, skip the
    %%% following lines
    gmSEQ.refCounts=Track('Init');
    
    SignalGeneratorFunctionPool('SetMod');
    SignalGeneratorFunctionPool('WritePow');
    SignalGeneratorFunctionPool('WriteFreq');
    if startsWith(gmSEQ.name, 'f_')
       gSG.bOn = 0;
    else
       gSG.bOn = 1;
    end
    SignalGeneratorFunctionPool('RFOnOff');
    
    if handles.useSG2.Value
        SignalGeneratorFunctionPool2('SetMod');
        SignalGeneratorFunctionPool2('WritePow');
        SignalGeneratorFunctionPool2('WriteFreq');
        if startsWith(gmSEQ.name, 'f_')
            gSG2.bOn = 0;
        else
            gSG2.bOn = 1;
        end
        SignalGeneratorFunctionPool2('RFOnOff');
    end
    
    SignalGeneratorFunctionPool3('SetMod');
    SignalGeneratorFunctionPool3('WritePow');
    SignalGeneratorFunctionPool3('WriteFreq');
    if startsWith(gmSEQ.name, 'f_')
        gSG3.bOn = 0;
    else
        gSG3.bOn = 1;
    end
    SignalGeneratorFunctionPool3('RFOnOff');
    
    
    CreateCaliLog(hObject, eventdata, handles);
    
    if gmSEQ.bRandom
        disp("Random measurement ongoing...")
    end
    
    try
        Set_FPGA_GUI_buttons(handles, 'off')
        %DAQmxResetDevice('Dev1');
        [~, hCounter0] = SetNCounters(0,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        %         [~, hCounter1] = SetNCounters(1,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        %         [~, hCounter2] = SetNCounters(2,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        %         [~, hCounter3] = SetNCounters(3,1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000);
        if gmSEQ.measPD
            [~, hCounterPD0] = SetPDCounters([],1*gmSEQ.ctrN*gmSEQ.Repeat,PortMap('Ctr Gate'),500000,numPDChan);
        end
        
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
                Calibration(hObject, eventdata, handles)
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
                        gSG3.Pow = gmSEQ.SweepParam(j);
                        SignalGeneratorFunctionPool3('WritePow');
                    end

                    % Power sweep should be displayed directly in dBm.
                    if strcmp(gmSEQ.name, 'PiCal') || strcmp(gmSEQ.name, 'PiCal_SG2') || strcmp(gmSEQ.name, 'CaliPi')
                        gmSEQ.ScaleT = 1;
                        gmSEQ.ScaleStr = 'dBm';
                    end
                end
                
                if gmSEQ.bTomo
                    for axis = 0:gmSEQ.Ntomo-1
                        gmSEQ.CoolSwitch = axis;
                        SequencePool(string(gmSEQ.name));
                        DrawSequence(gmSEQ,hObject, eventdata, handles.axes1);
                        for k=1:numel(gmSEQ.CHN)
                            gmSEQ.CHN(k).T=gmSEQ.CHN(k).T/1e9;
                            gmSEQ.CHN(k).DT=gmSEQ.CHN(k).DT/1e9;
                            gmSEQ.CHN(k).Delays=gmSEQ.CHN(k).Delays/1e9;
                        end
                        PBFunctionPool('PreprocessPBSequence',gmSEQ); % todo: account for ns
                        
                        %%%
                        StartCounters(hCounter);
                        Run_PB_Sequence();
                        [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                        DAQmxStopTask(hCounter);
                        %%%
                        
                        sigDatum = ProcessData(vec);
                        for k = 1:gmSEQ.ctrN
                            gmSEQ.signal_Ave(gmSEQ.ctrN*axis + k, j) = sigDatum(k);
                            if i == 1
                                gmSEQ.signal(gmSEQ.ctrN*axis + k, j) = sigDatum(k);
                            else
                                gmSEQ.signal(gmSEQ.ctrN*axis + k, j) = (gmSEQ.signal(gmSEQ.ctrN*axis + k, j)*(i-1)+sigDatum(k))/i;
                            end
                        end
                    end
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
                    fpga.start_program(string(gmSEQ.name));
                    %handles.fpga_ack_str = msg;
                    pause(0.1)
                    Run_PB_Sequence();
                    
                    [~, vec0] = ReadCountersN(hCounter0,(1*gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                    if gmSEQ.measPD;[~, vec1] = ReadCountersPD(hCounterPD0,(1*gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5,numPDChan);end
                    %                     [~, vec2] = ReadCountersN(hCounter2,(1*gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                    %                     [~, vec3] = ReadCountersN(hCounter3,(1*gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*1.5);
                    DAQmxStopTask(hCounter0);
                    
                    %%% fpga stop program
                    pause(0.1)
                    
                    fpga.stop_program();
                    if gmSEQ.measPD;DAQmxStopTask(hCounterPD0);end
                    %                     DAQmxStopTask(hCounter2);
                    %                     DAQmxStopTask(hCounter3);
                    %%%
                    
                    %vec = [0 0 0];
                    sigDatum0 = ProcessData(vec0);
                    %                     sigDatum2 = ProcessData(vec2);
                    %                     sigDatum3 = ProcessData(vec3);
                    %                     sigDatum = sigDatum0+sigDatum1+sigDatum2+sigDatum3;
                    
                    %process PD voltage data acquired
                    if gmSEQ.measPD
                        sigVoltDatum = NaN(numPDChan,gmSEQ.ctrN);
                        for iPD = 1:numPDChan
                            sigVoltProcessing = vec1(1+(gmSEQ.ctrN*gmSEQ.Repeat)*(iPD-1):(gmSEQ.ctrN*gmSEQ.Repeat)*iPD);
                            for ic = 1:gmSEQ.ctrN
                                sigVoltDatum(iPD,ic)=sum(sigVoltProcessing(ic:gmSEQ.ctrN:end))/(length(sigVoltProcessing)/gmSEQ.ctrN); %store the average voltage across "repeats"
                            end                       
                            
                            %store voltage data
                            for k = 1:gmSEQ.ctrN
                                data_index = k+iPD*gmSEQ.ctrN; %the index of the data in the stored data
                                gmSEQ.signal_Ave(data_index, j) = sigVoltDatum(iPD,k);
                                if i == 1
                                    gmSEQ.signal(data_index, j) = sigVoltDatum(iPD,k);
                                else
                                    gmSEQ.signal(data_index, j) = (gmSEQ.signal(data_index, j)*(i-1)+sigVoltDatum(iPD,k))/i;
                                end
                            end
                        end
                    end
                    
                    
                    sigDatum = sigDatum0;
                    for k = 1:gmSEQ.ctrN
                        gmSEQ.signal_Ave(k, j) = sigDatum(k);
                        if i == 1
                            gmSEQ.signal(k, j) = sigDatum(k);
                        else
                            gmSEQ.signal(k, j) = (gmSEQ.signal(k, j)*(i-1)+sigDatum(k))/i;
                        end
                    end
                    
                    if gmSEQ.saveRaw
                        csvwrite('D:\RawData.csv', mean(gmSEQ.signal,2));
                    end
                    
                    

                end
                
                % save a backup of the data here in case matlab crashes
                TemporarySave(BackupFile);
                if gmSEQ.ctrN<=30 %do not plot if too many counter gates              
                    if strcmp(gmSEQ.name, 'T1_S00_S01_S10_S11_darkRef')
                        PlotT1Data(handles,raw_j)
                    elseif strcmp(gmSEQ.name, 'T1_S00_S01_S10_S11_S1m1')
                        PlotT1Data_method2(handles,raw_j)
                    elseif strcmp(gmSEQ.name, 'T1_S11_S1m1')||strcmp(gmSEQ.name, 'T1_S11_S1m1_shelving')||strcmp(gmSEQ.name, 'T1_S11_S1m1_drive_1m1')
                        PlotT1Data_method3(handles,raw_j)
                    elseif strcmp(gmSEQ.name, 'T1_S00_S01_S10')||strcmp(gmSEQ.name, 'T1_S00_S01_S10_spectator_noise')||strcmp(gmSEQ.name, 'T1_S00_S01_S10_shelving')
                        PlotT1Data_method4(handles,raw_j)
                    elseif strcmp(gmSEQ.name, 'T1_S00_S10_Sm10')   % average the three curves to get charge decay
                        PlotT1DataAveCharge(handles,raw_j)  
%                     elseif strcmp(gmSEQ.name, 'T1_S00_S10_Sm10_fdc')   % average the three curves to get charge decay
%                         PlotT1DataAveChargeFDC(handles,raw_j)
                    elseif strcmp(gmSEQ.name, 'T1_charge_calib')
                        PlotT1DataOnlyCharge(handles,raw_j)
                    elseif strcmp(gmSEQ.name, 'Rabi')||strcmp(gmSEQ.name, 'Rabi_1m1')||strcmp(gmSEQ.name, 'Rabi_SG2')||strcmp(gmSEQ.name, 'Rabi_SG3')||strcmp(gmSEQ.name, 'Rabi_composite')
                        PlotRabiData(handles,raw_j)
                        if get(handles.bShowLegend,'Value')
                            FitRabi(handles);
                        end
                    elseif strcmp(gmSEQ.name, 'T1_Sij_all')
                        PlotT1Data_9curves(handles, raw_j)
                    else
                        PlotData(handles,raw_j);
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
            
            if handles.bSlackUpload.Value
                save_and_upload_GUI_figure(handles, 'Current sequence is still running.')
            end
            
            if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                break
            end
        end
        Set_FPGA_GUI_buttons(handles, 'on');
        ClearCounters(hCounter0);
        if gmSEQ.measPD;ClearCounters(hCounterPD0);end
        %         ClearCounters(hCounter2);
        %         ClearCounters(hCounter3);
    catch ME
        KillAllTasks; %kill all niDAQ tasks
        set(handles.runningText,'string','Error!')
        gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
        gSG3.bOn=0; SignalGeneratorFunctionPool3('RFOnOff');
        if handles.useSG2.Value; gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff'); end
        fpga.stop_program();
        Set_FPGA_GUI_buttons(handles, 'on')
        %turn on laser
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM'));
        rethrow(ME);
    end
    if gmSEQ.bTrack
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
    end
    if handles.bSlackUpload.Value
        save_and_upload_GUI_figure(handles, 'Current sequence is finished.')
    end
    
    
elseif isfield(gmSEQ,'bLiO')   % activates for ESR
    CreateSavePath_Ave()
    gmSEQ.dataN = gmSEQ.ctrN;
    gmSEQ.signal_Ave = NaN(gmSEQ.dataN, gmSEQ.NSweepParam);
    gmSEQ.signal = NaN(gmSEQ.dataN, gmSEQ.NSweepParam);
    gmSEQ.refCounts=Track('Init');
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
            status = DAQmxStartTask(hScan);  DAQmxErr(status);            
            status = DAQmxStartTask(hCounter);  DAQmxErr(status);
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
            %PlotData(handles,0);
            PlotESRData(handles);
            if get(handles.bShowLegend,'Value')
                FitESR(handles);
            end
            
            
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
        %turn on laser
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM'));
        rethrow(ME);
    end
    if ~gmSEQ.bTrack
        ExperimentFunctionPool('PBOFF',hObject, eventdata, handles);
    end
    gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
    
elseif gSG.bfixedPow && ~gSG.bfixedFreq % for ODMR
    % TODO: fix it for ODMR_1m1
    CreateSavePath_Ave()
    
    gmSEQ.refCounts=Track('Init');
    SignalGeneratorFunctionPool('SetMod');
    SignalGeneratorFunctionPool('WritePow');
    if startsWith(gmSEQ.name, 'f_')
       gSG.bOn = 0;
    else
       gSG.bOn = 1;
    end
    SignalGeneratorFunctionPool('RFOnOff');
    
    %%%%%%%%%%%%%%%%%%%
    
    if handles.useSG2.Value
        SignalGeneratorFunctionPool2('SetMod');
        SignalGeneratorFunctionPool2('WritePow');
        SignalGeneratorFunctionPool2('WriteFreq');
        if startsWith(gmSEQ.name, 'f_')
            gSG2.bOn = 0;
        else
            gSG2.bOn = 1;
        end
        SignalGeneratorFunctionPool2('RFOnOff');
    end
    
    SignalGeneratorFunctionPool3('SetMod');
    SignalGeneratorFunctionPool3('WritePow');
    SignalGeneratorFunctionPool3('WriteFreq');
    if startsWith(gmSEQ.name, 'f_')
        gSG3.bOn = 0;
    else
        gSG3.bOn = 1;
    end
    SignalGeneratorFunctionPool3('RFOnOff');
    
    %%%%%%%%%%
    
    gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
    CreateCaliLog(hObject, eventdata, handles);
    
    %gmSEQ.bTomo = gmSEQ.Alternate;
    gmSEQ.bTomo = 0; %tomograph measurement is depreicated on this setup
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
        %turn on laser
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM'));
        rethrow(ME);
    end
end

gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
if handles.useSG2.Value; gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff'); end
gSG3.bOn=0; SignalGeneratorFunctionPool3('RFOnOff');

% The following stop is just for test, added by Weijie 07/30/2022
% chaseFunctionPool('stopChase', gmSEQ.MWAWG)
% chaseFunctionPool('stopChase', gmSEQ.P1AWG)
% chaseFunctionPool('stopChase', gmSEQ.MWAWG2)


gmSEQ.bGo = 0;
gmSEQ.bExp = 0;
SaveIgorText(handles);

disp('Experiment completed!')
%turn on laser
PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM'));
set(handles.runningText,'string','Stopped')
%sound(y,Fs);

function RunSequence_HeliCam(hObject, eventdata, handles)
% Widefield lock-in acquisition with the HeliCam C4 (external DivideBy4).
% Image-based counterpart to the NI-DAQ branches: the camera is configured once,
% only the PulseBlaster timing changes per sweep point, and each burst yields
% per-pixel I/Q that form a contrast image. No ctr0 / ReadCountersN here.
global gmSEQ gSG gSG2 gCam gWide
BackupFile = 'C:\MATLAB_Code\Data\TempDataBackup\Temp.mat';

% Lazy backend init (robust to Initialize order / detector switch).
if isempty(gCam)
    cfg0 = WidefieldConfig();
    if cfg0.useFakeCamera
        gCam = FakeCamera(cfg0);
    else
        gCam = HeliCamInterface(cfg0.ifNo, cfg0.devNo);
    end
end

gmSEQ.bGo  = 1;
gmSEQ.bExp = 1;
gmSEQ.ctrN = 1;            % no NI-DAQ counter gate in widefield mode
CreateSavePath_Ave();

% --- Lock-in trigger budget -------------------------------------------------
% nFrames comes from the GUI Repeat field (>= 4, HeliCam minimum). One PB run of
% an hc_* sequence = one lock-in period (CamRef NRise=4 -> 4 quarter edges), so the
% PB loop count is exactly the number of periods the camera consumes. Average is
% the outer repeat of the whole acquisition.
cfgPB = WidefieldConfig();

% Demodulation periods averaged into each output frame. This was hardcoded to 1,
% which is the most demanding setting the camera can be given: one lock-in frame
% per reference period means a frame every 4*readout, i.e. ~2.5 kHz at readout =
% 100 us. Both vendor examples use 20-100 for good reason. Now configurable, and
% overridable from the GUI via gmSEQ.lockInNPeriods if that field is added.
nPeriodsSel = 1;
if isfield(cfgPB,'nPeriods') && ~isempty(cfgPB.nPeriods)
    nPeriodsSel = cfgPB.nPeriods;
end
if isfield(gmSEQ,'lockInNPeriods') && ~isempty(gmSEQ.lockInNPeriods)
    nPeriodsSel = gmSEQ.lockInNPeriods;
end
gmSEQ.nPeriods = max(1, min(100, round(nPeriodsSel)));   % camera range 1..100
gmSEQ.nFrames  = max(4, round(gmSEQ.Repeat));   % GUI Repeat -> nFrames

% PB runs exactly the periods the camera consumes -- no surplus. A surplus was
% carried for a while on the theory that a shortfall of even one edge would leave
% getBuffer waiting forever with no partial data; 20 consecutive acquisitions with
% zero surplus showed the camera does not need it. (gmSEQ.Repeat is re-read from
% the GUI by LoadUserInputs on every run, so overwriting it here does not
% accumulate.)
nBlankCfg = 0;
if isfield(cfgPB,'blankPeriods') && ~isempty(cfgPB.blankPeriods)
    nBlankCfg = cfgPB.blankPeriods;
end
% Periods the camera consumes: (nPeriods + blank) per frame, all nFrames frames.
nPeriodsNeeded = (gmSEQ.nPeriods + nBlankCfg) * gmSEQ.nFrames;
gmSEQ.nPBPeriods = nPeriodsNeeded;
% Set both: the root PBFunctionPool loops on SEQ.Repeat, the one in
% mytoolboxes/PulseBlaster loops on SEQ.Samples, and path order decides which
% runs. Keeping them equal makes the loop count correct either way.
gmSEQ.Repeat   = gmSEQ.nPBPeriods;
gmSEQ.Samples  = gmSEQ.nPBPeriods;

% Camera exposure tracks the GUI readout (= quarter-bin spacing), kept just
% below it by the sensor overhead so the configured reference frequency matches
% the actual PB quarter rate (otherwise the camera won't lock and readIQ times
% out). readout is in ns; camera exposure floor ~1.825 us.
overheadNs = 2000;                                  % ~2 us sensor busy overhead
if isfield(cfgPB,'sensorOverheadNs') && ~isempty(cfgPB.sensorOverheadNs)
    overheadNs = cfgPB.sensorOverheadNs;
end
expoNs = max(gmSEQ.readout - overheadNs, 1825);     % camera exposure floor 1.825 us
gmSEQ.exposureSeconds = expoNs * 1e-9;

fprintf(['[Widefield] Edge budget: camera needs %d periods ', ...
         '(%d frames x (%d+%d)) = %d CamRef edges; PB will run %d periods ', ...
         '= %d edges.\n'], nPeriodsNeeded, gmSEQ.nFrames, gmSEQ.nPeriods, ...
        nBlankCfg, 4*nPeriodsNeeded, gmSEQ.nPBPeriods, 4*gmSEQ.nPBPeriods);
% slack is 0 by construction (exposure = readout - overhead); it goes NEGATIVE
% only when readout is too short for the camera's 1.825 us exposure floor, which
% means the next CamRef edge lands while the sensor is still busy.
slackNs = gmSEQ.readout - expoNs - overheadNs;
fprintf(['[Widefield] Quarter bin = readout = %g ns; exposure = %g ns ', ...
         '(overhead %g ns, slack %g ns).\n'], ...
        gmSEQ.readout, expoNs, overheadNs, slackNs);
if slackNs < 0
    fprintf(2, ['[Widefield] WARNING: readout %g ns is too short -- the exposure ', ...
                'floor (1825 ns) plus overhead (%g ns) exceeds the quarter bin, so ', ...
                'the next CamRef edge arrives while the sensor is still busy. ', ...
                'Raise readout to at least %g ns.\n'], ...
            gmSEQ.readout, overheadNs, 1825 + overheadNs);
end

% Output frame rate the camera is being asked to sustain. One frame per
% nPeriods reference periods, each period = 4 quarter bins. With nPeriods = 1
% this is 1/(4*readout) -- 2.5 kHz at readout = 100 us, which may simply exceed
% what the sensor can emit. Raising nPeriods divides it down.
periodSeconds = 4 * gmSEQ.readout * 1e-9;
frameRateHz   = 1 / (gmSEQ.nPeriods * periodSeconds);
fprintf(['[Widefield] Reference period = %.4g s; %d periods/frame ', ...
         '-> %.4g frames/s, burst %.4g s for %d frames.\n'], ...
        periodSeconds, gmSEQ.nPeriods, frameRateHz, ...
        gmSEQ.nFrames * gmSEQ.nPeriods * periodSeconds, gmSEQ.nFrames);

% --- Configure camera once: WidefieldConfig hardware/display fields, with the
% per-run lock-in params taken from gmSEQ (populated by LoadUserInputs). ---
ccfg = WidefieldConfig();
ccfg.exposureSeconds      = gmSEQ.exposureSeconds;   % tracks readout, set above
ccfg.nPeriods             = gmSEQ.nPeriods;          % forced to 1 above
ccfg.nFrames              = gmSEQ.nFrames;
ccfg.sensitivity          = gmSEQ.sensitivity;
ccfg.coupling             = gmSEQ.coupling;
ccfg.referenceTimeShiftUs = gmSEQ.referenceTimeShiftUs;
gCam.configLockInMode(ccfg);

H = gCam.Height; W = gCam.Width; N = gmSEQ.NSweepParam;

% Frequency-swept sequences (e.g. hc_ODMR) use GHz on the GUI -> Hz, as ODMR does.
bFreqSweep = ~gSG.bfixedFreq;
if bFreqSweep
    gmSEQ.SweepParam = gmSEQ.SweepParam * 1e9;
end

% --- Result store (images, parallel to scalar gmSEQ.signal) ---
gWide = struct();
gWide.signal     = NaN(H, W, N);   % contrast = -mean(Q)./mean(I)
gWide.reference  = NaN(H, W, N);   % mean(I)
gWide.rawsignal  = NaN(H, W, N);   % -mean(Q)
gWide.SweepParam = gmSEQ.SweepParam;
gWide.name       = char(string(gmSEQ.name));

% Instrument switches (InstrumentEnabled.m). With SRS disabled, all MW source
% calls are skipped -- run hc_Image (needs no MW). hc_Rabi/T1/ODMR need the SRS.
srsOn = InstrumentEnabled('srs');
pbOn  = InstrumentEnabled('pulseblaster');

% --- MW source on (off for f_ sequences, mirroring the pulsed branch) ---
if srsOn
    SignalGeneratorFunctionPool('SetMod');
    SignalGeneratorFunctionPool('WritePow');
    if ~bFreqSweep
        SignalGeneratorFunctionPool('WriteFreq');
    end
    if startsWith(string(gmSEQ.name), 'f_'); gSG.bOn = 0; else; gSG.bOn = 1; end
    SignalGeneratorFunctionPool('RFOnOff');
end

roi = ccfg.roi;   % [] -> frame-center ROI for the 1-D trace

try
    for i = 1:gmSEQ.Average
        gmSEQ.iAverage = i;
        handles.biAverage.String = num2str(i);
        j = 1;
        while j <= N
            gmSEQ.m = gmSEQ.SweepParam(j);
            if bFreqSweep && srsOn
                gSG.Freq = gmSEQ.SweepParam(j);
                SignalGeneratorFunctionPool('WriteFreq');
            end

            % Program PulseBlaster for this point (emits the CamRef quarter train).
            SequencePool(string(gmSEQ.name));
            DrawSequence(gmSEQ, hObject, eventdata, handles.axes1);
            for k = 1:numel(gmSEQ.CHN)
                gmSEQ.CHN(k).T      = gmSEQ.CHN(k).T      / 1e9;
                gmSEQ.CHN(k).DT     = gmSEQ.CHN(k).DT     / 1e9;
                gmSEQ.CHN(k).Delays = gmSEQ.CHN(k).Delays / 1e9;
            end
            if pbOn
                PBFunctionPool('PreprocessPBSequence', gmSEQ);
            end

            % Acquire one lock-in burst.
            gCam.startAcq();
            if pbOn; Run_PB_Sequence(); end   % PB drives the CamRef quarter train
            [I, Q] = gCam.readIQ(ccfg.timeoutMs);
            gCam.stopAcq();

            ref      = mean(I, 3);
            sig      = -mean(Q, 3);
            contrast = sig ./ (ref + eps);

            if i == 1
                gWide.signal(:,:,j)    = contrast;
                gWide.reference(:,:,j) = ref;
                gWide.rawsignal(:,:,j) = sig;
            else
                gWide.signal(:,:,j)    = (gWide.signal(:,:,j)*(i-1)    + contrast) / i;
                gWide.reference(:,:,j) = (gWide.reference(:,:,j)*(i-1) + ref)      / i;
                gWide.rawsignal(:,:,j) = (gWide.rawsignal(:,:,j)*(i-1) + sig)      / i;
            end

            DisplayWidefield(handles, j, roi);

            TemporarySave(BackupFile);
            drawnow;
            if ~gmSEQ.bGo; break; end
            j = j + 1;
        end
        if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg; break; end
    end
catch ME
    try; gCam.stopAcq(); catch; end
    if InstrumentEnabled('nidaq'); try; KillAllTasks; catch; end; end
    if srsOn; gSG.bOn = 0; SignalGeneratorFunctionPool('RFOnOff'); end
    set(handles.runningText, 'string', 'Error!')
    if pbOn; PBFunctionPool('PBON', 2^SequencePool('PBDictionary','GreenAOM')); end
    rethrow(ME);
end

% --- Cleanup ---
if srsOn
    gSG.bOn = 0; SignalGeneratorFunctionPool('RFOnOff');
    if InstrumentEnabled('srs2') && isfield(handles,'useSG2') && handles.useSG2.Value
        gSG2.bOn = 0; SignalGeneratorFunctionPool2('RFOnOff');
    end
end
gmSEQ.bGo  = 0;
gmSEQ.bExp = 0;
if pbOn; PBFunctionPool('PBON', 2^SequencePool('PBDictionary','GreenAOM')); end
SaveWidefield();
set(handles.runningText, 'string', 'Stopped')
disp('Widefield experiment completed!')

function DisplayWidefield(handles, j, roi)
% DisplayWidefield(handles, j, roi)  Live widefield display for HeliCam runs.
%   axes2: image at sweep point j (contrast normally; raw intensity I for hc_Image)
%   axes3: ROI-mean of that quantity vs sweep parameter, built up through point j
% roi = [] -> frame-center square; else [xc yc halfwidth] in pixels.
global gmSEQ gWide

% hc_Image is laser-in-Q1-only, so contrast is ~0; show the I (reference) image.
isImageOnly = strcmp(char(string(gmSEQ.name)), 'hc_Image');
if isImageOnly
    stack = gWide.reference;   % I = Q1 image
    qty   = 'intensity (I)';
else
    stack = gWide.signal;      % contrast = rawsignal ./ reference
    qty   = 'contrast';
end

img = stack(:,:,j);
[H, W] = size(img);

% --- axes2: 2-D image ---
imagesc(handles.axes2, img);
axis(handles.axes2, 'image');
colorbar(handles.axes2);
title(handles.axes2, sprintf('%s @ %g %s', ...
    qty, gmSEQ.SweepParam(j)*gmSEQ.ScaleT, gmSEQ.ScaleStr));

% --- ROI box ---
if isempty(roi)
    cx = round(W/2); cy = round(H/2); hw = round(min(H,W)/10);
else
    cx = roi(1); cy = roi(2); hw = roi(3);
end
xr = max(1,cx-hw):min(W,cx+hw);
yr = max(1,cy-hw):min(H,cy+hw);
hold(handles.axes2, 'on');
rectangle(handles.axes2, 'Position', [xr(1) yr(1) numel(xr) numel(yr)], ...
    'EdgeColor', 'r', 'LineWidth', 1);
hold(handles.axes2, 'off');

% --- axes3: ROI-mean trace vs sweep ---
trace = squeeze(mean(mean(stack(yr,xr,:), 1), 2));
plot(handles.axes3, gmSEQ.SweepParam(1:j)*gmSEQ.ScaleT, trace(1:j), '-o');
xlabel(handles.axes3, gmSEQ.ScaleStr);
ylabel(handles.axes3, ['ROI ' qty]);
grid(handles.axes3, 'on');
if j > 1
    xlim(handles.axes3, sort([gmSEQ.SweepParam(1) gmSEQ.SweepParam(end)])*gmSEQ.ScaleT);
end

function SaveWidefield()
% SaveWidefield  Write the widefield run to a portable HDF5 (.h5) file.
% Stores reference (mean I) and rawsignal (-mean Q) only; contrast is derived
% on read as rawsignal ./ reference. Metadata: key scalars as root attributes
% plus the full gmSEQ as a JSON string (params_json). Written into the dated
% CreateSavePath_Ave folder with a collision-safe _### suffix.
global gmSEQ gSG gWide gSaveDataAve

if isempty(gWide) || ~isfield(gWide,'reference'); return; end

% Reuse the dated folder prepared by CreateSavePath_Ave, and take the date from
% the folder name rather than parsing gSaveDataAve.file. That field is built with
% strcat on gmSEQ.name, so it inherits gmSEQ.name's type -- when the sequence name
% is a string/cell it is a CELL, which propagated into stem and made sprintf
% throw. It also carries the _### suffix, which the old pattern never matched.
pth     = char(string(gSaveDataAve.path));
base    = regexprep(pth, '[\\/]+$', '');            % drop trailing separator
toks    = regexp(base, '[\\/]', 'split');
dateStr = toks{end};                                % '<YYYY-M-D>'
if isempty(dateStr)
    dateStr = datestr(datetime('now'), 'yyyy-mm-dd');
end
name = regexprep(char(string(gmSEQ.name)), '\W', '');
stem = char(fullfile(base, [name '_' dateStr '_WF']));

% Collision-safe suffix.
n = 1;
while exist(sprintf('%s_%03d.h5', stem, n), 'file'); n = n + 1; end
fname = sprintf('%s_%03d.h5', stem, n);

ref = gWide.reference;
raw = gWide.rawsignal;
sz  = size(ref);
if numel(sz) < 3; sz(3) = 1; end

% Datasets (chunked + gzip; chunk a single frame for partial reads).
chunk = [sz(1) sz(2) 1];
h5create(fname, '/reference',   sz, 'Datatype','double', 'ChunkSize',chunk, 'Deflate',4);
h5write (fname, '/reference',   ref);
h5create(fname, '/rawsignal',   sz, 'Datatype','double', 'ChunkSize',chunk, 'Deflate',4);
h5write (fname, '/rawsignal',   raw);
h5create(fname, '/sweep_param', [1 numel(gWide.SweepParam)], 'Datatype','double');
h5write (fname, '/sweep_param', gWide.SweepParam(:)');

% Root attributes: key scalars + full params as JSON.
h5writeatt(fname, '/', 'sequence',       char(string(gmSEQ.name)));
h5writeatt(fname, '/', 'sweep_unit',     gmSEQ.ScaleStr);
h5writeatt(fname, '/', 'derived',        'contrast = rawsignal ./ reference');
attrIf(fname, 'exposure_s',     gmSEQ, 'exposureSeconds');
attrIf(fname, 'n_periods',      gmSEQ, 'nPeriods');
attrIf(fname, 'n_frames',       gmSEQ, 'nFrames');
attrIf(fname, 'sensitivity',    gmSEQ, 'sensitivity');
attrIf(fname, 'quarter_bin_ns', gmSEQ, 'quarterBinNs');
attrIf(fname, 'average',        gmSEQ, 'Average');
if ~isempty(gSG) && isfield(gSG,'Pow');  h5writeatt(fname,'/','mw_power_dBm', gSG.Pow);  end
if ~isempty(gSG) && isfield(gSG,'Freq'); h5writeatt(fname,'/','mw_freq_Hz',   gSG.Freq); end
try
    h5writeatt(fname, '/', 'params_json', jsonencode(gmSEQ));
catch
    % jsonencode can choke on non-serializable fields; metadata loss is non-fatal.
end

fprintf('[Widefield] Saved %s\n', fname);

function attrIf(fname, attrName, s, field)
% Write s.(field) as a root attribute if the field exists and is non-empty.
if isfield(s, field) && ~isempty(s.(field))
    h5writeatt(fname, '/', attrName, s.(field));
end

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

if strcmp(gmSEQ.name, 'T1_S00_S01_S10_S11_darkRef')
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

function [status, task] = SetPDCounters(varargin)
% Initialize DAQ
global hCPS
[status, task ] = DAQmxFunctionPool('CreateAIChannel',varargin{3},varargin{2},varargin{4},varargin{5});
hCPS.hPDCounter0=task;

function PlotData(handles,raw_j)
global gmSEQ
%axes(handles.axes2); %cla;

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
    
    if gmSEQ.bTomo
        % Generalize version
        if gmSEQ.ctrN ~= 4
            error("This function has not been implemented.")
        end
        for i = 1:gmSEQ.Ntomo
            [data(i,:), data_err(i,:)] = ContrastDiff(signal(4*(i-1)+1,:), signal(4*(i-1)+3,:),...
                signal(4*(i-1)+2,:), signal(4*(i-1)+4,:), gmSEQ.iAverage);
            errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data(i,:))).*gmSEQ.ScaleT, data(i,:), data_err(i,:), ...
                'color', [(i-1)/(gmSEQ.Ntomo - 1), 0, 1-(i-1)/(gmSEQ.Ntomo - 1)], ...
                'DisplayName', num2str(i))
            hold(handles.axes3, 'on')
        end
        legend(handles.axes3)
        hold(handles.axes3, 'off')
    else
        if gmSEQ.ctrN==3
            if strcmp(gmSEQ.name,'T1JC')
                data=signal(1,:)-signal(2,:)./signal(3,:);
            else
                data=signal(1,:);
                data_err = zeros(size(data));
                % data=signal(1,:)-signal(3,:)./(signal(2,:)-signal(4,:));
            end
        elseif gmSEQ.ctrN==2
            if strcmp(gmSEQ.name,'Scan_CounterGate_time') || strcmp(gmSEQ.name,'f_CtrGateCali')
                sig = signal(2,:);
                ref = signal(1,:);
                data = (ref-sig)./ref.*sqrt(sig);        % contrast / noise in signal
                data_err =zeros(size(sig));
            else
                sig = signal(2,:);
                ref = signal(1,:);
                data = sig./ref;
                %data = ref-sig;
                ref_err = 1./sqrt(gmSEQ.iAverage * ref); % Relative error of reference
                sig_err = 1./sqrt(gmSEQ.iAverage * sig); % Relative error of signal
                rel_err = sqrt(ref_err.^2 + sig_err.^2);
                data_err = rel_err .* data;
            end
        elseif gmSEQ.ctrN==4
            if strcmp(gmSEQ.name,'Test_NV_Polarization') || strcmp(gmSEQ.name,'Special Cooling') || strcmp(gmSEQ.name,'Special Cooling_2') || strcmp(gmSEQ.name,'Special Cooling_P1_2_DurMeas')
                data = (signal(1,:)-signal(3,:))./(signal(2,:)+signal(4,:))*2;
            elseif strcmp(gmSEQ.name,'CtrDur') && gmSEQ.meas == "SPCM"
                data = -(signal(2,:)-signal(4,:))./sqrt((signal(1,:)+signal(3,:))/2);
                data_err = data .* 0;
            elseif strcmp(gmSEQ.name,'Elec_Pol_Extract') || strcmp(gmSEQ.name,'Rabi_fix_MWDutyCycle')
                sig1 = signal(2,:);
                ref1 = signal(1,:);
                data1 = sig1./ref1;
                ref_err1 = 1./sqrt(gmSEQ.iAverage * ref1); % Relative error of reference
                sig_err1 = 1./sqrt(gmSEQ.iAverage * sig1); % Relative error of signal
                rel_err1 = sqrt(ref_err1.^2 + sig_err1.^2);
                data_err1 = rel_err1 .* data1;
                
                sig2 = signal(4,:);
                ref2 = signal(3,:);
                data2 = sig2./ref2;
                ref_err2 = 1./sqrt(gmSEQ.iAverage * ref2); % Relative error of reference
                sig_err2 = 1./sqrt(gmSEQ.iAverage * sig2); % Relative error of signal
                rel_err2 = sqrt(ref_err2.^2 + sig_err2.^2);
                data_err2 = rel_err2 .* data2;
            elseif strcmp(gmSEQ.name,'T1_Rb_S00_S01_Rd')||strcmp(gmSEQ.name,'T1_Rb_S00_S01_Rd_newRef')
                % data = (gmSEQ.reference(~isnan(gmSEQ.reference))-gmSEQ.reference3(~isnan(gmSEQ.reference3)))./(gmSEQ.signal(~isnan(gmSEQ.signal))+gmSEQ.reference2(~isnan(gmSEQ.reference2)))*2;
                ref_B = signal(1,:);
                ref_D = signal(3,:);
                sig_B = signal(2,:);
                sig_D = signal(4,:);
                
                [data, data_err] = ContrastDiff(ref_B, ref_D,sig_B, sig_D, gmSEQ.iAverage);
            elseif strcmp(gmSEQ.name,'Echo')|| strcmp(gmSEQ.name,'Ramsey')
                ref_B = signal(1,:);
                ref_D = signal(3,:);
                sig_B = signal(2,:);
                sig_D = signal(4,:); 
                data = (sig_B - sig_D)*2./(ref_B + ref_D);
                data_err = data*0;
            elseif strcmp(gmSEQ.name,'Echo_wDarkRef')
                ref_B = signal(3,:);
                ref_D = signal(1,:);
                sig_B = signal(2,:);
                sig_D = signal(4,:); 
                data = (sig_B - sig_D)./(ref_B - ref_D);
                N =  gmSEQ.iAverage;
                ref_B_err = 1./sqrt(N * ref_B); % Relative error of bright reference
                ref_D_err = 1./sqrt(N * ref_D); % Relative error of dark reference
                sig_B_err = 1./sqrt(N * sig_B); % Relative error of bright signal
                sig_D_err = 1./sqrt(N * sig_D); % Relative error of dark signal
                ref_err = sqrt((ref_B_err .* ref_B).^2 + (ref_D_err .* ref_D).^2)./(ref_B + ref_D);
                sig_err = sqrt((sig_B_err .* sig_B).^2 + (sig_D_err .* sig_D).^2)./(sig_B - sig_D);
                rel_err = sqrt(ref_err.^2 + sig_err.^2);
                data_err = rel_err .* data;
            elseif strcmp(gmSEQ.name,'f_DEER_scan_freq')||strcmp(gmSEQ.name,'f_Echo')||strcmp(gmSEQ.name,'f_DEER_scan_tau')...
                    ||strcmp(gmSEQ.name,'f_DEER_scan_dur')||strcmp(gmSEQ.name,'f_DEER_scan_power')
                ref_B = signal(1,:);
                ref_D = signal(3,:);
                sig_B = signal(2,:);
                sig_D = signal(4,:); 
                [data, data_err] = ContrastDiff2(ref_B, ref_D,sig_B, sig_D, gmSEQ.iAverage);
            elseif strcmp(gmSEQ.name,'f_XY8')||strcmp(gmSEQ.name,'f_DEER_XY8')
                ref_B = signal(1,:);
                sig_D = signal(2,:);
                ref_D = signal(3,:);
                sig_B = signal(4,:); 
                [data, data_err] = ContrastDiff2(ref_B, ref_D,sig_B, sig_D, gmSEQ.iAverage);
            else          
                ref_B = signal(3,:);
                ref_D = signal(1,:);
                sig_B = signal(4,:);
                sig_D = signal(2,:);           
                [data, data_err] = ContrastDiff(ref_B, ref_D,sig_B, sig_D, gmSEQ.iAverage);
            end
        elseif gmSEQ.ctrN==5
            sig_B = signal(2,:);
            ref_B = signal(1,:);
            sig_D = signal(4,:);
            ref_D = signal(3,:);
            data = sig_B-sig_D;
            data_err = zeros(size(signal(1,:)));
        elseif gmSEQ.ctrN==8
            if strcmp(gmSEQ.name,'T1_S00_S01_fdc') 
                sig_B = signal(3,:);
                ref_B = fliplr(signal(7,:));
                sig_D = signal(5,:);
                ref_D = fliplr(signal(1,:));
                [data, data_err] = ContrastDiff(ref_B, ref_D,sig_B, sig_D, gmSEQ.iAverage);
            else 
                sig_B = signal(3,:);
                ref_B = signal(7,:);
                sig_D = signal(5,:);
                ref_D = signal(1,:);
                [data, data_err] = ContrastDiff(ref_B, ref_D,sig_B, sig_D, gmSEQ.iAverage);

%                 data = (sig_B-sig_D)/(ref_B+ref_D);
%                 data_err = zeros(size(signal(1,:)));
            end
        else
            data = zeros(size(signal(1,:)));
            data_err = data;
        end
        % plot(handles.axes3, gmSEQ.SweepParam(1:length(data)).*ScaleT,data,'-g')
        if strcmp(gmSEQ.name,'Elec_Pol_Extract')|| strcmp(gmSEQ.name,'Rabi_fix_MWDutyCycle')
            errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data1)).*gmSEQ.ScaleT, data1, data_err1,'-r')
            hold(handles.axes3,'on')
            errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data2)).*gmSEQ.ScaleT, data2, data_err2,'-b')
            hold(handles.axes3,'off')             
        else
            %errorbar(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data, data_err,'-g')
            plot(handles.axes3, gmSEQ.SweepParam(1:length(data)).*gmSEQ.ScaleT, data,'-g')
        end
    end
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

function [data, data_err] = ContrastDiff(ref_B, ref_D,sig_B, sig_D, N)
data = 2*(sig_B - sig_D)./(ref_B + ref_D);
%data = (sig_B - sig_D)./(ref_B - ref_D); %Normalize to 1
ref_B_err = 1./sqrt(N * ref_B); % Relative error of bright reference
ref_D_err = 1./sqrt(N * ref_D); % Relative error of dark reference
sig_B_err = 1./sqrt(N * sig_B); % Relative error of bright signal
sig_D_err = 1./sqrt(N * sig_D); % Relative error of dark signal
ref_err = sqrt((ref_B_err .* ref_B).^2 + (ref_D_err .* ref_D).^2)./(ref_B + ref_D);
sig_err = sqrt((sig_B_err .* sig_B).^2 + (sig_D_err .* sig_D).^2)./(sig_B - sig_D);
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;

function [data, data_err] = ContrastDiff2(ref_B, ref_D,sig_B, sig_D, N)
data = (sig_B - sig_D)./(ref_B - ref_D); %Normalize to 1
ref_B_err = 1./sqrt(N * ref_B); % Relative error of bright reference
ref_D_err = 1./sqrt(N * ref_D); % Relative error of dark reference
sig_B_err = 1./sqrt(N * sig_B); % Relative error of bright signal
sig_D_err = 1./sqrt(N * sig_D); % Relative error of dark signal
ref_err = sqrt((ref_B_err .* ref_B).^2 + (ref_D_err .* ref_D).^2)./(ref_B + ref_D);
sig_err = sqrt((sig_B_err .* sig_B).^2 + (sig_D_err .* sig_D).^2)./(sig_B - sig_D);
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data_err = rel_err .* data;

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

function [status,A] = ReadCountersPD(task,samps,timeout,numPDChan)
[status, A] = DAQmxFunctionPool('ReadAnalogVoltage',task, samps, timeout,numPDChan);
DAQmxErr(status);

function ClearCounters(task)
DAQmxClearTask(task);

function TemporarySave(BackupFile)
global gSG gmSEQ gWide

% convert relevant globals to a bigger structure
BackupExp.gmSEQ=gmSEQ;
BackupExp.gSG=gSG;
% include widefield image stacks when present (HeliCam runs)
if ~isempty(gWide); BackupExp.gWide=gWide; end
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

function CreateCaliLog(hObject, eventdata, handles)
global gCaliLog gTrackLog gmSEQ gCaliCounter
if ~gmSEQ.bTrack
    return
end
now = clock;
date = [num2str(now(1)),'-',num2str(now(2)),'-',num2str(round(now(3)))];
fullPath=fullfile('D:\Data\',date,'\');
if ~exist(fullPath,'dir')
    mkdir(fullPath);
end

if gmSEQ.bCali
    gCaliCounter.RFCali = 0;
    gCaliLog.path = fullPath;
    gCaliLog.file = ['_' date '_CaliLog.txt'];
    name=regexprep(gmSEQ.name,'\W',''); % rewrite the sequence name without spaces/weird characters
    %File name and prompt
    B=fullfile(gCaliLog.path, strcat(name, gCaliLog.file));
    file = strcat(name, gCaliLog.file);
    
    %Prevent overwriting
    mfile = strrep(B,'.txt','*');
    mfilename = strrep(gCaliLog.file,'.txt','');
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
    file = strrep(file,'.txt',sprintf('_%03d.txt',ImgN));
    gCaliLog.final= fullfile(gCaliLog.path, file);
end
if gmSEQ.bTrack
    gCaliCounter.ImageCorr = 0;
    gTrackLog.path = fullPath;
    gTrackLog.file = ['_' date '_TrackLog.txt'];
    name=regexprep(gmSEQ.name,'\W',''); % rewrite the sequence name without spaces/weird characters
    %File name and prompt
    B=fullfile(gTrackLog.path, strcat(name, gTrackLog.file));
    file = strcat(name, gTrackLog.file);
    
    %Prevent overwriting
    mfile = strrep(B,'.txt','*');
    mfilename = strrep(gTrackLog.file,'.txt','');
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
    file = strrep(file,'.txt',sprintf('_%03d.txt',ImgN));
    gTrackLog.final= fullfile(gTrackLog.path, file);
end

function Calibration(hObject, eventdata, handles)
global gCaliCounter gmSEQ
if gmSEQ.bTrack
    gCaliCounter.ImageCorr = gCaliCounter.ImageCorr + 1;
    if (mod(gCaliCounter.ImageCorr, gmSEQ.TrackPointN)==1) % track at the starting of the measurement
        Track('ImageCorr');
    end
end

if 0
%if gmSEQ.bCali
    gCaliCounter.RFCali = gCaliCounter.RFCali + 1;
    if (mod(gCaliCounter.RFCali, gmSEQ.CaliN)==1) || (gmSEQ.CaliN == 1)
        if strcmp(gmSEQ.name, 'Special Cooling')
            AutoCalibration(hObject, eventdata, handles);
        end
    end
end

function AutoCalibration(hObject, eventdata, handles)
global gmSEQ gSG gSG2 gSaveDataAve gCaliLog

if ~gmSEQ.bCali
    return;
end
% Save the current parameters
gmSEQt = gmSEQ;
gSGt = gSG;
gSG2t = gSG2;
gSaveDataAvet = gSaveDataAve;

% Set Laser AWG power here
h = findobj('Tag','ImageNVCGUI');
if ~isempty(h)
    % get handles and other user-defined data associated to Gui1
    handles_ImageNVC = guidata(h);
end
PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
ImageFunctionPool('UpdateVoltage',0, 0, handles_ImageNVC);

ExperimentFunctionPool('AutoCalibration', hObject, eventdata, handles, false);
gSGt.Freq = gSG.Freq;
gSGt.Pow = gSG.Pow;
gmSEQt.SAmp1 = gSG.AWGAmp;
gmSEQt.SAmp2 = gSG.AWGAmp;
gmSEQt.SAmp1_M = gSG.AWGAmp;
gmSEQt.SAmp2_M = gSG.AWGAmp;

% Log
fid = fopen(string(gCaliLog.final),'at'); % a means add data, w means new data
fprintf(fid,'%s', [datestr(datetime(clock))]);
fprintf(fid,' %4.3f %2.1f %.2f\n', [gSG.Freq/1e9 + 0.125, gSG.Pow, gSG.AWGAmp]);
fclose(fid);

% Load the parameters
gmSEQ = gmSEQt;
gSG = gSGt;
gSG2 = gSG2t;
gSaveDataAve = gSaveDataAvet;

% Reset MW
gmSEQ.refCounts=Track('Init');
SignalGeneratorFunctionPool('SetMod');
SignalGeneratorFunctionPool('WritePow');
SignalGeneratorFunctionPool('WriteFreq');
gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');

function refCounts = Track(what)
global gmSEQ gSG gTrackLog gScan

if gmSEQ.bTrack
    % get the handle of Gui1
    h = findobj('Tag','ImageNVCGUI');
    
    % if exists (not empty)
    if ~isempty(h)
        % get handles and other user-defined data associated to Gui1
        handles_ImageNVC = guidata(h);
    end
    
    PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM'));
    currentCounts = ImageFunctionPool('RunCPSOnce',0, 0, handles_ImageNVC);
    if ~isfield(gmSEQ,'bLiO')
        ExperimentFunctionPool('PBOFF',0, 0, handles_ImageNVC);
    end
else
    refCounts=0;
    return
end

switch what
    case 'Init'
        refCounts=currentCounts;
        return
    case 'Run'
        if currentCounts<.9*gmSEQ.refCounts
            PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
            %             for i=1:3
            %                 currentCounts = ImageFunctionPool('NewTrackFast',0, 0, handles_ImageNVC);
            %                 drawnow;
            %                 if gmSEQ.bGo==0
            %                     refCounts=currentCounts;
            %                     return
            %                 end
            %             end
            ImageFunctionPool('TrackImageCorr',0, 0, handles_ImageNVC);
            ImageFunctionPool('TrackZ', 0, 0, handles_ImageNVC);
            if ~isfield(gmSEQ,'bLiO')
                ExperimentFunctionPool('PBOFF',0, 0, handles_ImageNVC);
            end
            fid = fopen(string(gTrackLog.final),'at'); % a means add data, w means new data
            fprintf(fid,'%s', datestr(datetime(clock)));
            fprintf(fid,' %.4f %.4f %3.1f\n', [gScan.FixVx, gScan.FixVy, gScan.FixVz]);
            fclose(fid);
            refCounts=currentCounts;
        else
            refCounts=gmSEQ.refCounts;
        end
    case 'ImageCorr'
        %disp(['ImageCorrelate']);
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM'));
        % ImageFunctionPool('UpdateVoltage',0, 0, handles_ImageNVC);
        ImageFunctionPool('TrackZ', 0, 0, handles_ImageNVC);% not written
        ImageFunctionPool('TrackImageCorr',0, 0, handles_ImageNVC);
        % ImageFunctionPool('TrackImageCorr',0, 0, handles_ImageNVC);
        refCounts = currentCounts;
        
        fid = fopen(string(gTrackLog.final),'at'); % a means add data, w means new data
        fprintf(fid,'%s', datestr(datetime(clock)));
        fprintf(fid,' %.4f %.4f %3.1f\n', [gScan.FixVx, gScan.FixVy, gScan.FixVz]);
        fclose(fid);
        
        % pause(20); % z postion relaxation
end

function CreateSavePath_Ave()
global gSaveDataAve gmSEQ
now = clock;
date = [num2str(now(1)),'-',num2str(now(2)),'-',num2str(round(now(3)))];
fullPath=fullfile('C:\Data\',date,'\');
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

function Set_FPGA_GUI_buttons(handles, is_enable)
handles.fpga_get_waveform_lsit.Enable = is_enable;
handles.fpga_get_program_list.Enable = is_enable;
handles.fpga_get_envelope_list.Enable = is_enable;
handles.fpga_get_state.Enable = is_enable;
handles.fpga_get_connect.Enable = is_enable;
handles.fpga_get_disconnect.Enable = is_enable;

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



grid(handles.axes2, 'on');
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
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref));
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig));
rel_err = sqrt(ref_err.^2 + sig_err.^2);
data1_err = rel_err .* data1;


%S11-S10
sig = sig11 - sig10;
ref = (refB10+refB11)/2 - (refD10+refD11)/2;
data2 = sig./ref;
ref_err = 1./sqrt(gmSEQ.iAverage * abs(ref)); % Relative error of reference
sig_err = 1./sqrt(gmSEQ.iAverage * abs(sig)); % Relative error of signal
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


function save_and_upload_GUI_figure(handles, message)
global gSaveDataAve
% save the main exp GUI figure

name = gSaveDataAve.file;
filename = strcat('C:\Users\dilution_fridge_2\Desktop\T1_SemiAuto_Saves\',name);
filename = replace(filename, '.txt', '.png');
filename_char = filename{1};
imwrite(getframe(handles.figure1).cdata, filename_char)

% upload saved GUI figure to slack
default_keep = int32(100); %keep only 100 uploads
scriptFolder = 'C:\Matlab_Code\AutoRunSequences';

% Add it to Python's module search path if not already there
if count(py.sys.path, scriptFolder) == 0
    insert(py.sys.path, int32(0), scriptFolder)
end

py.slack_upload_v2.upload_and_cleanup(filename_char, message, default_keep);



