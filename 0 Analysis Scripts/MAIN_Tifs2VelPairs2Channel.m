%% Define variables and parameters
csvName = 'CombinedData';
combinedDir = 'C:\Users\Jude\Documents\SlidingMTData';
dt = 1;
pixelConv = .101;
timeConv = 1.29;


%% %%%%%%%%%%%%%%%% CHANNEL 1 %%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define directory
dataDir = 'C:\Users\judem\Documents\SlidingMTData\ForLinneaTifs\Data tifs';
outDir1 = dataDir;
DATA_PATH = fullfile(dataDir, 'C1 tifs');
[~, ySize] = FUNC_getImgDims(DATA_PATH, 'tif');

%% Get Tracer particles
tracerParams = FUNC_getTracerParameters(DATA_PATH, 20);
[MT_DATA,IMAGES] = FUNC_TracerFinderRedo(DATA_PATH, tracerParams);

%% Convert to array
allMTData = FUNC_MTStructure2Array(MT_DATA);

%% Find Trajectories from detected Tracers
trajectoryParams = FUNC_getTrajectoryParameters(allMTData, IMAGES, 20);
TRAJECTORY = FUNC_TrajectoryTracker(allMTData, trajectoryParams);

%% Convert to right-handed axis system by flipping y
LH_TRAJECTORY = TRAJECTORY;
TRAJECTORY = FUNC_LeftToRightInvert(TRAJECTORY, ySize, 'Y');

%% Plot Trajectories
FUNC_TrajectoryOverlayViewerImg(LH_TRAJECTORY, IMAGES, 0)

%% Save variables
% %  save(fullfile(currDir,'imageData.mat'),'IMAGES','-v7.3');              %%This variable is large
saveDir1 = fullfile(outDir1, 'Channel 1');
mkdir(saveDir1);
save(fullfile(saveDir1,'tracerData.mat'),'allMTData');
save(fullfile(saveDir1,'tracerDataStruct.mat'),'MT_DATA');
save(fullfile(saveDir1,'trajectoryData.mat'),'TRAJECTORY');
save(fullfile(saveDir1,'plottingTrajectoryData.mat'),'LH_TRAJECTORY');
%  save(fullfile(saveDir,'calculatingTrajectoryData.mat'),'trajectoryArray');
save(fullfile(saveDir1,'parameters.mat'),'tracerParams','trajectoryParams');

%% %%%%%%%%%%%%%%%% CHANNEL 2 %%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define directory
dataDir = 'C:\Users\Jude\Documents\MATLAB\For Linnea\Data tifs';
outDir2 = dataDir;
DATA_PATH = fullfile(dataDir, 'C2 tifs');
[~, ySize] = FUNC_getImgDims(DATA_PATH, 'tif');

%% Get Tracer particles
tracerParams = FUNC_getTracerParameters(DATA_PATH, 20);
[MT_DATA,IMAGES] = FUNC_TracerFinderRedo(DATA_PATH, tracerParams);

%% Convert to array
allMTData = FUNC_MTStructure2Array(MT_DATA);

%% Find Trajectories from detected Tracers
trajectoryParams = FUNC_getTrajectoryParameters(allMTData, IMAGES, 20);
TRAJECTORY = FUNC_TrajectoryTracker(allMTData, trajectoryParams);

%% Convert to right-handed axis system by flipping y
LH_TRAJECTORY = TRAJECTORY;
TRAJECTORY = FUNC_LeftToRightInvert(TRAJECTORY, ySize, 'Y');

%% Plot Trajectories
FUNC_TrajectoryOverlayViewerImg(LH_TRAJECTORY, IMAGES, 0)

%% Save variables
% %  save(fullfile(currDir,'imageData.mat'),'IMAGES','-v7.3');              %%This variable is large
saveDir2 = fullfile(outDir2, 'Channel 2');
mkdir(saveDir2);
save(fullfile(saveDir2,'tracerData.mat'),'allMTData');
save(fullfile(saveDir2,'tracerDataStruct.mat'),'MT_DATA');
save(fullfile(saveDir2,'trajectoryData.mat'),'TRAJECTORY');
save(fullfile(saveDir2,'plottingTrajectoryData.mat'),'LH_TRAJECTORY');
%  save(fullfile(saveDir,'calculatingTrajectoryData.mat'),'trajectoryArray');
save(fullfile(saveDir2,'parameters.mat'),'tracerParams','trajectoryParams');

%% %%%%%%%%%%%%%%%%%%%%%%%%% Concatenate data and convert to array %%%%%%%%

%% Load trajectories
ch1Struct = load(fullfile(saveDir1, 'trajectoryData.mat'));
fields = cell2mat(fieldnames(ch1Struct));
trajs1Struct = ch1Struct.(fields);

ch2Struct = load(fullfile(saveDir2, 'trajectoryData.mat'));
fields = cell2mat(fieldnames(ch2Struct));
trajs2Struct = ch2Struct.(fields);

%% Convert to arrays
[trajs1,FIELDS] = FUNC_Structure2Array(trajs1Struct);
trajs2 = FUNC_Structure2Array(trajs2Struct);

%% Rearrange into [x, y, frame, orient, ID, channel]
tracks1 = [trajs1(2,:); trajs1(3,:); trajs1(1,:); trajs1(5,:); trajs1(6,:); ones(1,size(trajs1,2))];
tracks2 = [trajs2(2,:); trajs2(3,:); trajs2(1,:); trajs2(5,:); trajs2(6,:); 2*ones(1,size(trajs2,2))];

%% Concatenate
tracks = [tracks1 tracks2]';
%% Save 
mkdir(combinedDir);
save(fullfile(combinedDir, 'tracks.mat'), 'tracks');

%% Find velocity pairs from trajectories
FUNC_Trajs2VelPairs(combinedDir,combinedDir,[csvName '_Unscaled'],dt,1,1);

FUNC_Trajs2VelPairs(combinedDir,combinedDir,csvName,dt,pixelConv,timeConv);

%% Check with Linnea analysis
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],1,1,1,1149)
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],timeConv,pixelConv,1,1149)
