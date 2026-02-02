function corrected_chn = ApplyFPGATimeCorrection(chn_data, ppm_offset)
arguments
    chn_data
    ppm_offset = 236.1;
end
    % Change the Pulseblaster rather than FPGA time axies 
    %
    % CHANGE LOGIC:
    % 1. IDENTIFY TRIGGER ANCHOR: The FPGA and PulseBlaster clocks only 
    %    diverge once the FPGA is active. We use FPGA Trigger as the 
    %    t_trigger reference. Any time before this point is "Absolute Time."
    % 2. COORDINATE TRANSFORMATION: For any timestamp T > t_trigger, we 
    %    scale only the duration that occurs after the trigger:
    %    T_new = t_trigger + (T_orig - t_trigger) * (1 + alpha).
    % 3. INTERVAL SPLITTING: For pulses (DT) that "cover" the trigger 
    %    (Start < t_trig < End), only the portion of the duration that 
    %    exists after the trigger is scaled.
    % 4. INTEGER QUANTIZATION: Because the PulseBlaster hardware only 
    %    accepts integer, all final results are rounded to 
    %    the nearest integer to prevent driver errors.
    
    % Calculate scaling factor
    alpha = ppm_offset / 1e6;
    scaling_factor = (1 + alpha);
    
    % Locate the FPGA trigger (PBN 4) to find the drift start point
    idx_trig = find([chn_data.PBN] == PBDictionary('FPGATrig'), 1);
    if isempty(idx_trig)
        return
    end
    t_trig = chn_data(idx_trig).T(1);
    
    corrected_chn = chn_data;
    
    for i = 1:numel(chn_data)
        % --- Correct Start Times (T) ---
        % Logic: If the pulse starts after the trigger, scale the delay 
        % relative to the trigger point.
        for j = 1:length(chn_data(i).T)
            t_start = chn_data(i).T(j);
            if t_start > t_trig
                corrected_chn(i).T(j) = round(t_trig + (t_start - t_trig) * scaling_factor);
            else
                 corrected_chn(i).T(j) = round(t_start);
            end
        end
        
        % --- Correct Durations (DT) ---
        % Logic: Scale the portion of the pulse duration that falls 
        % within the "drifting" time zone (t > t_trig).
        for j = 1:length(chn_data(i).DT)
            t_start = chn_data(i).T(j);
            dt_orig = chn_data(i).DT(j);
            t_end = t_start + dt_orig;
            
            if t_start >= t_trig
                % Case: Pulse is entirely in the drift zone
                corrected_chn(i).DT(j) = round(dt_orig * scaling_factor);
            elseif t_end > t_trig
                % Case: Pulse overlaps the trigger
                pre_trig_dt = t_trig - t_start;
                post_trig_dt = t_end - t_trig;
                corrected_chn(i).DT(j) = round(pre_trig_dt + (post_trig_dt * scaling_factor));
            else
                corrected_chn(i).DT(j) = round(dt_orig);
            end
            % Else: Entirely before trigger, no change needed.
        end
        
        % --- Correct Delays ---
        % No correction to the delay value           
        
        % --- FINAL HARDWARE QUANTIZATION ---
        % Ensure PulseBlaster receives only integers for all time fields
        corrected_chn(i).T = round(corrected_chn(i).T);
        corrected_chn(i).DT = round(corrected_chn(i).DT);
        corrected_chn(i).Delays = round(corrected_chn(i).Delays);

    end
end