%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function implements a basic closed loop, with a simple design
% We start with a tamplate of ZERO stimulation, we read the s.CURR_EEG
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
% -1: The connection to the s.HOST and port number did not succeed.
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
function [ret, s] = cLoop_run_session (templateName)
try
    addpath(genpath('MatNIC_v2.5'));
    
    print_constants;
    
    ret = 0;
    
    s = cLoop_session(templateName);
    clean_up = onCleanup(@() terminate_session(s));
    
    % If nothing is entered then we load our basic empty template
    
    if ~exist('templateName','var') || isempty(s.TEMPLATE_NAME)
        s.TEMPLATE_NAME = 'FC6_exp';
    end
    % Connect to NIC Software
    
    [ret, ~ , s.SOCK] = MatNICConnect(s.HOST);
    
    if (ret < 0)
        log_print('ERROR: Failed on connecting to server',s.DEF_PRINT)
        return
    end
    log_print('INFO: Connection to server succesful!',s.DEF_PRINT)
    
    % Load template
    
    log_print(sprintf('INFO: Proceeding to load template %s ...',templateName),s.DEF_PRINT )
    
    ret = MatNICLoadTemplate(s.TEMPLATE_NAME, s.SOCK);
    if (ret < 0)
        log_print('ERROR: Load template failed',s.DEF_PRINT)
        return
    end
    log_print('INFO: Load template successful!',s.DEF_PRINT)
    
    % Launch stimulation section with EMPTY tamplate
    
    while (1)
        [ret, status] = MatNICQueryStatus(s.SOCK);
        if (ret < 0)
            return
        end
        switch status
            % Template loaded
            case 'CODE_STATUS_TEMPLATE_LOADED'
                log_print('INFO: Template was found and loaded!',s.DEF_PRINT);
                % Request for user confirmation
            case 'CODE_STATUS_STIMULATION_READY'
                log_print('System is ready for stimulation',s.DEF_PRINT);
                
                ret = MatNICStartStimulation(s.SOCK);
                pause(1);
                if ret == 0
                    s.INIT_TIME = clock;
                else
                    log_print('Start stimulating failed',s.DEF_PRINT);
                    return
                end
                break;
                
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % pre-trial s.CURR_EEG and stimulation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    while (1)
        
        s.CURR_EEG = get_eeg(s.START_EEG_LENGTH, s.EEG_CHANNELS, s.HOST);
        
        s.START_EEG = s.CURR_EEG;
        
        % Need to ask Tal what to do with this records!
        
        [ret, status] = MatNICQueryStatus(s.SOCK);
        if (ret < 0)
            break
        end
        
        switch status
            % pretrial timulation in progress
            case 'CODE_STATUS_STIMULATION_RAMPUP'
                
                log_print(sprintf('* Stimulation performing ramp up. Ellapsed %f sec', etime(clock, s.INIT_TIME) ),s.DEF_PRINT)
                
            case 'CODE_STATUS_STIMULATION_FULL'
                
                log_print(sprintf('* Stimulation started. Ellapsed %f sec', etime(clock, s.INIT_TIME) ),s.DEF_PRINT)
                
                ret = MatNICOnlineAtacsChange(s.STIM_AMP, s.CHANNEL_TO_STIM, ...
                    s.TRANSITION_TO_PEAK, s.SOCK);
                if (ret < 0)
                    break
                end
                % Wait for the stimulation to finish
                pause((s.START_STIM_LENGTH + s.TRANSITION_TO_PEAK)/60);
                % Turn off stimulation
                ret = MatNICOnlineAtacsChange(s.MIN_AMP, s.CHANNEL_TO_STIM, ...
                    s.TRANSITION_FROM_PEAK, s.SOCK);
                if (ret < 0)
                    break
                end
                % Wait for the transition to finish
                pause(s.TRANSITION_FROM_PEAK/60);
                break
                
            case 'CODE_STATUS_STIMULATION_RAMPDOWN'
                
                log_print(sprintf('* Stimulation performing ramp down. Ellapsed %f sec', etime(clock, s.INIT_TIME) ),s.DEF_PRINT)
                
            case 'CODE_STATUS_STIMULATION_FINISHED'
                
                log_print('* Stimulation finished',s.DEF_PRINT)
                break;
                
            case 'CODE_STATUS_s.CURR_EEG_OFF'
                
                log_print('* s.CURR_EEG streaming is off',s.DEF_PRINT);
                
            case 'CODE_STATUS_s.CURR_EEG_ON'
                
                log_print('* s.CURR_EEG streaming is on',s.DEF_PRINT);
                
            otherwise
                
                log_print(['Unexpected status received , Aborting', status],s.DEF_PRINT);
                break;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % eeg recording for obtaining the optimal activity
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    s.CURR_EEG = get_eeg(s.OPT_EEG_LENGTH, s.EEG_CHANNELS, s.HOST);
    
    s.OPTIMAL_ACTIVITY = get_optimal_activity(s.CURR_EEG);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % adding the new session to the server
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    ret = init_session(s);
    
    if (ret < 0)
        log_print('ERROR:  init session failed',s.DEF_PRINT)
        return
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Main loop, reading eeg, analyzing and stimulating.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    finalTime = datenum(clock() + LOOP_LENGTH);
    
    while datenum(clock()) < finalTime
        
        s.CURR_EEG = get_eeg(s.LOOP_EEG_LENGTH, s.EEG_CHANNELS, s.HOST);
        
        ret = get_model_from_server(s);
        
        if (ret < 0)
            log_print(sprintf('Obtaining model failed with rc %d',ret), print_constants.CONSOLE)
            return
        end
        
        ret = update_model_in_server(s);
        
        if (ret < 0)
            log_print(sprintf('Updating model failed with rc %d',ret), print_constants.CONSOLE)
            return
        end
        
        [ret, status] = MatNICQueryStatus(s.SOCK);
        if (ret < 0)
            log_print(sprintf('MatNICQueryStatus failed with rc %d',ret), print_constants.CONSOLE)
            return
        end
        
        switch status
            % Stimulation in progress
            case 'CODE_STATUS_STIMULATION_RAMPUP'
                
                log_print(sprintf('* Stimulation performing ramp up. Ellapsed %f sec', etime(clock, s.INIT_TIME) ),s.DEF_PRINT)
                
            case 'CODE_STATUS_STIMULATION_FULL'
                
                log_print(sprintf('* Stimulation started. Ellapsed %f sec', etime(clock, s.INIT_TIME) ),s.DEF_PRINT)
                
                if ( s.STIM_AMP <= 0)
                    continue
                end
                
                ret = MatNICOnlineAtacsChange(s.STIM_AMP, s.CHANNEL_TO_STIM, ...
                    s.TRANSITION_TO_PEAK, s.SOCK);
                if (ret < 0)
                    break
                end
                % Wait for the stimulation to finish
                pause((s.STIM_LENGTH + s.TRANSITION_TO_PEAK)/60);
                % Turn off stimulation
                ret = MatNICOnlineAtacsChange(s.MIN_AMP, s.CHANNEL_TO_STIM, ...
                    s.TRANSITION_FROM_PEAK, s.SOCK);
                if (ret < 0)
                    break
                end
                % Wait for the transition to finish
                pause(s.TRANSITION_FROM_PEAK/60);
                % Wait resting period before next eeg session
                pause(s.RESTING_PERIOD);
                break
                
                
            case 'CODE_STATUS_STIMULATION_RAMPDOWN'
                
                log_print(sprintf('* Stimulation performing ramp down. Ellapsed %f sec', etime(clock, s.INIT_TIME) ),s.DEF_PRINT)
                
            case 'CODE_STATUS_STIMULATION_FINISHED'
                
                log_print('* Stimulation finished',s.DEF_PRINT)
                break;
                
            case 'CODE_STATUS_s.CURR_EEG_OFF'
                
                log_print('* s.CURR_EEG streaming is off',s.DEF_PRINT);
                
            case 'CODE_STATUS_s.CURR_EEG_ON'
                
                log_print('* s.CURR_EEG streaming is on',s.DEF_PRINT);
                
            otherwise
                
                log_print(['Unexpected status received , Aborting', status],s.DEF_PRINT);
                break;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Final eeg recording - Post Trail
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    s.END_EEG = get_eeg(s.FINAL_EEG_LENGTH, s.EEG_CHANNELS, s.HOST);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Abort Stimulation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    abort_rt = MatNICAbortStimulation(s.SOCK);
    
    if (abort_rt < 0)
        log_print('Abort stimulation failed',s.DEF_PRINT)
    end
    
    s.ABORTED = true;
    
catch ME
    log_print(ME.getReport(), print_constants.CONSOLE)
    return
end

end