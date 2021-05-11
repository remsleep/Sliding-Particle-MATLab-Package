%% Define variables and parameters
csvName = 'CombinedData';
combinedDir = 'C:\Users\Jude\Documents\SlidingMTData';
dt = 1;
pixelConv = 0.101;%meters/pixels
timeConv = 1.29;%seconds/frame

%% Define directory
dataDir = 'C:\Users\Jude\Documents\SlidingMTData';
outDir1 = dataDir;
DATA_PATH = fullfile(dataDir, 'tifs');
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
saveDir1 = fullfile(outDir1, '');
mkdir(saveDir1);
save(fullfile(saveDir1,'tracerData.mat'),'allMTData');
save(fullfile(saveDir1,'tracerDataStruct.mat'),'MT_DATA');
save(fullfile(saveDir1,'trajectoryData.mat'),'TRAJECTORY');
save(fullfile(saveDir1,'plottingTrajectoryData.mat'),'LH_TRAJECTORY');
%  save(fullfile(saveDir,'calculatingTrajectoryData.mat'),'trajectoryArray');
save(fullfile(saveDir1,'parameters.mat'),'tracerParams','trajectoryParams');

%% Load trajectories
ch1Struct = load(fullfile(saveDir1, 'tracks.mat'));
fields = fieldnames(ch1Struct);
trajs1 = ch1Struct.(fields{1});

%% Convert to arrays
[trajs1,FIELDS] = FUNC_Structure2Array(trajs1Struct);

%% Rearrange into [x, y, frame, orient, ID, channel]
% tracks = [trajs1(2,:); trajs1(3,:); trajs1(1,:); trajs1(5,:); trajs1(6,:); ones(1,size(trajs1,2))]';
tracks = [trajs1, ones(size(trajs1,1),1)]';
%% Save 
% mkdir(combinedDir);
save(fullfile(combinedDir, 'tracksWChannel.mat'), 'tracks');

%% Find velocity pairs from trajectories
FUNC_Trajs2VelPairs(combinedDir,combinedDir,[csvName '_unscaled'],dt,1,1);
FUNC_Trajs2VelPairs(combinedDir,combinedDir,csvName,dt,pixelConv,timeConv);

%% Check with Linnea analysis
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],1,1,1,1149)
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],timeConv,pixelConv,1,1149)
