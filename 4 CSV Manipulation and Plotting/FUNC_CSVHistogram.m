function [sumN,edges,outlierNum] = FUNC_CSVHistogram(dataDir,fieldName,edges)
%FUNC_CSVHISTOGRAM takes in the directory DATADIR of a csv containing
%the desired data, as well as the field name FIELDNAME of the desired data,
%returning a histogram of the data stored in the column of data
%associated with field name. EDGES determines the edges of the bins to be
%counted over and can be set by the user or is defined by the function, if
%left undefined.
%Note: FIELDNAME must be a string and DATADIR must be a string ending in
%<the desired filename>.csv

%% Begin function
%Initialize the datastore affiliated with the csv and the number of 
%unbinned elements
dataStore = datastore(dataDir);
outlierNum = 0;

%Check to see if custom edges have been passed to the function or not
    %Case if edges are left undefined: defines edges using histcounts
    %Extra edges are added if outlier data are located in later instances
    %of dataread
if nargin == 2
    %Load data
    currData = read(dataStore);
    currFieldVals = currData.(fieldName);
    %Define first set of edges using histcounts
    [sumN, edges] = histcounts(currFieldVals);
    binWidth = max(diff(edges)); maxBin = max(edges); minBin = min(edges);
    %Iterate through the entire csv file
    while hasdata(dataStore)
        %Load data
        currData = read(dataStore);
        currFieldVals = currData.(fieldName);
        %Search for outlier data and update edges if necessary
        if ( max(currFieldVals) > maxBin || min(currFieldVals) < minBin )
            [edges,isNewMat] = updateEdges(currFieldVals, edges, binWidth);
            %Check to see if edges upperbound was raised -> get index of
            %last old entry before updating sumN
            if max(currFieldVals) > maxBin
                old2New = find(diff(isNewMat) == -1);
            else
                old2New = numel(isNewMat);
            end
            updatedN = zeros(1,numel(isNewMat(2:end)));
            updatedN(isNewMat(1:old2New-1)) = sumN;
        else
            updatedN = sumN;
        end
        %Find distribution of data located in this collection of edges
        [currN, edges] = histcounts(currFieldVals, edges);
        sumN = updatedN + currN;
        %Count number of unbinned data and add tally to outlierNum
        outlierNum = outlierNum + (numel(currFieldVals) - sum(currN));
%         if outlierNum + (numel(currFieldVals) - sum(currN)) ~= 0
%         end
    end
%See Line 10: Check to see if custom edges have been passed or not
    %Bin all data within desired edges and count number of outliers
elseif nargin == 3
    sumN = [];
    edges = sort(edges);
    %Iterate through the entire csv file
    while hasdata(dataStore)
        %Load data
        currData = read(dataStore);
        currFieldVals = currData.(fieldName);
        %Find distribution of data located in this collection of edges
        [currN, ~] = histcounts(currFieldVals, edges);
        %Add to the previous distributions
        if isempty(sumN)
            sumN = currN;
        else
            sumN = sumN + currN;
        end
        %Count number of unbinned data and add tally to outlierNum
        outlierNum = outlierNum + (numel(currFieldVals) - sum(currN));
    end
end
   
end

%% Additional Functions
function [newEdges,isNew] = updateEdges(currFieldVals, edges, binWidth)
%UPDATEEDGES takes in field values CURRFIELDVALS, histogram edges EDGES,
%and the maximum bin width BINWIDTH of said edges and returns new histogram
%edges with the same binWidth capable of encompassing all current data

%Define boundary values
maxVal = max(currFieldVals); minVal = min(currFieldVals);
maxBin = max(edges);         minBin = min(edges);
%Determine number of edges to add at upper and lower bounds
lowEdgeNum = floor( (minVal - minBin)/binWidth );
upEdgeNum  =  ceil( (maxVal - maxBin)/binWidth );
%Add edges and return
newEdges = [ ((minBin - binWidth*lowEdgeNum):binWidth:minBin - binWidth), ...
    edges, (maxBin + binWidth:binWidth:(maxBin + binWidth*upEdgeNum)) ];
%Define logical matrix indicating which edges are new and old
isNew = ismember(newEdges,edges);

end
