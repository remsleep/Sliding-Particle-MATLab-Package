function [tracks] = FUNC_TrajStruct2TracksArray(TRAJECTORY)
%FUNC_TRAJS2TRACKSMAT Takes in a TRAJECTORY structure containing at least
%FRAME, X, Y, and ORIENT fields and returns a 5xN array containing        
% [x, y, timestamp, orientation, ID]

% Convert structure to an array before manipulating
arrayConv = FUNC_Structure2Array(TRAJECTORY);

% Construct tracks
tracks = [arrayConv(2,:); arrayConv(3,:); arrayConv(1,:); ...
    arrayConv(5,:); arrayConv(6,:)]; 

end

