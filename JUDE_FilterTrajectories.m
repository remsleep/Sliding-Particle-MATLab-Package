function FILT_TRAJECTORY = JUDE_FilterTrajectories(TRAJECTORY)
%JUDE_FILTERTRAJECTORIES This function takes in a structure that contains
%all of the trajectories detected from the data and filters through
%trajectories that involve zigzagging. In particular, the function breaks
%up a trajectory where the zigzag occurs by creating a trajectory with the
%microtubules before the zigzag and another trajectory with the
%microtubules after the zig zag. 
%   Detailed explanation goes here
    numTraj = length(TRAJECTORY);
    FILT_TRAJECTORY = TRAJECTORY;
    for trajNum = 1:numTraj
        
        currTraj = TRAJECTORY(trajNum);
        currX = currTraj.X;
        currY = currTraj.Y;
        outliersX = isoutlier(diff(currX));
        outliersY = isoutlier(diff(currY));
        badIndices = find(outliersX + outliersY >= 1);
        
        if isempty(badIndices)
            FILT_TRAJECTORY = [FILT_TRAJECTORY TRAJECTORY(trajNum)];
            continue;
        end
        
        
        %This part identifies which MTs in the trajectory shouldnt be there
        badMTs = [];
        counter = 1;
        
        for currIndex = 1:length(badIndices)
            if (badIndices(currIndex) == 1)
                badMTs(counter) = badIndices(currIndex);
                counter = counter + 1;
            end
            
            if currIndex > 1
                if (badIndices(currIndex) == badIndices(currIndex - 1) + 1) 
                    badMTs(counter) = badIndices(currIndex); 
                    counter = counter + 1;
                end  
            end
            
        end
        
        if (badIndices(end) == length(currX))
            badMTs(counter) = badIndices(end) + 1;
        end
        
        
        %Now that we know which MTs are bad, we can split the trajectory to
        %remove the incorrect MTs from our data
        if isempty(badMTs)
            FILT_TRAJECTORY = [FILT_TRAJECTORY TRAJECTORY(trajNum)];
            continue;
        end
        
        splitTraj = struct();
        splitTrajNum = 1;
        splitTraj.FRAME = [];
        splitTraj.X = [];
        splitTraj.Y = [];
        splitTraj.LENGTH = [];
        splitTraj. ORIENT = [];
        splitTrajNum = splitTrajNum + 1;
        if (badMTs(1) - 1 >= 3)
            splitTraj(splitTrajNum).FRAME = TRAJECTORY(trajNum).FRAME(1:badMTs(1)-1);
            splitTraj(splitTrajNum).X = TRAJECTORY(trajNum).X(1:badMTs(1)-1);
            splitTraj(splitTrajNum).Y = TRAJECTORY(trajNum).Y(1:badMTs(1)-1);
            splitTraj(splitTrajNum).LENGTH = TRAJECTORY(trajNum).LENGTH(1:badMTs(1)-1);
            splitTraj(splitTrajNum).ORIENT = TRAJECTORY(trajNum).ORIENT(1:badMTs(1)-1);
            splitTrajNum = splitTrajNum + 1;
        end
        
        for currMT = 1:length(badMTs) - 1
            if (badMTs(currMT + 1) - badMTs(currMT) - 1 >= 3)
                splitTraj(splitTrajNum).FRAME = TRAJECTORY(trajNum).FRAME(badMTs(currMT)+1:badMTs(currMT + 1)-1);
                splitTraj(splitTrajNum).X = TRAJECTORY(trajNum).X(badMTs(currMT)+1:badMTs(currMT + 1)-1);
                splitTraj(splitTrajNum).Y = TRAJECTORY(trajNum).Y(badMTs(currMT)+1:badMTs(currMT + 1)-1);
                splitTraj(splitTrajNum).LENGTH = TRAJECTORY(trajNum).LENGTH(badMTs(currMT)+1:badMTs(currMT + 1)-1);
                splitTraj(splitTrajNum).ORIENT = TRAJECTORY(trajNum).ORIENT(badMTs(currMT)+1:badMTs(currMT + 1)-1);
                splitTrajNum = splitTrajNum + 1;
            end
        end
        
        if (length(currX) - badMTs(end) >= 3)
            splitTraj(splitTrajNum).FRAME = TRAJECTORY(trajNum).FRAME(badMTs(end)+1:end);
            splitTraj(splitTrajNum).X = TRAJECTORY(trajNum).X(badMTs(end)+1:end);
            splitTraj(splitTrajNum).Y = TRAJECTORY(trajNum).Y(badMTs(end)+1:end);
            splitTraj(splitTrajNum).LENGTH = TRAJECTORY(trajNum).LENGTH(badMTs(end)+1:end);
            splitTraj(splitTrajNum).ORIENT = TRAJECTORY(trajNum).ORIENT(badMTs(end)+1:end);
        end
        

        currTrajLength = length(FILT_TRAJECTORY);
        FILT_TRAJECTORY = [FILT_TRAJECTORY splitTraj];
        FILT_TRAJECTORY(currTrajLength + 1) = [];
        
    end
    FILT_TRAJECTORY(1:numTraj) = [];
    
    %Filter Out Trajectories that have too much variance for outliers to be
    %detected
    badTrajs = [];
    
    for trajNum = 1:numTraj
        standardDevX = std(diff(FILT_TRAJECTORY(trajNum).X));
        standardDevY = std(diff(FILT_TRAJECTORY(trajNum).Y));
        avgDiffX = abs(mean(diff(FILT_TRAJECTORY(trajNum).X)));
        avgDiffY = abs(mean(diff(FILT_TRAJECTORY(trajNum).X)));
        if standardDevX >=  mean(avgDiffX) || standardDevY >= mean(avgDiffY)
            badTrajs = [badTrajs, trajNum];
        end
    end
    
    FILT_TRAJECTORY(badTrajs) = [];
end

