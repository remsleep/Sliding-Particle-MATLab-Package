function [REL_PARVEL, REL_PERPVEL, DISTANCE, COORD_MATRIX, DELTAANG, FRAMES] = ...
    FUNC_PairwiseParPerpVelocitiesSameChannelArrayLower(velInfo, WINDOW, cutOffAngle)
%Calculate the velocity pair by pair. VELINFO is a structure containing
%     {'FRAME'        }
%     {'X'            }
%     {'Y'            }
%     {'LENGTH'       }
%     {'ORIENT'       }
%     {'OBJECT_NUMBER'}
%     {'PARVEL'       }
%     {'PERPVEL'      }
% as fields. The script converts these fields into arrays for efficient
% manipulation. WINDOW is te window over which velocitis were averaged.
% The code will remove the first (WINDOW-1) velocity entries from each
% trajectory in order to avoid counting "incomplete" data. CUTOFFANGLE is a
% variable indicating the maximum angular difference particles are allowed
% to be at to allow the user to calculate relative velocities between the
% two.
%NOTE: All numerical arrays stored in these fields must be row
% vectors, not column vectors. One can use vertcat(velInfo.FIELD)'
% rather than [velInfo.FIELD] below for fields not structured in this way
% This is a copy of FUNC_PairwiseParPerpVelocitiesSameChannelArray but
% every instance of triu has been replaced with tril

%Set value of WINDOW if unset by user
if nargin == 1
    WINDOW = 1;
    cutOffAngle = pi;
end

%Insert markers for invalid velocity values depending on WINDOW size
if WINDOW > 1
    for currTraj = 1:numel(velInfo)
        numFrames = numel(velInfo(currTraj).FRAME);
        velInfo(currTraj).FRAME(1:min(numFrames,WINDOW-1)) = 0;
    end
end

%Extract arrays from VELINFO structure
FRAME = [velInfo.FRAME];
X = [velInfo.X];
Y = [velInfo.Y];
ORIENT = [velInfo.ORIENT];
PARVEL = [velInfo.PARVEL];
PERPVEL = [velInfo.PERPVEL];


%Count pairs to preallocate space
pairNum = 0;
for currFrame = 1:max(FRAME)                    %Iterate through frames and count trajectory pairs in each
    numberTrajsInFrame = sum(FRAME == currFrame);
    if numberTrajsInFrame > 1
        pairNum = pairNum + nchoosek(numberTrajsInFrame,2);
%     else
%         pairNum
    end
end

%Initialize matrices
REL_PARVEL = zeros(1, pairNum);
REL_PERPVEL = REL_PARVEL;
DISTANCE = REL_PARVEL;
PARDIFFS = REL_PARVEL;
PERPDIFFS = REL_PARVEL;
DELTAANG = REL_PARVEL;
FRAMES = REL_PARVEL;
% parCoord1 = REL_PARVEL;
% perpCoord1 = REL_PARVEL;
% parCoord2 = REL_PARVEL;
% perpCoord2 = REL_PARVEL;

%Define counter index
countInd = 1;

