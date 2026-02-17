function snapshot = capture_profile_snapshot(handlesAuto)
%CAPTURE_PROFILE_SNAPSHOT Capture v2.1 GUI control values into a snapshot struct.

snapshot = struct();
snapshot.capturedAt = datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF');
snapshot.controls = repmat(struct( ...
    'tag', '', ...
    'style', '', ...
    'string', '', ...
    'value', [], ...
    'enable', ''), 0, 1);

if nargin < 1 || ~isstruct(handlesAuto)
    return;
end

fields = fieldnames(handlesAuto);
for i = 1:numel(fields)
    h = handlesAuto.(fields{i});
    if ~isgraphics(h)
        continue;
    end

    style = safe_get_prop(h, 'Style', '');
    tag = safe_get_prop(h, 'Tag', '');
    if isempty(tag)
        continue;
    end

    c = struct();
    c.tag = tag;
    c.style = style;
    c.string = safe_get_prop(h, 'String', '');
    c.value = safe_get_prop(h, 'Value', []);
    c.enable = safe_get_prop(h, 'Enable', '');
    snapshot.controls(end + 1, 1) = c; %#ok<AGROW>
end
end

function value = safe_get_prop(h, prop, defaultValue)
if isprop(h, prop)
    value = get(h, prop);
else
    value = defaultValue;
end
end
