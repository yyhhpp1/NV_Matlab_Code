function clear_stop_b_field_queue(cfg)
%CLEAR_STOP_B_FIELD_QUEUE Clear stop latch for run_b_field_queue_v2_1.
%   clear_stop_b_field_queue()
%   clear_stop_b_field_queue(cfg)
%
% Optional cfg fields:
%   .stopAppDataKey  (default 'BT_CONTROL_STOP_B_QUEUE')
%   .hFigAuto        (optional v2.1 auto GUI handle for clearing stop button flag)
%   .verbose         (default true)

if nargin < 1 || isempty(cfg)
    cfg = struct();
end
cfg = apply_defaults(cfg);

setappdata(0, cfg.stopAppDataKey, false);

if ~isempty(cfg.hFigAuto) && (ishandle(cfg.hFigAuto) || isgraphics(cfg.hFigAuto))
    try
        hAuto = guidata(cfg.hFigAuto);
        if isstruct(hAuto) && isfield(hAuto, 'pushbutton_stopProg') && isgraphics(hAuto.pushbutton_stopProg, 'uicontrol')
            set(hAuto.pushbutton_stopProg, 'UserData', 0);
        end
    catch
    end
end

if cfg.verbose
    fprintf('[clear_stop_b_field_queue] Stop latch cleared.\n');
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
