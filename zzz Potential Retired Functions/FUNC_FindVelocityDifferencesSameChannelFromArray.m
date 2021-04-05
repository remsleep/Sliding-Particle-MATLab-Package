function [finalData,truncData] = FUNC_FindVelocityDifferencesSameChannelFromArray(TRAJECTORY,pixelConv,timeConv, cutOffAngle)
%FUNC_FINDVELOCITYDIFFERENCESSAMECHANNELFROMARRAY finds the velocity
%difference between pairs of objects in TRAJECTORY along axes parallel and
%perpendicular to the first (reference) object's director (determined by
%orientation). The script first calculates the positional difference
%between all pairs at all times before rotating those differences into the
%parallel/perpendicular reference frame of the first (reference) object.
%The script then calculates the velocities of objects by dividing by the
%time step between sequential positional differences. Finally, the script
%takes the difference of velocities between all pairs of objects within
%each frame. 
%The function takes in TRAJECTORY, an array containing all x
%and y coordinates, orientations, frames, and length information as fields.
%The array order must be of the form [x, y, frame, orientation, ID]
%The function calculates the velocities of individual particles in a 
%reference frame defined by the directors normal and parallel to each
%particle at a given time.
%PIXELCONV and TIMECONV are conversion variables indicating the number
%of um/pixel and seconds/frame, respectively
%All object pairs with angle difference greater than CUTOFFANGLE are
%ignored and not stored

%% Intialize storage and define variables, if necessary
%Set pixel and time conversions to 1 and cutoff angle to pi if left undefined by user
if nargin == 1
    pixelConv = 1;
    timeConv = 1;
    cutOffAngle = pi;
elseif nargin == 2
    cutOffAngle = pixelConv;
    pixelConv = 1;
    timeConv = 1;
elseif nargin == 3
    cutOffAngle = pi;
end

%Count pairs to preallocate space
pairNum = 0;
for currFrame = 1:max(TRAJECTORY(3,:))                    %Iterate through frames and count trajectory pairs in each
    numberTrajsInFrame = sum(TRAJECTORY(3,:) == currFrame);
    if numberTrajsInFrame > 1
        pairNum = pairNum + nchoosek(numberTrajsInFrame,2);
    end
end

%Initialize storage vectors
diffData = zeros(7,pairNum);
finalData = zeros(9,pairNum);
storInd = 1;

%% Find positional differences between object pairs within the same frames
%Iterate through time to calculate distances between all object pairs
for currFrame = 1:max(TRAJECTORY(3,:))   
    
    %Select all data associated with objects in current frame
    tempInds = TRAJECTORY(3,:) == currFrame;
    tempData = TRAJECTORY(:,tempInds);
    
    %Store IDs in ID matrix
    IDMat = repmat(tempData(5,:),sum(tempInds),1); IDMatTr = IDMat';
    
    %Store x, y, angle coordinates of current data
    tempX = tempData(1,:); tempY = tempData(2,:); tempAng = tempData(4,:);
    
    %Take difference of positions; column index - reference particle
    diffXMat = ((tempX(:).'-tempX(:))'); diffYMat = ((tempY(:).'-tempY(:))');
    
    %Prepare angle matrices for rotation and filtering
    angleMat = repmat(tempAng,numel(tempAng),1);
    diffAngMat = wrapToPi(2*((tempAng(:).'-tempAng(:))'))/2;  
    
    %Rotate position differences into reference object's par/perp frame;
    %Note that this is done using only the reference object's orientation
    diffParMat = diffXMat.*cos(angleMat) + diffYMat.*sin(angleMat);
    diffPerpMat = -diffXMat.*sin(angleMat) + diffYMat.*cos(angleMat);
    
    %Define logic matrix to collect only valid object pairs in the lower
    %triangular portion of the difference matrices above  grfev
            %Filter based on angle diff. with logic matrices
    outliersMat = ~(abs(diffAngMat) >= abs(cutOffAngle));
    indexMat = logical(tril(true(size(diffParMat)),-1).*(outliersMat));    
    sizeData = sum(sum(indexMat));
    
    %Store rotated distance data 
    diffData(1,storInd:(storInd+sizeData-1)) = diffParMat(indexMat)';
    diffData(2,storInd:(storInd+sizeData-1)) = diffPerpMat(indexMat)';
    %Store associated angles
    diffData(3,storInd:(storInd+sizeData-1)) = angleMat(indexMat)';
    diffData(4,storInd:(storInd+sizeData-1)) = diffAngMat(indexMat)';
    %Store frame and ID data
    diffData(5,storInd:(storInd+sizeData-1)) = currFrame*ones((sizeData),1)';
    diffData(6,storInd:(storInd+sizeData-1)) = IDMat(indexMat);
    diffData(7,storInd:(storInd+sizeData-1)) = IDMatTr(indexMat);
    
    %Update storage index
    storInd = storInd + sizeData;
    
end

%% Calculate velocity differences by iterating through object pairs
storInd = 1;
%Iterate through object ID 1
for ID1 = max(1,min(diffData(6,:))):max(diffData(6,:))
   
    %Identify all data of pairs with reference ID = ID1
    IDinds = diffData(6,:) == ID1;
    tempData = diffData(:,IDinds);
    
    %Sort tempData numerically by the ID of object 2
    tempData = sortrows(tempData',7)';
    
    %Calculate velocity differences between objects by subtracting the
    %separations of each chronologically appearing identical pair and 
    %dividing by the time interval separating consequent time steps 
    sepDiffs = diff(tempData(1:2,:)',1)';
    velDiffs = sepDiffs ./ repmat(diff(tempData(5,:)),2,1);
    
    %Identify matrix junctions between pairs and omit erroneous data points 
    %from those junctions
    goodData = logical(1 - (diff(tempData(7,:)) > 0));
    velDiffs = velDiffs(:,goodData);
    
    %Create index vector to fit velocity data in with rest of data
    finalInds = logical([zeros(1,storInd) goodData]);
    
    %Store relative vel difference data (parallel, perpendicular)
    finalData(6:7,finalInds) = velDiffs;
    finalData([1:5 8:9], storInd:(storInd + size(tempData,2) - 1)) = ...
        tempData;
    
    %Mark points without velocities with NaNs
    exclMat = zeros(1,numel(finalInds));
    exclMat(storInd:end) = 1;
    finalData(6:7,logical((~finalInds).*exclMat)) = NaN;
    storInd = storInd + size(tempData,2);
    
end

%% Clean up data and return both truncated and untruncated data sets
%Rescale using pixel and time conversion parameters
finalData([1:2 6:7],:) = finalData([1:2 6:7],:) * pixelConv;
finalData(6:7,:) = finalData(6:7,:) / timeConv;

%Remove any excess zeros at the end of each data set in case values were
%cutoff by angle selection
if sum( finalData(8,:) == 0 ) > 0
   cutOffInd = min( find( finalData(8,:) == 0) );
   finalData = finalData(:,1:(cutOffInd-1));
end

%Create truncated data set including only data with non-zero velocities
truncInds = ~isnan(finalData(6,:));
truncData = finalData(:,truncInds);

end

