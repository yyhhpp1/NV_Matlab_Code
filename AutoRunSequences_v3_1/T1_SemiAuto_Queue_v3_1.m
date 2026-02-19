function varargout = T1_SemiAuto_Queue_v3_1(varargin)
% T1_SEMIAUTO_QUEUE_V3_1 MATLAB code for T1_SemiAuto_Queue_v3_1.fig
%      T1_SEMIAUTO_QUEUE_V3_1, by itself, creates a new T1_SEMIAUTO_QUEUE_V3_1 or raises the existing
%      singleton*.
%
%      H = T1_SEMIAUTO_QUEUE_V3_1 returns the handle to a new T1_SEMIAUTO_QUEUE_V3_1 or the handle to
%      the existing singleton*.
%
%      T1_SEMIAUTO_QUEUE_V3_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in T1_SEMIAUTO_QUEUE_V3_1.M with the given input arguments.
%
%      T1_SEMIAUTO_QUEUE_V3_1('Property','Value',...) creates a new T1_SEMIAUTO_QUEUE_V3_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before T1_SemiAuto_Queue_v3_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to T1_SemiAuto_Queue_v3_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Last Modified by GUIDE v2.5 17-Feb-2026 17:07:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @T1_SemiAuto_Queue_v3_1_OpeningFcn, ...
                   'gui_OutputFcn',  @T1_SemiAuto_Queue_v3_1_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before T1_SemiAuto_Queue_v3_1 is made visible.
function T1_SemiAuto_Queue_v3_1_OpeningFcn(hObject, eventdata, handles, varargin)
thisDir = fileparts(mfilename('fullpath'));
addpath(thisDir, '-begin');

handles.output = hObject;
handles.session = v3_1.queue_gui_util('init_session', varargin{:});
if isfield(handles.session, 'saveRoot') && ~isempty(handles.session.saveRoot)
    handles.campaign = v3_1.new_campaign('saveRoot', handles.session.saveRoot);
else
    handles.campaign = v3_1.new_campaign();
end
handles.rowToJobIdx = [];
handles.selectedRow = 1;
handles.isBusy = false;

handles = v3_1.queue_gui_util('refresh_ui', handles);
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Idle');
v3_1.queue_gui_util('set_current_job_text', handles, 'No job selected.');

guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = T1_SemiAuto_Queue_v3_1_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes when entered data in editable cell(s) in table_queue_jobs.
function table_queue_jobs_CellEditCallback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles) || ~isfield(handles, 'campaign') || isempty(eventdata.Indices)
    return;
end

row = eventdata.Indices(1);
col = eventdata.Indices(2);
jobIdx = v3_1.queue_gui_util('map_row_to_job_index', handles, row);
if jobIdx == 0
    handles = v3_1.queue_gui_util('refresh_ui', handles);
    guidata(hObject, handles);
    return;
end

job = handles.campaign.jobs(jobIdx);
switch col
    case 1
        job.enabled = logical(eventdata.NewData);
        handles.campaign.jobs(jobIdx) = job;
    case 2
        newOrder = v3_1.queue_gui_util('to_number', eventdata.NewData, job.order);
        if handles.campaign.isRunning && ~strcmpi(job.status.state, 'pending')
            warndlg('Only pending jobs can be reordered while running.', 'v3.1 Queue');
        else
            handles.campaign.jobs(jobIdx).order = newOrder;
            handles.campaign = v3_1.queue_gui_util('apply_order_rules', handles.campaign);
        end
    case 3
        job.name = char(eventdata.NewData);
        handles.campaign.jobs(jobIdx) = job;
    case 4
        job.setpoint.B = v3_1.queue_gui_util('to_number', eventdata.NewData, job.setpoint.B);
        handles.campaign.jobs(jobIdx) = job;
    case 5
        job.setpoint.T = v3_1.queue_gui_util('to_number', eventdata.NewData, job.setpoint.T);
        handles.campaign.jobs(jobIdx) = job;
    case 6
        job.profile.name = char(eventdata.NewData);
        handles.campaign.jobs(jobIdx) = job;
    otherwise
end

handles.campaign.lastSavedAt = v3_1.queue_gui_util('now_stamp');
handles = v3_1.queue_gui_util('refresh_ui', handles);
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in table_queue_jobs.
function table_queue_jobs_CellSelectionCallback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles) || ~isfield(handles, 'campaign') || isempty(eventdata.Indices)
    return;
end

handles.selectedRow = eventdata.Indices(1, 1);
msg = v3_1.queue_gui_util('current_job_text_from_selection', handles);
v3_1.queue_gui_util('set_current_job_text', handles, msg);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_add_job.
function pushbutton_add_job_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles)
    return;
end

n = numel(handles.campaign.jobs) + 1;
job = v3_1.new_job('name', sprintf('Job_%03d', n));
handles.campaign = v3_1.add_job(handles.campaign, job);
handles.selectedRow = n;

