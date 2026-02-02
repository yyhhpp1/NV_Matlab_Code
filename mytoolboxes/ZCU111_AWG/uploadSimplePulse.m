function uploadSimplePulse(name, freq, amp, dur, phase)
global fpga

%fpga_time_correction = 1e6/(1e6 + 235.5);
fpga_time_correction = 1;

s.name = name;
s.style = "const";
s.freq = freq;
s.gain = amp;
s.phase =  phase;
s.length = dur;
s.mode = "oneshot";
js = jsonencode(s);
temp_save_path = ['C:\Matlab_Code\mytoolboxes\ZCU111_AWG\fpga_temp_files\' name '.json'];
fileID = fopen(temp_save_path, 'w');
fwrite(fileID, js, 'char');
fclose(fileID);

%%% fpga upload
fpga.upload_waveform_cfg(temp_save_path, name);
end

