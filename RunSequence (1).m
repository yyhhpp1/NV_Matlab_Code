function RunSequence(hObject, eventdata, handles)
[y,Fs] = audioread('WindowsNotify.wav');
BackupFile = 'D:\MATLAB_Code\MATLAB_Code\Data\TempDataBackup\Temp.mat';

global gmSEQ gSG tmax hCPS gSG2 gSaveDataAve
%gSG3

gmSEQ.bGo=1;
InitializeData(handles);

disp(strcat('Commencing ',{' '},string(gmSEQ.name), ' sequence...'))
drawnow;
% adding an alternating fucntion for cooling/heating sequence
% by Chong 7/20/2020
if gmSEQ.Alternate
    % only works for sequence with name
    if strcmp(gmSEQ.name, 'SpecialCooling2_FixN_MeasSeparate') || strcmp(gmSEQ.name, 'SpecialCooling')
        
        % saving for each average
        
        CreateSavePath_Ave()
        
        
        gmSEQ.signal_2=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference_2=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference2_2=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference3_2=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference4_2=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference5_2=NaN(1,gmSEQ.NSweepParam);
        
        % Save for each average
        gmSEQ.signal_Ave =NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference2_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference3_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference4_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference5_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.signal_2_Ave =NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference_2_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference2_2_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference3_2_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference4_2_Ave=NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference5_2_Ave=NaN(1,gmSEQ.NSweepParam);
        
        
       
        gmSEQ.refCounts=Track('Init');
        SignalGeneratorFunctionPool('SetMod');
        SignalGeneratorFunctionPool('WritePow');
        SignalGeneratorFunctionPool('WriteFreq');
        
        gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
        SequencePool(string(gmSEQ.name));
        try
            [~, hCounter] = SetNCounters(gmSEQ.ctrN*gmSEQ.Repeat,'/Dev1/PFI1',500000);
            for i=1:gmSEQ.Average
                gmSEQ.iAverage=i;
                handles.biAverage.String=num2str(gmSEQ.iAverage);
                j=1;
                iwarmup=1;
                
                %only track at begining of each average
                % do not update the gmSEQ.refCounts
                Track('Run');
                
                while j<=gmSEQ.NSweepParam
                    %gmSEQ.refCounts=Track('Run');
                    gmSEQ.m=gmSEQ.SweepParam(j);
                    
                    % choosing Switch for alternating measurement
                    gmSEQ.CoolSwitch = 2;
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
                    [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*2);
                    DAQmxStopTask(hCounter);
                    [sigDatum, refDatum] = ProcessData(vec);
                    
                    
                    % Save for each average
                    gmSEQ.signal_Ave(j) =sigDatum;
                    gmSEQ.reference_Ave(j)=refDatum(1);
                    gmSEQ.reference2_Ave(j)=refDatum(2);
                    gmSEQ.reference3_Ave(j)=refDatum(3);
                    gmSEQ.reference4_Ave(j)=refDatum(4);
                    gmSEQ.reference5_Ave(j)=refDatum(5);
                    
                    if i==1
                        gmSEQ.signal(j)=sigDatum;
                        gmSEQ.reference(j)=refDatum(1);
                        gmSEQ.reference2(j)=refDatum(2);
                        if gmSEQ.ctrN==4 % Add By Chong 4/2/2017
                            gmSEQ.reference3(j)=refDatum(3);
                        end
                        if gmSEQ.ctrN==6 % Add By zzl Dec/2022
                            gmSEQ.reference3(j)=refDatum(3);
                            gmSEQ.reference4(j)=refDatum(4);
                            gmSEQ.reference5(j)=refDatum(5);
                        end
                    else
                        gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                        gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;
                        gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;
                        if gmSEQ.ctrN==4
                            gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                        end
                        if gmSEQ.ctrN==6
                            gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                            gmSEQ.reference4(j)=((gmSEQ.reference4(j)*(i-1))+refDatum(4))/i;
                            gmSEQ.reference5(j)=((gmSEQ.reference5(j)*(i-1))+refDatum(5))/i;
                        end
                    end
                    
                    % Alternating measurement
                    gmSEQ.CoolSwitch = 1;
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
                    [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*2);
                    DAQmxStopTask(hCounter);
                    [sigDatum, refDatum] = ProcessData(vec);
                    
                    % Save for each average
                    gmSEQ.signal_2_Ave(j) =sigDatum;
                    gmSEQ.reference_2_Ave(j)=refDatum(1);
                    gmSEQ.reference2_2_Ave(j)=refDatum(2);
                    gmSEQ.reference3_2_Ave(j)=refDatum(3);
                    gmSEQ.reference4_2_Ave(j)=refDatum(4);
                    gmSEQ.reference5_2_Ave(j)=refDatum(5);
                    
                    
                    if i==1
                        gmSEQ.signal_2(j)=sigDatum;
                        gmSEQ.reference_2(j)=refDatum(1);
                        gmSEQ.reference2_2(j)=refDatum(2);
                        if gmSEQ.ctrN==4 % Add By Chong 4/2/2017
                            gmSEQ.reference3_2(j)=refDatum(3);
                        end
                        if gmSEQ.ctrN==6 % Add By zzl Dec/2022
                            gmSEQ.reference3_2(j)=refDatum(3);
                            gmSEQ.reference4_2(j)=refDatum(4);
                            gmSEQ.reference5_2(j)=refDatum(5);
                        end
                    else
                        gmSEQ.signal_2(j)=((gmSEQ.signal_2(j)*(i-1))+sigDatum)/i;
                        gmSEQ.reference_2(j)=((gmSEQ.reference_2(j)*(i-1))+refDatum(1))/i;
                        gmSEQ.reference2_2(j)=((gmSEQ.reference2_2(j)*(i-1))+refDatum(2))/i;
                        if gmSEQ.ctrN==4
                            gmSEQ.reference3_2(j)=((gmSEQ.reference3_2(j)*(i-1))+refDatum(3))/i;
                        end
                        if gmSEQ.ctrN==6
                            gmSEQ.reference3_2(j)=((gmSEQ.reference3_2(j)*(i-1))+refDatum(3))/i;
                            gmSEQ.reference4_2(j)=((gmSEQ.reference4_2(j)*(i-1))+refDatum(4))/i;
                            gmSEQ.reference5_2(j)=((gmSEQ.reference5_2(j)*(i-1))+refDatum(5))/i;
                        end
                    end
                    
                    
                    % save a backup of the data here in case matlab crashes
                    TemporarySave(BackupFile);
                    
                    PlotData(handles);
                    drawnow;
                    if ~gmSEQ.bGo
                        break
                    end
                    if (gmSEQ.bWarmUpAOM && iwarmup==3)||~gmSEQ.bWarmUpAOM||i~=1||j~=1
                        j=j+1;
                    elseif gmSEQ.bWarmUpAOM
                        iwarmup=iwarmup+1;
                    end
                    
                end
                
                
                
                if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                    break
                end
                
                
                
                % saving each average for experiment
                SaveIgorText_Average(handles);
                
            end
            
            ClearCounters(hCounter);
        catch ME
            KillAllTasks;
            rethrow(ME);
        end
        if gmSEQ.bTrack
            PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
            
            h = findobj('Tag','ImageNVCGUI');
            % if exists (not empty)
            if ~isempty(h)
                % get handles and other user-defined data associated to Gui1
                handles_ImageNVC = guidata(h);
            end
            
            % turn on AWG as well
            ImageFunctionPool('UpdateVoltage', 0, 0, handles_ImageNVC);
            pause(0.2);
        end
        
        
        
    else
        warning('The chosen sequence does not have alternating function');
    end
