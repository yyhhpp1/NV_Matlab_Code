function varargout = T1_SemiAuto_ParamInput_v2_1(varargin)
% T1_SEMIAUTO_PARAMINPUT_V2_1 MATLAB code for T1_SemiAuto_ParamInput_v2_1.fig
%      T1_SEMIAUTO_PARAMINPUT_V2_1, by itself, creates a new T1_SEMIAUTO_PARAMINPUT_V2_1 or raises the existing
%      singleton*.
%
%      H = T1_SEMIAUTO_PARAMINPUT_V2_1 returns the handle to a new T1_SEMIAUTO_PARAMINPUT_V2_1 or the handle to
%      the existing singleton*.
%
%      T1_SEMIAUTO_PARAMINPUT_V2_1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in T1_SEMIAUTO_PARAMINPUT_V2_1.M with the given input arguments.
%
%      T1_SEMIAUTO_PARAMINPUT_V2_1('Property','Value',...) creates a new T1_SEMIAUTO_PARAMINPUT_V2_1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before T1_SemiAuto_ParamInput_v2_1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to T1_SemiAuto_ParamInput_v2_1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help T1_SemiAuto_ParamInput_v2_1

% Last Modified by GUIDE v2.5 20-Feb-2026 16:21:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @T1_SemiAuto_ParamInput_v2_1_OpeningFcn, ...
                   'gui_OutputFcn',  @T1_SemiAuto_ParamInput_v2_1_OutputFcn, ...
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


% --- Executes just before T1_SemiAuto_ParamInput_v2_1 is made visible.
function T1_SemiAuto_ParamInput_v2_1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to T1_SemiAuto_ParamInput_v2_1 (see VARARGIN)

% Choose default command line output for T1_SemiAuto_ParamInput_v2_1
handles.output = hObject;
set(hObject, 'CloseRequestFcn', ...
    @(src, evt) T1_SemiAuto_ParamInput_v2_1_CloseRequestFcn(src, evt, guidata(src)));

% Parent GUI handles from Experimental_PB_DAQ.
if length(varargin) >= 1
    handles.hFigA = varargin{1};
end
if length(varargin) >= 2
    handles.hObjectA = varargin{2};
end
if length(varargin) >= 3
    handles.eventdataA = varargin{3};
end

% Restore state from the last closed session.
statePath = get_v2_1_state_path();
if exist(statePath, 'file')
    loaded = load(statePath);
    if isfield(loaded, 'state') && isstruct(loaded.state)
        state = loaded.state;
        fields = fieldnames(state);
        for i = 1:length(fields)
            if isfield(handles, fields{i})
                h = handles.(fields{i});
                if isgraphics(h, 'uicontrol')
                    style = get(h, 'Style');
                    switch style
                        case {'edit', 'text'}
                            set(h, 'String', state.(fields{i}));
                        case {'checkbox', 'radiobutton', 'togglebutton', 'popupmenu', 'slider'}
                            set(h, 'Value', state.(fields{i}));
                    end
                end
            end
        end
    end
end

guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = T1_SemiAuto_ParamInput_v2_1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_startProg.
function pushbutton_startProg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_startProg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Reset stop flag before each run.
if isfield(handles, 'pushbutton_stopProg') && isgraphics(handles.pushbutton_stopProg, 'uicontrol')
    handles.pushbutton_stopProg.UserData = 0;
end

% Retrieve parent Experimental_PB_DAQ handles.
if ~isfield(handles, 'hFigA') || isempty(handles.hFigA) || ~ishandle(handles.hFigA)
    errordlg('Parent Experimental_PB_DAQ GUI handle is missing. Relaunch from the main GUI.', ...
        'SmartT1 v2.1');
    return;
end

hFigA = handles.hFigA;
handlesA = guidata(hFigA);

hObjectA = [];
eventdataA = [];
if isfield(handles, 'hObjectA')
    hObjectA = handles.hObjectA;
end
if isfield(handles, 'eventdataA')
    eventdataA = handles.eventdataA;
end

handlesB = handles;
t1_semi_auto_program(hObjectA, eventdataA, handlesA, handlesB);


% --- Executes on button press in pushbutton_stopProg.
function pushbutton_stopProg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stopProg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gmSEQ
handles.pushbutton_stopProg.UserData = 1;
try
    gmSEQ.bGo = 0;
    gmSEQ.bGoAfterAvg = 0;
    gmSEQ.bExp = 0;
catch
end



