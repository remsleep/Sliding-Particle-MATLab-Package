function [] = FUNC_HistogramVelOverTime(allVelInfo, SAVE_DATA)
%FUNC_HISTOGRAMVELOVERTIME takes in ALLVELINFO and plots the binned
%velocities stored therein at each frame in time. The variable ALLVELINFO
%is a 5xN array, where N is the number of velocities recorded between
%particle pairs. 
% - the first row of ALLVELINFO is the relative velocities between particles
% - the second row of ALLVELINFO is the distance between the measured particles
% - the third row of ALLVELINFO is the frame these velocities were taken
% - the fourth row of ALLVELINFO is the index of the first particle
% - the fifth row of ALLVELINFO is the index of the second particle
% SAVE_DATA is a booleon value indicating whether or not each frame will be
% saved.

%Find highest frame
maxFrame = max(allVelInfo(3,:));

%Get directory where data will be saved
if SAVE_DATA == 1
    saveDir = uigetdir;
end

%Iterate through frames and plot histograms
for currFrame = 1:maxFrame
    
    frameIndices = allVelInfo(3,:) == currFrame;
    
    [N, edges] = histcounts(allVelInfo(1, frameIndices));
    plot(edges(2:end),N)
    pause(.1)
    
    if SAVE_DATA == 1
    end
    
    hold on
    
end

