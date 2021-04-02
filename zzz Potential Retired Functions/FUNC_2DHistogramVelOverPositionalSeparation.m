function [peaks,avgs,binCoords] = FUNC_2DHistogramVelOverPositionalSeparation(allVelInfo, spacing, SAVE_DATA)
%FUNC_2DHISTOGRAMVELOVERPOSITIONALSEPARATION takes in ALLVELINFO and plots the binned
% velocities stored therein within a binned subsection of particle
% separation. The variable ALLVELINFO is a 4xN array, where N is the number 
% of relative velocities recorded between particle pairs. 
% - the first row of ALLVELINFO is the relative parallel velocities between particles
% - the second row of ALLVELINFO is the relative perpendicular velocities between particles
% - the third row of ALLVELINFO is the distance along a particle's parallel director between the pair
% - the fourth row of ALLVELINFO is the distance along a particle's perpendicular director between the pair
% SAVE_DATA is a booleon value indicating whether or not each frame will be
% saved. SPACING is a scalar that determines the separation of binning in
% the units of displacement
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%BINCOORDS is an MxNx2 matrix that contains the binned values of parallel
% and perpendicular velocities. M and N are determined as the number of
% spacings between the maximal and minimal parallel and perpendicular
% velocities with separation SPACING
%%PEAKS is an MxNx4 matrix which contains information within a given bin
% value designated by the corresponding BINCOORDS coordinate:
% [peak histogram parallel velocity, number of instances, peak histogram
% perpendicular velocity, number of instances]
%%AVGS is an MxNx4 matrix which cotains information within a given bin
% value designated by the corresponding BINCOORDS coordinate:
% [avg parallel velocity within a given bin spacing, associated stdev,  
% avg perpallel velocity within a given bin spacing, associated stdev]

if nargin == 3
    %Get directory where data will be saved
    if SAVE_DATA == 1
        saveDir = uigetdir;
    end
else
    SAVE_DATA = 0;
    if nargin == 1
        spacing = 1;
    end
end

%Define boundaries of parallel and perpendicular displacement bins
parSepDists = min(allVelInfo(3,:)):spacing:max(allVelInfo(3,:));
perpSepDists = min(allVelInfo(4,:)):spacing:max(allVelInfo(4,:));

%Initialize peaks array
peaks = zeros(numel(parSepDists)-1, numel(perpSepDists)-1,4);
avgs = peaks;
binCoords = peaks(:,:,1:2);

%Iterate through grid of separations
for parSep = 1:numel(parSepDists(2:end))
    
    %Find indices of elements in current parallel separation range
    sepIndicesUpper = allVelInfo(3,:) <= parSepDists(1+parSep);
    sepIndicesLower = allVelInfo(3,:) >= parSepDists(parSep);
    parSepIndices = find(1-mod(sepIndicesUpper + sepIndicesLower,2));
    parSepVels = allVelInfo(:,parSepIndices);
    
    for perpSep = 1:numel(perpSepDists(2:end))
            
        %Find indices of elements in current parallel separation range
        sepIndicesUpper = parSepVels(4,:) <= perpSepDists(1+perpSep);
        sepIndicesLower = parSepVels(4,:) >= perpSepDists(perpSep);
        perpSepIndices = find(1-mod(sepIndicesUpper + sepIndicesLower,2));
        tempVels = parSepVels(1:2,perpSepIndices);
        
        %Define mean velocity and variance for current separation window
        avgs(parSep,perpSep,1) = mean(tempVels(1,:));
        avgs(parSep,perpSep,2) = var(tempVels(1,:));
        avgs(parSep,perpSep,3) = mean(tempVels(2,:));
        avgs(parSep,perpSep,4) = var(tempVels(2,:));
        
        %Get histogram of relative velocities in current separation range
%         [N, parEdges] = histcounts(tempVels(1,:), ...
%             parSepDists(parSep):(parSepDists(parSep+1)-parSepDists(parSep))/25:parSepDists(parSep+1)); %#ok<FNDSB>
       [N, parEdges] = histcounts(tempVels(1,:), 25); %#ok<FNDSB>
        peakIndex = min(find( N == max(N) ));
        peaks(parSep,perpSep,1) = parEdges(peakIndex+1);
        peaks(parSep,perpSep,2) = N(peakIndex);
        
%         [N, perpEdges] = histcounts(tempVels(2,:), ...
%             perpSepDists(perpSep):(perpSepDists(perpSep+1)-perpSepDists(perpSep))/25:perpSepDists(perpSep+1)); %#ok<FNDSB>); %#ok<FNDSB>
       [N, perpEdges] = histcounts(tempVels(2,:), 25); %#ok<FNDSB>); %#ok<FNDSB>
        peakIndex = min(find( N == max(N) ));
        peaks(parSep,perpSep,3) = perpEdges(peakIndex+1);
        peaks(parSep,perpSep,4) = N(peakIndex);
        
        %Store bin coordinate
        binCoords(parSep, perpSep, :) = [parSepDists(1+parSep), perpSepDists(1+perpSep)];
%     

    end

    

    %Must still be implemented
%     if SAVE_DATA == 1
%     end
    
    
%     hold on
    
end

end

