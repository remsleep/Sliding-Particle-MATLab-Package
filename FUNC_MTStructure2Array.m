function [ALL_MT_DATA] = FUNC_MTStructure2Array(MT_DATA)
%FUNC_MTSTRUCTURE2ARRAY Thsi function takes in MT_DATA, a structure of
%structures with each substructure containing the data of all MTs detected
%in a current frame, and covnerts it into a 5xN array, where N is the total
%number of detected MTs across all frames. 
% - The first row contains the frame in which the given MT was detected 
% - The second row indicates the given MT's length
% - The third row indicates the given MT's orientation
% - The fourth row indicates the x-position of the given MT
% - The fifth row indicates the y-position of the given MT

%Initialize a scalar of the total number of detected MTs
totalMTs = 0;

%Define last frame
lastFrame = numel(MT_DATA);

%Iterate through each frame and count elements
for currFrame = 1:lastFrame
    totalMTs = totalMTs + numel(MT_DATA(currFrame).MTs);
end

%Initialize the array
ALL_MT_DATA = zeros(5, totalMTs);
FOI = 0;            %First Open Index in array (next zero index)

%Iterate through each frame and store the data
for currFrame = 1:lastFrame
    
    %Number of MTs in this frame
    maxMTs = numel(MT_DATA(currFrame).MTs);
    
    ALL_MT_DATA(1,(FOI+1):(FOI+maxMTs)) = currFrame*ones(1, maxMTs);
    
    %Iterate through MTs
    for currMT = 1:maxMTs
        
        ALL_MT_DATA(2,FOI+currMT) = MT_DATA(currFrame).MTs(currMT).MajorAxisLength;
        ALL_MT_DATA(3,FOI+currMT) = deg2rad(MT_DATA(currFrame).MTs(currMT).Orientation);
        ALL_MT_DATA(4,FOI+currMT) = MT_DATA(currFrame).MTs(currMT).Centroid(1);
        ALL_MT_DATA(5,FOI+currMT) = MT_DATA(currFrame).MTs(currMT).Centroid(2);
        
    end
    
    %Update next free index
    FOI = FOI + maxMTs;
    
end

