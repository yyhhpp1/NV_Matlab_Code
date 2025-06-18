function T1_SemiAuto_Program(hObject, eventdata, handles, handles2)

% This function should realize the following task
% Read predefined seqeunce parameter from GUI
% RUN esr
% Fit esr 
% Save esr GUI 
% RUN Rabi
% Fit Rabi
% Save Rabi GUI
% RUN T1
% Fit T1
% Save T1 GUI

global gSaveDataAve

seqs_to_run = {'ESR','Rabi','T1'};

for i_seq = 1:length(seqs_to_run)
    
    load_input_to_main_GUI(seqs_to_run{i_seq}, handles, handles2)
    Auto_LoadUserInputs(hObject,eventdata,handles);
    T1_SemiAuto_Run(hObject, eventdata, handles, handles2);
    filename = strcat('C:\Users\dilution_fridge_2\Desktop\T1_SemiAuto_Saves\',gSaveDataAve.file);
    filename = replace(filename, '.txt', '.png');
    imwrite(getframe(handles.figure1).cdata, filename{1})
    
    if handles2.pushbutton_stopProg.UserData; break; end
end

end

function load_input_to_main_GUI(which, handles, h)
global gmSEQ

if strcmp(which, 'ESR')
    seq.name = 'ESR';
    seq.FROM1 = h.startESR.String;
    seq.TO1 = h.stopESR.String;
    seq.SweepNPoints= h.nPtsESR.String;
    seq.fixPow = h.MWPowerESR.String;
    seq.misc = h.RepeatESR.String;
    seq.Average =  h.maxAveESR.String;
    
elseif strcmp(which, 'Rabi')
    seq.name = 'Rabi';
    seq.FROM1 = h.startRabi.String;
    seq.TO1 = h.stopRabi.String;
    seq.SweepNPoints= h.nPtsRabi.String;
    seq.fixPow = h.MWPowerRabi.String;
    seq.Repeat = h.RepeatRabi.String;
    seq.Average =  h.maxAveRabi.String;
    
    seq.fixFreq = sprintf('%.8f', gmSEQ.ESRFitFreq/1000);
    
elseif strcmp(which, 'T1')
    seq.name = 'T1_S00_S01_S10_S11_darkRef';
    seq.FROM1 = h.startT1.String;
    seq.TO1 = h.stopT1.String;
    seq.SweepNPoints= h.nPtsT1.String;
    seq.fixPow = h.MWPowerT1.String;
    seq.Repeat = h.RepeatT1.String;
    seq.Average =  h.maxAveT1.String;
     
    seq.pi = sprintf('%.0f', gmSEQ.RabiFitPi);
    
else
   disp('here')
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

