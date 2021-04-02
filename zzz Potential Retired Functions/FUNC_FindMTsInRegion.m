%%this function takes in data about microtubules and the dimensions of a
%%region and outputs the percentage of total MTs in that region as well as
%%velocity and sep dist info about MTs in the region.
function [percentMTs,MTParVels,MTPerpVels,MTDistances,MTCoords] = ...
    FUNC_FindMTsInRegion(regionDimensions,QuadrantOption,MTPairInfo)
    
    XLow = regionDimensions(1,1);
    XHigh = regionDimensions(1,2);
    YLow = regionDimensions(1,3);
    YHigh = regionDimensions(1,4);
    
    Coords = MTPairInfo(4:5,:);
    
    if QuadrantOption == 1%%only looks at one quadrant
       
        indexMatX = (((Coords(1,:) >= XLow) + (Coords(1,:) <= XHigh)) == 2);
        indexMatY = (((Coords(2,:) >= YLow) + (Coords(2,:) <= YHigh)) == 2);
        indexMat = (indexMatX + indexMatY == 2);
   
    elseif QuadrantOption == 2%%looks at all four quadrants
       
        indexMatX = (((abs(Coords(1,:)) >= XLow) + (abs(Coords(1,:)) <= XHigh)) == 2);
        indexMatY = (((abs(Coords(2,:)) >= YLow) + (abs(Coords(2,:)) <= YHigh)) == 2);
        indexMat = (indexMatX + indexMatY == 2);
        
    end
    
    numMTsTotal = length(Coords(1,(indexMat)));
    MTParVels = MTPairInfo(1,(indexMat));
    MTPerpVels = MTPairInfo(2,(indexMat));
    MTDistances = MTPairInfo(3,(indexMat));
    MTCoords = MTPairInfo(3:4,(indexMat));
    
    percentMTs = (numMTsTotal/size(MTPairInfo,2)) * 100;
    
end

