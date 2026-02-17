function varargout = T1_SemiAuto_ParamInput(varargin)
% T1_SEMIAUTO_PARAMINPUT MATLAB code for T1_SemiAuto_ParamInput.fig
%      T1_SEMIAUTO_PARAMINPUT, by itself, creates a new T1_SEMIAUTO_PARAMINPUT or raises the existing
%      singleton*.
%
%      H = T1_SEMIAUTO_PARAMINPUT returns the handle to a new T1_SEMIAUTO_PARAMINPUT or the handle to
%      the existing singleton*.
%
%      T1_SEMIAUTO_PARAMINPUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in T1_SEMIAUTO_PARAMINPUT.M with the given input arguments.
%
%      T1_SEMIAUTO_PARAMINPUT('Property','Value',...) creates a new T1_SEMIAUTO_PARAMINPUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before T1_SemiAuto_ParamInput_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to T1_SemiAuto_ParamInput_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help T1_SemiAuto_ParamInput

% Last Modified by GUIDE v2.5 14-Feb-2026 15:21:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @T1_SemiAuto_ParamInput_OpeningFcn, ...
                   'gui_OutputFcn',  @T1_SemiAuto_ParamInput_OutputFcn, ...
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


% --- Executes just before T1_SemiAuto_ParamInput is made visible.
function T1_SemiAuto_ParamInput_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to T1_SemiAuto_ParamInput (see VARARGIN)

% Choose default command line output for T1_SemiAuto_ParamInput
handles.output = hObject;
set(hObject, 'CloseRequestFcn', ...
    @(src, evt) T1_SemiAuto_ParamInput_CloseRequestFcn(src, evt, guidata(src)));

% Check if we received the parent GUI Experimental_PB_DAQ handle
% (GUI A is the parant GUI Experimentak_PB_DAQ)
% Unpack inputs if present
if length(varargin) >= 1
    handles.hFigA = varargin{1};  % GUI A figure handle
end

if length(varargin) >= 2
    handles.hObjectA = varargin{2};  % hObject from GUI A
end

if length(varargin) >= 3
    handles.eventdataA = varargin{3};  % eventdata from GUI A
end


    if exist('T1_SemiAuto_ParamInput_state.mat', 'file')
        loaded = load('T1_SemiAuto_ParamInput_state.mat');
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
                        case {'checkbox', 'radiobutton', 'togglebutton'}
                            set(h, 'Value', state.(fields{i}));
                        case 'popupmenu'
                            set(h, 'Value', state.(fields{i}));
                        case 'slider'
                            set(h, 'Value', state.(fields{i}));
                        otherwise
                            % Do nothing
                    end
                end
            end
        end
    end



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes T1_SemiAuto_ParamInput wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = T1_SemiAuto_ParamInput_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function MWPowerT1_1_Callback(hObject, eventdata, handles)
% hObject    handle to MWPowerT1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWPowerT1_1 as text
%        str2double(get(hObject,'String')) returns contents of MWPowerT1_1 as a double


% --- Executes during object creation, after setting all properties.
function MWPowerT1_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWPowerT1_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MWPowerRabi_Callback(hObject, eventdata, handles)
% hObject    handle to MWPowerRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWPowerRabi as text
%        str2double(get(hObject,'String')) returns contents of MWPowerRabi as a double


% --- Executes during object creation, after setting all properties.
function MWPowerRabi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWPowerRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MWPowerESR_Callback(hObject, eventdata, handles)
% hObject    handle to MWPowerESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWPowerESR as text
%        str2double(get(hObject,'String')) returns contents of MWPowerESR as a double


% --- Executes during object creation, after setting all properties.
function MWPowerESR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWPowerESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startESR_Callback(hObject, eventdata, handles)
% hObject    handle to startESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startESR as text
%        str2double(get(hObject,'String')) returns contents of startESR as a double


% --- Executes during object creation, after setting all properties.
function startESR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopESR_Callback(hObject, eventdata, handles)
% hObject    handle to stopESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopESR as text
%        str2double(get(hObject,'String')) returns contents of stopESR as a double


