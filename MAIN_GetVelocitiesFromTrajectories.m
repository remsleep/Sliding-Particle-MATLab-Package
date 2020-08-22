%Begin with Trajectory data in a structure
% disp(['Current batch: ', num2str(currBatch)])
% currDir = [baseDir, num2str(currBatch)];
% load(fullfile(currDir,'trajectoryData.mat'));
%Define scalings, if necessary
directory = 'C:\Users\Rémi Boros\OneDrive\Documents\MATLAB\Lemma MT Tracking Code\Sliding-Particle-MATLab-Package\Stephen Linnea Old Velocities';
fileName = 'First3Trajs_AnalysisDataChange_Remi.csv';
analysisDir = 'First3Trajs';
pixelConv = 6.5*2/100;      %%In um/pix
timeConv = 0.35;            %%In seconds/frame
WINDOW = 2;                 %%Window of integration for which velocities are calculated
angleCutOff = 360;           %%Max angle in degrees allowed between MTs
ySize = 1280;
binSize = 10;
load(fullfile(directory, 'tracks.mat'));
tr = tr';

%% Calculate velocities; assums [x, y, frame, orientation, ID] array structure
first3 = max(find(tr(5,:)==3));
tr3 = tr(:,1:first3);
disp('Calculating velocities...')
tic

% velInfo = FUNC_FindVelocityFromArray(tr1000, WINDOW, pixelConv, timeConv);
velInfo = FUNC_FindVelocityFromArray(tr3, 1, 1);
toc

%% Convert array to structure
%Move ID Row to front: [x,y,frame,orient,ID,parvel,perpvel] -> [ID,parvel,perpvel,x,y,frame,orient]
shiftedVelInfo = circshift(velInfo, 3, 1);
structVelInfo = FUNC_Array2Structure(shiftedVelInfo, {'ID', 'PARVEL', 'PERPVEL', 'X', 'Y', 'FRAME', 'ORIENT'});
% flippedY_shiftedVelInfo = circshift(RH_velInfo, 3, 1);
% flippedY_structVelInfo = FUNC_Array2Structure(flippedY_shiftedVelInfo, {'ID', 'PARVEL', 'PERPVEL', 'X', 'Y', 'FRAME', 'ORIENT'});

%% Construct new arrays of velocities parallel and perpendicular to MT alignment
disp('Calculating relative velocities...')
[relParVel, relPerpVel, Distance, Coords, DeltaAng, Frames] = ...
    FUNC_PairwiseParPerpVelocitiesSameChannelArrayLower(structVelInfo, WINDOW, deg2rad(angleCutOff));

%% Average velocities wrt binned velocities
allVelInfo = [relParVel; relPerpVel; Coords(1,:); Coords(2,:)];
[allPeaks, allAvgs, binCoords] = FUNC_2DHistogramVelOverPositionalSeparation(allVelInfo, 10);

%% Convert data to .csv for Stephen analysis [RSep; RelAng; DeltaAng; Vpar; Vperp; T]
preArray = [sqrt(Coords(1,:).^2 + Coords(2,:).^2); atan2(Coords(2,:),Coords(1,:)); ...
    DeltaAng; -relParVel; -relPerpVel; Frames]';
FUNC_Array2CSVSpecific(directory,analysisDir,fileName,preArray);

%%
BinInterframeRodPairDetails2(directory,fileName,timeConv,pixelConv,1,1000);
% BinInterframeRodPairDetails2(directory,['Lower_' fileName],timeConv,pixelConv,1,1000);

%% Save data
disp('Saving data...')
%  save(fullfile(currDir,'allVelocityInfo.mat'),'velInfo');
%  save(fullfile(currDir,'allVelocityInfoArray.mat'),'velArray');
%  save(fullfile(currDir,'relativeParallelVelocities.mat'),'relParVel');
%  save(fullfile(currDir,'relativePerpendicularVelocities.mat'),'relPerpVel');
%  save(fullfile(currDir,'separationDistances.mat'),'Distance');

