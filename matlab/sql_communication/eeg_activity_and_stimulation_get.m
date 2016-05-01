function [ret] = eeg_activity_and_stimulation_get(varargin)
    constant_load_all;
    activity = varargin{1};
    
    if strcmp(activity,constant_activity.EEG_ACTIVITY_AND_STIMULATION_GET_ACTIVITY)
        session_id = varargin{2};
        [ret,data]=create_struct(session_id);
        request.action = constant_activity.EEG_ACTIVITY_AND_STIMULATION_GET_ACTIVITY;
    end
    if ret ~= 0
        return;
    end
    request.data = data;
    options = weboptions('MediaType','application/json');
    ret = webwrite(constant_address.GET_DATA_URL,request,options);
end