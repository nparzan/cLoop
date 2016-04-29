function [ret] = session_add(subject_id,experimenter_id,task,objective_activity_band,objective_activity_value,electrode_placement,comment)
    addpath('jsonlab');
    
    ADD_SESSION_URL = 'http://www.cs.tau.ac.il/~noamp1/cLoop/php/session_add.php';
    [ret,session_data]=create_struct(subject_id,experimenter_id,task,objective_activity_band,objective_activity_value,electrode_placement,comment);
    request.action = 'ADD_SESSION';
    request.data = session_data;
    if ret ~= 0
        return;
    end
    options = weboptions('MediaType','application/json');
    ret_raw = webwrite(ADD_SESSION_URL,request,options);
    ret = loadjson(ret_raw);
end