%Iterate through time and get relative velocity pairs
for currFrame = 1:max(FRAME)
    
    %Logic vector indicating indices of trajectories in current frame
    trajsInFrame = (FRAME == currFrame);                
    
    if sum(trajsInFrame) > 0
      
        %Store parallel and perpendicular velocities associated at these times
        tempParVels = PARVEL(trajsInFrame);
        tempPerpVels = PERPVEL(trajsInFrame);
        %Exploit outer product to find relative velocities between all pairs
        relParVels = ((tempParVels(:).'- tempParVels(:))');
        relPerpVels = ((tempPerpVels(:).'- tempPerpVels(:))');
        
        %NOTE: In all matrices below, rows represent info of the reference
        %particle (particle 1), while columns represent info of the paired
        %particle (particle 2).
  
        %Store x, y positions and angle
        tempX = X(trajsInFrame);
        tempY = Y(trajsInFrame);
        tempAng = ORIENT(trajsInFrame);

        %%%Calculate coordinates in parallel, perpendicular frame using
        %%%orientation of "particle 1"
        %First, define matrices of differences in x and y between each trajectory
        diffXMat = ((tempX(:).'-tempX(:))');
        diffYMat = ((tempY(:).'-tempY(:))');
        diffAngMat = wrapToPi(2*tril((tempAng(:).'-tempAng(:))'))/2;              
        %Define matrix of angles to be used to calculate cos(theta1) and sin(theta1)
        angleMat = (ones(numel(tempAng),1)'.*tempAng(:));
        %Find transformed coordinates
        diffParCoordMat = diffXMat.*cos(angleMat) + diffYMat.*sin(angleMat);
        diffPerpCoordMat = -diffXMat.*sin(angleMat) + diffYMat.*cos(angleMat);
        
        %Use the sign of the transformed coordinates to finalize sign of vels
%         relParVels = relParVels.*sign(diffParCoordMat);
%         relPerpVels = relPerpVels.*sign(diffPerpCoordMat);

        %Use the outer product to calculate separation of particles
        separations = sqrt(diffXMat.^2 + diffYMat.^2);

        %Reorder data into vector form by using separations to identify non-zero entries
            %Filter based on angle diff. with logic matrices
        outliersMat = ~(abs(diffAngMat) >= abs(cutOffAngle));
        indexMat = logical(tril(true(size(separations)),-1).*(outliersMat));    
        sizeData = sum(sum(indexMat));

            %Store data
        REL_PARVEL(countInd:(countInd+sizeData-1)) = relParVels(indexMat)';
        REL_PERPVEL(countInd:(countInd+sizeData-1)) = relPerpVels(indexMat)';
        DISTANCE(countInd:(countInd+sizeData-1)) = separations(indexMat)';

        PARDIFFS(countInd:(countInd+sizeData-1)) = diffParCoordMat(indexMat);
        PERPDIFFS(countInd:(countInd+sizeData-1)) = diffPerpCoordMat(indexMat);
        
        DELTAANG(countInd:(countInd+sizeData-1)) = diffAngMat(indexMat);
        
        FRAMES(countInd:(countInd+sizeData-1)) = currFrame;
        
        %%The following is used to store the coordinates of ref. and paired
        %%particles rather than the relative position of the paired
        %%particle relative to the ref. particle at the origin.
%         %Make x and y matrices for coordinate storage in (x,y)_1 and
%         %(x,y)_2 
%         tempXMat = repmat(tempX, numel(tempX), 1)';
%         tempYMat = repmat(tempY, numel(tempY), 1)';
%         tempXMat2 = tempXMat';
%         tempYMat2 = tempYMat';
%         
%         %Transform coordinates to par. perp. directions; paired particle (2)
%         %is transformed wrt reference particle's (1) angle
%         tempParCoord1 = tempXMat.*cos(angleMat) + tempYMat.*sin(angleMat);
%         tempPerpCoord1 = -tempXMat.*sin(angleMat) + tempYMat.*cos(angleMat);
%         tempParCoord2 = tempXMat2.*cos(angleMat) + tempYMat2.*sin(angleMat);
%         tempPerpCoord2 = -tempXMat2.*sin(angleMat) + tempYMat2.*cos(angleMat);
%         %Find transformed differences
%         diffParCoordMat = tril(tempParCoord1 - tempParCoord2);
%         diffPerpCoordMat = tril(tempPerpCoord1 - tempPerpCoord2);
%         
%         %Add to (x,y)_1 and (x,y)_2 matrix
%         parCoord1(countInd:(countInd+sizeData-1)) = tempParCoord1(indexMat);
%         perpCoord1(countInd:(countInd+sizeData-1)) = tempPerpCoord1(indexMat);
%         parCoord2(countInd:(countInd+sizeData-1)) = tempParCoord2(indexMat);
%         perpCoord2(countInd:(countInd+sizeData-1)) = tempPerpCoord2(indexMat);
        
        %Update countID
        countInd = countInd + sizeData;
    end
end

%Combine coordinates
% COORD_MATRIX = [parCoord1; perpCoord1; parCoord2; perpCoord2];
COORD_MATRIX = [PARDIFFS; PERPDIFFS];

%Pair down vectors based on non-zero separation of MTs
zeroStart = find(diff(DISTANCE == 0), 1, 'last' );
if ~isempty(zeroStart)
    REL_PARVEL = REL_PARVEL(1:zeroStart);
    REL_PERPVEL = REL_PERPVEL(1:zeroStart);
    DISTANCE = DISTANCE(1:zeroStart);
    COORD_MATRIX = COORD_MATRIX(:, 1:zeroStart);
    DELTAANG = DELTAANG(:, 1:zeroStart);
    FRAMES = FRAMES(:, 1:zeroStart);
end

end