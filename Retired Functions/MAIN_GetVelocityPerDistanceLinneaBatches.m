%Begin with Trajectory data in a structure
baseDir = 'D:\Linnea Data\forRemi\Batch';
for currBatch = 1:10
disp(['Current batch: ', num2str(currBatch)])
currDir = [baseDir, num2str(currBatch)];
load(fullfile(currDir,'RH_trajectoryData.mat'));
%Define scalings, if necessary
pixelConv = 6.5*2/100;      %%In um/pix
timeConv = 0.35;            %%In seconds/frame
WINDOW = 8;                 %%Window of integration for which velocities are calculated
angleCutOff = 10;           %%Max angle in degrees allowed between MTs
%% Calculate velocities
disp('Calculating velocities...')
tic
velInfo = FUNC_Find_Velocity(RH_TRAJECTORY, WINDOW, pixelConv, timeConv);
toc
%% Convert to an array
disp('Converting to velocities array...')
[velArray, FIELDS] = FUNC_Structure2Array(velInfo);

%% Consturct new arrays of velocities parallel and perpendicular to MT alignment
disp('Calculating relative velocities...')
[relParVel, relPerpVel, Distance] = FUNC_PairwiseParPerpVelocitiesSameChannelArray(velInfo, WINDOW, deg2rad(angleCutOff));
% [relParVelSub, relPerpVelSub, DistanceSub] = FUNC_PairwiseParPerpVelocitiesSameChannelArray(velInfo, WINDOW);

%% Get the peak velocities for these velocities
% close all
% parVelInfo = [relParVel; Distance];
% perpVelInfo = [relPerpVel; Distance];
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
% 
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
 save(fullfile(currDir,['allVelocityInfo_' num2str(WINDOW) '_' num2str(angleCutOff) '.mat']),'velInfo');
 save(fullfile(currDir,['allVelocityInfoArray_' num2str(WINDOW) '_' num2str(angleCutOff) '.mat']),'velArray');
 save(fullfile(currDir,['relativeParallelVelocities_' num2str(WINDOW) '_' num2str(angleCutOff) '.mat']),'relParVel');
 save(fullfile(currDir,['relativePerpendicularVelocities_' num2str(WINDOW) '_' num2str(angleCutOff) '.mat']),'relPerpVel');
 save(fullfile(currDir,['separationDistances_' num2str(WINDOW) '_' num2str(angleCutOff) '.mat']),'Distance');
end 
