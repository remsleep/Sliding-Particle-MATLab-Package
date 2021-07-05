%% Description
% This script takes in object classification data from Ilastik and returns
% velocity pair information

%% Define directory
dataDir = 'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Batch 1';
imgDirs = {'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Batch 1\488'};
dataNames = {'488_all_Object Predictions.h5'};
channelIndices = {1};

csvName = 'CombinedData';
outDir = 'R:\Two Channel Nematic\2021-05-31\100uM ATP Single Parafilm Chamber\Data Analysis\Batch 1';

dataIDs = 1;
[xSize, ySize] = FUNC_getImgDims(dataDir, 'tif');
testImgCount = 5;
pixelConv = .16;       %in um/pix
timeConv = 0.5;        %in sec/frame
dt = 1;

%% Get Tracer particles
MT_DATA = FUNC_TracerFinderIlastik(dataDir, dataNames, dataIDs);

%% Get data set indices
channelInfo = [MT_DATA.Set];

%% Iterate through each data set
allTrajIndex = 1;
allTrajs = struct();
allRHTrajs = struct();
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
    
    % Convert to right-handed axis system by flipping y
    RH_TRAJECTORY = FUNC_LeftToRightInvert(TRAJECTORY, ySize, 'Y');

    % Combine trajectories
    if fileIndex == 1
        allTrajs = TRAJECTORY(1);
        allRHTrajs = TRAJECTORY(1);
    end
    
    % Store Trajectory data in encompassing all trajectory tensor
    allTrajs(allTrajIndex:(allTrajIndex+numel(TRAJECTORY)-1)) = TRAJECTORY;
    allRHTrajs(allTrajIndex:(allTrajIndex+numel(TRAJECTORY)-1)) = RH_TRAJECTORY;
    allTrajIndex = allTrajIndex + numel(TRAJECTORY);
    
    % Generate identifying vector to discern different data sets
    fieldNames = fieldnames(TRAJECTORY);
    currIDVec = channelIndices{fileIndex}*ones( 1, numel([TRAJECTORY.(fieldNames{1})]) );
    fileIDVec = [fileIDVec currIDVec];
    
end

%% Generate tracks.m [x,y,frame,orientation,ID,channel]
trajsArray = FUNC_Structure2Array(allRHTrajs);
tracks = [trajsArray(2,:); trajsArray(3,:); trajsArray(1,:); ...
    trajsArray(5,:); trajsArray(6,:); fileIDVec]'; 

%% Save tracks.m
save(fullfile(outDir, 'tracks.mat'), 'tracks');
save(fullfile(outDir, 'trajectories.mat'), 'allRHTrajs');
save(fullfile(outDir, 'LHtrajectories.mat'), 'allTrajs');

%% Find velocity pairs from trajectories
FUNC_Trajs2VelPairs(outDir,outDir,[csvName '_unscaled'],dt,1,1);
FUNC_Trajs2VelPairs(outDir,outDir,csvName,dt,pixelConv,timeConv);
