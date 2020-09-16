function [outData] = FUNC_FindVelocityFromArray(TRAJECTORY,pixelConv,timeConv)
%FUNC_FINDVELOCITYFROMARRAY Takes in TRAJECTORY, an array containing all x
%and y coordinates, orientations, frames, and length information as fields.
%The array order must be of the form [x, y, frame, orientation, ID]
%The function calculates the velocities of individual particles in a 
%reference frame defined by the directors normal and parallel to each
%particle at a given time.
%PIXELCONV and TIMECONV are conversion variables indicating the number
%of um/pixel and seconds/frame, respectively

%Set pixel and time conversions to 1 if left undefined by user
if nargin == 1
    pixelConv = 1;
    timeConv = 1;
end

%Convert fields to vectors
FRAME = TRAJECTORY(3,:);
X = TRAJECTORY(1,:);
Y = TRAJECTORY(2,:);
ORIENT = TRAJECTORY(4,:);
IDNUM = TRAJECTORY(5,:);

%Initialize storage vectors
outData = zeros(7,numel(IDNUM));
storInd = 1;

%Iterate through IDs
for currTraj = 1:max(IDNUM)

    %Select all data associated with current trajectory
    tempInds = IDNUM == currTraj;
    tempData = [X(tempInds); Y(tempInds); FRAME(tempInds); ORIENT(tempInds); IDNUM(tempInds)];
    
    %Reorder data chronologically (via FRAME order)
    [~, timeInds] = sort(tempData(3,:));
    tempData = tempData(:,timeInds);
    
    %Define "difference" matrices of x,y coordinates (nearest time steps)
    %and divide by time step (Find V_x and V_y)
    Vx = diff(tempData(1,:)) ./ diff(tempData(3,:)) * pixelConv/timeConv;
    Vy = diff(tempData(2,:)) ./ diff(tempData(3,:)) * pixelConv/timeConv;
    
    %Transform velocities to parallel-perpendicular reference frame
    avgAngles = mean([tempData(4,1:end-1); tempData(4,2:end)]);
    Vpar = Vx.*cos(avgAngles) + Vy.*sin(avgAngles);
    Vperp = -Vx.*sin(avgAngles) + Vy.*cos(avgAngles);
    
    %Store in structure
    outData(1:5,storInd:storInd+numel(Vpar)) = tempData;
    outData(6,storInd+1:storInd+numel(Vpar)) = Vpar;
    outData(7,storInd+1:storInd+numel(Vpar)) = Vperp;
    storInd = storInd+numel(Vperp)+1;
    
end

end

