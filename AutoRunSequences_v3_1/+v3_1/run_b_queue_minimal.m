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
%       .writeNotionSequenceLog write per-sequence notion events (default false)
%       .notionSpoolPath   JSONL spool path for external uploader
%       .notionQueueLogPath CSV queue log path
%       .notionPageKey     optional notion page key included in events
%       .runRoot           optional run root for context
%       .tbStepIndex       optional TB step index for context
%       .tSetK             optional temperature for context
%       .stopAppDataKey stop latch key (default 'BT_CONTROL_STOP_B_QUEUE')
%       .verbose        default true
%
% Output
%   out: output struct from run_b_field_queue_v2_1.

if nargin < 2 || isempty(runtimeCtx)
    runtimeCtx = struct();
end
ensure_bt_control_on_path();
runtimeCtx = apply_defaults(runtimeCtx);

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
cfg.writeNotionSequenceLog = runtimeCtx.writeNotionSequenceLog;
cfg.notionSpoolPath = runtimeCtx.notionSpoolPath;
cfg.notionQueueLogPath = runtimeCtx.notionQueueLogPath;
cfg.notionPageKey = runtimeCtx.notionPageKey;
cfg.runRoot = runtimeCtx.runRoot;
cfg.tbStepIndex = runtimeCtx.tbStepIndex;
cfg.tSetK = runtimeCtx.tSetK;
cfg.verbose = runtimeCtx.verbose;

out = run_b_field_queue_v2_1(targetBkGList, cfg);
end

function runtimeCtx = apply_defaults(runtimeCtx)
fileCfg = bt_control_cfg_load('run_b_field_queue_v2_1');
runtimeCtx = set_default(runtimeCtx, 'hFigAuto', cfg_file_value(fileCfg, 'hFigAuto', []));
runtimeCtx = set_default(runtimeCtx, 'hFigMain', cfg_file_value(fileCfg, 'hFigMain', []));
runtimeCtx = set_default(runtimeCtx, 'mode', cfg_file_value(fileCfg, 'mode', 'driven'));
runtimeCtx = set_default(runtimeCtx, 'magnetCfg', cfg_file_value(fileCfg, 'magnetCfg', struct()));
runtimeCtx = set_default(runtimeCtx, 'bEstimateScale', cfg_file_value(fileCfg, 'bEstimateScale', 1000));
runtimeCtx = set_default(runtimeCtx, 'writeStartLog', cfg_file_value(fileCfg, 'writeStartLog', true));
runtimeCtx = set_default(runtimeCtx, 'startLogPath', cfg_file_value(fileCfg, 'startLogPath', ''));
runtimeCtx = set_default(runtimeCtx, 'writeAnalysisSnippet', cfg_file_value(fileCfg, 'writeAnalysisSnippet', true));
runtimeCtx = set_default(runtimeCtx, 'analysisSnippetPath', cfg_file_value(fileCfg, 'analysisSnippetPath', ''));
runtimeCtx = set_default(runtimeCtx, 'writeNotionSequenceLog', cfg_file_value(fileCfg, 'writeNotionSequenceLog', false));
runtimeCtx = set_default(runtimeCtx, 'notionSpoolPath', cfg_file_value(fileCfg, 'notionSpoolPath', ''));
runtimeCtx = set_default(runtimeCtx, 'notionQueueLogPath', cfg_file_value(fileCfg, 'notionQueueLogPath', ''));
runtimeCtx = set_default(runtimeCtx, 'notionPageKey', cfg_file_value(fileCfg, 'notionPageKey', ''));
runtimeCtx = set_default(runtimeCtx, 'runRoot', cfg_file_value(fileCfg, 'runRoot', ''));
runtimeCtx = set_default(runtimeCtx, 'tbStepIndex', cfg_file_value(fileCfg, 'tbStepIndex', NaN));
runtimeCtx = set_default(runtimeCtx, 'tSetK', cfg_file_value(fileCfg, 'tSetK', NaN));
runtimeCtx = set_default(runtimeCtx, 'stopAppDataKey', cfg_file_value(fileCfg, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE'));
runtimeCtx = set_default(runtimeCtx, 'verbose', cfg_file_value(fileCfg, 'verbose', true));
end

function s = set_default(s, key, value)
if ~isfield(s, key) || isempty(s.(key))
    s.(key) = value;
end
end

function v = cfg_file_value(s, key, fallback)
if isstruct(s) && isfield(s, key) && ~isempty(s.(key))
    v = s.(key);
else
    v = fallback;
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
