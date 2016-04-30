function [ret] = stimulation_add(session_id, stimulation_duration, stimulation_amplitude, stimulation_frequency)
    constant_load_all;
    ADD_STIMULATION_URL = constant_address.INSERT_DATA_URL;
    [ret,stimulation_data]=create_struct(session_id, stimulation_duration, stimulation_amplitude, stimulation_frequency);
    request.action = constant_activity.STIMULATION_ADD_ACTIVITY;
    request.data = stimulation_data;
    request.table = constant_table.EEG_ACTIVITY;
    if ret ~= 0
        return;
    end
    options = weboptions('MediaType','application/json');
    ret = webwrite(ADD_STIMULATION_URL,request,options);
end