function out = hc_DarkRef(mode, pathOrData)
% out = hc_DarkRef(mode, pathOrData)  Capture / load a per-pixel DARK REFERENCE.
%
%   hc_DarkRef('save')          store the current gWide as the dark reference
%   hc_DarkRef('save', path)    ... to an explicit .mat path
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
            gW = getGlobalWide();
            if isempty(gW) || ~isfield(gW, 'reference')
                error('hc_DarkRef: global gWide has no data to store as dark.');
            end
            j = firstValidSlice(gW.reference);
            if isnan(j)
                error('hc_DarkRef: gWide contains no completed slice.');
            end

            dark = struct();
            dark.reference = double(gW.reference(:,:,j));
            if isfield(gW, 'rawsignal')
                dark.rawsignal = double(gW.rawsignal(:,:,j));
            end
            dark.settings = captureSettings();
            dark.slice    = j;

            d = fileparts(p);
            if ~isempty(d) && ~exist(d, 'dir'); mkdir(d); end
            save(p, '-struct', 'dark');
            fprintf('[hc_DarkRef] Saved dark reference (%dx%d, slice %d) to\n   %s\n', ...
                    size(dark.reference,1), size(dark.reference,2), j, p);
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
