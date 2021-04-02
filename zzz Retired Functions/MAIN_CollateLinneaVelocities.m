    %% Define scalings, if necessary
close all
pixelConv = 6.5*2/100;       %%In um/pix
timeConv = 0.35;        %%In seconds/frame
WINDOW = 2;             %%Window of integration for which velocities are calculated
angleCutOff = 10;       %%Max angle in degrees allowed between MTs
totalBatches = 10;
%% Load
prefixDir = 'D:\Linnea Data\forRemi\Batch';
figure()
hold on
figure()
hold on
allPar = [];
allPerp = [];
allDist = [];
for batchNum = 1:totalBatches
    currDir = [prefixDir, num2str(batchNum)];
    
    % Get the peak velocities for these velocities
    % close all

    load(fullfile(currDir,'relativeParallelVelocities_8_10.mat'));
    load(fullfile(currDir,'relativePerpendicularVelocities_8_10.mat'));
    load(fullfile(currDir,'separationDistances_8_10.mat'));

    parVelInfo = [relParVel; Distance];
    perpVelInfo = [relPerpVel; Distance];
    allPar = [allPar, relParVel];
    allPerp = [allPerp, relPerpVel];
    allDist = [allDist, Distance];
    
    [parPeakVels, parAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(parVelInfo, 5, 0);
    figure(1)
    scatter(sepVals(2:end), parAvgs(1,:), 40, ...
        [(1-(batchNum-1)/totalBatches) 0 (batchNum-1)/totalBatches], 'filled')
    hold on
%     tempErr = errorbar(sepVals(2:end), parAvgs(1,:), parAvgs(2,:), 'LineStyle', 'None');
%     tempErr.Color =  [(1-(batchNum-1)/totalBatches) 0 (batchNum-1)/totalBatches];
    xlabel('Microtubule Separation (um)');
    ylabel('Sliding velocity (um/sec)');
    title(sprintf('Relative parallel sliding velocity @%.1f degrees sepn .', angleCutOff))
    set(gca,'FontSize',12);

    [perpPeakVels, perpAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(perpVelInfo, 5, 0);
    figure(2)
    scatter(sepVals(2:end), perpAvgs(1,:), 40, ...
        [(1-(batchNum-1)/totalBatches) 0 (batchNum-1)/totalBatches],'filled')
    hold on
%     tempErr = errorbar(sepVals(2:end), perpAvgs(1,:), perpAvgs(2,:), 'LineStyle', 'None');
%     tempErr.Color =  [(1-(batchNum-1)/totalBatches) 0 (batchNum-1)/totalBatches];
    xlabel('Microtubule Separation (um)');
    ylabel('Sliding velocity (um/sec)');
    title(sprintf('Relative perpendicular sliding velocity @%.1f degrees sep.', angleCutOff))
    set(gca,'FontSize',12);
end

%% Plot average

allParInfo = [allPar; allDist];
allPerpInfo = [allPerp; allDist];

[allParPeakVels, parAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(allParInfo, 5, 0);
figure(1)
scatter(sepVals(2:end), parAvgs(1,:), 100, [1 0 1], 'filled', 'd')
hold on
% errorbar(sepVals(2:end), parAvgs(1,:), parAvgs(2,:), ...
%     'Color', [1 0 1], 'LineWidth', 4, 'LineStyle', 'None');
xlabel('Microtubule Separation (um)');
ylabel('Sliding velocity (um/sec)');
title(sprintf('Relative parallel sliding velocity @%.1f degrees sep.', angleCutOff))
set(gca,'FontSize',12);

[allPerpPeakVels, perpAvgs, ~, sepVals] = FUNC_HistogramVelOverSeparation(allPerpInfo, 5, 0);
figure(2)
scatter(sepVals(2:end), perpAvgs(1,:), 100, [1 0 1], 'filled', 'd')
hold on
% errorbar(sepVals(2:end), perpAvgs(1,:), perpAvgs(2,:), ...
%     'Color', [1 0 1], 'LineWidth', 4, 'LineStyle', 'None');
xlabel('Microtubule Separation (um)');
ylabel('Sliding velocity (um/sec)');
title(sprintf('Relative perpendicular sliding velocity @%.1f degrees sep.', angleCutOff))
set(gca,'FontSize',12);
