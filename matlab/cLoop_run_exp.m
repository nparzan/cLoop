%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% This function implements a basic closed loop, with a simple design
% We start with a tamplate of ZERO stimulation, we read the EEG
% activity and we stimulate according to the thata band levels.
%
% We assume channel 7 is the tACS stimulation channel, 8 is the reciever
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
function [ret, start_eeg, end_eeg] = cLoop_run_exp (templateName)

addpath(genpath('MatNIC_v2.5'));

%%%%%%%%%%%%%%%%%%%%%%%%%
% Veriables Definitions %
%%%%%%%%%%%%%%%%%%%%%%%%%

ret = 0;
isStimulating = false;
initTime = 0;
channelToStim = 7;

host = 'localhost';

optimal_activity = zeros(1,5);

% Constants

print_constants;

TRANSITION_TO_PEAK = 5000; % mS
TRANSITION_FROM_PEAK = 5000; % mS

START_EEG_LENGTH = 60*5; % seconds
OPT_EEG_LENGTH = 60*2; % seconds
START_STIM_LENGTH = 1000*60*10; % mS

RESTING_PERIOD = 30; % time between stimulation and the next EEG record 
LOOP_EEG_LENGTH = 30; % seconds
LOOP_LENGTH = [0, 0, 0, 0, 20, 0]; % year/month/day/hour/min/sec

FINAL_EEG_LENGTH = 60*5; % seconds

MAX_AMP = 1200; % microAmper
MIN_AMP = 0;

% Learned veriables - default values
LV.stimLength = 30000; % Ms -- unused for now (Constant)
LV.tACS_Freq = 6; % unused here for now, handeled in the tamplate
LV.stimAmp = 0; 

def_print = print_constants.CONSOLE; % bit flag

%%%%%%%%%%%%%%%%%
% Function Body %
%%%%%%%%%%%%%%%%%

% If nothing is entered then we load our basic empty template

if ~exist('templateName','var') || isempty(templateName)
  templateName='FC6_exp';

% Connect to NIC Software

[ret, status, sock] = MatNICConnect(host);

if (ret < 0)
    log_print('ERROR: Failed on connecting to server',def_print)
    return
end
log_print('INFO: Connection to server succesful!',def_print)

% Load template

log_print(sprintf('INFO: Proceeding to load template %s ...',templateName),def_print )

ret = MatNICLoadTemplate(templateName, sock);
if (ret < 0)
    log_print('ERROR: Load template failed',def_print)
    return
end
log_print('INFO: Load template successful!',def_print)

% Launch stimulation section with EMPTY tamplate

while (1)
    [ret, status] = MatNICQueryStatus(sock);    
    if (ret < 0)
        return
    end
    switch status
        % Template loaded
        case 'CODE_STATUS_TEMPLATE_LOADED'
            log_print('INFO: Template was found and loaded!',def_print);
        % Request for user confirmation
        case 'CODE_STATUS_STIMULATION_READY'
            log_print('System is ready for stimulation',def_print);
            if isStimulating == false
                ret = MatNICStartStimulation(sock);
                pause(1);
                if ret == 0
                    initTime = clock;
                else
                    log_print('Start stimulating failed',def_print);
                    return
                end
                break;
            end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pre-trial EEG and stimulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

