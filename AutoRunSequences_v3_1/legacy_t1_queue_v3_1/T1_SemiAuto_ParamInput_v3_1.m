function varargout = T1_SemiAuto_ParamInput_v3_1(varargin)
% v3.1 launcher for the existing v2.1 GUI with Start callback rebound to v3.1.

ensure_v2_1_path();

if nargout
    [varargout{1:nargout}] = T1_SemiAuto_ParamInput_v2_1(varargin{:});
    hFig = varargout{1};
else
    hFig = T1_SemiAuto_ParamInput_v2_1(varargin{:});
end

if ~ishandle(hFig)
    return;
end

handles = guidata(hFig);
if isstruct(handles) && isfield(handles, 'pushbutton_startProg') ...
        && isgraphics(handles.pushbutton_startProg, 'uicontrol')
    set(handles.pushbutton_startProg, 'Callback', @pushbutton_startProg_v3_1_Callback);
end

try
    set(hFig, 'Name', 'T1 SemiAuto Param Input v3.1', 'NumberTitle', 'off');
catch
end
end

function pushbutton_startProg_v3_1_Callback(hObject, eventdata)
handles = guidata(hObject);

if isfield(handles, 'pushbutton_stopProg') && isgraphics(handles.pushbutton_stopProg, 'uicontrol')
    handles.pushbutton_stopProg.UserData = 0;
end

if ~isfield(handles, 'hFigA') || isempty(handles.hFigA) || ~ishandle(handles.hFigA)
    errordlg('Parent Experimental_PB_DAQ GUI handle is missing. Relaunch from the main GUI.', ...
        'SmartT1 v3.1');
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
t1_semi_auto_program_v3_1(hObjectA, eventdataA, handlesA, handlesB);
end

function ensure_v2_1_path()
thisDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(thisDir);
v2Dir = fullfile(repoRoot, 'AutoRunSequences_v2_1');

if ~isfolder(v2Dir)
    error('SmartT1:v3_1:MissingV2_1', ...
        'Cannot find AutoRunSequences_v2_1 at: %s', v2Dir);
end

addpath(thisDir, '-begin');
addpath(v2Dir, '-end');
end
