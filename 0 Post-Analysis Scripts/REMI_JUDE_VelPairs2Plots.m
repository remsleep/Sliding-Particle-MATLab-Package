%% Define Location of CSV File
csvName = 'CombinedData.csv';
MTDataDir = 'R:\Two Channel Nematic\Alex Two Color MT Data\Ilastik Training\Analyzed Data\9 Degree Filt 5um-s Vel Filtered InterChannel\Parallel Axis 6um Width\2um Spacing';

dataLoc = fullfile(MTDataDir,csvName);
pixelConv = .101;
timeConv = 1.29;
scaleVal = 350;
dx = scaleVal/14000;

%% Stitch Velocity Data Sets Together
%if there are multiple data sets that should be analyzed together, this
%section stitches the data sets together so that they can be analyzed as
%one
saveName = fullfile(MTDataDir,csvName);
numDataSets = 0;
for dataSet = 1:numDataSets
    dataName = fullfile(MTDataDir,[csvName '_' num2str(dataSet)]);
    Jude_StitchDataSets(saveName,dataName);
end
%% Switch Velocity Signs
%ensures negative velocity corresponds to contractile motion while 
%positive velocity corresponds to extensile motion
% JUDE_SwitchVelocitySign(MTDataDir,MTDataDir,csvName,[csvName '_SignSwitched']);

%% %%%%%%%%%%%%%%%%%%% FILTERING %%%%%%%%%%%%%%%%%%%%%%%%%

%% Filter Through Data based on Angle
degreeCutOff = 9;
angleCutOff = deg2rad(degreeCutOff);
maxVel = scaleVal*pixelConv/timeConv;

% filtDir = fullfile(MTDataDir, sprintf('%s Degree Filt',num2str(degreeCutOff)));
filtDir = fullfile(MTDataDir, sprintf('%s Degree Filt Vel Filtered',num2str(degreeCutOff)));
filtCSVName = [csvName '_' num2str(degreeCutOff) 'Degrees'];
FUNC_FilterCSVOmit(MTDataDir,filtDir,csvName,filtCSVName,{'DeltaA'},[angleCutOff,(2*pi)-angleCutOff]);
FUNC_FilterCSVIncl(filtDir,filtDir,filtCSVName,filtCSVName,{'VRelpar'},[-maxVel, maxVel]);
    FUNC_FilterCSVIncl(filtDir,filtDir,filtCSVName,filtCSVName,{'Ch1_Ch2'},[4,4]);
% FUNC_FilterCSVOmit(MTDataDir,MTDataDir,[csvName '_SignSwitched'],filtCSVName,{'DeltaA'},[angleCutOff,(2*pi)-angleCutOff]);

%% Filter Through Data based on Channel Number
%for channel option can choose 1:any channel combination, 2:both MTs from first channel
%, 3: pair contains one MT from each channel, 4: both MTs from second channel
ChOpt = 4;
if ChOpt ~= 1
    FUNC_FilterCSVIncl(MTDataDir,MTDataDir,filtCSVName,filtCSVName,{'Ch1_Ch2'},[ChOpt,ChOpt]);
end
%% Filtering to create region with Desired Separation Width
regionWidth = 6;%in microns
parCSVName = [filtCSVName '_ParAxis'];
perpCSVName = [filtCSVName '_PerpAxis'];
parDir = fullfile(filtDir, ['Parallel Axis '  sprintf('%sum Width',num2str(regionWidth))]);
perpDir = fullfile(filtDir, ['Perpendicular Axis '  sprintf('%sum Width',num2str(regionWidth))]);

%For regions along parallel axis
FUNC_FilterCSVIncl(filtDir,parDir,filtCSVName,parCSVName,...
    {'PerpSep'},[-regionWidth,regionWidth]);

%For regions along perpendicular axis
FUNC_FilterCSVIncl(filtDir,perpDir,filtCSVName,perpCSVName,...
    {'ParSep'},[-regionWidth,regionWidth]);

%% Define region analysis parameters
numRegions = 30;
regionLength = 2;%in microns
% numBins = 50;
% edge = 100;%determines how far farthest bin is from zero
edges = (-scaleVal:dx:scaleVal)*pixelConv/timeConv;
regionMidPts = zeros(1,numRegions);
for region = 1:numRegions
    regionMidPts(region) = (((region-1)*(regionLength))+(region*regionLength))/2;
