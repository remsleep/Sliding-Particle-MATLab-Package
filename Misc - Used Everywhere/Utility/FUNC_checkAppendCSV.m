function [fileName] = FUNC_checkAppendCSV(fileName)
%This simple function checks to see if the inputted FILENAME ends in '.csv'
%and appends '.csv' if it does not
if (length(fileName) > 4)
   if ~contains(fileName((end-3):end),'.csv') 
       fileName = [fileName '.csv'];
   end
else
    fileName = [fileName '.csv'];
end

end
