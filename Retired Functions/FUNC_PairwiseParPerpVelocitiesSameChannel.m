function [REL_PARVEL, REL_PERPVEL, DISTANCE] = FUNC_PairwiseParPerpVelocitiesSameChannel(TRAJECTORY)
%Calculate the velocity pair by pair. TRAJECTORY should be a structure
%containing FRAME, X, Y, LENGTH, ORIENT, PARVEL, PERPVEL fields.

REL_PARVEL = [];
REL_PERPVEL = [];
DISTANCE = [];

%go through every possible set of MT pairs
for i = 1:(length(TRAJECTORY)-1) 
for j = (i+1):length(TRAJECTORY)
    
    %Find matching frames
    [~, i_INDEX, j_INDEX] = intersect(TRAJECTORY(i).FRAME,TRAJECTORY(j).FRAME); 
    for k = 1:length(i_INDEX) %Iterate over matching frames

        
        %Find naive velocity
        TEMP_REL_PARVEL = TRAJECTORY(i).PARVEL(i_INDEX(k)) - TRAJECTORY(j).PARVEL(j_INDEX(k)); 
        TEMP_REL_PERPVEL = TRAJECTORY(i).PERPVEL(i_INDEX(k)) - TRAJECTORY(j).PERPVEL(j_INDEX(k)); 

     %   if abs(TRAJECTORY(i).VEL(i_INDEX(k))) < 0.8 || abs(TRAJECTORY(j).VEL(j_INDEX(k))) < 0.8
     %       TEMP_REL_VEL = NaN;
     %   end
        
        
        %Only bother if REL_VEL is not NaN
        if (isnan(TEMP_REL_PARVEL) == 0 && isnan(TEMP_REL_PERPVEL) == 0)
            %Find positions to calculate extensile/contractile velocity
            XPOS_i = TRAJECTORY(i).X(i_INDEX(k)); 
            XPOS_j = TRAJECTORY(j).X(j_INDEX(k));
            YPOS_i = TRAJECTORY(i).Y(i_INDEX(k));
            YPOS_j = TRAJECTORY(j).Y(j_INDEX(k));

            %Do the coordinate transform using only the Angle of first MT
            ANGLE_i = TRAJECTORY(i).ORIENT(1); 
            PARPOS_i = XPOS_i * (cos(   ANGLE_i)) + YPOS_i * (sin(   ANGLE_i));
            PARPOS_j = XPOS_j * (cos(   ANGLE_i)) + YPOS_j * (sin(   ANGLE_i));

            PERPPOS_i = -XPOS_i * (sin(   ANGLE_i)) + YPOS_i * (cos(   ANGLE_i));
            PERPPOS_j = -XPOS_j * (sin(   ANGLE_i)) + YPOS_j * (cos(   ANGLE_i));
            
            %Make sure TEMP_REL_VEL has correct sign for extensile/contractile velocity
            if PARPOS_i < PARPOS_j  
                TEMP_REL_PARVEL = -TEMP_REL_PARVEL;
            end
            if PERPPOS_i < PERPPOS_j  
                TEMP_REL_PERPVEL = -TEMP_REL_PERPVEL;
            end

            %Store the results, and calculate the distance for the pair
            REL_PARVEL(end+1)  = TEMP_REL_PARVEL;
            REL_PERPVEL(end+1)  = TEMP_REL_PERPVEL;
            DISTANCE(end+1) = sqrt((XPOS_i -  XPOS_j)^2 + (YPOS_i -  YPOS_j)^2);
        end
        

    end
end
end


end