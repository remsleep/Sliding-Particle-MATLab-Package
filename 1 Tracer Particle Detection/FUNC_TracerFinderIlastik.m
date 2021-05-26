function [MTData] = FUNC_TracerFinderIlastik(dataDir,dataNames,dataIDs)
%FUNC_TRACERFINDERILASTIK This function takes in the DATADIR of an .h5
%file, looking for files ending in '_Object Predictions.h5' that contain a
%table called "exported_data." The function looks first for a file
%beginning with the name DATANAMES, a cell array, and otherwise looks
%through all files in the directory ending in "_Object Predictions.h5"
%DATAID is vector which determines the ID given to objects in Ilastik 
%Object Classification that the user wishes to have analyzed. Data is
%returned in a struct(), with each index representing a frame and itself a
%struct() with the length and orientation information for each object
%detected in a given time point

%% Ensure that proper number of arguments have been submitted
stringEnd = '_Object Predictions.h5';
objField = '/exported_data';

if nargin == 2
    dataInfo = dir(fullfile(dataDir,['*' stringEnd]));
    dataNames = {dataInfo.name};
elseif nargin == 1
    dataInfo = dir(fullfile(dataDir,['*' stringEnd]));
    dataNames = {dataInfo.name};
    dataIDs = 1;
end

%% Ensure that each file name ends in the appropriate string
for currName = 1:numel(dataNames)
    dataNames{currName} = FUNC_checkAppendGeneral(dataNames{currName},stringEnd(end-2:end));
    dataNames{currName} = FUNC_checkAppendGeneral(dataNames{currName},stringEnd);
end

%% Extract detected object locations (in thresholded pixels)
for currFile = 1:numel(dataNames)    
    dataLoc = fullfile(dataDir, dataNames{currFile});
    objPredictions = h5read(dataLoc,objField);
    objPredictions = squeeze(objPredictions);
    objPredictions = flipud(objPredictions);
    objPredictions = fliplr(permute(objPredictions,[2,1,3]));
    allDataSets(:,:,:,currFile) = objPredictions;
end

%% Sort out desired objects based on Ilastik labeling
filteredPreds = allDataSets;
for currID = 1:numel(dataIDs)
    filteredPreds(allDataSets~=dataIDs(currID)) = 0;
end

%% Extract data from binarized, filtered images
MTData = struct();
numFrames = size(objPredictions,3);
structInd = 1;
for currFile = 1:numel(dataNames)
    currDataSet = filteredPreds(:,:,:,currFile);
    for currFrame = 1:numFrames
        binaryImage = currDataSet(:,:,currFrame);
        CC = bwconncomp(binaryImage);
        MTs = regionprops(CC, 'centroid','MajorAxisLength','Orientation','MinorAxisLength');
        %Generate a field recording the original file name of this data
        [fieldNameCell{1:numel(MTs)}] = deal(dataNames(currFile));
        [MTs.('fileName')] = fieldNameCell{:};
        MTData(structInd).MTs = MTs;
        structInd = structInd + 1;
    end
end

end

