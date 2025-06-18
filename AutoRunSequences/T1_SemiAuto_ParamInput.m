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

% Last Modified by GUIDE v2.5 17-Jun-2025 14:37:25

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



function MWPowerT1_Callback(hObject, eventdata, handles)
% hObject    handle to MWPowerT1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWPowerT1 as text
%        str2double(get(hObject,'String')) returns contents of MWPowerT1 as a double


% --- Executes during object creation, after setting all properties.
function MWPowerT1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWPowerT1 (see GCBO)
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
