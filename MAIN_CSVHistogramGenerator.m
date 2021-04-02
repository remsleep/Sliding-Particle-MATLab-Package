%% This script lets the user plot histogram distributions of velocity pair data

%% Filter out all pairs oriented more than cutOffAng radians apart
ogDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Batch1';
outDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Batch1\10 Degree Filter';
ogName = 'Batch1_LHVelPairs.csv';
outName = 'LinneaDataB1_10degreeFilter';

cutOffAng = deg2rad(10);
FUNC_FilterCSVIncl(ogDir,outDir,ogName,outName,{'DeltaA'},[-cutOffAng cutOffAng])
fileLoc = fullfile(outDir, [outName '.csv']);

%% Plot separation distributions
figure
[N, edges, ~] = FUNC_CSVHistogram(fileLoc,'Rsep');
histogram('BinCounts', N, 'BinEdges', edges)
set(gca, 'FontSize', 14)
title({'{\bf\fontsize{14} Isotropic pair distribution by separation distance}'; ...
    '{\fontsize{12} 10 degree angle tolerance, 2um bin separation}'},'FontWeight','Normal')
xlabel('Separation Distance (um)')
ylabel('Counts')

figure
[redN, redEdges, ~] = FUNC_CSVHistogram(fileLoc,'Rsep',0:.1:3);
histogram('BinCounts', redN, 'BinEdges', redEdges)
set(gca, 'FontSize', 14)
title({'{\bf\fontsize{14} Isotropic pair distribution by separation distance}'; ...
    '{\fontsize{12} 10 degree angle tolerance, 100nmum bin separation}'},'FontWeight','Normal')
xlabel('Separation Distance (um)')
ylabel('Counts')


%% Filter along Parallel and Perpendicular axes 
ogDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Batch1\10 Degree Filter';
outDir = ogDir;
ogName = 'LinneaDataB1_10degreeFilter';

cutOffParSep = 6; cutOffPerpSep = cutOffParSep;
FUNC_FilterCSVIncl(ogDir,outDir,ogName,[ogName '_WithinDeltaR.csv'],{'Rsep'},[-cutOffParSep cutOffParSep])
FUNC_FilterCSVIncl(ogDir,outDir,ogName,[ogName '_AlongPerpendicularAxis.csv'],{'ParSep'},[-cutOffParSep cutOffParSep])
FUNC_FilterCSVIncl(ogDir,outDir,ogName,[ogName '_AlongParallelAxis.csv'],{'PerpSep'},[-cutOffPerpSep cutOffPerpSep])


%% Plot separation distributions
% outDir = 'D:\Alex Two Color MT Data\Data Set 1\Combined\10 Degree Filter';
outName = 'LinneaDataB1_10degreeFilter_WithinDeltaR.csv';
fileLoc = fullfile(outDir, outName);
% figure
[N, edges, ~] = FUNC_CSVHistogram(fileLoc,'PerpSep',-60:2:60);
histogram('BinCounts', N, 'BinEdges', edges)
set(gca, 'FontSize', 14)
title({'{\bf\fontsize{14} Perpendicular axis pair distribution by perpendicular separation distance}'; ...
    '{\fontsize{12} 10 degree angle tolerance, 2um bin separation, 2um axis cut off}'},'FontWeight','Normal')
xlabel('Separation Distance (um)')
ylabel('Counts')

%% Make collection of velocity filter .csv's
ogDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Batch1\10 Degree Filter';
outDir = fullfile(ogDir,'Separation Filters Along Par Axis');
ogName = 'LinneaDataB1_10degreeFilter_AlongParallelAxis.csv';
mkdir(outDir);
minSep = 6; maxSep = 100; spacing = 13;
spacingMat = minSep:spacing:maxSep;

for index = 1:numel(spacingMat)

    cutOffSepVal = spacingMat(index);
    outName = sprintf('10degFilt_ParAxis_%sum_MaxParSep',num2str(spacingMat(index)));
    FUNC_FilterCSVIncl(ogDir,outDir,ogName,outName,{'ParSep'},[-cutOffSepVal cutOffSepVal])
    
    fileLoc = fullfile(outDir, [outName '.csv']);
    figure
    [N, edges, ~] = FUNC_CSVHistogram(fileLoc,'Vperp');
    histogram('BinCounts', N, 'BinEdges', edges)
    set(gca, 'FontSize', 14)
    title({'{\bf\fontsize{14} Perpendicular axis pair distribution by perpendicular separation distance}'; ...
        '{\fontsize{12} 10 degree angle tolerance, 2um bin separation, 2um axis cut off}'},'FontWeight','Normal')
    xlabel('Separation Distance (um)')
    ylabel('Counts')
end

%% Iterate through .csv's, fit to Gaussians, plot, and extract mean velocities
dataDir = 

