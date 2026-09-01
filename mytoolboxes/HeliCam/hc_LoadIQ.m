function [I, Q, label, legacy] = hc_LoadIQ(src, caller)
% hc_LoadIQ(src, caller)  Load a widefield I/Q stack from gWide or a saved .h5.
%
%   [I, Q, label, legacy] = hc_LoadIQ(src, caller)
%     src    : [] or omitted -> the live global gWide; else a path to a .h5
%              written by SaveWidefield; or a struct in gWide's shape
%     caller : name used in error messages
%     I, Q   : H x W x N doubles. Q is [] when the source has no Q.
%     label  : human-readable description of where the data came from
%     legacy : true if the source used the pre-rename field/dataset names
%
% ONE place understands where the quadratures live, so every consumer
% (hc_ImageStats, hc_FindStride, hc_FocusCompare, hc_DarkRef) reads them the
% same way and only this file has to know about the rename.
%
% BACKWARD COMPATIBILITY. The quadratures used to be called 'reference' (I) and
% 'rawsignal' (Q) -- names that described neither what they were nor how raw they
% were, since both are equally frame-averaged, dark-subtracted and
% polarity-corrected. They are now simply I and Q. Files and dark references
% written before that change still carry the old names, so both spellings are
% accepted here forever: renaming a convention must not orphan data already on
% disk. New files only ever get /I and /Q.

if nargin < 2 || isempty(caller); caller = 'hc_LoadIQ'; end

I = []; Q = []; legacy = false;

% --- live gWide (or a struct in its shape) ---------------------------------
if nargin < 1 || isempty(src) || isstruct(src)
    if nargin >= 1 && isstruct(src)
        gW    = src;
        label = 'supplied struct';
    else
        global gWide   %#ok<TLEV>
        gW    = gWide;
        label = 'live gWide';
    end

    if isempty(gW) || ~isstruct(gW)
        error('%s: no widefield data in memory. Pass a path to a saved .h5.', caller);
    end
    if isfield(gW, 'I')
        I = gW.I;
        if isfield(gW, 'Q'); Q = gW.Q; end
    elseif isfield(gW, 'reference')
        legacy = true;
        I = gW.reference;
        if isfield(gW, 'rawsignal'); Q = gW.rawsignal; end
    else
        error('%s: %s has no I (or legacy reference) data yet.', caller, label);
    end
    I = double(I);
    if ~isempty(Q); Q = double(Q); end
    return;
end

% --- saved .h5 ------------------------------------------------------------
p = char(string(src));
if ~isfile(p)
    error('%s: file not found: %s', caller, p);
end
label = p;

try
    I = double(h5read(p, '/I'));
catch
    try
        I = double(h5read(p, '/reference'));   % pre-rename file
        legacy = true;
    catch
        error(['%s: %s has neither /I nor the legacy /reference dataset -- ', ...
               'not a widefield file?'], caller, p);
    end
end

qName = '/Q';
if legacy; qName = '/rawsignal'; end
try
    Q = double(h5read(p, qName));
catch
    % An I-only file is legitimate (some dark references are), so this is not an
    % error. Try the other spelling too before giving up, in case a file was
    % written across the rename.
    try
        if legacy; Q = double(h5read(p, '/Q')); else; Q = double(h5read(p, '/rawsignal')); end
    catch
        Q = [];
    end
end
end
