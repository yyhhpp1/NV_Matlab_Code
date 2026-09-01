classdef FakeCamera < handle
% FakeCamera  Hardware-free stand-in for HeliCamInterface.
%
% Implements the same camera protocol so the full RunSequence HeliCam branch,
% live plotting and saving can be exercised with no camera attached:
%   configLockInMode(cfg) / startAcq() / [I,Q]=readIQ(timeoutMs) / stopAcq()
%   f = readActualRefFrequency()
%
% Synthetic data: a Gaussian bright "NV ensemble" blob on a baseline. The blob's
% contrast dips as a function of the current sweep value gmSEQ.m, giving a
% visible 2D image AND a meaningful ROI-vs-sweep trace (a decaying Rabi-like
% oscillation). Matches HeliCamInterface's I/Q sign convention:
%   reference = mean(I, 3);  signal = mean(Q, 3);  contrast = signal ./ reference.
% No extra minus sign -- readIQ returns already sign-corrected I/Q on the real
% camera, so this one must too (see HeliCamInterface's header).

    properties (Access = public)
        Height (1,1) double = 512
        Width  (1,1) double = 542
    end

    properties (Access = private)
        nFrames    = 60
        actualFreq = 1e4
        blob                 % cached Gaussian blob (H x W)
    end

    methods
        function obj = FakeCamera(cfg)
        % FakeCamera(cfg)  cfg optional; uses WidefieldConfig defaults otherwise.
            if nargin < 1 || isempty(cfg); cfg = WidefieldConfig(); end
            obj.Height = cfg.height;
            obj.Width  = cfg.width;
            fprintf('[FakeCamera] Synthetic camera created (%dx%d).\n', obj.Height, obj.Width);
        end

        function configLockInMode(obj, cfg)
            obj.nFrames = cfg.nFrames;
            [fRef, ~, tExp] = HeliCamInterface.exposureToReferenceFrequency( ...
                cfg.exposureSeconds, cfg.sensitivity);
            obj.actualFreq = fRef;
            obj.buildBlob();
            fprintf('[FakeCamera] Lock-in configured: exposure %.3g s, f_ref %.1f Hz, %d frames.\n', ...
                    tExp, fRef, obj.nFrames);
        end

        function startAcq(~)
            % no-op for the fake camera
        end

        function [I, Q] = readIQ(obj, ~)
        % Return synthetic I/Q stacks double(Height, Width, nFrames).
            global gmSEQ %#ok<GVMIS>

            if isempty(obj.blob); obj.buildBlob(); end

            % Current sweep value -> contrast model.
            m = 0;
            if ~isempty(gmSEQ) && isfield(gmSEQ, 'm') && ~isempty(gmSEQ.m); m = double(gmSEQ.m); end
            period = 120;  decay = 600;                 % arbitrary "ns" scales
            rabi   = 0.5 * (1 - cos(2*pi*m/period)) * exp(-m/decay);
            dipDepth = 0.25;                            % peak contrast dip
            contrastMap = 1 - dipDepth * rabi * obj.blob;   % ~1 off-blob, dips on-blob

            baseline  = 200;
            brightAmp = 3000;
            ref2D = baseline + brightAmp * obj.blob;    % bright reference image

            nf = obj.nFrames;
            I = zeros(obj.Height, obj.Width, nf);
            Q = zeros(obj.Height, obj.Width, nf);
            noise = 0.02;                               % fractional per-frame noise
            for k = 1:nf
                If = ref2D .* (1 + noise * obj.randn2());
                I(:,:,k) = If;
                % signal = ref .* contrastMap;  convention signal = -mean(Q) => Q = -signal
                Q(:,:,k) = -(If .* contrastMap);
            end
        end

        function stopAcq(~)
            % no-op
        end

        function f = readActualRefFrequency(obj)
            f = obj.actualFreq;
        end

        function delete(~)
            % nothing to release
        end
    end

    methods (Access = private)
        function buildBlob(obj)
        % Normalized Gaussian blob (peak 1) centered in the frame.
            [X, Y] = meshgrid(1:obj.Width, 1:obj.Height);
            x0 = obj.Width/2;  y0 = obj.Height/2;
            sig = min(obj.Height, obj.Width) / 6;
            obj.blob = exp(-((X - x0).^2 + (Y - y0).^2) / (2 * sig^2));
        end

        function r = randn2(obj)
            r = randn(obj.Height, obj.Width);
        end
    end
end
