function [] = FUNC_renameCSVFields(dataDir,csvName,ogFields,newFields)
%FUNC_RENAMECSVFIELDS Takes in the directory DATADIR and name of .csv file
%CSVNAME to access. The script then searches for variables (column titles)
%contained in OGFIELDS, a cell array containing strings, and replaces them
%1 to 1 with the contents of NEWFIELDS, another cell array containing
%strings. OGFIELDS and NEWFIELDS must be of the same length and will be
%replaced in the order they are presented in. Data is stored in new .csv

%% Initiatilization

% Get original all original csv field names
csvName = FUNC_checkAppendCSV(csvName);
ds = datastore(fullfile(dataDir, csvName));
fields = ds.SelectedVariableNames;
allNewVariables = fields;


% Iterate through all pre-existing fields, search for fields in ogFields,
% and replace with fields in newFields
for fieldInd = 1:numel(ogFields)
    
    currField = ogFields{fieldInd};
    if logical(sum(contains(ds.SelectedVariableNames,currField)))
        repInd = contains(ds.SelectedVariableNames, currField);
        allNewVariables{repInd} = newFields{fieldInd};
    end
end

%Prepare a copies .csv called csvName_copy
outName = FUNC_checkAppendCSV([csvName(1:end-4) '_copy']);
saveLoc=fullfile(dataDir, outName);

%Write the File Headers to the csv file.
fileID= fopen(saveLoc, 'w');

% Iterate through new variables cell array and add new headers
for fieldInd = 1:numel(allNewVariables)-1
    
    fprintf(fileID, '%12s,', allNewVariables{fieldInd});
    
end
fprintf(fileID, '%12s \n', allNewVariables{end});

% Clean up
fclose(fileID);

%Iterate through datastore and copy all old data to new file
h = waitbar(0,'Binning Rod Data');  %initiate waitbar.
DatastoreInfo = dir(saveLoc);
while hasdata(ds)

    [data ,info]= read(ds);
    waitbar(info.Offset/DatastoreInfo.bytes,h);  %PROGRESS BAR INFO. 
    writetable(data,saveLoc, "WriteMode","Append");       % For ML 2020 and later
%     writetable(data,saveLoc);
    
end

close(h)
end

