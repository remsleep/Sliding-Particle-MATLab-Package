function [] = JUDE_SwitchVelocitySign(ogDir,outDir,ogName,outName)
    %%We wish to define a positive relative velocity for pairs that are
    %%moving away from each other (extensile) while pairs moving towards
    %%each other (contractile) have a negative relative velocity.
    %%Currently, the sign of the velocities are based on whether the
    %%microtubule in the pair is moving up or down on either the parallel or
    %%perpendicular axis. This function switches the signs of velocities
    %%that are positive for microtubules that have negative parallel or
    %%perp coordinates relative to their MT partner. This ensures that
    %%extensile pairs have positive relative velocities while contractile
    %%pairs have negative relative velocities.
    
    %Check if ogName and outName end in '.csv'
    ogName  = checkAppendCSV(ogName);
    outName = checkAppendCSV(outName);
    
    %Define full addresses of original and output data
    dataLoc = fullfile(ogDir,ogName);
    outLoc = fullfile(outDir,outName);
    
    %Extract Data from csv file
    dataTable = readtable(dataLoc);
    
    parVelInfo = dataTable.Vpar;
    perpVelInfo = dataTable.Vperp;
    
    parSepInfo = dataTable.ParSep;
    perpSepInfo = dataTable.PerpSep;
    
    %Create Index Matrices to choose which entries to multiply by -1
    %first looking at parallel direction
    parIndexMat = (parSepInfo < 0);
    parVelInfo(parIndexMat) = -parVelInfo(parIndexMat);
    
    %perp direction
    perpIndexMat = (perpSepInfo < 0);
    perpVelInfo(perpIndexMat) = -perpVelInfo(perpIndexMat);
    
    %update columns in table
    dataTable.Vpar = parVelInfo;
    dataTable.Vperp = perpVelInfo;
    
    writetable(dataTable,outLoc);
end
%%aditional function
function [fileName] = checkAppendCSV(fileName)
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