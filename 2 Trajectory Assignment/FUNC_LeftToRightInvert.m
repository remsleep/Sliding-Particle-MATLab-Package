function [TRAJECTORY] = FUNC_LeftToRightInvert(TRAJECTORY, ySize, fieldName)
%FUNC_LEFTTORIGHTINVERT takes in the TRAJECTORY structure and sends
%coordinates located in the 'Y' field from y to (YSIZE-y). If FIELDNAME is
%explicitly expressed (a string), the function will look to flip the
%contents of the contents of the FIELDNAME field.

%Use 'Y' as field name if not otherwise specified
if nargin == 2
    fieldName = 'Y';
end

%Iterate through trajectories and flip y coordinates
for index = 1:numel(TRAJECTORY)
    
    TRAJECTORY(index).(fieldName) = ySize - TRAJECTORY(index).(fieldName);
    
end

end

