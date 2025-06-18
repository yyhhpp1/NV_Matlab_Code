function magnet_611_set_field_target(tcp, field_val)

    cmd = sprintf("CONFigure:FIELD:TARGet %g", field_val);

    writeline(tcp, cmd);
end 