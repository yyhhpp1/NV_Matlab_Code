function ids_Image
% ids_Image  Simplest IDS widefield acquisition: a plain intensity image.
%
% No microwaves at all, so the SIG and REF blocks are IDENTICAL and
%   I = reference frame,  Q = signal frame,  Q./I = 1 everywhere but for noise.
%
% That is the point. Use it to focus, align and check exposure before running
% ids_Rabi / ids_T1 / ids_ODMR, and to verify the trigger architecture end to
% end: if two frames come back per PB run and their ratio is flat at 1, the
% block pair, the trigger line and the SIG/REF pairing are all working.
%
% Displays I (a raw camera image) rather than Q./I, because a flat ratio tells
% you nothing about focus.
%
% The sweep parameter is inert here -- set sweep N = 1 for a single image.
% N > 1 just repeats the same acquisition, which is a legitimate way to look at
% frame-to-frame stability but is not a scan of anything.

global gmSEQ gSG
gSG.bfixedPow  = 1;
gSG.bfixedFreq = 1;
gSG.bMod       = 'LOL';        % no modulation
gSG.bModSrc    = 'External';

[gmSEQ.ScaleT, gmSEQ.ScaleStr] = GetScale(gmSEQ.To);

% Seeds the 'WFcontrast' GUI box when this sequence is selected; edit the box
% (even mid-run) to plot something else.
gmSEQ.WFcontrastExpr = 'I';

cfg = IDSConfig();

% No MW in either block.
ids_BuildBlocks(cfg, [], []);

ApplyDelays();
end
