%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MatNICTutorial
%
% This function implements an interactive client to connect to the NIC 
% Software. The MatNICTutorial script performs the following actions:
%
%  [1] Check that parameters are passed properly ['templateName', 'host']
%  [2] Start a MatNIC session with NIC Software running in 'host'
%  [3] Load stimulation template
%  [4] Obtain the current status of NIC until template is loaded
%  (i.e. CODE_STATUS_STIMULATION_READY)
%  [5] Request for user confirmation and start stimulation
%  [6] Notify user about stimulation progress
%  [7] When stimulation finished request user to stimulate again or abort
%  script
%
%  Check for those signatures in the following script for further
%  description on the calls
%
% The following are the functions of MatNIC to connect, send the commands 
% to the server and read the status the server sends:
% - MatNICConnect
% - MatNICConnectQueryStatus
% - MatNICConnectLoadTemplate
% - MatNICConnectOnlineFreqChange
% - MatNICConnectStartStimulation
% - MatNICConnectAbortStimulation
% - MatNICConnectStartEEG
% - MatNICConnectStopEEG
% - MatNICConnectOnlineAtdcsChange
% - MatNICConnectOnlineAtacsChange
% - MatNICConnectOnlineFtacsChange
% - MatNICConnectOnlinePtacsChange
% - MatNICConnectOnlineAtrnsChange
% - MatNICConnectEnableTRNSFilter
%
%
% Input:
% templateName: Name of the template to be loaded on NIC.
% host: Name or IP of the host where NIC is running.
%
% Output:
% ret: Zero or positive number if the function completes successfully. A
% negative number otherwise:
% -1: The connection to the host and port number did not succeed.
% -2: Error writing template name.
% -3: Error reading from server.
% -4: Template not loaded.
% -5: Error writing command to the server.
%
% Author: Javier Acedo (javier.acedo@starlab.es)
%         Sergi Torrellas (sergi.torrellas@neuroelectrics.com)
% Company: Neuroelectrics
% Created: 16 Jan 2013
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = TestEEG (templateName, host)

ret = 0;
seconds=120;
channels=3;

% Verify correctness of the parameters [1]
if ~exist('templateName','var') || isempty(templateName)
  templateName='defaultTemplate';
end
if ~exist('host','var') || isempty(host)
  host='localhost';
end

% Connect to NIC Software [2]
[ret, status, sock] = MatNICConnect(host);
if (ret < 0)
    disp('ERROR: Failed on connecting to server')
    return
end
disp('INFO: Connection to server succesful!')

% Load template [3]
disp(sprintf('INFO: Proceeding to load template %s ...',templateName) )
ret = MatNICLoadTemplate(templateName, sock);
if (ret < 0)
    disp('ERROR: Load template failed')
    return
end
disp('INFO: Load template successful!')



%[r] = MatNICStartEEG('TestPatient',1,1,sock)
r = 0;
if r == 0
    disp('Starting stimulation')
    [r] = MatNICStartStimulation(sock)
end

disp('INFO: Recording started')     
A=MatNICEEGRecord(seconds, channels, host);
disp('INFO: Recording finished')
pause(3)
%MatNICStopEEG (sock)

ret = MatNICAbortStimulation(sock);
[Rows,Columns]=size(A);
n=(1:1:Rows);
plot(n,A(:,1)/1e3)
[ret,status]=MatNICQueryStatus(sock);
disp(status);
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% confirmStartStimulation
%
% This function wait for confirmation from the user
%
% Input:
% sock : socket for connecting to NIC
%
% Output:
% ret : 0 on user asked for start stimulation, -1 otherwise
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = confirmStartStimulation(sock) 
	isThereInputFromUser = false;
    ret = 0;
    while ~isThereInputFromUser
        userInput = input(['Start stimulation / Abort? ', ...
                            'Y/A [Y]: '], 's');
        if( length(userInput) ~= 1)
            disp(['ERROR: UserInput NOT correct -> "', userInput, '"'])
            continue
        end                        
        if isempty(userInput)
            userInput = 'Y';
        end
        if (userInput == 'Y' || userInput == 'y' || ...
                    userInput == 'A' || userInput == 'a')
            isThereInputFromUser = true;
        end
        if (userInput == 'Y' || userInput == 'y')
            ret = MatNICStartStimulation(sock);
            if (ret < 0)
                ret = -1;
                return
            end
        else
            ret = -1;
        end
    end
end 

