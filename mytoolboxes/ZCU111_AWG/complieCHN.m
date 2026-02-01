% function ch = complieCHN(CHN)
% N_chn = length(CHN);
% prog_save = cell(N_chn);
% %fpga_time_correction = 1e6/(1e6 + 0); %this is newly added to account for fpga time not same as pulseblaster. Haopu 12/3/25
% %fpga_time_correction =  1;
% for i = 1:N_chn
%     prog = ['['];
%     N_cmd = length(CHN{i});
%     for j = 1:N_cmd
%         cmd = CHN{i}{j};
%         if ~ischar(cmd)
%             cmd = num2str(cmd);
%         end
%         prog = [prog cmd ','];
%     end
%     prog = [prog(1:end-1) ']'];
%     prog_save{i} = prog;
% end
% 
% %channel number is changed here. 
% if N_chn == 1
%     ch.ch1 = prog_save{1};
% elseif N_chn == 2
%     ch.ch1 = prog_save{1};
%     ch.ch2 = prog_save{2};
% else
%     warning('max number of channels is 2 for now')
% end
% end

function ch = complieCHN(CHN)
    % --- Configuration ---
    %fpga_time_correction = 1e6/(1e6 + 235.5); 
    fpga_time_correction = 1; 

    N_chn = length(CHN);
    prog_save = cell(N_chn, 1);

    for i = 1:N_chn
        prog = '[';
        
        cmd_list = CHN{i}; 
        N_cmd = length(cmd_list);
        
        for j = 1:N_cmd
            cmd = cmd_list{j};
            
            % --- CASE 1: Command is a raw number ---
            if isnumeric(cmd)
                cmd = cmd * fpga_time_correction;
                cmd = num2str(cmd, 12); 
                
            % --- CASE 2: Command is a string ---
            elseif ischar(cmd)
                % 1. Define Patterns
                % P1: Loop -> 'loop(' followed by digits
                p_loop = 'loop\s*\(\s*\d+';
                % P2: Identifier -> Starts with letter or _, contains alphanumeric
                p_id   = '[a-zA-Z_]\w*';
                % P3: Number -> Floats, Ints, Scientific (e.g., 1e-6)
                p_num  = '(\d+(\.\d*)?|\.\d+)([eE][-+]?\d+)?';
                
                % Combine patterns with OR (|). Order matters! 
                % We check for Loops first, then IDs, then raw Numbers.
                full_pat = sprintf('(%s)|(%s)|(%s)', p_loop, p_id, p_num);
                
                % 2. Find all matches
                [matchStr, starts, ends] = regexp(cmd, full_pat, 'match', 'start', 'end');
                
                % 3. Iterate BACKWARDS to replace without messing up indices
                for k = length(matchStr):-1:1
                    token = matchStr{k};
                    
                    % -- LOGIC START --
                    if startsWith(token, 'loop', 'IgnoreCase', true)
                        % Is a loop command: Keep as is
                        replacement = token;
                    elseif isletter(token(1)) || token(1) == '_'
                        % Is an Identifier (e.g., "X_2"): Keep as is
                        replacement = token;
                    else
                        % Is a Number: Apply correction
                        val = str2double(token);
                        val = val * fpga_time_correction;
                        replacement = num2str(val, 12);
                    end
                    % -- LOGIC END --
                    
                    % Inject replacement into the string
                    cmd = [cmd(1:starts(k)-1), replacement, cmd(ends(k)+1:end)];
                end
            end
            
            prog = [prog cmd ','];
        end
        
        % Fix trailing comma
        if N_cmd > 0
            prog(end) = ']';
        else
            prog = [prog ']'];
        end
        
        prog_save{i} = prog;
    end

    % --- Output Assignment ---
    if N_chn == 1
        ch.ch1 = prog_save{1};
    elseif N_chn == 2
        ch.ch1 = prog_save{1};
        ch.ch2 = prog_save{2};
    else
        warning('max number of channels is 2 for now')
    end
end