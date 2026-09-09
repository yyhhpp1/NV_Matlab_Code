classdef FakeIDSCamera < handle
% FakeIDSCamera  Hardware-free stand-in for IDSCamInterface.
%
% Same protocol, so the whole RunSequence_IDSCam path -- block planning, the
% sweep loop, dark subtraction, live display, HDF5 saving, averaging -- runs with
% no camera, no PulseBlaster and no Python. Set IDSConfig.useFakeCamera = true.
%
% Synthetic data follows this path's sign convention exactly, which is the point:
% both quadratures are POSITIVE raw-ADU images and nothing is negated anywhere.
%
%   I = reference frame (MW off)  = pedestal + blob
%   Q = signal frame    (MW on)   = pedestal + blob .* contrast
%
% so Q./I sits just under 1 and dips where the NV blob is, which is what the
% ids_* sequences ask the display to plot. A stub that copied the HeliCam's
% quadrature-difference convention would exercise the same code and produce a
% plot that looks nothing like real data.
%
% The dip is driven by gmSEQ.m, so a Rabi sweep gives a real oscillation on
% axes3 rather than a flat line -- enough to tell a working display from a
% broken one.

    properties (Access = public)
        Height (1,1) double = 256
        Width  (1,1) double = 1280
    end

    properties (Access = private)
        nPairs         = 10
        programSeconds = 4e-3
        blob                       % cached Gaussian blob (H x W), peak 1
        armed          = false
    end

    methods
        function obj = FakeIDSCamera(cfg)
            if nargin < 1 || isempty(cfg); cfg = IDSConfig(); end
            obj.Height = cfg.height;
            obj.Width  = cfg.width;
            fprintf('[FakeIDS] Synthetic camera created (%dx%d).\n', ...
                    obj.Height, obj.Width);
        end

        function configure(obj, cfg)
            obj.Height = double(cfg.height);
            obj.Width  = double(cfg.width);
            obj.nPairs = double(cfg.framePairs);
            if isfield(cfg,'programNs') && ~isempty(cfg.programNs)
                obj.programSeconds = double(cfg.programNs) * 1e-9;
            end
            obj.buildBlob();
            fprintf(['[FakeIDS] Configured: ROI %dx%d, exposure %g ns, %d SIG/REF ', ...
                     'pairs.\n'], obj.Width, obj.Height, ...
                    double(cfg.exposureNs), obj.nPairs);
        end

        function configLockInMode(obj, cfg)
            obj.configure(cfg);
        end

        function startAcq(obj)
            obj.armed = true;
        end

        function [I, Q] = readIQ(obj, ~)
        % Synthetic burst: H x W x nPairs for each of signal and reference.
            global gmSEQ %#ok<GVMIS>

            if ~obj.armed
                error('FakeIDSCamera:NotArmed', 'readIQ before startAcq.');
            end
            if isempty(obj.blob); obj.buildBlob(); end

            m = 0;
            if ~isempty(gmSEQ) && isfield(gmSEQ,'m') && ~isempty(gmSEQ.m)
                m = double(gmSEQ.m);
            end

            % A Rabi-like contrast dip, so the axes3 trace has structure.
            period = 120;  decay = 600;
            rabi   = 0.5 * (1 - cos(2*pi*m/period)) * exp(-m/decay);
            dip    = 0.25;
            contrastMap = 1 - dip * rabi * obj.blob;

            % Photons and pedestal are kept SEPARATE, because only one of them
            % is noisy in the way that matters. Shot noise scales as sqrt of the
            % PHOTON count; the pedestal is a dark offset that carries only read
            % noise. Lumping them together (sqrt of pedestal + photons) makes the
            % unlit background far noisier than a real frame, and since Q./I is
            % a ratio of two such numbers, the synthetic contrast map then looks
            % violently noisy exactly where a real one is quietest -- which
            % misrepresents what the display is supposed to show.
            pedestal  = 120;      % dark offset; no BlackLevel node on this sensor
            readNoise = 3;        % ADU rms, roughly flat
            photons   = 4000 * obj.blob;

            n = obj.nPairs;
            I = zeros(obj.Height, obj.Width, n);
            Q = zeros(obj.Height, obj.Width, n);
            for k = 1:n
                pRef = photons;
                pSig = photons .* contrastMap;
                I(:,:,k) = pedestal + pRef + sqrt(max(pRef,0)) .* obj.randn2() ...
                                           + readNoise * obj.randn2();
                Q(:,:,k) = pedestal + pSig + sqrt(max(pSig,0)) .* obj.randn2() ...
                                           + readNoise * obj.randn2();
            end
        end

        function stopAcq(obj)
            obj.armed = false;
        end

        function f = readActualRefFrequency(obj)
            f = 1 / obj.programSeconds;
        end

        function s = lastStatus(~)
            s = struct('ok', true, 'n_got', NaN, 'missed_triggers', 0, ...
                       'frame_id_gaps', 0, 'incomplete_buffers', 0);
        end

        function delete(~)
        end
    end

    methods (Access = private)
        function r = randn2(obj)
            r = randn(obj.Height, obj.Width);
        end

        function buildBlob(obj)
            [X, Y] = meshgrid(1:obj.Width, 1:obj.Height);
            x0 = obj.Width/2;  y0 = obj.Height/2;
            sig = min(obj.Height, obj.Width) / 5;
            obj.blob = exp(-((X - x0).^2 + (Y - y0).^2) / (2 * sig^2));
        end
    end
end
