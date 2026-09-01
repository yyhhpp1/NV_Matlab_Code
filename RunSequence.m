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
    
    useSG3 = 0;
    if useSG3
        SignalGeneratorFunctionPool3('SetMod');
        SignalGeneratorFunctionPool3('WritePow');
        SignalGeneratorFunctionPool3('WriteFreq');
        if startsWith(gmSEQ.name, 'f_')
            gSG3.bOn = 0;
        else
            gSG3.bOn = 1;
        end
        SignalGeneratorFunctionPool3('RFOnOff');
    end

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
                        %gSG3.Pow = gmSEQ.SweepParam(j);
                        %SignalGeneratorFunctionPool3('WritePow');
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
                    %fpga.start_program(string(gmSEQ.name));
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
                    
                    %fpga.stop_program();
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
        %gSG3.bOn=0; SignalGeneratorFunctionPool3('RFOnOff');
        if handles.useSG2.Value; gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff'); end
        %fpga.stop_program();
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
    
    
elseif isfield(gmSEQ,'bLiO')   % activates for cwESR
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
    PBFunctionPool('PBON',2^SequencePool('PBDictionary','GreenAOM')+2^SequencePool('PBDictionary','MWSwitch')+2^SequencePool('PBDictionary','MWSwitchHP'));
    
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

    useSG3 = 0;
    if useSG3
        SignalGeneratorFunctionPool3('SetMod');
        SignalGeneratorFunctionPool3('WritePow');
        SignalGeneratorFunctionPool3('WriteFreq');
        if startsWith(gmSEQ.name, 'f_')
            gSG3.bOn = 0;
        else
            gSG3.bOn = 1;
        end
        SignalGeneratorFunctionPool3('RFOnOff');
    end
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
%gSG3.bOn=0; SignalGeneratorFunctionPool3('RFOnOff');

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
global gmSEQ gSG gSG2 gCam gWide gScan
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
% nPeriods and nFrames come straight from the GUI (handles.nPeriods /
% handles.nFrames edit fields on Experiment_PB_DAQ), read into gmSEQ by
% LoadUserInputs, with WidefieldConfig as the fallback when those fields are
% absent/empty. One PB run of an hc_* sequence = one lock-in period (CamRef
% NRise=4 -> 4 quarter edges), so the PB loop count is exactly the number of
% periods the camera consumes. Average is the outer repeat of the whole
% acquisition.
cfgPB = WidefieldConfig();

% GenICam advertises 1..100, but the effective floor is 2: with
% LockInTargetTimeConstantNPeriods = 1 the camera reports
% LockInActualTimeConstantNPeriods = 2 (verified 2026-08-12, firmware 1.11.0,
% f_ref 1262.6 Hz -- the frame-rate inequality passed, so this is a firmware
% floor, not a timing violation). Asking for 1 therefore yields 2 anyway while
% PB budgets edges for 1, starving the burst into a readIQ timeout. Clamp to
% what the hardware will actually do.
gmSEQ.nPeriods = max(2, min(100, round(gmSEQ.nPeriods)));   % effective range 2..100
gmSEQ.nFrames  = max(4, round(gmSEQ.nFrames));               % camera minimum 4

% Reflect any clamping back onto the GUI so the displayed value matches what's
% actually used (e.g. a typed nFrames=1 shows as 4 once this run starts).
set(handles.nPeriods, 'String', num2str(gmSEQ.nPeriods));
set(handles.nFrames,  'String', num2str(gmSEQ.nFrames));
drawnow;

% PB runs exactly the periods the camera consumes -- no surplus. A surplus was
% carried for a while on the theory that a shortfall of even one edge would leave
% getBuffer waiting forever with no partial data; 20 consecutive acquisitions with
% zero surplus showed the camera does not need it.
nBlankCfg = 0;
if isfield(cfgPB,'blankPeriods') && ~isempty(cfgPB.blankPeriods)
    nBlankCfg = cfgPB.blankPeriods;
end
% AC coupling reserves the first period of every frame to measure the
% background before subtracting it (heliCam C4 manual, chapter3 "Coupling":
% background suppression "at the cost of an integration cycle"; chapter3's
% frame-validity formula includes a +1 term for Coupling==AC). PB has to
% supply that extra edge too, or every frame is one period short of what the
% camera actually consumes -> readIQ timeout, same failure mode as the
% nPeriods=1 edge shortfall this function already guards against elsewhere.
nCouplingExtra = 0;
if isfield(gmSEQ,'coupling') && strcmpi(gmSEQ.coupling, 'AC')
    nCouplingExtra = 1;
end
% Periods the camera consumes: (nPeriods + blank + AC background period) per
% frame, all nFrames frames.
nPeriodsNeeded = (gmSEQ.nPeriods + nBlankCfg + nCouplingExtra) * gmSEQ.nFrames;
gmSEQ.nPBPeriods = nPeriodsNeeded;
% Set both: the root PBFunctionPool loops on SEQ.Repeat, the one in
% mytoolboxes/PulseBlaster loops on SEQ.Samples, and path order decides which
% runs. Keeping them equal makes the loop count correct either way.
gmSEQ.Repeat   = gmSEQ.nPBPeriods;
gmSEQ.Samples  = gmSEQ.nPBPeriods;

