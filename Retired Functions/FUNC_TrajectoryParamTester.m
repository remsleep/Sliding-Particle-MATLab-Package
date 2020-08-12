function [MAX_DISPLACEMENT, MAX_ROTATION, MAX_SCALE, MIN_FRAMES] = ...
    FUNC_TrajectoryParamTester(MT_FRAME, MT_LENGTH, MT_ORIENT, MT_X, MT_Y)
%%This function takes in microtubule location, length, orientation, and 
%%temporal information and allows the user to tune detection parameters to
%%optimally detect trajectories.

%Set default parameter values
MAX_DISPLACEMENT = 100;    %in pixels
MAX_ROTATION     = 0.05;   %in Radians
MAX_SCALE        = 0.05;   %in Percent
MIN_FRAMES       = 3;     %How many frames does the MT need to be in before it counts?

%Initialize TRAJECTORY structure to contain all trajectory information
TRAJECTORY = struct();

%% Grab every original MT
k = 1;
% for currTraj = 1:max 
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

for currMT = k:length(MT_X) %Go through every MT we see
    
    CANDIDATES = []; %We want to check if we manage to use this MT or not
    i = 1;
    while i <= length(TRAJECTORY) %Go through every trajectory already, see if MT belongs there
        
        if TRAJECTORY(i).FRAME(end) < (MT_FRAME(currMT) - 2) %Was this Trajectory tracked within the last two frames?
            if length(TRAJECTORY(i).FRAME) > MIN_FRAMES  %If not, is it long enough to store?
                FIN_TRAJECTORY(end+1) = TRAJECTORY(i);  %store it
            end
            TRAJECTORY(i) = [];                     %remove it from the list of active trajectories          
        else
            SCALE = mean(TRAJECTORY(i).LENGTH) /MT_LENGTH(currMT);
            SCALE_CHECK = SCALE < (1+MAX_SCALE) && SCALE > (1-MAX_SCALE);
            if SCALE_CHECK %Check scale hasn't changed by a factor of 20% Do this first b.c. it's fastest
                ANGLE_SIMPLE = abs(TRAJECTORY(i).ORIENT(end) - MT_ORIENT(currMT));  %Orientation is -pi/2 to pi/2
                ANGLE_DIFFICULT = abs(abs(TRAJECTORY(i).ORIENT(end) - MT_ORIENT(currMT)) - pi) ;
                ANGLE = min(ANGLE_SIMPLE,ANGLE_DIFFICULT);
                if ANGLE < MAX_ROTATION  %Check angle rotation isn't more than MAX_ROTATION
                    %Get X and Y distances
                    DISTANCE_Y = abs(TRAJECTORY(i).Y(end) - MT_Y(currMT));
                    DISTANCE_X = abs(TRAJECTORY(i).X(end) - MT_X(currMT));
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
            if TRAJECTORY(q).FRAME(end) == (MT_FRAME(currMT) - 3)
                CANDIDATES(find(q)) = []; 
            end
        end
    end
    if length(CANDIDATES) > 1
    DISTANCE_ARRAY = []; %Set it to an impossible value first
        for q = CANDIDATES
                    DISTANCE_Y = abs(TRAJECTORY(q).Y(end) - MT_Y(currMT));
                    DISTANCE_X = abs(TRAJECTORY(q).X(end) - MT_X(currMT));
                    %Get total distance, and the distance in the parallel bsais
                    DISTANCE  = sqrt(  DISTANCE_X^2 + DISTANCE_Y^2  );
                    DISTANCE_ARRAY = [DISTANCE_ARRAY DISTANCE];
        end
       INDEX = find(DISTANCE_ARRAY == min(DISTANCE_ARRAY));
       CANDIDATES = CANDIDATES(INDEX);
    end

    
    if length(CANDIDATES) == 1
        q = CANDIDATES(1);
        if TRAJECTORY(q).FRAME(end) == (MT_FRAME(currMT) - 2) %If this is from two frames ago, we need to update it twice.
            TRAJECTORY(q).FRAME(end+1) = MT_FRAME(currMT)-1;
            TRAJECTORY(q).X(end+1) = (MT_X(currMT) + TRAJECTORY(q).X(end))/2;
            TRAJECTORY(q).Y(end+1) = (MT_Y(currMT) + TRAJECTORY(q).Y(end))/2;
            TRAJECTORY(q).LENGTH(end+1) = MT_LENGTH(currMT);
            TRAJECTORY(q).ORIENT(end+1) = MT_ORIENT(currMT);
        end
        TRAJECTORY(q).FRAME(end+1) = MT_FRAME(currMT);
        TRAJECTORY(q).X(end+1) = MT_X(currMT);
        TRAJECTORY(q).Y(end+1) = MT_Y(currMT);
        TRAJECTORY(q).LENGTH(end+1) = MT_LENGTH(currMT);
        TRAJECTORY(q).ORIENT(end+1) = MT_ORIENT(currMT);
    else     %If we didn't use it, start a new chain with it
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

end

function [MAX_DISPLACEMENT, MAX_ROTATION, MAX_SCALE, MAX_FRAMES, notSatisfied] = ...
        updateParameters(MAX_DISPLACEMENT, MAX_ROTATION, MAX_SCALE, MAX_FRAMES)
%%This function allows the usre to update the parameters used when
%%detecting an constructing trajectories.

    %Reset parameter change trigger
    stringtrigger = -1;
    possibleResponses = ['1', 'yes', 'Yes', '0', 'no', 'No'];

    fprintf('\n');
    while ~ismember(stringtrigger, possibleResponses)
        %Adjust LENGTH and WIDTH, if necessary
        fprintf('Current allowed max displacement of MTs: %d; Would you like new values? ',...
            MAX_DISPLACEMENT);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(1:7))
            LENGTH = input('Please input a new LENGTH: '); 
            WIDTH = input('Please input a new WIDTH: ');
            notSatisfied = 1;
        else
            notSatisfied = 0;
        end
        %Adjust pixelMin and pixelMax, if necessary
        fprintf('Current MT pixelMin: %d; Current MT pixelMax: %d.\nWould you like new values? ',...
            pixelMin,pixelMax);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(1:7))
            pixelMin = input('Please input a new pixelMin: ');
            pixelMax = input('Please input a new pixelMax: '); 
            stringtrigger = 'y';
            notSatisfied = 1;
        elseif ismember(stringtrigger, possibleResponses(8:end)) && (notSatisfied == 0)
            notSatisfied = 0;
        end
    end
    
end