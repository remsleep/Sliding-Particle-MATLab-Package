function [TRAJECTORY] = FUNC_Find_Velocity(TRAJECTORY, WINDOW, pixelConv, timeConv)
%Calculating velocities frame by frame is very noisy. So instead we will
%take a MTs rolling trajectory and fit a velocity to that. PIXELCONV is the
%microns/pixel conversion from the original images and TIMECONV is the time
%between frames in seconds.
%figure
%hold on;

%Assign dummy conversion quantities, if necessary
if nargin == 2
    pixelConv = 1;
    timeConv = 1;
end

for i = 1:length(TRAJECTORY) %Go through Each Trajectory
    
    %Remove outliers from the whole track at once
    TRAJECTORY(i).X = smooth(TRAJECTORY(i).X,length(TRAJECTORY)/2,'rlowess')';
    TRAJECTORY(i).Y = smooth(TRAJECTORY(i).Y,length(TRAJECTORY)/2,'rlowess')';
    
    for t = 1:length(TRAJECTORY(i).FRAME) %Go through each time point
        %Create a window of frames to look at
        WINDOW_MIN = max(t + 1 - WINDOW,1);
        WINDOW_MAX = min(max(t,WINDOW),length(TRAJECTORY(i).FRAME));
        
        %Find an angle parallel to the MT over the window of frames
        TEMP_ANGLE = mean(TRAJECTORY(i).ORIENT(WINDOW_MIN:WINDOW_MAX));
        
        % x-axis parallel, y-axis is perp.
        %Coordinate transform using TEMP_ANGLE, to make a parallel direction
        PARALLEL = (TRAJECTORY(i).X(WINDOW_MIN:WINDOW_MAX) .* (cos(TEMP_ANGLE)) ) ...
            + (TRAJECTORY(i).Y(WINDOW_MIN:WINDOW_MAX) .* (sin(TEMP_ANGLE)) );
        
        %Need to remove outliers now.
        PARALLEL = filloutliers(PARALLEL,'linear');
        
        %Fit the positions to a slope to determine velocity
        PARALLEL_FIT = fitlm((1:length(PARALLEL)),PARALLEL);
        
        %Store parallel velocities, with rescaling
        TRAJECTORY(i).PARVEL(t) = PARALLEL_FIT.Coefficients.Estimate(2)*pixelConv/timeConv;
        
        %Coordinate transform using TEMP_ANGLE, to make a perpendicular direction
        PERPENDI = -(TRAJECTORY(i).X(WINDOW_MIN:WINDOW_MAX) .* (sin(TEMP_ANGLE)) ) ...
               + (TRAJECTORY(i).Y(WINDOW_MIN:WINDOW_MAX) .* (cos(TEMP_ANGLE)) );
        
        %Need to remove outliers now.
        PERPENDI = filloutliers(PERPENDI,'linear');
        
        %Fit the positions to a slope to determine velocity
        PERPENDI_FIT = fitlm((1:length(PERPENDI)),PERPENDI);
        
        %Store parallel velocities
        TRAJECTORY(i).PERPVEL(t) = PERPENDI_FIT.Coefficients.Estimate(2)*pixelConv/timeConv;
        
        
    end
    
    %Rescale x,y,length if necessary
    if pixelConv ~= 1
        TRAJECTORY(i).X = TRAJECTORY(i).X*pixelConv;
        TRAJECTORY(i).Y = TRAJECTORY(i).Y*pixelConv;
        if isfield(TRAJECTORY,'LENGTH')
            TRAJECTORY(i).LENGTH = TRAJECTORY(i).LENGTH*pixelConv;
        end
    end
            
    %Smooth out the velocity to fill in NaN holes where it is reasonable
%    TRAJECTORY(i).VEL = smooth(TRAJECTORY(i).VEL);
%    plot(TRAJECTORY(i).VEL);
end
end