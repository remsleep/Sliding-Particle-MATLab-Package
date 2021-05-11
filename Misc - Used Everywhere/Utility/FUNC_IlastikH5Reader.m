function Data = FUNC_IlastikH5Reader(FilePath,FileName, field)
%ILASTIKH5READER Takes in directory FilePath and file name FileName and
%reads the data from the corresponding h5 file
%   Detailed explanation goes here


currDir = pwd;

cd(FilePath);
pause (.1) 
NumFiles = 1:10;
pxl = 0.3788; %0.3551 for 48; 0.3788 for 36hrs
% cd(currDir)
% for OrgPos = 1:length(NumFiles)
    Data = h5read(sprintf(FileName),field);
end