end

%Making Directories to Store CSV for Each Distribution
parRegionDir = fullfile(parDir,sprintf('%sum Spacing',num2str(regionLength)));
mkdir(parRegionDir);

perpRegionDir = fullfile(perpDir,sprintf('%sum Spacing',num2str(regionLength)));
mkdir(perpRegionDir);

%% Create 2 dimensional parVels structure where fields are regions 
parVels = struct();
%create array to determine number of data points for each distribution

for region = 1:numRegions
    %creating bounds for region
    lowerBound = (region-1)*regionLength;
    upperBound = region*regionLength;

    
    parFileName = cleanString([sprintf('%06.1f',(region*regionLength)) 'um']);
    FUNC_FilterCSVIncl(parDir,parRegionDir,parCSVName,parFileName,{'ParSep'},[-upperBound,upperBound]);
    FUNC_FilterCSVOmit(parRegionDir,parRegionDir,parFileName,parFileName,{'ParSep'},[-lowerBound,lowerBound]);
    filteredTable = readtable(fullfile(parRegionDir,FUNC_checkAppendCSV(parFileName)));
%     currFieldName = ['Region_' num2str(region*regionLength) 'um'];
    allVels(region).parVels = filteredTable.('VRelpar');
    allVels(region).parVelRegion = region*regionLength;
    
    perpFileName = cleanString([sprintf('%06.1f',(region*regionLength)) 'um']);
    FUNC_FilterCSVIncl(perpDir,perpRegionDir,perpCSVName,perpFileName,{'PerpSep'},[-upperBound,upperBound]);
    FUNC_FilterCSVOmit(perpRegionDir,perpRegionDir,perpFileName,perpFileName,{'PerpSep'},[-lowerBound,lowerBound]);
    filteredTable = readtable(fullfile(perpRegionDir,FUNC_checkAppendCSV(perpFileName)));
%     currFieldName = ['Region_' num2str(region*regionLength) 'um'];
    allVels(region).perpVels = filteredTable.('VRelperp');
    allVels(region).perpVelReigon = region*regionLength;
  
end
%% %%%%%%%%%%%%%%%%%% MINOR ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%

%% Extract Amount of Data in Each Region
numDataDist = zeros(2,numRegions);
for region = 1:numRegions
%     currFieldName = ['Region_' num2str(region*regionLength) 'um'];
    numDataDist(1,region) = length(allVels(region).parVels);
    numDataDist(2,region) = length(allVels(region).perpVels);
end
%% Extract Avg Velocities From ParVels Structure (To Compare with Peaks of Distributions)
    avgVels = zeros(1,numRegions);
    avgV_Error= avgVels;
    for region = 1:numRegions
%         currFieldName = ['Region_' num2str(region*regionLength) 'um'];
        currParVels = allVels(region).parVels;
        avgVels(region) = mean(currParVels);
        
        avgV_Error(region) = std(currParVels);
        avgV_Error(region) = avgV_Error(region)/sqrt(numDataDist(1,region));
    end
    scale = diff(avgVels);
    avgScale = mean(scale);
    figure(1);
    hold on
    linearFit = polyfit(regionMidPts,avgVels,1);
    errorbar(regionMidPts,avgVels,avgV_Error,'.');
    avgVelSlope = linearFit(1,1);
    plot(regionMidPts,(linearFit(1,1)*regionMidPts + linearFit(1,2)));
    title(['Average Velocity of Each Distribution. Slope: ' num2str(avgVelSlope)]); 
    xlabel('Parallel Separation Distance (um)');
    ylabel('Average Value of Par Vel Distributions(um/s)');
    hold off

%% Apply horizontal scaling factor correction to parVels Structure
% for region = 1:numRegions
%    currFieldName = ['RegionNum_' num2str(region)];
%    parVels.(currFieldName) = parVels.(currFieldName) + (avgScale * region);
% end


%% %%%%%%%%%%%%%%%%%%%%%%%%% PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%

%% Plot Relative Velocity Distributions for Each Region 
%%Also Determining Amount of Data in Each Bin and Extacting Peak Values of
%%Each Distribution
plotOpt = 1;
%^determines whether gaussian fit will be plotted; 0: no gaussian fit,
%1:gaussian fit

