function [REL_VEL, DISTANCE] = FUNC_PairwiseVelocity(TRAJECTORY)
%Calculate the velocity pair by pair

REL_VEL = [];
DISTANCE = [];

%go through every possible set of MT pairs
for i = 1:(length(TRAJECTORY)-1) 
for j = (i+1):length(TRAJECTORY)
    
    %Find matching frames
    [~, i_INDEX, j_INDEX] = intersect(TRAJECTORY(i).FRAME,TRAJECTORY(j).FRAME); 
    for k = 1:length(i_INDEX) %Iterate over matching frames

        
        %Find naive velocity
        TEMP_REL_VEL = TRAJECTORY(i).VEL(i_INDEX(k)) - TRAJECTORY(j).VEL(j_INDEX(k)); 

     %   if abs(TRAJECTORY(i).VEL(i_INDEX(k))) < 0.8 || abs(TRAJECTORY(j).VEL(j_INDEX(k))) < 0.8
     %       TEMP_REL_VEL = NaN;
     %   end
        
        
        %Only bother if REL_VEL is not NaN
        if isnan(TEMP_REL_VEL) == 0 
            %Find positions to calculate extensile/contractile velocity
            XPOS_i = TRAJECTORY(i).X(i_INDEX(k)); 
            XPOS_j = TRAJECTORY(j).X(j_INDEX(k));
            YPOS_i = TRAJECTORY(i).Y(i_INDEX(k));
            YPOS_j = TRAJECTORY(j).Y(j_INDEX(k));

            %Do the coordinate transform using only the Angle of first MT
            ANGLE_i = TRAJECTORY(i).ORIENT(1); 
            POS_i = XPOS_i * abs(cos(   ANGLE_i)) + YPOS_i * abs(sin(   ANGLE_i));
            POS_j = XPOS_j * abs(cos(   ANGLE_i)) + YPOS_j * abs(sin(   ANGLE_i));

            %Make sure TEMP_REL_VEL has correct sign for extensile/contractile velocity
            if POS_i < POS_j  
                TEMP_REL_VEL = -TEMP_REL_VEL;
            end

            %Store the results, and calculate the distance for the pair
            REL_VEL(end+1)  = TEMP_REL_VEL;
            DISTANCE(end+1) = sqrt((XPOS_i -  XPOS_j)^2 + (YPOS_i -  YPOS_j)^2);
        end

    end
end
end


end