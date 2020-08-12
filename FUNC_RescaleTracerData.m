function [allMTData] = FUNC_RescaleTracerData(allMTData, pixelConv)
%FUNC_RESCALETRACERDATA takes in ALLMTDATA, a 5xN array containing frame,
%length, orientation, and x-y coordinates of N objects, and PIXELCONV, a
%scalar indicating the conversion of microns per pixel in the selected
%frames. 

allMTData(4:5,:) = allMTData(4:5,:)*pixelConv;
allMTData(2,:) = allMTData(2,:)*pixelConv;

end

