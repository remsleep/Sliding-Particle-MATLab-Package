% Runs off of a folder of .csv files and plots the mean value of one of the
% fields

%% Define data directory and file name
dataDir = 'C:\Users\Rémi Boros\OneDrive\Documents\MATLAB\Lemma MT Tracking Code\Sliding-Particle-MATLab-Package\Test Cases\Value One Filt\13-spaced Binnings';

%% 
allFiles = dir(dataDir);
fieldOfInterest = 'ValueTwo';
meanVals = [];
stdDevs = [];
numElmts = [];
xVals = [];
for currBin = 3:numel(allFiles)
    
    currFile = allFiles(currBin).name;
    [meanVals(currBin-2), stdDevs(currBin-2), numElmts(currBin-2)] = ...
        FUNC_GetMeanValCSV(dataDir,currFile,{fieldOfInterest});
    currBinInd = min(strfind(currFile, '_'));      %Find the index where um is written in the file name
    xVals(currBin-2) = str2double(makeNumber(currFile(1:currBinInd-1)));
 
end

%% Plot mean velocities with standard error error bars
errorbar(xVals, meanVals, stdDevs./sqrt(numElmts),'o')
xlim([min(xVals) - 1, max(xVals) + 1]);  
set(gca, 'FontSize', 15)
title('Mean Val vs. Spacing')
xlabel('Spacing')
ylabel('Mean Val')


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
