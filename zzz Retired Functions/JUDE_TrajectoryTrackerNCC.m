function [FIN_TRAJECTORY] = JUDE_TrajectoryTrackerNCC(MT_DATA, parameters, objPredictions, framesTot)
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
if nargin == 4
    lastMT = numel(find(MT_FRAME <= framesTot));
elseif nargin == 3
    lastMT = numel(MT_FRAME);
end

%% Grab every microtubule in frame 1
TRAJECTORY = struct();

for currMT = 1:numel(find(MT_FRAME == 1))
    TRAJECTORY(currMT).FRAME = MT_FRAME(currMT);
    TRAJECTORY(currMT).X = MT_X(currMT);
    TRAJECTORY(currMT).Y = MT_Y(currMT);
    TRAJECTORY(currMT).LENGTH = MT_LENGTH(currMT);
    TRAJECTORY(currMT).ORIENT = MT_ORIENT(currMT);
end

%% Either Match an MT, or create a new chain for it for each time frame t

%We will use this to store finished trajectories
%The first data point is for sizing and will be removed at end of code
FIN_TRAJECTORY = TRAJECTORY(1);
skip = 0;

for currMT = numel(TRAJECTORY)+1:lastMT %Go through every MT we see (currentMT)
    
    
    currLength = MT_LENGTH(currMT);
    currFrame = MT_FRAME(currMT);
    currX = MT_X(currMT);
    currY = MT_Y(currMT);
    currOrient = MT_ORIENT(currMT);
    
    %Creating bounding box for template
    boxWidth = 2 * (currLength * abs(cos(currOrient)));
    boxHeight = 2 * (currLength * abs(sin(currOrient)));
    boxSide = max(boxWidth,boxHeight);
   
    X_High = ceil(min(size(objPredictions,2), currX + boxSide));
    X_Low = floor(max(1,currX - boxSide));
    Y_High = ceil(min(size(objPredictions,1), currY + boxSide));
    Y_Low = floor(max(1,currY - boxSide));
    
    %create image and template so that they can be cross correlated
    TEMPLATE = objPredictions(Y_Low:Y_High, X_Low:X_High, currFrame);
    posPred = zeros(3,2);
    
    %we are looking at trajectories that last detected a microtubule six
    %frames ago
    if currFrame > 3
        earliestFrame = 3;
    else
        earliestFrame = currFrame - 1;
    end
    
    for prevFrame = 1:earliestFrame
        IMAGE = objPredictions(:,:,currFrame - prevFrame);
        CORRELATION = normxcorr2(TEMPLATE, IMAGE);
        [maxCorrX, maxCorrY] = find(CORRELATION == max(max(CORRELATION)));
        maxCorrX = mean(maxCorrX);
        maxCorrY = mean(maxCorrY);
        
        posShiftX = ((X_High + X_Low)/2) - (maxCorrX - ((X_High - X_Low)/2));
        posShiftY = ((Y_High + Y_Low)/2) - (maxCorrY - ((Y_High - Y_Low)/2));
    
        posPred(prevFrame,:) = [currX - posShiftX, currY - posShiftY];
    end
   
    
    %%CORRELATION = normxcorr2(TEMPLATE,IMAGE);
    %using coords corresponding to max correlation as predicted location of
    %MT
    %%[maxCorrX, maxCorrY] = find(CORRELATION == max(max(CORRELATION)));
    
    %calculating the positional shift between the center of the template to the
    %location of maximum correlation in IMAGE --> this gives the
    %positional shift of the microtubule.
    %%posShiftX = ((X_High + X_Low)/2) - (maxCorrX - ((X_High - X_Low)/2));
    %%posShiftY = ((Y_High + Y_Low)/2) - (maxCorrY - ((Y_High - Y_Low)/2));
    
    %%posPred = [currX - posShiftX, currY - posShiftY];
    
    
    %run through existing trajectories and see which ones have microtubules
    %that are closest to the predicted location and which ones meet
    %criteria set by trajectory parameters input
    CANDIDATES = zeros(1,lastMT - numel(TRAJECTORY) + 1); %We want to check if we manage to use this MT or not
    compMT = 1;
    

    
    while compMT <= numel(TRAJECTORY)%Go through every trajectory already, see if MT belongs there (comparing MT)
        
        
        trajFrame = TRAJECTORY(compMT).FRAME;
        trajX = TRAJECTORY(compMT).X;
        trajY = TRAJECTORY(compMT).Y;
        trajLength = TRAJECTORY(compMT).LENGTH;
        trajOrient = TRAJECTORY(compMT).ORIENT;
        
        %skipping for loops once we start looking at trajectories that end
        %on the same frame as that corresponding to currMT, just to improve
        %run time
        
        if trajFrame < (MT_FRAME(currMT) - 3) %Was this Trajectory not tracked within the last two frames?
            if length(trajFrame) > MIN_FRAMES  %If so, is it long enough to store?
                FIN_TRAJECTORY(end+1) = TRAJECTORY(compMT);  %store it
            end
            TRAJECTORY(compMT) = [];                     %remove it from the list of active trajectories
 
            
        else
        if trajFrame(end) ~= currFrame
            SCALE = mean(trajLength) /MT_LENGTH(currMT);
            SCALE_CHECK = SCALE < (1+MAX_SCALE) && SCALE > (1-MAX_SCALE);
            if SCALE_CHECK %Check scale hasn't changed by a factor of 20% Do this first b.c. it's fastest
                ANGLE_SIMPLE = abs(trajOrient(end) - MT_ORIENT(currMT));  %Orientation is -pi/2 to pi/2
                ANGLE_DIFFICULT = abs(abs(trajOrient(end) - MT_ORIENT(currMT)) - pi) ;
                ANGLE = min(ANGLE_SIMPLE,ANGLE_DIFFICULT);%%there will be an obtuse and acute angle; need acute angle
                if ANGLE < MAX_ROTATION  %Check angle rotation isn't more than MAX_ROTATION
                    %Get X and Y distances
                    DISTANCE_Y = abs(trajY(end) - MT_Y(currMT));
                    DISTANCE_X = abs(trajX(end) - MT_X(currMT));
                    %Get total distance, and the distance in the parallel basis
                    DISTANCE  = sqrt(  DISTANCE_X^2 + DISTANCE_Y^2  );
                    if DISTANCE < MAX_DISPLACEMENT %Check distance is less than max displacement 
                          distFromPred = sqrt(((trajX(end) - posPred(currFrame - trajFrame(end),1))^2) + ...
                                        (((trajY(end) - posPred(currFrame - trajFrame(end),2))^2)));%Pythagorean Thm
                          if distFromPred < 100
                               CANDIDATES(compMT) = compMT;      
                          end
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
    %finding candidate that is closest to location predicted by cross
    %correlation
    DISTANCE_ARRAY = zeros(1,numel(CANDIDATES)); 
    
        for currConflict = CANDIDATES
                    conflictX = TRAJECTORY(currConflict).X(end);
                    conflictY = TRAJECTORY(currConflict).Y(end);
                    conflictFrame = TRAJECTORY(currConflict).FRAME(end);
                    
                    distFromPred = sqrt(((conflictX - posPred(currFrame - conflictFrame,1))^2) + ...
                        ((conflictY - posPred(currFrame - conflictFrame,2))^2));
                  
                    DISTANCE_ARRAY(CANDIDATES == currConflict) = distFromPred;
        end
        CANDIDATES = CANDIDATES(DISTANCE_ARRAY == min(DISTANCE_ARRAY));
    end

    
    if length(CANDIDATES) == 1
        currConflict = CANDIDATES(1);
        conflictFrame = TRAJECTORY(currConflict).FRAME;
        conflictX = TRAJECTORY(currConflict).X;
        conflictY = TRAJECTORY(currConflict).Y;
        if conflictFrame(end) == (MT_FRAME(currMT) - 2) %If this is from two frames ago, we need to update it twice.
            TRAJECTORY(currConflict).FRAME(end+1) = MT_FRAME(currMT)-1;
            TRAJECTORY(currConflict).X(end+1) = (MT_X(currMT) + conflictX(end))/2;
            TRAJECTORY(currConflict).Y(end+1) = (MT_Y(currMT) + conflictY(end))/2;
            TRAJECTORY(currConflict).LENGTH(end+1) = MT_LENGTH(currMT);
            TRAJECTORY(currConflict).ORIENT(end+1) = MT_ORIENT(currMT);
        end
        if TRAJECTORY(currConflict).FRAME(end) == (MT_FRAME(currMT) - 3) %If this is from three frames ago, we need to update it twice.
            TRAJECTORY(currConflict).FRAME(end+1) = MT_FRAME(currMT)-2;
            TRAJECTORY(currConflict).X(end+1) = conflictX(end) + ((MT_X(currMT) - conflictX(end))/3);
            TRAJECTORY(currConflict).Y(end+1) = conflictY(end) + ((MT_Y(currMT) - conflictY(end))/3);
            TRAJECTORY(currConflict).LENGTH(end+1) = MT_LENGTH(currMT);
            TRAJECTORY(currConflict).ORIENT(end+1) = MT_ORIENT(currMT);
            
            TRAJECTORY(currConflict).FRAME(end+1) = MT_FRAME(currMT)-1;
            TRAJECTORY(currConflict).X(end+1) = conflictX(end) + (2 * ((MT_X(currMT) - conflictX(end))/3));
            TRAJECTORY(currConflict).Y(end+1) = conflictY(end) + (2 * ((MT_Y(currMT) - conflictY(end))/3));
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
FIN_TRAJECTORY(1) = [];
