function [VELTRAJECTORY] = FUNC_FindVelocityFromArray(TRAJECTORY, WINDOW, pixelConv, timeConv)
%Calculating velocities frame by frame is very noisy. So instead we will
%take a MTs rolling trajectory and fit a velocity to that. PIXELCONV is the
%microns/pixel conversion from the original images and TIMECONV is the time
%between frames in seconds. TRAJECTORY is a 5xN array with the following info
%stored in each row: [x, y, frame, orientation, ID]
%figure
%hold on;

%Assign dummy conversion quantities, if necessary
if nargin == 2
    pixelConv = 1;
    timeConv = 1;
end

baseIndex = 1;
VELTRAJECTORY = zeros(7,size(TRAJECTORY,2));
VELTRAJECTORY(1:5,:) = TRAJECTORY;

for currTraj = 1:max(TRAJECTORY(5,:)) %Go through Each Trajectory
    
    topIndex = max(find(TRAJECTORY(5,:) == currTraj));
    
    %Remove outliers from the whole track at once
    VELTRAJECTORY(1,baseIndex:topIndex) = ...
        smooth(TRAJECTORY(1,baseIndex:topIndex),length(TRAJECTORY)/2,'rlowess')';
    VELTRAJECTORY(2,baseIndex:topIndex) = ...
        smooth(TRAJECTORY(2,baseIndex:topIndex),length(TRAJECTORY)/2,'rlowess')';
    
    for t = baseIndex:topIndex %Go through each time point
        %Create a window of frames to look at
        WINDOW_MIN = max(t + 1 - WINDOW,baseIndex);
        WINDOW_MAX = min(max(t,WINDOW + baseIndex - 1),topIndex);
        
        %Find an angle parallel to the MT over the window of frames
        TEMP_ANGLE = mean(TRAJECTORY(4,WINDOW_MIN:WINDOW_MAX));
        
        % x-axis parallel, y-axis is perp.
        %Coordinate transform using TEMP_ANGLE, to make a parallel direction
        PARALLEL = (TRAJECTORY(1,WINDOW_MIN:WINDOW_MAX) .* (cos(TEMP_ANGLE)) ) ...
            + (TRAJECTORY(2,WINDOW_MIN:WINDOW_MAX) .* (sin(TEMP_ANGLE)) );
        
        %Need to remove outliers now.
        PARALLEL = filloutliers(PARALLEL,'linear');
        
        %Fit the positions to a slope to determine velocity
        PARALLEL_FIT = fitlm((1:length(PARALLEL)),PARALLEL);
        
        %Store parallel velocities, with rescaling
        VELTRAJECTORY(6,t) = PARALLEL_FIT.Coefficients.Estimate(2)*pixelConv/timeConv;
        
        %Coordinate transform using TEMP_ANGLE, to make a perpendicular direction
%         PERPENDI = (TRAJECTORY(i).X(WINDOW_MIN:WINDOW_MAX) .* abs(sin(TEMP_ANGLE)) ) ...
%                + (TRAJECTORY(i).Y(WINDOW_MIN:WINDOW_MAX) .* abs(cos(TEMP_ANGLE)) );
        PERPENDI = -(TRAJECTORY(1,WINDOW_MIN:WINDOW_MAX) .* (sin(TEMP_ANGLE)) ) ...
               + (TRAJECTORY(2,WINDOW_MIN:WINDOW_MAX) .* (cos(TEMP_ANGLE)) );
        
        %Need to remove outliers now.
        PERPENDI = filloutliers(PERPENDI,'linear');
        
        %Fit the positions to a slope to determine velocity
        PERPENDI_FIT = fitlm((1:length(PERPENDI)),PERPENDI);
        
        %Store parallel velocities
        VELTRAJECTORY(7,t) = PERPENDI_FIT.Coefficients.Estimate(2)*pixelConv/timeConv;
            
    end
            
    baseIndex = topIndex + 1;
    
%     if baseIndex > 500
%     end
    %Smooth out the velocity to fill in NaN holes where it is reasonable
%    TRAJECTORY(i).VEL = smooth(TRAJECTORY(i).VEL);
%    plot(TRAJECTORY(i).VEL);
end
    
%Rescale x,y,length if necessary
if pixelConv ~= 1
    VELTRAJECTORY(1,:) = VELTRAJECTORY(1,:)*pixelConv;
    VELTRAJECTORY(2,:) = VELTRAJECTORY(2,:)*pixelConv;
%         TRAJECTORY(currTraj).LENGTH = TRAJECTORY(currTraj).LENGTH*pixelConv;
end

end