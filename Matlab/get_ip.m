function [ip] = get_ip()
[status, cmdout ] = system('ipconfig');
if status < 0
    disp('Cannot find device IP');
    ip = -1;
    return;
else
    k =  strfind(cmdout,'Ethernet adapter Bluetooth Network Connection');
    cmdout = cmdout(k:k+400);
    k = strfind(cmdout,'Autoconfiguration IPv4 Address. . :');
    ip = cmdout(k +36:k+48);
end
end