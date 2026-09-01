function [lims, src] = hc_WFClim(handles)
% hc_WFClim(handles)  Resolve manual colour limits for the axes2 widefield image.
%
%   [lims, src] = hc_WFClim(handles)
%     lims : [lo hi] to force on axes2, or [] to leave the automatic scale alone
%     src  : 'GUI'     -- lims is a valid manual override, use it
%            'off'     -- override not requested (or the widgets are absent)
%            'invalid' -- override requested but the boxes do not make a usable
%                         range; caller should fall back to the automatic scale
%
% Three widgets on Experiment_PB_DAQ govern this:
%
%   'colorBarMin'       edit box  -- lower colour limit
%   'colorBarMax'       edit box  -- upper colour limit
%   'overwriteColorBar' checkbox  -- whether those boxes take over
%
% Precedence: the boxes apply ONLY while overwriteColorBar is ticked. Untick it
% and the automatic scale takes back over immediately -- no need to clear the
% boxes, so limits you were using stay there ready to re-enable. This mirrors
% the WFContrast / overwriteExpr pair handled by hc_WFExpr.
%
% Read LIVE, on every display update, straight off the widgets -- deliberately
% NOT through LoadUserInputs, which would freeze the values at Run time. Editing
% a box or the tick mid-run therefore changes the next point's plot.
%
% Values are parsed with str2double, so each box takes a plain number
% ('0', '-5.2', '1e3'). Arithmetic ('5/2') is NOT evaluated: this runs inside
% the acquisition display loop, where eval'ing GUI text is a needless way to
% acquire new failure modes.
%
% CASE MATTERS. isfield is case-SENSITIVE and these names must match the Tag set
% in GUIDE exactly. A mismatched spelling makes the boxes SILENTLY inert -- no
% error, just the automatic scale every time. If you rename a Tag in GUIDE,
% change it here too. (This exact trap cost real time once already with
% 'WFContrast'; see hc_WFExpr.)
%
% Never throws. A missing widget, a deleted handle, a blank box or a junk value
% all resolve to 'off'/'invalid' rather than interrupting an acquisition.

LO   = 'colorBarMin';        % edit box: lower limit
HI   = 'colorBarMax';        % edit box: upper limit
GATE = 'overwriteColorBar';  % checkbox: do those boxes override?

lims = [];
src  = 'off';

haveHandles = nargin >= 1 && ~isempty(handles) && isstruct(handles);
if ~haveHandles || ~isfield(handles, LO) || ~isfield(handles, HI)
    return;   % layout without the boxes: automatic scale, exactly as before
end

% --- Is the override switched on? -------------------------------------------
% The gate must be present AND ticked. Unlike hc_WFExpr -- where a layout with
% only the edit box let that box govern for backward compatibility -- there is
% no prior behaviour to preserve here, and limits that applied themselves the
% moment someone typed in a box would be a trap.
if ~isfield(handles, GATE)
    return;
end
try
    useBoxes = logical(get(handles.(GATE), 'Value'));
catch
    return;   % deleted handle -> do not override
end
if ~useBoxes
    return;
end

% --- Read the two boxes ------------------------------------------------------
lo = readNum(handles, LO);
hi = readNum(handles, HI);

% --- Validate ----------------------------------------------------------------
% clim() rejects a non-increasing range, so lo >= hi has to be caught here or it
% throws inside the display. Reported as 'invalid' rather than silently swapped:
% a reversed pair is a typo, and quietly reordering it would hide the mistake
% while the picture changed under you.
if isfinite(lo) && isfinite(hi) && hi > lo
    lims = [lo hi];
    src  = 'GUI';
else
    src  = 'invalid';
end
end


function v = readNum(handles, tag)
% One edit box as a scalar double; NaN for anything unusable.
v = NaN;
try
    s = get(handles.(tag), 'String');
    if iscell(s)
        if isempty(s); s = ''; else; s = s{1}; end   % multiline: first row
    end
    s = strtrim(char(s));
    if ~isempty(s)
        v = str2double(s);
    end
catch
    % Deleted handle or an unexpected widget type: leave it NaN.
end
if ~isscalar(v); v = NaN; end
end
