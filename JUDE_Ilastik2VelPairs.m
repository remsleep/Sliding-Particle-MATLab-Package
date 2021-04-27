%% Define variables and parameters
csvName = 'CombinedData';
combinedDir = 'C:\Users\Jude\Documents\SlidingMTData';
dt = 1;
pixelConv = 0.101;%meters/pixels
timeConv = 1.29;%seconds/frame

%% Define directory and import Ilastik Data
dataDir = 'C:\Users\judem\Documents\SlidingMTData\ForLinneaTifs\Data tifs';
dataName = 'C1 tifs.h5';
dataField = '/table';
MTTable = FUNC_IlastikH5Reader(dataDir,dataName,dataField);

predictionsName = 'C1 tifs_Object Predictions.h5';
objField = '/exported_data';
objPredictions = FUNC_IlastikH5Reader(dataDir,predictionsName,objField);

outDir1 = dataDir;
% get image dimensions
xSize = size(squeeze(objPredictions),1);
ySize = size(squeeze(objPredictions),2);
numFrames = size(squeeze(objPredictions),3);

%% Create Array with MT Data
Frame = double(MTTable.timestep + 1);
CentroidX = double(MTTable.CenterOfTheObject_0);
CentroidY = double(MTTable.CenterOfTheObject_1);
MajorAxisLength = double(2*MTTable.RadiiOfTheObject_0);
MinorAxisLength = double(2*MTTable.RadiiOfTheObject_1);
Orientation = double(atan(-(MTTable.PrincipalComponentsOfTheObject_0).^(-1)));

allMTData = [Frame'; MajorAxisLength'; Orientation'; CentroidX'; CentroidY'];

%% Overlay MTs Predictions on MT Images
% define directory and name of images
imageLoc = 'C:\Users\judem\Documents\SlidingMTData\ForLinneaTifs\Data tifs';
imageFile = 'C1 tifs';
imageDir = fullfile(imageLoc,imageFile);

% creating MTs structure containing information stored in allMTData
MTData = struct();
for frame = 1:numFrames
    mtIndicesThisFrame = find(allMTData(1,:) == frame);
    for mtNum = 1:length(mtIndicesThisFrame)
        MTData(frame).MTs(mtNum).Centroid = [CentroidX(mtIndicesThisFrame(mtNum)), CentroidY(mtIndicesThisFrame(mtNum))];
        MTData(frame).MTs(mtNum).MajorAxisLength = MajorAxisLength(mtIndicesThisFrame(mtNum));
        MTData(frame).MTs(mtNum).MinorAxisLength = MinorAxisLength(mtIndicesThisFrame(mtNum));
        MTData(frame).MTs(mtNum).Orientation = rad2deg(Orientation(mtIndicesThisFrame(mtNum)));
    end
end

% Run Through Each Image and Overlay Predicted MT Locations,
% Orientations,etc.
imageFiles = dir([imageDir '\*.tif']);
for currFrame = 1:numFrames
    IMAGE = imread(fullfile(imageDir, imageFiles(currFrame).name));
    FUNC_overlayMTsImage(MTData(currFrame).MTs, IMAGE);
    pause(0.1);
end

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
