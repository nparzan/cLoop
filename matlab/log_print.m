function [ret] = log_print(str, dest, file)
% This function send to the loger all the relevant data
% it is also optional to print the log into the local console  
%
% input arguments:
%   str - string to be loged (printed)
%   dest - the destination for the print (log,local console,local file)
%   this is a bitflag - log/console/file
%    
% output:
%   ret < 0 for failure, otherwise 0.

ret = 0;

% log flag is on
if bitand(dest,1)
    send_to_log(str);
end

% console print flag is on
if bitand(dest,2)
    disp(str);
end

% file flag is on
if bitand(dest,4)
    fileID = fopen(file,'a'); % a -> apend
    fprintf(fileID,str);
    fclose(fileID);
end

end
