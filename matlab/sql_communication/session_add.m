function [ret] = session_add(subject_id,experimenter_id,task,objective_activity_band,objective_activity_value,electrode_placement,comment)
    constant_load_all;
    ADD_SESSION_URL = constant_address.INSERT_DATA_URL;
    [ret,session_data]=create_struct(subject_id,experimenter_id,task,objective_activity_band,objective_activity_value,electrode_placement,comment);
    request.action = constant_activity.SESSION_ADD_ACTIVITY;
    request.data = session_data;
    request.table = constant_table.SESSION;
    if ret ~= 0
        return;
    end
    options = weboptions('MediaType','application/json');
    ret = webwrite(ADD_SESSION_URL,request,options);
end