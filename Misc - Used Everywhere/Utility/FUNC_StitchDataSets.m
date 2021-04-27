function [] = FUNC_StitchDataSets(saveName,dataName)
%Stitches together data sets so that they can all be analyzed and filtered
%through as one
    dataArray = table2array(readtable(dataName));
    dlmwrite(saveName,dataArray,'-append');
end