%This script concatenates velInfo Data sets so that data from multiple
%experiments can be analyzed together

savename = 'C:\Users\judem\Documents\SlidingMTData\CombinedData.csv';
concatenateDir = 'C:\Users\judem\Documents\SlidingMTData';
concatenateName = 'CombinedData';
concatenateFile = fullfile(concatenateDir,[concatenateName '.csv']);

concatenateArray = table2array(readtable(fullfile(concatenateDir,concatenateName)));

dlmwrite(savename,concatenateArray,'-append');
