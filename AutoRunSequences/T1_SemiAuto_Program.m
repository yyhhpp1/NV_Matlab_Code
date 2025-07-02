function T1_SemiAuto_Program(hObject, eventdata, handles, handles2)

% handles is experiment GUI
% handels2 is T1param GUI

global gSaveDataAve

seqs_to_run = {'Presets','ESR','Rabi','ESR2','Rabi2','T00','T11'};

for i_seq = 1:length(seqs_to_run)
    
    % load param from child (T1) GUI to parent (main exp) GUI
    load_input_to_main_GUI(seqs_to_run{i_seq}, handles, handles2)
    
    % load main exp GUI input to gmSEQ
    Auto_LoadUserInputs(hObject,eventdata,handles);
    
    % run each seqeunce
    if strcmp(seqs_to_run{i_seq}, 'Presets')~= 1
        T1_SemiAuto_Run(hObject, eventdata, handles, handles2);
        
        % save the main exp GUI figure
        if handles2.use_title.Value
            name = strcat(handles2.figTitle.String, gSaveDataAve.file);
        else
            name = gSaveDataAve.file;
        end
        filename = strcat('C:\Users\dilution_fridge_2\Desktop\T1_SemiAuto_Saves\',name);
        filename = replace(filename, '.txt', '.png');
        filename_char = filename{1};
        imwrite(getframe(handles.figure1).cdata, filename_char)
        
        % upload saved GUI figure to slack
        if handles2.slackUploadFlag.Value
            message = [char(handles2.slackUploadText.String) '. Current sequence is finished.'];
            default_keep = int32(100); %keep only 100 uploads
            scriptFolder = 'C:\Matlab_Code\AutoRunSequences';

            % Add it to Python's module search path if not already there
            if count(py.sys.path, scriptFolder) == 0
                insert(py.sys.path, int32(0), scriptFolder)
            end
            
            py.slack_upload_v2.upload_and_cleanup(filename_char, message, default_keep);
        end
        
    end
    
    % stop program if button pressed
    if handles2.pushbutton_stopProg.UserData; break; end
end

end

function load_input_to_main_GUI(which, handles, h)
global gmSEQ

if strcmp(which, 'Presets')
    if h.zone1_radio_button.Value
        seq.readout = h.initZ1.String;
        seq.CtrGateDur = h.readoutZ1.String;
    elseif h.zone2_radio_button.Value
        seq.readout = h.initZ2.String;
        seq.CtrGateDur = h.readoutZ2.String;
    elseif h.zone3_radio_button.Value
        seq.readout = h.initZ3.String;
        seq.CtrGateDur = h.readoutZ3.String;
    end
    
elseif strcmp(which, 'ESR')
    seq.name = 'ESR';
    seq.FROM1 = h.startESR.String;
    seq.TO1 = h.stopESR.String;
    seq.SweepNPoints= h.nPtsESR.String;
    seq.fixPow = h.MWPowerESR.String;
    seq.misc = h.RepeatESR.String;
    seq.Average =  h.maxAveESR.String;
    seq.useSG2 = 0;
    seq.bSweep2 = 0;
    
elseif strcmp(which, 'Rabi')
    seq.name = 'Rabi';
    seq.FROM1 = h.startRabi.String;
    seq.TO1 = h.stopRabi.String;
    seq.SweepNPoints= h.nPtsRabi.String;
    seq.fixPow = h.MWPowerRabi.String;
    seq.Repeat = h.RepeatRabi.String;
    seq.Average =  h.maxAveRabi.String;
    seq.useSG2 = 0;
    
    seq.fixFreq = sprintf('%.8f', gmSEQ.ESRFitFreq/1000);
    
elseif strcmp(which, 'ESR2')
    seq.name = 'ESR';
    seq.FROM1 = h.startESR2.String;
    seq.TO1 = h.stopESR2.String;
    seq.SweepNPoints= h.nPtsESR2.String;
    seq.fixPow = h.MWPowerESR2.String;
    seq.misc = h.RepeatESR2.String;
    seq.Average =  h.maxAveESR2.String;
    seq.useSG2 = 0;
    
    seq.pi = sprintf('%.0f', gmSEQ.RabiFitPi); %save the pi time before the 2nd rabi
    
elseif strcmp(which, 'Rabi2')
    seq.name = 'Rabi_SG2';
    seq.FROM1 = h.startRabi2.String;
    seq.TO1 = h.stopRabi2.String;
    seq.SweepNPoints= h.nPtsRabi2.String;
    seq.fixPow2 = h.MWPowerRabi2.String;
    seq.Repeat = h.RepeatRabi2.String;
    seq.Average =  h.maxAveRabi2.String;
    seq.useSG2 = 1;
    
    seq.fixFreq2 = sprintf('%.8f', gmSEQ.ESRFitFreq/1000);
    
    
elseif strcmp(which, 'T11')
    
    %Split the sweep range to two parts: 1/4, 3/4 of total sweep range
    t0 = str2double(h.startT1.String);
    t1 =str2double(h.stopT1.String);
    tr = t1 - t0;
    FROM1 = t0;
    TO1 = t0 + round(tr/4, -3);
    FROM2 = TO1;
    TO2 = t1;
    
    seq.name = 'T1_S11_S1m1'; %T1_S00_S01_S10_S11_S1m1, T1_S11_S1m1
    seq.FROM1 = num2str(FROM1);
    seq.TO1 = num2str(TO1);
    seq.SweepNPoints= h.nPtsT1.String;
    seq.fixPow = h.MWPowerRabi.String;
    seq.fixPow2 = h.MWPowerRabi2.String;
    seq.Repeat = h.RepeatT1.String;
    seq.Average =  h.maxAveT1.String;
    seq.useSG2 = 1;
    
    seq.bSweep2 = 1;
    seq.FROM2 = num2str(FROM2);
    seq.TO2 = num2str(TO2);
    seq.SweepNPoints2 = h.nPtsT1.String;
    
    seq.DEERpi = sprintf('%.0f', gmSEQ.RabiFitPi);
elseif strcmp(which, 'T00')
    
    %Split the sweep range to two parts: 1/4, 3/4 of total sweep range
    t0 = str2double(h.startT1.String);
    t1 =str2double(h.stopT1.String);
    tr = t1 - t0;
    FROM1 = t0;
    TO1 = t0 + round(tr/4, -3);
    FROM2 = TO1;
    TO2 = t1;
    
    seq.name = 'T1_S00_S01_S10'; %T1_S00_S01_S10_S11_S1m1, T1_S11_S1m1
    seq.FROM1 = num2str(FROM1);
    seq.TO1 = num2str(TO1);
    seq.SweepNPoints= h.nPtsT1.String;
    seq.fixPow = h.MWPowerRabi.String;
    seq.fixPow2 = h.MWPowerRabi2.String;
    seq.Repeat = h.RepeatT1.String;
    seq.Average =  h.maxAveT1.String;
    seq.useSG2 = 0;
    
    seq.bSweep2 = 1;
    seq.FROM2 = num2str(FROM2);
    seq.TO2 = num2str(TO2);
    seq.SweepNPoints2 = h.nPtsT1.String;
    
else
    disp('you should not be here')
end

fld = fieldnames(seq);
num_para = numel(fld);
for i_para = 1: num_para
    if strcmp(fld{i_para},'name')
        handles.sequence.Value = 1;
        handles.sequence.String = {seq.(fld{i_para})};
        gmSEQ.name = {seq.(fld{i_para})};
    elseif ~isnumeric(seq.(fld{i_para}))
        set(handles.(fld{i_para}),'String',seq.(fld{i_para}))
    else
        set(handles.(fld{i_para}),'Value',seq.(fld{i_para}))
    end
end

end

