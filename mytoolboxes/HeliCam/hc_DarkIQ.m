function [dI, dQ, legacy] = hc_DarkIQ(D)
% hc_DarkIQ(D)  Pull the I and Q dark frames out of a stored dark-reference struct.
%
%   [dI, dQ, legacy] = hc_DarkIQ(D)
%     D      : struct loaded from wf_darkref.mat (hc_DarkRef('load'))
%     dI, dQ : the dark frames, or [] when absent
%     legacy : true if D used the pre-rename field names
%
% Same reason as hc_LoadIQ: dark references saved before the rename carry
% 'reference'/'rawsignal' instead of 'I'/'Q', and a dark file is exactly the kind
% of thing that sits on disk for months. Both spellings stay readable.

dI = []; dQ = []; legacy = false;
if isempty(D) || ~isstruct(D); return; end

if isfield(D, 'I')
    dI = D.I;
    if isfield(D, 'Q'); dQ = D.Q; end
elseif isfield(D, 'reference')
    legacy = true;
    dI = D.reference;
    if isfield(D, 'rawsignal'); dQ = D.rawsignal; end
end
if ~isempty(dI); dI = double(dI); end
if ~isempty(dQ); dQ = double(dQ); end
end
