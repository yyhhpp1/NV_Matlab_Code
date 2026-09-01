function fcfg = hc_FocusConfig(cfg)
% hc_FocusConfig(cfg)  Resolve the hc_ZScan focus-metric parameters.
%
% One place decides what every focus knob is, so hc_FocusMask, hc_FocusMetric and
% the live display cannot drift onto different values and produce a mask that
% disagrees with the score computed against it.
%
% Resolution order, highest priority first:
%   1. gmSEQ.focus<Name>        -- per-run override (this is the documented route
%                                 for a future GUI field: set gmSEQ.focusDarkFrac
%                                 from a widget in LoadUserInputs and it wins here
%                                 automatically, with no change to this file)
%   2. cfg.focus<Name>          -- WidefieldConfig default
%   3. the hardcoded default below
%
% Returns a struct with SHORT field names (darkFrac, erodePx, ...) so callers read
% cleanly. That renaming is also how idempotence is detected: handing an
% already-resolved struct back in returns it unchanged, so callers can accept
% either a WidefieldConfig or a resolved struct without caring which.
%
% See hc_FocusMask / hc_FocusMetric for what each parameter actually does.

% Already resolved -> pass straight through.
if nargin >= 1 && isstruct(cfg) && isfield(cfg, 'darkFrac') && isfield(cfg, 'erodePx')
    fcfg = cfg;
    return;
end

if nargin < 1 || isempty(cfg) || ~isstruct(cfg)
    cfg = WidefieldConfig();
end

fcfg = struct();
fcfg.metric      = pick(cfg, 'focusMetric',      'tenengrad');
fcfg.darkFrac    = pick(cfg, 'focusDarkFrac',    0.35);
fcfg.brightPct   = pick(cfg, 'focusBrightPct',   95);
fcfg.hotFactor   = pick(cfg, 'focusHotFactor',   3);
fcfg.erodePx     = pick(cfg, 'focusErodePx',     3);
fcfg.smooth      = pick(cfg, 'focusSmooth',      true);
fcfg.minValidPx  = pick(cfg, 'focusMinValidPx',  500);
fcfg.goToBest    = pick(cfg, 'focusGoToBest',    true);
fcfg.minConf     = pick(cfg, 'focusMinConf',     1.2);

% The filters hc_FocusMetric applies (3x3 smooth composed with a 3x3 Sobel /
% Laplacian, or a +/-1 Brenner step) have a combined support of 5x5, so every
% pixel that contributes to a score needs its whole 5x5 neighbourhood inside the
% valid region. Anything below 2 would let the shadow edge leak back in through
% the filter footprint after we went to the trouble of masking it.
if ~isfinite(fcfg.erodePx) || fcfg.erodePx < 2
    fcfg.erodePx = 2;
end
fcfg.erodePx = round(fcfg.erodePx);

% A negative or non-finite fraction would mask everything or nothing at random;
% 0 is meaningful and deliberate (it disables dark rejection, which is the
% negative control described in the hc_ZScan header).
if ~isfinite(fcfg.darkFrac) || fcfg.darkFrac < 0
    fcfg.darkFrac = 0;
end

function v = pick(cfg, name, dflt)
% gmSEQ override > WidefieldConfig > hardcoded default.
global gmSEQ
v = dflt;
if isfield(cfg, name) && ~isempty(cfg.(name))
    v = cfg.(name);
end
if ~isempty(gmSEQ) && isstruct(gmSEQ) && isfield(gmSEQ, name) && ~isempty(gmSEQ.(name))
    v = gmSEQ.(name);
end
