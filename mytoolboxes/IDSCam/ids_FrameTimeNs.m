function [tFrameNs, info] = ids_FrameTimeNs(widthPx, heightPx, pixelFormat, expoNs)
% ids_FrameTimeNs  Minimum frame period of the IDS uEye+ U3-3140CP-M (ns).
%
%   [tFrameNs, info] = ids_FrameTimeNs(widthPx, heightPx, pixelFormat, expoNs)
%
%   info .readoutNs  sensor readout floor
%        .linkNs     USB3 bandwidth floor
%        .exposeNs   exposure + turnaround
%        .bound      which of the three won: 'readout' | 'link' | 'exposure'
%        .maxRateHz  1/tFrameNs
%
% THE MODEL (CAMERA_FINDINGS.md sec.3, reproduces every measured ROI to ~1%)
%
%   T_frame = max( 115 us + H * (1.14 us + 3.45 ns * W)     sensor readout floor
%                  W * H * bytes / 391 MB/s                 USB3 link cap
%                  T_exp + 23 us )                          exposure + turnaround
%
% MEASURED ACCURACY (checked against all nine ROIs in findings sec.4.1)
%
%   1280x1024 +0.3%   1280x512 +0.2%   1280x256 +0.1%   1280x64 -0.3%
%    640x256  +0.2%    512x256 +0.5%    256x256 -3.5%   (Mono10)
%   1280x256  -0.2%   1280x64  +0.1%                    (Mono8)
%
% Eight of nine land inside 0.5%. The exception is 256x256, where the model
% UNDER-predicts the frame time by 3.5% -- i.e. it believes the camera is faster
% than it is, which is the unsafe direction for a rate check. The doc's claim of
% "~1%" was fitted against four ROIs, none of them 256 wide, so treat narrow
% ROIs as the model's weak spot.
%
% ids_BlockPlan's 90% rate ceiling covers a 3.5% error with room to spare, which
% is one more reason not to raise cfg.maxRateFraction: part of that headroom is
% paying for this model's error, not only for the sec.4.7 overrun band.
%
% THE 23 us IS THE REAL DEAD TIME, NOT 68 us
%
% The camera PIPELINES: exposure of frame N+1 overlaps readout of frame N, in
% free-run AND under external trigger, even though the TriggerOverlap node is
% absent entirely. So sweeping exposure at fixed ROI leaves the frame period
% completely FLAT until the exposure exceeds the readout floor -- 1280x256 sat
% at 1.540 ms from 49.7 us of exposure all the way to 1399.7 us, 28x the
% exposure, before the period moved at all.
%
% An earlier analysis reported ~68 us as "the fixed per-frame overhead", computed
% as T_frame - T_exp at MINIMUM exposure. That silently assumes serial operation.
% It is the correct intercept of the readout floor but it is NOT the operational
% dead time, and using it understates achievable duty badly. The only genuinely
% dead interval is 23 us, and it is ROI-independent (identical at H=64 and
% H=256) -- the global transfer + reset turnaround.
%
% Consequence for the block plan: extra exposure is FREE while you are below the
% readout floor, and above it the duty cycle exceeds 99%.

    if nargin < 3 || isempty(pixelFormat); pixelFormat = 'Mono8'; end
    if nargin < 4 || isempty(expoNs);      expoNs = 0;            end

    W = double(widthPx);
    H = double(heightPx);

    % Bytes per pixel on the wire. Mono10p is packed 10-bit (1.25 B/px); Mono10
    % is padded to 16 bits and so costs the same link bandwidth as a full 2 B/px.
    switch lower(strtrim(char(pixelFormat)))
        case 'mono8';   bpp = 1;
        case 'mono10p'; bpp = 1.25;
        case 'mono10';  bpp = 2;
        otherwise;      bpp = 2;      % unknown -> assume the expensive case
    end

    info = struct();
    info.readoutNs = 115000 + H * (1140 + 3.45 * W);
    info.linkNs    = W * H * bpp / 391e6 * 1e9;
    info.exposeNs  = expoNs + 23000;

    [tFrameNs, which] = max([info.readoutNs, info.linkNs, info.exposeNs]);

    switch which
        case 1; info.bound = 'readout';
        case 2; info.bound = 'link';
        case 3; info.bound = 'exposure';
    end

    info.maxRateHz = 1e9 / tFrameNs;
    info.deadNs    = 23000;
    info.bytesPerPx = bpp;
end
