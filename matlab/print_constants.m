classdef print_constants
    %PRINT_CONSTANTS
    % These are bit flags for the logging destination
    % e.g. to print to the consonle and server : 
    %   def_print = print_constants.SERVER_LOG + print_constants.CONSLOE
    %   log_print('Hello World',def_print)
    properties( Constant = true )
        NO_PRINT = 0;
        SERVER_LOG = 1; % send to remote server log
        CONSOLE = 2; % print to local console
        FILE = 4; % save to a local file
    end
end

