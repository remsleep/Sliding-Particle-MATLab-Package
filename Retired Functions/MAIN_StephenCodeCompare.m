%Begin with Trajectory data in a structure
% disp(['Current batch: ', num2str(currBatch)])
% currDir = [baseDir, num2str(currBatch)];
% load(fullfile(currDir,'trajectoryData.mat'));
%Define scalings, if necessary
directory = 'C:\Users\Rémi Boros\OneDrive\Documents\MATLAB\Lemma MT Tracking Code\Sliding-Particle-MATLab-Package\Stephen Linnea Old Velocities';
fileName = 'FullLinneaData';
analysisDir = 'FullLinneaData';
pixelConv = 6.5*2/100;      %%In um/pix
timeConv = 0.35;            %%In seconds/frame
WINDOW = 2;                 %%Window of integration for which velocities are calculated
angleCutOff = 10;           %%Max angle in degrees allowed between MTs
ySize = 1280;
binSize = 10;

%% Calculate velocities; assums [x, y, frame, orientation, ID] array structure
disp('Calculating velocities...')
tic
Stephen_CalcRelVelocities2(directory,analysisDir,fileName);
toc

 %% Load data and convert to array
dataTable = readtable([fullfile(directory, analysisDir, fileName) '.csv']);
SD_relVelInfo = table2array(dataTable);     % Column order is [Rsep RelAngle DeltaA Vpar Vperp time]

%% Calculate parallel and perpendicular separation from Rsep and RelAngle
SD_relVelInfo(:,7) = SD_relVelInfo(:,1).*cos(SD_relVelInfo(:,2));
SD_relVelInfo(:,8) = SD_relVelInfo(:,1).*sin(SD_relVelInfo(:,2));

%% Rescale velocities positions using pixel and time conversion values
SD_relVelInfo(:,1) = SD_relVelInfo(:,1)*pixelConv;
SD_relVelInfo(:,4) = SD_relVelInfo(:,4)*pixelConv/timeConv;
SD_relVelInfo(:,5) = SD_relVelInfo(:,5)*pixelConv/timeConv;
SD_relVelInfo(:,7) = SD_relVelInfo(:,7)*pixelConv;
SD_relVelInfo(:,8) = SD_relVelInfo(:,8)*pixelConv;

%% Isolate velocities of particles that are within angleCutOff 
SD_relVelInfo(:,2) = wrapToPi(SD_relVelInfo(:,2));
cutOffInds = abs(SD_relVelInfo(:,2)) <= deg2rad(angleCutOff);
SD_cutRelVelInfo = SD_relVelInfo(cutOffInds, :);

%% Average velocities wrt binned velocities
SD_allVelInfo = ...
    [SD_relVelInfo(:,4)'; SD_relVelInfo(:,5)'; SD_relVelInfo(:,7)'; SD_relVelInfo(:,8)'];
[SD_allPeaks, SD_allAvgs, SD_binCoords] = ...
    FUNC_2DHistogramVelOverPositionalSeparation(SD_allVelInfo, 10);
SD_cutAllVelInfo = ...
    [SD_cutRelVelInfo(:,4)'; SD_cutRelVelInfo(:,5)'; SD_cutRelVelInfo(:,7)'; SD_cutRelVelInfo(:,8)'];
[SD_cutAllPeaks, SD_cutAllAvgs, SD_cutBinCoords] = ...
    FUNC_2DHistogramVelOverPositionalSeparation(SD_cutAllVelInfo, 10);

%% Linnea Analysis
BinInterframeRodPairDetails2(directory,fileName,timeConv,pixelConv,1,1000);

%% Save data
disp('Saving data...')
%  save(fullfile(currDir,'allVelocityInfo.mat'),'velInfo');
%  save(fullfile(currDir,'allVelocityInfoArray.mat'),'velArray');
%  save(fullfile(currDir,'relativeParallelVelocities.mat'),'relParVel');
%  save(fullfile(currDir,'relativePerpendicularVelocities.mat'),'relPerpVel');
%  save(fullfile(currDir,'separationDistances.mat'),'Distance');

