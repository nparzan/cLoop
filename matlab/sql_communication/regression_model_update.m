function [ret] = regression_model_update(varargin)
    constant_load_all;
    activity = varargin{1};
    
    if strcmp(activity,constant_activity.REGRESSION_MODEL_UPDATE_ACTIVITY)
        session_id = varargin{2}; user = varargin{3}; password = varargin{4};
        update_duration = varargin{5}; update_amplitude = varargin{6};
        update_frequency = varargin{7};
        [ret,data]=create_struct(session_id, user, password, update_duration, update_amplitude, update_frequency);
        request.action = constant_activity.REGRESSION_MODEL_UPDATE_ACTIVITY;
        
    end
    
    if ret ~= 0
        return;
    end    
    
    request.data = data;
    request.table = constant_table.REGRESSION_MODEL;
    options = weboptions('MediaType','application/json');
    ret = webwrite(constant_address.UPDATE_DATA_URL,request,options);
end