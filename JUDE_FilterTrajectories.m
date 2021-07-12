function FILT_TRAJECTORY = JUDE_FilterTrajectories(TRAJECTORY)
%JUDE_FILTERTRAJECTORIES This function takes in a structure that contains
%all of the trajectories detected from the data and filters out
%trajectories that involve zigzagging. In particular, the function breaks
%up a trajectory where the zigzag occurs by creating a trajectory with the
%microtubules before the zigzag and another trajectory with the
%microtubules after the zig zag. 

    numTraj = length(TRAJECTORY);
    FILT_TRAJECTORY = TRAJECTORY;
    %Go through every trajectory and see whether there are outliers in the
    %MTs positional shifts
    for trajNum = 1:numTraj
        
        currTraj = TRAJECTORY(trajNum);
        currX = currTraj.X;
        currY = currTraj.Y;
        outliersX = isoutlier(diff(currX));
        outliersY = isoutlier(diff(currY));
        outliers = outliersX + outliersY;
        badIndices = find(outliers >= 1);
        
        if isempty(badIndices)
            FILT_TRAJECTORY = [FILT_TRAJECTORY TRAJECTORY(trajNum)]; %if there are no outliers, 
            %add og trajectory to final trajectory structure and move on to the next trajectory
            continue;
        end
        
        
        %This part identifies which MTs in the trajectory shouldnt be there
        badMTs = [];
        counter = 1;
        
        for currIndex = 1:length(badIndices)%case where first microtubule in trajectory should be removed
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
            
            if (badIndices(currIndex) ~= 1 && badIndices(currIndex) ~= length(outliers))%for cases between first and last microtubule in a trajectory
                
                if (outliers(badIndices(currIndex) - 1) == 0 && outliers(badIndices(currIndex)+1) == 0)
                    badMTs(counter) = badIndices(currIndex); % for cases where the trajectory 
                    %switches to a different microtubule
                    counter = counter + 1;
                end
            end
            
        end
        
        if (badIndices(end) == length(currX))%if the last microtubule in the trajectory should be removed
            badMTs(counter) = badIndices(end) + 1;
        end
        
        
        %Now that we know which MTs are bad, we can split the trajectory to
        %remove the incorrect MTs from our data
        if isempty(badMTs) %if there are no bad microtubules, we can add the og trajectory to the 
            %final trajectory structure and move on to the next trajectory
            FILT_TRAJECTORY = [FILT_TRAJECTORY TRAJECTORY(trajNum)];
            continue;
        end
        %temporary structure that will contain the split trajectories
        splitTraj = struct();
        splitTrajNum = 1;
        
        splitTraj.FRAME = [];%adding empty spaces for formatting so that I can concatenate later
        splitTraj.X = [];
        splitTraj.Y = [];
        splitTraj.LENGTH = [];
        splitTraj. ORIENT = [];
        splitTrajNum = splitTrajNum + 1;
        if (badMTs(1) - 1 >= 3)%Create trajectory between beginning of OG trajectory 
            %and first bad microtubule
            splitTraj(splitTrajNum).FRAME = TRAJECTORY(trajNum).FRAME(1:badMTs(1)-1);
            splitTraj(splitTrajNum).X = TRAJECTORY(trajNum).X(1:badMTs(1)-1);
            splitTraj(splitTrajNum).Y = TRAJECTORY(trajNum).Y(1:badMTs(1)-1);
            splitTraj(splitTrajNum).LENGTH = TRAJECTORY(trajNum).LENGTH(1:badMTs(1)-1);
            splitTraj(splitTrajNum).ORIENT = TRAJECTORY(trajNum).ORIENT(1:badMTs(1)-1);
            splitTrajNum = splitTrajNum + 1;
        end
        
        for currMT = 1:length(badMTs) - 1
            %creating trajectories between bad microtubules and adding them
            %to splitTraj
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
            %for adding microtubules between last bad microtubule and the
            %end of the og trajectory
            splitTraj(splitTrajNum).FRAME = TRAJECTORY(trajNum).FRAME(badMTs(end)+1:end);
            splitTraj(splitTrajNum).X = TRAJECTORY(trajNum).X(badMTs(end)+1:end);
            splitTraj(splitTrajNum).Y = TRAJECTORY(trajNum).Y(badMTs(end)+1:end);
            splitTraj(splitTrajNum).LENGTH = TRAJECTORY(trajNum).LENGTH(badMTs(end)+1:end);
            splitTraj(splitTrajNum).ORIENT = TRAJECTORY(trajNum).ORIENT(badMTs(end)+1:end);
        end
        

        currTrajLength = length(FILT_TRAJECTORY);
        FILT_TRAJECTORY = [FILT_TRAJECTORY splitTraj];
        %add new trajectories to final trajectory structure
        FILT_TRAJECTORY(currTrajLength + 1) = []; %remove empty formatting data point we added earlier
        
    end
    FILT_TRAJECTORY(1:numTraj) = [];%Remove all original trajectories from final trajectory structure
    
    %Filter Out Trajectories that have too much variance for outliers to be
    %detected
    %Now that we have dealt with trajectories that have obvious outliers,
    %we need to remove trajectories that have consistently large variance in
    %velocity throughout the entire trajectory. This accounts for trajectories 
    %that zigzag for the entire trajectory. We will deal with this by
    %measuring the standard deviation in the positional shifts of the
    %trajectory and see if that is unreasonably large compared to the mean
    %positional shift. 
    badTrajs = [];
    
    
    for trajNum = 1:numTraj
        standardDevX = std(diff(FILT_TRAJECTORY(trajNum).X));
        standardDevY = std(diff(FILT_TRAJECTORY(trajNum).Y));
        avgDiffX = abs(mean(diff(FILT_TRAJECTORY(trajNum).X)));
        avgDiffY = abs(mean(diff(FILT_TRAJECTORY(trajNum).X)));
        if standardDevX >=  mean(avgDiffX) || standardDevY >= mean(avgDiffY) %We dont want 
            %the restriction to be to harsh or else accelerating
            %trajectories will be removed
            badTrajs = [badTrajs, trajNum];
        end
    end
    
    FILT_TRAJECTORY(badTrajs) = [];
end

