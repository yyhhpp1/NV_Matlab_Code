function ch = complieCHN(CHN)
N_chn = length(CHN);
prog_save = cell(N_chn);
fpga_time_correction = 1e6/(1e6 + 224); %this is newly added to account for fpga time not same as pulseblaster. Haopu 12/3/25
%fpga_time_correction =  1;
for i = 1:N_chn
    prog = ['['];
    N_cmd = length(CHN{i});
    for j = 1:N_cmd
        cmd = CHN{i}{j};
        if ~ischar(cmd)
            cmd = num2str(cmd*fpga_time_correction);
        end
        prog = [prog cmd ','];
    end
    prog = [prog(1:end-1) ']'];
    prog_save{i} = prog;
end

%channel number is changed here. 
if N_chn == 1
    ch.ch1 = prog_save{1};
elseif N_chn == 2
    ch.ch1 = prog_save{1};
    ch.ch2 = prog_save{2};
else
    warning('max number of channels is 2 for now')
end
end

