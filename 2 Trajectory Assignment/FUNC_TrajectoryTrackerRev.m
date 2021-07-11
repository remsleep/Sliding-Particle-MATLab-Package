function [FIN_TRAJECTORY] = FUNC_TrajectoryTrackerRev(MT_DATA, parameters, framesTot)
%%This function finds trajectories from microtubule locations and 
%%orientations using a number of allowed parameters for cost functions.
%%PARAMETERS is a 1x4 array containing the desired
%%maximum displacements, rotations, scales, and frames allowed between
%%subsequent frames for a microtubule to be correlated. MT_DATA is a 5xN
%%array that contains the frames in which microtubules appear, microtubule
%%lengths, orientations, and x-y positions for N detected microtubules.
%%FRAMESTOT is the total number of frames over which trajectories will be
%%detected.

%%Split and reassign parameters and data
%MT data
MT_FRAME = MT_DATA(1,:);
MT_LENGTH = MT_DATA(2,:);
MT_ORIENT = MT_DATA(3,:);
MT_X = MT_DATA(4,:);
MT_Y = MT_DATA(5,:);
%Parameters
MAX_DISPLACEMENT = parameters(1);    %in pixels
MAX_ROTATION     = parameters(2);   %in Radians
MAX_SCALE        = parameters(3);   %in Percent
MIN_FRAMES       = parameters(4);     %How many frames does the MT need to be in before it counts?

%Find number of detected objects in first framesTot number of frames
if nargin == 3
    lastMT = numel(find(MT_FRAME <= framesTot));
elseif nargin == 2
    lastMT = numel(MT_FRAME);
end

%% Grab every microtubule in frame 1
TRAJECTORY = struct();

    TRAJECTORY.FRAME = MT_FRAME(MT_FRAME == 1);
    TRAJECTORY.X = MT_X(MT_FRAME == 1);
    TRAJECTORY.Y = MT_Y(MT_FRAME == 1);
    TRAJECTORY.LENGTH = MT_LENGTH(MT_FRAME == 1);
    TRAJECTORY.ORIENT = MT_ORIENT(MT_FRAME == 1);


%% Either Match an MT, or create a new chain for it for each time frame t

%We will use this to store finished trajectories
%The first data point is for sizing and will be removed at end of code
FIN_TRAJECTORY = TRAJECTORY(1);

