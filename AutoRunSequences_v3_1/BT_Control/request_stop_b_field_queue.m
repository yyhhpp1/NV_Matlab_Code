function request_stop_b_field_queue(cfg)
%REQUEST_STOP_B_FIELD_QUEUE Request stop for run_b_field_queue_v2_1.
%   request_stop_b_field_queue()
%   request_stop_b_field_queue(cfg)
%
% Optional cfg fields:
%   .stopAppDataKey  (default 'BT_CONTROL_STOP_B_QUEUE')
%   .hFigAuto        (optional v2.1 auto GUI handle for immediate stop forwarding)
%   .verbose         (default true)

if nargin < 1 || isempty(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

setappdata(0, cfg.stopAppDataKey, true);

if ~isempty(cfg.hFigAuto) && (ishandle(cfg.hFigAuto) || isgraphics(cfg.hFigAuto))
    try
        hAuto = guidata(cfg.hFigAuto);
        if isstruct(hAuto) && isfield(hAuto, 'pushbutton_stopProg') && isgraphics(hAuto.pushbutton_stopProg, 'uicontrol')
            set(hAuto.pushbutton_stopProg, 'UserData', 1);
        end
    catch
    end
end

global gmSEQ
try
    gmSEQ.bGo = 0;
    gmSEQ.bGoAfterAvg = 0;
    gmSEQ.bExp = 0;
catch
end

if cfg.verbose
    fprintf('[request_stop_b_field_queue] Stop requested.\n');
end
end

function cfg = apply_defaults(cfg)
cfg = set_default(cfg, 'stopAppDataKey', 'BT_CONTROL_STOP_B_QUEUE');
cfg = set_default(cfg, 'hFigAuto', []);
cfg = set_default(cfg, 'verbose', true);
end

function cfg = set_default(cfg, key, val)
if ~isfield(cfg, key) || isempty(cfg.(key))
    cfg.(key) = val;
end
end
