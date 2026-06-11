function cfg = bt_control_cfg_load(sectionName)
%BT_CONTROL_CFG_LOAD Load BT control defaults from bt_control_defaults.cfg.
%   cfg = bt_control_cfg_load()
%   cfg = bt_control_cfg_load(sectionName)
%
% Merging rule:
%   - Always loads [global] first.
%   - If sectionName provided, loads [sectionName] and overrides [global].
%   - Returns empty struct when file is missing or parse fails.

cfg = struct();
cfgPath = fullfile(fileparts(mfilename('fullpath')), 'bt_control_defaults.cfg');
if ~isfile(cfgPath)
    return;
end

allCfg = parse_cfg_file(cfgPath);
if isempty(fieldnames(allCfg))
    return;
end

cfg = merge_structs(cfg, get_section(allCfg, 'global'));
if nargin >= 1 && ~isempty(sectionName)
    cfg = merge_structs(cfg, get_section(allCfg, char(string(sectionName))));
end
end

function out = parse_cfg_file(cfgPath)
out = struct();
fid = fopen(cfgPath, 'r');
if fid < 0
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

current = 'global';
out.(sanitize_name(current)) = struct();

while true
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    txt = strtrim(line);
    if isempty(txt)
        continue;
    end
    if startsWith(txt, '#') || startsWith(txt, ';')
        continue;
    end

    if startsWith(txt, '[') && endsWith(txt, ']')
        secRaw = strtrim(txt(2:end-1));
        if isempty(secRaw)
            continue;
        end
        current = sanitize_name(secRaw);
        if ~isfield(out, current)
            out.(current) = struct();
        end
        continue;
    end

    eqIdx = strfind(txt, '=');
    if isempty(eqIdx)
        continue;
    end
    kRaw = strtrim(txt(1:eqIdx(1)-1));
    vRaw = strtrim(txt(eqIdx(1)+1:end));
    if isempty(kRaw)
        continue;
    end
    key = sanitize_name(kRaw);
    val = parse_value(vRaw);
    out.(current).(key) = val;
end
end

function sec = get_section(allCfg, nameIn)
name = sanitize_name(nameIn);
if isfield(allCfg, name)
    sec = allCfg.(name);
else
    sec = struct();
end
end

function out = merge_structs(a, b)
out = a;
if ~isstruct(b)
    return;
end
f = fieldnames(b);
for i = 1:numel(f)
    out.(f{i}) = b.(f{i});
end
end

function name = sanitize_name(in)
name = matlab.lang.makeValidName(char(string(in)));
if isempty(name)
    name = 'unnamed';
end
end

function v = parse_value(raw)
txt = strtrim(char(string(raw)));
if isempty(txt)
    v = [];
    return;
end

if numel(txt) >= 2
    if (txt(1) == '"' && txt(end) == '"') || (txt(1) == '''' && txt(end) == '''')
        v = txt(2:end-1);
        return;
    end
end

l = lower(txt);
if any(strcmp(l, {'true','yes','on'}))
    v = true;
    return;
end
if any(strcmp(l, {'false','no','off'}))
    v = false;
    return;
end

if startsWith(txt, '[') && endsWith(txt, ']')
    inner = strtrim(txt(2:end-1));
    if isempty(inner)
        v = [];
        return;
    end
    parts = regexp(inner, '[,\s;]+', 'split');
    parts = parts(~cellfun(@isempty, parts));
    nums = nan(1, numel(parts));
    allNum = true;
    for i = 1:numel(parts)
        nums(i) = str2double(parts{i});
        if ~isfinite(nums(i))
            allNum = false;
            break;
        end
    end
    if allNum
        v = nums;
    else
        v = inner;
    end
    return;
end

n = str2double(txt);
if isfinite(n)
    v = n;
else
    v = txt;
end
end