else
    
    
    if gSG.bfixedPow && gSG.bfixedFreq % Fix microwave power & fix microwave frequency RABI
        % saving for each average
        CreateSavePath_Ave()
        
        % create empty arrays to fill with data for each average
        gmSEQ.signal_Ave = NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference_Ave =NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference2_Ave =NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference3_Ave = NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference4_Ave =NaN(1,gmSEQ.NSweepParam);
        gmSEQ.reference5_Ave = NaN(1,gmSEQ.NSweepParam);  
        
        gmSEQ.refCounts=Track('Init');
        SignalGeneratorFunctionPool('SetMod');
        SignalGeneratorFunctionPool('WritePow');
        SignalGeneratorFunctionPool('WriteFreq');
        
        gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
        SequencePool(string(gmSEQ.name));
        gSG.first=1;
        
        gSG2.bOn = 0; %disabled by WJ 4/12/23
      
        if gSG2.bOn 
            if gSG2.bfixedFreq % ENDOR RABI
                try
                    SignalGeneratorFunctionPool2('SetMod');
                    SignalGeneratorFunctionPool2('WritePow');
                    SignalGeneratorFunctionPool2('WriteFreq');
                    gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');

                    [~, hCounter] = SetNCounters(gmSEQ.ctrN*gmSEQ.Repeat,'/Dev1/PFI1',500000);

                    ImageCorrCounter = 0; % a Counter to identify when to track

                    for i=1:gmSEQ.Average
                        gmSEQ.iAverage=i;
                        handles.biAverage.String=num2str(gmSEQ.iAverage);
                        j=1;
                        iwarmup=1;

                        %only track at begining of each average
                        % do not update the gmSEQ.refCounts
                        % Track('Run');

                        while j<=gmSEQ.NSweepParam
                            ImageCorrCounter = ImageCorrCounter+1;
                            if (mod(ImageCorrCounter, gmSEQ.TrackPointN)==1) % track at the starting of the measurement
                                Track('ImageCorr');
                            end
                            %gmSEQ.refCounts=Track('Run');
                            gmSEQ.m=gmSEQ.SweepParam(j);
                            SequencePool(string(gmSEQ.name));
                            gSG.first=0;
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
                            [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*3);
                            DAQmxStopTask(hCounter);
                            [sigDatum, refDatum] = ProcessData(vec);
                            if i==1
                                gmSEQ.signal(j)=sigDatum;
                                gmSEQ.reference(j)=refDatum(1);
                                %   if gmSEQ.bCtr2

                                gmSEQ.reference2(j)=refDatum(2);


                                if gmSEQ.ctrN==4
                                    % Add By Chong 4/2/2017
                                    gmSEQ.reference3(j)=refDatum(3);
                                end
                                
                                if gmSEQ.ctrN==6
                                    % Add By zzl Dec/2022
                                    gmSEQ.reference3(j)=refDatum(3);
                                    gmSEQ.reference4(j)=refDatum(4);
                                    gmSEQ.reference5(j)=refDatum(5);
                                end
                                %   end
                            else
                                gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                                gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;

                                gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;

                                if gmSEQ.ctrN==4
                                    gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                                end
                                
                                if gmSEQ.ctrN==6
                                    gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                                    gmSEQ.reference4(j)=((gmSEQ.reference4(j)*(i-1))+refDatum(4))/i;
                                    gmSEQ.reference5(j)=((gmSEQ.reference5(j)*(i-1))+refDatum(5))/i;
                                end
                            end

                            %%%
                            % FUCK Yuanqi 11/24/2021

                            % Save for each average
                            gmSEQ.signal_Ave(j) =sigDatum;
                            gmSEQ.reference_Ave(j)=refDatum(1);

                            gmSEQ.reference2_Ave(j)=refDatum(2);

                            if gmSEQ.ctrN==4
                                gmSEQ.reference3_Ave(j)=refDatum(3);
                            end
                            
                            if gmSEQ.ctrN==6
                                gmSEQ.reference3_Ave(j)=refDatum(3);
                                gmSEQ.reference4_Ave(j)=refDatum(4);
                                gmSEQ.reference5_Ave(j)=refDatum(5);
                            end
                            % -----------------------------------------------------
                            % save a backup of the data here in case matlab crashes
                            if ~mod(j, 5)
                                TemporarySave(BackupFile);
                                PlotData(handles);
                                drawnow;
                            end
                            if ~gmSEQ.bGo
                                break
                            end
                            if (gmSEQ.bWarmUpAOM && iwarmup==3)||~gmSEQ.bWarmUpAOM||i~=1||j~=1
                                j=j+1;
                            elseif gmSEQ.bWarmUpAOM
                                iwarmup=iwarmup+1;
                            end

                        end
                        if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                            break
                        end
                        % save a file for each run
                        SaveIgorText_Average(handles)

                    end

                    ClearCounters(hCounter);
                catch ME
                    KillAllTasks;
                    rethrow(ME);
                end
            elseif ~gSG2.bfixedFreq % using second MW source ENDOR ODMR
                disp('You are now doing...1stMW-fixed 2ndMW-VariableFreq Lite...')
                gmSEQ.refCounts=Track('Init');
                gSG2.bMod='';
                gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
                SignalGeneratorFunctionPool2('SetMod');
                SignalGeneratorFunctionPool2('WritePow');
                SignalGeneratorFunctionPool2('WriteFreq');
                gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
                try
                    [~, hCounter] = SetNCounters(gmSEQ.ctrN*gmSEQ.Repeat,'/Dev1/PFI1',500000);
                    for i=1:gmSEQ.Average
                        gmSEQ.iAverage=i;
                        handles.biAverage.String=num2str(gmSEQ.iAverage);
                        j=1;
                        iwarmup=1;
                        while j<=gmSEQ.NSweepParam
                            gmSEQ.refCounts=Track('Run');
                            SequencePool(string(gmSEQ.name));
                            gSG2.Freq=gmSEQ.SweepParam(j);
    %                         SignalGeneratorFunctionPool2('WritePow');
                            SignalGeneratorFunctionPool2('WriteFreq');
    %                         
                            SequencePool(string(gmSEQ.name));
                            gSG.first=0;
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
                            [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*2);
                            DAQmxStopTask(hCounter);
                            [sigDatum, refDatum] = ProcessData(vec);
                            if i==1
                                gmSEQ.signal(j)=sigDatum;
                                gmSEQ.reference(j)=refDatum(1);
                                %   if gmSEQ.bCtr2
                                gmSEQ.reference2(j)=refDatum(2);

                                % Ask Satcher
                                if gmSEQ.ctrN==4
                                    gmSEQ.reference3(j)=refDatum(3);
                                end
                                
                                if gmSEQ.ctrN==6
                                    gmSEQ.reference3(j)=refDatum(3);
                                    gmSEQ.reference4(j)=refDatum(4);
                                    gmSEQ.reference5(j)=refDatum(5);
                                end
                                %   end
                            else
                                gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                                gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;
                                gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;

                                if gmSEQ.ctrN==4
                                    gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                                end
                                
                                if gmSEQ.ctrN==6
                                    gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                                    gmSEQ.reference4(j)=((gmSEQ.reference4(j)*(i-1))+refDatum(4))/i;
                                    gmSEQ.reference5(j)=((gmSEQ.reference5(j)*(i-1))+refDatum(5))/i;
                                end
                            end
                            % save a backup of the data here in case matlab crashes
                            TemporarySave(BackupFile);
                            PlotData(handles);
                            drawnow;
                            if ~gmSEQ.bGo
                                break
                            end
                            if (gmSEQ.bWarmUpAOM && iwarmup==2)||~gmSEQ.bWarmUpAOM||i~=1||j~=1
                                j=j+1;
                            elseif gmSEQ.bWarmUpAOM
                                iwarmup=iwarmup+1;
                            end

                        end
                        if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                            break
                        end
                    end


                    ClearCounters(hCounter);
            catch ME
                KillAllTasks;
                rethrow(ME);
                end
            end
        else
            try
                [~, hCounter] = SetNCounters(gmSEQ.ctrN*gmSEQ.Repeat,'/Dev1/PFI1',500000);

                ImageCorrCounter = 0; % a Counter to identify when to track

                for i=1:gmSEQ.Average
                    gmSEQ.iAverage=i;
                    handles.biAverage.String=num2str(gmSEQ.iAverage);
                    j=1;
                    iwarmup=1;

                    %only track at begining of each average
                    % do not update the gmSEQ.refCounts
                    % Track('Run');

                    while j<=gmSEQ.NSweepParam
                        ImageCorrCounter = ImageCorrCounter+1;
                        if (mod(ImageCorrCounter, gmSEQ.TrackPointN)==1) % track at the starting of the measurement
                            Track('ImageCorr');
                        end
                        %gmSEQ.refCounts=Track('Run');
                        gmSEQ.m=gmSEQ.SweepParam(j);
                        SequencePool(string(gmSEQ.name));
                        gSG.first=0;
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
                        [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*3);
                        DAQmxStopTask(hCounter);
                        [sigDatum, refDatum] = ProcessData(vec);
                        if i==1
                            gmSEQ.signal(j)=sigDatum;
                            gmSEQ.reference(j)=refDatum(1);

                            gmSEQ.reference2(j)=refDatum(2);


                            if gmSEQ.ctrN==4
                                % Add By Chong 4/2/2017
                                gmSEQ.reference3(j)=refDatum(3);
                            end
                            
                             if gmSEQ.ctrN==6
                                % Add By zzl Dec/2022
                                gmSEQ.reference3(j)=refDatum(3);
                                gmSEQ.reference4(j)=refDatum(4);
                                gmSEQ.reference5(j)=refDatum(5);
                            end
                            %   end
                        else
                            gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                            gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;

                            gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;

                            if gmSEQ.ctrN==4
                                gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                            end
                            
                             if gmSEQ.ctrN==6
                                gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                                gmSEQ.reference4(j)=((gmSEQ.reference4(j)*(i-1))+refDatum(4))/i;
                                gmSEQ.reference5(j)=((gmSEQ.reference5(j)*(i-1))+refDatum(5))/i;
                            end
                        end

                        %%%
                        % FUCK Yuanqi 11/24/2021

                        % Save for each average
                        gmSEQ.signal_Ave(j) =sigDatum;
                        gmSEQ.reference_Ave(j)=refDatum(1);

                        gmSEQ.reference2_Ave(j)=refDatum(2);

                        if gmSEQ.ctrN==4
                            gmSEQ.reference3_Ave(j)=refDatum(3);
                        end
                        
                        if gmSEQ.ctrN==6
                            gmSEQ.reference3_Ave(j)=refDatum(3);
                            gmSEQ.reference4_Ave(j)=refDatum(4);
                            gmSEQ.reference5_Ave(j)=refDatum(5);
                        end
                        % -----------------------------------------------------
                        % save a backup of the data here in case matlab crashes
                        if ~mod(j, 10)
                            TemporarySave(BackupFile);
                            PlotData(handles);
                            drawnow;
                        end
                        if ~gmSEQ.bGo
                            break
                        end
                        if (gmSEQ.bWarmUpAOM && iwarmup==3)||~gmSEQ.bWarmUpAOM||i~=1||j~=1
                            j=j+1;
                        elseif gmSEQ.bWarmUpAOM
                            iwarmup=iwarmup+1;
                        end

                    end
                    if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                        break
                    end
                    % save a file for each run
                    SaveIgorText_Average(handles)

                end

                ClearCounters(hCounter);
            catch ME
                KillAllTasks;
                rethrow(ME);
            end
        end
        if gmSEQ.bTrack
            PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
            
