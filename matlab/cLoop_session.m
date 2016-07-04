classdef cLoop_session < handle
    %CLOOP_SESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        TEMPLATE_NAME;
        SOCK;
        HOST;
        
        INIT_TIME;
        CHANNEL_TO_STIM;
        EEG_CHANNELS;
        
        OPTIMAL_ACTIVITY;
        
        TRANSITION_TO_PEAK; % mS
        TRANSITION_FROM_PEAK; % mS
        
        START_EEG_LENGTH; % seconds
        START_STIM_LENGTH; % mS
        
        OPT_EEG_LENGTH; % seconds
        
        RESTING_PERIOD; % time between stimulation and the next EEG record
        
        LOOP_EEG_LENGTH; % seconds
        LOOP_LENGTH; % year/month/day/hour/min/sec
        
        FINAL_EEG_LENGTH; % seconds
        
        MAX_AMP; % microAmper
        MIN_AMP;
        
        % Learned veriables - default values
        STIM_LENGTH; % Ms -- unused for now (Constant)
        TACS_FREQ; % unused here for now, handeled in the tamplate
        STIM_AMP;
        
        duration_model_update;
        amplitude_model_update;
        frequency_model_update;
        
        DEF_PRINT; % bit flag
        
        CURR_EEG;
        
        START_EEG;
        END_EEG;
        
        LOG_FILE;
        
        ABORTED;
        
        subject_id;
        experimenter_id;
        task;
        electrode_placement;
        comment;
        session_id;
        user;
        password;
        
        stimulation_id;
        activity_id;
        regression_id;
    end
    
    methods
        
        function s = cLoop_session(templateName)
            %
            % Create session object
            %
            s.TEMPLATE_NAME = templateName;
            s.SOCK = '';
            s.HOST = 'localhost';
            
            s.INIT_TIME = 0;
            s.CHANNEL_TO_STIM = 7;
            s.EEG_CHANNELS = 6; % number of EEG channels to record
            
            s.OPTIMAL_ACTIVITY = zeros(1,5);
            
            %s.TRANSITION_TO_PEAK = 5000; % mS
            %s.TRANSITION_FROM_PEAK = 5000; % mS
             s.TRANSITION_TO_PEAK = 1000; % mS
            s.TRANSITION_FROM_PEAK = 1000; % mS
            %s.START_EEG_LENGTH = 60*5; % seconds
            %s.START_STIM_LENGTH = 1000*60*10; % mS
            s.START_EEG_LENGTH = 5; % seconds
            s.START_STIM_LENGTH = 1000*5; % mS
            
            
            %s.OPT_EEG_LENGTH = 60*2; % seconds
            s.OPT_EEG_LENGTH = 5; % seconds
            
            %s.RESTING_PERIOD = 30; % time between stimulation and the next EEG record
            s.RESTING_PERIOD = 10;
            
            %s.LOOP_EEG_LENGTH = 30; % seconds
            %s.LOOP_LENGTH = [0, 0, 0, 0, 20, 0]; % year/month/day/hour/min/sec
            s.LOOP_EEG_LENGTH = 5; % seconds
            s.LOOP_LENGTH = [0, 0, 0, 0, 3, 0]; % year/month/day/hour/min/sec
            %s.FINAL_EEG_LENGTH = 60*5; % seconds
            s.FINAL_EEG_LENGTH = 2; % seconds
            s.MAX_AMP = 1200; % microAmper
            s.MIN_AMP = 0;
            
            % Learned veriables - default values
            %s.STIM_LENGTH = 30000; % Ms -- unused for now (Constant)
            %s.TACS_FREQ = 6; % unused here for now, handeled in the tamplate
            s.STIM_LENGTH = 3000; % Ms -- unused for now (Constant)
            s.TACS_FREQ = 6; % unused here for now, handeled in the tamplate
            s.STIM_AMP = 0;
            
            s.duration_model_update = false;
            s.amplitude_model_update = true;
            s.frequency_model_update = false;
            
            print_constants;
            s.DEF_PRINT = print_constants.CONSOLE; % bit flag
            
            s.CURR_EEG = ones(1,5)*-1;
            
            s.START_EEG = ones(1,5)*-1;
            s.END_EEG = ones(1,5)*-1;
            
            s.LOG_FILE = [];
            
            s.ABORTED = false;
            
            s.subject_id = '1';
            s.experimenter_id = '2';
            s.task = 'some task';
            s.electrode_placement = get_electrode_placement(s.TEMPLATE_NAME);
            s.comment = '';
            
            s.session_id = '';
            s.user = '';
            s.password = '';
            
            s.stimulation_id = -1;
            s.activity_id = 0;
            s.regression_id = 0;
        end
        
        function rc = init_session(s)
            % adding the new session to the server
            try
                for t = 1:5
                    
                    ret = sql_add(constant_activity.SESSION_ADD_ACTIVITY, ...
                                  s.subject_id,...
                                  s.experimenter_id,...
                                  s.task, ...
                                  s.OPTIMAL_ACTIVITY(1),s.OPTIMAL_ACTIVITY(2),s.OPTIMAL_ACTIVITY(3),...
                                  s.OPTIMAL_ACTIVITY(4),s.OPTIMAL_ACTIVITY(5),...
                                  s.electrode_placement,...
                                  s.comment)
                              
                    rc = ret.ret;
                    if rc < 0
                        log_print(sprintf('adding session failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        s.session_id = ret.session_id;
                        break
                    end
                end
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT);
                rc = -1;
            end
        end
        
        function rc = add_regression_model(s)
            % adding the new session to the server
            try
                for t = 1:5
                    
                    ret = sql_add(constant_activity.REGRESSION_MODEL_ADD_ACTIVITY, ...
                                  s.session_id)
                     
                    rc = ret.ret;
                    if rc < 0
                        log_print(sprintf('adding regression failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        s.regression_id = ret.entry_id;
                        break
                    end
                end
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT);
                rc = -1;
            end
        end
        
        function rc = send_eeg(s)
            % adding the new session to the server
            try
                for t = 1:5
                    
                    ret = sql_add(constant_activity.EEG_ACTIVITY_ADD_ACTIVITY, ...
                                  s.session_id,...
                                  s.stimulation_id,...
                                  s.CURR_EEG(1),...
                                  s.CURR_EEG(2),...
                                  s.CURR_EEG(3),...
                                  s.CURR_EEG(4),...
                                  s.CURR_EEG(5))
                              
                    rc = ret.ret;
                    if rc < 0
                        log_print(sprintf('adding eeg activity failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        s.activity_id = ret.entry_id;
                        break
                    end
                end
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT);
                rc = -1;
            end
        end
        
        function rc = send_stim(s)
            % adding the new session to the server
            try
                for t = 1:5
                    
                    ret = sql_add(constant_activity.STIMULATION_ADD_ACTIVITY, ...
                                  s.session_id,...
                                  s.activity_id,...
                                  s.STIM_LENGTH/1000,...
                                  s.STIM_AMP,...
                                  s.TACS_FREQ)
                              
                    rc = ret.ret;
                    if rc < 0
                        log_print(sprintf('adding stimulation failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        s.stimulation_id = ret.entry_id;
                        break
                    end
                end
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT);
                rc = -1;
            end
        end
        
        function rc = update_model_in_server(s)
            % send the activity to the server for regression
            try
                for t = 1:5
                    
                    ret = regression_model_update(constant_activity.REGRESSION_MODEL_UPDATE_ACTIVITY,...
                                                  s.session_id,...
                                                  s.user,...
                                                  s.password,...
                                                  s.duration_model_update,...
                                                  s.amplitude_model_update,...
                                                  s.frequency_model_update)
                    
                    rc = ret.ret;
                    if rc < 0
                        log_print(sprintf('updating model failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        break
                    end
                end
                
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT)
                rc = -1;
            end
        end
        
        
        function rc = get_model_from_server(s)
            % get the next stimulation from the server
            try
                for t = 1:5
                    
                    ret = regression_model_get(constant_activity.REGRESSION_MODEL_GET_ACTIVITY,...
                                               s.session_id,...
                                               'AMPLITUDE_MODEL')
                    
                    rc = ret.ret;
                    if rc < 0
                        log_print(sprintf('fetching model from server failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        break
                    end
                end
                ret.data.REGRESSION_MODEL
                ret.data.REGRESSION_MODEL.amplitude_model
                if strncmp(ret.data.REGRESSION_MODEL.amplitude_model,'NONE',4)
                    disp('model not ready, sending random stimulatio');
                    s.STIM_AMP = rand(1)
                else
                    % Might need to convet to double!
                    model = loadjson(ret.data.REGRESSION_MODEL.amplitude_model)
                    coefs = zeros(1,6);
                    coefs(3) = model.alpha;
                    coefs(4) = model.beta;
                    coefs(5) = model.gamma;
                    coefs(1) = model.delta;
                    coefs(2) = model.theta;
                    coefs(6) = model.intercept;
                    s.STIM_AMP = [s.CURR_EEG 1]*coefs';
                    fprintf('stimulation from model is %d',s.STIM_AMP);
                    if (s.STIM_AMP) < s.MIN_AMP
                        s.STIM_AMP = s.MIN_AMP;
                    elseif (s.STIM_AMP) > s.MAX_AMP
                        s.STIM_AMP = s.MAX_AMP;   
                    end
                end
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT)
                rc = -1;
            end
        end
        
        function terminate_session(s)
            ret_string = 'successfully';
            
            if ~s.ABORTED
                abort_rt = MatNICAbortStimulation(s.SOCK);
                ret_string = 'unsuccessfully';
                if (abort_rt < 0)
                    log_print('Abort stimulation failed',s.DEF_PRINT)
                end
                s.ABORTED = true;
            end
            
            log_print(sprintf('Session finished %s',ret_string),s.DEF_PRINT)
            
        end
        
        
    end
    
end