% Camera exposure comes from gmSEQ.CtrGateDur for EVERY hc_* sequence, with no
% exceptions. The quarter period is the other axis and comes from the GUI QP box
% via hc_QuarterBin; the two are set independently, which is the whole point --
% QP says how often the camera is triggered, CtrGateDur says how long it
% integrates after each trigger.
%
% CtrGateDur is the right field because the confocal (NI-DAQ) path already uses
% it for the same physical role -- the detector's actual integration/gate window
% within the readout pulse (see e.g. Sequences/Rabi.m's ctr0 gating) -- so "how
% long the detector integrates" means one thing across both detection modalities.
%
% hc_Image/hc_ZScan used to be special-cased to integrate the whole quarter
% (exposure from QP), on the grounds that they light the full bin. That made them
% the only sequences whose exposure could not be set independently of the trigger
% rate, and it meant the same GUI field controlled different things depending on
% which sequence was selected. They now follow the same rule as everything else:
% to integrate the whole bin there, set CtrGateDur to the QP value. Any new hc_*
% sequence inherits this without being listed anywhere.
% hc_scan_exposure is the one exception, and it has to be settled HERE rather
% than at the sweep-validation block further down, because the value chosen on
% this line is what gets written to the camera before the loop starts.
% That sequence sweeps the gate, so its GUI CtrGateDur box holds nothing but
% whatever was last typed for some other measurement -- typically a confocal
% readout gate of 1000-4000 ns. Configuring the camera from it is at best a
% throwaway write (the loop retunes at every point anyway) and at worst fatal:
% a gate under floor+overhead clamps the exposure to the camera's minimum, and
% until the fix in HeliCamInterface.exposureToReferenceFrequency that minimum was
% a frequency the camera rejects outright. Seeding from the first sweep point
% instead makes the pre-loop configuration a point the run actually visits.
bExpSweep = strcmp(char(string(gmSEQ.name)), 'hc_scan_exposure');
if bExpSweep && isfield(gmSEQ,'SweepParam') && ~isempty(gmSEQ.SweepParam)
    exposureSourceNs = gmSEQ.SweepParam(1);
else
    exposureSourceNs = gmSEQ.CtrGateDur;
end

% Camera exposure tracks that source, kept just below it by the sensor
% overhead so the configured reference frequency matches the actual PB
% quarter rate (otherwise the camera won't lock and readIQ times out).
% Values are in ns; the camera exposure floor comes from hc_MinExposureNs.
overheadNs = 2000;                                  % ~2 us sensor busy overhead
if isfield(cfgPB,'sensorOverheadNs') && ~isempty(cfgPB.sensorOverheadNs)
    overheadNs = cfgPB.sensorOverheadNs;
end
% Shortest exposure the camera will accept, derived from the reference-frequency
% grid rather than typed in -- see hc_MinExposureNs for why a literal here was
% wrong (the old 1825 ns is a frequency the camera rejects).
expoFloorNs = hc_MinExposureNs(gmSEQ.sensitivity);
% Local copy for the slack / frame-rate diagnostics printed just below. The
% value actually written to the camera comes from ConfigureExposure, which owns
% gmSEQ.exposureSeconds and applies this same formula -- kept identical here on
% purpose so the printed slack describes what is configured.
expoNs = max(exposureSourceNs - overheadNs, expoFloorNs);

fprintf(['[Widefield] Edge budget: camera needs %d periods ', ...
         '(%d frames x (%d+%d+%d[AC])) = %d CamRef edges; PB will run %d periods ', ...
         '= %d edges.\n'], nPeriodsNeeded, gmSEQ.nFrames, gmSEQ.nPeriods, ...
        nBlankCfg, nCouplingExtra, 4*nPeriodsNeeded, gmSEQ.nPBPeriods, 4*gmSEQ.nPBPeriods);

% The real quarter bin, for the slack/frame-rate checks below and for the
% quarter_bin_ns attribute. hc_QuarterBin unconditionally, because that is what
% EVERY hc_* sequence file now calls to place its CamRef edges.
%
% This used to default to gmSEQ.readout and name three sequences as exceptions.
% That list was never updated when Q moved to the QP box, so any sequence outside
% it -- hc_Scan_init_time, and every future one -- had its quarter bin read from
% 'readout', a field no sequence uses as Q any more. Worse, the assignment just
% below writes this value back into gmSEQ.quarterBinNs, the very field
% hc_QuarterBin reads, so the wrong value then replaced the QP box for every PB
% program built after this point: the pulse diagram drawn at LoadSEQ showed the
% real QP and the run silently used 'readout'. Deriving it from the one shared
% accessor removes both the stale list and the writeback hazard.
%
% hc_T1 builds a composite bin from its own pulse timings; it was already on the
% old list and so is unchanged by this.
quarterBinNsUsed = hc_QuarterBin(cfgPB);
% Record what was actually used, so the quarter_bin_ns attribute SaveWidefield
% writes reflects this run instead of the WidefieldConfig default.
gmSEQ.quarterBinNs = quarterBinNsUsed;

% slack is 0 by construction (exposure = source - overhead); it goes NEGATIVE
% only when the exposure source is too short for the camera's exposure floor,
% which means the next CamRef edge lands while the sensor is still busy.
slackNs = quarterBinNsUsed - expoNs - overheadNs;
fprintf(['[Widefield] Quarter bin = %g ns; exposure = %g ns ', ...
         '(overhead %g ns, slack %g ns).\n'], ...
        quarterBinNsUsed, expoNs, overheadNs, slackNs);
if slackNs < 0
    fprintf(2, ['[Widefield] WARNING: quarter bin %g ns is too short -- the exposure ', ...
                'floor (%g ns) plus overhead (%g ns) exceeds it, so the next CamRef ', ...
                'edge arrives while the sensor is still busy. Raise the QP box to ', ...
                'at least %g ns.\n'], ...
            quarterBinNsUsed, expoFloorNs, overheadNs, expoFloorNs + overheadNs);
end

% Output frame rate the camera is being asked to sustain. One frame per
% nPeriods reference periods, each period = 4 quarter bins. With nPeriods = 1
% this is 1/(4*quarter bin) -- 2.5 kHz at a 100 us quarter bin, which may
% simply exceed what the sensor can emit. Raising nPeriods divides it down.
periodSeconds = 4 * quarterBinNsUsed * 1e-9;
frameRateHz   = 1 / (gmSEQ.nPeriods * periodSeconds);
fprintf(['[Widefield] Reference period = %.4g s; %d periods/frame ', ...
         '-> %.4g frames/s, burst %.4g s for %d frames.\n'], ...
        periodSeconds, gmSEQ.nPeriods, frameRateHz, ...
        gmSEQ.nFrames * gmSEQ.nPeriods * periodSeconds, gmSEQ.nFrames);

% --- Configure camera: WidefieldConfig hardware/display fields, with the
% per-run lock-in params taken from gmSEQ (populated by LoadUserInputs). ---
% Everything except the exposure is written once here and never touched again.
% The exposure goes through ConfigureExposure (local function below) because
% hc_scan_exposure re-runs that same step inside the sweep loop -- one owner for
% "gate width -> integration time -> camera -> PB edge budget", so the two call
% sites cannot drift apart.
ccfg = WidefieldConfig();
ccfg.nPeriods             = gmSEQ.nPeriods;          % forced to 1 above
ccfg.nFrames              = gmSEQ.nFrames;
ccfg.sensitivity          = gmSEQ.sensitivity;
ccfg.coupling             = gmSEQ.coupling;
ccfg.referenceTimeShiftUs = gmSEQ.referenceTimeShiftUs;
ccfg = ConfigureExposure(gCam, ccfg, exposureSourceNs, overheadNs, nBlankCfg, nCouplingExtra);

H = gCam.Height; W = gCam.Width; N = gmSEQ.NSweepParam;

% Frequency-swept sequences (e.g. hc_ODMR) use GHz on the GUI -> Hz, as ODMR does.
bFreqSweep = ~gSG.bfixedFreq;
if bFreqSweep
    gmSEQ.SweepParam = gmSEQ.SweepParam * 1e9;
end

% --- Exposure-swept sequences (hc_scan_exposure): the sweep axis drives the
% camera's integration time ---------------------------------------------------
% Same shape as the frequency and Z sweeps: the swept quantity is written to
% hardware inside the loop. What makes this one different from every other hc_*
% sequence is that the hardware being written is the CAMERA -- the exposure
% register is normally set once, above, and left alone for the whole run.
%
% This is name-keyed rather than declarative because it changes the meaning of
% two things the rest of the run treats as constants: the exposure and the dark
% pedestal. A sequence that quietly opted in by rewriting gmSEQ.CtrGateDur would
% also silently invalidate the single dark reference, and that failure is
% invisible in the data -- it just biases the ratio. Naming it makes the
% coupling explicit and keeps every other sequence on the fast path.
% bExpSweep is set further up, where the pre-loop exposure source is chosen.
if bExpSweep
    % Validate the WHOLE sweep before acquiring anything: a bad From/To must not
    % be discovered N/2 points in, with half a curve already on disk.
    eAll = gmSEQ.SweepParam(:).';
    if any(~isfinite(eAll)) || any(eAll < 12)
        error('RunSequence:ExposureGateTooShort', ...
              ['hc_scan_exposure: the gate sweep contains a value below the 12 ns ', ...
               'PulseBlaster minimum instruction length (or a non-finite one). ', ...
               'Range requested: [%g, %g] ns. Nothing was acquired.'], ...
              min(eAll), max(eAll));
    end
    if any(eAll > quarterBinNsUsed)
        error('RunSequence:ExposureGateTooLong', ...
              ['hc_scan_exposure: the gate sweep reaches %g ns but the quarter bin ', ...
               'is only %g ns. A gate that long swallows the next quarter boundary, ', ...
               'so the four CamRef pulses merge into one and the camera sees 1 edge ', ...
               'per period instead of 4 -- readIQ then waits forever. Cap the sweep ', ...
               'or raise the QP box. Nothing was acquired.'], ...
              max(eAll), quarterBinNsUsed);
    end

    % Below gate = floor + overhead the exposure CLAMPS, so those points all
    % measure the same integration time and the curve grows a false flat foot.
    % A warning, not an error: a deliberate sweep through the floor is a
    % legitimate thing to look at, as long as it is not mistaken for signal.
    gateFloorNs = expoFloorNs + overheadNs;
    nClamped = sum(eAll < gateFloorNs);
    if nClamped > 0
        fprintf(2, ['[Widefield] hc_scan_exposure: WARNING -- %d of %d sweep points ', ...
                    'are below %g ns (camera exposure floor %g ns + overhead %g ns). ', ...
                    'Their exposure clamps to %g ns, so they all measure the SAME ', ...
                    'integration time and the low end of the curve will be flat by ', ...
                    'construction, not by physics.\n'], ...
                nClamped, numel(eAll), gateFloorNs, expoFloorNs, overheadNs, expoFloorNs);
    end

    % The dark pedestal accumulates during the exposure, and the exposure is the
    % swept quantity -- so a single dark is correct at exactly one point. The
    % sequence file declares WFneedsDarkRef, which ticks the box automatically;
    % this fires only if it was deliberately unticked afterwards.
    if ~(isfield(gmSEQ,'bTakeDarkRef') && gmSEQ.bTakeDarkRef)
        fprintf(2, ['[Widefield] hc_scan_exposure: WARNING -- takeDarkRef is OFF. The ', ...
                    'dark pedestal scales with exposure, which is the swept quantity, ', ...
                    'so whatever dark is applied is right at ONE point of this sweep ', ...
                    'and wrong everywhere else. The -I./Q ratio will be biased ', ...
                    'systematically along the axis. Tick takeDarkRef.\n']);
    end

    fprintf(['[Widefield] Exposure sweep: %d points, gate %g..%g ns -> exposure ', ...
             '%g..%g ns (gate - %g ns overhead, floor %g ns). Camera reconfigured ', ...
             'and a fresh dark taken at EVERY point.\n'], ...
            numel(eAll), min(eAll), max(eAll), ...
            max(min(eAll) - overheadNs, expoFloorNs), ...
            max(max(eAll) - overheadNs, expoFloorNs), ...
            overheadNs, expoFloorNs);
end

% --- Z-swept sequences (hc_ZScan): the sweep axis drives the objective -------
% Same shape as the frequency sweep above: the PB program is identical at every
% point and the swept quantity is written to hardware inside the loop.
bZSweep       = strcmp(char(string(gmSEQ.name)), 'hc_ZScan');
zStart        = NaN;
zSettle       = 0;
bZMoveEnabled = false;   % set below; gates every objective move in this run
if bZSweep
    % The EO drive must be live BEFORE the sweep starts. Its library and handle
    % are loaded only by ImageNVC -> Start (ImageFunctionPool.m:1352-1363);
    % Experiment_PB_DAQ's own Initialize never touches them. Without them every
    % WriteVoltage fails inside calllib while the sweep cheerfully records N
    % identical frames at whatever Z the objective happens to sit at -- which
    % looks exactly like a real scan of a perfectly flat focus curve. Refusing up
    % front is the only way that failure stays visible.
    %
    % Exempted under useFakeCamera, which exists to exercise this code path with
    % no hardware attached at all -- demanding a real objective drive there would
    % defeat the point.
    bZMoveEnabled = ~(isfield(ccfg,'useFakeCamera') && ccfg.useFakeCamera);
    if ~bZMoveEnabled
        fprintf(['[Widefield] hc_ZScan: fake camera -- Z moves are SKIPPED, so the ', ...
                 'focus curve is meaningless. Code-path check only.\n']);
    elseif ~EODriveReady()
        error('RunSequence:EODriveNotReady', ...
              ['hc_ZScan: the EO objective drive is not initialised, so Z cannot ', ...
               'be moved and every point of the stack would be taken at the same ', ...
               'position. Open ImageNVC and press Start once (that loads ', ...
               'EO-Drive.dll and sets eohandle), then rerun. Nothing was moved.']);
    end

    zMin = 0;   zMax = 100;
    if isfield(ccfg,'zMinUm') && ~isempty(ccfg.zMinUm); zMin = ccfg.zMinUm; end
    if isfield(ccfg,'zMaxUm') && ~isempty(ccfg.zMaxUm); zMax = ccfg.zMaxUm; end

    % Validate the WHOLE sweep before moving anything: a bad From/To must not
    % be discovered halfway through, with the objective already travelling.
    zAll = gmSEQ.SweepParam(:);
    if any(~isfinite(zAll)) || any(zAll < zMin) || any(zAll > zMax)
        error('RunSequence:ZOutOfRange', ...
              ['hc_ZScan: requested Z range [%g, %g] um is outside the safe ', ...
               'range [%g, %g] um set in WidefieldConfig (zMinUm/zMaxUm). ', ...
               'Nothing was moved.'], min(zAll), max(zAll), zMin, zMax);
    end

    % Starting Z, restored when the run finishes or errors. gScan is the
    % imaging GUI's state; without it there is no way to know where Z began, so
    % say so rather than silently leaving the objective parked at the last point.
    if ~isempty(gScan) && isfield(gScan,'FixVz') && isscalar(gScan.FixVz) ...
            && isfinite(gScan.FixVz)
        zStart = double(gScan.FixVz);
    else
        fprintf(2, ['[Widefield] WARNING: no gScan.FixVz, so the starting Z is ', ...
                    'unknown and cannot be restored. The objective will be left ', ...
                    'at the last Z of the sweep.\n']);
    end

    % Settle after each move = one full acquisition burst, so it tracks the
    % sequence timing / nPeriods / nFrames instead of being a fixed guess.
    zSettle = gmSEQ.nPBPeriods * periodSeconds;
    if isfield(ccfg,'zSettleSeconds') && ~isempty(ccfg.zSettleSeconds)
        zSettle = ccfg.zSettleSeconds;
    end
    fprintf(['[Widefield] Z stack: %d points over %g..%g um (safe range ', ...
             '%g..%g), settle %.4g s per step.\n'], ...
            numel(zAll), min(zAll), max(zAll), zMin, zMax, zSettle);

    % ONE pass, whatever the GUI Average says. A Z stack is a focus MEASUREMENT,
    % not a signal average: the answer is the position of a peak, and repeating
    % the whole sweep does not sharpen it -- each point is already averaged over
    % nFrames internally. What extra passes do cost is real: the objective is
    % driven back and forth across the full range again, and the parking move
    % that puts the sample in focus is deferred until the last pass finishes.
    %
    % Placed after the range validation above so a run that is about to be
    % refused does not mutate anything, and written onto gmSEQ.Average (rather
    % than a local loop bound) so the 'average' attribute in the .h5 reports what
    % actually ran. The onCleanup puts the user's value back on the way out --
    % normal exit or error, and after SaveWidefield has read it -- because the
    % Run button path is not the only caller of RunSequence, and a leaked
    % Average = 1 would silently disable averaging for the next sequence.
    if gmSEQ.Average ~= 1
        aveWanted = gmSEQ.Average;   % plain scalar: an anonymous function would
                                     % otherwise capture the whole gmSEQ struct
        fprintf(['[Widefield] hc_ZScan: Average = %d ignored -- running ONE sweep, ', ...
                 'then stopping and parking at best focus.\n'], aveWanted);
        aveRestore = onCleanup(@() RestoreAverage(aveWanted));
        gmSEQ.Average = 1;
    end
end

% --- Result store (images, parallel to scalar gmSEQ.signal) ---
% The two lock-in quadratures, named for what they are. I and Q hold, per sweep
% point, the mean over the burst's frames of the camera's I and Q outputs, with
% the run's dark reference subtracted. readIQ has already applied the polarity
% inversion, so there is no further negation anywhere downstream.
%
% Which quadrature carries the physics is a property of the SEQUENCE, not of
% these fields: it depends on where the laser and MW sit in the four quarters.
% That is exactly why the old names ('reference' for I, 'rawsignal' for Q) had to
% go -- they asserted roles the data does not have. Neither is more "raw" than
% the other, and neither is inherently a normaliser.
gWide = struct();
gWide.I          = NaN(H, W, N);   % mean over frames of I = Q1 - Q3, dark-subtracted
gWide.Q          = NaN(H, W, N);   % mean over frames of Q = Q2 - Q4, dark-subtracted
gWide.SweepParam = gmSEQ.SweepParam;
gWide.name       = char(string(gmSEQ.name));

% One ROI scalar per (Average pass, sweep point): ROI-mean of the displayed
% expression evaluated on THAT pass's own images. Their scatter across passes is
% what becomes the error bar on axes3, std/sqrt(n). Scalars, so a 999-pass run
% costs a few tens of kB -- the pass IMAGES are never retained.
%
% roiExpr records which expression these samples belong to. Because the value
% stored is the evaluated expression (matching what axes3 plots: per-pixel
% expression first, ROI-mean second), changing the expression mid-run makes the
% history meaningless, so it is discarded and the statistics restart.
% Welford running statistics of the axes3 ROI value, per sweep point. One sample
% is the ROI-mean of the display expression on a SINGLE camera frame, so these
% accumulate over BOTH loops -- every frame of every Average pass -- giving
% n = nFrames * nPasses.
%
% Indexed by sweep point only. There is no pass index and they are never reset
% between passes: allocated here, BEFORE the `for i = 1:gmSEQ.Average` loop
% below, so each pass adds its nFrames samples on top of what is already there.
% (Contrast passI/passQ, which are deliberately reallocated per pass.)
%
% Welford rather than sums of v and v^2: the naive var = (S2 - S1^2/n)/(n-1)
% subtracts two nearly equal large numbers, which at v ~ 500 with a ~0.5 spread
% throws away about 6 of 16 significant digits and can return a negative
% variance. Welford accumulates products of deviations, so there is no
% large-number cancellation and M2 >= 0 by construction -- for identical samples
% delta is exactly 0 and M2 stays exactly 0.
%
% Three vectors of length N: ~1 kB whatever Average is. That matters because
% TemporarySave writes the whole of gWide to disk at every sweep point, and the
% Average x N matrix this replaces was 16.8 MB at Average = 99999.
gWide.roiN    = zeros(1, N);   % samples so far -- runs to nFrames * nPasses
gWide.roiMean = zeros(1, N);   % running mean over ALL frames of ALL passes
gWide.roiM2   = zeros(1, N);   % running sum of squared deviations
gWide.roiExpr = '';            % which expression this state belongs to
gWide.roiLast = [0 0];         % [pass, point] last accumulated -- anti-double-count

% Per-point dark pedestal audit trail, written only by the hc_scan_exposure path
% below. Frame-MEAN scalars, not the H x W x N dark stacks themselves: the full
% stacks would be ~2 MB per point, and TemporarySave writes the whole of gWide to
% disk at EVERY point -- the same cost that made the Average x N ROI matrix
% unaffordable and forced the Welford accumulators above. These two vectors are
% enough to see how the pedestal tracked the swept exposure after the fact.
gWide.darkPointI = NaN(1, N);
gWide.darkPointQ = NaN(1, N);

% --- Dark reference: subtracted from every I/Q below ------------------------
% Two sources. The GUI checkbox takes ONE fresh laser-off burst here, before the
% sweep and outside the Average loop, so it is matched to this run's exposure /
% nPeriods / nFrames by construction (the camera was configured just above and is
% not touched again). Camera pixel noise is static at fixed settings, so that one
% dark I / dark Q pair serves every sweep point and every average pass. Unchecked
% falls back to the stored wf_darkref.mat (hc_DarkRef), which carries the usual
% staleness risk.
bDarkPerPoint = bExpSweep && isfield(gmSEQ,'bTakeDarkRef') && gmSEQ.bTakeDarkRef;
if bDarkPerPoint
    % hc_scan_exposure: DEFERRED to the loop. One dark here would be matched to
    % one exposure, and the exposure is what this sequence sweeps -- taking it
    % now, at the GUI CtrGateDur rather than at any sweep point's gate, would be
    % both wasted and wrong. The loop captures a fresh pair immediately after
    % reconfiguring the camera for each point, so every point is subtracted with
    % its own pedestal.
    darkI = [];
    darkQ = [];
    gWide.darkSource     = 'fresh-per-point';
    gWide.darkSubtracted = true;
    fprintf(['[Widefield] Dark reference: per-sweep-point (hc_scan_exposure). One ', ...
             'laser-off pair will be captured at each of the %d exposures, before ', ...
             'that point''s acquisition.\n'], N);
elseif isfield(gmSEQ,'bTakeDarkRef') && gmSEQ.bTakeDarkRef
    [darkI, darkQ] = AcquireDarkRef(gCam, ccfg, H, W);
    gWide.darkSource   = 'fresh';
    gWide.darkSubtracted = ~isempty(darkI);
else
    [darkI, darkQ] = LoadDarkRefForRun(ccfg, H, W);
    gWide.darkSource   = 'stored';
    gWide.darkSubtracted = ~isempty(darkI);
end
if ~gWide.darkSubtracted; gWide.darkSource = 'none'; end
% Kept so SaveWidefield can store them and the subtraction stays reversible.
gWide.darkI = darkI;
gWide.darkQ = darkQ;

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
        % This pass's own (non-cumulative) images, saved as the Ave_xxx_yyy
        % snapshot below -- mirrors gmSEQ.signal_Ave in the confocal path,
        % which likewise holds only the latest pass, not the running average.
        passI = NaN(H, W, N);
        passQ = NaN(H, W, N);
        while j <= N
            gmSEQ.m = gmSEQ.SweepParam(j);

            % --- Exposure sweep: retune the camera to THIS point -------------
            % The gate width is the swept quantity and it is the camera's
            % integration-time source, so the exposure register has to be
            % rewritten here. The pre-loop configuration does not cover any point
            % of this sweep: it runs at the GUI CtrGateDur, which for this
            % sequence is just whatever was last typed in that box.
            % ConfigureExposure also redoes the CamRef edge budget, which
            % is not optional: a new exposure means a new target reference
            % frequency, and the camera is free to land on a different actual
            % time constant, leaving PB short of edges and readIQ hanging.
            %
            % Then the matching dark, BEFORE the real program is built:
            % AcquireDarkRef runs its own PB program (this sequence's, minus the
            % laser) and leaves gmSEQ.CHN converted to seconds, which is safe
            % only because SequencePool below rmfields CHN and rebuilds it in ns.
            if bExpSweep
                ccfg = ConfigureExposure(gCam, ccfg, gmSEQ.SweepParam(j), ...
                                         overheadNs, nBlankCfg, nCouplingExtra);
                if bDarkPerPoint
                    [darkI, darkQ] = AcquireDarkRef(gCam, ccfg, H, W, ...
                                                    gmSEQ.SweepParam(j), (i == 1 && j == 1));
                    gWide.darkPointI(j) = mean(darkI(:), 'omitnan');
                    gWide.darkPointQ(j) = mean(darkQ(:), 'omitnan');
                    % Latest pair only -- see the darkPointI/Q comment above for
                    % why the full stacks are not retained.
                    gWide.darkI = darkI;
                    gWide.darkQ = darkQ;
                end
            end

            if bFreqSweep && srsOn
                gSG.Freq = gmSEQ.SweepParam(j);
                SignalGeneratorFunctionPool('WriteFreq');
            end
            if bZSweep && bZMoveEnabled
                % Range already validated before the loop, so this cannot
                % command the objective outside the safe travel.
                ImageFunctionPool('WriteVoltage',{}, {}, {},'Obj_Piezo', gmSEQ.SweepParam(j))
                %WriteVoltage('Obj_Piezo', gmSEQ.SweepParam(j));
                pause(zSettle);
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
            % Timeout sized to THIS point's burst, not a fixed 20 s. CHN is in
            % seconds by now (converted just above), and for a swept-wait
            % sequence like hc_T1 the program length changes per point, so this is
            % recomputed here rather than hoisted out of the loop.
            tmoMs = hc_AcqTimeoutMs(ccfg, gmSEQ.CHN, gmSEQ.nPBPeriods);

            gCam.startAcq();
            if pbOn; Run_PB_Sequence(); end   % PB drives the CamRef quarter train
            [I, Q] = gCam.readIQ(tmoMs);
            gCam.stopAcq();

            % SUM over the burst's frames, not the mean: this keeps the value on
            % a raw photon-count scale, and it makes the pass-to-pass scatter the
            % single honest measure of uncertainty -- frame noise is already
            % inside it, so the SEM over passes needs nothing added to it.
            %
            % size(I,3), NOT gmSEQ.nFrames: readIQ drops nDiscard warmup frames,
            % so the two can differ and the dark multiplier has to follow what
            % actually arrived.
            nF = size(I, 3);
            Ij = sum(I, 3);
            Qj = sum(Q, 3);
            % Remove the static per-pixel pedestal + fixed-pattern structure
            % BEFORE forming contrast: on the raw scale the pedestal (~518)
            % dwarfs the light-induced part, so an uncorrected ratio describes
            % the offset rather than the measurement.
            %
            % Each dark frame pairs with its own quadrature. Both sides were
            % already polarity-inverted by readIQ, so these are plain
            % subtractions and neither takes an extra minus. ONE dark pair serves
            % every sweep point and every average pass; it was captured once
            % before this loop -- EXCEPT under hc_scan_exposure, where the swept
            % gate changes the integration time and therefore the pedestal, so
            % darkI/darkQ were just replaced with this point's own pair above.
            % darkI/darkQ are the pedestal of ONE frame (AcquireDarkRef takes
            % mean(I,3)), which is what a pedestal physically is. Ij is a sum of
            % nF frames, so nF pedestals have to come off -- equivalent to
            % sum(I - darkI, 3), without materialising the temporary.
            if ~isempty(darkI)
                Ij = Ij - nF * darkI;
                Qj = Qj - nF * darkQ;
            end
            passI(:,:,j) = Ij;
            passQ(:,:,j) = Qj;

            % --- Negative Q under the exposure sweep -------------------------
            % hc_scan_exposure plots -I./Q .* sqrt(abs(Q)). The abs() is there so
            % the image stays real, but it hides something worth seeing: Q < 0
            % means the quadrature came out on the wrong side of zero, i.e. the
            % lock-in phase is wrong for that pixel (shadow, unlit region, or a
            % pedestal subtraction that overshot). Those pixels are plotted from
            % a MAGNITUDE, so they look like signal. They are not -- they are
            % unmeasured. Reported per point, loudly, with the count.
            if bExpSweep
                nNegQ = sum(Qj(:) < 0);
                if nNegQ > 0
                    fprintf(2, ['[Widefield] hc_scan_exposure: point %d (gate %g ns): ', ...
                                'Q < 0 in %d of %d pixels (%.1f%%). The display uses ', ...
                                'sqrt(abs(Q)), so those pixels are drawn from the ', ...
                                'magnitude of a quadrature whose SIGN says the lock-in ', ...
                                'phase is wrong there. Treat them as unmeasured, not ', ...
                                'as signal.\n'], ...
                            j, gmSEQ.SweepParam(j), nNegQ, numel(Qj), ...
                            100 * nNegQ / numel(Qj));
                end
            end

            % No derived quantity is stored. Any combination of I and Q the
            % display or the analysis wants is formed on demand from these two
            % (see hc_WFContrast and the WFcontrast box), so there is exactly one
            % place where each number comes from.
            if i == 1
                gWide.I(:,:,j) = Ij;
                gWide.Q(:,:,j) = Qj;
            else
                gWide.I(:,:,j) = (gWide.I(:,:,j)*(i-1) + Ij) / i;
                gWide.Q(:,:,j) = (gWide.Q(:,:,j)*(i-1) + Qj) / i;
            end

            % Display faults must never abort an acquisition -- a mistyped display
            % expression, a degenerate colour limit, a closed axes. The data is
            % already in gWide and on disk by the next line either way.
            try
                % Ij/Qj are THIS pass's frame-summed, dark-subtracted images
                % for this point. The display banks one ROI sample per pass from
                % them; the scatter of those samples across passes is the error
                % bar. Passed as arguments rather than parked in gWide, because
                % TemporarySave writes the whole of gWide to disk at every point.
                DisplayWidefield(handles, j, roi, [], Ij, Qj);
            catch MEdisp
                fprintf(2, ['[Widefield] WARNING: display failed at point %d (%s); ', ...
                            'acquisition continues.\n'], j, MEdisp.message);
            end

            TemporarySave(BackupFile);
            drawnow;
            if ~gmSEQ.bGo; break; end
            j = j + 1;
        end
        SaveWidefieldAve(handles, passI, passQ);
        if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg; break; end
    end
catch ME
    try; gCam.stopAcq(); catch; end
    if InstrumentEnabled('nidaq'); try; KillAllTasks; catch; end; end
    if srsOn; gSG.bOn = 0; SignalGeneratorFunctionPool('RFOnOff'); end
    % Put the objective back before anything else can act on the error -- a
    % failed run must not leave it parked at an arbitrary Z. Deliberately a plain
    % restore, not FinishZFocus: a partial stack from a failed run is no basis for
    % chasing a focus peak.
    RestoreZ(bZSweep && bZMoveEnabled, zStart);
    set(handles.runningText, 'string', 'Error!')
    if pbOn; PBFunctionPool('PBON', 2^SequencePool('PBDictionary','GreenAOM')); end
    rethrow(ME);
end

% Park at best focus (hc_ZScan, interior peak) or restore the starting Z.
FinishZFocus(handles, bZSweep, bZMoveEnabled, zStart, roi, N, ccfg);

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
SaveWidefield(handles);
set(handles.runningText, 'string', 'Stopped')
disp('Widefield experiment completed!')

function FinishZFocus(handles, bZSweep, bZMoveEnabled, zStart, roi, N, ccfg)
% FinishZFocus(...)  End-of-run objective placement for hc_ZScan.
%
% Parks the objective at the best-focus Z when the focus curve actually justifies
% it, and otherwise restores the starting Z. Three ways it declines to move, all
% of which matter:
%
%  * peak on the first or last Z -- the curve was still rising at the edge of the
%    range, so the real focus is OUTSIDE what was scanned and the "best" point is
%    just the closest the sweep got. Moving there would be confidently wrong.
%  * flat curve (low confidence) -- an argmax exists but it is noise.
%  * focusGoToBest disabled in WidefieldConfig.
%
% On success it also redraws axes2 with the best-Z image while leaving axes3
% showing the whole score-vs-Z curve, so the last thing on screen is the image
% the objective is now actually sitting at.
global gWide gScan

if ~bZSweep || isempty(gWide) || ~isfield(gWide, 'focus') || isempty(gWide.focus)
    RestoreZ(bZSweep && bZMoveEnabled, zStart);
    return;
end

f    = gWide.focus;
fcfg = hc_FocusConfig(ccfg);

% Report the curve before deciding, so the console record is the same either way.
fprintf('[Focus] %s: peak at Z = %g um (scanned point %d of %d), confidence %.2f.\n', ...
        f.metric, f.zBest, f.iBest, N, f.conf);
if isfield(f, 'validFrac')
    fprintf('[Focus] Scored %d pixels (%.1f%% of the frame).\n', ...
            f.nValid, 100 * f.validFrac);
end
if isfield(f, 'fallback') && f.fallback
    fprintf(2, ['[Focus] NOTE: the mask fell back to the plain frame interior, so ', ...
                'the stripline shadow was NOT rejected and this peak may be the ', ...
                'stripline plane rather than the diamond.\n']);
end

if ~fcfg.goToBest
    fprintf('[Focus] focusGoToBest is off; restoring the starting Z.\n');
    RestoreZ(bZSweep && bZMoveEnabled, zStart);
    return;
end

if ~f.isInterior
    fprintf(2, ['[Focus] Peak sits on the %s scanned Z (%g um), so true focus is ', ...
                'OUTSIDE this range -- not moving there. Extend the sweep %s ', ...
                'and rerun.\n'], ...
            ternary(f.iBest == 1, 'first', 'last'), f.zBest, ...
            ternary(f.iBest == 1, 'downward (lower From)', 'upward (higher To)'));
    RestoreZ(bZSweep && bZMoveEnabled, zStart);
    return;
end

if ~isfinite(f.conf) || f.conf < fcfg.minConf
    fprintf(2, ['[Focus] Focus curve is flat (confidence %.2f < %.2f): no real ', ...
                'peak to move to. Either the field has no structure to focus on, ', ...
                'or the mask removed what did. Restoring the starting Z.\n'], ...
            f.conf, fcfg.minConf);
    RestoreZ(bZSweep && bZMoveEnabled, zStart);
    return;
end

% Clamp to the same safe travel the sweep was validated against: the parabolic
% interpolation can land just outside a sweep that ran to the rails.
zGo = min(max(f.zBest, zLimit(ccfg, 'zMinUm', 0)), zLimit(ccfg, 'zMaxUm', 100));
if zGo ~= f.zBest
    fprintf('[Focus] Interpolated best Z %g um clamped to the safe range -> %g um.\n', ...
            f.zBest, zGo);
end

zParked = NaN;
if ~bZMoveEnabled
    fprintf('[Focus] Z moves are disabled this run; would have parked at %g um.\n', zGo);
else
    try
        ImageFunctionPool('WriteVoltage', {}, {}, {}, 'Obj_Piezo', zGo);
        if ~isempty(gScan) && isfield(gScan, 'FixVz')
            gScan.FixVz = zGo;
        end
        zParked = zGo;
        fprintf('[Focus] Objective parked at best focus, Z = %g um.\n', zGo);
    catch
        fprintf(2, ['[Focus] WARNING: could not move to the best-focus Z (%g um). ', ...
                    'The objective is wherever the last sweep point left it.\n'], zGo);
    end
end

% Leave axes2 showing the image the objective is now at, without truncating the
% score curve on axes3. jCurve = however many points the curve actually covers,
% which is < N if the run was stopped early.
try
    DisplayWidefield(handles, f.iBest, roi, numel(f.score));
catch
    % Display-only; never let a plotting hiccup mask a completed run.
end

% AFTER the redraw, because DisplayWidefield rebuilds gWide.focus from scratch and
% would otherwise wipe this -- and SaveWidefield reads it straight after, so the
% .h5 would lose focus_z_parked_um and the file would not record where the
% objective was actually left.
if isfinite(zParked) && ~isempty(gWide) && isfield(gWide, 'focus')
    gWide.focus.zParked = zParked;
end

function v = zLimit(ccfg, name, dflt)
% Safe-travel limit from WidefieldConfig, with a fallback.
v = dflt;
if isstruct(ccfg) && isfield(ccfg, name) && ~isempty(ccfg.(name)); v = ccfg.(name); end

function out = ternary(cond, a, b)
if cond; out = a; else; out = b; end

function RestoreAverage(v)
% RestoreAverage(v)  Put the GUI's Average count back after an hc_ZScan run.
% Called from an onCleanup, so it runs on both the normal and error exits, and
% only after SaveWidefield has recorded the count that actually ran.
global gmSEQ
gmSEQ.Average = v;

function tf = EODriveReady()
% EODriveReady()  Can 'Obj_Piezo' actually move right now?
% Both the loaded library and a non-zero handle are required; ImageNVC -> Start is
% the only thing that sets either (ImageFunctionPool.m:1352-1363).
global eohandle
tf = libisloaded('EO0x2DDrive') && ~isempty(eohandle) && ...
     isnumeric(eohandle) && isscalar(eohandle) && eohandle ~= 0;

function RestoreZ(bZSweep, zStart)
% RestoreZ(bZSweep, zStart)  Return the objective to where the Z stack started.
% No-op unless this was a Z sweep with a known starting position. Errors are
% swallowed: this runs on the error path too, where the original fault is the
% one worth reporting.
global gScan
if ~bZSweep || ~isfinite(zStart); return; end
try
    % Must go through the ImageFunctionPool dispatch, as the sweep loop does.
    % WriteVoltage is a PRIVATE subfunction of ImageFunctionPool.m -- it is not on
    % the path and there is no local copy here -- so calling it bare threw
    % 'Undefined function', was swallowed by the catch below, and left the
    % objective parked at the last Z of every stack while printing a warning that
    % looked like a hardware fault.
    ImageFunctionPool('WriteVoltage', {}, {}, {}, 'Obj_Piezo', zStart);
    if ~isempty(gScan) && isfield(gScan, 'FixVz')
        gScan.FixVz = zStart;
    end
    fprintf('[Widefield] Objective Z restored to %g um.\n', zStart);
catch
    fprintf(2, '[Widefield] WARNING: could not restore Z to %g um.\n', zStart);
end

function DisplayWidefield(handles, j, roi, jCurve, Ipass, Qpass)
% DisplayWidefield(handles, j, roi, jCurve)  Live widefield display for HeliCam runs.
%   axes2: image at sweep point j (contrast normally; intensity I for hc_Image)
%   axes3: ROI-mean of that quantity vs sweep parameter, through point jCurve
%          -- EXCEPT for hc_ZScan, where axes3 is the focus score vs Z instead
% roi = [] -> frame-center square; else [xc yc halfwidth] in pixels.
%
% jCurve (default j) decouples the image from the curve: the end of an hc_ZScan run
% redraws axes2 at the best-focus slice while leaving axes3 showing the whole
% sweep, so the final picture is the image the objective was actually parked at
% without the score curve appearing to stop early.
%
% Both quantities are read from gWide, which the sweep loop fills with ALREADY
% dark-subtracted arrays, so this display shows corrected data whenever a dark was
% applied. The title reports which dark that was, because the picture changes
% character completely between the two regimes: with no dark it is dominated by the
% ~517 per-pixel pedestal and its row structure, with one it is a near-zero-mean map
% of the actual light.
global gmSEQ gWide

if nargin < 4 || isempty(jCurve); jCurve = j; end
if nargin < 5; Ipass = []; end
if nargin < 6; Qpass = []; end

% --- What to display: a user-defined expression over I and Q ----------------
% Resolved fresh on every update (hc_WFExpr): the 'WFcontrast' GUI box wins, else
% the expression the sequence file declared in gmSEQ.WFcontrastExpr, else plain I.
% Editing the box mid-run therefore changes the next point's plot. hc_WFContrast
% never throws -- a bad expression falls back to I and marks the axis label -- so
% nothing here can interrupt an acquisition.
Iall = gWide.I;    % mean over frames of I, dark-subtracted
Qall = gWide.Q;    % mean over frames of Q, dark-subtracted
[expr, exprSrc]           = hc_WFExpr(handles);
[stack, qty, exprInfo]    = hc_WFContrast(Iall, Qall, expr);

isZScan = strcmp(char(string(gmSEQ.name)), 'hc_ZScan');

img = stack(:,:,j);
[H, W] = size(img);

% --- hc_ZScan: focus mask + score, recomputed over everything acquired so far --
% Recomputing from scratch each update (rather than appending one score) keeps the
% whole displayed curve consistent with ONE mask. Scores computed against
% different masks are not comparable, and the mask legitimately changes as more Z
% points arrive and widen the union of the shadow. A few conv2 calls on 542x512 is
% milliseconds, so there is nothing to save by being clever here.
zFocus = [];
if isZScan
    try
        fcfg  = hc_FocusConfig([]);
        % Iall, NOT stack: focus is a measurement of how sharp the LIGHT is, so it
        % has to run on the intensity image whatever expression the display is
        % showing. Scoring 'I/Q' or 'I-Q' would hand the mask and the Tenengrad
        % metric something that is not a light level at all.
        sub   = Iall(:,:,1:jCurve);
        [valid, minfo] = hc_FocusMask(sub, fcfg);
        [F, finfo]     = hc_FocusMetric(sub, valid, fcfg);
        zAxis          = gmSEQ.SweepParam(1:jCurve) * gmSEQ.ScaleT;
        [zBest, iBest, isInterior, conf] = hc_FocusPeak(zAxis, F);

        zFocus = struct('score', F, 'metrics', finfo.metrics, 'metric', finfo.metric, ...
                        'valid', valid, 'zBest', zBest, 'iBest', iBest, ...
                        'isInterior', isInterior, 'conf', conf, ...
                        'nValid', minfo.nValid, 'validFrac', minfo.validFrac, ...
                        'fallback', minfo.fallback, 'looksUndarked', minfo.looksUndarked, ...
                        'params', fcfg);
        gWide.focus = zFocus;
    catch ME
        % A focus-analysis fault must not take down the acquisition display.
        fprintf(2, '[Focus] WARNING: focus analysis failed (%s).\n', ME.message);
        zFocus = [];
    end
end

% --- axes2: 2-D image ---
imagesc(handles.axes2, img);
colormap('pink')
axis(handles.axes2, 'image');
colorbar(handles.axes2);

% Colour limits from the WHOLE swept dataset, not from this one slice.
%
% imagesc autoscales to whatever slice it is handed, so the mapping changed at
% every sweep point: a point with little contrast had its noise floor stretched
% over the full colormap while a high-contrast point looked fine, and nothing
% could be compared between them by eye. Taking min/max over every acquired
% slice fixes the scale, so brightness changing across the sweep is something
% you can actually SEE.
%
% The limits grow during the first pass as points arrive, then stop moving once
% the sweep has been round once -- from pass 2 onward the scale is stable and the
% image only refines as the average improves.
%
% 'all'/'omitnan' rather than stack(:) so a 46 MB stack is not copied on every
% update; hc_WFContrast has already mapped Inf to NaN, so NaN is the only
% non-finite left to omit.
% ...unless the colorBarMin/colorBarMax boxes are overriding it. Those win over
% everything: the whole point of a manual scale is to hold still while the data
% moves, so that two runs, or two points, can be compared against a fixed ruler.
% Resolved live off the widgets by hc_WFClim, so ticking the box or retyping a
% limit mid-run takes effect at the next sweep point.
[climMan, climSrc] = hc_WFClim(handles);
if ~isempty(climMan)
    clim(handles.axes2, climMan);
else
    loC = min(stack, [], 'all', 'omitnan');
    hiC = max(stack, [], 'all', 'omitnan');
    if isfinite(loC) && isfinite(hiC) && hiC > loC
        padC = 0.05 * (hiC - loC);          % a little headroom top and bottom
        clim(handles.axes2, [loC - padC, hiC + padC]);
    end
end
darkTag = 'NONE';
if ~isempty(gWide) && isfield(gWide,'darkSource') && ~isempty(gWide.darkSource)
    darkTag = char(string(gWide.darkSource));
end
if strcmpi(darkTag, 'none'); darkTag = 'NONE'; end   % shout the uncorrected case
% Say where the expression came from, so a stale GUI box cannot be mistaken for
% the sequence's own default, and report any pixels the expression itself made
% non-finite (e.g. 'I/Q' where Q is zero) rather than leaving them as silent gaps.
exprTag = '';
if ~strcmp(exprSrc, 'default'); exprTag = [' (' exprSrc ')']; end
nfTag = '';
if exprInfo.nNonFinite > 0
    nfTag = sprintf('   [%d non-finite]', exprInfo.nNonFinite);
end
% Same reasoning for the colour scale: a manual override is invisible in the
% picture itself, and a REJECTED one is worse -- the boxes look set, the tick
% looks on, and the scale is quietly still automatic. Say which is in force, and
% only when it is not the plain automatic case, so the usual title is unchanged.
climTag = '';
switch climSrc
    case 'GUI';     climTag = sprintf('   [clim: GUI %g..%g]', climMan(1), climMan(2));
    case 'invalid'; climTag = '   [clim: GUI INVALID -> auto]';
end
title(handles.axes2, sprintf('%s%s @ %g %s   [dark: %s]%s%s', ...
    qty, exprTag, gmSEQ.SweepParam(j)*gmSEQ.ScaleT, gmSEQ.ScaleStr, darkTag, climTag, nfTag));

% --- ROI box ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isZScan && ~isempty(zFocus)
    % The ROI plays no part in the focus score, so drawing its box here would
    % only imply it did. Outline the scored region instead: the mask is otherwise
    % an invisible parameter, and seeing it hug the stripline shadow with visible
    % clearance is the whole basis for trusting the number on axes3.
    hold(handles.axes2, 'on');
    try
        contour(handles.axes2, double(zFocus.valid), [0.5 0.5], 'c', 'LineWidth', 1);
    catch
        % contour can object to a degenerate all-true / all-false mask; the image
        % itself is the important part.
    end
    hold(handles.axes2, 'off');
else
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
end

if isZScan && ~isempty(zFocus)
    % --- axes3: focus score vs Z (this IS the answer the scan exists to give) ---
    zAxis = gmSEQ.SweepParam(1:jCurve) * gmSEQ.ScaleT;
    plot(handles.axes3, zAxis, zFocus.score, '-o');
    hold(handles.axes3, 'on');
    if isfinite(zFocus.iBest)
        plot(handles.axes3, zAxis(zFocus.iBest), zFocus.score(zFocus.iBest), ...
             'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r');
    end
    MarkCurrentSweepPoint(handles.axes3, j);
    hold(handles.axes3, 'off');
    xlabel(handles.axes3, gmSEQ.ScaleStr);
    ylabel(handles.axes3, ['focus score (' zFocus.metric ')']);
    grid(handles.axes3, 'on');

    % Everything needed to judge the peak, in the title: where it is, whether it
    % is really a peak (conf), how much of the frame it was measured on, and a
    % shout if the peak is at the edge of the range and so probably outside it.
    edgeTag = '';
    if ~zFocus.isInterior; edgeTag = '  AT RANGE EDGE'; end
    fbTag = '';
    if zFocus.fallback; fbTag = '  MASK FALLBACK'; end
    title(handles.axes3, sprintf('best %g %s   conf %.2f   %.0f%% px%s%s', ...
        zFocus.zBest, gmSEQ.ScaleStr, zFocus.conf, 100*zFocus.validFrac, edgeTag, fbTag));
else
    % --- axes3: ROI-mean trace vs sweep ---
    % NaN-safe per point: a plain mean() would return NaN for the whole ROI as
    % soon as one pixel divided by zero, wiping out an otherwise good point. Done
    % with a loop rather than nanmean/omitnan to stay off the Statistics Toolbox,
    % which nothing else in this repo depends on.
    roiSub = stack(yr, xr, :);
    trace  = NaN(1, size(roiSub, 3));
    for kTr = 1:size(roiSub, 3)
        vTr = roiSub(:,:,kTr);
        vTr = vTr(isfinite(vTr));
        if ~isempty(vTr); trace(kTr) = mean(vTr); end
    end
    % Draw every point that HAS data, not 1:jCurve.
    %
    % j restarts at 1 on each Average pass, and plot() clears the axes, so
    % plotting 1:jCurve redrew a single point at the start of pass 2 and the
    % curve appeared to be wiped. The data was never lost -- gWide holds the
    % running average for all N points -- it simply was not being drawn. Keying
    % off the finite entries instead means the curve fills in during pass 1 and
    % then STAYS up from pass 2 onward, refining in place as the average
    % improves.
    % --- bank ONE ROI sample for this pass, at this point --------------------
    % One sample per (pass, point): the ROI-mean of the display expression on
    % this pass's frame-summed images. Their scatter ACROSS PASSES is the error
    % bar, and that is correct without adding anything for the frames -- the
    % frame noise is already inside each pass value, because a pass value is a
    % sum over its frames.
    %
    % So roiN counts PASSES, not frames: after p passes, roiN(j) = p.
    if ~isempty(Ipass) && ~isempty(Qpass)
        try
            % Expression changed? The running state is expression-specific and
            % cannot be re-derived, so discard rather than mix.
            if ~strcmp(gWide.roiExpr, expr)
                gWide.roiN(:)    = 0;
                gWide.roiMean(:) = 0;
                gWide.roiM2(:)   = 0;
                gWide.roiExpr    = expr;
                gWide.roiLast    = [0 0];
            end

            iAve = 1;
            if isfield(gmSEQ,'iAverage') && ~isempty(gmSEQ.iAverage)
                iAve = round(gmSEQ.iAverage);
            end

            % Never accumulate the same (pass, point) twice. Only one call does
            % so today, but FinishZFocus redraws and any future redraw would
            % silently inflate n and shrink every bar.
            if ~isequal(gWide.roiLast, [iAve j]) && j >= 1 && j <= numel(gWide.roiN)
                pSlice = hc_WFContrast(Ipass, Qpass, expr);
                vP = pSlice(yr, xr);
                vP = vP(isfinite(vP));
                if ~isempty(vP)
                    v = mean(vP);

                    % Welford: folds one sample into the running mean/M2 with no
                    % subtraction of large sums, so M2 >= 0 by construction --
                    % for identical samples delta is exactly 0 and M2 stays 0.
                    % Matters more now that values are nFrames x larger.
                    nW     = gWide.roiN(j) + 1;
                    delta  = v - gWide.roiMean(j);
                    mW     = gWide.roiMean(j) + delta / nW;
                    delta2 = v - mW;
                    gWide.roiN(j)    = nW;
                    gWide.roiMean(j) = mW;
                    gWide.roiM2(j)   = gWide.roiM2(j) + delta * delta2;
                    gWide.roiLast    = [iAve j];
                end
            end
        catch
            % Statistics are a nicety; never let them break the display.
        end
    end

    % --- point and error bar from the running state --------------------------
    % Plotting roiMean rather than the running-average curve keeps the dot at the
    % centre of its own error bar by construction. For a linear expression the
    % two are identical; for a ratio they differ slightly, and a bar that did not
    % straddle its point would look like a bug.
    nS = gWide.roiN;
    mS = gWide.roiMean;
    mS(nS < 1) = NaN;
    eS = NaN(size(nS));
    ok2 = nS >= 2;
    eS(ok2) = sqrt(gWide.roiM2(ok2) ./ (nS(ok2) .* (nS(ok2) - 1)));

    useSamples = any(isfinite(mS));
    if useSamples
        yPlot = mS; ePlot = eS;
    else
        yPlot = trace; ePlot = NaN(size(trace));   % no samples yet: the raw trace
    end
    hasData = isfinite(yPlot);

    if any(hasData)
        xPlot = gmSEQ.SweepParam(hasData) * gmSEQ.ScaleT;
        yD    = yPlot(hasData);
        eD    = ePlot(hasData);
        if any(isfinite(eD))
            % errorbar treats NaN as "no bar", so points from a single pass get a
            % bare marker and the rest get bars -- which is exactly right.
            eD(~isfinite(eD)) = 0;
            errorbar(handles.axes3, xPlot, yD, eD, '-o');
        else
            plot(handles.axes3, xPlot, yD, '-o');
        end
    end
    hold(handles.axes3, 'on');
    MarkCurrentSweepPoint(handles.axes3, j);
    hold(handles.axes3, 'off');
    xlabel(handles.axes3, gmSEQ.ScaleStr);
    ylabel(handles.axes3, ['ROI ' qty]);
    grid(handles.axes3, 'on');
end
if numel(gmSEQ.SweepParam) > 1
    xlim(handles.axes3, sort([gmSEQ.SweepParam(1) gmSEQ.SweepParam(end)])*gmSEQ.ScaleT);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function MarkCurrentSweepPoint(ax, j)
% MarkCurrentSweepPoint(ax, j)  Red vertical line on axes3 at the sweep point
% that has just finished acquiring.
%
% Now that the curve persists across Average passes instead of being redrawn
% from scratch, there is no longer a growing right-hand end to show where the
% sweep is -- on pass 2 onward the whole trace is up at once. This line is what
% tells you which point was just measured, and it sweeps left to right once per
% pass.
%
% Drawn as a plot() spanning the current ylim rather than xline(), so it does not
% depend on a MATLAB release that has the axes-handle xline syntax. Call inside a
% hold(ax,'on') block, AFTER the data, so ylim is already settled.
%
% Silent no-op on anything unexpected: this is decoration, and a marker must
% never be the reason a display update fails mid-acquisition.
global gmSEQ
try
    if isempty(gmSEQ) || ~isfield(gmSEQ,'SweepParam') || isempty(gmSEQ.SweepParam)
        return;
    end
    if ~isscalar(j) || ~isfinite(j) || j < 1 || j > numel(gmSEQ.SweepParam)
        return;
    end
    sc = 1;
    if isfield(gmSEQ,'ScaleT') && ~isempty(gmSEQ.ScaleT) && isfinite(gmSEQ.ScaleT)
        sc = gmSEQ.ScaleT;
    end
    xNow = double(gmSEQ.SweepParam(j)) * sc;
    if ~isfinite(xNow); return; end
    yl = ylim(ax);
    plot(ax, [xNow xNow], yl, 'r-', 'LineWidth', 1);
    ylim(ax, yl);          % plot() can nudge the limits; put them back
catch
end

function [darkI, darkQ] = AcquireDarkRef(gCam, ccfg, H, W, mPoint, bFullReport)
% [darkI, darkQ] = AcquireDarkRef(gCam, ccfg, H, W [, mPoint, bFullReport])
% Capture ONE laser-off dark frame pair (GUI checkbox 'takeDarkRef').
%
% Normally called exactly once per run, from before the sweep and OUTSIDE the
% Average loop. The camera has already been configured at this point and is not
% touched again, so this dark is matched to the run's exposure / nPeriods /
% nFrames by construction -- which is the whole point of taking it here rather
% than loading a stored file that may have been captured at other settings. The
% camera's per-pixel noise is static at fixed settings, so one pair serves every
% sweep point and every average pass.
%
% mPoint (optional) breaks that "once per run" assumption on purpose, for
% hc_scan_exposure. There the swept parameter IS the exposure, so the pedestal --
% which is dark charge accumulated during the integration window -- changes from
% point to point and a single pair would be right at exactly one of them. The
% loop reconfigures the camera and then calls this with that point's sweep value,
% so each dark is matched to the exposure it will be subtracted from. Passing
% mPoint also builds the program at that value rather than at SweepParam(1).
%
% bFullReport (optional, default true) picks the three-line report over the
% one-line one; the per-point caller sets it only on its first call.
%
% The PB program is the SELECTED sequence's own, with the GreenAOM channel
% dropped -- that is the only light channel in any hc_* sequence, and each of
% them sets its program length with a dummy1 marker rather than with the laser
% (hc_Image.m:39, hc_T1.m:60, hc_Rabi.m:66, hc_ODMR.m:58), so removing the laser
% cannot shorten the program or move a CamRef edge. The lock-in therefore sees
% exactly the reference train the real run will deliver.
%
% MW channels are deliberately left in: the SRS is still off at this point in the
% run, and microwaves do not illuminate the sensor.
global gmSEQ

% Build the program at the FIRST sweep point, unless the caller named one. For
% hc_Rabi/hc_T1/hc_ODMR the swept parameter stretches the idle gap between CamRef
% edges but not the camera's exposure register (that comes from CtrGateDur), and
% dark charge accumulates only during the exposure window -- so the point chosen
% there does not matter. hc_scan_exposure is the exception that motivates the
% argument: it sweeps CtrGateDur itself.
% SequencePool rmfields CHN and the sequence rebuilds it, so nBefore has to be
% counted after this call, not before.
bPerPoint = (nargin >= 5) && ~isempty(mPoint);
if nargin < 6 || isempty(bFullReport); bFullReport = true; end
if bPerPoint
    gmSEQ.m = mPoint;
else
    gmSEQ.m = gmSEQ.SweepParam(1);
    mPoint  = gmSEQ.m;   % only ever used in the report below
end
SequencePool(string(gmSEQ.name));

nBefore   = numel(gmSEQ.CHN);
gmSEQ.CHN = gmSEQ.CHN([gmSEQ.CHN.PBN] ~= SequencePool('PBDictionary','GreenAOM'));
nDropped  = nBefore - numel(gmSEQ.CHN);
if nDropped == 0
    fprintf(2, ['[Widefield] WARNING: dark reference found no GreenAOM channel to ', ...
                'drop in %s. If that sequence drives the laser on another channel, ', ...
                'this "dark" is NOT dark.\n'], char(string(gmSEQ.name)));
end

for k = 1:numel(gmSEQ.CHN)
    gmSEQ.CHN(k).T      = gmSEQ.CHN(k).T      / 1e9;
    gmSEQ.CHN(k).DT     = gmSEQ.CHN(k).DT     / 1e9;
    gmSEQ.CHN(k).Delays = gmSEQ.CHN(k).Delays / 1e9;
end

pbOn = InstrumentEnabled('pulseblaster');
if pbOn; PBFunctionPool('PreprocessPBSequence', gmSEQ); end

try
    % Same burst-aware timeout as the sweep: the dark reference runs the very
    % same PB program (minus the laser), so it takes just as long and must not be
    % the thing that times out first.
    tmoMs = hc_AcqTimeoutMs(ccfg, gmSEQ.CHN, gmSEQ.nPBPeriods);

    gCam.startAcq();
    if pbOn; Run_PB_Sequence(); end
    [I, Q] = gCam.readIQ(tmoMs);
    gCam.stopAcq();
catch ME
    try; gCam.stopAcq(); catch; end
    error('RunSequence:DarkRefFailed', ...
          ['Dark reference acquisition failed (%s). takeDarkRef is checked, so the ', ...
           'run is stopped rather than proceeding with an uncorrected measurement.'], ...
          ME.message);
end

% Plain frame means, NO sign flip. readIQ already applies the polarity inversion
% (HeliCamInterface.m:303-304: the C4's demodulation weight is the negative of the
% manual's Eq. 5.54), so these land in the same sign-corrected domain as the sweep
% loop's ref/sig below and subtract cleanly there. Negating again here would flip
% the dark relative to the data and DOUBLE the pedestal instead of removing it.
darkI = mean(I, 3);
darkQ = mean(Q, 3);

if ~isequal(size(darkI), [H W])
    error('RunSequence:DarkRefSize', ...
          ['Dark reference is %dx%d but this run is %dx%d. Subtracting it would be ', ...
           'meaningless.'], size(darkI,1), size(darkI,2), H, W);
end

% Full report, or one compact line. The per-point caller runs this N x Average
% times and three lines apiece would bury every other message in the console, so
% it asks for the full report on its first call only. Verbosity is an ARGUMENT
% rather than a persistent counter on purpose: a counter would survive the run
% that set it and leave the next run's first dark reported as if it were a
% continuation.
if bFullReport
    if bPerPoint
        fprintf(['[Widefield] Dark reference: FRESH, per sweep point, first at gate ', ...
                 '%g ns (%d laser channel(s) dropped, %d frames). Later points report ', ...
                 'one line each.\n'], mPoint, nDropped, size(I,3));
    else
        fprintf(['[Widefield] Dark reference: FRESH, acquired once for this run ', ...
                 '(%d laser channel(s) dropped, %d frames).\n'], nDropped, size(I,3));
    end
    fprintf(['[Widefield]   dark I: mean %.6g, std %.4g, p-p %.4g | ', ...
             'dark Q: mean %.6g, std %.4g, p-p %.4g\n'], ...
            mean(darkI(:),'omitnan'), std(darkI(:),'omitnan'), ...
            max(darkI(:)) - min(darkI(:)), ...
            mean(darkQ(:),'omitnan'), std(darkQ(:),'omitnan'), ...
            max(darkQ(:)) - min(darkQ(:)));
else
    fprintf(['[Widefield]   dark @ gate %g ns: I mean %.6g std %.4g | ', ...
             'Q mean %.6g std %.4g\n'], ...
            mPoint, mean(darkI(:),'omitnan'), std(darkI(:),'omitnan'), ...
            mean(darkQ(:),'omitnan'), std(darkQ(:),'omitnan'));
end

function ccfg = ConfigureExposure(gCam, ccfg, gateNs, overheadNs, nBlankCfg, nCouplingExtra)
% ccfg = ConfigureExposure(gCam, ccfg, gateNs, overheadNs, nBlankCfg, nCouplingExtra)
% Turn a ctr-gate width into a camera exposure, write it, and re-budget the PB
% CamRef edge count from what the camera actually ended up holding.
%
% One owner for the whole chain, because there are now two callers: the pre-sweep
% configuration (every hc_* sequence) and the per-point retune inside the loop
% (hc_scan_exposure only). Splitting these three steps across the two sites is
% what would let them drift, and the drift is silent -- a stale edge budget shows
% up as nothing but a readIQ timeout.
%
% The re-budget is NOT optional after a reconfiguration. Exposure sets the target
% reference frequency (t_s = sensitivity / (4*f_ref), see
% HeliCamInterface.exposureToReferenceFrequency), and the camera reports the
% effective time constant only afterwards, in a read-only register it is free to
% land elsewhere on. Periods per frame = actual time constant + actual blank + the
% AC coupling background period, so budgeting from the targets can leave the burst
% short of CamRef edges.
global gmSEQ

% Floor derived from the camera's reference-frequency grid, not typed in --
% hc_MinExposureNs explains why the literal that used to sit here (1825 ns) was
% itself out of range and turned a clamp into a GenICam exception.
expoNs = max(gateNs - overheadNs, hc_MinExposureNs(ccfg.sensitivity));
gmSEQ.exposureSeconds = expoNs * 1e-9;
ccfg.exposureSeconds  = gmSEQ.exposureSeconds;

gCam.configLockInMode(ccfg);

if ismethod(gCam, 'readActualPeriods')
    [nPerAct, nBlankAct] = gCam.readActualPeriods();
    if ~isnan(nPerAct) && nPerAct > 0
        if isnan(nBlankAct); nBlankAct = nBlankCfg; end
        needAct = (nPerAct + nBlankAct + nCouplingExtra) * gmSEQ.nFrames;
        if needAct ~= gmSEQ.nPBPeriods
            fprintf(2, ['[Widefield] Edge budget CORRECTED from the camera: %d -> %d ', ...
                        'periods (%d frames x (%g actual + %g blank + %d AC)). PB was ', ...
                        'about to run %d periods, starving the burst.\n'], ...
                    gmSEQ.nPBPeriods, needAct, gmSEQ.nFrames, nPerAct, nBlankAct, ...
                    nCouplingExtra, gmSEQ.nPBPeriods);
            gmSEQ.nPBPeriods = needAct;
            gmSEQ.Repeat     = needAct;
            gmSEQ.Samples    = needAct;
        end
    end
end

function [darkI, darkQ] = LoadDarkRefForRun(cfg, H, W)
% [darkI, darkQ] = LoadDarkRefForRun(cfg, H, W)  Fetch the stored dark
% reference (hc_DarkRef) for subtraction during this run, or [] to skip.
%
% Skips quietly when disabled in WidefieldConfig or when none is stored -- a
% missing dark is a normal state, not an error. Refuses one whose frame size
% differs (subtracting it would be meaningless), and WARNS but proceeds on a
% settings mismatch: the pedestal scales with exposure/nPeriods/nFrames, so a
% dark taken at other settings subtracts the wrong amount. nPeriods matters
% most -- 20 -> 100 moved the decoded level by ~4x on this camera.
global gmSEQ

darkI = [];
darkQ = [];

if isfield(cfg,'subtractDarkRef') && ~cfg.subtractDarkRef
    fprintf('[Widefield] Dark subtraction: OFF (disabled in WidefieldConfig).\n');
    return
end

try
    D = hc_DarkRef('load');
catch
    fprintf(['[Widefield] Dark subtraction: OFF (none stored). Capture one with ', ...
             'the light blocked via hc_DarkRef(''save''), or import a saved run ', ...
             'with hc_DarkRef(''import'', <file.h5>).\n']);
    return
end

% hc_DarkIQ accepts both the current I/Q field names and the pre-rename
% reference/rawsignal ones, so a dark captured months ago still loads.
[dI, dQ, darkLegacy] = hc_DarkIQ(D);
if isempty(dI) || ~isequal(size(dI), [H W])
    fprintf(2, ['[Widefield] Dark subtraction: OFF -- stored dark is %s but this ', ...
                'run is %dx%d. Recapture it.\n'], mat2str(size(dI)), H, W);
    return
end
if darkLegacy
    fprintf(['[Widefield] Dark reference uses the legacy reference/rawsignal field ', ...
             'names; read as I/Q.\n']);
end

darkI = dI;
if ~isempty(dQ) && isequal(size(dQ), [H W])
    darkQ = dQ;
else
    darkQ = zeros(H, W);   % I-only dark: leave Q untouched rather than guess
    fprintf(2, '[Widefield] Dark reference has no Q frame; Q left uncorrected.\n');
end

fprintf('[Widefield] Dark subtraction: ON (pedestal I %.6g, Q %.6g).\n', ...
        mean(darkI(:), 'omitnan'), mean(darkQ(:), 'omitnan'));

% Warn on the settings the pedestal depends on.
if isfield(D,'settings') && isstruct(D.settings)
    f = {'exposureSeconds','nPeriods','nFrames'};
    for k = 1:numel(f)
        if ~isfield(D.settings, f{k}) || ~isfield(gmSEQ, f{k}); continue; end
        b = D.settings.(f{k});
        a = double(gmSEQ.(f{k}));
        if isnan(b) || ~isscalar(a); continue; end
        if abs(a - b) > 1e-12 * max(1, abs(b))
            fprintf(2, ['[Widefield]   WARNING: dark was taken at %s = %g but this ', ...
                        'run uses %g. The pedestal scales with it, so the ', ...
                        'subtraction is wrong.\n'], f{k}, b, a);
        end
    end
end

function SaveWidefieldAve(handles, Idat, Qdat)
% SaveWidefieldAve(handles, Idat, Qdat)  Write ONE average pass's own (non-
% cumulative) images to <name>_<date>_Ave_<xxx>_<yyy>.h5. Mirrors
% SaveIgorText_Average.m: xxx is the run ID CreateSavePath_Ave assigned once
% when Run was clicked (shared with the final save below), yyy increments
% once per completed average pass. Also mirrors its GUI update
% (handles.textFileNameAve.String).
global gWide

[base, dateStr, name, xxx] = WidefieldRunStem();
tag  = sprintf('%s_%s_Ave_%s', name, dateStr, xxx);
stem = char(fullfile(base, tag));

% yyy: collision-safe, independent of the confocal .txt counter (this file is
% .h5, so it needs its own check against existing .h5 files).
n = 1;
while exist(sprintf('%s_%03d.h5', stem, n), 'file'); n = n + 1; end
fname     = sprintf('%s_%03d.h5', stem, n);
shortName = sprintf('%s_%03d.h5', tag, n);

sweepParam = [];
if ~isempty(gWide) && isfield(gWide, 'SweepParam'); sweepParam = gWide.SweepParam; end
% bWriteDark = false: the dark is one pair for the whole run, identical in every
% pass, so copying it into each snapshot would add megabytes and no information.
% The dark_source / dark_subtracted attributes still say what was applied.
WriteWidefieldH5(fname, Idat, Qdat, sweepParam, false);

% No console print here: one line per average pass floods the command window
% on a long run. The GUI field below already shows the latest pass filename,
% and SaveWidefield still prints the final averaged file.
if ~isempty(handles) && isfield(handles, 'textFileNameAve')
    handles.textFileNameAve.String = shortName;
end

function SaveWidefield(handles)
% SaveWidefield(handles)  Write the finished, fully-averaged widefield run to
% <name>_<date>_<xxx>.h5 (no "_Ave" tag) -- the widefield counterpart of
% SaveIgorText.m's final save, reusing the SAME run ID xxx that
% SaveWidefieldAve tagged every per-average snapshot with. Stores reference
% the two lock-in quadratures I and Q -- both already sign-corrected by readIQ
% and dark-subtracted -- plus this run's dark_I/dark_Q. No derived quantity is
% stored: any combination of I and Q is formed on read. Also mirrors
% SaveIgorText.m's GUI update
% (handles.textFileName.String).
global gmSEQ gWide

% Both quadratures, because WriteWidefieldH5 dereferences gWide.I and gWide.Q on
% the same line below -- testing only one would let a half-built gWide past this
% guard and error one line later instead of returning quietly. Current names
% only: the legacy reference/rawsignal spellings still have to be honoured when
% reading FILES (hc_LoadIQ does that), but the live gWide is rebuilt with I/Q on
% every widefield run, so accepting the old names here would just clear the guard
% and then fail on the missing gWide.I.
if isempty(gWide) || ~isfield(gWide,'I') || ~isfield(gWide,'Q'); return; end

[base, dateStr, name, xxx] = WidefieldRunStem();
tag       = sprintf('%s_%s_%s', name, dateStr, xxx);   % no "_Ave" -- final result
fname     = char(fullfile(base, [tag '.h5']));
shortName = [tag '.h5'];

% bWriteDark = true: the final file is the complete record of the run, so it
% carries the dark frames themselves and the subtraction stays reversible.
WriteWidefieldH5(fname, gWide.I, gWide.Q, gWide.SweepParam, true);

if ~isempty(handles) && isfield(handles, 'textFileName')
    handles.textFileName.String = shortName;
end

fprintf('[Widefield] Saved %s\n', fname);

function [base, dateStr, name, xxx] = WidefieldRunStem()
% [base, dateStr, name, xxx] = WidefieldRunStem()  Common pieces of the
% widefield filename: dated save folder, date string, sanitized sequence name,
% and the run ID xxx that CreateSavePath_Ave assigned once when Run was
% clicked (parsed back out of gSaveDataAve.file, e.g.
% 'hc_Image_2026-8-12_Ave_003.txt' -> xxx = '003'). Shared by
% SaveWidefieldAve and SaveWidefield so every file from one run carries the
% same xxx, matching the confocal path's <name>_Ave_xxx / <name>_xxx scheme.
global gmSEQ gSaveDataAve

pth     = char(string(gSaveDataAve.path));
base    = regexprep(pth, '[\\/]+$', '');            % drop trailing separator
toks    = regexp(base, '[\\/]', 'split');
dateStr = toks{end};                                % '<YYYY-M-D>'
if isempty(dateStr)
    dateStr = datestr(datetime('now'), 'yyyy-mm-dd');
end
name = regexprep(char(string(gmSEQ.name)), '\W', '');

xxx = '001';
m = regexp(char(string(gSaveDataAve.file)), '_Ave_(\d+)\.txt$', 'tokens', 'once');
if ~isempty(m); xxx = m{1}; end

function WriteWidefieldH5(fname, Idat, Qdat, sweepParam, bWriteDark)
% WriteWidefieldH5(fname, Idat, Qdat, sweepParam, bWriteDark)  Datasets + metadata
% shared by both the per-average snapshot and the final-average file.
%
% bWriteDark also stores the run's dark frames as /dark_I and /dark_Q. Only the
% final file sets it: there is exactly ONE dark pair per run, applied unchanged to
% every sweep point and every average pass, so duplicating it into each snapshot
% would cost megabytes for no new information.
global gmSEQ gSG gWide

if nargin < 5 || isempty(bWriteDark); bWriteDark = false; end

sz = size(Idat);
if numel(sz) < 3; sz(3) = 1; end

% Datasets (chunked + gzip; chunk a single frame for partial reads).
chunk = [sz(1) sz(2) 1];
% /I and /Q, named for what they are. Files written before this rename carry
% /reference (I) and /rawsignal (Q); hc_LoadIQ and analysis/wf_viewer.py read
% either spelling, so old data stays openable.
h5create(fname, '/I', sz, 'Datatype','double', 'ChunkSize',chunk, 'Deflate',4);
h5write (fname, '/I', Idat);
h5create(fname, '/Q', sz, 'Datatype','double', 'ChunkSize',chunk, 'Deflate',4);
h5write (fname, '/Q', Qdat);
if ~isempty(sweepParam)
    h5create(fname, '/sweep_param', [1 numel(sweepParam)], 'Datatype','double');
    h5write (fname, '/sweep_param', sweepParam(:)');
end

% Root attributes: key scalars + full params as JSON.
h5writeatt(fname, '/', 'sequence',   char(string(gmSEQ.name)));
h5writeatt(fname, '/', 'sweep_unit', gmSEQ.ScaleStr);
% What I and Q actually are, so a file is interpretable without this source.
% No derived quantity is stored -- deliberately: which combination of I and Q
% carries the physics depends on where the sequence put the laser and MW, so
% naming one of them "the signal" in the file would assert something false.
% How the frames were reduced. Values are SUMMED over n_frames, not averaged --
% raw photon-count scale, and it makes the pass-to-pass scatter the whole
% uncertainty. Files written before 2026-08-25 hold frame MEANS and carry no such
% attribute, so a missing frame_reduction means 'mean'.
h5writeatt(fname, '/', 'frame_reduction', 'sum');
h5writeatt(fname, '/', 'iq_convention', ...
    ['I = sum over n_frames of (Q1 - Q3); Q = sum over n_frames of (Q2 - Q4); ' ...
     'both polarity-inverted by readIQ, and dark-subtracted as ' ...
     'n_frames x the per-frame pedestal'])
% Whether the stored dark reference was already removed from these arrays --
% without it there is no way to tell a corrected run from an uncorrected one.
if ~isempty(gWide) && isfield(gWide, 'darkSubtracted')
    h5writeatt(fname, '/', 'dark_subtracted', double(gWide.darkSubtracted));
end
% Which dark: 'fresh' = one laser-off burst taken by this run at exactly these
% camera settings; 'stored' = the wf_darkref.mat file, which may be stale;
% 'none' = nothing subtracted, so the arrays still carry the ~517 pedestal.
if ~isempty(gWide) && isfield(gWide, 'darkSource')
    h5writeatt(fname, '/', 'dark_source', char(string(gWide.darkSource)));
end

% The dark frames themselves (final file only). Stored in the SAME sign-corrected
% domain as /I and /Q -- readIQ already applied the polarity
% inversion before either was formed -- so adding them back undoes the correction.
if bWriteDark && ~isempty(gWide) && isfield(gWide,'darkI') && ~isempty(gWide.darkI)
    dsz = size(gWide.darkI);
    h5create(fname, '/dark_I', dsz, 'Datatype','double', 'ChunkSize',dsz, 'Deflate',4);
    h5write (fname, '/dark_I', gWide.darkI);
    if isfield(gWide,'darkQ') && isequal(size(gWide.darkQ), dsz)
        h5create(fname, '/dark_Q', dsz, 'Datatype','double', 'ChunkSize',dsz, 'Deflate',4);
        h5write (fname, '/dark_Q', gWide.darkQ);
    end
    % The undo recipe holds only when ONE pair was applied to every point. Under
    % hc_scan_exposure the dark is re-measured at each exposure and /dark_I is
    % just the last one, so promising that recipe there would be a lie -- and a
    % costly one, since it would look reversible. Say what is actually stored.
    bPerPointDark = isfield(gWide,'darkSource') && ...
                    strcmpi(char(string(gWide.darkSource)), 'fresh-per-point');
    if bPerPointDark
        h5writeatt(fname, '/', 'derived_dark', ...
            ['per-point dark: /dark_I and /dark_Q are the LAST sweep point''s pair, ' ...
             'not the one applied throughout. The subtraction is NOT reversible from ' ...
             'this file; /dark_point_I and /dark_point_Q give the frame-mean pedestal ' ...
             'actually removed at each point.']);
    else
        h5writeatt(fname, '/', 'derived_dark', ...
            'undo the dark subtraction with: raw I = /I + /dark_I; raw Q = /Q + /dark_Q');
    end
end

% Per-point pedestal trace (hc_scan_exposure). Frame-mean scalars, one per sweep
% point -- enough to see the pedestal track the swept exposure, which is the
% thing a reader of this file most needs to check before trusting a ratio.
if bWriteDark && ~isempty(gWide) && isfield(gWide,'darkPointI') && ...
        any(isfinite(gWide.darkPointI))
    psz = size(gWide.darkPointI);
    h5create(fname, '/dark_point_I', psz, 'Datatype','double');
    h5write (fname, '/dark_point_I', gWide.darkPointI);
    if isfield(gWide,'darkPointQ') && isequal(size(gWide.darkPointQ), psz)
        h5create(fname, '/dark_point_Q', psz, 'Datatype','double');
        h5write (fname, '/dark_point_Q', gWide.darkPointQ);
    end
end

% --- Focus analysis (hc_ZScan). Final file only: it describes the whole stack,
% not one average pass, so copying it into every snapshot would only invite
% reading a per-pass file's focus as if it were the run's answer. ------------
if bWriteDark && ~isempty(gWide) && isfield(gWide,'focus') && ~isempty(gWide.focus)
    f = gWide.focus;
    if isfield(f,'score') && ~isempty(f.score)
        h5create(fname, '/focus_score', [1 numel(f.score)], 'Datatype','double');
        h5write (fname, '/focus_score', double(f.score(:)'));
    end
    % Every metric, not just the one that drove the run, so the choice of metric
    % can be re-judged offline (hc_FocusCompare) without rescanning.
    if isfield(f,'metrics') && isstruct(f.metrics)
        mnames = fieldnames(f.metrics);
        for mi = 1:numel(mnames)
            v = f.metrics.(mnames{mi});
            if isempty(v); continue; end
            h5create(fname, ['/focus_metrics/' mnames{mi}], [1 numel(v)], 'Datatype','double');
            h5write (fname, ['/focus_metrics/' mnames{mi}], double(v(:)'));
        end
    end
    % The mask itself: without it the scores cannot be reproduced or checked.
    if isfield(f,'valid') && ~isempty(f.valid)
        vsz = size(f.valid);
        h5create(fname, '/focus_mask', vsz, 'Datatype','uint8', 'ChunkSize',vsz, 'Deflate',4);
        h5write (fname, '/focus_mask', uint8(f.valid));
    end
    h5writeatt(fname, '/', 'focus_metric',         char(string(f.metric)));
    h5writeatt(fname, '/', 'focus_best_z_um',      f.zBest);
    h5writeatt(fname, '/', 'focus_best_index',     f.iBest);
    h5writeatt(fname, '/', 'focus_peak_interior',  double(f.isInterior));
    h5writeatt(fname, '/', 'focus_confidence',     f.conf);
    h5writeatt(fname, '/', 'focus_valid_fraction', f.validFrac);
    h5writeatt(fname, '/', 'focus_mask_fallback',  double(f.fallback));
    if isfield(f,'zParked'); h5writeatt(fname, '/', 'focus_z_parked_um', f.zParked); end
    if isfield(f,'params') && isstruct(f.params)
        h5writeatt(fname, '/', 'focus_dark_frac',  f.params.darkFrac);
        h5writeatt(fname, '/', 'focus_erode_px',   f.params.erodePx);
        h5writeatt(fname, '/', 'focus_bright_pct', f.params.brightPct);
    end
end
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



