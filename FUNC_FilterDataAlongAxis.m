function [] = FUNC_FilterDataAlongAxis(ogDir,outDir,ogName,outName,axisAng,tolerance,relAngName)
%FUNC_FILTERDATAALONGAXIS Takes in the directory OGDIR of a .csv file named
%OGNAME and constructs a new .csv file named OUTNAME in the directory
%OUTDIR such that all data within +-TOLERANCE along the desired axis,
%defined by AXISANG and named RELANGNAME as the "relative
%angle" field, is preserved. TOLERANCE and AXISANG are floats and are
%assumed to be in radians. RELANGNAME is a 1x1 cell array containing the 
%string name of the field with which the program will filter. If left 
%undefined by the user, the default of this field is "RelAngle"
%The default value of TOLERANCE, if left undefined by the user is 10 deg.
%The function uses the function FUNC_FilterCSVOmit to carve out the
%"unfit" data piece by piece and will leave all data within a the 

if nargin == 6
    relAngName = {'RelAngle'};
    disp('relative angle field set to RelAngle')
elseif nargin == 5
    relAngName = {'RelAngle'};
    tolerance = deg2rad(10);
    disp('relative angle field set to RelAngle and tolerance set to 10')
end

%Define four boundary angles
allAngles = mod( [axisAng - tolerance, axisAng + tolerance, ...
    axisAng - tolerance + pi, axisAng + tolerance + pi], 2*pi );
allAngles = sort(allAngles);

%Trim in two steps
FUNC_FilterCSVOmit(ogDir,outDir,ogName,outName,relAngName,[allAngles(1) allAngles(2)]);
FUNC_FilterCSVOmit(outDir,outDir,outName,outName,relAngName,allAngles(3:4));

end