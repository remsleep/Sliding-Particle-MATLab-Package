function [allRelVelInfo] = FUNC_PairwiseDiffTrajectoriesVel(TRAJECTORY1, TRAJECTORY2)
%Calculate the velocities of tracked MTs relative to one another across two
%data sets; that is, calculate relative velocities of MTs in one data set
%relative to MTs in the other data set. The TRAJECTORY structures should
%each already have velocities as fields using FUNC_Find_Velocity

REL_VEL = [];
DISTANCE = [];
TRAJ1 = [];
TRAJ2 = [];
FRAMENUM = [];

%go through every possible set of MT pairs
for i = 1:length(TRAJECTORY1) 
for j = 1:length(TRAJECTORY2)
    
    %Find matching frames
    [~, i_INDEX, j_INDEX] = intersect(TRAJECTORY1(i).FRAME,TRAJECTORY2(j).FRAME); 
    for k = 1:length(i_INDEX) %Iterate over matching frames

        
        %Find naive velocity
        TEMP_REL_VEL = TRAJECTORY1(i).VEL(i_INDEX(k)) - TRAJECTORY2(j).VEL(j_INDEX(k)); 

     %   if abs(TRAJECTORY(i).VEL(i_INDEX(k))) < 0.8 || abs(TRAJECTORY(j).VEL(j_INDEX(k))) < 0.8
     %       TEMP_REL_VEL = NaN;
     %   end
        
        
        %Only bother if REL_VEL is not NaN
        if isnan(TEMP_REL_VEL) == 0 
            %Find positions to calculate extensile/contractile velocity
            XPOS_i = TRAJECTORY1(i).X(i_INDEX(k)); 
            XPOS_j = TRAJECTORY2(j).X(j_INDEX(k));
            YPOS_i = TRAJECTORY1(i).Y(i_INDEX(k));
            YPOS_j = TRAJECTORY2(j).Y(j_INDEX(k));

            %Do the coordinate transform using only the Angle of first MT
            ANGLE_i = TRAJECTORY1(i).ORIENT(1); %%%%%%%%%%%%%%%%%%%%%%
            POS_i = XPOS_i * abs(cos(   ANGLE_i)) + YPOS_i * abs(sin(   ANGLE_i));
            POS_j = XPOS_j * abs(cos(   ANGLE_i)) + YPOS_j * abs(sin(   ANGLE_i));

            %Make sure TEMP_REL_VEL has correct sign for extensile/contractile velocity
            if POS_i < POS_j  
                TEMP_REL_VEL = -TEMP_REL_VEL;
            end

            %Store the results, and calculate the distance between the pair
            REL_VEL(end+1)  = TEMP_REL_VEL;
            DISTANCE(end+1) = sqrt((XPOS_i -  XPOS_j)^2 + (YPOS_i -  YPOS_j)^2);
            TRAJ1(end+1) = i;
            TRAJ2(end+1) = j;
            FRAMENUM(end+1) = k;
        end

    end
end
end

allRelVelInfo = [REL_VEL; DISTANCE; TRAJ1; TRAJ2; FRAMENUM];

end