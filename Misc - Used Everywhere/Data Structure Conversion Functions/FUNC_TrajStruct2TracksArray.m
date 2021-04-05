function [tracks, fieldNames] = FUNC_TrajStruct2TracksArray(TRAJECTORY, desiredFields)
%FUNC_TRAJS2TRACKSMAT Takes in a TRAJECTORY structure containing DESFIELDS
% as fields and returns a 5xN array containing        
% [x, y, timestamp, orientation, ID] called TRACKS. If DESFIELDS is not
% passed by the user, DESFIELDS by default will be of the form 
% {'X','Y','FRAME','ORIENT','OBJECT_NUMBER'}
% FIELDNAMES is a cell array indicating the contents of each row in TRACKS

if nargin == 1
    % Define a template of desired field names to look for
    desiredFields = {'X','Y','FRAME','ORIENT','OBJECT_NUMBER'};
end

% Get fields of TRAJECTORY with OBJECT_NUMBER (object ID)
[convArray, fields] = FUNC_Structure2Array(TRAJECTORY);
tracksLen = numel([TRAJECTORY.(fields{1})]);

% Instantiate tracks object
tracks = zeros(numel(desiredFields), tracksLen);
fieldNames = cell(numel(desiredFields),1);

% Iterate through desired fields and check that TRAJECTORY contains them
for currField = 1:numel(desiredFields)
   
    fieldName = cell2mat(desiredFields(currField));
    
    % Check that field exists in TRAJECTORY, then assign row data
    if numel(find(contains(fields,fieldName))) == 0
        currContent = zeros(1, tracksLen);
    else
        fieldInds = (contains(fields,fieldName));
        currContent = convArray(fieldInds,:);
    end
    
    % Store name of transferred field
    fieldNames{currField} = fieldName;
    
    % Store contents of current field in tracks matrix
    tracks(currField,:) = currContent;
    
end

end

