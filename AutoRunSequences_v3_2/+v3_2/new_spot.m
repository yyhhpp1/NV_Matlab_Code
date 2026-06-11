function spot = new_spot(varargin)
%NEW_SPOT Create a campaign-level laser spot definition for v3.2.

opts = parse_name_value(varargin{:});
spot = struct();
if isfield(opts, 'id') && ~isempty(opts.id)
    spot.id = char(opts.id);
else
    spot.id = sprintf('spot_%s_%04d', datestr(now, 'yyyymmdd_HHMMSS'), randi([0, 9999]));
end
if isfield(opts, 'name') && ~isempty(opts.name)
    spot.name = char(opts.name);
else
    spot.name = 'Spot';
end
spot.enabled = true;
spot.order = 1;
spot.xV = field_or(opts, 'xV', NaN);
spot.yV = field_or(opts, 'yV', NaN);
spot.isCurrentPosition = false;
end

function opts = parse_name_value(varargin)
opts = struct();
if mod(nargin, 2) ~= 0
    error('SmartT1:v3_2:InvalidArgs', 'Name/value arguments must be paired.');
end
for i = 1:2:nargin
    key = varargin{i};
    if ~(ischar(key) || isstring(key))
        error('SmartT1:v3_2:InvalidArgs', 'Option names must be text.');
    end
    opts.(char(key)) = varargin{i + 1};
end
end

function out = field_or(s, fieldName, defaultValue)
if isfield(s, fieldName)
    out = s.(fieldName);
else
    out = defaultValue;
end
end
