function request_stop_queue_minimal(runtimeCtx)
%REQUEST_STOP_QUEUE_MINIMAL Request stop for v3.2 minimal BT queue.
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
request_stop_b_field_queue(cfg);
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
repoRoot = fileparts(fileparts(thisDir));
btDir = fullfile(repoRoot, 'AutoRunSequences_v3_1', 'BT_Control');

if exist('request_stop_b_field_queue', 'file') ~= 2
    if isfolder(btDir)
        addpath(btDir);
    end
end

if exist('request_stop_b_field_queue', 'file') ~= 2
    error('SmartT1:v3_2:BTControlMissing', ...
        'Cannot find request_stop_b_field_queue.m. Expected under %s', btDir);
end
end