% --- Executes during object creation, after setting all properties.
function stopESR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPtsESR_Callback(hObject, eventdata, handles)
% hObject    handle to nPtsESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPtsESR as text
%        str2double(get(hObject,'String')) returns contents of nPtsESR as a double


% --- Executes during object creation, after setting all properties.
function nPtsESR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPtsESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startRabi_Callback(hObject, eventdata, handles)
% hObject    handle to startRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startRabi as text
%        str2double(get(hObject,'String')) returns contents of startRabi as a double


% --- Executes during object creation, after setting all properties.
function startRabi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopRabi_Callback(hObject, eventdata, handles)
% hObject    handle to stopRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopRabi as text
%        str2double(get(hObject,'String')) returns contents of stopRabi as a double


% --- Executes during object creation, after setting all properties.
function stopRabi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPtsRabi_Callback(hObject, eventdata, handles)
% hObject    handle to nPtsRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPtsRabi as text
%        str2double(get(hObject,'String')) returns contents of nPtsRabi as a double


% --- Executes during object creation, after setting all properties.
function nPtsRabi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPtsRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startT1_Callback(hObject, eventdata, handles)
% hObject    handle to startT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startT1 as text
%        str2double(get(hObject,'String')) returns contents of startT1 as a double


% --- Executes during object creation, after setting all properties.
function startT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopT1_Callback(hObject, eventdata, handles)
% hObject    handle to stopT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopT1 as text
%        str2double(get(hObject,'String')) returns contents of stopT1 as a double


% --- Executes during object creation, after setting all properties.
function stopT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPtsT1_Callback(hObject, eventdata, handles)
% hObject    handle to nPtsT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPtsT1 as text
%        str2double(get(hObject,'String')) returns contents of nPtsT1 as a double


% --- Executes during object creation, after setting all properties.
function nPtsT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPtsT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxAveESR_Callback(hObject, eventdata, handles)
% hObject    handle to maxAveESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAveESR as text
%        str2double(get(hObject,'String')) returns contents of maxAveESR as a double


% --- Executes during object creation, after setting all properties.
function maxAveESR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAveESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxAveRabi_Callback(hObject, eventdata, handles)
% hObject    handle to maxAveRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAveRabi as text
%        str2double(get(hObject,'String')) returns contents of maxAveRabi as a double


% --- Executes during object creation, after setting all properties.
function maxAveRabi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAveRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxAveT1_Callback(hObject, eventdata, handles)
% hObject    handle to maxAveT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAveT1 as text
%        str2double(get(hObject,'String')) returns contents of maxAveT1 as a double


% --- Executes during object creation, after setting all properties.
function maxAveT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAveT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thrsESR_Callback(hObject, eventdata, handles)
% hObject    handle to thrsESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thrsESR as text
%        str2double(get(hObject,'String')) returns contents of thrsESR as a double


% --- Executes during object creation, after setting all properties.
function thrsESR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrsESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function thrsRabi_Callback(hObject, eventdata, handles)
% hObject    handle to thrsRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of thrsRabi as text
%        str2double(get(hObject,'String')) returns contents of thrsRabi as a double


% --- Executes during object creation, after setting all properties.
function thrsRabi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thrsRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_startProg.
function pushbutton_startProg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_startProg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% rest the stop flag
handles.pushbutton_stopProg.UserData = 0;

% Retrieve GUI Exp_PB_DAQ handles (labeled as A)

hFigA = handles.hFigA;
handlesA = guidata(hFigA);
hObjectA = handles.hObjectA;
eventdataA = handles.eventdataA;

% Retrieve GUI T1_SemiAuto (current) handles
handlesB = handles;

% Save current inputs
%savestate(handles)

% Call T1_SemiAuto_Program
T1_SemiAuto_Program(hObjectA, eventdataA, handlesA, handlesB);



% --- Executes on button press in pushbutton_stopProg.
function pushbutton_stopProg_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stopProg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.pushbutton_stopProg.UserData = 1;



