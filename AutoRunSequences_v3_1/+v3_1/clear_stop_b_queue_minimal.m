function clear_stop_b_queue_minimal(runtimeCtx)
%CLEAR_STOP_B_QUEUE_MINIMAL Clear stop latch for v3_1.run_b_queue_minimal.
%   v3_1.clear_stop_b_queue_minimal()
%   v3_1.clear_stop_b_queue_minimal(runtimeCtx)
%
% runtimeCtx fields:
%   .hFigAuto
%   .stopAppDataKey
%   .verbose

if nargin < 1 || isempty(runtimeCtx)
    runtimeCtx = struct();
end
runtimeCtx = apply_defaults(runtimeCtx);

ensure_bt_control_on_path();

cfg = struct();
cfg.hFigAuto = runtimeCtx.hFigAuto;
cfg.stopAppDataKey = runtimeCtx.stopAppDataKey;
cfg.verbose = runtimeCtx.verbose;
clear_stop_b_field_queue(cfg);
end

function runtimeCtx = apply_defaults(runtimeCtx)
runtimeCtx = set_default(runtimeCtx, 'hFigAuto', []);
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
thisDir = fileparts(thisFile);
rootDir = fileparts(thisDir);
btDir = fullfile(rootDir, 'BT_Control');

if exist('clear_stop_b_field_queue', 'file') ~= 2
    if isfolder(btDir)
        addpath(btDir);
    end
end

if exist('clear_stop_b_field_queue', 'file') ~= 2
    error('SmartT1:v3_1:BTControlMissing', ...
        'Cannot find clear_stop_b_field_queue.m. Expected under %s', btDir);
end
end
