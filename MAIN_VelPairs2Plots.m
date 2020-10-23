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
% FUNC_FilterCSVOmit(combinedDir,combinedDir,[csvName '_SignSwitched'],filtCSVName,{'RelAngle'},[angleCutOff,(2*pi)-angleCutOff]);
%for channel option can choose 1:all channels, 2:both from first channel
%, 3: MTs from both channels, 4: both from second channel
ChOpt = 3;
if ChOpt ~= 1
    FUNC_FilterCSVIncl(combinedDir,combinedDir,[csvName '_SignSwitched'],filtCSVName,{'Ch1_Ch2'},[ChOpt,ChOpt]);
end
%% Filtering to create region with Desired Separation Width
regionWidth = 0.2;%in microns
FUNC_FilterCSVIncl(combinedDir,combinedDir,filtCSVName,filtCSVName,...
    {'ParSep'},[-regionWidth,regionWidth]);

%% Look at different separation distances and plot parallel velocity distributions
numRegions = 10;
regionInterval = 0.5;%in microns

regionDir = fullfile(combinedDir,'RegionComparison');
mkdir(regionDir);
avgVels = zeros(1,10);
for region = 1:numRegions
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
    
    fileName = [filtCSVName '_' num2str(region)];
    FUNC_FilterCSVIncl(combinedDir,regionDir,filtCSVName,fileName,{'PerpSep'},[-upperBound,upperBound]);
    FUNC_FilterCSVOmit(regionDir,regionDir,fileName,fileName,{'PerpSep'},[-lowerBound,lowerBound]);
    %plotting parameters
    
    numBins = 50;
    %plot for each region
    figure(region);
    filteredTable = readtable(fullfile(regionDir,fileName));
    parVels = filteredTable.('Vpar');
    
    outerBinEdge = 3*std(parVels);

    histogram(parVels,linspace(-outerBinEdge,outerBinEdge,numBins));
    title([num2str(lowerBound) ' to ' num2str(upperBound) ' microns']);

    
    avgVels(region) = mean(parVels);
   
end
    scale = diff(avgVels);
    avgScale = mean(scale);
    
    