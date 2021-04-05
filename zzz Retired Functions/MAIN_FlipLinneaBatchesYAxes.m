%% Define scalings, if necessary
close all
prefixDir = 'D:\Linnea Data\forRemi\Batch';
currDir = fullfile([prefixDir num2str(1)],'tifs');
[xSize, ySize] = FUNC_getImgDims(currDir, 'tif');
totalBatches = 10;
%% Load

for currBatch = 1:totalBatches
   
    currDir = [prefixDir num2str(currBatch)];
    load(fullfile(currDir,'trajectoryData.mat'));
    RH_TRAJECTORY = FUNC_LeftToRightInvert(TRAJECTORY, ySize, 'Y');
    
    save(fullfile(currDir,'RH_trajectoryData.mat'),'RH_TRAJECTORY');
end