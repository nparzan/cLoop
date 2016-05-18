%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function implements a basic closed loop, with a simple design
% We start with a tamplate of ZERO stimulation, we read the EEG
% activity and we stimulate according to the thata band levels.
%
% We assume channel 1 is the tACS stimulation channel
%
% Input:
% templateName: Name of the template to be loaded on NIC.
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
% theta: the theta activity before each stimulation
%
% delta: the differences between the activity after every stimulation
%
%
% Known issues: None
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ret, theta, delta] = cLoopSimpleDesign (templateName)

addpath(genpath('MatNIC_v2.5'));

%%%%%%%%%%%%%%%%%%%%%%%%%
% Veriables Definitions %
%%%%%%%%%%%%%%%%%%%%%%%%%

ret = 0;
isStimulating = false;
initTime = 0;
channelToStim = 1;
transitionToPeak = 5000;
transitionFromPeak = 5000;
host = 'localhost';

% Constants
tACS_Freq = 10000; % unused here for now, handeled in the tamplate
restingPeriod = 10; % time between stimulation and the next EEG record 

% Learned veriables - default values
LV.stimLength = 1000; % Ms
LV.EEGLength = 10; % seconds
LV.stimAmp = 0;

% the next vars are just for Tal. to be deleted later
theta_col = 2;
EEGChannel = 4;
maxNumOfStim = 20;
numOfStim = 0; 
theta = zeros(10,1);
delta = zeros(10,1); 

%%%%%%%%%%%%%%%%%
% Function Body %
%%%%%%%%%%%%%%%%%

% If nothing is entered then we load our basic empty template

if ~exist('templateName','var') || isempty(templateName)
  templateName='Tutorial_Example';

% Connect to NIC Software

[ret, status, sock] = MatNICConnect(host);

if (ret < 0)
    disp('ERROR: Failed on connecting to server')
    return
end
disp('INFO: Connection to server succesful!')

% Load template

disp(sprintf('INFO: Proceeding to load template %s ...',templateName) )
ret = MatNICLoadTemplate(templateName, sock);
if (ret < 0)
    disp('ERROR: Load template failed')
    return
end
disp('INFO: Load template successful!')



% Launch stimulation section with EMPTY tamplate

while (1)
    [ret, status] = MatNICQueryStatus(sock);    
    if (ret < 0)
        return
    end
    switch status
        % Template loaded
        case 'CODE_STATUS_TEMPLATE_LOADED'
            disp('INFO: Template was found and loaded!');
        % Request for user confirmation
        case 'CODE_STATUS_STIMULATION_READY'
            disp('System is ready for stimulation');
            if isStimulating == false
                ret = MatNICStartStimulation(sock);
                pause(1);
                if ret == 0
                    initTime = clock;
                else
                    disp('Start stimulating failed');
                end
                break;
            end
    end
end

% Main loop, reading EEG, analyzing and stimulating. 

while (numOfStim < maxNumOfStim)
    
    EEG = getEEG(LV.EEGLength,8,host);
    
    % Prints of the current activity and delta, will be removed
    numOfStim = numOfStim+1;
    theta(numOfStim) = EEG.Activities(EEGChannel,theta_col);
    if (numOfStim > 1)
        delta(numOfStim) = theta(numOfStim) - theta(numOfStim-1);
        delta(numOfStim)
    end
    
    LV = getLearnedVarsFromServer(EEG);
    
    [ret, status] = MatNICQueryStatus(sock); 
    if (ret < 0)
        break
    end
    
    switch status
        % Stimulation in progress
		case 'CODE_STATUS_STIMULATION_RAMPUP'
            
			disp(sprintf('* Stimulation performing ramp up. Ellapsed %f sec', etime(clock, initTime) ))
            
        case 'CODE_STATUS_STIMULATION_FULL'
            
            disp(sprintf('* Stimulation started. Ellapsed %f sec', etime(clock, initTime) ))
            
            % stimulate with the learned parameters
            if(LV.stimAmp > 0)
                ret = MatNICOnlineAtacsPeak(LV.stimAmp, channelToStim, ...
                                        transitionToPeak, LV.stimLength, ...
                                        transitionFromPeak, sock);                   
                if (ret < 0)
                    break
                end
                % Wait for the learned amount of time
                pause(restingPeriod);
            end
            
            
		case 'CODE_STATUS_STIMULATION_RAMPDOWN'
            
			disp(sprintf('* Stimulation performing ramp down. Ellapsed %f sec', etime(clock, initTime) ))
            
        case 'CODE_STATUS_STIMULATION_FINISHED'
            
            disp('* Stimulation finished')
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

abort_rt = MatNICAbortStimulation(sock);
 
if (abort_rt < 0)
    disp('Abort stimulation failed')
end

end