%Initializing Arrays
numDataBin = zeros(numBins-1,numRegions); 
peaks = zeros(1,numRegions);
peakError = peaks;

%create bins for each region and plot distribution
for region = 1:numRegions
    currFieldName = ['Region_' num2str(region*regionLength) 'um'];
    
    N = histcounts(parVels.(currFieldName),edges);
    %Applies Vertical Scaling
    N_scaled = N/numDataDist(1,region);
    
    figure(region+1);
    %Plots based on which fit option user chooses
    if plotOpt == 1
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss1');
        plot(f,'r',mean([edges(1:end-1);edges(2:end)]),N_scaled);
        peaks(1,region) = f.b1;
        peakError(1,region) = f.c1;
        peakError(1,region) = peakError(1,region)/sqrt(numDataDist(1,region));
        xlim([-8,8]);
    elseif plotOpt == 2
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss2');
        plot(f,'r',mean([edges(1:end-1);edges(2:end)]),N_scaled);
    elseif plotOpt == 0 % scatter plot
        scatter(mean([edges(1:end-1);edges(2:end)]),N_scaled,'filled');
    end
    
    %Creating Plot Title
    lowerBound = (region-1)*regionLength;
    upperBound = region*regionLength;
    title([num2str(lowerBound) ' to ' num2str(upperBound) ' microns']);
    
    %N gives amount of data points for each bin for a given distribution
    numDataBin(:,region) = N';
end    
%% Overlay all distributions 
figure(region+2);
hold on;
legendNames = cell(1,numRegions);
for region = 1:numRegions
    currFieldName = ['Region_' num2str(region*regionLength) 'um'];
    N = histcounts(parVels.(currFieldName),edges);
    %applying vertical scaling
    N_scaled = N/numDataDist(1,region);
    
    %Determining Color for Each Gaussian --> progresses as region increases
    color = [1-(region-1)/numRegions,(region-1)/numRegions,(region-1)/numRegions];
    
    %Plotting Each Scatter Plot One at a Time
    scatter(mean([edges(1:end-1);edges(2:end)]),N_scaled,'filled','MarkerFaceColor',color);

    %Creating Legend Names
    lowerBound = (region-1)*regionLength;
    upperBound = region*regionLength;
    str = [num2str(lowerBound), ' to ',num2str(upperBound),' microns'];
    legendNames{region} = join(str);
end
    title('Overlayed Parallel Velocity Distributions');
    legend(legendNames);
hold off;
%% Overlay Gaussian Fits
plotOpt = 1;
figure(region+3);
hold on;
legendNames = strings(1,numRegions);
for region = 1:numRegions
    currFieldName = ['Region_' num2str(region*regionLength) 'um'];
    N = histcounts(parVels.(currFieldName),edges);
    %applying vertical scaling
    N_scaled = N/numDataDist(1,region);
    
    %setting color of each distribution
    color = [1-(region-1)/numRegions,0,(region-1)/numRegions];
    
    %find gaussian fit based on plotOpt
    if plotOpt == 1
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss1');
    elseif plotOpt == 2
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss2');
    end
    p = plot(f,mean([edges(1:end-1);edges(2:end)]),N_scaled);
    
    %delete scatter data to see gaussian distributions more clearly
    delete(p(1,1));
    
    %create legend names for each distribution
    lowerBound = (region-1)*regionLength;
    upperBound = region*regionLength;
    str = [num2str(lowerBound) ' to ' num2str(upperBound) ' microns'];
    
    %set color for each distribution and display correct legend name
    fitLine = p(2,1);
    fitLine.Color = color;
    fitLine.DisplayName = str;
   
end
    title('Overlayed Parallel Velocity Gaussian Fits');
    xlabel('parallel relative velocity (um/s)');
    ylabel('normalized frequency');

hold off;

%% Plot Peaks for Each Distribution
figure(region + 4)
hold on 
errorbar(regionMidPts,peaks,peakError,'.');
xlabel('Parallel Separation Distance (um)');
ylabel('Peak Value of Par Vel Distributions(um/s)');
linearFit = polyfit(regionMidPts,peaks,1);
peakSlope = linearFit(1,1);
plot(regionMidPts,(linearFit(1,1)*regionMidPts + linearFit(1,2)));
title(['Peak of Each Distribution. Slope: ' num2str(peakSlope)]);
hold off


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

