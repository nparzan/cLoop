function [ret] = eeg_activity_add(session_id, activity, band_for_improvement, amplitude_for_improvement)
    % Activity is an array with five elements in the following order:
        % Alpha, Beta, Gamma, Delta, Theta
        % If a specific band is irrelevant, set to (-1)        
    constant_load_all;
    alpha_activity = activity{1};
    beta_activity = activity{2};
    gamma_activity = activity{3};
    delta_activity = activity{4};
    theta_activity = activity{5};
    ADD_EEG_ACTIVITY_URL = constant_address.INSERT_DATA_URL;
    [ret,eeg_activity_data]=create_struct(session_id, alpha_activity, beta_activity, gamma_activity, delta_activity, theta_activity, band_for_improvement, amplitude_for_improvement);
    request.action = constant_activity.EEG_ACTIVITY_ADD_ACTIVITY;
    request.data = eeg_activity_data;
    request.table = constant_table.EEG_ACTIVITY;
    if ret ~= 0
        return;
    end
    options = weboptions('MediaType','application/json');
    ret = webwrite(ADD_EEG_ACTIVITY_URL,request,options);
end