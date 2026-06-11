function out = compile_v2_1_analysis_snippets(mainFolder, outFile)
%COMPILE_V2_1_ANALYSIS_SNIPPETS Merge v2.1 analysis snippets into one file.
%   out = compile_v2_1_analysis_snippets(mainFolder)
%   out = compile_v2_1_analysis_snippets(mainFolder, outFile)
%
% This scans recursively under mainFolder for files named:
%   analysis_add_entry_snippet.txt
%
% For each snippet:
%   1) Parse run folder name, e.g. Run_0p00G_90p00K_20260308_192345
%   2) Parse B line from snippet (B = xxx;), mapping NaN -> 0
%   3) Collect data.add_entry(...) lines
%
% Output is grouped and sorted by T then B:
%   T = <T>;
%   B = <B>;
%   data.add_entry(...)
%
% If outFile is omitted:
%   <mainFolder>\compiled_analysis_add_entry_snippet.txt

if nargin < 1 || isempty(mainFolder)
    error('SmartT1:v3_1:MissingInput', 'mainFolder is required.');
end
if ~ischar(mainFolder) && ~isstring(mainFolder)
    error('SmartT1:v3_1:InvalidInput', 'mainFolder must be a path string.');
end
mainFolder = char(string(mainFolder));
if exist(mainFolder, 'dir') ~= 7
    error('SmartT1:v3_1:FolderNotFound', 'mainFolder does not exist: %s', mainFolder);
end

if nargin < 2 || isempty(outFile)
    outFile = fullfile(mainFolder, 'compiled_analysis_add_entry_snippet.txt');
else
    outFile = char(string(outFile));
end

snippetFiles = dir(fullfile(mainFolder, '**', 'analysis_add_entry_snippet.txt'));
if isempty(snippetFiles)
    error('SmartT1:v3_1:NoSnippetFiles', ...
        'No analysis_add_entry_snippet.txt found under: %s', mainFolder);
end

records = repmat(struct( ...
    'snippetPath', '', ...
    'runFolder', '', ...
    'T', NaN, ...
    'B', NaN, ...
    'entryLines', {{}}), 0, 1);

for i = 1:numel(snippetFiles)
    f = snippetFiles(i);
    snippetPath = fullfile(f.folder, f.name);
    runFolder = f.folder;

    [TfromFolder, ~] = parse_run_folder_T_B(runFolder);
    [BfromSnippet, entryLines] = parse_snippet_file(snippetPath);
    if isempty(entryLines)
        continue;
    end

    rec = struct();
    rec.snippetPath = snippetPath;
    rec.runFolder = runFolder;
    rec.T = TfromFolder;
    rec.B = BfromSnippet;
    rec.entryLines = entryLines;
    records(end + 1, 1) = rec; %#ok<AGROW>
end

if isempty(records)
    error('SmartT1:v3_1:NoEntries', ...
        'Snippet files were found but no data.add_entry lines were parsed.');
end

Tvals = [records.T].';
Bvals = [records.B].';
Tsort = Tvals;
Bsort = Bvals;
Tsort(~isfinite(Tsort)) = inf;
Bsort(~isfinite(Bsort)) = inf;
[~, idxSort] = sortrows([Tsort, Bsort], [1 2]);
records = records(idxSort);

[ok, errMsg] = write_compiled_snippet(outFile, records, mainFolder);
if ~ok
    error('SmartT1:v3_1:WriteFailed', 'Failed to write compiled snippet: %s', errMsg);
end

out = struct();
out.mainFolder = mainFolder;
out.outFile = outFile;
out.nSnippetFiles = numel(snippetFiles);
out.nRecords = numel(records);
disp(sprintf('[compile_v2_1_analysis_snippets] Wrote %d record(s) to %s', out.nRecords, out.outFile));
end

function [T_K, B_G] = parse_run_folder_T_B(runFolderPath)
T_K = NaN;
B_G = NaN;

[~, runName, ~] = fileparts(runFolderPath);

% New style: Run_0p00G_90p00K_20260308_192345
tokNew = regexp(runName, '^Run_([^_]+)_([^_]+)_\d{8}_\d{6}(?:_\d+)?$', 'tokens', 'once');
if ~isempty(tokNew) && numel(tokNew) >= 2
    B_G = decode_tag_value(tokNew{1}, 'G');
    T_K = decode_tag_value(tokNew{2}, 'K');
    return;
