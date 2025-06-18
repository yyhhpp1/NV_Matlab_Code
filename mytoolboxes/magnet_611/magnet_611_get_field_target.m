function data = magnet_611_get_field_target(tcp)

data = char(writeread(tcp,"FIELD:TARGet?"));

end