function apply_profile_snapshot(handlesAuto, snapshot)
%APPLY_PROFILE_SNAPSHOT Restore captured control values onto v2.1 GUI handles.

if nargin < 1 || ~isstruct(handlesAuto) || nargin < 2 || ~isstruct(snapshot)
    return;
end
if ~isfield(snapshot, 'controls') || isempty(snapshot.controls)
    return;
end

tagMap = build_tag_map(handlesAuto);
for i = 1:numel(snapshot.controls)
    ctrl = snapshot.controls(i);
    if ~isfield(ctrl, 'tag') || isempty(ctrl.tag)
        continue;
    end
    safeTag = matlab.lang.makeValidName(char(ctrl.tag));
    if ~isfield(tagMap, safeTag)
        continue;
    end
    h = tagMap.(safeTag);
    if ~isgraphics(h)
        continue;
    end

    set_if_prop(h, 'String', ctrl, 'string');
    set_if_prop(h, 'Value', ctrl, 'value');
    drawnow;
end
end

function tagMap = build_tag_map(handlesAuto)
tagMap = struct();
fields = fieldnames(handlesAuto);
for i = 1:numel(fields)
    h = handlesAuto.(fields{i});
    if ~isgraphics(h)
        continue;
    end
    tag = '';
    if isprop(h, 'Tag')
        tag = get(h, 'Tag');
    end
    if isempty(tag)
        continue;
    end
    safeTag = matlab.lang.makeValidName(tag);
    tagMap.(safeTag) = h;
end
end

function set_if_prop(h, propName, ctrl, ctrlField)
if ~isprop(h, propName)
    return;
end
if ~isfield(ctrl, ctrlField)
    return;
end
value = ctrl.(ctrlField);
try
    set(h, propName, value);
catch
end
end
