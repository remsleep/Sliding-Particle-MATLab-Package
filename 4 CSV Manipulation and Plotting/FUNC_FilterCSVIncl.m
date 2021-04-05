function [] = FUNC_FilterCSVIncl(ogDir,outDir,ogName,outName,fields,limVals)
%FUNC_FILTERCSVINCL This function takes in the directory OGDIR of a currently
%existing .csv file, fields labeled in the top row, and creates a new .csv
%in the desired OUTDIR after filtering. The program takes in a 1xN cell array
%FIELDS and an accompanying Nx2 array LIMVALS which contains the bounding
%values of each corresponding field. 
%For example, if LIMVALS(3,:) = [4,62], then the function will generate a
%filtered list of data including only the rows whose value of the 3rd field
%stored in FIELDS is bounded by 4 and 62. To cut out data bound in this
%opening, one must use FUNC_FilterCSVOmit or FUNC_FilterCSVOrdered
%OGNAME and OUTNAME are the names of the original and new/output .csv
%files, respectively.
%Note: OGDIR, OUTDIR, OGNAME, and OUTNAME are all strings

%The function has been updated to call on FUNC_FilterCSVOrdered as it is
%the more general function

limVals = sort(limVals);
FUNC_FilterCSVOrdered(ogDir,outDir,ogName,outName,fields,limVals,0);

end