for currMT = numel(TRAJECTORY):lastMT %Go through every MT we see (currentMT)
    
    CANDIDATES = zeros(1,lastMT - numel(TRAJECTORY) + 1); %We want to check if we manage to use this MT or not
    compMT = 1;
    
    while compMT <= numel(TRAJECTORY)%Go through every trajectory already, see if MT belongs there (comparing MT)
        %if trajectory not tracked within last two frames, the trajectory
        %is over and should be considered for storage and then removed
        if TRAJECTORY(compMT).FRAME(end) < (MT_FRAME(currMT) - 2) %Was this Trajectory not tracked within the last two frames?
            if length(TRAJECTORY(compMT).FRAME) > MIN_FRAMES  %If so, is it long enough to store?
                FIN_TRAJECTORY(end+1) = TRAJECTORY(compMT);  %store it
            end
            TRAJECTORY(compMT) = [];                     %remove it from the list of active trajectories
            
        else
            SCALE = mean(TRAJECTORY(compMT).LENGTH) /MT_LENGTH(currMT);
            SCALE_CHECK = SCALE < (1+MAX_SCALE) && SCALE > (1-MAX_SCALE);
            if SCALE_CHECK %Check scale hasn't changed by a factor of 20% Do this first b.c. it's fastest
                ANGLE_SIMPLE = abs(TRAJECTORY(compMT).ORIENT(end) - MT_ORIENT(currMT));  %Orientation is -pi/2 to pi/2
                ANGLE_DIFFICULT = abs(abs(TRAJECTORY(compMT).ORIENT(end) - MT_ORIENT(currMT)) - pi) ;
                ANGLE = min(ANGLE_SIMPLE,ANGLE_DIFFICULT);%%there will be an obtuse and acute angle; need acute angle
                if ANGLE < MAX_ROTATION  %Check angle rotation isn't more than MAX_ROTATION
                    %Get X and Y distances
                    DISTANCE_Y = abs(TRAJECTORY(compMT).Y(end) - MT_Y(currMT));
                    DISTANCE_X = abs(TRAJECTORY(compMT).X(end) - MT_X(currMT));
                    %Get total distance, and the distance in the parallel basis
                    DISTANCE  = sqrt(  DISTANCE_X^2 + DISTANCE_Y^2  );
                    if DISTANCE < MAX_DISPLACEMENT %Check distance is less than max displacement      
                        if TRAJECTORY(compMT).FRAME(end) ~= MT_FRAME(currMT)
                            CANDIDATES(compMT) = compMT;
                        end
                    end
                end
            end
            compMT = compMT + 1;
        end
    end
    CANDIDATES = CANDIDATES(CANDIDATES ~= 0);
    
    
    %THIS SECTION IS TO TRY TO FIND THE BEST MATCH IN A CASE OF MULTIPLE
    %MATCHES

    if length(CANDIDATES) > 1
    %finding candidate that is closest in distance to currMT
    DISTANCE_ARRAY = zeros(1,numel(CANDIDATES)); 
        for currConflict = CANDIDATES
                    DISTANCE_Y = abs(TRAJECTORY(currConflict).Y(end) - MT_Y(currMT));
                    DISTANCE_X = abs(TRAJECTORY(currConflict).X(end) - MT_X(currMT));
                    %Get total distance, and the distance in the parallel bsais
                    DISTANCE  = sqrt(  DISTANCE_X^2 + DISTANCE_Y^2  );
                    DISTANCE_ARRAY(CANDIDATES == currConflict) = DISTANCE;
        end
        CANDIDATES = CANDIDATES(DISTANCE_ARRAY == min(DISTANCE_ARRAY));
    end

    
    if length(CANDIDATES) == 1
        currConflict = CANDIDATES(1);
        if TRAJECTORY(currConflict).FRAME(end) == (MT_FRAME(currMT) - 2) %If this is from two frames ago, we need to update it twice.
            TRAJECTORY(currConflict).FRAME(end+1) = MT_FRAME(currMT)-1;
            TRAJECTORY(currConflict).X(end+1) = (MT_X(currMT) + TRAJECTORY(currConflict).X(end))/2;
            TRAJECTORY(currConflict).Y(end+1) = (MT_Y(currMT) + TRAJECTORY(currConflict).Y(end))/2;
            TRAJECTORY(currConflict).LENGTH(end+1) = MT_LENGTH(currMT);
            TRAJECTORY(currConflict).ORIENT(end+1) = MT_ORIENT(currMT);
        end
        TRAJECTORY(currConflict).FRAME(end+1) = MT_FRAME(currMT);
        TRAJECTORY(currConflict).X(end+1) = MT_X(currMT);
        TRAJECTORY(currConflict).Y(end+1) = MT_Y(currMT);
        TRAJECTORY(currConflict).LENGTH(end+1) = MT_LENGTH(currMT);
        TRAJECTORY(currConflict).ORIENT(end+1) = MT_ORIENT(currMT);
    else     %If MT has no candidates, start a new trajectory with it
        TRAJECTORY(end+1).FRAME = MT_FRAME(currMT);
        TRAJECTORY(end).X = MT_X(currMT);
        TRAJECTORY(end).Y = MT_Y(currMT);
        TRAJECTORY(end).LENGTH = MT_LENGTH(currMT);
        TRAJECTORY(end).ORIENT = MT_ORIENT(currMT);
    end
    
    
    
end


%% Again remove any trajectories that have less than MIN_FRAMES frames, store the rest
%We have to do this twice because a lot of trajectories were still open at
%the end of the other loop
trajNum = 1;
while trajNum <= length(TRAJECTORY)
    if length(TRAJECTORY(trajNum).FRAME) > MIN_FRAMES
        %Store it
        FIN_TRAJECTORY(end+1) = TRAJECTORY(trajNum);
        trajNum = trajNum + 1;
    else
        %Remove it
        TRAJECTORY(trajNum) = [];
    end
end

%Remove the 1st data point we added earlier
FIN_TRAJECTORY(1:2) = [];
