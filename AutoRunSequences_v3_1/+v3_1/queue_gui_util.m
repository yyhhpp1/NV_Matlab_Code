function varargout = queue_gui_util(action, varargin)
%QUEUE_GUI_UTIL Utility dispatcher for v3.1 GUIDE queue GUI.

switch lower(char(action))
    case 'init_session'
        [varargout{1:nargout}] = init_session(varargin{:});
    case 'refresh_ui'
        [varargout{1:nargout}] = refresh_ui(varargin{:});
    case 'campaign_to_table'
        [varargout{1:nargout}] = campaign_to_table(varargin{:});
    case 'map_row_to_job_index'
        [varargout{1:nargout}] = map_row_to_job_index(varargin{:});
    case 'get_selected_job_index'
        [varargout{1:nargout}] = get_selected_job_index(varargin{:});
    case 'current_job_text_from_selection'
        [varargout{1:nargout}] = current_job_text_from_selection(varargin{:});
    case 'set_runtime_state_text'
        [varargout{1:nargout}] = set_runtime_state_text(varargin{:});
    case 'set_current_job_text'
        [varargout{1:nargout}] = set_current_job_text(varargin{:});
    case 'apply_order_rules'
        [varargout{1:nargout}] = apply_order_rules(varargin{:});
    case 'locate_v2_context'
        [varargout{1:nargout}] = locate_v2_context(varargin{:});
    case 'build_runtime_ctx'
        [varargout{1:nargout}] = build_runtime_ctx(varargin{:});
    case 'pull_campaign_from_gui'
        [varargout{1:nargout}] = pull_campaign_from_gui(varargin{:});
    case 'push_campaign_to_gui'
        [varargout{1:nargout}] = push_campaign_to_gui(varargin{:});
    case 'to_number'
        [varargout{1:nargout}] = to_number(varargin{:});
    case 'now_stamp'
        [varargout{1:nargout}] = now_stamp();
    otherwise
        error('SmartT1:v3_1:GuiUtilAction', 'Unknown queue_gui_util action: %s', char(action));
end
end


function session = init_session(varargin)
session = struct();
session.handlesAuto = struct();
session.handlesMain = struct();
session.hObjectA = [];
session.eventdataA = [];
session.saveRoot = '';

if nargin >= 4 && isstruct(varargin{3}) && isstruct(varargin{4})
    session.hObjectA = varargin{1};
    session.eventdataA = varargin{2};
    session.handlesMain = varargin{3};
    session.handlesAuto = varargin{4};
    return;
end

if nargin == 1 && isstruct(varargin{1})
    s = varargin{1};
    if is_valid_auto_handles(s)
        session.handlesAuto = s;
        if isfield(s, 'hFigA') && ishandle(s.hFigA)
            session.handlesMain = guidata(s.hFigA);
        end
    else
        session = merge_struct(session, s);
    end
    return;
end

if mod(numel(varargin), 2) == 0
    for i = 1:2:numel(varargin)
        key = varargin{i};
        value = varargin{i + 1};
        if ~(ischar(key) || isstring(key))
            continue;
        end
        k = lower(char(key));
        switch k
            case 'handlesauto'
                session.handlesAuto = value;
            case 'handlesmain'
                session.handlesMain = value;
            case 'hobjecta'
                session.hObjectA = value;
            case 'eventdataa'
                session.eventdataA = value;
            case 'saveroot'
                session.saveRoot = char(value);
            otherwise
                session.(char(key)) = value;
        end
    end
end
end


function handles = refresh_ui(handles)
if ~isfield(handles, 'campaign')
    return;
end

[data, rowToJobIdx] = campaign_to_table(handles.campaign);
handles.rowToJobIdx = rowToJobIdx;

if isfield(handles, 'table_queue_jobs') && isgraphics(handles.table_queue_jobs, 'uitable')
    set(handles.table_queue_jobs, ...
        'ColumnName', {'Enable','Order','JobName','B_set','T_set','ProfileName','Status','Attempts','LastResult','LastTimestamp'}, ...
        'ColumnEditable', [true true true true true true false false false false], ...
        'Data', data);
end

if isempty(data)
    handles.selectedRow = 1;
else
    handles.selectedRow = max(1, min(handles.selectedRow, size(data, 1)));
end

