function [ret] = sql_add(varargin)
    constant_load_all;
    insert_data_to_sql_url = constant_address.INSERT_DATA_URL;
    activity = varargin{1};
    if strcmp(activity,constant_activity.SESSION_ADD_ACTIVITY)
        subject_id = varargin{2}; experimenter_id = varargin{3}; task = varargin{4};
        objective_activity_band = varargin{5}; objective_activity_value = varargin{6};
        electrode_placement = varargin{7}; comment = varargin{8};
        [ret,data]=create_struct(subject_id,experimenter_id,task,objective_activity_band,objective_activity_value,electrode_placement,comment);
        request.action = constant_activity.SESSION_ADD_ACTIVITY;
        request.table = constant_table.SESSION;
    elseif strcmp(activity,constant_activity.EEG_ACTIVITY_ADD_ACTIVITY)
        session_id = varargin{2}; alpha_activity = varargin{3}; beta_activity = varargin{4}; 
        gamma_activity = varargin{5}; delta_activity = varargin{6}; theta_activity = varargin{7};
        band_for_improvement = varargin{8}; amplitude_for_improvement = varargin{9};
        [ret,data]=create_struct(session_id, alpha_activity, beta_activity, gamma_activity, delta_activity, theta_activity, band_for_improvement, amplitude_for_improvement);
        request.action = constant_activity.EEG_ACTIVITY_ADD_ACTIVITY;
        request.table = constant_table.EEG_ACTIVITY;
    elseif strcmp(activity,constant_activity.STIMULATION_ADD_ACTIVITY)
        %session_id, stimulation_duration, stimulation_amplitude, stimulation_frequency
        session_id = varargin{2}; stimulation_duration = varargin{3}; 
        stimulation_amplitude = varargin{4}; stimulation_frequency = varargin{5};
        [ret,data]=create_struct(session_id, stimulation_duration, stimulation_amplitude, stimulation_frequency);
        request.action = constant_activity.STIMULATION_ADD_ACTIVITY;
        request.table = constant_table.STIMULATION;
    end
    if ret ~= 0
        return;
    end
    request.data = data;
    options = weboptions('MediaType','application/json');
    ret = webwrite(insert_data_to_sql_url,request,options);
end