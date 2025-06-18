function data = magnet_611_get_PS(tcp)

data = char(writeread(tcp, "PS?"));
end