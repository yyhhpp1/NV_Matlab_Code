function Auto_Run_B_Sweep(hObject, eventdata, handles)
global gmSEQ
gmSEQ.bAutoRun = 1;

% Preset Parameters
%Target_B_lst = [60, 40, 20];     % unit: Gauss
Target_B_lst = [60, 40, 20, 150, 170, 220, 240, 260, 280, 300, 320, 340, 360, 380, 400];     % unit: Gauss
ZFS = 2.871;                        % unit: GHz
gamma = 2.8e-3;                     % unit: GHz/Gauss
gauss_to_current = [0.002610721442886, ...
                    0.001566633266533, ...
                    0.006737474949900 ];       % unit: A/Gauss

% Loop over Target_B_lst
for i = 1:length(Target_B_lst)
    % Read target B
    B_target = Target_B_lst(i);
    f1_target = ZFS - gamma * B_target;
    f2_target = ZFS + gamma * B_target;

    % Create Folder to save
    path = createSaveFolder(B_target);

    % Set target Ix, Iy, Iz
    setTargetCurrents(B_target, gauss_to_current);

    % Turn off tracking
    set(handles.bTrack, 'Value',0)
    drawnow limitrate nocallbacks;

    % ESR f1 and f2
    f1_fit = runESR(f1_target);
    if ~gmSEQ.bAutoRun
        disp('AutoRun is stopped.')
        return
    end
    f2_fit = runESR(f2_target);
    if ~gmSEQ.bAutoRun
        disp('AutoRun is stopped.')
        return
    end

    % scan fpga gains
    gain1 = runGainScan(f1_fit);
    if ~gmSEQ.bAutoRun
        disp('AutoRun is stopped.')
        return
    end
    gain2 = runGainScan(f2_fit);
    if ~gmSEQ.bAutoRun
        disp('AutoRun is stopped.')
        return
    end

    % Turn on tracking
    set(handles.bTrack, 'Value',1)
    drawnow limitrate nocallbacks;

    % SQ T1
    runSQT1(f1_fit, gain1)
    if ~gmSEQ.bAutoRun
        disp('AutoRun is stopped.')
        return
    end

    % DQ T1
    runDQT1(f1_fit, gain1, f2_fit, gain2)
    if ~gmSEQ.bAutoRun
        disp('AutoRun is stopped.')
        return
    end