function RepeatT1_Callback(hObject, eventdata, handles)
% hObject    handle to RepeatT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepeatT1 as text
%        str2double(get(hObject,'String')) returns contents of RepeatT1 as a double


% --- Executes during object creation, after setting all properties.
function RepeatT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepeatT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RepeatRabi_Callback(hObject, eventdata, handles)
% hObject    handle to RepeatRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepeatRabi as text
%        str2double(get(hObject,'String')) returns contents of RepeatRabi as a double


% --- Executes during object creation, after setting all properties.
function RepeatRabi_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepeatRabi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RepeatESR_Callback(hObject, eventdata, handles)
% hObject    handle to RepeatESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepeatESR as text
%        str2double(get(hObject,'String')) returns contents of RepeatESR as a double


% --- Executes during object creation, after setting all properties.
function RepeatESR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepeatESR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MWPowerRabi2_Callback(hObject, eventdata, handles)
% hObject    handle to MWPowerRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWPowerRabi2 as text
%        str2double(get(hObject,'String')) returns contents of MWPowerRabi2 as a double


% --- Executes during object creation, after setting all properties.
function MWPowerRabi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWPowerRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MWPowerESR2_Callback(hObject, eventdata, handles)
% hObject    handle to MWPowerESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWPowerESR2 as text
%        str2double(get(hObject,'String')) returns contents of MWPowerESR2 as a double


% --- Executes during object creation, after setting all properties.
function MWPowerESR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWPowerESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startESR2_Callback(hObject, eventdata, handles)
% hObject    handle to startESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startESR2 as text
%        str2double(get(hObject,'String')) returns contents of startESR2 as a double


% --- Executes during object creation, after setting all properties.
function startESR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopESR2_Callback(hObject, eventdata, handles)
% hObject    handle to stopESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopESR2 as text
%        str2double(get(hObject,'String')) returns contents of stopESR2 as a double


% --- Executes during object creation, after setting all properties.
function stopESR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPtsESR2_Callback(hObject, eventdata, handles)
% hObject    handle to nPtsESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPtsESR2 as text
%        str2double(get(hObject,'String')) returns contents of nPtsESR2 as a double


% --- Executes during object creation, after setting all properties.
function nPtsESR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPtsESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startRabi2_Callback(hObject, eventdata, handles)
% hObject    handle to startRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startRabi2 as text
%        str2double(get(hObject,'String')) returns contents of startRabi2 as a double


% --- Executes during object creation, after setting all properties.
function startRabi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopRabi2_Callback(hObject, eventdata, handles)
% hObject    handle to stopRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopRabi2 as text
%        str2double(get(hObject,'String')) returns contents of stopRabi2 as a double


% --- Executes during object creation, after setting all properties.
function stopRabi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPtsRabi2_Callback(hObject, eventdata, handles)
% hObject    handle to nPtsRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPtsRabi2 as text
%        str2double(get(hObject,'String')) returns contents of nPtsRabi2 as a double


% --- Executes during object creation, after setting all properties.
function nPtsRabi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPtsRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxAveESR2_Callback(hObject, eventdata, handles)
% hObject    handle to maxAveESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAveESR2 as text
%        str2double(get(hObject,'String')) returns contents of maxAveESR2 as a double


% --- Executes during object creation, after setting all properties.
function maxAveESR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAveESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxAveRabi2_Callback(hObject, eventdata, handles)
% hObject    handle to maxAveRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAveRabi2 as text
%        str2double(get(hObject,'String')) returns contents of maxAveRabi2 as a double


% --- Executes during object creation, after setting all properties.
function maxAveRabi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAveRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RepeatRabi2_Callback(hObject, eventdata, handles)
% hObject    handle to RepeatRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepeatRabi2 as text
%        str2double(get(hObject,'String')) returns contents of RepeatRabi2 as a double