function edit_rabi_power_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rabi_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rabi_power as text
%        str2double(get(hObject,'String')) returns contents of edit_rabi_power as a double


% --- Executes during object creation, after setting all properties.
function edit_rabi_power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rabi_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_rabi_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_rabi_average as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_rabi_average as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_rabi_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_rabi_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_rabi_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_rabi_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_rabi_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_rabi_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_rabi_start as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_rabi_start as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_rabi_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_rabi_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_rabi_stop as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_rabi_stop as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_rabi_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_rabi_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_rabi_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_rabi_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_rabi_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_rabi_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_odmr_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_odmr_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_odmr_average as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_odmr_average as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_odmr_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_odmr_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_odmr_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_odmr_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_odmr_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_odmr_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_odmr_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_odmr_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_odmr_power_Callback(hObject, eventdata, handles)
% hObject    handle to edit_odmr_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_odmr_power as text
%        str2double(get(hObject,'String')) returns contents of edit_odmr_power as a double


% --- Executes during object creation, after setting all properties.
function edit_odmr_power_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_odmr_power (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_precal_odmr_points_per_mhz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_precal_odmr_points_per_mhz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_precal_odmr_points_per_mhz as text
%        str2double(get(hObject,'String')) returns contents of edit_precal_odmr_points_per_mhz as a double


% --- Executes during object creation, after setting all properties.
function edit_precal_odmr_points_per_mhz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_precal_odmr_points_per_mhz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_enable_rough_scan.
function chk_enable_rough_scan_Callback(hObject, eventdata, handles)
% hObject    handle to chk_enable_rough_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_enable_rough_scan



function edit_rough_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rough_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rough_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_rough_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_rough_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rough_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_rough_stop_policy.
function popup_rough_stop_policy_Callback(hObject, eventdata, handles)
% hObject    handle to popup_rough_stop_policy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_rough_stop_policy contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_rough_stop_policy


% --- Executes during object creation, after setting all properties.
function popup_rough_stop_policy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_rough_stop_policy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rough_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rough_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rough_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_rough_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_rough_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rough_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rough_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rough_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rough_average as text
%        str2double(get(hObject,'String')) returns contents of edit_rough_average as a double


% --- Executes during object creation, after setting all properties.
function edit_rough_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rough_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rough_fit_relerr_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rough_fit_relerr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rough_fit_relerr as text
%        str2double(get(hObject,'String')) returns contents of edit_rough_fit_relerr as a double


% --- Executes during object creation, after setting all properties.
function edit_rough_fit_relerr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rough_fit_relerr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rough_max_retries_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rough_max_retries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rough_max_retries as text
%        str2double(get(hObject,'String')) returns contents of edit_rough_max_retries as a double


% --- Executes during object creation, after setting all properties.
function edit_rough_max_retries_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rough_max_retries (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_estimated_B_G_Callback(hObject, eventdata, handles)
% hObject    handle to edit_estimated_B_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_estimated_B_G as text
%        str2double(get(hObject,'String')) returns contents of edit_estimated_B_G as a double


% --- Executes during object creation, after setting all properties.
function edit_estimated_B_G_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_estimated_B_G (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_smart_point_distribution.
function chk_smart_point_distribution_Callback(hObject, eventdata, handles)
% hObject    handle to chk_smart_point_distribution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_smart_point_distribution


% --- Executes on button press in chk_off_sq_m1.
function chk_off_sq_m1_Callback(hObject, eventdata, handles)
% hObject    handle to chk_off_sq_m1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_off_sq_m1


% --- Executes on button press in chk_off_sq_p1.
function chk_off_sq_p1_Callback(hObject, eventdata, handles)
% hObject    handle to chk_off_sq_p1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_off_sq_p1


% --- Executes on button press in chk_off_dq.
function chk_off_dq_Callback(hObject, eventdata, handles)
% hObject    handle to chk_off_dq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_off_dq



function edit_off_sq_m1_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_m1_start as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_m1_start as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_m1_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_m1_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_m1_stop as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_m1_stop as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_m1_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_m1_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_m1_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_m1_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_m1_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_m1_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_m1_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_m1_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_m1_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_m1_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_m1_average as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_m1_average as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_m1_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_m1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_p1_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_p1_start as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_p1_start as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_p1_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_p1_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_p1_stop as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_p1_stop as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_p1_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_p1_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_p1_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_p1_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_p1_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_p1_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_p1_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_p1_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_p1_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_sq_p1_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_sq_p1_average as text
%        str2double(get(hObject,'String')) returns contents of edit_off_sq_p1_average as a double


% --- Executes during object creation, after setting all properties.
function edit_off_sq_p1_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_sq_p1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_dq_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_dq_start as text
%        str2double(get(hObject,'String')) returns contents of edit_off_dq_start as a double


% --- Executes during object creation, after setting all properties.
function edit_off_dq_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_dq_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_dq_stop as text
%        str2double(get(hObject,'String')) returns contents of edit_off_dq_stop as a double


% --- Executes during object creation, after setting all properties.
function edit_off_dq_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_dq_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_dq_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_off_dq_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_off_dq_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_dq_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_dq_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_off_dq_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_off_dq_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_off_dq_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_off_dq_average as text
%        str2double(get(hObject,'String')) returns contents of edit_off_dq_average as a double


% --- Executes during object creation, after setting all properties.
function edit_off_dq_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_off_dq_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chk_aligned_sq_m1.
function chk_aligned_sq_m1_Callback(hObject, eventdata, handles)
% hObject    handle to chk_aligned_sq_m1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_aligned_sq_m1


% --- Executes on button press in chk_aligned_sq_p1.
function chk_aligned_sq_p1_Callback(hObject, eventdata, handles)
% hObject    handle to chk_aligned_sq_p1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_aligned_sq_p1


% --- Executes on button press in chk_aligned_dq.
function chk_aligned_dq_Callback(hObject, eventdata, handles)
% hObject    handle to chk_aligned_dq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_aligned_dq



function edit_aligned_sq_m1_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_m1_start as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_m1_start as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_m1_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_m1_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_m1_stop as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_m1_stop as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_m1_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_m1_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_m1_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_m1_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_m1_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_m1_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_m1_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_m1_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_m1_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_m1_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_m1_average as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_m1_average as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_m1_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_m1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_p1_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_p1_start as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_p1_start as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_p1_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_p1_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_p1_stop as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_p1_stop as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_p1_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_p1_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_p1_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_p1_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_p1_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_p1_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_p1_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_p1_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_p1_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_sq_p1_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_sq_p1_average as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_sq_p1_average as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_sq_p1_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_sq_p1_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_dq_start_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_dq_start as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_dq_start as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_dq_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_dq_stop_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_dq_stop as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_dq_stop as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_dq_stop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_dq_npts_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_dq_npts as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_dq_npts as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_dq_npts_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_npts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_dq_repeat_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_dq_repeat as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_dq_repeat as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_dq_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_aligned_dq_average_Callback(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_aligned_dq_average as text
%        str2double(get(hObject,'String')) returns contents of edit_aligned_dq_average as a double


% --- Executes during object creation, after setting all properties.
function edit_aligned_dq_average_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_aligned_dq_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function savestate_v2_1(handles)
if nargin < 1 || isempty(handles) || ~isstruct(handles)
    return;
end

state = struct();
fields = fieldnames(handles);
for i = 1:length(fields)
    h = handles.(fields{i});
    if isgraphics(h, 'uicontrol')
        style = get(h, 'Style');
        switch style
            case {'edit', 'text'}
                state.(fields{i}) = get(h, 'String');
            case {'checkbox', 'radiobutton', 'togglebutton', 'popupmenu', 'slider'}
                state.(fields{i}) = get(h, 'Value');
        end
    end
end

save(get_v2_1_state_path(), 'state');


% --- Executes when user attempts to close T1_SemiAuto_ParamInput_v2_1.
function T1_SemiAuto_ParamInput_v2_1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to T1_SemiAuto_ParamInput_v2_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if nargin < 3 || isempty(handles) || ~isstruct(handles)
    handles = guidata(hObject);
end

try
    savestate_v2_1(handles);
catch ME
    warning('T1_SemiAuto_ParamInput_v2_1:SaveStateFailed', ...
        'Failed to save GUI state on close: %s', ME.message);
end

delete(hObject);

function p = get_v2_1_state_path()
thisDir = fileparts(mfilename('fullpath'));
p = fullfile(thisDir, 'T1_SemiAuto_ParamInput_v2_1_state.mat');


% --- Executes on button press in chk_enable_precal.
function chk_enable_precal_Callback(hObject, eventdata, handles)
% hObject    handle to chk_enable_precal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chk_enable_precal



function edit47_Callback(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit47 as text
%        str2double(get(hObject,'String')) returns contents of edit47 as a double


% --- Executes during object creation, after setting all properties.
function edit47_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit47 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
