function out = run_b_queue_minimal(targetBkGList, runtimeCtx)
%RUN_B_QUEUE_MINIMAL Minimal v3.1 wrapper: run only B-field queue with v2.1.
%   out = v3_1.run_b_queue_minimal(targetBkGList, runtimeCtx)
%
% Inputs
%   targetBkGList : numeric vector of B targets in kG.
%   runtimeCtx    : struct
%       .hFigAuto       handle to T1_SemiAuto_ParamInput_v2_1 figure (required)
%       .hFigMain       optional handle to parent main GUI
%       .mode           final magnet mode: 'driven' or 'persistent' (default 'driven')
%       .magnetCfg      cfg passed to set_z_magnet_mode (default struct())
%       .bEstimateScale B_estimate [G] = targetBkG * scale (default 1000)
%       .writeStartLog  write v2.1 start log CSV (default true)
%       .startLogPath   explicit CSV path (default empty => auto name)
%       .writeAnalysisSnippet write queue analysis snippet TXT (default true)
%       .analysisSnippetPath  explicit snippet TXT path (default empty => auto name)
%       .stopAppDataKey stop latch key (default 'BT_CONTROL_STOP_B_QUEUE')
%       .verbose        default true
%
% Output
%   out: output struct from run_b_field_queue_v2_1.

if nargin < 2 || isempty(runtimeCtx)
    runtimeCtx = struct();
end
runtimeCtx = apply_defaults(runtimeCtx);

ensure_bt_control_on_path();

cfg = struct();
cfg.hFigAuto = runtimeCtx.hFigAuto;
cfg.hFigMain = runtimeCtx.hFigMain;
cfg.mode = runtimeCtx.mode;
cfg.magnetCfg = runtimeCtx.magnetCfg;
cfg.bEstimateScale = runtimeCtx.bEstimateScale;
cfg.resetStopLatch = true;
cfg.stopAppDataKey = runtimeCtx.stopAppDataKey;
cfg.writeStartLog = runtimeCtx.writeStartLog;
cfg.startLogPath = runtimeCtx.startLogPath;
cfg.writeAnalysisSnippet = runtimeCtx.writeAnalysisSnippet;
cfg.analysisSnippetPath = runtimeCtx.analysisSnippetPath;
cfg.verbose = runtimeCtx.verbose;

out = run_b_field_queue_v2_1(targetBkGList, cfg);
end

function runtimeCtx = apply_defaults(runtimeCtx)
runtimeCtx = set_default(runtimeCtx, 'hFigAuto', []);
runtimeCtx = set_default(runtimeCtx, 'hFigMain', []);
runtimeCtx = set_default(runtimeCtx, 'mode', 'driven');
runtimeCtx = set_default(runtimeCtx, 'magnetCfg', struct());
runtimeCtx = set_default(runtimeCtx, 'bEstimateScale', 1000);
runtimeCtx = set_default(runtimeCtx, 'writeStartLog', true);
runtimeCtx = set_default(runtimeCtx, 'startLogPath', '');
runtimeCtx = set_default(runtimeCtx, 'writeAnalysisSnippet', true);
runtimeCtx = set_default(runtimeCtx, 'analysisSnippetPath', '');
runtimeCtx = set_default(runtimeCtx, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE');
runtimeCtx = set_default(runtimeCtx, 'verbose', true);
end

function s = set_default(s, key, value)
if ~isfield(s, key) || isempty(s.(key))
    s.(key) = value;
end
end

function ensure_bt_control_on_path()
thisFile = mfilename('fullpath');
thisDir = fileparts(thisFile);               % ...\AutoRunSequences_v3_1\+v3_1
rootDir = fileparts(thisDir);                % ...\AutoRunSequences_v3_1
btDir = fullfile(rootDir, 'BT_Control');

if exist('run_b_field_queue_v2_1', 'file') ~= 2
    if isfolder(btDir)
        addpath(btDir);
    end
end

if exist('run_b_field_queue_v2_1', 'file') ~= 2
    error('SmartT1:v3_1:BTControlMissing', ...
        'Cannot find run_b_field_queue_v2_1.m. Expected under %s', btDir);
end
end
