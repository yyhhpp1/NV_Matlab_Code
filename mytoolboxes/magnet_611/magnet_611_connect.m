function [t]=magnet_611_connect(IP, port)

t = tcpclient(IP, port);
t.Timeout = 3;
end

