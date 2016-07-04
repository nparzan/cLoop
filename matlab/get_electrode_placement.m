function placement = get_electrode_placement(template)
% Need to be implemented
% Will get the information from the session XML file
% for now we use constant values
placement = '';
switch template
    case 'FC6_exp'
        placement = ['Cz','Fz','Fpz','F7','F8','Pz','ac-Fc6','ret-Fc5'];
    case 'PZ_exp'
        placement = ['Cz','Fz','Fpz','F7','F8','Fc6','ac-Pz','ret-Fc5'];
end

end

