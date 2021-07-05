%% Define variables and parameters
csvName = 'CombinedData';
combinedDir = 'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Data Analysis\Batch 3';
dt = 1;
pixelConv = 0.160;      %um/pixels
timeConv = 0.5;         %seconds/frame

%% Define directory and import Ilastik Object Predictions
dataDir = 'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Batch 3';
predictionsName = '488_all_Object Predictions.h5';

objField = '/exported_data';
objPredictions = FUNC_IlastikH5Reader(dataDir,predictionsName,objField);
objPredictions = squeeze(objPredictions);
objPredictions = flipud(objPredictions);
objPredictions = fliplr(permute(objPredictions,[2,1,3]));

%% Sort out desired objects based on Ilastik labeling
desiredLabel = 1;
filteredPreds = objPredictions;
filteredPreds(objPredictions~=desiredLabel) = 0;

%% Extract Data from Binary Images
MTData = struct();
numFrames = size(objPredictions,3);
for currFrame = 1:numFrames
    binaryImage = filteredPreds(:,:,currFrame);
    %Remove >pixelMax and <pixelMin pixel objects:
%     L = labelmatrix(CC);
    CC = bwconncomp(binaryImage);
    MTs = regionprops(CC, 'centroid','MajorAxisLength','Orientation','MinorAxisLength');
    MTData(currFrame).MTs = MTs;
end

%% Overlay MT Data over MT images
imageLoc = 'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Batch 3\488';
% imageFile = 'C1 tifs';
% imageDir = fullfile(imageLoc,imageFile);
imageFiles = dir(fullfile(imageLoc, '\*.tif'));
for currFrame = 1:numFrames
    IMAGE = imread(fullfile(imageLoc, imageFiles(currFrame).name));%IMAGE = objPredictions(:,:,currFrame);
    FUNC_overlayMTsImage(MTData(currFrame).MTs, IMAGE);
    pause(0.1);
end