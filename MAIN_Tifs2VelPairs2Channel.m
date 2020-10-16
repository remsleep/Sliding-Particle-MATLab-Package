%% Define variables and parameters
csvName = 'CombinedData';
<<<<<<< HEAD:MAIN_Tifs2VelPairs.m
combinedDir = 'C:\Users\Jude\Documents\SlidingMTData';
=======
combinedDir = 'D:\Alex Two Color MT Data\Data Set 1\Combined';
>>>>>>> 752734971e6d7b7365e9d51eebd4cf18ea24f0ad:MAIN_Tifs2VelPairs2Channel.m
dt = 1;
pixelConv = .101;
timeConv = 1.29;


%% %%%%%%%%%%%%%%%% CHANNEL 1 %%%%%%%%%%%%%%%%%%%%%%%%%%
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

%% %%%%%%%%%%%%%%%% CHANNEL 2 %%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define directory
dataDir = 'D:\Alex Two Color MT Data\Data Set 1\Channel 2 1150 frames\';
outDir2 = dataDir;
DATA_PATH = fullfile(dataDir, 'C2 tifs');
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
<<<<<<< HEAD:MAIN_Tifs2VelPairs.m
FUNC_Trajs2VelPairs(combinedDir,combinedDir,[csvName '_Unscaled'],dt,1,1);
JudeData = FUNC_Trajs2VelPairs(combinedDir,combinedDir,csvName,dt,pixelConv,timeConv);
%% switch signs of velocities
JUDE_SwitchVelocitySign(combinedDir,combinedDir,csvName,[csvName '_SignSwitched']);
%% Filtering Through Data based on Angle, Separation, and Channel Nums
%parameters for filtering through data
parLow = 0;
parHigh = 0.2;
perpLow = 0;
perpHigh = 10;
angleCutOff = deg2rad(10);
filtCSVName = [csvName '_Filtered'];
%filter angles
FUNC_FilterCSVIncl(combinedDir,combinedDir,csvName,filtCSVName,{'RelAngle'},[0,angleCutOff]);
%filter through par seps
FUNC_FilterCSVIncl(combinedDir,combinedDir,filtCSVName,filtCSVName,{'ParSep'},[-parHigh,parHigh]);
FUNC_FilterCSVOmit(combinedDir,combinedDir,filtCSVName,filtCSVName,{'ParSep'},[-parLow,parLow]);
%filter through perp seps
FUNC_FilterCSVIncl(combinedDir,combinedDir,filtCSVName,filtCSVName,{'PerpSep'},[-perpHigh,perpHigh]);
FUNC_FilterCSVOmit(combinedDir,combinedDir,filtCSVName,filtCSVName,{'PerpSep'},[-perpLow,perpLow]);
%% plot histogram of relative parallel velocities
%choose data to plot and extract data from csv file
dataDir = fullfile(combinedDir,[filtCSVName '.csv']);
fieldName = 'Vpar';
filteredTable = readtable(dataDir);
outerBinEdge = 10;
=======
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
>>>>>>> 752734971e6d7b7365e9d51eebd4cf18ea24f0ad:MAIN_Tifs2VelPairs2Channel.m
numBins = 50;
%histogram parameters
[sumN,edges] = FUNC_CSVHistogram(dataDir,fieldName);
hold on
histogram(filteredTable.(fieldName),linspace(-outerBinEdge,outerBinEdge,numBins));
title(sprintf('Region Dimensions: [%1$.2f, %2$.2f, %3$.2f, %4$.2f]', parLow,...
    parHigh,perpLow,perpHigh));
hold off
%% Check with Linnea analysis
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],1,1,1,1149)
BinInterframeRodPairDetails2(combinedDir,[csvName '_unscaled'],timeConv,pixelConv,1,1149)