function [ret] = regression_model_get(varargin)
    constant_load_all;
    activity = varargin{1};
    
    if strcmp(activity,constant_activity.REGRESSION_MODEL_GET_ACTIVITY)
        session_id = varargin{2};
        %model_type is from {duration_model, amplitude_model, frequency_model}
        model_type = varargin{3};
        [ret,data]=create_struct(session_id,model_type);
        request.action = constant_activity.REGRESSION_MODEL_GET_ACTIVITY;
    end
    if ret ~= 0
        return;
    end
    request.data = data;
    options = weboptions('MediaType','application/json');
    ret = webwrite(constant_address.GET_DATA_URL,request,options);
end