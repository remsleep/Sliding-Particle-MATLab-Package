%% Define Location of CSV File
csvName = 'CombinedData';
combinedDir = 'C:\Users\Jude\Documents\SlidingMTData';
dataLoc = fullfile(combinedDir,csvName);

%% Switch Velocity 
%signs so positive velocity corresponds to contractile motion while 
%positive velocity corresponds to extensile motion
JUDE_SwitchVelocitySign(combinedDir,combinedDir,csvName,[csvName '_SignSwitched']);
%% Filter Through Data based on Angle and Channel Numbers
angleCutOff = deg2rad(10);
filtCSVName = [csvName '_Filtered'];
FUNC_FilterCSVOmit(combinedDir,combinedDir,[csvName '_SignSwitched'],filtCSVName,{'RelAngle'},[angleCutOff,(2*pi)-angleCutOff]);
%for channel option can choose 1:any channel combination, 2:both MTs from first channel
%, 3: pair contains one MT from each channel, 4: both MTs from second channel
ChOpt = 3;
if ChOpt ~= 1
    FUNC_FilterCSVIncl(combinedDir,combinedDir,[csvName '_SignSwitched'],filtCSVName,{'Ch1_Ch2'},[ChOpt,ChOpt]);
end
%% Filtering to create region with Desired Separation Width
regionWidth = 2;%in microns
FUNC_FilterCSVIncl(combinedDir,combinedDir,filtCSVName,filtCSVName,...
    {'ParSep'},[-regionWidth,regionWidth]);
%% Define region analysis parameters
numRegions = 10;
regionInterval = 0.2;%in microns
regionDir = fullfile(combinedDir,'RegionComparison');
mkdir(regionDir);
%% Create 2 dimensional parVels structure where fields are regions 
parVels = struct();
avgVels = zeros(1,10);
RMSD = avgVels;%for error bars
regionMidPts = RMSD;%to plot at center of region rather than on right or left side
for region = 1:numRegions
    %creating bounds for region
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
    regionMidPts(region) = (upperBound+lowerBound)/2;
    
    fileName = [filtCSVName '_' num2str(region)];
    FUNC_FilterCSVIncl(combinedDir,regionDir,filtCSVName,fileName,{'PerpSep'},[-upperBound,upperBound]);
    FUNC_FilterCSVOmit(regionDir,regionDir,fileName,fileName,{'PerpSep'},[-lowerBound,lowerBound]);

    
    filteredTable = readtable(fullfile(regionDir,fileName));
    currFieldName = ['RegionNum_' num2str(region)];
    parVels.(currFieldName) = filteredTable.('Vpar');
    
    currParVels = parVels.(currFieldName);
    avgVels(region) = mean(currParVels);
    RMSD(region) = sqrt((1/(length(currParVels)-1))*sum((currParVels-avgVels(region)).^2));
  
end   
%%finding scaling factor
    scale = diff(avgVels);
    avgScale = mean(scale);
%% Apply scaling factor correction to parVels array
for region = 1:numRegions
   currFieldName = ['RegionNum_' num2str(region)];
   parVels.(currFieldName) = parVels.(currFieldName) + (avgScale * region);
end
%% Plot Relative Velocity Distributions for Each Region
numBins = 500;
for region = 1:numRegions
    currFieldName = ['RegionNum_' num2str(region)];
    edges = linspace(-5,5,numBins);
    N = histcounts(parVels.(currFieldName),edges);
    
    figure(region);
    scatter(mean([edges(1:end-1);edges(2:end)]),N,'filled');
    
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
    title([num2str(lowerBound) ' to ' num2str(upperBound) ' microns']);
    
end    
%     histogram(parVels,linspace(-outerBinEdge,outerBinEdge,numBins));    
    figure(region+1);
    errorbar(regionMidPts,avgVels,RMSD);
    title('Average Velocity versus Region Separation Distance');
    