%             h = findobj('Tag','ImageNVCGUI');
%             % if exists (not empty)
%             if ~isempty(h)
%                 % get handles and other user-defined data associated to Gui1
%                 handles_ImageNVC = guidata(h);
%             end
%             
%             % turn on AWG as well
%             ImageFunctionPool('UpdateVoltage', 0, 0, handles_ImageNVC);
%             pause(0.2);
        end
    elseif isfield(gmSEQ,'bLiO')   % activates for ESR measurement
        gmSEQ.refCounts=Track('Init');
        SequencePool(string(gmSEQ.name));
        gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
        gSG.sweepDev=(gmSEQ.SweepParam(gmSEQ.NSweepParam)-gmSEQ.SweepParam(1))/2;
        gSG.Freq=(gmSEQ.SweepParam(gmSEQ.NSweepParam)+gmSEQ.SweepParam(1))/2;
        SignalGeneratorFunctionPool('WriteFreq');
        if gSG.Pow > -5
            error('Too strong microwave power for ESR measurement');
        else
            SignalGeneratorFunctionPool('WritePow');
        end
        SignalGeneratorFunctionPool('SetMod');
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM')+2^SequencePool('PBDictionary','MWswitch1'));
%         SignalGeneratorFunctionPool2('WritePow');
%         gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff'); %ejd 7/20/23

        %     PBFunctionPool('PBON',2^SequencePool('PBDictionary','MWswitch'));
        
