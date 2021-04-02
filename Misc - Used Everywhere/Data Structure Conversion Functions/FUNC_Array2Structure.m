function [STRUCTURE] = FUNC_Array2Structure(ARRAY, FIELDS)
%FUNC_ARRAY2STRUCTURE takes in an ARRAY and returns a structure
%with the contents of each row stored as a field. The first  row of
%the array must be positive definite integers and serve as the ID of the
%contents in the array; i.e. information is stored in the structure based
%on the identification number in the ID row. FIELDS is a cell array of
%each corresponding field name; i.e. the second row of the array will be
%stored in the field name stored in the second entry of the cell array.
tic
%Initialize Structure
STRUCTURE = struct();

%Iterate through ID number
for currID = 1:max(ARRAY(1,:))
    
    %Identify relevant column coordinates of all objects with the current ID
    IDIndices = (ARRAY(1,:) == currID);
    
    %Iterate through FIELDS
    for fieldIndex = 1:numel(FIELDS)
       
        tempField = cell2mat(FIELDS(fieldIndex));
        STRUCTURE(currID).(tempField) = ARRAY(fieldIndex,IDIndices);
        
    end
    
end

toc
end