if handles.campaign.isRunning
    if strcmpi(handles.campaign.runtimeControl.stopMode, 'none')
        set_runtime_state_text(handles, 'Running...');
    else
        set_runtime_state_text(handles, ['Running (' handles.campaign.runtimeControl.stopMode ')...']);
    end
else
    if strcmpi(handles.campaign.runtimeControl.stopMode, 'none')
        set_runtime_state_text(handles, 'Idle');
    else
        set_runtime_state_text(handles, ['Stopped (' handles.campaign.runtimeControl.stopMode ')']);
    end
end

if isfield(handles, 'text_current_job') && isgraphics(handles.text_current_job)
    set_current_job_text(handles, current_job_text_from_selection(handles));
end
end


function [data, rowToJobIdx] = campaign_to_table(campaign)
if ~isfield(campaign, 'jobs') || isempty(campaign.jobs)
    data = cell(0, 10);
    rowToJobIdx = [];
    return;
end

jobs = campaign.jobs;
orders = arrayfun(@(j) j.order, jobs);
[~, sortIdx] = sortrows([(1:numel(jobs))', orders(:)], [2 1]);
rowToJobIdx = sortIdx(:)';

data = cell(numel(sortIdx), 10);
for r = 1:numel(sortIdx)
    j = jobs(sortIdx(r));
    data{r,1} = logical(j.enabled);
    data{r,2} = j.order;
    data{r,3} = j.name;
    data{r,4} = j.setpoint.B;
    data{r,5} = j.setpoint.T;
    data{r,6} = j.profile.name;
    data{r,7} = j.status.state;
    data{r,8} = j.status.attemptCount;
    data{r,9} = j.status.lastResult;
    data{r,10} = j.status.lastTimestamp;
end
end


function idx = map_row_to_job_index(handles, row)
idx = 0;
if ~isfield(handles, 'rowToJobIdx') || isempty(handles.rowToJobIdx)
    return;
end
if row < 1 || row > numel(handles.rowToJobIdx)
    return;
end
idx = handles.rowToJobIdx(row);
end


function idx = get_selected_job_index(handles)
idx = 0;
if ~isfield(handles, 'campaign') || ~isfield(handles.campaign, 'jobs') || isempty(handles.campaign.jobs)
    return;
end
row = 1;
if isfield(handles, 'selectedRow') && ~isempty(handles.selectedRow)
    row = handles.selectedRow;
end
idx = map_row_to_job_index(handles, row);
if idx == 0
    idx = 1;
end
end


function txt = current_job_text_from_selection(handles)
if ~isfield(handles, 'campaign') || isempty(handles.campaign.jobs)
    txt = 'No job selected.';
    return;
end

jobIdx = get_selected_job_index(handles);
if jobIdx == 0
    txt = 'No job selected.';
    return;
end

j = handles.campaign.jobs(jobIdx);
txt = sprintf('Selected: %s | B=%.6g | T=%.6g | status=%s', j.name, j.setpoint.B, j.setpoint.T, j.status.state);

if isfield(handles.campaign, 'currentJobId') && ~isempty(handles.campaign.currentJobId)
    if strcmp(handles.campaign.currentJobId, j.id)
        txt = [txt ' [RUNNING]'];
    end
end
end


function set_runtime_state_text(handles, txt)
if isfield(handles, 'text_runtime_state') && isgraphics(handles.text_runtime_state)
    set(handles.text_runtime_state, 'String', txt);
end
end


function set_current_job_text(handles, txt)
if isfield(handles, 'text_current_job') && isgraphics(handles.text_current_job)
    set(handles.text_current_job, 'String', txt);
end
end


function campaign = apply_order_rules(campaign)
jobs = campaign.jobs;
if isempty(jobs)
    return;
end

if campaign.isRunning
    pendingIdx = find(arrayfun(@(j) strcmpi(j.status.state, 'pending'), jobs));
    if isempty(pendingIdx)
        return;
    end

    pendingOrders = arrayfun(@(k) jobs(k).order, pendingIdx);
    [~, localOrd] = sortrows([(1:numel(pendingIdx))', pendingOrders(:)], [2 1]);
    orderedPendingIdx = pendingIdx(localOrd);
    orderedIds = arrayfun(@(k) jobs(k).id, orderedPendingIdx, 'UniformOutput', false);
    campaign = v3_1.reorder_pending_jobs(campaign, orderedIds);
else
    allOrders = arrayfun(@(j) j.order, jobs);
    [~, ord] = sortrows([(1:numel(jobs))', allOrders(:)], [2 1]);
    for i = 1:numel(ord)
        jobs(ord(i)).order = i;
    end
    campaign.jobs = jobs;
end

campaign.lastSavedAt = now_stamp();
end


function [ok, ctx, msg] = locate_v2_context(handles)
ok = false;
ctx = struct('handlesAuto', struct(), 'handlesMain', struct(), 'hObjectA', [], 'eventdataA', []);
msg = 'Could not locate an active v2.1 auto GUI context.';

if isfield(handles, 'session')
    s = handles.session;
    if isfield(s, 'handlesAuto') && is_valid_auto_handles(s.handlesAuto)
        ctx.handlesAuto = s.handlesAuto;
        if isfield(s, 'handlesMain') && isstruct(s.handlesMain)
            ctx.handlesMain = s.handlesMain;
        elseif isfield(s.handlesAuto, 'hFigA') && ishandle(s.handlesAuto.hFigA)
            ctx.handlesMain = guidata(s.handlesAuto.hFigA);
        end
        if isfield(s, 'hObjectA'), ctx.hObjectA = s.hObjectA; end
        if isfield(s, 'eventdataA'), ctx.eventdataA = s.eventdataA; end
        ok = true;
        msg = '';
        return;
    end
end

figs = findall(0, 'Type', 'figure');
for i = 1:numel(figs)
    try
        h = guidata(figs(i));
    catch
        h = [];
    end
    if ~is_valid_auto_handles(h)
        continue;
    end
    ctx.handlesAuto = h;
    if isfield(h, 'hFigA') && ishandle(h.hFigA)
        ctx.handlesMain = guidata(h.hFigA);
    else
        ctx.handlesMain = struct();
    end
    if isfield(h, 'hObjectA'), ctx.hObjectA = h.hObjectA; end
    if isfield(h, 'eventdataA'), ctx.eventdataA = h.eventdataA; end
    ok = true;
    msg = '';
    return;
end
end


function tf = is_valid_auto_handles(h)
tf = isstruct(h) && isfield(h, 'pushbutton_startProg') && isfield(h, 'pushbutton_stopProg');
end


function runtimeCtx = build_runtime_ctx(handles, hObject)
runtimeCtx = struct();
runtimeCtx.v2Runner = @t1_semi_auto_program_v3_1;
runtimeCtx.placeholder = struct('setDelaySec', 0.0, 'settleSec', 0.2);

[ok, ctx, ~] = locate_v2_context(handles);
runtimeCtx.executeV21 = ok;
if ok
    runtimeCtx.handlesAuto = ctx.handlesAuto;
    runtimeCtx.handlesMain = ctx.handlesMain;
    runtimeCtx.hObjectA = ctx.hObjectA;
    runtimeCtx.eventdataA = ctx.eventdataA;
else
    runtimeCtx.handlesAuto = struct();
    runtimeCtx.handlesMain = struct();
    runtimeCtx.hObjectA = [];
    runtimeCtx.eventdataA = [];
end

fig = ancestor(hObject, 'figure');
runtimeCtx.pullCampaignFcn = @() pull_campaign_from_gui(fig);
runtimeCtx.pushCampaignFcn = @(c) push_campaign_to_gui(fig, c);
end


function pulled = pull_campaign_from_gui(fig)
pulled = struct();
if ~ishandle(fig)
    return;
end
try
    h = guidata(fig);
catch
    h = [];
end
if isempty(h) || ~isstruct(h) || ~isfield(h, 'campaign')
    return;
end

pulled.runtimeControl = h.campaign.runtimeControl;
pulled.jobs = h.campaign.jobs;
end


function push_campaign_to_gui(fig, campaign)
if ~ishandle(fig)
    return;
end
try
    h = guidata(fig);
catch
    return;
end
if isempty(h) || ~isstruct(h)
    return;
end

h.campaign = campaign;
h = refresh_ui(h);
guidata(fig, h);
end


function out = merge_struct(base, extra)
out = base;
fields = fieldnames(extra);
for i = 1:numel(fields)
    out.(fields{i}) = extra.(fields{i});
end
end


function v = to_number(raw, fallback)
if isnumeric(raw)
    v = raw;
elseif ischar(raw) || isstring(raw)
    v = str2double(raw);
else
    v = NaN;
end
if ~isfinite(v)
    v = fallback;
end
end


function s = now_stamp()
s = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
end
