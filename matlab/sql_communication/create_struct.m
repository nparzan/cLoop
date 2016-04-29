function [ret, struct_parse] = create_struct(varargin)
    for i=1:length(varargin)
        struct_parse.(inputname(i))=varargin{i};
    end
    ret = 0;
end