handles = v3_1.queue_gui_util('refresh_ui', handles);
msg = v3_1.queue_gui_util('current_job_text_from_selection', handles);
v3_1.queue_gui_util('set_current_job_text', handles, msg);
guidata(hObject, handles);


function edit1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_clone_job.
function pushbutton_clone_job_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
jobIdx = v3_1.queue_gui_util('get_selected_job_index', handles);
if jobIdx == 0
    return;
end

src = handles.campaign.jobs(jobIdx);
clone = src;
clone.id = sprintf('job_%s_%04d', datestr(now, 'yyyymmdd_HHMMSS'), randi([0, 9999]));
clone.name = [src.name '_copy'];
clone.order = max([handles.campaign.jobs.order]) + 1;
clone.status.state = 'pending';
clone.status.attemptCount = 0;
clone.status.userDeclaredFailed = false;
clone.status.userFailAction = 'none';
clone.status.lastResult = '';
clone.status.lastTimestamp = '';
clone.history = repmat(clone.history, 0, 1);

handles.campaign = v3_1.add_job(handles.campaign, clone);
handles = v3_1.queue_gui_util('refresh_ui', handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_delete_job.
function pushbutton_delete_job_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
jobIdx = v3_1.queue_gui_util('get_selected_job_index', handles);
if jobIdx == 0
    return;
end

handles.campaign.jobs(jobIdx) = [];
handles.campaign = v3_1.queue_gui_util('apply_order_rules', handles.campaign);
handles.selectedRow = max(1, min(handles.selectedRow, numel(handles.campaign.jobs)));
handles = v3_1.queue_gui_util('refresh_ui', handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_move_up.
function pushbutton_move_up_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
jobIdx = v3_1.queue_gui_util('get_selected_job_index', handles);
if jobIdx == 0
    return;
end

if handles.campaign.isRunning && ~strcmpi(handles.campaign.jobs(jobIdx).status.state, 'pending')
    warndlg('Only pending jobs can be reordered while running.', 'v3.1 Queue');
    return;
end

order = handles.campaign.jobs(jobIdx).order;
neighbor = find([handles.campaign.jobs.order] < order, 1, 'last');
if isempty(neighbor)
    return;
end

swapOrder = handles.campaign.jobs(neighbor).order;
handles.campaign.jobs(neighbor).order = order;
handles.campaign.jobs(jobIdx).order = swapOrder;
handles.campaign = v3_1.queue_gui_util('apply_order_rules', handles.campaign);
handles = v3_1.queue_gui_util('refresh_ui', handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_move_down.
function pushbutton_move_down_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
jobIdx = v3_1.queue_gui_util('get_selected_job_index', handles);
if jobIdx == 0
    return;
end

if handles.campaign.isRunning && ~strcmpi(handles.campaign.jobs(jobIdx).status.state, 'pending')
    warndlg('Only pending jobs can be reordered while running.', 'v3.1 Queue');
    return;
end

order = handles.campaign.jobs(jobIdx).order;
neighbor = find([handles.campaign.jobs.order] > order, 1, 'first');
if isempty(neighbor)
    return;
end

swapOrder = handles.campaign.jobs(neighbor).order;
handles.campaign.jobs(neighbor).order = order;
handles.campaign.jobs(jobIdx).order = swapOrder;
handles.campaign = v3_1.queue_gui_util('apply_order_rules', handles.campaign);
handles = v3_1.queue_gui_util('refresh_ui', handles);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_capture_v2_profile.
function pushbutton_capture_v2_profile_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
jobIdx = v3_1.queue_gui_util('get_selected_job_index', handles);
if jobIdx == 0
    warndlg('Select a queue job first.', 'v3.1 Queue');
    return;
end

[okCtx, v2ctx, msg] = v3_1.queue_gui_util('locate_v2_context', handles);
if ~okCtx
    errordlg(msg, 'v3.1 Queue');
    return;
end

job = handles.campaign.jobs(jobIdx);
profileName = sprintf('cfg_%s', datestr(now, 'HHMMSS'));
handles.campaign = v3_1.set_job_profile_from_handles(handles.campaign, job.id, v2ctx.handlesAuto, profileName);

handles = v3_1.queue_gui_util('refresh_ui', handles);
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Profile captured.');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_run_enabled.
function pushbutton_run_enabled_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles) || handles.isBusy
    return;
end
if isempty(handles.campaign.jobs)
    warndlg('Queue is empty.', 'v3.1 Queue');
    return;
end

hasEnabledPending = any(arrayfun(@(j) j.enabled && strcmpi(j.status.state, 'pending'), handles.campaign.jobs));
if ~hasEnabledPending
    warndlg('No enabled pending jobs to run.', 'v3.1 Queue');
    return;
end

handles.isBusy = true;
handles.campaign.runtimeControl.stopMode = 'none';
handles.campaign.runtimeControl.currentJobAction = 'none';
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Running...');
guidata(hObject, handles);
drawnow;

runtimeCtx = v3_1.queue_gui_util('build_runtime_ctx', handles, hObject);
if ~runtimeCtx.executeV21
    v3_1.queue_gui_util('set_runtime_state_text', handles, 'Running (dry-run: no v2.1 context)...');
    drawnow;
end

[campaignOut, report] = v3_1.run_campaign(handles.campaign, runtimeCtx);

handles = guidata(hObject);
if isempty(handles)
    return;
end
handles.campaign = campaignOut;
handles.isBusy = false;
handles = v3_1.queue_gui_util('refresh_ui', handles);

if isfield(report, 'finalState') && strcmpi(report.finalState, 'finished')
    v3_1.queue_gui_util('set_runtime_state_text', handles, 'Finished.');
else
    v3_1.queue_gui_util('set_runtime_state_text', handles, 'Stopped.');
end
msg = v3_1.queue_gui_util('current_job_text_from_selection', handles);
v3_1.queue_gui_util('set_current_job_text', handles, msg);
guidata(hObject, handles);


% --- Executes on button press in pushbutton_run_selected.
function pushbutton_run_selected_Callback(hObject, eventdata, handles)
warndlg('Run Selected is not part of the MVP wiring yet.', 'v3.1 Queue');


% --- Executes on button press in pushbutton_resume_queue.
function pushbutton_resume_queue_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles)
    return;
end
if isempty(handles.campaign.queueStatePath) || ~isfile(handles.campaign.queueStatePath)
    warndlg('No queue_state.mat found for resume.', 'v3.1 Queue');
    return;
end

handles.campaign = v3_1.load_campaign_state(handles.campaign.queueStatePath);
handles = v3_1.queue_gui_util('refresh_ui', handles);
v3_1.queue_gui_util('set_runtime_state_text', handles, 'State loaded. Press Run Enabled to continue.');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_stop_queue.
function pushbutton_stop_queue_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles)
    return;
