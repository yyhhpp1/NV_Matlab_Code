function w = hc_CamRefWidth(cfg, Q)
% w = hc_CamRefWidth(cfg, Q)  CamRef TTL pulse width in ns for a quarter bin Q.
%
% The camera locks to reference EDGES, so in principle a narrow spike suffices.
% In practice a digital input has a minimum pulse width it will register: it is
% sampled or filtered internally, and a pulse shorter than that period can be
% missed entirely. A 100 ns pulse inside a 100 us bin is 0.1% duty and sits right
% at the edge of what a GigE camera input is likely to catch -- and a reference
% train the camera silently ignores looks exactly like a readIQ timeout with no
% data, which is indistinguishable from bad wiring.
%
% So default to a ~50% duty square wave (Q/2), the conventional way to feed an
% external lock-in reference. Edge positions -- the only thing that sets the
% quarter boundaries -- are unchanged by the width.
%
% cfg.camRefWidthNs = [] (or absent) -> auto, Q/2.
% An explicit value is honoured but CLAMPED to Q/2, because a pulse wider than
% half the bin risks still being high when the next quarter edge is due, which
% would destroy the train rather than merely mistime it.

    w = [];
    if isfield(cfg, 'camRefWidthNs')
        w = cfg.camRefWidthNs;
    end

    if isempty(w)
        w = Q / 2;                  % auto: 50% duty
    end

    w = min(w, Q / 2);              % never encroach on the next quarter
    w = max(w, 12);                 % PulseBlaster minimum instruction length (ns)
end
