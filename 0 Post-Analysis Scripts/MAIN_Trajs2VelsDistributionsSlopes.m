%% Define directories and conversion factors
dataDir = 'D:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Combined';
analysisDir = 'D:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Combined\2020-11-18';
% dataDir = 'D:\Two Channel Nematic\Linnea Data\forRemi\2020-11-19 Analysis';
% analysisDir = 'D:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Combined\Stephen Test\Channel 1\Channel 1';
pixelConv = 6.5*2/100;   %in microns/pixel
timeConv = 0.35;    %in seconds/frame
WINDOW = 1;         %in frames
angleCutOff = 10;   %in degrees
axisCutOff = 6;     %microns
allDataName = 'LinneaB1_';

%% Get reference frame data from tracks.m in dataDir and store in analysisDir
FUNC_Trajs2VelPairs(dataDir, analysisDir, allDataName, WINDOW, pixelConv, timeConv);
% FUNC_Trajs2VelPairs(dataDir, analysisDir, [allDataName '_unscaled'], WINDOW, 1, 1);

%% Filter out unaligned microtubules/objects
angFiltHandle = sprintf('%s Degree Filter', num2str(angleCutOff));
angFiltFolder = fullfile(analysisDir, angFiltHandle);
angFiltName = [allDataName sprintf('_%sDegFilter',num2str(angleCutOff))];
FUNC_FilterCSVIncl(analysisDir, angFiltFolder, allDataName, angFiltName, ...
    {'DeltaA'},[0 deg2rad(angleCutOff)])

%% Filter and keep data only along perpendicular axis
% axisFiltHandle = 'Perpendicular Axis';
% axisFiltFolder = fullfile(angFiltFolder, axisFiltHandle);
% axisFiltName = [angFiltName '_PerpAxis'];
% FUNC_FilterCSVIncl(angFiltFolder, axisFiltFolder, angFiltName, axisFiltName, ...
%     {'ParSep'}, [-axisCutOff axisCutOff]);
axisFiltHandle = 'Parallel Axis';
axisFiltFolder = fullfile(angFiltFolder, axisFiltHandle);
axisFiltName = [angFiltName '_ParAxis'];
FUNC_FilterCSVIncl(angFiltFolder, axisFiltFolder, angFiltName, axisFiltName, ...
    {'PerpSep'}, [-axisCutOff axisCutOff]);

%% Bin by separation distance along perpendicular axis
binSize = 13; binMin = 6; binMax = 100;      %in microns
% binFiltHandle = cleanString( sprintf('Perpendicular Separation Distance %sum Binnings',num2str(binSize)) );
binFiltHandle = cleanString( sprintf('Parallel Separation Distance %sum Binnings',num2str(binSize)) );
% binFiltFolder = fullfile(axisFiltFolder, binFiltHandle);
binFiltFolder = 'R:\Two Channel Nematic\Linnea Data\forRemi\Batch1\10 Degree Filter\Separation Filters Along Par Axis';

% %Remove inner fraction of data, then outer fraction of data
% for currBin = binMin:binSize:binMax
%    binFiltName = cleanString( sprintf('%sum_BinSize%s',num2str(currBin), num2str(binSize)) );
%    FUNC_FilterCSVOmit(axisFiltFolder, binFiltFolder, axisFiltName, binFiltName, ...
%        {'PerpSep'}, [-currBin currBin]);
%    FUNC_FilterCSVIncl(binFiltFolder, binFiltFolder, binFiltName, binFiltName, ...
%        {'PerpSep'}, [-(currBin+binSize) (currBin+binSize)]);
% end
%Remove inner fraction of data, then outer fraction of data
for currBin = binMin:binSize:binMax
   binFiltName = cleanString( sprintf('%sum_BinSize%s',num2str(currBin), num2str(binSize)) );
   FUNC_FilterCSVOmit(axisFiltFolder, binFiltFolder, axisFiltName, binFiltName, ...
       {'ParSep'}, [-currBin currBin]);
   FUNC_FilterCSVIncl(binFiltFolder, binFiltFolder, binFiltName, binFiltName, ...
       {'ParSep'}, [-(currBin+binSize) (currBin+binSize)]);
end

%% Get mean velocities and standard deviations
binDir = 'D:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Combined\2020-11-18\10 Degree Filter\Parallel Axis\Parallel Separation Distance 5um Binnings';
allFiles = dir(binDir);
fieldOfInterest = 'VRelpar';
meanVals = [];
stdDevs = [];
numElmts = [];
xVals = [];
for currBin = 3:numel(allFiles)
    
    currFile = allFiles(currBin).name;
    [meanVals(currBin-2), stdDevs(currBin-2), numElmts(currBin-2)] = ...
        FUNC_GetMeanValCSV(binDir,currFile,{fieldOfInterest});
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


