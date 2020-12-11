%% Define Location of CSV File
csvName = 'CombinedData';
combinedDir = 'C:\Users\Jude\Documents\SlidingMTData';
dataLoc = fullfile(combinedDir,csvName);
%% Switch Velocity 
%signs so positive velocity corresponds to contractile motion while 
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
    {'ParSep'},[-regionWidth,regionWidth]);
%% Define region analysis parameters
numRegions = 10;
regionInterval = 0.2;%in microns
regionDir = fullfile(combinedDir,'RegionComparison');
mkdir(regionDir);
%% Create 2 dimensional parVels structure where fields are regions 
parVels = struct();

for region = 1:numRegions
    %creating bounds for region
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;

    
    fileName = [filtCSVName '_' num2str(region)];
    FUNC_FilterCSVIncl(combinedDir,regionDir,filtCSVName,fileName,{'PerpSep'},[-upperBound,upperBound]);
    FUNC_FilterCSVOmit(regionDir,regionDir,fileName,fileName,{'PerpSep'},[-lowerBound,lowerBound]);

    
    filteredTable = readtable(fullfile(regionDir,fileName));
    currFieldName = ['RegionNum_' num2str(region)];
    parVels.(currFieldName) = filteredTable.('Vpar');
  
end   

%% Use mean parallel relative velocity from each region to find horizontal scaling factor
avgVels = zeros(1,10);
RMSD = avgVels;%for error bars
regionMidPts = RMSD;
for region = 1:numRegions
    currFieldName = ['RegionNum_' num2str(region)];
    currParVels = parVels.(currFieldName);
    avgVels(region) = mean(currParVels);
    RMSD(region) = sqrt((1/(length(currParVels)-1))*sum((currParVels-avgVels(region)).^2));
    regionMidPts(region) = (((region-1)*(regionInterval))+(region*regionInterval))/2;
end
    scale = diff(avgVels);
    avgScale = mean(scale);
    figure(1);
    errorbar(regionMidPts,avgVels,RMSD);
    title('Average Velocity versus Region Separation Distance'); 
%% Apply horizontal scaling factor correction to parVels Structure
for region = 1:numRegions
   currFieldName = ['RegionNum_' num2str(region)];
   parVels.(currFieldName) = parVels.(currFieldName) + (avgScale * region);
end
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
for region = 1:numRegions
    currFieldName = ['RegionNum_' num2str(region)];
    edges = linspace(-1,1,numBins);
    N = histcounts(parVels.(currFieldName),edges);
    
    N_scaled = N/verScaleFactor(region,1);
    
    figure(region);
    
    if plotOpt == 1
        f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss2');
        plot(f,'r',mean([edges(1:end-1);edges(2:end)]),N_scaled);
    elseif plotOpt == 0
        scatter(mean([edges(1:end-1);edges(2:end)]),N_scaled,'filled');
    end
    
    
    lowerBound = (region-1)*regionInterval;
    upperBound = region*regionInterval;
    title([num2str(lowerBound) ' to ' num2str(upperBound) ' microns']);
    
end    
%     histogram(parVels,linspace(-outerBinEdge,outerBinEdge,numBins));    
    figure(region+1);
    errorbar(regionMidPts,avgVels,RMSD);
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
numBins = 50;
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
    f = fit(mean([edges(1:end-1);edges(2:end)])',N_scaled','gauss2');
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
    set(fitLine,'DisplayName',str,'Color',color);
   
end
    title('Overlayed Parallel Velocity Gaussian Fits');
    xlabel('parallel relative velocity (um/s)');
    ylabel('normalized frequency');

hold off;