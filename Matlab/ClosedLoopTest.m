%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ClosedLoopTest Comments are OUTDATED!
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
%
%
%
%
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret] = ClosedLoopTest (templateName)

ret = 0;

% If nothing is entered then we load our basic empty template[1]
if ~exist('templateName','var') || isempty(templateName)
  templateName='Tutorial_Example';

host=get_ip();


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



% Launch stimulation section
isStimulating = false;
initTime = clock;
while (1)
    [ret, status] = MatNICQueryStatus(sock);    
    if (ret < 0)
        return
    end
    switch status
        % Template loaded[4]
        case 'CODE_STATUS_TEMPLATE_LOADED'
            disp('INFO: Template was found and loaded!');
        % Request for user confirmation [5], [7]
        case 'CODE_STATUS_STIMULATION_READY'
            disp('System is ready for stimulation');
            if isStimulating == false
                ret = MatNICStartStimulation(sock);
                pause(1);
                if ret == 0
                    isStimulating = true;
                    initTime = clock;
                else
                    disp('Start stimulating failed');
                end
                break;
            end
    end
end

while (isStimulating)
    EEG = getEEG(10,3,host);
    Stm = getStimulation(EEG);
    [ret, status] = MatNICQueryStatus(sock);    
    if (ret < 0)
        return
    end
    switch status
        % Stimulation in progress [6]
		case 'CODE_STATUS_STIMULATION_RAMPUP'
			disp(sprintf('* Stimulation performing ramp up. Ellapsed %f sec', etime(clock, initTime) ))
        case 'CODE_STATUS_STIMULATION_FULL'
            
            disp(sprintf('* Stimulation started. Ellapsed %f sec', etime(clock, initTime) ))
            if strcmp(Stm.Function,'MatNICOnlineAtdcsPeak')
                ret = MatNICOnlineAtdcsPeak(Stm.amplitudeArray, Stm.channelArray, ...
                                        Stm.transitionToPeak, Stm.transitionStay, ...
                                        Stm.transitionFromPeak, sock)
            end
            pause(3);
            %break;
            
		case 'CODE_STATUS_STIMULATION_RAMPDOWN'
			disp(sprintf('* Stimulation performing ramp down. Ellapsed %f sec', etime(clock, initTime) ))
        case 'CODE_STATUS_STIMULATION_FINISHED'
            disp('* Stimulation finished')
            isStimulating = false;
            break;
        case 'CODE_STATUS_EEG_OFF'
            disp('* EEG streaming is off');
        case 'CODE_STATUS_EEG_ON'
            disp('* EEG streaming is on');
        otherwise
            disp(['Unexpected status received , Aborting', status]);
            break;
    end
end

% Abort Stimulation
ret = MatNICAbortStimulation(sock);
    
end