%         h = findobj('Tag','ImageNVCGUI'); WJ
%         % if exists (not empty)
%         if ~isempty(h)
%             % get handles and other user-defined data associated to Gui1
%             handles_ImageNVC = guidata(h);
%         end
%         % turn on AWG as well
%         ImageFunctionPool('UpdateVoltage', 0, 0, handles_ImageNVC);
%         pause(0.2); WJ
        
        %     if gmSEQ.bWarmUpAOM %%% probably not necessary for this method of ESR
        %         gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
        %         pause(30);
        %     end
        try
            [vec, NN]=MakeSweepVector();
            
            gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
            
            ImageCorrCounter = 0; % a Counter to identify when to track
            
            for i=1:gmSEQ.Average
                %gmSEQ.refCounts=Track('Run');
%                 ImageCorrCounter = ImageCorrCounter+1; WJ
%                 if (mod(ImageCorrCounter, gmSEQ.TrackPointN)==1) % track at the starting of the measurement
%                     Track('ImageCorr');
%                     PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM')+2^SequencePool('PBDictionary','MWswitch1'));
%                 end WJ
                %%%%% Pulse Train %%%%%
                [~, hPulse] = DigPulseTrainCont(gmSEQ.NSweepParam*gSG.sweepRate,0.5,NN);
                hCPS.hPulse=hPulse;
                %%%%% Analog write %%%%
                [ ~, hScan ] = DAQmxFunctionPool('WriteAnalogVoltage','Dev1/ao2',vec, NN,gmSEQ.NSweepParam*gSG.sweepRate);
                hCPS.hScan=hScan;
                %%%%% Create counting channel %%%%
                [~, hCounter] = SetNCounters(NN,'/Dev1/PFI13',gmSEQ.NSweepParam*gSG.sweepRate);
                hCPS.hCounter=hCounter;
                gmSEQ.iAverage=i;
                handles.biAverage.String=num2str(gmSEQ.iAverage);
                status = DAQmxStartTask(hScan);  DAQmxErr(status);
                status = DAQmxStartTask(hCounter);  DAQmxErr(status);
                status = DAQmxStartTask(hPulse);    DAQmxErr(status);
                
                [~, A] = ReadCountersN(hCounter,NN, gmSEQ.misc*1.1);
                
                DAQmxStopTask(hCounter);
                DAQmxStopTask(hScan);
                DAQmxStopTask(hPulse);
                if gmSEQ.bAAR==1
                    if i==1
                        gmSEQ.signal = ProcessData(A);
                    else
                        gmSEQ.signal = (gmSEQ.signal*(i-1)+ProcessData(A))/i;
                    end
                else
                    gmSEQ.signal = ProcessData(A);
                end
                
                TemporarySave(BackupFile);
                PlotData(handles);
                drawnow;
                DAQmxClearTask(hCounter);
                DAQmxClearTask(hPulse);
                DAQmxClearTask(hScan);
                if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                    break
                end
            end
        catch ME
            KillAllTasks;
            gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
            gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff');
            rethrow(ME);
        end
        if ~gmSEQ.bTrack
            ExperimentFunctionPool('PBOFF',hObject, eventdata, handles);
        end
        
        
    elseif gSG.bfixedPow && ~gSG.bfixedFreq % for ODMR (pulsed - ESR)
        %gSG2.bfixedFreq=1; %ejd 5/16/23 we're never using SG2
        if ~gSG2.bfixedFreq % using second MW source
            gmSEQ.refCounts=Track('Init');
            gSG2.bMod='IQ';
            gSG2.bModSrc='External';
            % gSG2.bOn=1; SignalGeneratorFunctionPool2('RFOnOff');
            SignalGeneratorFunctionPool2('SetMod');
            gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;
            gSG.first=1;
            try
                [~, hCounter] = SetNCounters(gmSEQ.ctrN*gmSEQ.Repeat,'/Dev1/PFI1',500000);
                for i=1:gmSEQ.Average
                    gmSEQ.iAverage=i;
                    handles.biAverage.String=num2str(gmSEQ.iAverage);
                    j=1;
                    iwarmup=1;
                    while j<=gmSEQ.NSweepParam
                        gmSEQ.refCounts=Track('Run');
                        SequencePool(string(gmSEQ.name));
                        gSG2.Freq=gmSEQ.SweepParam(j);
