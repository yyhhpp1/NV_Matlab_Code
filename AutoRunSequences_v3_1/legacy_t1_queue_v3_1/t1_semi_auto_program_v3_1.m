function t1_semi_auto_program_v3_1(hObject, eventdata, handlesMain, handlesAuto)
% Thin v3.1 wrapper that delegates execution to the v2.1 core program.
% Add future v3.1-only automation hooks before/after the delegate call.

ensure_v2_1_path();

% v3.1 pre-run hook area.

t1_semi_auto_program(hObject, eventdata, handlesMain, handlesAuto);

% v3.1 post-run hook area.
end

function ensure_v2_1_path()
thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
v2Dir = fullfile(repoRoot, 'AutoRunSequences_v2_1');

if ~isfolder(v2Dir)
    error('SmartT1:v3_1:MissingV2_1', ...
        'Cannot find AutoRunSequences_v2_1 at: %s', v2Dir);
end

addpath(thisDir, '-begin');
addpath(v2Dir, '-end');
end
