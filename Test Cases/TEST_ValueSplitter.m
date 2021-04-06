% Runs off of a test file called "Splitting Test.csv" and checks that the
% library is able to split a data set into subsets separated by some deltax

%% Define data directory and file name
dataDir = 'C:\Users\Rémi Boros\OneDrive\Documents\MATLAB\Lemma MT Tracking Code\Sliding-Particle-MATLab-Package\Test Cases';
allDataName = 'Splitting Test - Pos';

%% Make binned .csvs along Value One (field name)
binSize = 13; binMin = 6; binMax = 100;      %in microns

% PERPENDICULAR Axis Binning
filtHandle = 'Value One Filt';
filtFolder = fullfile(dataDir, filtHandle);
binFiltHandle = cleanString( sprintf('%s-spaced Binnings',num2str(binSize)) );
binFiltFolder = fullfile(filtFolder, binFiltHandle);
%Remove inner fraction of data, then outer fraction of data
for currBin = binMin:binSize:binMax
   binFiltName = cleanString( sprintf('%s_BinSize%s',num2str(currBin), num2str(binSize)) );
   FUNC_FilterCSVOmit(dataDir, binFiltFolder, allDataName, binFiltName, ...
       {'ValueOne'}, [-currBin currBin]);
   FUNC_FilterCSVIncl(binFiltFolder, binFiltFolder, binFiltName, binFiltName, ...
       {'ValueOne'}, [-(currBin+binSize) (currBin+binSize)]);
end

% Process zero to binMin window
if binMin > 0
    currBin = 0;
       binFiltName = cleanString( sprintf('%s_BinSize%s',num2str(currBin), num2str(binSize)) );
   FUNC_FilterCSVIncl(dataDir, binFiltFolder, allDataName, binFiltName, ...
       {'ValueOne'}, [-(currBin+binMin) (currBin+binMin)]);
end

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

