function w = hc_CamRefWidth(cfg, Q, wWanted)
% w = hc_CamRefWidth(cfg, Q, wWanted)  CamRef TTL pulse width in ns for quarter bin Q.
%
%   cfg     : WidefieldConfig struct (cfg.camRefWidthNs is the configured width)
%   Q       : quarter period in ns
%   wWanted : OPTIONAL explicit width the caller wants, e.g. gmSEQ.CtrGateDur.
%             Takes precedence over cfg.camRefWidthNs. This is how the pulsed
%             sequences keep control of the width while still getting the clamp.
%
% The camera locks to reference EDGES, so in principle a narrow spike suffices.
% In practice a digital input has a minimum pulse width it will register: it is
% sampled or filtered internally, and a pulse shorter than that period can be
% missed entirely. A 100 ns pulse inside a 100 us bin is 0.1% duty and sits right
% at the edge of what a GigE camera input is likely to catch -- and a reference
% train the camera silently ignores looks exactly like a readIQ timeout with no
% data, which is indistinguishable from bad wiring.
%
% So with nothing specified, default to a ~50% duty square wave (Q/2), the
% conventional way to feed an external lock-in reference. Edge positions -- the
% only thing that sets the quarter boundaries -- are unchanged by the width.
%
% THE CLAMP, AND WHY IT IS NOT NEGOTIABLE
%
% Any requested width is honoured up to Q/2 and clamped there. Not a style
% preference -- arithmetic. The four pulses sit at 0, Q, 2Q, 3Q, so a width of Q
% or more means the line is still high when the next pulse begins: there is no
% falling edge between them, so there is no rising edge either. PB emits ONE
% rising edge per period instead of four, the camera gets a quarter of the edges
% it is waiting for, and readIQ times out with "no data available" -- with the
% pulse diagram on axes1 looking perfectly reasonable, because the edges are
% where they should be; it is the gaps that are missing.
%
% This is easy to hit precisely because the attractive setting is the fatal one.
% In every sequence except hc_Image/hc_ZScan, CtrGateDur is ALSO the camera
% exposure source (RunSequence_HeliCam), and the natural choice for maximum light
% is to integrate the whole quarter -- CtrGateDur ~ Q. That is exactly the value
% that destroys the reference train. Below Q/2 the two roles coexist happily.
%
% Clamping is reported (once per distinct request) rather than done silently: a
% width you asked for and did not get is worth knowing about, and the previous
% behaviour of not clamping at all cost a run to diagnose.

persistent lastNote
if isempty(lastNote); lastNote = ''; end

    w = [];
    if nargin >= 3 && ~isempty(wWanted) && isfinite(wWanted) && wWanted > 0
        w = wWanted;                        % caller's explicit request wins
    elseif isfield(cfg, 'camRefWidthNs')
        w = cfg.camRefWidthNs;
    end

    if isempty(w) || ~isfinite(w) || w <= 0
        w = Q / 2;                          % auto: 50% duty
    end

    wAsked = w;
    w = min(w, Q / 2);                      % never encroach on the next quarter
    w = max(w, 12);                         % PulseBlaster minimum instruction length (ns)

    if wAsked > Q / 2
        note = sprintf('%g|%g', wAsked, Q);
        if ~strcmp(note, lastNote)
            fprintf(2, ['[Widefield] CamRef width %g ns exceeds half the quarter bin ', ...
                        '(Q/2 = %g ns) and was clamped to %g ns. At %g ns the four ', ...
                        'reference pulses would have run together, leaving 1 rising ', ...
                        'edge per period instead of 4 and starving the camera. Lower ', ...
                        'CtrGateDur below Q/2 to choose the width yourself.\n'], ...
                    wAsked, Q/2, w, wAsked);
            lastNote = note;
        end
    end
end
