%% Define directory
 currDir = 'C:\Users\Jude\Documents\MATLAB\For Linnea\Data tifs';
 DATA_PATH = fullfile(currDir, 'C2 tifs');
 [xSize, ySize] = FUNC_getImgDims(DATA_PATH, 'tif');
 
 %% Get Tracer particles
tracerParams = FUNC_getTracerParameters(DATA_PATH, 20);
[MT_DATA,IMAGES] = FUNC_TracerFinderRedo(DATA_PATH, tracerParams);
 
 %% Convert to array
 allMTData = FUNC_MTStructure2Array(MT_DATA);
 
 %% Find Trajectories from detected Tracers
 trajectoryParams = FUNC_getTrajectoryParameters(allMTData, IMAGES, 20);
 TRAJECTORY = FUNC_TrajectoryTracker(allMTData, trajectoryParams);
 
 %% Convert to right-handed axis system by flipping y
 RH_TRAJECTORY = FUNC_LeftToRightInvert(TRAJECTORY, ySize, 'Y');
%  trajectoryArray = FUNC_Structure2Array(TRAJECTORY);
%  trajectoryArray(3,:) = yDim - trajectoryArray(3,:);
%  trajectoryArray = ...
%      [trajectoryArray(2,:); trajectoryArray(3,:); trajectoryArray(1,:); trajectoryArray(5,:); trajectoryArray(6,:)];
 
 %% Plot Trajectories
 FUNC_TrajectoryOverlayViewerImg(TRAJECTORY, IMAGES, 0)
 
 %% Save variables
% %  save(fullfile(currDir,'imageData.mat'),'IMAGES','-v7.3');              %%This variable is large
%  save(fullfile(currDir,'tracerData.mat'),'allMTData');
%  save(fullfile(currDir,'tracerDataStruct.mat'),'MT_DATA');
%  save(fullfile(currDir,'plottingTrajectoryData.mat'),'TRAJECTORY');
%  save(fullfile(currDir,'calculatingTrajectoryData.mat'),'trajectoryArray');
%  save(fullfile(currDir,'parameters.mat'),'tracerParams','trajectoryParams');
