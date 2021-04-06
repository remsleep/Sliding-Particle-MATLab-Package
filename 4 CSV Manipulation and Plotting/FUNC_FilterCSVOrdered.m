function [] = FUNC_FilterCSVOrdered(ogDir,outDir,ogName,outName,fields,limVals,storeMode)
%FUNC_FILTERCSVINCL This function takes in the directory OGDIR of a currently
%existing .csv file, fields labeled in the top row, and creates a new .csv
%in the desired OUTDIR after filtering. The program takes in a 1xN cell array
%FIELDS and an accompanying Nx2 array LIMVALS which contains the bounding
%values of each corresponding field. 
%For example, if LIMVALS(3,:) = [4,62], then the function will generate a
%filtered list of data including only the rows whose value of the 3rd field
%stored in FIELDS is more than 4 and less than 62. 
%OGNAME and OUTNAME are the names of the original and new/output .csv
%files, respectively.
%STOREMODE is a boolean value for which 0 indicates data inclusion and 1
%indicates data exclusion
%Note: OGDIR, OUTDIR, OGNAME, and OUTNAME are all strings
%Note: The order of LIMVALS is important! The function will always look for
%values greater than LIMVALS(:,1) and smaller than LIMVALS(:,2)

%Check if ogName and outName end in '.csv'
ogName  = checkAppendCSV(ogName);
outName = checkAppendCSV(outName);

%Define full addresses of original and output data
dataLoc = fullfile(ogDir,ogName);
outLoc = fullfile(outDir,outName);
%Check to see if the user is overwriting the ogData (dataLoc=outLoc)
if strcmp(dataLoc,outLoc)
   %Copy the original data to a temporary file and update address of og. data
   tempDataLoc = fullfile(ogDir,['temp_',ogName]);
   movefile(dataLoc,tempDataLoc);
   dataLoc = tempDataLoc;
end

%Initialize the original .csv reader object
dataStore = datastore(dataLoc);
allFieldNames = dataStore.VariableNames;
fileHeads = cell2table(cell(0,numel(allFieldNames)),'VariableNames',allFieldNames);

%Create your output directory and generate the new .csv output
if ~exist(outDir, 'dir')
    mkdir(outDir); 
end
fileID= fopen(outLoc, 'w');
writetable(fileHeads, outLoc);
fclose(fileID);

%Set a variable to store data until periodically saved
toSaveData = []; cycleNum = 0;
%Iterate through all data in the .csv
while hasdata(dataStore)
   
    cycleNum = cycleNum + 1;
    %Read newest newest batch of data
    currTempData = read(dataStore);
    
    %Iterate through all fields passed to the function
    for currField = 1:numel(fields)
       %Logic matrix filtering values based on LIMVAL and STOREMODE
       keepInds = logical( (currTempData.(fields{currField}) >= limVals(currField,1)) ...
           .* (currTempData.(fields{currField}) <= limVals(currField,2)) );
        if storeMode == 1
           keepInds = ~keepInds;
        end
        %Filter data
        currTempData = currTempData(keepInds,:);
    end
    
    %Save data to outData every 100 cycles
    toSaveData = [toSaveData; currTempData];
    if mod(cycleNum,10) == 0
        dlmwrite(outLoc,table2array(toSaveData),'-append');
        toSaveData = [];
    end
    
end

%Save remaining data
if ~isempty(toSaveData)
    dlmwrite(outLoc,table2array(toSaveData),'-append');
    toSaveData = [];
end

%Clean up by deleting any temp files
dataLoc = fullfile(ogDir,ogName);
if strcmp(dataLoc, outLoc)
    delete(tempDataLoc);
end

% Add a delay to prevent thread hiccups
fclose('all')

end

%% Additional Functions
function [fileName] = checkAppendCSV(fileName)
%This simple function checks to see if the inputted FILENAME ends in '.csv'
%and appends '.csv' if it does not
if (length(fileName) > 4)
   if ~contains(fileName((end-3):end),'.csv') 
       fileName = [fileName '.csv'];
   end
else
    fileName = [fileName '.csv'];
end

end