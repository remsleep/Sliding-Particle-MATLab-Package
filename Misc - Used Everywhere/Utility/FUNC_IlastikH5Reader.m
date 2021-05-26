function Data = FUNC_IlastikH5Reader(FilePath,FileName, field)
%ILASTIKH5READER Takes in directory FilePath and file name FileName and
%reads the data from the corresponding h5 file

    Data = h5read(fullfile(FilePath,FileName),field);
    
end