end

% Old style fallback: Run_120p00G_20260308_192345
tokOld = regexp(runName, '^Run_([^_]+)_\d{8}_\d{6}(?:_\d+)?$', 'tokens', 'once');
if ~isempty(tokOld) && numel(tokOld) >= 1
    B_G = decode_tag_value(tokOld{1}, 'G');
end
end

function val = decode_tag_value(tagStr, suffixChar)
val = NaN;
raw = char(string(tagStr));
if isempty(raw)
    return;
end
if nargin >= 2 && ~isempty(suffixChar)
    sf = char(string(suffixChar));
    if endsWith(raw, sf)
        raw = raw(1:end-numel(sf));
    end
end
raw = strrep(raw, 'm', '-');
raw = strrep(raw, 'p', '.');
vv = str2double(raw);
if isfinite(vv)
    val = vv;
end
end

function [B_G, entryLines] = parse_snippet_file(snippetPath)
B_G = 0;
entryLines = {};

txt = fileread(snippetPath);
if isempty(txt)
    return;
end
lines = regexp(txt, '\r\n|\n|\r', 'split');

for i = 1:numel(lines)
    ln = strtrim(lines{i});
    if startsWith(ln, 'B')
        tok = regexp(ln, '^B\s*=\s*([^;]+);', 'tokens', 'once');
        if ~isempty(tok)
            bRaw = strtrim(tok{1});
            if strcmpi(bRaw, 'NaN')
                B_G = 0;
            else
                bVal = str2double(bRaw);
                if isfinite(bVal)
                    B_G = bVal;
                else
                    B_G = 0;
                end
            end
            break;
        end
    end
end

for i = 1:numel(lines)
    ln = strtrim(lines{i});
    if startsWith(ln, 'data.add_entry(')
        entryLines{end + 1, 1} = ln; %#ok<AGROW>
    end
end
end

function [ok, errMsg] = write_compiled_snippet(outFile, records, mainFolder)
ok = false;
errMsg = '';

[outDir, ~, ~] = fileparts(outFile);
if ~isempty(outDir) && exist(outDir, 'dir') ~= 7
    [mkOk, mkMsg, mkId] = mkdir(outDir);
    if ~mkOk
        errMsg = sprintf('Cannot create output folder "%s": %s (%s)', outDir, mkMsg, mkId);
        return;
    end
end

[fid, fopenMsg] = fopen(outFile, 'w');
if fid < 0
    errMsg = sprintf('Cannot open output file "%s": %s', outFile, fopenMsg);
    return;
end
cleanupObj = onCleanup(@() fclose(fid)); %#ok<NASGU>

fprintf(fid, '%% Compiled v2.1 analysis snippet\n');
fprintf(fid, '%% Source root: %s\n', mainFolder);
fprintf(fid, '%% Generated at: %s\n\n', datestr(now, 'yyyy-mm-dd HH:MM:SS.FFF'));

lastT = NaN;
lastB = NaN;
for i = 1:numel(records)
    r = records(i);
    T = r.T;
    B = r.B;

    tChanged = (i == 1) || (~isfinite(lastT) && isfinite(T)) || (isfinite(lastT) && isfinite(T) && abs(lastT - T) > 1e-12) || (isfinite(lastT) ~= isfinite(T));
    if tChanged
        if i > 1
            fprintf(fid, '\n');
        end
        if isfinite(T)
            fprintf(fid, 'T = %.12g;\n', T);
        else
            fprintf(fid, 'T = NaN; %% unknown from folder name\n');
        end
        lastB = NaN;
    end

    bChanged = (i == 1) || (~isfinite(lastB) && isfinite(B)) || (isfinite(lastB) && isfinite(B) && abs(lastB - B) > 1e-12) || (isfinite(lastB) ~= isfinite(B));
    if bChanged
        if isfinite(B)
            fprintf(fid, 'B = %.12g;\n', B);
        else
            fprintf(fid, 'B = 0;\n');
        end
    end

    for j = 1:numel(r.entryLines)
        fprintf(fid, '%s\n', r.entryLines{j});
    end
    fprintf(fid, '\n');

    lastT = T;
    lastB = B;
end

ok = true;
end