end
disp('AutoRun is completed.')

    function fullPath = createSaveFolder(B_target)
        rootPath = "C:\Users\MoleculeExp\Desktop\autoruns\";
        fullPath = rootPath + sprintf("B_%d_G", B_target);

        % Check if folder exists
        if ~isfolder(fullPath)
            mkdir(fullPath);
            fprintf('Created new folder: %s\n', fullPath);
        else
            fprintf('Folder already exists: %s\n', fullPath);
        end
    end

    function setTargetCurrents(B, c2g)
        I = B * c2g;

        global gMag;
        gMag.x.ISet(I(1)); pause(0.5);
        gMag.y.ISet(I(2)); pause(0.5);
        gMag.z.ISet(I(3)); pause(0.5);
    end


    function f_fit = runESR(fc)
        handles.sequence.Value = 1; 
        handles.sequence.String = "ESR";
        drawnow limitrate nocallbacks;
        gmSEQ.name = "ESR";
        
        scan_span = 0.05; %unit: GHz

        a = fc - scan_span/2;
        b = fc + scan_span/2;
        
        % make sure stay in srs scan range.
        if a < 3.0375 && 3.0375 < b
            if abs(3.0375 - a) < abs(3.0375 - b)
                % 3.0375 closer to a
                b = 3.0375 + (b - a);
                a = 3.0375;
            else
                % 3.0375 closer to b
                a = 3.0375 - (b - a);
                b = 3.0375;
            end
        end
        
        from1_str = string(a);
        to1_str = string(b);
        
        % GUI input
        set(handles.FROM1,       'String', from1_str)
        set(handles.TO1,         'String', to1_str  )
        set(handles.SweepNPoints,'String', "101"    )
        set(handles.misc,        'String', "5"      )
        set(handles.Average,     'String', "5"      )
        set(handles.fixPow,      'String', "-45"    )
        drawnow limitrate nocallbacks;
        
        % Run
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject, eventdata, handles);
        
        % Fit
        x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT; % GHz
        y = double(gmSEQ.signal(1, :));
        
        lorentz = @(p, x) p(1) - p(2) ./ (1 + ((x - p(3))/p(4)).^2); 
        offset0 = mean(y);
        amp0 = max(y) - min(y);
        gamma0 = 5e-3;  % GHz
        p0 = [offset0, amp0, fc, gamma0];

        opts = optimoptions('lsqcurvefit', 'Display', 'off');
        popt = lsqcurvefit(lorentz, p0, x, y, [], [], opts);
        f_fit = popt(3); % GHz

        x_fit = linspace(x(1), x(end), 201);
        y_fit = lorentz(popt, x_fit);
        label = sprintf('f = %.4f', popt(3));
        hold(handles.axes2, "on")
        plot(handles.axes2, x_fit, y_fit, 'DisplayName', label)
        hold(handles.axes2, "off")

        % Screenshot
        global gSaveDataAve
        filename = strrep(gSaveDataAve.file, '.txt', '.png');
        imwrite(getframe(handles.figure1).cdata, fullfile(path, filename))
    end

    function gain = runGainScan(f)
        handles.sequence.Value = 1; 
        handles.sequence.String = "f_PiCali";
        gmSEQ.name = "f_PiCali";
        set(handles.pi,          'String', "50")
        drawnow limitrate nocallbacks;
  
        % Set ch7 freq
        freq_MHz_str = string(f*1e3);
        set(handles.FPGAFreq7,'String', freq_MHz_str)
        drawnow limitrate nocallbacks;

        %%%% Coarse scan %%%%%
        if f < 3
            coarse_range = [1, 8];
        else
            coarse_range = [1, 15];
        end
        set(handles.FROM1,           'String', string(coarse_range(1)))
        set(handles.TO1,             'String', string(coarse_range(2)))
        set(handles.SweepNPoints,    'String', string(21))
        set(handles.misc,            'String', "1")
        set(handles.Repeat,          'String', "10000")
        set(handles.Average,         'String', "2"      )
        drawnow limitrate nocallbacks;

        % Run
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject, eventdata, handles);

        % Fit
        x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
        ref = double(gmSEQ.signal(1, :));
        sig = double(gmSEQ.signal(2, :));
        y = sig./ref;

        sineModel = @(p, x) p(1) * cos(pi*x/p(2) + p(3)) + p(4);
        % p = [A, t, phi, offset]

        A0 = (max(y) - min(y)) / 2;
        [~, minIndex] = min(y);
        t0 = x(minIndex);
        if t0 > max(x) / 2
            t0 = max(x) / 2;
        end
        phi0 = 0;
        offset0 = mean(y);
        p0 = [A0, t0, phi0, offset0];

        lb = [0, 0, -pi/2, 0];
        ub = [1, 20, pi/2, 1];

        % 3. Fit (no bounds)
        opts = optimoptions('lsqcurvefit', 'Display', 'off');
        popt = lsqcurvefit(sineModel, p0, x, y, lb, ub, opts);
        gain_coarse = (pi - popt(3))/pi * popt(2);

        x_fit = linspace(x(1), x(end), 201);
        y_fit = sineModel(popt, x_fit);
        label = sprintf('gain = %.3f', gain_coarse);
        hold(handles.axes3, "on")
        plot(handles.axes3, x_fit, y_fit, 'DisplayName', label)
        legend(handles.axes3)
        hold(handles.axes3, "off")

        % Screenshot
        global gSaveDataAve
        filename = strrep(gSaveDataAve.file, '.txt', '.png');
        imwrite(getframe(handles.figure1).cdata, fullfile(path, filename))
        
        gain = gain_coarse;

        % %%%% Fine scan %%%%%
        % fine_range = [max(0.01, -1.5+gain_coarse) , min(15, gain_coarse)];
        % set(handles.FROM1,           'String', string(fine_range(1)))
        % set(handles.TO1,             'String', string(fine_range(2)))
        % set(handles.SweepNPoints,    'String', "11")
        % set(handles.misc,            'String', "3")
        % set(handles.Repeat,          'String', "10000")
        % set(handles.Average,         'String', "2"      )
        % 
        % % Run
        % Auto_LoadUserInputs(hObject,eventdata,handles);
        % RunSequence(hObject, eventdata, handles);
        % 
        % % Fit
        % x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
        % ref = double(gmSEQ.signal(1, :));
        % sig = double(gmSEQ.signal(2, :));
        % y = sig./ref;
        % 
        % sineModel = @(p, x) p(1) * cos(pi*x/p(2) + p(3)) + p(4);
        % % p = [A, t, phi, offset]
        % 
        % A0 = (max(y) - min(y)) / 2;
        % [~, minIndex] = min(y);
        % t0 = x(minIndex);
        % phi0 = 0;
        % offset0 = mean(y);
        % p0 = [A0, t0, phi0, offset0];
        % 
        % lb = [0, 0, -pi/2, 0];
        % ub = [1, 20, pi/2, 1];
        % 
        % % 3. Fit (no bounds)
        % opts = optimoptions('lsqcurvefit', 'Display', 'off');
        % popt = lsqcurvefit(sineModel, p0, x, y, lb, ub, opts);
        % gain = (pi - popt(3))/pi * popt(2);
        % 
        % x_fit = linspace(x(1), x(end), 201);
        % y_fit = sineModel(popt, x_fit);
        % label = sprintf('gain = %.3f', gain);
        % hold(handles.axes3, "on")
        % plot(handles.axes3, x_fit, y_fit, 'DisplayName', label)
        % legend(handles.axes3)
        % hold(handles.axes3, "off")
        % 
        % % Screenshot
        % filename = strrep(gSaveDataAve.file, '.txt', '.png');
        % imwrite(getframe(handles.figure1).cdata, fullfile(path, filename))
    end

    function runSQT1(f, gain)
        if gain > 20
            disp('STOPPED DUE TO HIGH FGPA POWER')
            return
        end

        handles.sequence.Value = 1; 
        handles.sequence.String = "f_T1_S00_S01_S10";
        drawnow limitrate nocallbacks;
        gmSEQ.name = "f_T1_S00_S01_S10";

        % Set ch7 freq, gain
        freq_MHz_str = string(f*1e3);
        gain_str = string(gain);
        set(handles.FPGAFreq7,'String', freq_MHz_str)
        set(handles.FPGAGain7,'String', gain_str)

        from1_str = string(1000);
        to1_str = string(3001000);

        % GUI input
        set(handles.FROM1,       'String', from1_str)
        set(handles.TO1,         'String', to1_str  )
        set(handles.SweepNPoints,'String', "21"    )
        set(handles.Repeat,      'String', "1000")
        set(handles.Average,     'String', "15"      )
        drawnow limitrate nocallbacks;

        % Run
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject, eventdata, handles);
        
        % Screenshot
        global gSaveDataAve
        filename = strrep(gSaveDataAve.file, '.txt', '.png');
        imwrite(getframe(handles.figure1).cdata, fullfile(path, filename))
    end
    
    function runDQT1(f1, gain1, f2, gain2)
        if gain1 > 20
            disp('STOPPED DUE TO HIGH FGPA POWER')
            return
        end

        if gain2 > 20
            disp('STOPPED DUE TO HIGH FGPA POWER')
            return
        end

        handles.sequence.Value = 1; 
        handles.sequence.String = "f_T1_S11_S1m1";
        drawnow limitrate nocallbacks;
        gmSEQ.name = "f_T1_S11_S1m1";

        % Set ch7 freq, gain
        freq_MHz_str = string(f1*1e3);
        gain_str = string(gain1);
        set(handles.FPGAFreq7,'String', freq_MHz_str)
        set(handles.FPGAGain7,'String', gain_str)

        % Set ch6 freq, gain
        freq_MHz_str = string(f2*1e3);
        gain_str = string(gain2);
        set(handles.FPGAFreq6,'String', freq_MHz_str)
        set(handles.FPGAGain6,'String', gain_str)

        from1_str = string(1000);
        to1_str = string(5001000);

        % GUI input
        set(handles.FROM1,       'String', from1_str)
        set(handles.TO1,         'String', to1_str  )
        set(handles.SweepNPoints,'String', "21"    )
        set(handles.Repeat,      'String', "1000")
        set(handles.Average,     'String', "15"      )
        drawnow limitrate nocallbacks;

        % Run
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject, eventdata, handles);
        
        % Screenshot
        global gSaveDataAve
        filename = strrep(gSaveDataAve.file, '.txt', '.png');
        imwrite(getframe(handles.figure1).cdata, fullfile(path, filename))
    end
    
end

