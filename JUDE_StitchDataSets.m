<<<<<<< HEAD
function [] = JUDE_StitchDataSets(savename, setname)
%This function concatenates two relative velocity data sets togethers so we
%can analyze them as one batch
%   Detailed explanation goes here
    setVelArray = table2array(readtable(setname));
    dlmwrite(savename,setVelArray,'-append');
=======
function [] = JUDE_StitchDataSets(saveName,dataName)
%Stitches together data sets so that they can all be analyzed and filtered
%through as one
    dataArray = table2array(readtable(dataName));
    dlmwrite(saveName,dataArray,'-append');
>>>>>>> aada226005e7b77b1cd6c4c18c7a56b64f882119
end