%% Reproduce Linnea Figures
boundVals = 6; sepBounds = 10; binSize = 1;
% Parallel Velocity distribution within 5um along Parallel Axis
ogDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Batch1\10 Degree Filter';
ogName = 'LinneaDataB1_10degreeFilter_AlongParallelAxis.csv';
outDir = fullfile(ogDir,'Separation Filters Along Par Axis');
outName = '10degFilt_ParAxis6umFilt.csv';
FUNC_FilterCSVIncl(ogDir,outDir,ogName,outName,{'ParSep'},[-boundVals boundVals]);
fileLoc = fullfile(ogDir,ogName);
% Plot
figure
hold on
[N, edges, ~] = FUNC_CSVHistogram(fileLoc,'Vpar',-sepBounds:binSize:sepBounds);
edgeScatterVals = mean([edges(1:end-1);edges(2:end)]);
fpar = fit(edgeScatterVals.',(N/sum(N)).','gauss2');
scatter(edgeScatterVals, N/sum(N),'filled','red');
plot(fpar,'red')
% Perpendicular Velocity distribution within 5um along Perpendicular Axis
ogDir = 'D:\Linnea Data\forRemi\2020-09-19 Linnea Plots Compare\10 Degree Filter';
ogName = 'LinneaData_10degreeFilter_AlongPerpendicularAxis.csv';
outDir = fullfile(ogDir,'Separation Filters Along Perp Axis');
outName = '10degFilt_PerpAxis6umFilt.csv';
FUNC_FilterCSVIncl(ogDir,outDir,ogName,outName,{'PerpSep'},[-boundVals boundVals]);
fileLoc = fullfile(ogDir,ogName);
%Plot
[N, edges, ~] = FUNC_CSVHistogram(fileLoc,'Vperp',-sepBounds:binSize:sepBounds);
edgeScatterVals = mean([edges(1:end-1);edges(2:end)]);
fperp = fit(edgeScatterVals.',(N/sum(N)).','gauss2');
plot(fperp,'blue')
scatter(edgeScatterVals, N/sum(N),'filled','blue');
set(gca, 'FontSize', 14)
xlabel('Separation Distance (um)')
ylabel('Probability')
 title({'{\bf\fontsize{14} Parallel (red) and Perpendicular (blue) Velocity Distributions Along Rsep. Axes}'; ...
        '{\fontsize{12} 10 degree angle tolerance, 6um cut off separation}'},'FontWeight','Normal')

%% Single Channel Reproduce Linnea Figures
% boundVals = 6;
% % Parallel Velocity distribution within 5um along Parallel Axis
% ogDir = 'D:\Alex Two Color MT Data\Data Set 1\Combined\10 Degree Filter';
% ogName = 'CombinedData_10degreeFilter_AlongParallelAxis.csv';
% outDir = 'D:\Alex Two Color MT Data\Data Set 1\Combined\10 Degree Filter\Separation Filters Along Par Axis';
% outName = '10degFilt_ParAxis6umFilt.csv';
% FUNC_FilterCSVIncl(ogDir,outDir,ogName,outName,{'ParSep'},[-boundVals boundVals]);
% fileLoc = fullfile(ogDir,ogName);
% % Plot
% figure
% hold on
% [N, edges, ~] = FUNC_CSVHistogram(fileLoc,'Vpar',-0.7:.05:0.7);
% edgeScatterVals = mean([edges(1:end-1);edges(2:end)]);
% fpar = fit(edgeScatterVals.',(N/sum(N)).','gauss2');
% scatter(edgeScatterVals, N/sum(N),'filled','red');
% plot(fpar,'red')
% % Perpendicular Velocity distribution within 5um along Perpendicular Axis
% ogDir = 'D:\Alex Two Color MT Data\Data Set 1\Combined\10 Degree Filter';
% ogName = 'CombinedData_10degreeFilter_AlongPerpendicularAxis.csv';
% outDir = 'D:\Alex Two Color MT Data\Data Set 1\Combined\10 Degree Filter\Separation Filters Along Perp Axis';
% outName = '10degFilt_PerpAxis6umFilt.csv';
% FUNC_FilterCSVIncl(ogDir,outDir,ogName,outName,{'PerpSep'},[-boundVals boundVals]);
% fileLoc = fullfile(ogDir,ogName);
% %Plot
% [N, edges, ~] = FUNC_CSVHistogram(fileLoc,'Vperp',-0.7:.05:0.7);
% edgeScatterVals = mean([edges(1:end-1);edges(2:end)]);
% fperp = fit(edgeScatterVals.',(N/sum(N)).','gauss2');
% plot(fperp,'blue')
% scatter(edgeScatterVals, N/sum(N),'filled','blue');
% set(gca, 'FontSize', 14)
% xlabel('Separation Distance (um)')
% ylabel('Probability')
%  title({'{\bf\fontsize{14} Parallel (red) and Perpendicular (blue) Velocity Distributions Along Rsep. Axes}'; ...
%         '{\fontsize{12} 10 degree angle tolerance, 6um cut off separation}'},'FontWeight','Normal')
