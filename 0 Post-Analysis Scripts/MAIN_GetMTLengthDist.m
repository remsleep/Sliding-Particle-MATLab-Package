%% Description
% This script takes in the directory of Ilastik .h5 object classification
% files and returns the length distributions of MTs within trajectories,
% binned based on length distribution

%% Define directory
dataDir = 'R:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Channel 1 1150 frames';
imgDirs = {'R:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Channel 1 1150 frames\C1 tifs'};
dataNames = {'C1_tiff_Object Predictions.h5'};
channelIndices = {1};
% imgDirs = {'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Batch 1\488', ...
%     'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Batch 2\488', ...
%     'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Batch 3\488'};
% dataNames = {'1_488_all_Object Predictions.h5', ...
%     '2_488_all_Object Predictions.h5', ...
%     '3_488_all_Object Predictions.h5'};
% channelIndices = {1,1,1};

csvName = 'CombinedData';
outDir = 'R:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Channel 1 1150 frames';

dataIDs = 1;
[xSize, ySize] = FUNC_getImgDims(dataDir, 'tif');
testImgCount = 20;
pixelConv = .101;       %in um/pix
timeConv = 1.29;        %in sec/frame
dt = 1;

%% Get Tracer particles
MT_DATA = FUNC_TracerFinderIlastik(dataDir, dataNames, dataIDs);

%% Get data set indices
channelInfo = [MT_DATA.Set];

%% Iterate through each data set
allTrajIndex = 1;
allTrajs = struct();
fileIDVec = [];
for fileIndex = 1:numel(dataNames)
    
    validFrames = (channelInfo == fileIndex);
    currImgDir = imgDirs{fileIndex};
    currMTData = FUNC_MTStructure2Array(MT_DATA(validFrames));
    
    % Load images for trajectory preparation
    imgNames = dir(fullfile(currImgDir, '*.tif'));
    IMAGES = zeros(xSize, ySize, testImgCount);
    for currFrame = 1:testImgCount

        IMAGES(:,:,currFrame) = imread(fullfile(currImgDir,imgNames(currFrame).name));

    end
    
    % Find Trajectories from detected Tracers
    trajectoryParams = FUNC_getTrajectoryParameters(currMTData, IMAGES, testImgCount);
    TRAJECTORY = FUNC_TrajectoryTracker(currMTData, trajectoryParams);

    % Combine trajectories
    if fileIndex == 1
        allTrajs = TRAJECTORY(1);
    end
    
    % Store Trajectory data in encompassing all trajectory tensor
    allTrajs(allTrajIndex:(allTrajIndex+numel(TRAJECTORY)-1)) = TRAJECTORY;
    allTrajIndex = allTrajIndex + numel(TRAJECTORY);
    
    % Generate identifying vector to discern different data sets
    fieldNames = fieldnames(TRAJECTORY);
    currIDVec = channelIndices{fileIndex}*ones( 1, numel([TRAJECTORY.(fieldNames{1})]) );
    fileIDVec = [fileIDVec currIDVec];
    
end

%% Extract length distributions, get mean and variances, and bin results
meanVals = zeros(1,numel(allTrajs));
varVals = meanVals;
errorVals = meanVals;

for currTraj = 1:numel(allTrajs)
    tempLengths = allTrajs(currTraj).LENGTH*pixelConv;
    meanVals(currTraj) = mean(tempLengths);
    varVals(currTraj) = var(tempLengths);
    errorVals(currTraj) = var(tempLengths)/sqrt(numel(tempLengths));
    
end

[binNum, edges, binIndex] = histcounts(meanVals, 50);
binVars = zeros(1, numel(binNum));
binErrors = binVars;

for currBin = 1:numel(binNum)
    tempVars = varVals(binIndex == currBin);
    tempErrors = errorVals(binIndex == currBin);
    binVars(currBin) = mean(tempVars);
    binErrors(currBin) = mean(tempErrors);
    
end

figure
scatter(edges(2:end), binVars,'filled');
hold on
scatter(edges(2:end), binErrors,'filled');
xlabel('MT length (um)');
ylabel('Variance (um)');
set(gca,'FontSize',15)
legend('Variance','Standard Error')