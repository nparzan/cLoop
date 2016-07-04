classdef cLoop_session < handle
    %CLOOP_SESSION Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        TAMPLATE;
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
        
    end
    
    methods
        
        function s = cLoop_session(templateName, subject_id, experimenter_id, task)
            %
            % Create session object
            %
            s.TAMPLATE = templateName;
            s.SOCK = '';
            s.HOST = 'localhost';
            
            s.INIT_TIME = 0;
            s.CHANNEL_TO_STIM = 7;
            s.EEG_CHANNELS = 6; % number of EEG channels to record
            
            s.OPTIMAL_ACTIVITY = zeros(1,5);
            
            s.TRANSITION_TO_PEAK = 5000; % mS
            s.TRANSITION_FROM_PEAK = 5000; % mS
            
            s.START_EEG_LENGTH = 60*5; % seconds
            s.START_STIM_LENGTH = 1000*60*10; % mS
            
            s.OPT_EEG_LENGTH = 60*2; % seconds
            
            s.RESTING_PERIOD = 30; % time between stimulation and the next EEG record
            
            s.LOOP_EEG_LENGTH = 30; % seconds
            s.LOOP_LENGTH = [0, 0, 0, 0, 20, 0]; % year/month/day/hour/min/sec
            
            s.FINAL_EEG_LENGTH = 60*5; % seconds
            
            s.MAX_AMP = 1200; % microAmper
            s.MIN_AMP = 0;
            
            % Learned veriables - default values
            s.STIM_LENGTH = 30000; % Ms -- unused for now (Constant)
            s.TACS_FREQ = 6; % unused here for now, handeled in the tamplate
            s.STIM_AMP = 0;
            
            print_constants;
            s.DEF_PRINT = print_constants.CONSOLE; % bit flag
            
            s.CURR_EEG = ones(1,5)*-1;
            
            s.START_EEG = ones(1,5)*-1;
            s.END_EEG = ones(1,5)*-1;
            
            s.LOG_FILE = [];
            
            s.ABORTED = false;
            
            s.subject_id = subject_id;
            s.experimenter_id = experimenter_id;
            s.task = task;
            s.electrode_placement = get_electrode_placement(s.TAMPLATE);
            s.comment = '';
            
            s.session_id = '';
            s.user = '';
            s.password = '';
            
        end
        
        function ret = init_session(s)
            % adding the new session to the server
            try
                for t = 1:5
                    
                    ret = sql_add(constant_activity.SESSION_ADD_ACTIVITY, ...
                                  s.subject_id,...
                                  s.experimenter_id,...
                                  s.task, ...
                                  s.CURR_EEG(1),s.CURR_EEG(2),s.CURR_EEG(3),...
                                  s.CURR_EEG(4),s.CURR_EEG(5),...
                                  s.electrode_placement,...
                                  s.comment);
                              
                    rc = uint16(ret.ret);
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
                ret = -1;
            end
        end
        
        function ret = update_model_in_server(s)
            % send the activity to the server for regression
            try
                for t = 1:5
                    
                    ret = regression_model_update(constant_activity.REGRESSION_MODEL_UPDATE_ACTIVITY,...
                                                  s.session_id,...
                                                  s.user,...
                                                  s.password,...
                                                  s.STIM_LENGTH,...
                                                  s.STIM_AMP,...
                                                  s.TACS_FREQ);
                    
                    rc = uint16(ret.ret);
                    if rc < 0
                        log_print(sprintf('updating model failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        break
                    end
                end
                
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT)
                ret = -1;
            end
        end
        
        
        function ret = get_model_from_server(s)
            % get the next stimulation from the server
            try
                for t = 1:5
                    
                    ret = regression_model_get(constant_activity.REGRESSION_MODEL_GET_ACTIVITY,...
                                               'amplitude_model',...
                                                s.session_id);
                    
                    rc = uint16(ret.ret);
                    if rc < 0
                        log_print(sprintf('fetching activity from server failed with rt %d',ret), s.DEF_PRINT)
                        continue
                    else
                        break
                    end
                end
                
                if strcmp(ret.msg,'NOT ENOUGH INFO')
                    s.STIM_AMP = rand(1);
                else
                    % Might need to convet to double!
                    coefs = ret.coefs;% tentatively
                    s.STIM_AMP = [s.CURR_EEG 1]*coefs';
                end
            catch ME
                log_print(ME.getReport(), s.DEF_PRINT)
                ret = -1;
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

