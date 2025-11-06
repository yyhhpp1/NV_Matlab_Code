function Auto_Run_B_Grid_Search(hObject, eventdata, handles)
%======================================================================
% Automated current grid search to measure ESR at each (Ix, Iy, Iz)
%======================================================================
global gmSEQ gMag gSaveDataAve

gmSEQ.bAutoRun = true;

%------------------ CONSTANTS -----------------------------------------
f1 = 3.6;                 % GHz
f2 = 3.75;                 % GHz
SAVE_ROOT = "C:\Users\MoleculeExp\Desktop\autoruns\grid_search\";

% Define current search grid
I_start = [1.4353, 0, 2.7584];
I_end   = [1.6353, 0, 2.7584];
nI      = [5, 1, 1];   % number of points along each axis
I_center = (I_start + I_end)/2;

% Generate grid
Ix = linspace(I_start(1), I_end(1), nI(1));
Iy = linspace(I_start(2), I_end(2), nI(2));
Iz = linspace(I_start(3), I_end(3), nI(3));
[IX, IY, IZ] = ndgrid(Ix, Iy, Iz);
Target_I_lst = [IX(:), IY(:), IZ(:)];

% ESR scan parameters
Npts = 151;
Misc = 10;
NAve = 5;
fixPow = -45;

%------------------ MAIN LOOP -----------------------------------------
fprintf('Grid search: %d total points\n', size(Target_I_lst,1));

% Create folder
path = ensureFolder(SAVE_ROOT, I_center);

for idx = 1:size(Target_I_lst,1)
    if ~gmSEQ.bAutoRun
        disp('AutoRun stopped.');
        return;
    end

    I = Target_I_lst(idx, :);
    fprintf('\n=== Grid point %d/%d: [%.4f, %.4f, %.4f] A ===\n', ...
            idx, size(Target_I_lst,1), I(1), I(2), I(3));

    try

        % Set target currents
        setTargetCurrents(I);

        %------------------ ESR ------------------
        runESR(f1, f2, Npts, Misc, NAve, fixPow);

        name = safeScreenshot(handles.figure1, path, idx);

    catch ME
        warning('Error at grid point %d: %s', idx, ME.message);
    end
end

disp('AutoRun completed successfully.');

%======================================================================
% Helper Functions
%======================================================================

function savePath = ensureFolder(root, I)
    savePath = root + sprintf("Grid_center_Ix%.4f_Iy%.4f_Iz%.4f",I(1), I(2), I(3));
    if ~isfolder(savePath)
        mkdir(savePath);
        fprintf('Created folder: %s\n', savePath);
    end
end

function setTargetCurrents(I)
    gMag.x.ISet(I(1)); pause(0.3);
    gMag.y.ISet(I(2)); pause(0.3);
    gMag.z.ISet(I(3)); pause(0.3);
end

function runESR(f1, f2, Npts, Misc, NAve, fixPow)
    gmSEQ.name = "ESR";
    setSequence(handles, "ESR");

    % GUI parameters
    setGUIParams(handles, struct( ...
        'FROM1', f1, 'TO1', f2, 'SweepNPoints', Npts, ...
        'misc', Misc, 'Average', NAve, 'fixPow', fixPow));

    Auto_LoadUserInputs(hObject,eventdata,handles);
    RunSequence(hObject,eventdata,handles);
end

%------------------ Utility helpers -----------------------------------

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

function name = safeScreenshot(fig, path, idx)
    pause(0.1); % ensure update
    try
        f = getframe(fig);
        [~, name, ~] = fileparts(gSaveDataAve.file);
        imwrite(f.cdata, fullfile(path, "Id_" + string(idx) + "_" + name + ".png"));
    catch
        warning('Screenshot failed.');
    end
end

end
