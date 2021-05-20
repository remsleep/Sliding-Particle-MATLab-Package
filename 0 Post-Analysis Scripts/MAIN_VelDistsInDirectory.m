%% DESCRIPTION
% This script takes in the directory of a folder wherein is expected to be 
% a series of .csv files. The script does not distinguish between files and
% will simply try to extract data from all of them. Order is determined by
% file name. The script iterates through each .csv and returns
% distributions of the desired field FIELDNAME from each file. The script
% also plots the mean value of FIELDNAME from each file.

%% Define directory of .csvs
binnedDir = 'R:\Two Channel Nematic\Linnea Data\forRemi\Linnea Original Data\9 Degree Filt Vel Filtered\Parallel Axis\ParAxisCSVs';
pixelConv = 6.5*2/100;
timeConv = .35;

fieldName = 'VRelpar';
velEdges = (-70:.005:70)*pixelConv/timeConv;

%% Get .csv file names
fileNames = dir(fullfile(binnedDir, '*.csv'));
regionEdges = zeros(numel(fileNames),1);

%% Iterate through each file and plot BinInterframe spacing distributions
figure
hold on
for currFile = 1:numel(fileNames)
    
    currDir = fullfile(fileNames(currFile).folder, fileNames(currFile).name);
    [sumN,edges,outlierNum] = FUNC_CSVHistogram(currDir,fieldName,velEdges);
    scatter(edges(2:end),(sumN),'filled')
    tempName = fileNames(currFile).name;
%     regionEdges(currFile) = str2double(makeNumber(tempName(1:6)));
    regionEdges(currFile) = str2double(tempName(1:4));
    
end

%% Iterate through each file and plot more controlled spacing distributions
conEdges = -10:.1:10;
figure
hold on
for currFile = 1:numel(fileNames)
    
    currDir = fullfile(fileNames(currFile).folder, fileNames(currFile).name);
    [sumN,edges,outlierNum] = FUNC_CSVHistogram(currDir,fieldName,conEdges);
    scatter(edges(2:end),(sumN),'filled')

    
end

%% Get mean value of field for each separation distance
meanVals = zeros(numel(regionMidPoints),1);
numElmts = meanVals;

for currFile = 1:numel(fileNames)
    
    [meanVals(currFile),~,numElmts(currFile)] = FUNC_GetMeanValCSV(fileNames(currFile).folder, fileNames(currFile).name, {fieldName});

end

figure
scatter(regionEdges, meanVals,'filled')

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


