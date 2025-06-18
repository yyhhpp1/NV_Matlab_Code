function magnet_611_set_field_unit(tcp, unit)

if strcmp(unit, "kG")
    writeline(tcp,"CONF:FIELD:UNITS 0");    % 0 is kG, 1 is T

elseif strcmp(unit, "T")
    writeline(tcp,"CONF:FIELD:UNITS 1");    % 0 is kG, 1 is T
else
    disp("Unit must be kG/T")
end

end