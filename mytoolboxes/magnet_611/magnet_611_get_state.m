function data = magnet_611_get_state(tcp)

data = char(writeread(tcp, "STATE?"));

end

%  meaning of the state code

% 1 RAMPING to target field/current
% 
% 2 HOLDING at the target field/current
% 
% 3 PAUSED
% 
% 4 Ramping in MANUAL UP mode
% 
% 5 Ramping in MANUAL DOWN mode
% 
% 6 ZEROING CURRENT (in progress)
% 
% 7 Quench detected
% 
% 8 At ZERO current
% 
% 9 Heating persistent switch
% 
% 10 Cooling persistent switch
% 
% 11 External Rampdown active



