%%This script reorganizes Trajectory Data from Main_AnalyzeParamSweeps so
%%that it can be plugged into the velocity finding scripts while retaining
%%information about what channel each trajectory is from

C1_TrajArray = JUDE_TrajStructure2Array(C1_TRAJ);
columnC1 = ones(length(C1_TrajArray),1);
C1_TrajArray = [C1_TrajArray columnC1];


C2_TrajArray = JUDE_TrajStructure2Array(C2_TRAJ);
columnC2 = zeros(length(C2_TrajArray),1);
columnC2(:) = 2;
C2_TrajArray = [C2_TrajArray columnC2];


%%making sure MTs in diff channels have diff IDs
C2_TrajArray(:,5) = C2_TrajArray(:,5) + max(C1_TrajArray(:,5));
    
%%combining data from both channels into single matrix
BOTH_TRAJ = [C1_TrajArray; C2_TrajArray];