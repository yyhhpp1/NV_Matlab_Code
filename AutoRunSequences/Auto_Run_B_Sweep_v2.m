function Auto_Run_B_Sweep_v2(hObject, eventdata, handles)
    %======================================================================
    %  Automated B-field sweep with ESR, gain calibration, and T1
    %  Originally by Haopu Yang
    %  Improved by ChatGPT 5
    %======================================================================
    global gmSEQ gMag gSaveDataAve

    gmSEQ.bAutoRun = true;

    %------------------ CONSTANTS -----------------------------------------
    ZFS = 2.871;                   % GHz
    gamma = 2.8e-3;                % GHz/Gauss
    SRS_PROTECT_FREQ = 3.0375;     % GHz
    SCAN_SPAN = 0.05;              % GHz
    SAVE_ROOT = "C:\Users\MoleculeExp\Desktop\autoruns\";

    % Magnetic field to current conversion (A/G)
    gauss_to_current = [2.3721, 0.8207, 4.5125]/2/299.2;

    % Target magnetic fields (Gauss)
    Target_B_lst = [10];

    %------------------ MAIN LOOP -----------------------------------------
    for B_target = Target_B_lst
        if ~gmSEQ.bAutoRun, disp('AutoRun stopped.'); return; end

        fprintf('\n=== Starting B = %.1f G ===\n', B_target);

        try
            % Create folder
            savePath = ensureFolder(SAVE_ROOT, B_target);

            % Set target currents
            setTargetCurrents(B_target, gauss_to_current);

            % Disable 
            set(handles.bTrack, 'Value', 0);
            drawnow limitrate nocallbacks;

            %------------------ ESR ------------------
            f1 = ZFS - gamma * B_target;
            f2 = ZFS + gamma * B_target;
            f1_fit = runESR(f1, savePath, SCAN_SPAN, SRS_PROTECT_FREQ);
            if ~gmSEQ.bAutoRun, return; end
            f2_fit = runESR(f2, savePath, SCAN_SPAN, SRS_PROTECT_FREQ);
            if ~gmSEQ.bAutoRun, return; end
            
            %f1_fit = 1.1927;
            %f2_fit = 4.5507;

            %------------------ GAIN & RABI ------------------
            g1 = runGainScan(f1_fit, savePath);
            %g1 = 2.0574; 
            if ~gmSEQ.bAutoRun, return; end
            p1 = runRabi(f1_fit, g1, savePath);
            if ~gmSEQ.bAutoRun, return; end
            g2 = runGainScan(f2_fit, savePath);
            %g2 = 17.7384;
            if ~gmSEQ.bAutoRun, return; end
            p2 = runRabi(f2_fit, g2, savePath);
            if ~gmSEQ.bAutoRun, return; end

            % Enable tracking
            set(handles.bTrack, 'Value', 1);
            drawnow limitrate nocallbacks;

            %------------------ SQ and DQ T1 ------------------
            %runSQT1(f1_fit, g1, p1, savePath);
            if ~gmSEQ.bAutoRun, return; end
            if B_target<10000
                runSQT1(f2_fit, g2, p2, savePath);
            end
            if ~gmSEQ.bAutoRun, return; end
            runDQT1(f1_fit, g1, p1, f2_fit, g2, p2, savePath);

        catch ME
            warning('Error at B = %.1f G: %s', B_target, ME.message);
        end
    end

    disp('AutoRun completed successfully.');

    %======================================================================
    % Helper Functions
    %======================================================================

    function savePath = ensureFolder(root, B)
        savePath = root + sprintf("B_%d_G", B);
        if ~isfolder(savePath)
            mkdir(savePath);
            fprintf('Created folder: %s\n', savePath);
        end
    end

    function setTargetCurrents(B, c2g)
        I = B * c2g;
        fprintf('\n=== [Ix, Iy, Iz] = [%.4f, %.4f, %.4f] A ===\n', ...
            I(1), I(2), I(3));
        gMag.x.ISet(I(1)); pause(0.3);
        gMag.y.ISet(I(2)); pause(0.3);
        gMag.z.ISet(I(3)); pause(0.3);
    end

    function f_fit = runESR(fc, path, span, protect_freq)
        gmSEQ.name = "ESR";
        setSequence(handles, "ESR");
        [a, b] = adjustScanRange(fc, span, protect_freq);
        setGUIParams(handles, struct( ...
            'FROM1', a, 'TO1', b, 'SweepNPoints', 101, ...
            'misc', 5, 'Average', 5, 'fixPow', -45));

        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);

        % Lorentzian fit
        x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
        y = double(gmSEQ.signal(1,:));
        lorentz = @(p,x) p(1) - p(2)./(1+((x-p(3))/p(4)).^2);
        [val, idx] = min(y);
        p0 = [mean(y), max(y)-min(y), x(idx), 2e-3];
        opts = optimoptions('lsqcurvefit','Display','off');
        popt = lsqcurvefit(lorentz,p0,x,y,[],[],opts);
        f_fit = popt(3);

        % Plot
        hold(handles.axes2,"on");
        plot(handles.axes2, linspace(min(x),max(x),200), lorentz(popt,linspace(min(x),max(x),200)), ...
             'DisplayName', sprintf('f = %.4f', f_fit));
        legend(handles.axes3); hold(handles.axes3,"off");
        safeScreenshot(handles.figure1, path);
    end

    function gain = runGainScan(f, path)
        gmSEQ.name = "f_PiCali";
        setSequence(handles, "f_PiCali");
        set(handles.pi, 'String', "200");
        set(handles.FPGAFreq7, 'String', string(f*1e3));

        if f < 3
            coarse_range = [1, 5];
        else
            coarse_range = [1, 10];
        end
        setGUIParams(handles, struct( ...
            'FROM1', coarse_range(1), 'TO1', coarse_range(2), ...
            'SweepNPoints', 11, 'misc', 1, 'Repeat', 10000, 'Average', 1));

        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);

        % Fit
        x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
        y = double(gmSEQ.signal(2,:)) ./ double(gmSEQ.signal(1,:));
        sineModel = @(p,x) p(1)*cos(pi*x/p(2)+p(3)) + p(4);
        p0 = [(max(y)-min(y))/2, x(find(y==min(y),1)), 0, mean(y)];
        lb = [0,0,-pi/2,0]; ub = [1,20,pi/2,1];
        opts = optimoptions('lsqcurvefit','Display','off');
        popt = lsqcurvefit(sineModel,p0,x,y,lb,ub,opts);
        gain = (pi - popt(3))/pi * popt(2);

        % Plot
        hold(handles.axes3,"on");
        plot(handles.axes3, linspace(min(x),max(x),200), ...
            sineModel(popt,linspace(min(x),max(x),200)), ...
            'DisplayName', sprintf('gain = %.3f', gain));
        legend(handles.axes3); hold(handles.axes3,"off");
        safeScreenshot(handles.figure1, path);
    end

    function pitime = runRabi(f, g, path)
        gmSEQ.name = "f_Rabi";
        setSequence(handles, "f_Rabi");
        set(handles.FPGAGain7,'String',string(g));
        set(handles.FPGAFreq7, 'String', string(f*1e3));

        rabi_range = [4, 404];
        setGUIParams(handles, struct( ...
            'FROM1', rabi_range(1), 'TO1', rabi_range(2), ...
            'SweepNPoints', 21, 'misc', 1, 'Repeat', 10000, 'Average', 2));

        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);

        % Fit
        x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT; %us
        y = double(gmSEQ.signal(2,:)) ./ double(gmSEQ.signal(1,:));
        sineModel = @(p,x) p(1)*cos(pi*x/p(2)+p(3)) + p(4);
        p0 = [(max(y)-min(y))/2, x(find(y==min(y),1)), 0, mean(y)];
        lb = [0,0,-pi/2,0]; ub = [1,500,pi/2,1];
        opts = optimoptions('lsqcurvefit','Display','off');
        popt = lsqcurvefit(sineModel,p0,x,y,lb,ub,opts);
        pitime = round((pi - popt(3))/pi * popt(2)*1000);%ns

        % Plot
        hold(handles.axes3,"on");
        plot(handles.axes3, linspace(min(x),max(x),200), ...
            sineModel(popt,linspace(min(x),max(x),200)), ...
            'DisplayName', sprintf('gain = %.3f', pitime));
        legend(handles.axes3); hold(handles.axes3,"off");
        safeScreenshot(handles.figure1, path);
    end


    function runSQT1(f, gain, p, path)
        if gain>20, warning('STOPPED: high FPGA power.'); return; end
        gmSEQ.name = "f_T1_S00_S01_S10";
        setSequence(handles, gmSEQ.name);
        set(handles.pi,'String',string(p));
        set(handles.FPGAFreq7,'String',string(f*1e3));
        set(handles.FPGAGain7,'String',string(gain));
        setGUIParams(handles, struct('FROM1',1000,'TO1',5001000,...
            'SweepNPoints',21,'Repeat',1000,'Average',10));
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);
        safeScreenshot(handles.figure1, path);
    end

    function runDQT1(f1,g1,p1,f2,g2,p2,path)
        if any([g1,g2]>20), warning('STOPPED: high FPGA power.'); return; end
        gmSEQ.name = "f_T1_S11_S1m1";
        setSequence(handles, gmSEQ.name);
        set(handles.pi,'String',string(p1));
        set(handles.DEERpi,'String',string(p2));
        set(handles.FPGAFreq7,'String',string(f1*1e3));
        set(handles.FPGAGain7,'String',string(g1));
        set(handles.FPGAFreq6,'String',string(f2*1e3));
        set(handles.FPGAGain6,'String',string(g2));
        setGUIParams(handles, struct('FROM1',1000,'TO1',8001000,...
            'SweepNPoints',21,'Repeat',1000,'Average',10));
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);
        safeScreenshot(handles.figure1, path);
    end

    %------------------ Utility helpers -----------------------------------
    function [a,b] = adjustScanRange(fc, span, protect_freq)
        a = fc - span/2; b = fc + span/2;
        if a<protect_freq && protect_freq<b
            if abs(protect_freq-a) < abs(protect_freq-b)
                b = protect_freq + (b - a); a = protect_freq;
            else
                a = protect_freq - (b - a); b = protect_freq;
            end
        end
    end

    function setSequence(handles, name)
        handles.sequence.Value = 1;
        handles.sequence.String = name;
        drawnow limitrate nocallbacks;
    end

    function setGUIParams(handles, p)
        fn = fieldnames(p);
        for k = 1:numel(fn)
            set(handles.(fn{k}), 'String', string(p.(fn{k})));
        end
        drawnow limitrate nocallbacks;
    end

    function safeScreenshot(fig, path)
        pause(0.1); % ensure update
        try
            f = getframe(fig); pause(0.1)
            [~,name,~] = fileparts(gSaveDataAve.file);
            imwrite(f.cdata, fullfile(path, name + ".png"));
        catch
            warning('Screenshot failed.');
        end
    end
end
