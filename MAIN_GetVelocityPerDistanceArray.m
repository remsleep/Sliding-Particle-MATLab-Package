%Begin with Trajectory data in a structure
% disp(['Current batch: ', num2str(currBatch)])
% currDir = [baseDir, num2str(currBatch)];
% load(fullfile(currDir,'trajectoryData.mat'));
%Define scalings, if necessary
directory = 'C:\Users\Rémi Boros\OneDrive\Documents\MATLAB\Lemma MT Tracking Code\Sliding-Particle-MATLab-Package\Stephen Linnea Old Velocities';
fileName = 'AnalysisDataChange_Remi.csv';
pixelConv = 6.5*2/100;      %%In um/pix
timeConv = 0.35;            %%In seconds/frame
WINDOW = 2;                 %%Window of integration for which velocities are calculated
angleCutOff = 360;           %%Max angle in degrees allowed between MTs
ySize = 1280;
binSize = 10;
load(fullfile(directory, 'tracks.mat'));

%% Calculate velocities; assums [x, y, frame, orientation, ID] array structure

% first1000 = min(find(tr(:,3)==1000));
% tr1000 = tr(1:first1000,:)';
first1000 = min(find(tr(3,:)==1000));
tr1000 = tr(:,1:first1000);
disp('Calculating velocities...')
tic
% velInfo = FUNC_FindVelocityFromArray(tr1000, WINDOW, pixelConv, timeConv);
velInfo = FUNC_FindVelocityFromArray(tr1000, WINDOW, 1, 1);
toc
% flippedY_tr1000 = tr1000; flippedY_tr1000(2,:) = ySize-flippedY_tr1000(2,:);
% disp('Calculating velocities...')
% tic
% flippedY_velInfo = FUNC_FindVelocityFromArray(flippedY_tr1000, WINDOW, pixelConv, timeConv);
% toc

%% Convert array to structure
%Move ID Row to front: [x,y,frame,orient,ID,parvel,perpvel] -> [ID,parvel,perpvel,x,y,frame,orient]
shiftedVelInfo = circshift(velInfo, 3, 1);
structVelInfo = FUNC_Array2Structure(shiftedVelInfo, {'ID', 'PARVEL', 'PERPVEL', 'X', 'Y', 'FRAME', 'ORIENT'});
% flippedY_shiftedVelInfo = circshift(RH_velInfo, 3, 1);
% flippedY_structVelInfo = FUNC_Array2Structure(flippedY_shiftedVelInfo, {'ID', 'PARVEL', 'PERPVEL', 'X', 'Y', 'FRAME', 'ORIENT'});

%% Consturct new arrays of velocities parallel and perpendicular to MT alignment
disp('Calculating relative velocities...')
[relParVel, relPerpVel, Distance, Coords, DeltaAng, Frames] = ...
    FUNC_PairwiseParPerpVelocitiesSameChannelArray(structVelInfo, WINDOW, deg2rad(angleCutOff));
[lo_relParVel, lo_relPerpVel, lo_Distance, lo_Coords, lo_DeltaAng, lo_Frames] = ...
    FUNC_PairwiseParPerpVelocitiesSameChannelArrayLower(structVelInfo, WINDOW, deg2rad(angleCutOff));
% [fY_relParVel, fY_relPerpVel, fY_Distance, fY_Coords] = FUNC_PairwiseParPerpVelocitiesSameChannelArray(flippedY_structVelInfo, WINDOW, deg2rad(angleCutOff));
% [relParVelSub, relPerpVelSub, DistanceSub] = FUNC_PairwiseParPerpVelocitiesSameChannelArray(velInfo, WINDOW);

%% Average velocities wrt binned velocities
allVelInfo = [relParVel; relPerpVel; Coords(1,:); Coords(2,:)];
[allPeaks, allAvgs, binCoords] = FUNC_2DHistogramVelOverPositionalSeparation(allVelInfo, 10);
% lo_allVelInfo = [lo_relParVel; lo_relPerpVel; lo_Coords(1,:); lo_Coords(2,:)];
% [lo_allPeaks, lo_allAvgs, lo_binCoords] = FUNC_2DHistogramVelOverPositionalSeparation(lo_allVelInfo, 10);
% flippedY_allVelInfo = [fY_relParVel; fY_relPerpVel; fY_Coords(1,:); fY_Coords(2,:)];
% [fY_allPeaks, fY_allAvgs, fY_binCoords] = FUNC_2DHistogramVelOverPositionalSeparation(flippedY_allVelInfo, 10);

%% Convert data to .csv for Stephen analysis [RSep; RelAng; DeltaAng; Vpar; Vperp; T]
preArray = [sqrt(Coords(1,:).^2 + Coords(2,:).^2); atan2(Coords(1,:),Coords(2,:)); ...
    DeltaAng; -relParVel; -relPerpVel; Frames]';
FUNC_Array2CSVSpecific(directory,fileName,preArray);
% lo_preArray = [sqrt(lo_Coords(1,:).^2 + lo_Coords(2,:).^2); atan2(lo_Coords(1,:),lo_Coords(2,:)); ...
%     lo_DeltaAng; lo_relParVel; lo_relPerpVel; lo_Frames]';
% FUNC_Array2CSVSpecific(directory,['Lower_' fileName],lo_preArray);
%%
BinInterframeRodPairDetails2(directory,fileName,timeConv,pixelConv,1,1000);
% BinInterframeRodPairDetails2(directory,['Lower_' fileName],timeConv,pixelConv,1,1000);

%% Get the peak velocities for these velocities
% % close all
% parVelInfo = [relParVel; Distance];
% perpVelInfo = [relPerpVel; Distance];
% % RH_parVelInfo = [RH_relParVel; RH_Distance];
% % RH_perpVelInfo = [RH_relPerpVel; RH_Distance];
% 
% [parPeakVels, parAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(parVelInfo, 5, 0);
% figure()
% scatter(sepVals(2:end), parAvgs(1,:), 'filled')
% hold on
% errorbar(sepVals(2:end), parAvgs(1,:), parAvgs(2,:), 'LineStyle', 'None')
% xlabel('Microtubule Separation (um)');
% ylabel('Sliding velocity (um/sec)');
% title(sprintf('Relative parallel sliding velocity @%.1f degrees sep.', angleCutOff))
% set(gca,'FontSize',12);

% [perpPeakVels, perpAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(perpVelInfo, 5, 0);
% figure()
% scatter(sepVals(2:end), perpAvgs(1,:), 'filled')
% hold on
% errorbar(sepVals(2:end), perpAvgs(1,:), perpAvgs(2,:), 'LineStyle', 'None')
% xlabel('Microtubule Separation (um)');
% ylabel('Sliding velocity (um/sec)');
% title(sprintf('Relative perpendicular sliding velocity @%.1f degrees sep.', angleCutOff))
% set(gca,'FontSize',12);

%% Save data
disp('Saving data...')
%  save(fullfile(currDir,'allVelocityInfo.mat'),'velInfo');
%  save(fullfile(currDir,'allVelocityInfoArray.mat'),'velArray');
%  save(fullfile(currDir,'relativeParallelVelocities.mat'),'relParVel');
%  save(fullfile(currDir,'relativePerpendicularVelocities.mat'),'relPerpVel');
%  save(fullfile(currDir,'separationDistances.mat'),'Distance');

