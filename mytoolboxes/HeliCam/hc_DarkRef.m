function out = hc_DarkRef(mode, pathOrData)
% out = hc_DarkRef(mode, pathOrData)  Capture / load a per-pixel DARK REFERENCE.
%
%   hc_DarkRef('save')          store the current gWide as the dark reference
%   hc_DarkRef('save', path)    ... to an explicit .mat path
%   hc_DarkRef('import', h5)    store a previously saved widefield .h5 as the
%                               dark reference (settings read from its attrs)
%   d = hc_DarkRef('load')      load it (errors if absent)
%   d = hc_DarkRef('load', path)
%   hc_DarkRef('clear')         delete the stored file
%   hc_DarkRef('path')          report where it would be stored
%
% Why this exists: the C4's rawI/rawQ carry a large per-pixel electronic pedestal.
% With the cap ON, reference reads ~517 in decoded units; the light-induced part of
% a real measurement can be a few units on top of that. Until the pedestal is
% removed, every image is dominated by offset plus row-structured fixed-pattern
% noise, and both the displayed picture and any ROI mean are meaningless.
%
% Heliotis' own c4DemodSimple.m removes the offset as I - mean(I,3) (per-pixel
% average over frames). That is CORRECT ONLY FOR THEIR DEMO, where the LED is
% detuned from the reference so I/Q rotate at a beat frequency and the temporal
% mean is pure offset. Here the reference is locked to PulseBlaster, so a real
% signal is CONSTANT across frames -- subtracting the frame mean would delete the
% signal along with the pedestal.
%
% The right removal for a locked measurement is a dark frame: same exposure,
% nPeriods, nFrames and readout, with the light blocked. Subtracting it per pixel
% removes the offset AND most of the fixed-pattern structure, since both are
% static.
%
% Usage:
%   1. Block the light / cap on. Run the sequence. Then:  hc_DarkRef('save')
%   2. Unblock. Run the sequence.
%   3. hc_ImageStats([], [], hc_DarkRef('load'))
%
% The dark frame is only valid for the settings it was taken with -- exposure,
% nPeriods and nFrames all scale the pedestal. Those settings are stored alongside
% it and hc_ImageStats warns on a mismatch.

    if nargin < 1 || isempty(mode); mode = 'load'; end
    if nargin < 2; pathOrData = ''; end

    switch lower(char(mode))
        case 'path'
            out = defaultPath(pathOrData);
            fprintf('[hc_DarkRef] %s\n', out);

        case 'save'
            p  = defaultPath(pathOrData);
            % hc_LoadIQ handles both the current I/Q fields and the legacy
            % reference/rawsignal ones, so this works on a gWide from either era.
            [gI, gQ] = hc_LoadIQ([], 'hc_DarkRef');
            j = firstValidSlice(gI);
            if isnan(j)
                error('hc_DarkRef: gWide contains no completed slice.');
            end

            % Stored as I/Q. Readers accept the old names too, so an existing
            % wf_darkref.mat keeps working without being recaptured.
            %
            % DIVIDED BY nFrames. gWide now holds frame SUMS, but a dark
            % reference is the pedestal of ONE frame -- that is what
            % AcquireDarkRef produces (mean(I,3)) and what the sweep subtracts
            % nF of. Storing the summed slice unscaled would make this dark
            % nFrames times too large, and it would fail silently: the run would
            % simply over-subtract. Falls back to storing unscaled if the frame
            % count was not recorded, with a warning, rather than guessing.
            dark = struct();
            dark.settings = captureSettings();
            nFdark = NaN;
            if isfield(dark.settings,'nFrames'); nFdark = dark.settings.nFrames; end
            if ~isfinite(nFdark) || nFdark < 1
                nFdark = 1;
                fprintf(2, ['[hc_DarkRef] WARNING: no nFrames recorded, so the ', ...
                            'frame-sum could not be converted to a per-frame ', ...
                            'pedestal. This dark may be nFrames times too large.\n']);
            end

            dark.I = double(gI(:,:,j)) / nFdark;
            if ~isempty(gQ)
                dark.Q = double(gQ(:,:,j)) / nFdark;
            end
            dark.frameReduction = 'mean';   % what this file holds: ONE frame's pedestal
            dark.slice    = j;

            d = fileparts(p);
            if ~isempty(d) && ~exist(d, 'dir'); mkdir(d); end
            save(p, '-struct', 'dark');
            fprintf('[hc_DarkRef] Saved dark reference (%dx%d, slice %d) to\n   %s\n', ...
                    size(dark.I,1), size(dark.I,2), j, p);
            describeSettings(dark.settings);
            out = dark;

        case 'import'
            % Promote an already-saved widefield .h5 to THE dark reference.
            % Settings come from the file's own attributes rather than the
            % current gmSEQ, so importing an old run cannot mislabel it with
            % whatever happens to be loaded in the GUI right now.
            if isempty(pathOrData) || ~(ischar(pathOrData) || isstring(pathOrData))
                error('hc_DarkRef: ''import'' needs a path to a widefield .h5.');
            end
            src = char(string(pathOrData));
            if ~isfile(src)
                error('hc_DarkRef: file not found: %s', src);
            end

            dark = struct();
            [hI, hQ] = hc_LoadIQ(src, 'hc_DarkRef');
            dark.I = double(hI(:,:,1));
            if ~isempty(hQ)
                dark.Q = double(hQ(:,:,1));
            end
            dark.settings = settingsFromH5(src);
            dark.slice    = 1;
            dark.source   = src;

            p = defaultPath('');
            d = fileparts(p);
            if ~isempty(d) && ~exist(d, 'dir'); mkdir(d); end
            save(p, '-struct', 'dark');
            fprintf('[hc_DarkRef] Imported %s\n   as dark reference (%dx%d) -> %s\n', ...
                    src, size(dark.I,1), size(dark.I,2), p);
            describeSettings(dark.settings);
            out = dark;

        case 'load'
            if isstruct(pathOrData); out = pathOrData; return; end
            p = defaultPath(pathOrData);
            if ~isfile(p)
                error(['hc_DarkRef: no dark reference at %s. Block the light, run ', ...
                       'the sequence, then hc_DarkRef(''save'').'], p);
            end
            out = load(p);
            fprintf('[hc_DarkRef] Loaded dark reference from %s\n', p);
            if isfield(out, 'settings'); describeSettings(out.settings); end

        case 'clear'
            p = defaultPath(pathOrData);
            if isfile(p)
                delete(p);
                fprintf('[hc_DarkRef] Deleted %s\n', p);
            else
                fprintf('[hc_DarkRef] Nothing to delete at %s\n', p);
            end
            out = [];

        otherwise
            error('hc_DarkRef: mode must be ''save'', ''load'', ''clear'' or ''path''.');
    end
