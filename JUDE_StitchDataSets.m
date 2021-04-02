function [] = JUDE_StitchDataSets(savename, setname)
%This function concatenates two relative velocity data sets togethers so we
%can analyze them as one batch
%   Detailed explanation goes here
    setVelArray = table2array(readtable(setname));
    dlmwrite(savename,setVelArray,'-append');
end

