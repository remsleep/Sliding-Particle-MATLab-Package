%Track Tracer MTs, OUTPUT: A STRUCTURE OF MT'S, EACH WITH A SET OF FRAMES
%CORRESPONDING POSITIONS, AND ANGLES
%

function [FIN_TRAJECTORY] = FUNC_Tracer_Trajectory_Tracker(MT_FRAME, MT_LENGTH, MT_ORIENT, MT_X, MT_Y)

MAX_DISPLACEMENT = 100;    %in pixels
MAX_ROTATION     = 0.05;   %in Radians
MAX_SCALE        = 0.05;   %in Percent
MIN_FRAMES       = 3;     %How many frames does the MT need to be in before it counts?


%% Grab every original MT
k = 1;
while MT_FRAME(k) == 1
    TRAJECTORY(k).FRAME = MT_FRAME(k);
    TRAJECTORY(k).X = MT_X(k);
    TRAJECTORY(k).Y = MT_Y(k);
    TRAJECTORY(k).LENGTH = MT_LENGTH(k);
    TRAJECTORY(k).ORIENT = MT_ORIENT(k);
    k = k + 1;
end

%% Either Match an MT, or create a new chain for it for each time frame t

%We will use this to store finished trajectories
%The first data point is for sizing and will be removed at end of code
FIN_TRAJECTORY = TRAJECTORY(1);

for j = k:length(MT_X) %Go through every MT we see
    
    CANDIDATES = []; %We want to check if we manage to use this MT or not
    i = 1;
    while i <= length(TRAJECTORY) %Go through every trajectory already, see if MT belongs there
        
        if TRAJECTORY(i).FRAME(end) < (MT_FRAME(j) - 2) %Was this Trajectory tracked within the last two frames?
            if length(TRAJECTORY(i).FRAME) > MIN_FRAMES  %If not, is it long enough to store?
                FIN_TRAJECTORY(end+1) = TRAJECTORY(i);  %store it
            end
            TRAJECTORY(i) = [];                     %remove it from the list of active trajectories
            
        else
            SCALE = mean(TRAJECTORY(i).LENGTH) /MT_LENGTH(j);
            SCALE_CHECK = SCALE < (1+MAX_SCALE) && SCALE > (1-MAX_SCALE);
            if SCALE_CHECK %Check scale hasn't changed by a factor of 20% Do this first b.c. it's fastest
                ANGLE_SIMPLE = abs(TRAJECTORY(i).ORIENT(end) - MT_ORIENT(j));  %Orientation is -pi/2 to pi/2
                ANGLE_DIFFICULT = abs(abs(TRAJECTORY(i).ORIENT(end) - MT_ORIENT(j)) - pi) ;
                ANGLE = min(ANGLE_SIMPLE,ANGLE_DIFFICULT);
                if ANGLE < MAX_ROTATION  %Check angle rotation isn't more than MAX_ROTATION
                    %Get X and Y distances
                    DISTANCE_Y = abs(TRAJECTORY(i).Y(end) - MT_Y(j));
                    DISTANCE_X = abs(TRAJECTORY(i).X(end) - MT_X(j));
                    %Get total distance, and the distance in the parallel bsais
                    DISTANCE  = sqrt(  DISTANCE_X^2 + DISTANCE_Y^2  );
                    if DISTANCE < MAX_DISPLACEMENT %Check distance is less than max displacement      
                        CANDIDATES = [CANDIDATES i];
                    end
                end
            end
            i = i+1;
        end
    end
    
    %THIS SECTION IS TO TRY TO FIND THE BEST MATCH IN A CASE OF MULTIPLE
    %MATCHES
    if length(CANDIDATES) > 1
        for q = CANDIDATES
            if TRAJECTORY(q).FRAME(end) == (MT_FRAME(j) - 3)
                CANDIDATES(find(q)) = []; 
            end
        end
    end
    if length(CANDIDATES) > 1
    DISTANCE_ARRAY = []; %Set it to an impossible value first
        for q = CANDIDATES
                    DISTANCE_Y = abs(TRAJECTORY(q).Y(end) - MT_Y(j));
                    DISTANCE_X = abs(TRAJECTORY(q).X(end) - MT_X(j));
                    %Get total distance, and the distance in the parallel bsais
                    DISTANCE  = sqrt(  DISTANCE_X^2 + DISTANCE_Y^2  );
                    DISTANCE_ARRAY = [DISTANCE_ARRAY DISTANCE];
        end
       INDEX = find(DISTANCE_ARRAY == min(DISTANCE_ARRAY));
       CANDIDATES = CANDIDATES(INDEX);
    end

    
    if length(CANDIDATES) == 1
        q = CANDIDATES(1);
        if TRAJECTORY(q).FRAME(end) == (MT_FRAME(j) - 2) %If this is from two frames ago, we need to update it twice.
            TRAJECTORY(q).FRAME(end+1) = MT_FRAME(j)-1;
            TRAJECTORY(q).X(end+1) = (MT_X(j) + TRAJECTORY(q).X(end))/2;
            TRAJECTORY(q).Y(end+1) = (MT_Y(j) + TRAJECTORY(q).Y(end))/2;
            TRAJECTORY(q).LENGTH(end+1) = MT_LENGTH(j);
            TRAJECTORY(q).ORIENT(end+1) = MT_ORIENT(j);
        end
        TRAJECTORY(q).FRAME(end+1) = MT_FRAME(j);
        TRAJECTORY(q).X(end+1) = MT_X(j);
        TRAJECTORY(q).Y(end+1) = MT_Y(j);
        TRAJECTORY(q).LENGTH(end+1) = MT_LENGTH(j);
        TRAJECTORY(q).ORIENT(end+1) = MT_ORIENT(j);
    else     %If we didn't use it, start a new chain with it
        TRAJECTORY(end+1).FRAME = MT_FRAME(j);
        TRAJECTORY(end).X = MT_X(j);
        TRAJECTORY(end).Y = MT_Y(j);
        TRAJECTORY(end).LENGTH = MT_LENGTH(j);
        TRAJECTORY(end).ORIENT = MT_ORIENT(j);
    end
    
    
    
end


%% Again remove any trajectories that have less than MIN_FRAMES frames, store the rest
%We have to do this twice because a lot of trajectories were still open at
%the end of the other loop
i = 1;
while i <= length(TRAJECTORY)
    if length(TRAJECTORY(i).FRAME) > MIN_FRAMES
        %Store it
        FIN_TRAJECTORY(end+1) = TRAJECTORY(i);
        i = i + 1;
    else
        %Remove it
        TRAJECTORY(i) = [];
    end
end

%Remove the 1st data point we added earlier
FIN_TRAJECTORY(1) = [];
