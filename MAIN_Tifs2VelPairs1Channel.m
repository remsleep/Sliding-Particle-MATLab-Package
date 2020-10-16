%% Define variables and parameters
csvName = 'LinneaData';
combinedDir = 'D:\Linnea Data\forRemi\2020-09-19 Linnea Plots Compare';
dt = 1;
pixelConv = 6.5*2/100;
timeConv = 0.35;

%% Define directory
dataDir = 'D:\Alex Two Color MT Data\Data Set 1\Channel 1 1150 frames';
outDir1 = dataDir;
DATA_PATH = fullfile(dataDir, 'C1 tifs');
[~, ySize] = FUNC_getImgDims(DATA_PATH, 'tif');

%% Get Tracer particles
% tracerParams = FUNC_getTracerParameters(DATA_PATH, 20);
[MT_DATA,IMAGES] = FUNC_TracerFinderRedo(DATA_PATH, tracerParams);

%% Convert to array
allMTData = FUNC_MTStructure2Array(MT_DATA);

%% Find Trajectories from detected Tracers
% trajectoryParams = FUNC_getTrajectoryParameters(allMTData, IMAGES, 20);
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

%% Load trajectories
ch1Struct = load(fullfile(saveDir1, 'trajectoryData.mat'));
fields = cell2mat(fieldnames(ch1Struct));
trajs1Struct = ch1Struct.(fields);

%% Convert to arrays
[trajs1,FIELDS] = FUNC_Structure2Array(trajs1Struct);

%% Rearrange into [x, y, frame, orient, ID, channel]
tracks1 = [trajs1(2,:); trajs1(3,:); trajs1(1,:); trajs1(5,:); trajs1(6,:); ones(1,size(trajs1,2))];

%% Save 
mkdir(combinedDir);
save(fullfile(combinedDir, 'tracks.mat'), 'tracks');

%% Find velocity pairs from trajectories
FUNC_Trajs2VelPairs(combinedDir,combinedDir,[csvName '_unscaled'],dt,1,1);
FUNC_Trajs2VelPairs(combinedDir,combinedDir,csvName,dt,pixelConv,timeConv);

%% Region Analysis
MTPairData = [JudeData(:,4)'; JudeData(:,5)'; JudeData(:,1)'; JudeData(:,9:10)'];
MTPairData = MTPairData(:,mod(JudeData(:,7)' + JudeData(:,8)',2) == 1);%to filter through pairs 
%from certain channel combinations
QuadrantOption = 2;%%select 1 for one quadrant and 2 for all four quadrants
regionDimensions = [0,100,0,100];%%[xlow,xhigh,ylow,yhigh]
[percentMTs,RegParVels,RegPerpVels,RegCoords] = ...%Reg stands for region
    FUNC_FindMTsInRegion(regionDimensions,QuadrantOption,MTPairData);
%%plot histogram of relative parallel velocities
numBins = 50;
outerBinEdge = 1;
hold on
histogram(RegParVels,linspace(-outerBinEdge,outerBinEdge,numBins));
title(sprintf('Region Dimensions: [%1$.2f, %2$.2f, %3$.2f, %4$.2f]', regionDimensions(1),...
    regionDimensions(2),regionDimensions(3),regionDimensions(4)));
hold off
%% Check with Linnea analysis
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],1,1,1,1149)
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],timeConv,pixelConv,1,1149)
