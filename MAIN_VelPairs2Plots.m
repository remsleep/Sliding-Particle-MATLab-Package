%% Define Location of CSV File
csvName = 'CombinedData';
combinedDir = 'C:\Users\judem\Documents\SlidingMTData';
dataLoc = fullfile(combinedDir,csvName);
<<<<<<< HEAD
%% Stitch Different Data Sets Together
savename = fullfile(combinedDir,csvName);
numSets = 0;
for set = 1:numSets
    setname = fullfile(combinedDir, [csvName '(' num2str(set) ')']);
    JUDE_StitchDatSets(savename,setname);
=======
%% Stitch Velocity Data Sets Together
%if there are multiple data sets that should be analyzed together, this
%section stitches the data sets together so that they can be analyzed as
%one
saveName = fullfile(combinedDir,csvName);
numDataSets = 0;
for dataSet = 1:numDataSets
    dataName = fullfile(combinedDir,[csvName '_' num2str(dataSet)]);
    Jude_StitchDataSets(saveName,dataName);
>>>>>>> aada226005e7b77b1cd6c4c18c7a56b64f882119
end
%% Switch Velocity Signs
%ensures negative velocity corresponds to contractile motion while 
%positive velocity corresponds to extensile motion
JUDE_SwitchVelocitySign(combinedDir,combinedDir,csvName,[csvName '_SignSwitched']);
%% Filter Through Data based on Angle
angleCutOff = deg2rad(10);
filtCSVName = [csvName '_Filtered'];
FUNC_FilterCSVOmit(combinedDir,combinedDir,[csvName '_SignSwitched'],filtCSVName,{'DeltaA'},[angleCutOff,(2*pi)-angleCutOff]);

%% Filter Through Data based on Channel Number
%for channel option can choose 1:any channel combination, 2:both MTs from first channel
%, 3: pair contains one MT from each channel, 4: both MTs from second channel
ChOpt = 1;
if ChOpt ~= 1
    FUNC_FilterCSVIncl(combinedDir,combinedDir,filtCSVName,filtCSVName,{'Ch1_Ch2'},[ChOpt,ChOpt]);
end
%% Filtering to create region with Desired Separation Width
regionWidth = 2;%in microns
FUNC_FilterCSVIncl(combinedDir,combinedDir,filtCSVName,filtCSVName,...
    {'PerpSep'},[-regionWidth,regionWidth]);
%% Define region analysis parameters
numRegions = 10;
regionInterval = 4;%in microns
regionDir = fullfile(combinedDir,'RegionComparison');
mkdir(regionDir);
regionMidPts = zeros(1,numRegions);
for region = 1:numRegions
    regionMidPts(region) = (((region-1)*(regionInterval))+(region*regionInterval))/2;
end

%% Create 2 dimensional parVels structure where fields are regions 
parVels = struct();
%create array to determine number of data points for each distribution

for region = 1:numRegions
    %creating bounds for region
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;

    
    fileName = [filtCSVName '_' num2str(region)];
    FUNC_FilterCSVIncl(combinedDir,regionDir,filtCSVName,fileName,{'ParSep'},[-upperBound,upperBound]);
    FUNC_FilterCSVOmit(regionDir,regionDir,fileName,fileName,{'ParSep'},[-lowerBound,lowerBound]);

    
    filteredTable = readtable(fullfile(regionDir,fileName));
    currFieldName = ['RegionNum_' num2str(region)];
    parVels.(currFieldName) = filteredTable.('Vpar');
  
end   
%% Extract Amount of Data in Each Region
numDataDist = zeros(1,numRegions);
for region = 1:numRegions
    currFieldName = ['RegionNum_' num2str(region)];
    numDataDist(1,region) = length(parVels.(currFieldName));
end
%% Extract Avg Velocities From ParVels Structure (To Compare with Peaks of Distributions)
    avgVels = zeros(1,numRegions);
    avgV_Error= avgVels;
    for region = 1:numRegions
        currFieldName = ['RegionNum_' num2str(region)];
        currParVels = parVels.(currFieldName);
        avgVels(region) = mean(currParVels);
        avgV_Error(region) = sqrt((1/(length(currParVels)-1))*sum((currParVels-avgVels(region)).^2));
        avgV_Error(region) = avgV_Error(region)/sqrt(numDataDist(region));
    end
    scale = diff(avgVels);
    avgScale = mean(scale);
    figure(1);
    errorbar(regionMidPts,avgVels,avgV_Error);
    title('Average Velocity versus Region Separation Distance'); 

%% Apply horizontal scaling factor correction to parVels Structure
% for region = 1:numRegions
%    currFieldName = ['RegionNum_' num2str(region)];
%    parVels.(currFieldName) = parVels.(currFieldName) + (avgScale * region);
% end
%% Extract vertical scaling factor correction to parVels Structure
% crude vertical scaling where scaling factor is based on number of
% velocities in distribution
verScaleFactor = zeros(numRegions,1);
for region = 1:numRegions
    currFieldName = ['RegionNum_' num2str(region)];
    verScaleFactor(region,1) = length(parVels.(currFieldName));
end
%% Plot Relative Velocity Distributions for Each Region
plotOpt = 1;
%^determines whether gaussian fit will be plotted; 0: no gaussian fit, 1:gaussian fit
numBins = 50;

<<<<<<< HEAD
%Determine Number of data sets for each bin
numDataBin = zeros(numBins-1,numRegions); 
peaks = zeros(1,numRegions);
peakError = peaks;
=======
<<<<<<< HEAD
%creating array to determine num data points for each distribution and each
%bin within that distribution
numDataPerDist = zeros(1,numRegions);
numDataPerBin = zeros(numBins-1,numRegions);

