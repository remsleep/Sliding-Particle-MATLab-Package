%Begin with Trajectory data in a structure
% disp(['Current batch: ', num2str(currBatch)])
% currDir = [baseDir, num2str(currBatch)];
% load(fullfile(currDir,'trajectoryData.mat'));
%Define scalings, if necessary
pixelConv = 6.5*2/100;      %%In um/pix
timeConv = 0.35;            %%In seconds/frame
WINDOW = 5;                 %%Window of integration for which velocities are calculated
angleCutOff = 180;           %%Max angle in degrees allowed between MTs
ySize = 1280;
%% Convert trace array to structure of trajectories
testFIELDS = {'ID','X','Y','FRAME','ORIENT'};
TRAJECTORY = FUNC_Array2Structure(circshift(tr',1,1),testFIELDS);
RH_TRAJECTORY = FUNC_LeftToRightInvert(TRAJECTORY,ySize);

%% Calculate velocities
disp('Calculating velocities...')
tic
velInfo = FUNC_Find_Velocity(TRAJECTORY, WINDOW, pixelConv, timeConv);
toc
%% Convert to an array
disp('Converting to velocities array...')
[velArray, FIELDS] = FUNC_Structure2Array(velInfo);
% [RH_velArray, FIELDS] = FUNC_Structure2Array(RH_velInfo);

%% Consturct new arrays of velocities parallel and perpendicular to MT alignment
disp('Calculating relative velocities...')
[relParVel, relPerpVel, Distance] = FUNC_PairwiseParPerpVelocitiesSameChannelArray(velInfo, WINDOW, deg2rad(angleCutOff));
% [RH_relParVel, RH_relPerpVel, RH_Distance] = FUNC_PairwiseParPerpVelocitiesSameChannelArray(RH_velInfo, WINDOW, deg2rad(angleCutOff));
% [relParVelSub, relPerpVelSub, DistanceSub] = FUNC_PairwiseParPerpVelocitiesSameChannelArray(velInfo, WINDOW);

%% Get the peak velocities for these velocities
% close all
parVelInfo = [relParVel; Distance];
perpVelInfo = [relPerpVel; Distance];
% RH_parVelInfo = [RH_relParVel; RH_Distance];
% RH_perpVelInfo = [RH_relPerpVel; RH_Distance];

[parPeakVels, parAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(parVelInfo, 5, 0);
figure()
scatter(sepVals(2:end), parAvgs(1,:), 'filled')
hold on
errorbar(sepVals(2:end), parAvgs(1,:), parAvgs(2,:), 'LineStyle', 'None')
xlabel('Microtubule Separation (um)');
ylabel('Sliding velocity (um/sec)');
title(sprintf('Relative parallel sliding velocity @%.1f degrees sep.', angleCutOff))
set(gca,'FontSize',12);

[perpPeakVels, perpAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(perpVelInfo, 5, 0);
figure()
scatter(sepVals(2:end), perpAvgs(1,:), 'filled')
hold on
errorbar(sepVals(2:end), perpAvgs(1,:), perpAvgs(2,:), 'LineStyle', 'None')
xlabel('Microtubule Separation (um)');
ylabel('Sliding velocity (um/sec)');
title(sprintf('Relative perpendicular sliding velocity @%.1f degrees sep.', angleCutOff))
set(gca,'FontSize',12);

% [parPeakVels, parAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(RH_parVelInfo, 5, 0);
% figure()
% scatter(sepVals(2:end), parAvgs(1,:), 'filled')
% hold on
% errorbar(sepVals(2:end), parAvgs(1,:), parAvgs(2,:), 'LineStyle', 'None')
% xlabel('Microtubule Separation (um)');
% ylabel('Sliding velocity (um/sec)');
% title(sprintf('Relative parallel sliding velocity @%.1f degrees sep.', angleCutOff))
% set(gca,'FontSize',12);
% 
% [perpPeakVels, perpAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(RH_perpVelInfo, 5, 0);
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
 save(fullfile(currDir,'LinAllVelocityInfo.mat'),'velInfo');
 save(fullfile(currDir,'LinAllVelocityInfoArray.mat'),'velArray');
 save(fullfile(currDir,'LinRelativeParallelVelocities.mat'),'relParVel');
 save(fullfile(currDir,'LinRelativePerpendicularVelocities.mat'),'relPerpVel');
 save(fullfile(currDir,'LinSeparationDistances.mat'),'Distance');

