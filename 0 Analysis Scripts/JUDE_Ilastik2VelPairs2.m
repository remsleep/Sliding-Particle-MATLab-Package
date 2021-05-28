%% Define variables and parameters
csvName = 'CombinedData';
combinedDir = 'C:\Users\Jude\Documents\SlidingMTData';
dt = 1;
pixelConv = 0.101;%meters/pixels
timeConv = 1.29;%seconds/frame
%% Define directory and import Ilastik Object Predictions
dataDir = 'C:\Users\judem\Documents\SlidingMTData\ForLinneaTifs\Data tifs';
dataName = 'C1 tifs.h5';

predictionsName = 'C1 tifs_Object Predictions.h5';
objField = '/exported_data';
objPredictions = FUNC_IlastikH5Reader(dataDir,predictionsName,objField);
objPredictions = squeeze(objPredictions);
objPredictions = flipud(objPredictions);
objPredictions = fliplr(permute(objPredictions,[2,1,3]));

%% Extract Data from Binary Images
MTData = struct();
numFrames = size(objPredictions,3);
for currFrame = 1:numFrames
    binaryImage = objPredictions(:,:,currFrame);
    CC = bwconncomp(binaryImage);
    MTs = regionprops(CC, 'centroid','MajorAxisLength','Orientation','MinorAxisLength');
    MTData(currFrame).MTs = MTs;
end

allMTData = FUNC_MTStructure2Array(MTData);
%% Overlay MT Data over MT images
imageLoc = 'C:\Users\judem\Documents\SlidingMTData\ForLinneaTifs\Data tifs';
imageFile = 'C1 tifs';
imageDir = fullfile(imageLoc,imageFile);
imageFiles = dir([imageDir '\*.tif']);
for currFrame = 1:numFrames
    IMAGE = imread(fullfile(imageDir, imageFiles(currFrame).name));%IMAGE = objPredictions(:,:,currFrame);
    FUNC_overlayMTsImage(MTData(currFrame).MTs, IMAGE);
    pause(0.1);
end