%                         SignalGeneratorFunctionPool2('WritePow');
%                         SignalGeneratorFunctionPool2('WriteFreq');
%                         
                        SequencePool(string(gmSEQ.name));
                        gSG.first=0;
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
                        [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*2);
                        DAQmxStopTask(hCounter);
                        [sigDatum, refDatum] = ProcessData(vec);
                        if i==1
                            gmSEQ.signal(j)=sigDatum;
                            gmSEQ.reference(j)=refDatum(1);
                            %   if gmSEQ.bCtr2
                            gmSEQ.reference2(j)=refDatum(2);
                            
                            % Ask Satcher
                            if gmSEQ.ctrN==4
                                gmSEQ.reference3(j)=refDatum(3);
                            end
                            
                            if gmSEQ.ctrN==6
                                gmSEQ.reference3(j)=refDatum(3);
                                gmSEQ.reference4(j)=refDatum(4);
                                gmSEQ.reference5(j)=refDatum(5);
                            end
                            %   end
                        else
                            gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                            gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;
                            gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;
                            
                            if gmSEQ.ctrN==4
                                gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                            end
                            
                            if gmSEQ.ctrN==6
                                gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                                gmSEQ.reference4(j)=((gmSEQ.reference4(j)*(i-1))+refDatum(4))/i;
                                gmSEQ.reference5(j)=((gmSEQ.reference5(j)*(i-1))+refDatum(5))/i;
                            end
                        end
                        % save a backup of the data here in case matlab crashes
                        TemporarySave(BackupFile);
                        PlotData(handles);
                        drawnow;
                        if ~gmSEQ.bGo
                            break
                        end
                        if (gmSEQ.bWarmUpAOM && iwarmup==2)||~gmSEQ.bWarmUpAOM||i~=1||j~=1
                            j=j+1;
                        elseif gmSEQ.bWarmUpAOM
                            iwarmup=iwarmup+1;
                        end
                        
                    end
                    if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                        break
                    end
                end
                
                
                ClearCounters(hCounter);
            catch ME
                KillAllTasks;
                rethrow(ME);
            end
            
        else
            % use first MW do ODMR
            
            gmSEQ.refCounts=Track('Init');
            gSG.bOn=1; SignalGeneratorFunctionPool('RFOnOff');
            SignalGeneratorFunctionPool('SetMod');
            SignalGeneratorFunctionPool('WritePow');
            gmSEQ.SweepParam=gmSEQ.SweepParam*1e9;

            try
                [~, hCounter] = SetNCounters(gmSEQ.ctrN*gmSEQ.Repeat,'/Dev1/PFI1',500000);
                
                ImageCorrCounter = 0; % a Counter to identify when to track
                gSG.first = 1;
                
                for i=1:gmSEQ.Average
                    gmSEQ.iAverage=i;
                    handles.biAverage.String=num2str(gmSEQ.iAverage);
                    j=1;
                    iwarmup=1;
                    
                                        
                    while j<=gmSEQ.NSweepParam
                        disp('Run No. ' + string(j))
                        % gmSEQ.refCounts=Track('Run');
                        ImageCorrCounter = ImageCorrCounter+1;
                        if (mod(ImageCorrCounter, gmSEQ.TrackPointN)==1) % track at the starting of the measurement
                            Track('ImageCorr');
                        end
                        
                        SequencePool(string(gmSEQ.name));
                        gSG.first = 0;
                        
                        gSG.Freq=gmSEQ.SweepParam(j);
                        SignalGeneratorFunctionPool('WriteFreq');
                        % gmSEQ.m=gmSEQ.SweepParam(j);
                        
                        SequencePool(string(gmSEQ.name));
                        %DrawSequence(gmSEQ,hObject, eventdata, handles.axes1);
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
                        [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*2);
                        DAQmxStopTask(hCounter);
                        [sigDatum, refDatum] = ProcessData(vec);
                        if i==1
                            gmSEQ.signal(j)=sigDatum;
                            gmSEQ.reference(j)=refDatum(1);
                            gmSEQ.reference2(j)=refDatum(2);
                            
                            % Ask Satcher
                            if gmSEQ.ctrN==4
                                gmSEQ.reference3(j)=refDatum(3);
                            end
                            
                            if gmSEQ.ctrN==6
                                gmSEQ.reference3(j)=refDatum(3);
                                gmSEQ.reference4(j)=refDatum(4);
                                gmSEQ.reference5(j)=refDatum(5);
                            end
                            %   end
                        else
                            gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                            gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;
                            gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;
                            
                            if gmSEQ.ctrN==4
                                gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                            end
                            
                            if gmSEQ.ctrN==6
                                gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                                gmSEQ.reference4(j)=((gmSEQ.reference4(j)*(i-1))+refDatum(4))/i;
                                gmSEQ.reference5(j)=((gmSEQ.reference5(j)*(i-1))+refDatum(5))/i;
                            end
                        end
                        % save a backup of the data here in case matlab crashes
                        if ~mod(j, 10)
                            TemporarySave(BackupFile);
                            PlotData(handles);
                            drawnow;
                        end
                        if ~gmSEQ.bGo
                            break
                        end
                        if (gmSEQ.bWarmUpAOM && iwarmup==2)||~gmSEQ.bWarmUpAOM||i~=1||j~=1
                            j=j+1;
                        elseif gmSEQ.bWarmUpAOM
                            iwarmup=iwarmup+1;
                        end
                        
                    end
                    if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                        break
                    end
                end
                
                
                ClearCounters(hCounter);
            catch ME
                KillAllTasks;
                rethrow(ME);
            end
            
        end
        
        % elseif gSG.bfixedPow && gSG.bfixedFreq && ~gSG2.bfixedFreq% for 2ndMWdrive measurement / DEER
        
    elseif ~gSG.bfixedPow && ~gSG.bfixedFreq
        
        gmSEQ.refCounts=Track('Init');
        SignalGeneratorFunctionPool('SetMod');
        SignalGeneratorFunctionPool('WritePow');
        SignalGeneratorFunctionPool('WriteFreq');
        gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
        SequencePool(string(gmSEQ.name));
        try
            [~, hCounter] = SetNCounters(gmSEQ.ctrN*gmSEQ.Repeat,'/Dev1/PFI1',500000);
            for i=1:gmSEQ.Average
                gmSEQ.iAverage=i;
                handles.biAverage.String=num2str(gmSEQ.iAverage);
                j=1;
                iwarmup=1;
                
                
                while j<=gmSEQ.NSweepParam
                    gmSEQ.refCounts=Track('Run');
                    gmSEQ.m=gmSEQ.SweepParam(j);
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
                    [~, vec] = ReadCountersN(hCounter,(gmSEQ.ctrN*gmSEQ.Repeat),gmSEQ.Repeat*tmax/1e9*2);
                    DAQmxStopTask(hCounter);
                    [sigDatum, refDatum] = ProcessData(vec);
                    if i==1
                        gmSEQ.signal(j)=sigDatum;
                        gmSEQ.reference(j)=refDatum(1);
                        %   if gmSEQ.bCtr2
                        gmSEQ.reference2(j)=refDatum(2);
                        
                        if gmSEQ.ctrN==4
                            % Add By Chong 4/2/2017
                            gmSEQ.reference3(j)=refDatum(3);
                        end   
                        if gmSEQ.ctrN==6
                            gmSEQ.reference3(j)=refDatum(3);
                            gmSEQ.reference4(j)=refDatum(4);
                            gmSEQ.reference5(j)=refDatum(5);
                        end
                        %   end
                    else
                        gmSEQ.signal(j)=((gmSEQ.signal(j)*(i-1))+sigDatum)/i;
                        gmSEQ.reference(j)=((gmSEQ.reference(j)*(i-1))+refDatum(1))/i;
                        gmSEQ.reference2(j)=((gmSEQ.reference2(j)*(i-1))+refDatum(2))/i;
                        if gmSEQ.ctrN==4
                            gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                        end
                        if gmSEQ.ctrN==6
                            gmSEQ.reference3(j)=((gmSEQ.reference3(j)*(i-1))+refDatum(3))/i;
                            gmSEQ.reference4(j)=((gmSEQ.reference4(j)*(i-1))+refDatum(4))/i;
                            gmSEQ.reference5(j)=((gmSEQ.reference5(j)*(i-1))+refDatum(5))/i;
                        end
                    end
                    % save a backup of the data here in case matlab crashes
                    TemporarySave(BackupFile);
                    PlotData(handles);
                    drawnow;
                    if ~gmSEQ.bGo
                        break
                    end
                    if (gmSEQ.bWarmUpAOM && iwarmup==3)||~gmSEQ.bWarmUpAOM||i~=1||j~=1
                        j=j+1;
                    elseif gmSEQ.bWarmUpAOM
                        iwarmup=iwarmup+1;
                    end
                    
                end
                if ~gmSEQ.bGo || ~gmSEQ.bGoAfterAvg
                    break
                end
            end
            
            ClearCounters(hCounter);
        catch ME
            KillAllTasks;
            rethrow(ME);
        end
        if gmSEQ.bTrack
            PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
            
            h = findobj('Tag','ImageNVCGUI');
            % if exists (not empty)
            if ~isempty(h)
                % get handles and other user-defined data associated to Gui1
                handles_ImageNVC = guidata(h);
            end
            
            % turn on AWG as well
            ImageFunctionPool('UpdateVoltage', 0, 0, handles_ImageNVC);
            pause(0.2);
        end
        
        
    end
    
end

gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
%gSG2.bMod = ''; %ejd 7/20/23
gSG2.bOn=0; SignalGeneratorFunctionPool2('RFOnOff');
% gSG3.bOn=0; SignalGeneratorFunctionPool3('RFOnOff');

% Stop the AWG Dec/1/2022 weijie
chaseFunctionPool('stopChase', 1); pause(0.5);
chaseFunctionPool('stopChase', 2); pause(0.5);


% update AWG voltage for laser
h = findobj('Tag','ImageNVCGUI');
% if exists (not empty)
if ~isempty(h)
    % get handles and other user-defined data associated to Gui1
    handles_ImageNVC = guidata(h);
