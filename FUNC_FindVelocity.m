function [TRAJECTORY] = FUNC_FindVelocity(TRAJECTORY, pixelConv, timeConv)
%FUNC_FINDVELOCITY Takes in TRAJECTORY, a structure containing all x
%and y coordinates, orientations, frames, and length information as fields.
%The function converts the structure into a series of vectors and
%calculates the velocities of individual particles in a reference frame
%defined by the directors normal and parallel to each particle at a given
%time.PIXELCONV and TIMECONV are conversion variables indicating the number
%of um/pixel and seconds/frame, respectively

%Set pixel and time conversions to 1 if left undefined by user
if nargin == 1
    pixelConv = 1;
    timeConv = 1;
end

%Define an ID field to differentiate trajectories in array form
for index = 1:numel(TRAJECTORY)
    TRAJECTORY(index).ID = index*ones(1,numel(TRAJECTORY(index).FRAME));
end

%Convert fields to vectors
FRAME = [TRAJECTORY.FRAME];
X = [TRAJECTORY.X];
Y = [TRAJECTORY.Y];
ORIENT = [TRAJECTORY.ORIENT];
IDNUM = [TRAJECTORY.ID];

%Iterate through IDs
for currTraj = 1:max(IDNUM)

    %Select all data associated with current trajectory
    tempInds = IDNUM == currTraj;
    tempData = [X(tempInds); Y(tempInds); ORIENT(tempInds); FRAME(tempInds)];
    
    %Reorder data chronologically (via FRAME order)
    [~, timeInds] = sort(tempData(4,:));
    tempData = tempData(:,timeInds);
    
    %Define "difference" matrices of x,y coordinates (nearest time steps)
    %and divide by time step (Find V_x and V_y)
    Vx = diff(tempData(1,:)) ./ diff(tempData(4,:)) * pixelConv/timeConv;
    Vy = diff(tempData(2,:)) ./ diff(tempData(4,:)) * pixelConv/timeConv;
    
    %Transform velocities to parallel-perpendicular reference frame
    avgAngles = mean([tempData(3,1:end-1); tempData(3,2:end)]);
    Vpar = Vx.*cos(avgAngles) + Vy.*sin(avgAngles);
    Vperp = -Vx.*sin(avgAngles) + Vy.*cos(avgAngles);
    
    %Store in structure
    TRAJECTORY(currTraj).PARVEL = Vpar;
    TRAJECTORY(currTraj).PERPVEL = Vperp;
    
end

end

