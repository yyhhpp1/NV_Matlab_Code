function data = magnet_611_check_error(tcp)

data = char(writeread(tcp,"SYST:ERR?"));
end