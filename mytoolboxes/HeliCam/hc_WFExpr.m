function [expr, src] = hc_WFExpr(handles)
% hc_WFExpr(handles)  Resolve the widefield display expression for axes2/axes3.
%
%   [expr, src] = hc_WFExpr(handles)
%     expr : the expression string to evaluate over I and Q (never empty)
%     src  : 'GUI' | 'sequence' | 'default' -- where it came from
%
% Two widgets on Experiment_PB_DAQ govern this:
%
%   'WFContrast'    edit box   -- the expression you type
%   'overwriteExpr' checkbox   -- whether that box is allowed to take over
%
% Precedence:
%   1. the WFContrast box, ONLY while overwriteExpr is ticked
%   2. gmSEQ.WFcontrastExpr, declared by the hc_* sequence file
%   3. 'I' -- plain intensity, the last-resort fallback
%
% So the sequence's own line is what runs by default, and the box is inert until
% you deliberately tick the override. Untick it and the sequence takes back over
% immediately -- no need to clear the box, so an expression you were using stays
% there ready to re-enable.
%
% Read LIVE, on every display update, straight off the widgets -- deliberately
% NOT through LoadUserInputs. Two reasons:
%
%  * Editing the box or the tick mid-run changes the next point's plot. Going
%    through LoadUserInputs would freeze both at Run time.
%  * The ordering would otherwise invert the precedence. LoadUserInputs runs
%    BEFORE the sequence file, and the sequence file is re-run at every sweep
%    point (RunSequence's SequencePool call inside the loop), so a sequence that
%    sets gmSEQ.WFcontrastExpr would overwrite the GUI value at every point.
%    That is also why the widget tag ('WFContrast') is deliberately NOT the same
%    name as the gmSEQ field ('WFcontrastExpr'): same name would collide.
%
% CASE MATTERS. isfield is case-SENSITIVE, and these names must match the Tag
% set in GUIDE exactly. They were once spelled 'WFcontrast' here against a widget
% tagged 'WFContrast', and the only symptom was the box silently doing nothing --
% no error, no warning, just the sequence default every time. If you rename a Tag
% in GUIDE, change it here too.
%
% Never throws. A missing widget, a deleted handle, or a junk value all fall
% through to the next source rather than interrupting an acquisition.

global gmSEQ

TAG  = 'WFContrast';      % edit box: the expression text
GATE = 'overwriteExpr';   % checkbox: does that box override the sequence?

expr = '';
src  = 'default';

haveHandles = nargin >= 1 && ~isempty(handles) && isstruct(handles);

% --- 1. GUI box, gated by the override checkbox -----------------------------
if haveHandles && isfield(handles, TAG)
    useBox = true;
    if isfield(handles, GATE)
        % Checkbox present: it decides.
        try
            useBox = logical(get(handles.(GATE), 'Value'));
        catch
            useBox = false;   % deleted handle -> do not override
        end
    end
    % Checkbox ABSENT (older .fig with only the edit box): let the box govern,
    % which is what it did before the override existed. Otherwise the box would
    % be permanently dead on a layout with no way to enable it.

    if useBox
        try
            s = get(handles.(TAG), 'String');
            if iscell(s)
                if isempty(s); s = ''; else; s = s{1}; end   % multiline: first row
            end
            s = strtrim(char(s));
            if ~isempty(s)
                expr = s;
                src  = 'GUI';
            end
            % Blank box while ticked falls through to the sequence rather than
            % erroring -- a half-typed override should not blank the display.
        catch
            % Deleted handle or an unexpected widget type: fall through.
        end
    end
end

% --- 2. Sequence-declared default ------------------------------------------
if isempty(expr) && ~isempty(gmSEQ) && isstruct(gmSEQ) && ...
        isfield(gmSEQ, 'WFcontrastExpr') && ~isempty(gmSEQ.WFcontrastExpr)
    try
        s = strtrim(char(string(gmSEQ.WFcontrastExpr)));
        if ~isempty(s)
            expr = s;
            src  = 'sequence';
        end
    catch
    end
end

% --- 3. Fallback -----------------------------------------------------------
if isempty(expr)
    expr = 'I';
    src  = 'default';
end
end
