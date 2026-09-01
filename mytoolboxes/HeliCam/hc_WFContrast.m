function [stack, label, info] = hc_WFContrast(I, Q, expr)
% hc_WFContrast(I, Q, expr)  Evaluate the widefield display expression.
%
%   [stack, label, info] = hc_WFContrast(I, Q, expr)
%     I, Q  : H x W x N arrays -- gWide.I and gWide.Q, the two lock-in
%             quadratures, both already dark-subtracted and already
%             sign-corrected by readIQ, so neither needs another minus here
%     expr  : expression string over I and Q, e.g. 'I', 'I-Q', 'I/Q', 'Q./I'
%     stack : H x W x N result, ready to index as stack(:,:,j)
%     label : what to put on the axis -- the expression, or a marked fallback
%     info  : .expr .applied .src .fellBack .message .nNonFinite
%
% NEVER THROWS, BY DESIGN. This runs inside the acquisition loop, so a mistyped
% expression must cost a plot, not a run. Anything that goes wrong -- syntax
% error, undefined name, wrong-sized result -- falls back to plain I and says so
% on the axis label. The console warning is throttled to once per distinct
% problem so a 40-point sweep with a bad expression does not bury the window.
%
% OPERATORS ARE AUTO-VECTORISED. '*', '/', '^' and '\' are rewritten to '.*',
% './', '.^', '.\' unless already dotted, so 'I/Q' means what a user means by it.
% Without this, 'I/Q' on 512x542 arrays is mrdivide -- a least-squares linear
% solve that either errors or silently returns something that is not a per-pixel
% ratio at all. Writing './' explicitly also works and is left untouched.
%
% NON-FINITE VALUES ARE KEPT, NOT REJECTED. 'I/Q' divides by zero wherever Q is
% zero, which is normal in the shadow and in unfilled slices. Inf and NaN are
% mapped to NaN so imagesc autoscales past them and a NaN-safe ROI mean can skip
% them; the count of pixels the EXPRESSION made non-finite (as opposed to ones
% that were already NaN, e.g. the preallocated tail of the sweep) is reported in
% info.nNonFinite for the caller to surface.
%
% The expression is evaluated as an anonymous function, so it can call any MATLAB
% function. That is the same trust level as the eval() this codebase already uses
% for GUI numeric fields -- the person typing it is the person running the rig.

persistent lastWarn
if isempty(lastWarn); lastWarn = ''; end

if nargin < 3 || isempty(expr); expr = 'I'; end
expr = strtrim(char(string(expr)));

info            = struct();
info.expr       = expr;
info.applied    = expr;
info.fellBack   = false;
info.message    = '';
info.nNonFinite = 0;

% --- Auto-vectorise the operators -----------------------------------------
% Lookbehind leaves an already-dotted operator alone, so '.*' does not become
% '..*'. '^' sits last in the class so it is a literal, not a negation.
exprV = regexprep(expr, '(?<!\.)([*/\\^])', '.$1');
info.applied = exprV;

% --- Evaluate -------------------------------------------------------------
try
    f     = str2func(['@(I,Q) ' exprV]);
    stack = f(I, Q);
catch ME
    stack = [];
    info.message = ME.message;
end

% A result of the wrong shape cannot be indexed as stack(:,:,j) by the caller,
% and silently reshaping someone's projection would be worse than refusing it.
if ~isempty(stack) && ~isequal(size(stack), size(I))
    info.message = sprintf('result is %s but the image stack is %s', ...
                           mat2str(size(stack)), mat2str(size(I)));
    stack = [];
end

if isempty(stack)
    % Fall back to the one thing that is always available and always meaningful.
    stack         = I;
    label         = sprintf('I  [expr "%s" failed]', expr);
    info.fellBack = true;
    info.applied  = 'I';
    msg = sprintf('%s || %s', expr, info.message);
    if ~strcmp(msg, lastWarn)
        fprintf(2, ['[Widefield] Display expression "%s" failed (%s). Showing plain I ', ...
                    'instead; acquisition is unaffected.\n'], expr, info.message);
        lastWarn = msg;
    end
    return;
end

% --- Sanitise non-finite values ------------------------------------------
bad = ~isfinite(stack);
if any(bad(:))
    % Count only what the expression BROKE: positions where I was finite but the
    % result is not. The preallocated NaN tail of gWide would otherwise dominate
    % the count and make every early sweep point look catastrophic.
    info.nNonFinite = sum(bad(:) & isfinite(I(:)));
    stack(bad)      = NaN;
end

label    = expr;
lastWarn = '';   % expression is working again; re-arm the warning
end
