function dispatch(handles, handles2, raw_j, seqName, ctrN, plotCfg)
% Apply configured per-sequence plotting and optional live fitting.

cfg = normalize_plot_cfg(plotCfg);
if ctrN > cfg.maxCtrToPlot
    return;
end

seqName = normalize_to_char(seqName);
rule = get_rule_for_sequence(seqName, cfg);

invoke_plot(rule.plotFunction, handles, raw_j, cfg.default.plotFunction);
invoke_live_fit(rule.liveFitFunction, handles, handles2);
end

function cfg = normalize_plot_cfg(plotCfg)
if nargin < 1 || ~isstruct(plotCfg)
    cfg = default_plot_cfg();
    return;
end

cfg = default_plot_cfg();

if isfield(plotCfg, 'maxCtrToPlot') && ~isempty(plotCfg.maxCtrToPlot)
    cfg.maxCtrToPlot = plotCfg.maxCtrToPlot;
end

if isfield(plotCfg, 'default') && isstruct(plotCfg.default)
    if isfield(plotCfg.default, 'plotFunction') && ~isempty(plotCfg.default.plotFunction)
        cfg.default.plotFunction = plotCfg.default.plotFunction;
    end
    if isfield(plotCfg.default, 'liveFitFunction')
        cfg.default.liveFitFunction = plotCfg.default.liveFitFunction;
    end
end

if isfield(plotCfg, 'rules') && ~isempty(plotCfg.rules)
    cfg.rules = plotCfg.rules;
end
end

function cfg = default_plot_cfg()
cfg = struct();
cfg.maxCtrToPlot = 24;
cfg.default = struct('plotFunction', 'PlotData', 'liveFitFunction', '');
cfg.rules = {};
end

function rule = get_rule_for_sequence(seqName, cfg)
rule = cfg.default;
rules = cfg.rules;

if ~iscell(rules) || isempty(rules)
    return;
end

for i = 1:size(rules, 1)
    if size(rules, 2) < 2
        continue;
    end

    candidateName = normalize_to_char(rules{i, 1});
    if ~strcmp(candidateName, seqName)
        continue;
    end

    rule.plotFunction = normalize_to_char(rules{i, 2});
    if size(rules, 2) >= 3
        rule.liveFitFunction = normalize_to_char(rules{i, 3});
    else
        rule.liveFitFunction = '';
    end
    return;
end
end

function invoke_plot(plotFunction, handles, raw_j, defaultPlotFunction)
if nargin < 4 || isempty(defaultPlotFunction)
    defaultPlotFunction = 'PlotData';
end

plotFunction = normalize_to_char(plotFunction);
if isempty(plotFunction)
    plotFunction = defaultPlotFunction;
end

if ~function_exists(plotFunction)
    warn_once(['missing_plot_' plotFunction], ...
        'autoplot:MissingPlotFunction', ...
        'Plot function "%s" not found. Falling back to "%s".', ...
        plotFunction, defaultPlotFunction);
    plotFunction = defaultPlotFunction;
end

if ~function_exists(plotFunction)
    warn_once(['missing_plot_' plotFunction], ...
        'autoplot:MissingDefaultPlotFunction', ...
        'Default plot function "%s" not found. Skipping plot.', ...
        plotFunction);
    return;
end

try
    feval(plotFunction, handles, raw_j);
catch ME
    warn_once(['plot_failed_' plotFunction], ...
        'autoplot:PlotFunctionFailed', ...
        'Plot function "%s" failed: %s', ...
        plotFunction, ME.message);
end
end

function invoke_live_fit(fitFunction, handles, handles2)
fitFunction = normalize_to_char(fitFunction);
if isempty(fitFunction)
    return;
end

if ~function_exists(fitFunction)
    warn_once(['missing_fit_' fitFunction], ...
        'autoplot:MissingLiveFitFunction', ...
        'Live fit function "%s" not found. Skipping live fit.', ...
        fitFunction);
    return;
end

try
    feval(fitFunction, handles, handles2);
catch ME
    warn_once(['fit_failed_' fitFunction], ...
        'autoplot:LiveFitFunctionFailed', ...
        'Live fit function "%s" failed: %s', ...
        fitFunction, ME.message);
end
end

function tf = function_exists(funcName)
if isempty(funcName)
    tf = false;
    return;
end

% Package-qualified functions (e.g., plotting.plot_rabi_data) are more
% reliably resolved via WHICH than EXIST(...,'file') alone.
w = which(funcName);
if ~isempty(w)
    tf = true;
    return;
end

tf = (exist(funcName, 'file') == 2) || (exist(funcName, 'builtin') == 5);
end

function out = normalize_to_char(in)
if iscell(in)
    if isempty(in)
        out = '';
    else
        out = normalize_to_char(in{1});
    end
elseif isstring(in)
    out = char(in);
elseif ischar(in)
    out = in;
elseif isnumeric(in)
    out = num2str(in);
else
    out = char(string(in));
end
end

function warn_once(key, warningId, warningFmt, varargin)
persistent warnedKeys
if isempty(warnedKeys)
    warnedKeys = struct();
end

safeKey = matlab.lang.makeValidName(key);
if isfield(warnedKeys, safeKey)
    return;
end

warnedKeys.(safeKey) = true;
warning(warningId, warningFmt, varargin{:});
end