% --- Executes during object creation, after setting all properties.
function RepeatRabi2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepeatRabi2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RepeatESR2_Callback(hObject, eventdata, handles)
% hObject    handle to RepeatESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepeatESR2 as text
%        str2double(get(hObject,'String')) returns contents of RepeatESR2 as a double


% --- Executes during object creation, after setting all properties.
function RepeatESR2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepeatESR2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MWPowerT1_2_Callback(hObject, eventdata, handles)
% hObject    handle to MWPowerT1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWPowerT1_2 as text
%        str2double(get(hObject,'String')) returns contents of MWPowerT1_2 as a double


% --- Executes during object creation, after setting all properties.
function MWPowerT1_2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWPowerT1_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in use_title.
function use_title_Callback(hObject, eventdata, handles)
% hObject    handle to use_title (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_title



function figTitle_Callback(hObject, eventdata, handles)
% hObject    handle to figTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of figTitle as text
%        str2double(get(hObject,'String')) returns contents of figTitle as a double


% --- Executes during object creation, after setting all properties.
function figTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initZ1_Callback(hObject, eventdata, handles)
% hObject    handle to initZ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initZ1 as text
%        str2double(get(hObject,'String')) returns contents of initZ1 as a double


% --- Executes during object creation, after setting all properties.
function initZ1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initZ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function readoutZ1_Callback(hObject, eventdata, handles)
% hObject    handle to readoutZ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of readoutZ1 as text
%        str2double(get(hObject,'String')) returns contents of readoutZ1 as a double


% --- Executes during object creation, after setting all properties.
function readoutZ1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to readoutZ1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initZ2_Callback(hObject, eventdata, handles)
% hObject    handle to initZ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initZ2 as text
%        str2double(get(hObject,'String')) returns contents of initZ2 as a double


% --- Executes during object creation, after setting all properties.
function initZ2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initZ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function initZ3_Callback(hObject, eventdata, handles)
% hObject    handle to initZ3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of initZ3 as text
%        str2double(get(hObject,'String')) returns contents of initZ3 as a double


% --- Executes during object creation, after setting all properties.
function initZ3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to initZ3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function readoutZ2_Callback(hObject, eventdata, handles)
% hObject    handle to readoutZ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of readoutZ2 as text
%        str2double(get(hObject,'String')) returns contents of readoutZ2 as a double


% --- Executes during object creation, after setting all properties.
function readoutZ2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to readoutZ2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function readoutZ3_Callback(hObject, eventdata, handles)
% hObject    handle to readoutZ3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of readoutZ3 as text
%        str2double(get(hObject,'String')) returns contents of readoutZ3 as a double


% --- Executes during object creation, after setting all properties.
function readoutZ3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to readoutZ3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startT12_Callback(hObject, eventdata, handles)
% hObject    handle to startT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startT12 as text
%        str2double(get(hObject,'String')) returns contents of startT12 as a double


% --- Executes during object creation, after setting all properties.
function startT12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopT12_Callback(hObject, eventdata, handles)
% hObject    handle to stopT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopT12 as text
%        str2double(get(hObject,'String')) returns contents of stopT12 as a double


% --- Executes during object creation, after setting all properties.
function stopT12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPtsT12_Callback(hObject, eventdata, handles)
% hObject    handle to nPtsT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPtsT12 as text
%        str2double(get(hObject,'String')) returns contents of nPtsT12 as a double


% --- Executes during object creation, after setting all properties.
function nPtsT12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPtsT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxAveT12_Callback(hObject, eventdata, handles)
% hObject    handle to maxAveT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAveT12 as text
%        str2double(get(hObject,'String')) returns contents of maxAveT12 as a double


% --- Executes during object creation, after setting all properties.
function maxAveT12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAveT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function T1_SemiAuto_ParamInput_CloseRequestFcn(hObject, eventdata, handles)
    if nargin < 3 || isempty(handles) || ~isstruct(handles)
        handles = guidata(hObject);
    end

    try
        savestate(handles);
    catch ME
        warning('T1_SemiAuto_ParamInput:SaveStateFailed', ...
            'Failed to save GUI state on close: %s', ME.message);
    end

    delete(hObject);

function savestate(handles)
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
                case {'checkbox', 'radiobutton', 'togglebutton'}
                    state.(fields{i}) = get(h, 'Value');
                case 'popupmenu'
                    state.(fields{i}) = get(h, 'Value');
                case 'slider'
                    state.(fields{i}) = get(h, 'Value');
                otherwise
                    % Do nothing for other control types
            end
        end
    end

    save('T1_SemiAuto_ParamInput_state.mat', 'state');




function RepeatT12_Callback(hObject, eventdata, handles)
% hObject    handle to RepeatT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepeatT12 as text
%        str2double(get(hObject,'String')) returns contents of RepeatT12 as a double


% --- Executes during object creation, after setting all properties.
function RepeatT12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepeatT12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in slackUploadFlag.
function slackUploadFlag_Callback(hObject, eventdata, handles)
% hObject    handle to slackUploadFlag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of slackUploadFlag



function slackUploadText_Callback(hObject, eventdata, handles)
% hObject    handle to slackUploadText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slackUploadText as text
%        str2double(get(hObject,'String')) returns contents of slackUploadText as a double


% --- Executes during object creation, after setting all properties.
function slackUploadText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slackUploadText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function slackUploadFreq_Callback(hObject, eventdata, handles)
% hObject    handle to slackUploadFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slackUploadFreq as text
%        str2double(get(hObject,'String')) returns contents of slackUploadFreq as a double


% --- Executes during object creation, after setting all properties.
function slackUploadFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slackUploadFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function startT13_Callback(hObject, eventdata, handles)
% hObject    handle to startT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startT13 as text
%        str2double(get(hObject,'String')) returns contents of startT13 as a double


% --- Executes during object creation, after setting all properties.
function startT13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function stopT13_Callback(hObject, eventdata, handles)
% hObject    handle to stopT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stopT13 as text
%        str2double(get(hObject,'String')) returns contents of stopT13 as a double


% --- Executes during object creation, after setting all properties.
function stopT13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stopT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nPtsT13_Callback(hObject, eventdata, handles)
% hObject    handle to nPtsT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nPtsT13 as text
%        str2double(get(hObject,'String')) returns contents of nPtsT13 as a double


% --- Executes during object creation, after setting all properties.
function nPtsT13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nPtsT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxAveT13_Callback(hObject, eventdata, handles)
% hObject    handle to maxAveT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxAveT13 as text
%        str2double(get(hObject,'String')) returns contents of maxAveT13 as a double


% --- Executes during object creation, after setting all properties.
function maxAveT13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxAveT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RepeatT13_Callback(hObject, eventdata, handles)
% hObject    handle to RepeatT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RepeatT13 as text
%        str2double(get(hObject,'String')) returns contents of RepeatT13 as a double


% --- Executes during object creation, after setting all properties.
function RepeatT13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RepeatT13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function setB_Callback(hObject, eventdata, handles)
% hObject    handle to setB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of setB as text
%        str2double(get(hObject,'String')) returns contents of setB as a double


% --- Executes during object creation, after setting all properties.
function setB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to setB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sweepSpan_Callback(hObject, eventdata, handles)
% hObject    handle to sweepSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sweepSpan as text
%        str2double(get(hObject,'String')) returns contents of sweepSpan as a double


% --- Executes during object creation, after setting all properties.
function sweepSpan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sweepSpan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ZFS = 2.877; %GHz
g = 0.0028; %GGHz/Gauss
B = str2double(handles.setB.String);
span = str2double(handles.sweepSpan.String);
f1 = ZFS - B * g;
f2 = ZFS + B * g;
f1_start = f1 - span/2; 
f1_end = f1 + span/2;
f2_start = f2 - span/2;
f2_end = f2 + span/2;
handles.startESR.String = num2str(f1_start);
handles.stoptESR.String = num2str(f1_end);
handles.startESR2.String = num2str(f2_start);
handles.stopESR2.String = num2str(f2_end);
