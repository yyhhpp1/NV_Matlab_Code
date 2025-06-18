function magnet_611_set_ramp_rate(tcp, rate)

% set field ramp rate  <segment 1>, <rate kG/min>, <limit kG>
cmd = sprintf("CONF:RAMP:RATE:FIELD 1,%g,10", rate);
writeline(tcp, cmd);

end