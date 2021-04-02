function [ds] = FUNC_Array2CSVSpecific(directory,analysisDir,csvName,rawdata)
%FUNC_ARRAY2CSV Converts an array containing
% [R_Separation; RelativeAngle; AngleDifference; RelParVel; RelPerpVel; T]
% for microtubule pairs and saves them in a CSV. This is NOT a generalized
% function.

%Prepare a variable on the disk to save to periodically to speed things up
%and prevent memory issues. This will be a datastore.
%make new directory for saving data.  This will be a datastore for analysis.
analysisdir=fullfile(directory,analysisDir);   mkdir(analysisdir);
savename=strcat(analysisdir,'\',csvName,'.csv');


%Write the File Headers to the csv file.
fileID= fopen(savename, 'w');
%Output this:  [Rsep RelAngle DeltaA DeltaS DeltaVx DeltaVy Vpara Vperp];
fprintf(fileID,'%12s, %12s, %12s, %12s, %12s, %12s \n',...
    'Rsep', 'RelAngle', 'DeltaA', 'Vx', 'Vy','time');
fclose(fileID);


dlmwrite(savename,rawdata,'-append');

clc;

ds=datastore(savename);

end

