function Auto_T1(hObject, eventdata, handles)
%======================================================================
%  Automated T1
%  Pulse ESR, Rabi, then T1
%  Originally by Haopu Yang
%  Improved by ChatGPT 5
%======================================================================
global gmSEQ gSaveDataAve

gmSEQ.bAutoRun = true;

SAVE_ROOT = "C:\Users\Yao-RT3\Desktop\autoruns\";

if ~gmSEQ.bAutoRun, disp('AutoRun stopped.'); return; end

try
    % Create folder
    path = ensureFolder(SAVE_ROOT);

    % Disable tracking
    set(handles.bTrack, 'Value', 0);
    drawnow limitrate nocallbacks;
    
    fc = 2250;
    span = 100;
    freq = runPulsedESR(fc, path, span); if ~gmSEQ.bAutoRun, return; end
    fprintf('Frequency Peak: %.4f MHz', freq)
    pitime = runRabi(freq, path); if ~gmSEQ.bAutoRun, return; end
    fprintf('Pi time: %.4f ns', pitime)
    runSQT1(pitime, path); if ~gmSEQ.bAutoRun, return; end

catch ME
    rethrow(ME);
end


disp('AutoRun completed successfully.');

%======================================================================
% Helper Functions
%======================================================================

    function savePath = ensureFolder(root)
        savePath = root + datestr(now, 'yyyymmdd_HHMMSS');
        if ~isfolder(savePath)
            mkdir(savePath);
            fprintf('Created folder: %s\n', savePath);
        end
    end

    function f_fit = runPulsedESR(fc, path, span)
        gmSEQ.name = "f_PulsedESR";
        setSequence(handles, "f_PulsedESR");
        a = fc - span/2;
        b = fc + span/2;
        setGUIParams(handles, struct( ...
            'FROM1', a, 'TO1', b, 'SweepNPoints', 21, ...
            'Average', 1, 'Repeat', 1000));

        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);

        % Lorentzian fit
        x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
        y = double(gmSEQ.signal(2,:)) ./ double(gmSEQ.signal(1,:));
        lorentz = @(p,x) p(1) - p(2)./(1+((x-p(3))/p(4)).^2);
        p0 = [mean(y), max(y)-min(y), fc*1e-3, 5e-3];
        opts = optimoptions('lsqcurvefit','Display','off');
        popt = lsqcurvefit(lorentz,p0,x,y,[],[],opts);
        f_fit = popt(3)*1e3;

        % Plot
        hold(handles.axes3,"on");
        plot(handles.axes3, linspace(min(x),max(x),200), lorentz(popt,linspace(min(x),max(x),200)), ...
            'DisplayName', sprintf('f = %.4f', f_fit));
        legend(handles.axes3); hold(handles.axes3,"off");
        safeScreenshot(handles.figure1, path);
    end

    function gain = runGainScan(f, path)
        gmSEQ.name = "f_PiCali";
        setSequence(handles, "f_PiCali");
        set(handles.pi, 'String', "50");
        set(handles.FPGAFreq7, 'String', string(f*1e3));

        if f < 3
            coarse_range = [1, 8];
        else
            coarse_range = [1, 15];
        end
        setGUIParams(handles, struct( ...
            'FROM1', coarse_range(1), 'TO1', coarse_range(2), ...
            'SweepNPoints', 21, 'misc', 1, 'Repeat', 10000, 'Average', 2));

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

    function pitime = runRabi(f, path)
        gmSEQ.name = "f_Rabi";
        setSequence(handles, "f_Rabi");
        set(handles.FPGAFreq7, 'String', string(f));

        setGUIParams(handles, struct( ...
            'FROM1', 12, 'TO1', 212, ...
            'SweepNPoints', 21, 'Repeat', 1000, 'Average', 1));

        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);

        % Fit
        x = double(gmSEQ.SweepParam)*gmSEQ.ScaleT;
        y = double(gmSEQ.signal(2,:)) ./ double(gmSEQ.signal(1,:));
        sineModel = @(p,x) p(1)*cos(pi*x/p(2)+p(3)).*exp(-x/p(5)) + p(4);
        p0 = [(max(y)-min(y))/2, x(find(y==min(y),1)), 0, mean(y), max(x)*2/3];
        lb = [0,0,-pi/2,0, 0]; ub = [1,inf,pi/2,1, inf];
        opts = optimoptions('lsqcurvefit','Display','off');
        popt = lsqcurvefit(sineModel,p0,x,y,lb,ub,opts);
        pitime = round((pi - popt(3))/pi * popt(2)/gmSEQ.ScaleT);

        % Plot
        hold(handles.axes3,"on");
        plot(handles.axes3, linspace(min(x),max(x),200), ...
            sineModel(popt,linspace(min(x),max(x),200)), ...
            'DisplayName', sprintf('pi = %.3f', pitime));
        legend(handles.axes3); hold(handles.axes3,"off");
        safeScreenshot(handles.figure1, path);
    end

    function runT1Rho(f, gain, p, TO1, path)
        if gain>20, warning('STOPPED: high FPGA power.'); return; end
        gmSEQ.name = "f_T1_Spin_Locking";
        setSequence(handles, gmSEQ.name);
        set(handles.pi,'String',string(p));
        set(handles.FPGAFreq7,'String',string(f*1e3));
        set(handles.FPGAGain7,'String',string(gain));
        setGUIParams(handles, struct('FROM1',0,'TO1',TO1,...
            'SweepNPoints',21,'Repeat',100,'Average',10));
        Auto_LoadUserInputs(hObject,eventdata,handles);
        RunSequence(hObject,eventdata,handles);
        safeScreenshot(handles.figure1, path);
    end

    function runSQT1(p, path)
        gmSEQ.name = "f_T1_S00_S01_S10";
        setSequence(handles, gmSEQ.name);
        set(handles.pi,'String',string(p));
        setGUIParams(handles, struct('FROM1',1000,'TO1',100001000,...
            'SweepNPoints',11,'Repeat',10,'Average',50));
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
        setGUIParams(handles, struct('FROM1',1000,'TO1',6001000,...
            'SweepNPoints',21,'Repeat',1000,'Average',15));
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
