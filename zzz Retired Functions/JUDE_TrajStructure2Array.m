%%This functions takes in a structure containing information about MT
%%trajectories and then outputs a corresponding array
function TrajArray = JUDE_TrajStructure2Array(TRAJ)

    %%creating IDs
    for traj = 1:size(TRAJ,2)
        TRAJ(traj).ID = zeros(1,length(TRAJ(traj).FRAME));
        TRAJ(traj).ID(:) = traj;
    end
    %%count elements
    numMTs = 0;
    for traj = 1:size(TRAJ,2)
        numMTs = numMTs + numel(TRAJ(traj).FRAME);
    end
    
    %%Initialize Array
    TrajArray = zeros(numMTs,5);
    
    %%Store Info in Array
    firstIndex = 1;
    for currTraj = 1:size(TRAJ,2)
        TrajArray(firstIndex:firstIndex + numel(TRAJ(currTraj).FRAME)-1,1) = TRAJ(currTraj).FRAME;
        TrajArray(firstIndex:firstIndex + numel(TRAJ(currTraj).FRAME)-1,2) = TRAJ(currTraj).X;
        TrajArray(firstIndex:firstIndex + numel(TRAJ(currTraj).FRAME)-1,3) = TRAJ(currTraj).Y;
        TrajArray(firstIndex:firstIndex + numel(TRAJ(currTraj).FRAME)-1,4) = TRAJ(currTraj).ORIENT;
        TrajArray(firstIndex:firstIndex + numel(TRAJ(currTraj).FRAME)-1,5) = TRAJ(currTraj).ID;
        firstIndex = firstIndex + numel(TRAJ(currTraj).FRAME);
    end


end