while (1)
    
    EEG = get_eeg(START_EEG_LENGTH,6,host);
    
    start_eeg = EEG;
    
    % Need to ask Tal what to do with this records!
    
    [ret, status] = MatNICQueryStatus(sock); 
    if (ret < 0)
        break
    end
    
    switch status
        % pretrial timulation in progress
		case 'CODE_STATUS_STIMULATION_RAMPUP'
            
			log_print(sprintf('* Stimulation performing ramp up. Ellapsed %f sec', etime(clock, initTime) ),def_print)
            
        case 'CODE_STATUS_STIMULATION_FULL'
            
            log_print(sprintf('* Stimulation started. Ellapsed %f sec', etime(clock, initTime) ),def_print)

            ret = MatNICOnlineAtacsChange(LV.stimAmp, channelToStim, ...
                                    TRANSITION_TO_PEAK, sock);
            if (ret < 0)
                break
            end
            % Wait for the stimulation to finish
            pause((START_STIM_LENGTH + TRANSITION_TO_PEAK)/60);
            % Turn off stimulation
            ret = MatNICOnlineAtacsChange(MIN_AMP, channelToStim, ...
                                    TRANSITION_FROM_PEAK, sock);
            if (ret < 0)
                break
            end
            % Wait for the transition to finish
            pause(TRANSITION_FROM_PEAK/60);
            break
            
		case 'CODE_STATUS_STIMULATION_RAMPDOWN'
            
			log_print(sprintf('* Stimulation performing ramp down. Ellapsed %f sec', etime(clock, initTime) ),def_print)
            
        case 'CODE_STATUS_STIMULATION_FINISHED'
            
            log_print('* Stimulation finished',def_print)
            break;
            
        case 'CODE_STATUS_EEG_OFF'
            
            log_print('* EEG streaming is off',def_print);
            
        case 'CODE_STATUS_EEG_ON'
            
            log_print('* EEG streaming is on',def_print);
            
        otherwise
            
            log_print(['Unexpected status received , Aborting', status],def_print);
            break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EEG recording for obtaining the optimal activity
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

EEG = get_eeg(OPT_EEG_LENGTH,6,host);

optimal_activity = get_optimal_activity(EEG);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main loop, reading EEG, analyzing and stimulating.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

finalTime = datenum(clock() + LOOP_LENGTH);

while datenum(clock()) < finalTime
    
    EEG = get_eeg(LOOP_EEG_LENGTH,6,host);
    
    LV = get_learned_vars_from_server(EEG);
    
    [ret, status] = MatNICQueryStatus(sock); 
    if (ret < 0)
        break
    end
    
    switch status
        % Stimulation in progress
		case 'CODE_STATUS_STIMULATION_RAMPUP'
            
			log_print(sprintf('* Stimulation performing ramp up. Ellapsed %f sec', etime(clock, initTime) ),def_print)
            
        case 'CODE_STATUS_STIMULATION_FULL'
            
            log_print(sprintf('* Stimulation started. Ellapsed %f sec', etime(clock, initTime) ),def_print)
            
            if ( LV.stimAmp <= 0)
                continue
            end
            
            ret = MatNICOnlineAtacsChange(LV.stimAmp, channelToStim, ...
                                    TRANSITION_TO_PEAK, sock);
            if (ret < 0)
                break
            end
            % Wait for the stimulation to finish
            pause((LV.stimLength + TRANSITION_TO_PEAK)/60);
            % Turn off stimulation
            ret = MatNICOnlineAtacsChange(MIN_AMP, channelToStim, ...
                                    TRANSITION_FROM_PEAK, sock);
            if (ret < 0)
                break
            end
            % Wait for the transition to finish
            pause(TRANSITION_FROM_PEAK/60);
            % Wait resting period before next EEG session
            pause(RESTING_PERIOD);
            break
            
            
		case 'CODE_STATUS_STIMULATION_RAMPDOWN'
            
			log_print(sprintf('* Stimulation performing ramp down. Ellapsed %f sec', etime(clock, initTime) ),def_print)
            
        case 'CODE_STATUS_STIMULATION_FINISHED'
            
            log_print('* Stimulation finished',def_print)
            break;
            
        case 'CODE_STATUS_EEG_OFF'
            
            log_print('* EEG streaming is off',def_print);
            
        case 'CODE_STATUS_EEG_ON'
            
            log_print('* EEG streaming is on',def_print);
            
        otherwise
            
            log_print(['Unexpected status received , Aborting', status],def_print);
            break;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Final EEG recording - Post Trail
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end_eeg = get_eeg(FINAL_EEG_LENGTH,6,host);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Abort Stimulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

abort_rt = MatNICAbortStimulation(sock);
 
if (abort_rt < 0)
    log_print('Abort stimulation failed',def_print)
end

end