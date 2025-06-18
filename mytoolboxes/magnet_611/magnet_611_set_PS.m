function magnet_611_set_PS(tcp, state)

    cmd = sprintf("PS %g", state);
    writeline(tcp, cmd);
end