end

handles.campaign = v3_1.request_stop_queue(handles.campaign, 'User requested Stop Queue.');
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Stop Queue requested...');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_stop_all.
function pushbutton_stop_all_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles)
    return;
end

[okCtx, v2ctx, ~] = v3_1.queue_gui_util('locate_v2_context', handles);
if okCtx
    handles.campaign = v3_1.request_stop_all(handles.campaign, v2ctx.handlesAuto, 'User requested Stop All.');
else
    handles.campaign = v3_1.request_stop_all(handles.campaign, struct(), 'User requested Stop All.');
end
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Stop All requested...');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_mark_failed_skip.
function pushbutton_mark_failed_skip_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles)
    return;
end

handles.campaign = v3_1.request_current_job_action(handles.campaign, 'mark_failed_skip');
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Current job marked failed -> skip (latched).');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_mark_failed_redo.
function pushbutton_mark_failed_redo_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles)
    return;
end

handles.campaign = v3_1.request_current_job_action(handles.campaign, 'mark_failed_redo');
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Current job marked failed -> redo (latched).');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_redo_selected.
function pushbutton_redo_selected_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
jobIdx = v3_1.queue_gui_util('get_selected_job_index', handles);
if jobIdx == 0
    return;
end

handles.campaign.jobs(jobIdx).status.state = 'pending';
handles.campaign.jobs(jobIdx).enabled = true;
handles.campaign.jobs(jobIdx).order = max([handles.campaign.jobs.order]) + 1;
handles.campaign = v3_1.queue_gui_util('apply_order_rules', handles.campaign);
handles = v3_1.queue_gui_util('refresh_ui', handles);
v3_1.queue_gui_util('set_runtime_state_text', handles, 'Selected job scheduled for redo.');
guidata(hObject, handles);


% --- Executes on button press in pushbutton_redo_failed.
function pushbutton_redo_failed_Callback(hObject, eventdata, handles)
handles = guidata(hObject);
if isempty(handles) || isempty(handles.campaign.jobs)
    return;
end

maxOrder = max([handles.campaign.jobs.order]);
for i = 1:numel(handles.campaign.jobs)
    if strcmpi(handles.campaign.jobs(i).status.state, 'failed')
        maxOrder = maxOrder + 1;
        handles.campaign.jobs(i).status.state = 'pending';
        handles.campaign.jobs(i).enabled = true;
        handles.campaign.jobs(i).order = maxOrder;
    end
end
handles.campaign = v3_1.queue_gui_util('apply_order_rules', handles.campaign);
handles = v3_1.queue_gui_util('refresh_ui', handles);
v3_1.queue_gui_util('set_runtime_state_text', handles, 'All failed jobs scheduled for redo.');
guidata(hObject, handles);
