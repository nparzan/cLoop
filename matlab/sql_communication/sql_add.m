function [ret] = sql_add(varargin)
    constant_load_all;
    activity = varargin{1};
    if strcmp(activity,constant_activity.SESSION_ADD_ACTIVITY)
        subject_id = varargin{2}; experimenter_id = varargin{3}; task = varargin{4};
        objective_delta_value = varargin{5}; objective_theta_value = varargin{6};
        objective_alpha_value = varargin{7}; objective_beta_value = varargin{8};
        objective_gamma_value = varargin{9};
        %objective_activity_band = varargin{5}; objective_activity_value = varargin{6};
        electrode_placement = varargin{10}; comment = varargin{11};
        [ret,data]=create_struct(subject_id,experimenter_id,task,objective_delta_value,objective_theta_value,objective_alpha_value,objective_beta_value,objective_gamma_value,electrode_placement,comment);
        request.action = constant_activity.SESSION_ADD_ACTIVITY;
        request.table = constant_table.SESSION;
    elseif strcmp(activity,constant_activity.EEG_ACTIVITY_ADD_ACTIVITY)
        session_id = varargin{2}; stimulation_id = varargin{3};
        delta_activity = varargin{4}; theta_activity = varargin{5};
        alpha_activity = varargin{6}; beta_activity = varargin{7}; gamma_activity = varargin{8}; 
        [ret,data]=create_struct(session_id,stimulation_id, alpha_activity, beta_activity, gamma_activity, delta_activity, theta_activity);
        request.action = constant_activity.EEG_ACTIVITY_ADD_ACTIVITY;
        request.table = constant_table.EEG_ACTIVITY;
    elseif strcmp(activity,constant_activity.STIMULATION_ADD_ACTIVITY)
        session_id = varargin{2}; eeg_activity_id = varargin{3}; stimulation_duration = varargin{4}; 
        stimulation_amplitude = varargin{5}; stimulation_frequency = varargin{6};
        [ret,data]=create_struct(session_id, eeg_activity_id, stimulation_duration, stimulation_amplitude, stimulation_frequency);
        request.action = constant_activity.STIMULATION_ADD_ACTIVITY;
        request.table = constant_table.STIMULATION;
    end
    if ret ~= 0
        return;
    end
    request.data = data;
    options = weboptions('MediaType','application/json');
    ret = webwrite(constant_address.INSERT_DATA_URL,request,options);
end