end
ImageFunctionPool('UpdateVoltage', 0, 0, handles_ImageNVC);

% Zero the voltage of 2nd AWG
%ImageFunctionPool('ZeroVoltageAWG2');

gmSEQ.bGo=0;
disp('Experiment completed!')
sound(y,Fs);

%SaveData;

function InitializeData(handles)

global gmSEQ
gmSEQ.bAAR=get(handles.bAAR,'Value');
gmSEQ.Repeat=str2double(get(handles.Repeat,'String'));


if get(handles.bAverage,'Value')
    gmSEQ.Average=str2double(get(handles.Average,'String'));
else
    gmSEQ.Average=1;
end

% for two sweeping range.
% Add by C. Zu on 2/27/2017
if (gmSEQ.bSweep1log)
    gmSEQ.SweepParam=logspace(log10(gmSEQ.From),log10(gmSEQ.To),gmSEQ.N);
else
    gmSEQ.SweepParam=linspace(gmSEQ.From,gmSEQ.To,gmSEQ.N);
end

if (gmSEQ.bSweep2)
    if (gmSEQ.bSweep2log)
        gmSEQ.SweepParam=[gmSEQ.SweepParam logspace(log10(gmSEQ.From2),log10(gmSEQ.To2),gmSEQ.N2)];
    else
        gmSEQ.SweepParam=[gmSEQ.SweepParam linspace(gmSEQ.From2,gmSEQ.To2,gmSEQ.N2)];
    end
end

if (gmSEQ.bSweep3)
    if (gmSEQ.bSweep3log)
        gmSEQ.SweepParam=[gmSEQ.SweepParam logspace(log10(gmSEQ.From3),log10(gmSEQ.To3),gmSEQ.N3)];
    else
        gmSEQ.SweepParam=[gmSEQ.SweepParam linspace(gmSEQ.From3,gmSEQ.To3,gmSEQ.N3)];
    end
end




gmSEQ.NSweepParam=length(gmSEQ.SweepParam);

gmSEQ.signal=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference2=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference3=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference4=NaN(1,gmSEQ.NSweepParam);
gmSEQ.reference5=NaN(1,gmSEQ.NSweepParam);


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

function [signal, reference]=CreateAndSetCounters()

[ status, ~, signal ] = DAQmxCreateTask([]);
DAQmxErr(status);

[ status, ~, reference(1) ] = DAQmxCreateTask([]);
DAQmxErr(status);

DAQmxFunctionPool('SetGatedCounter',signal,'Dev1/ctr0','/Dev1/PFI8','/Dev1/PFI9');
DAQmxFunctionPool('SetGatedCounter',reference(1),'Dev1/ctr1','/Dev1/PFI8','/Dev1/PFI4');

% gmSEQ.bCtr2=0;
% ctr2=SequencePool('PBDictionary','ctr2');
% for i=1:numel(gmSEQ.CHN)
%     if gmSEQ.CHN(i).PBN==ctr2
%         [ status, ~, reference(2) ] = DAQmxCreateTask([]);
%         DAQmxErr(status);
%         gmSEQ.bCtr2=1;
%         DAQmxFunctionPool('SetGatedCounter',reference(2),'Dev1/ctr2','/Dev1/PFI8','/Dev1/PFI6');
%         break
%     end
% end

function [status, task] = SetNCounters(varargin)
%varargin(1) is the number of total samples
%varargin(2) is the source of gating
%varargin(3) is the frequency of the gating to expect
% Initialize DAQ
global gmSEQ hCPS
if strcmp(gmSEQ.meas,'SPCM')
    if isfield(gmSEQ,'bLiO')
        [status, task ] = DAQmxFunctionPool('SetCounter',varargin{1});
    else
        [status, task ] = DAQmxFunctionPool('SetGatedNCounter',varargin{1});
    end
    
elseif strcmp(gmSEQ.meas,'APD')
    [status, task ] = DAQmxFunctionPool('CreateAIChannel',varargin{2},varargin{1},varargin{3});
end
hCPS.hCounter=task;

function PlotData(handles)
global gmSEQ ScaleT ScaleStr

%axes(handles.axes2); %cla;
if gmSEQ.ctrN==1
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.signal),'-b')
else
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.signal),'-b','LineStyle', '--')    
hold(handles.axes2, 'on')
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference),'-r')
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference2),'-k','LineStyle','--')
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference3),'-m')
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference4),'-c','LineStyle','--')
plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference5),'-y')
end

if (gmSEQ.Alternate)
    plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.signal_2),'-b','LineStyle',':')
    plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference_2),'-r','LineStyle','-.')
    plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference2_2),'-k','LineStyle',':')
    plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference3_2),'-m','LineStyle','-.')
    plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference4_2),'-c','LineStyle',':')
    plot(handles.axes2, single(gmSEQ.SweepParam)*ScaleT,single(gmSEQ.reference5_2),'-y','LineStyle','-.')
end

