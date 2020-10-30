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

%% Look at different separation distances and plot parallel velocity distributions
numRegions = 10;
<<<<<<< HEAD
<<<<<<< HEAD
regionInterval = 0.5;%in microns
=======
regionInterval = 5;%in microns
>>>>>>> adding correctly working and updated code (1)
=======
regionInterval = 0.2;%in microns
>>>>>>> Merges code from old checkout

regionDir = fullfile(combinedDir,'RegionComparison');
mkdir(regionDir);
avgVels = zeros(1,10);
RMSD = avgVels;
regionVals = RMSD;
for region = 1:numRegions
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
    regionVals(region) = (upperBound+lowerBound)/2;
    
    fileName = [filtCSVName '_' num2str(region)];
    FUNC_FilterCSVIncl(combinedDir,regionDir,filtCSVName,fileName,{'PerpSep'},[-upperBound,upperBound]);
    FUNC_FilterCSVOmit(regionDir,regionDir,fileName,fileName,{'PerpSep'},[-lowerBound,lowerBound]);
    %plotting parameters
    
    numBins = 500;
    %plot for each region
    figure(region);
    filteredTable = readtable(fullfile(regionDir,fileName));
    parVels = filteredTable.('Vpar');
    
    outerBinEdge = 3*std(parVels);
    [N,edges] = histcounts(parVels,numBins);
    
    
    scatter(mean([edges(1:end-1);edges(2:end)]),N,'filled');
%     histogram(parVels,linspace(-outerBinEdge,outerBinEdge,numBins));
    title([num2str(lowerBound) ' to ' num2str(upperBound) ' microns']);

    
    avgVels(region) = mean(parVels);
    RMSD(region) = sqrt((1/(length(parVels)-1))*sum((parVels-avgVels(region)).^2));
    
end
    scale = diff(avgVels);
    avgScale = mean(scale);
    
    figure(region+1);
    errorbar(regionVals,avgVels,RMSD);
    