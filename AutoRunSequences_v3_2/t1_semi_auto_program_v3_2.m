function t1_semi_auto_program_v3_2(hObject, eventdata, handlesMain, handlesAuto)
%T1_SEMI_AUTO_PROGRAM_V3_2 Thin v3.2 wrapper over the v2.2 core runner.

ensure_v2_2_path();

% v3.2 pre-run hook area.

smart_relaxation_program_v2_2(hObject, eventdata, handlesMain, handlesAuto);

% v3.2 post-run hook area.
end

function ensure_v2_2_path()
thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
v2Dir = fullfile(repoRoot, 'AutoRunSequences_v2_2');

if ~isfolder(v2Dir)
    error('SmartT1:v3_2:MissingV2_2', ...
        'Cannot find AutoRunSequences_v2_2 at: %s', v2Dir);
end

addpath(thisDir, '-begin');
addpath(v2Dir, '-end');
end
