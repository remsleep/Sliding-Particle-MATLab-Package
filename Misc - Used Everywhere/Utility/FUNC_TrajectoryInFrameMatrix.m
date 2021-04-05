function [TrajInFrame] = FUNC_TrajectoryInFrameMatrix(TRAJECTORY, timePoints)
%TRAJINFRAMEMATRIX generates a matrix from the TRAJECTORIES structure that
%indicates which trajectories exist at what points in time. TIMEPOINTS is
%scalar indicating the total number of frames being analyzed. Assumes frame
%spacing of 1. This last argument can be dropped at a slight computational 
%time expense.


%Initialize the logic matrix. 
if nargin == 2
    TrajInFrame = zeros(size(TRAJECTORY,2), timePoints);
else
    TrajInFrame = [];
end

%Iterate through each trajectory and mark what times the exist at.
for currTraj = 1:numel(TRAJECTORY)
    
    trajTimes = TRAJECTORY(currTraj).FRAME;
    TrajInFrame(currTraj, trajTimes) = 1;

end

