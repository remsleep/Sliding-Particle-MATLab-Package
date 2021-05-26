%% Define variables and parameters
csvName = 'CombinedData';
combinedDir = 'R:\Two Channel Nematic\Alex Two Color MT Data\Ilastik Training';
dt = 1;
pixelConv = 0.101;%meters/pixels
timeConv = 1.29;%seconds/frame
%% Define directory and import Ilastik Object Predictions
dataDir = 'R:\Two Channel Nematic\Alex Two Color MT Data\Ilastik Training';
dataName = 'C2_all.h5';

predictionsName = 'C1_all_Object Predictions.h5';
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
imageLoc = 'R:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Channel 1 1150 frames\C1 tifs';
% imageFile = 'C1 tifs';
% imageDir = fullfile(imageLoc,imageFile);
imageFiles = dir(fullfile(imageLoc, '\*.tif'));
for currFrame = 1:numFrames
    IMAGE = imread(fullfile(imageLoc, imageFiles(currFrame).name));%IMAGE = objPredictions(:,:,currFrame);
    FUNC_overlayMTsImage(MTData(currFrame).MTs, IMAGE);
    pause(0.1);
end