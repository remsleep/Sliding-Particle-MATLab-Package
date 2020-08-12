function [ARRAY, FIELDS] = FUNC_Structure2Array(STRUCTURE)
%FUNC_TRAJECTORYSTRUCTURE2ARRAY takes in a STRUCTURE and turns it into an
%array with all fields containing equal numbers of constituents for a given
%subelement. The fields of these structures must contain only numbers. 
tic
%Get cell array of all fields
FIELDS = fieldnames(STRUCTURE);

%Get number of elements to be stored
tempField = cell2mat(FIELDS(1));
counter = numel([STRUCTURE.(tempField)]);

%Initialize array
ARRAY = zeros(numel(FIELDS)+1, counter);
counter = 1;                            %Reset counter

%Iterate through STRUCTURE elements and store field values
for index = 1:numel(STRUCTURE)
    
    endCounter = counter+numel(STRUCTURE(index).(tempField))-1;
    
    %Label the object
    ARRAY(end, counter:endCounter) = index;
    
    %Update counter
    counter = endCounter+1;
end

    %Iterate through each field
    for fieldIndex = 1:numel(FIELDS)
        
        tempField = cell2mat(FIELDS(fieldIndex));
        if ( size(STRUCTURE(1).(tempField),1) > size(STRUCTURE(1).(tempField),2) )
            ARRAY(fieldIndex, :) = vertcat(STRUCTURE.(tempField))';
        else
            ARRAY(fieldIndex, :) = [STRUCTURE.(tempField)];
        end
        
    end 

%Add OBJECT_NUMBER field to indicate what last row in ARRAY is
FIELDS(end+1) = {'OBJECT_NUMBER'};
toc
end

