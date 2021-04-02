function [meanVals,stdDevs,numElmts] = FUNC_GetMeanValCSV(dataDir, CSVName, fieldNames)
%FUNC_GETMEANVALCSV Takes in a directory DATADIR, the name of .csv file
%CSVNAME containing data, and a cell array of fields stored in that
%.csv FIELDNAMES. The function then returns the mean values, standard
%deviations, and number of elements stored in the .csv of the desired
%properties.

%Check if the .csv name ends in '.csv'
CSVName  = FUNC_checkAppendCSV(CSVName);

%Define full addresses of original and output data
dataLoc = fullfile(dataDir,CSVName);

%Initialize the original .csv reader object
dataStore = datastore(dataLoc);

%Initialize storage and outputs
allData = [];

%Iterate through all data in the .csv
while hasdata(dataStore)
   
    %Read newest newest batch of data
    currTempData = read(dataStore);
    newData = zeros( size(currTempData,1), numel(fieldNames) );
    
    %Iterate through all fields passed to the function
    for currField = 1:numel(fieldNames)
        
        try 
            newData(:,currField) = currTempData.(fieldNames{currField});
        catch errorMsg
            if (strcmp(errorMsg.identifier, 'MATLAB:table:UnrecognizedVarName'))
                newData(:,currField) = NaN;
            end
        end
        
    end
    
    %Append new data
    allData = [allData; newData];
    
end

%Calculate mean, standard deviation, count number of elements
meanVals = mean(allData);
stdDevs = std(allData);
numElmts = size(allData,1);

end