%create array that stores peaks of each distribution
peaks = zeros(1,numRegions);

%create bins for each region and plot distribution
=======
%Determine Number of data sets for each region and bin
numDataDist = zeros(1,numRegions);
numDataBin = zeros(numBins-1,numRegions); 
peaks = zeros(1,numRegions);
>>>>>>> aada226005e7b77b1cd6c4c18c7a56b64f882119
>>>>>>> fa76f408a4cf5ecd71eab27f675946ab7b2dbb1d
for region = 1:numRegions
    currFieldName = ['RegionNum_' num2str(region)];
    edges = linspace(-2,2,numBins);
    N = histcounts(parVels.(currFieldName),edges);
    
    N_scaled = N/verScaleFactor(region,1);
    
    figure(region);
<<<<<<< HEAD
    if plotOpt == 1 %single gaussian distribution
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss1');
        plot(f,'r',mean([edges(1:end-1);edges(2:end)]),N_scaled);
        peaks(1,region) = f.b1;
    elseif plotOpt == 2 %double gaussian distribution
=======
    if plotOpt == 1
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss1');
        plot(f,'r',mean([edges(1:end-1);edges(2:end)]),N_scaled);
        peaks(1,region) = f.b1;
        peakError(1,region) = f.c1;
        xlim([-2,2]);
    elseif plotOpt == 2
>>>>>>> aada226005e7b77b1cd6c4c18c7a56b64f882119
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss2');
        plot(f,'r',mean([edges(1:end-1);edges(2:end)]),N_scaled);
        
    elseif plotOpt == 0 % scatter plot
        scatter(mean([edges(1:end-1);edges(2:end)]),N_scaled,'filled');
    end
    
    
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
    title([num2str(lowerBound) ' to ' num2str(upperBound) ' microns']);
    
<<<<<<< HEAD
    
    numDataBin(:,region) = N';
    peakError(1,region) = peakError(1,region)/sqrt(numDataDist(1,region));
=======
<<<<<<< HEAD
    numDataPerDist(1,region) = length(parVels.(currFieldName));
    numDataPerBin(1:numBins-1,region) = N';
=======
    numDataDist(1,region) = length(parVels.(currFieldName));
    numDataBin(:,region) = N';
>>>>>>> aada226005e7b77b1cd6c4c18c7a56b64f882119
>>>>>>> fa76f408a4cf5ecd71eab27f675946ab7b2dbb1d
end    
%     histogram(parVels,linspace(-outerBinEdge,outerBinEdge,numBins));    
    figure(region+1);
    errorbar(regionMidPts,avgVels,avgV_Error);
    title('Average Velocity versus Region Separation Distance');    
%% Overlay all distributions 
numBins = 50;
figure(region+2);
hold on;
legendNames = cell(1,numRegions);
for region = 1:numRegions
    currFieldName = ['RegionNum_' num2str(region)];
    edges = linspace(-1,1,numBins);
    N = histcounts(parVels.(currFieldName),edges);
    
    N_scaled = N/verScaleFactor(region,1);
    
    
%     if ((region == 1) || (region == numRegions))
    color = [1-(region-1)/numRegions,(region-1)/numRegions,(region-1)/numRegions];
    scatter(mean([edges(1:end-1);edges(2:end)]),N_scaled,'filled','MarkerFaceColor',color);
%     end
    
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
    
    str = [num2str(lowerBound), ' to ',num2str(upperBound),' microns'];
    legendNames{region} = join(str);
end
    title('Overlayed Parallel Velocity Distributions');
    legend(legendNames);

hold off;
%% Overlay Gaussian Fits
plotOpt = 1;
numBins = 50;
plotOpt = 1;
figure(region+3);
hold on;
legendNames = strings(1,numRegions);
for region = 1:numRegions
    %bin data based on parallel relative velocity
    currFieldName = ['RegionNum_' num2str(region)];
    edges = linspace(-1,1,numBins);
    N = histcounts(parVels.(currFieldName),edges);
    
    N_scaled = N/verScaleFactor(region,1);
    color = [1-(region-1)/numRegions,0,(region-1)/numRegions];
    
    %find gaussian fit
    if plotOpt == 1
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss1');
    elseif plotOpt == 2
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss2');
    end
    p = plot(f,mean([edges(1:end-1);edges(2:end)]),N_scaled);
    
    %delete scatter data to see gaussian distributions more clearly
    delete(p(1,1));
    
    %create legend names for each distribution
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
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
<<<<<<< HEAD
%% Plotting Peaks for Each Region
hold on
figure(region + 4)
scatter(regionMidPts,peaks);
title('Distribution Peaks for Each Region');
hold off
=======
%% Plot Peaks for Each Distribution
figure(region + 4)
hold on 
errorbar(regionMidPts,peaks,peakError,'.');
title('Peak of Each Distribution');
<<<<<<< HEAD
xlabel('Parallel Separation Distance (um)');
ylabel('Peak Value of Par Vel Distributions(um/s)');
fit = polyfit(regionMidPts,peaks,1);
plot(regionMidPts,(fit(1,1)*regionMidPts + fit(1,2)));
hold off
=======
hold off
>>>>>>> aada226005e7b77b1cd6c4c18c7a56b64f882119
>>>>>>> fa76f408a4cf5ecd71eab27f675946ab7b2dbb1d
