function [peaks,avgs,Nsep,sepDist] = FUNC_HistogramVelOverSeparation(allVelInfo, spacing, SAVE_DATA)
%FUNC_HISTOGRAMVELOVERSEPARATION takes in ALLVELINFO and plots the binned
% velocities stored therein within a binned subsection of particle
% separation. The variable ALLVELINFO is a 5xN array, where N is the number 
% of velocities recorded between particle pairs. 
% - the first row of ALLVELINFO is the relative velocities between particles
% - the second row of ALLVELINFO is the distance between the measured particles
% - the third row of ALLVELINFO is the frame these velocities were taken
% - the fourth row of ALLVELINFO is the index of the first particle
% - the fifth row of ALLVELINFO is the index of the second particle
% SAVE_DATA is a booleon value indicating whether or not each frame will be
% saved. SPACING is a scalar that determines the separation of binning in
% the units of displacement

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

%Get distribution of separations
sepBinNum = round( max(allVelInfo(2,:))/spacing );
[Nsep, sepDist] = histcounts(allVelInfo(2,:), sepBinNum);

%Initialize peaks array
peaks = zeros(2, numel(Nsep));
avgs = peaks;

%Iterate through frames and plot histograms
for currSep = 1:numel(sepDist(2:end))
    
    %Find indices of elements in current separation range
    sepIndicesUpper = allVelInfo(2,:) <= sepDist(1+currSep);
    sepIndicesLower = allVelInfo(2,:)  >= sepDist(currSep);
    sepIndices = find(1 - mod(sepIndicesUpper + sepIndicesLower,2));
    tempVels = allVelInfo(1,sepIndices);
    
    %Define mean velocity and variance for current separation window
    avgs(1,currSep) = mean(tempVels);
    avgs(2,currSep) = var(tempVels);
    
    %Get histogram of relative velocities in current separation range
    [N, edges] = histcounts(tempVels,25); %#ok<FNDSB>
%     plot(edges(2:end),N)
%     title(sprintf('Current separation range: %s - %s', ...
%         num2str(sepDist(currSep)), num2str(sepDist(currSep+1))))
%     pause(.1)
%     
    peakIndex = min(find( N == max(N) ));
    peaks(1,currSep) = edges(peakIndex+1);
    peaks(2,currSep) = N(peakIndex);
%     
    %Must still be implemented
%     if SAVE_DATA == 1
%     end
    
    
%     hold on
    
end

