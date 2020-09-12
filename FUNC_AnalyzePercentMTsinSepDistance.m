function [MTPercents,AvgParVel,AvgPerpVel,regionBounds] = ...
    FUNC_AnalyzePercentMTsinSepDistance(windowWidth,MTPairInfo,MaxSep,numRegions,axis)
    %%this functions finds the percent of all MTs that are within a region

    %%creating regions that program will run through
    regionBounds = linspace(0,MaxSep,numRegions);
    
    %%initializing output arrays
    MTPercents = zeros(1,size(regionBounds,2));
    AvgParVel = MTPercents;
    AvgPerpVel = MTPercents;
    
    %%going through each region and adding values to arrays 
    for region = 1:numRegions-1
        %%create region dimensions
        if axis == 'X'
            regionDimensions = ...
                [regionBounds(region),regionBounds(region + 1),0,(windowWidth/2)];
        elseif axis == 'Y'
            regionDimensions = ...
                [0,(windowWidth/2),regionBounds(region),regionBounds(region + 1)];
        end
        %%extract region info
        [percentMTs,MTParVels,MTPerpVels] = ...
            FUNC_FindMTsInRegion(regionDimensions,2,MTPairInfo);
        %%store extracted info in arrays
        MTPercents(region) = percentMTs;
        AvgParVel(region) = mean(MTParVels);
        AvgPerpVel(region) = mean(MTPerpVels);
    end
end

