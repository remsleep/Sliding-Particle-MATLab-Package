function [xDim,yDim] = FUNC_getImgDims(directory, imgType)
%FUNC_GETIMGDIMS Takes in a DIRECTORY and IMGTYPE, both strings indicating
%the directory and image type being earched for in said directory, and
%returns the x and y dimensions of the FIRST image of the requested type in
%the directory.

%Get files info
FILES = dir([directory '\*.' imgType]);

IMAGE = imread(fullfile(directory, FILES(1).name));
xDim = size(IMAGE,1);
yDim = size(IMAGE,2);

end

