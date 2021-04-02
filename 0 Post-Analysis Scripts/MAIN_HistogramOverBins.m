%% Load .csv directory
binsDir = 'D:\Two Channel Nematic\Alex Two Color MT Data\Data Set 1\Combined\2020-11-18\10 Degree Filter\Parallel Axis\Parallel Separation Distance 5um Binnings';
edges = [-4:.1:4];

%% Get file names in directory
fileInfo = dir(binsDir);

%% Iterate through files and save histcount info (gauss1 fit)
fieldName = 'VRelpar';
fitMeans = zeros(size(fileInfo,1)-2,1);
fitVars = fitMeans;
numElmts = fitMeans;
fitStruct = struct();
allN = [];

%Iterate through all .csv files in the directory
for currBin = 3:size(fileInfo,1)
    index = currBin - 2;
    currFile = fileInfo(currBin).name;
    fullDir = fullfile(binsDir, currFile);
    if isempty(edges)
        [N,edges,outlierNum] = FUNC_CSVHistogram(fullDir,fieldName);
    else
        [N,edges,outlierNum] = FUNC_CSVHistogram(fullDir,fieldName,edges);
    end
    %Fit to a Gaussian
    edgeScatterVals = mean([edges(1:end-1);edges(2:end)]);
    currFit = fit(edgeScatterVals.', (N/sum(N)).','gauss1');
    %Get separation distance
    currBinInd = min(strfind(currFile, 'um'));      %Find the index where um is written in the file name
    currSep = str2double(makeNumber(currFile(1:currBinInd-1)));
    %Store everything
    allN = [allN; N];
    fitStruct(index).fit = currFit;
    fitStruct(index).sepVal = currSep;
    fitMeans(index) = currFit.b1;
    fitVars(index) = currFit.c1;
    numElmts(index) = sum(N);
end

%% Plot mean and std dev vs. separation 

%Load separations from structure and sort data
seps = [fitStruct.sepVal]';
[~,inds] = sort(seps);
combined = [seps, fitMeans, fitVars];
sortComb = combined(inds,:);

%Plot mean values vs. sep
figure
errorbar(seps, fitMeans, fitVars./sqrt(numElmts),'o')
set(gca,'FontSize',15);
xlim([min(seps) - .2, max(seps) + .2]);
title('Average Parallel Velocity vs. Parallel Separation')
xlabel('Separation Distance (um)')
ylabel('Average Velocity (um/s)')

figure
scatter(seps, fitVars, 'filled')
set(gca,'FontSize',15);
xlim([min(seps) - .2, max(seps) + .2]);
title('Std. Dev. Parallel Velocity vs. Parallel Separation')
xlabel('Separation Distance (um)')
ylabel('Std. Dev. Velocity (um/s)')

%% Plot Gaussians (overlay)
%Sort data
seps = [fitStruct.sepVal]';
[~,inds] = sort(seps);

figure
hold on
for index = inds'
%     index
%     if (mod(index-1,2) == 0)
    if index == 6
        if (sum(allN(index,:))>800)
            index
            plotColor = [ (max(inds)-index)/max(inds) .6 index/max(inds) ];
            scatter(edgeScatterVals, allN(index,:)/sum(allN(index,:)),50,plotColor,'filled')
            tempHandle = plot(fitStruct(index).fit);
            tempHandle.Color = plotColor; tempHandle.LineWidth = 3*(max(inds)-index+10)/max(inds);
        end
    end
end
set(gca,'FontSize',15);
xlabel('Velocity (um/s)')
ylabel('Fraction of data')
title('Velocity distributions over varying parallel separation')

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