grid on;
set(handles.axes2,'FontSize',8);
ylabel(handles.axes2, 'Fluorescence counts');
xlabel(handles.axes2, ScaleStr);
% xlim(handles.axes2, [gmSEQ.SweepParam(1)*ScaleT
% gmSEQ.SweepParam((gmSEQ.NSweepParam)*ScaleT); %ejd edit
hold(handles.axes2, 'off')

if (gmSEQ.Alternate)
    
    data=2*(gmSEQ.reference(~isnan(gmSEQ.reference))-gmSEQ.reference3(~isnan(gmSEQ.referxence3)))./(gmSEQ.signal(~isnan(gmSEQ.signal))+gmSEQ.reference2(~isnan(gmSEQ.reference2)));
    data_2=2*(gmSEQ.reference_2(~isnan(gmSEQ.reference_2))-gmSEQ.reference3_2(~isnan(gmSEQ.reference3_2)))./(gmSEQ.signal_2(~isnan(gmSEQ.signal_2))+gmSEQ.reference2_2(~isnan(gmSEQ.reference2_2)));
    
    plot(handles.axes3, gmSEQ.SweepParam(1:length(data)).*ScaleT,data,'-g')
    hold(handles.axes3, 'on')
    plot(handles.axes3, gmSEQ.SweepParam(1:length(data_2)).*ScaleT,data_2,'--k')
    grid on;
    set(handles.axes3,'FontSize',8);
    ylabel(handles.axes3, 'Fluorescence contrast');
    xlabel(handles.axes3, ScaleStr);
    xlim(handles.axes3, [gmSEQ.SweepParam(1)*ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*ScaleT]);
    hold(handles.axes3, 'off')
    
    
else
    if ~isfield(gmSEQ,'bLiO')&&gmSEQ.ctrN~=1
        %axes(handles.axes3);% cla;
        if gmSEQ.ctrN==3
            if strcmp(gmSEQ.name,'T1JC')
                data=(gmSEQ.signal(~isnan(gmSEQ.signal))-gmSEQ.reference(~isnan(gmSEQ.reference)))./(gmSEQ.reference2(~isnan(gmSEQ.reference2)));
            else
                data=(gmSEQ.signal(~isnan(gmSEQ.signal))-gmSEQ.reference2(~isnan(gmSEQ.reference2)))./(gmSEQ.reference(~isnan(gmSEQ.reference))-gmSEQ.reference2(~isnan(gmSEQ.reference2)));
            end
        else
            if strcmp(gmSEQ.name,'T1PolarP1_SpeedupP1Mix_4Counter')
                data=((gmSEQ.signal(~isnan(gmSEQ.signal))-gmSEQ.reference(~isnan(gmSEQ.reference))))-(gmSEQ.reference2(~isnan(gmSEQ.reference2))-gmSEQ.reference3(~isnan(gmSEQ.reference3)));
            elseif strcmp(gmSEQ.name,'SpinDiffuse_2Counter_Shelve') || strcmp(gmSEQ.name,'T1PolarP1_SpeedupP1Mix_2Counter') || strcmp(gmSEQ.name,'T1PolarP1_2Counter_2ndMWdrive') || strcmp(gmSEQ.name,'T1PolarP1_2Counter_2ndMWdriveLaser') ...
                    || strcmp(gmSEQ.name,'SpinDiff_shelve_2ndMWdrive') || strcmp(gmSEQ.name,'SpinDiffuse_2Counter_Shelve_Ramsey') || strcmp(gmSEQ.name,'SpinDiffuse_2Counter_Shelve_Echo') || strcmp(gmSEQ.name, 'SpinDiffuse_2Counter_Shelve_FM') ...
                    || strcmp(gmSEQ.name,'SpinDiffuse_2Counter_Shelve_FM_fxTau') || strcmp(gmSEQ.name,'SpinDiffuse_2Counter_Shelve_FM_SwpN') || strcmp(gmSEQ.name,'SpinDiff_shelve_2ndMWdrive_after_td') ||  strcmp(gmSEQ.name,'T1PolarP1_RotP1_2Counter_Shelve') ...
                    || strcmp(gmSEQ.name, 'SpinDiffuse_2Counter_Shelve_CPMG8_SwpN') || strcmp(gmSEQ.name, 'SpinLocking') || strcmp(gmSEQ.name, 'NVdensity_SpinLocking') || ...
                    strcmp(gmSEQ.name, 'NVdensity_SpinLocking_SwpFreq') || strcmp(gmSEQ.name, 'NVdensity_SpinLocking_SwpPow') || strcmp(gmSEQ.name, 'T1PolarP1_2Counter_2ndMWdrive_SwpFreq') ...
                    || strcmp(gmSEQ.name, 'SpinDiff_shelve_2ndMWdrive_AllON') ||  strcmp(gmSEQ.name, 'SpinDiff_shelve_2ndMWdrive_LateON') ...
                    || strcmp(gmSEQ.name, 'SpinDiff_shelve_2ndMWdrive_AfterLaserON') || strcmp(gmSEQ.name, 'T1Polar_4Counter_FlipOffP1') ...
                    || strcmp(gmSEQ.name, 'T1Polar_2ndMWDrive_FlipOffP1') || strcmp(gmSEQ.name, 'T1Polar_2ndMWDriveLaser_FlipOffP1') || strcmp(gmSEQ.name,'SpinDiffuse_2Counter_Shelve_FM_Sym_SwpN') ...
                    || strcmp(gmSEQ.name, 'Cooling_SpinLocking') || strcmp(gmSEQ.name, 'SpecialCooling') || strcmp(gmSEQ.name, 'SpecialCooling_FixN') || strcmp(gmSEQ.name, 'Ramsey_2Counter') ...
                    || strcmp(gmSEQ.name, 'Echo_2Counter') || strcmp(gmSEQ.name, 'SpecialCooling2') || strcmp(gmSEQ.name, 'SpecialCooling2_FixN') || strcmp(gmSEQ.name, 'SpecialCooling2_FixN_SpinLockingMeasure') ...
                    || strcmp(gmSEQ.name, 'SpecialCooling2_FixN_MeasSeparate') || strcmp(gmSEQ.name, 'XY8_SwpN_2Counter') || strcmp(gmSEQ.name, 'XY8_SwpT_2Counter') || strcmp(gmSEQ.name, 'DEER') || strcmp(gmSEQ.name, 'DEER_Rabi') || strcmp(gmSEQ.name, 'DEER_Echo') ...
                    || strcmp(gmSEQ.name, 'DEER_XY8N') 
                
                data=2*(gmSEQ.reference(~isnan(gmSEQ.reference))-gmSEQ.reference3(~isnan(gmSEQ.reference3)))./(gmSEQ.signal(~isnan(gmSEQ.signal))+gmSEQ.reference2(~isnan(gmSEQ.reference2)));
            elseif strcmp(gmSEQ.name, 'T1PolarP1_4Counter_LaserPow')
                data=2*(gmSEQ.signal(~isnan(gmSEQ.signal))-gmSEQ.reference2(~isnan(gmSEQ.reference2)))./(gmSEQ.reference(~isnan(gmSEQ.reference))+gmSEQ.reference3(~isnan(gmSEQ.reference3)));
                
                %elseif gmSEQ.ctrN==4
                %    data=((gmSEQ.signal(~isnan(gmSEQ.signal))-gmSEQ.reference(~isnan(gmSEQ.reference))))./(gmSEQ.reference2(~isnan(gmSEQ.reference2))-gmSEQ.reference3(~isnan(gmSEQ.reference3)));
            else
                if strcmp(gmSEQ.name,'T1PolarP1_RotP1_2Counter') || strcmp(gmSEQ.name,'T1PolarP1_FCB_2Counter') || strcmp(gmSEQ.name,'T1PolarP1_SpinDiff_2Counter') || strcmp(gmSEQ.name,'T1PolarP1_2Counter_2ndMWdrive') ...
                        || strcmp(gmSEQ.name,'Echo_2Counter_P1mix') || strcmp(gmSEQ.name,'Echo_2Counter_NoP1mix') || strcmp(gmSEQ.name,'TestCharge_2Counter') || strcmp(gmSEQ.name, 'T1PolarP1_RotP1_2ndMWdrive') ||  strcmp(gmSEQ.name, 'T1PolarP1_2Counter_2ndMWdrive_SwpFreq') ...
                        || strcmp(gmSEQ.name,'T1PolarP1_2Counter_2ndMWdriveLaser') || strcmp(gmSEQ.name,'Ramsey_2Counter') || strcmp(gmSEQ.name,'T1PolarP1_RotP1_2Counter_Plus1') || strcmp(gmSEQ.name, 'T1PolarP1_SpeedupP1Mix_2Counter_Plus1') || strcmp(gmSEQ.name, 'T1PolarP1_SpeedupP1Mix_2Counter_Minus1') ...
                        || strcmp(gmSEQ.name, 'T1PolarP1_RotP1_2Counter_Shelve') ||  strcmp(gmSEQ.name, 'T1PolarP1_2Counter_Shelve')
                    data=gmSEQ.signal(~isnan(gmSEQ.signal))-gmSEQ.reference(~isnan(gmSEQ.reference));
                else
                    data=gmSEQ.signal(~isnan(gmSEQ.signal))./gmSEQ.reference(~isnan(gmSEQ.reference));
                end
            end
        end
        
        
        plot(handles.axes3, gmSEQ.SweepParam(1:length(data)).*ScaleT,data,'-g');%, '--o') %ejd 11/16/2022
        grid on;
        set(handles.axes3,'FontSize',8);
        ylabel(handles.axes3, 'Fluorescence contrast');
        xlabel(handles.axes3, ScaleStr);
        xlim(handles.axes3, [gmSEQ.SweepParam(1)*ScaleT gmSEQ.SweepParam(gmSEQ.NSweepParam)*ScaleT]);
    end
    
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
        for kk=1:size(CMD,2)
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



function StartCounters(task)
DAQmxStartTask(task);
%     DAQmxStartTask(reference(1));
%     if gmSEQ.bCtr2
%         DAQmxStartTask(reference(2));
%     end

% function [sigDatum, refDatum] = ReadCounters(signal,reference)
% global gmSEQ
%
%     refDatum(1)=DAQmxFunctionPool('ReadCounterScalar',reference(1));
%     if gmSEQ.bCtr2
%         refDatum(2)=DAQmxFunctionPool('ReadCounterScalar',reference(2));
%     end
%     sigDatum=DAQmxFunctionPool('ReadCounterScalar',signal);

function [status,A] = ReadCountersN(task,samps,timeout)
global gmSEQ
if strcmp(gmSEQ.meas,'SPCM')
    [status, A]= DAQmxReadCounterU32(task, samps, timeout, zeros(1,samps), samps, libpointer('int32Ptr',0) );
elseif strcmp(gmSEQ.meas,'APD')
    [status, A] = DAQmxFunctionPool('ReadAnalogVoltage',task, samps, timeout);
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
vecA = -1:(2/(gmSEQ.NSweepParam-1)):1; %ejd this is original
% vecA = 1:-(2/(gmSEQ.NSweepParam-1)):-1; ejd changed it to this
vec = [vecA fliplr(vecA)];

vec=repmat(vec,1,ceil(gSG.sweepRate*gmSEQ.misc/2));
if strcmp(gmSEQ.meas,'SPCM')
    vec=[vec(1) vec];
end
NN=length(vec);


function [sigDatum, refDatum] = ProcessData(RawData)
global gmSEQ gSG
if strcmp(gmSEQ.meas,'SPCM')
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
        RawData1=[diff(RawData)];
        sigDatum=sum(RawData1(1:gmSEQ.ctrN:end));
        if gmSEQ.ctrN>1
            refDatum(1,:)=sum(RawData1(2:gmSEQ.ctrN:end));
            if gmSEQ.ctrN>2
                refDatum(2,:)=sum(RawData1(3:gmSEQ.ctrN:end));
                if gmSEQ.ctrN>3
                    refDatum(3,:)=sum(RawData1(4:gmSEQ.ctrN:end));
                    if gmSEQ.ctrN>4
                        refDatum(4,:)=sum(RawData1(5:gmSEQ.ctrN:end));
                        if gmSEQ.ctrN>5
                            refDatum(5,:)=sum(RawData1(6:gmSEQ.ctrN:end));
                        else
                            refDatum(5)=NaN;
                        end
                    else
                        refDatum(4)=NaN;
                    end
                else
                    refDatum(3)=NaN;
                end
            else
                refDatum(2)=NaN;
            end
        else
            refDatum(1)=NaN;
            refDatum(2)=NaN;
            refDatum(3)=NaN;
            refDatum(4)=NaN;
            refDatum(5)=NaN;
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
        sigDatum=sum(RawData(1:gmSEQ.ctrN:end));
        if gmSEQ.ctrN>1
            refDatum(1,:)=sum(RawData1(2:gmSEQ.ctrN:end));
            if gmSEQ.ctrN>2
                refDatum(2,:)=sum(RawData1(3:gmSEQ.ctrN:end));
                if gmSEQ.ctrN>3
                    refDatum(3,:)=sum(RawData1(4:gmSEQ.ctrN:end));
                    if gmSEQ.ctrN>4
                        refDatum(4,:)=sum(RawData1(5:gmSEQ.ctrN:end));
                        if gmSEQ.ctrN>5
                            refDatum(5,:)=sum(RawData1(6:gmSEQ.ctrN:end));
                        else
                            refDatum(5)=NaN;
                        end
                    else
                        refDatum(4)=NaN;
                    end
                else
                    refDatum(3)=NaN;
                end
            else
                refDatum(2)=NaN;
            end
        else
            refDatum(1)=NaN;
            refDatum(2)=NaN;
            refDatum(3)=NaN;
            refDatum(4)=NaN;
            refDatum(5)=NaN;
        end
    end
    
end

function refCounts = Track(what)
global gmSEQ gSG
if gmSEQ.bTrack
    % get the handle of Gui1
    h = findobj('Tag','ImageNVCGUI');
    
    % if exists (not empty)
    if ~isempty(h)
        % get handles and other user-defined data associated to Gui1
        handles_ImageNVC = guidata(h);
    end
    
    if (isfield(gmSEQ,'bLiO'))
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','MWswitch1')+2^SequencePool('PBDictionary','AOM'));
    else
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
    end
    
    
    % turn on laser AWG as well
    ImageFunctionPool('UpdateVoltage', 0, 0, handles_ImageNVC);
    pause(0.2);
    
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
        if currentCounts<0.85*gmSEQ.refCounts || currentCounts>1.15*gmSEQ.refCounts
            PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
            % turn on AWG as well
            ImageFunctionPool('UpdateVoltage', 0, 0, handles_ImageNVC);
            pause(0.2);
            
            for i=1:3
                currentCounts = ImageFunctionPool('NewTrackFast',0, 0, handles_ImageNVC);
                drawnow;
                if gmSEQ.bGo==0
                    refCounts=currentCounts;
                    return
                end
            end
            if ~isfield(gmSEQ,'bLiO')
                ExperimentFunctionPool('PBOFF',0, 0, handles_ImageNVC);
            end
            %             if currentCounts<.3*gmSEQ.refCounts
            %                 KillAllTasks;
            %                 gSG.bOn=0; SignalGeneratorFunctionPool('RFOnOff');
            %                 error('Tracking failed! Aborting...')
            %             end
            refCounts=currentCounts;
        else
            refCounts=gmSEQ.refCounts;
        end
    case 'ImageCorr'
        disp(['ImageCorrelate']);
        PBFunctionPool('PBON',2^SequencePool('PBDictionary','AOM'));
        ImageFunctionPool('TrackImageCorr',0, 0, handles_ImageNVC);
        ImageFunctionPool('TrackZ',0, 0, handles_ImageNVC); %disable
        %z-track, WJ 5/2/23 (not very accurate due to hysteresis inconsistency) 
        refCounts = currentCounts;
        
end


% Get the path for saving data for each ave
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
%final= fullfile(gSaveDataAve.path, file);