end

% ---------------------------------------------------------------------------- %
function p = defaultPath(explicit)
    if ~isempty(explicit) && (ischar(explicit) || isstring(explicit))
        p = char(string(explicit));
        return
    end
    root = 'C:\Data';
    try
        global gSaveDataAve %#ok<GVMIS>
        if ~isempty(gSaveDataAve) && isfield(gSaveDataAve, 'path')
            % Parent of the dated folder, so one dark serves the whole day.
            base = regexprep(char(string(gSaveDataAve.path)), '[\\/]+$', '');
            up   = fileparts(base);
            if ~isempty(up); root = up; end
        end
    catch
    end
    p = fullfile(root, 'wf_darkref.mat');
end

% ---------------------------------------------------------------------------- %
function s = captureSettings()
% Record the settings the pedestal depends on, so a stale dark can be detected.
    s = struct('exposureSeconds', NaN, 'nPeriods', NaN, 'nFrames', NaN, ...
               'readout', NaN, 'sensitivity', NaN);
    try
        global gmSEQ %#ok<GVMIS>
        f = fieldnames(s);
        for i = 1:numel(f)
            if isfield(gmSEQ, f{i}) && ~isempty(gmSEQ.(f{i}))
                v = gmSEQ.(f{i});
                if isnumeric(v) && isscalar(v); s.(f{i}) = double(v); end
            end
        end
    catch
    end
end

% ---------------------------------------------------------------------------- %
function s = settingsFromH5(src)
% Same fields captureSettings() records, read back off a saved .h5 instead of
% the live gmSEQ. Scalars come from root attributes; readout/sensitivity fall
% back to params_json, which carries the full gmSEQ of that run.
    s = struct('exposureSeconds', NaN, 'nPeriods', NaN, 'nFrames', NaN, ...
               'readout', NaN, 'sensitivity', NaN);
    attrMap = {'exposureSeconds','exposure_s'; 'nPeriods','n_periods'; ...
               'nFrames','n_frames'; 'sensitivity','sensitivity'};
    for i = 1:size(attrMap,1)
        try
            s.(attrMap{i,1}) = double(h5readatt(src, '/', attrMap{i,2}));
        catch
        end
    end
    try
        j = jsondecode(char(h5readatt(src, '/', 'params_json')));
        f = fieldnames(s);
        for i = 1:numel(f)
            if isnan(s.(f{i})) && isfield(j, f{i}) && isscalar(j.(f{i})) && isnumeric(j.(f{i}))
                s.(f{i}) = double(j.(f{i}));
            end
        end
    catch
    end
end

% ---------------------------------------------------------------------------- %
function describeSettings(s)
    if ~isstruct(s); return; end
    fprintf('   settings: exposure %g s, nPeriods %g, nFrames %g, readout %g ns\n', ...
            s.exposureSeconds, s.nPeriods, s.nFrames, s.readout);
end

% ---------------------------------------------------------------------------- %
function gW = getGlobalWide()
    global gWide %#ok<GVMIS>
    gW = gWide;
end

% ---------------------------------------------------------------------------- %
function j = firstValidSlice(ref)
    j = NaN;
    for k = 1:size(ref, 3)
        sl = ref(:,:,k);
        if ~all(isnan(sl(:))); j = k; return; end
    end
end
