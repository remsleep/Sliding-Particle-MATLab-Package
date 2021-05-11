%% Define directories and conversion factors
dataDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Linnea Original Data';
analysisDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Linnea Original Data';
% dataDir = 'D:\Two Channel Nematic\Linnea Data\forRemi\2020-11-19 Analysis';
% analysisDir = 'D:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Combined\Stephen Test\Channel 1\Channel 1';
pixelConv = 6.5*2/100;   %in microns/pixel
timeConv = 0.35;    %in seconds/frame
WINDOW = 1;         %in frames
angleCutOff = 10;   %in degrees
% axisCutOff = 6;     %microns
axisCutOff = 6/13*100;     %pixels
allDataName = 'LinneaOgVelPairs';

%% Get reference frame data from tracks.m in dataDir and store in analysisDir
FUNC_Trajs2VelPairs(dataDir, analysisDir, allDataName, WINDOW, pixelConv, timeConv);
FUNC_Trajs2VelPairs(dataDir, analysisDir, [allDataName '_unscaled'], WINDOW, 1, 1);

%% Filter out unaligned microtubules/objects
angFiltHandle = sprintf('%s Degree Filter', num2str(angleCutOff));
angFiltFolder = fullfile(analysisDir, angFiltHandle);
angFiltName = [allDataName sprintf('_%sDegFilter',num2str(angleCutOff)) '_unscaled'];
% angFiltName = [allDataName sprintf('_%sDegFilter',num2str(angleCutOff))];

FUNC_FilterCSVIncl(analysisDir, angFiltFolder, [allDataName '_unscaled'], angFiltName, ...
    {'DeltaA'},[0 deg2rad(angleCutOff)])

%% Filter and keep data only along perpendicular axis
axisFiltHandle = 'Perpendicular Axis';
axisFiltFolderPerp = fullfile(angFiltFolder, axisFiltHandle);
axisFiltNamePerp = [angFiltName '_PerpAxis'];
FUNC_FilterCSVIncl(angFiltFolder, axisFiltFolderPerp, angFiltName, axisFiltNamePerp, ...
    {'ParSep'}, [-axisCutOff axisCutOff]);
axisFiltHandle = 'Parallel Axis';
axisFiltFolderPar = fullfile(angFiltFolder, axisFiltHandle);
axisFiltNamePar = [angFiltName '_ParAxis'];
FUNC_FilterCSVIncl(angFiltFolder, axisFiltFolderPar, angFiltName, axisFiltNamePar, ...
    {'PerpSep'}, [-axisCutOff axisCutOff]);

%% Bin by separation distance along perpendicular axis
binSize = 13; binMin = 6; binMax = 100;      %in microns
% binSize = 13/13*100; binMin = 6/13*100; binMax = 100/13*100;      %in microns

% PERPENDICULAR Axis Binning
axisFiltHandle = 'Perpendicular Axis';
axisFiltFolderPerp = fullfile(angFiltFolder, axisFiltHandle);
binFiltHandle = cleanString( sprintf('Perpendicular Separation Distance %sum Binnings',num2str(binSize)) );
binFiltFolderPerp = fullfile(axisFiltFolderPerp, binFiltHandle);
%Remove inner fraction of data, then outer fraction of data
for currBin = binMin:binSize:binMax
   binFiltName = cleanString( sprintf('%sum_BinSize%s',num2str(currBin), num2str(binSize)) );
   FUNC_FilterCSVOmit(axisFiltFolderPerp, binFiltFolderPerp, axisFiltNamePerp, binFiltName, ...
       {'PerpSep'}, [-currBin currBin]);
   FUNC_FilterCSVIncl(binFiltFolderPerp, binFiltFolderPerp, binFiltName, binFiltName, ...
       {'PerpSep'}, [-(currBin+binSize) (currBin+binSize)]);
end

% Process zero to binMin window
if binMin > 0
    currBin = 0;
       binFiltName = cleanString( sprintf('%sum_BinSize%s',num2str(currBin), num2str(binSize)) );
   FUNC_FilterCSVIncl(axisFiltFolderPerp, binFiltFolderPerp, axisFiltNamePerp, binFiltName, ...
       {'PerpSep'}, [-(currBin+binMin) (currBin+binMin)]);
end

% PARALLEL Axis Binning
axisFiltHandle = 'Parallel Axis';
axisFiltFolderPar = fullfile(angFiltFolder, axisFiltHandle);
binFiltHandle = cleanString( sprintf('Parallel Separation Distance %sum Binnings',num2str(binSize)) );
binFiltFolderPar = fullfile(axisFiltFolderPar, binFiltHandle);
% %Remove inner fraction of data, then outer fraction of data
for currBin = binMin:binSize:binMax
   binFiltName = cleanString( sprintf('%sum_BinSize%s',num2str(currBin), num2str(binSize)) );
   FUNC_FilterCSVOmit(axisFiltFolderPar, binFiltFolderPar, axisFiltNamePar, binFiltName, ...
       {'ParSep'}, [-currBin currBin]);
   FUNC_FilterCSVIncl(binFiltFolderPar, binFiltFolderPar, binFiltName, binFiltName, ...
       {'ParSep'}, [-(currBin+binSize) (currBin+binSize)]);
end

% Process zero to binMin window
if binMin > 0
    currBin = 0;
       binFiltName = cleanString( sprintf('%sum_BinSize%s',num2str(currBin), num2str(binSize)) );
   FUNC_FilterCSVIncl(axisFiltFolderPar, binFiltFolderPar, axisFiltNamePar, binFiltName, ...
       {'ParSep'}, [-(currBin+binMin) (currBin+binMin)]);
end

%% Get mean velocities and standard deviations
% PERPENDICULAR
allFiles = dir(binFiltFolderPar);
fieldOfInterest = 'VRelperp';
meanVals = [];
stdDevs = [];
numElmts = [];
xVals = [];
for currBin = 3:numel(allFiles)
    
    currFile = allFiles(currBin).name;
    [meanVals(currBin-2), stdDevs(currBin-2), numElmts(currBin-2)] = ...
        FUNC_GetMeanValCSV(binFiltFolderPerp,currFile,{fieldOfInterest});
    currBinInd = min(strfind(currFile, 'um'));      %Find the index where um is written in the file name
    xVals(currBin-2) = str2double(makeNumber(currFile(1:currBinInd-1)));
 
end

%% Plot mean velocities with standard error error bars
errorbar(xVals, meanVals, stdDevs./sqrt(numElmts),'o')
xlim([min(xVals) - 1, max(xVals) + 1]);  
set(gca, 'FontSize', 15)
title('Average Parallel Velocity vs. Perpendicular Separation')
xlabel('Separation Distance (um)')
ylabel('Average Velocity (um/s)')

%% Plot number of elements vs separation distance
figure
scatter(xVals, numElmts,'filled')
xlabel('Separation Distance')
ylabel('Number of pairs')
set(gca,'FontSize', 15)

%% Extra functions
function [queriedStr] = cleanString(queriedStr)
    %A simple function to replace '.' with 'p'
    badVals = strfind(queriedStr, '.');
    queriedStr(badVals) = 'p';
end

function [queriedStr] = makeNumber(queriedStr)
    %A simple function to replace '.' with 'p'. This function is very
    %limited in capability and should not be used generically
    badVals = min(strfind(queriedStr, 'p'));
    queriedStr(badVals) = '.';
end


