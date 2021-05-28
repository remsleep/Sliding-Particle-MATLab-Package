function [fileName] = FUNC_checkAppendGeneral(fileName,fileEnd)
%This simple function checks to see if the inputted FILENAME ends with the
%inputted FILEEND; if not, the file returns a new file name ending with the
%desired FILEND. FILEEND and FILENAME must and will both be strings

if nargin == 2
    endLength = numel(fileEnd);
    if (length(fileName) > endLength)
       if ~contains(fileName((end-endLength+1):end),fileEnd) 
           fileName = [fileName fileEnd];
       end
    else
        fileName = [fileName fileEnd];
    end
end

end
