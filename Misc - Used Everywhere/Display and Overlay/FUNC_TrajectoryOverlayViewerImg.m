function [] = FUNC_TrajectoryOverlayViewerImg(TRAJECTORY, IMAGES, SAVE_DATA, FRAMES_TOTAL)
%This function plots given trajectory locations (in TRAJECTORY) over the
%images trajectories are sampled from, stored in the array IMAGES. The number of
%time points is extracted from the 3D IMAGES array (XxYxT).
%FRAMES_TOTAL is an optional variable that allows the user to run the first
%FRAMES_TOTAL number of points. It must be a scalar. SAVE_DATA is a logical
%boolean which indicates that the user would like to save their overlay
%images (1 for save, anything else for no save)

%Define total number of files to be analyzed
if nargin == 3
    FRAMES_TOTAL = size(IMAGES,3);
elseif nargin == 4
    FRAMES_TOTAL = min(FRAMES_TOTAL, size(IMAGES,3));
end

%Prep save directory
if SAVE_DATA == 1
    saveDir = uigetdir;
end

%Generate logical matrix indicating in which frames each trajectory exists.
%TFMat is Trajectory-Frame Matrix
TFMat = FUNC_TrajectoryInFrameMatrix(TRAJECTORY, FRAMES_TOTAL);

%Iterate through each frame and plot trajectories over images
for currFrame = 1000:FRAMES_TOTAL
    
    %Load and display image at currFrames
    currImg = IMAGES(:,:,currFrame);
    imagesc(currImg);
    colormap(gray)
    hold on
    
    %Overlay trajectory locations
    trajsInCurrFrame = find(TFMat(:,currFrame)==1);
    %Iterate through trajectories
    for index = 1:numel(trajsInCurrFrame)
        currTraj = trajsInCurrFrame(index);
        %Plot trajectories up to this point in time
        currEndTime = find(TRAJECTORY(currTraj).FRAME == currFrame);                %This variable is used to determine how far in the trajcetory's evolution we are
        plot(TRAJECTORY(currTraj).X(1:currEndTime),...
            TRAJECTORY(currTraj).Y(1:currEndTime),...
            'r','Linewidth', 2);
        %Scatter newest point
        scatter(TRAJECTORY(currTraj).X(currEndTime),TRAJECTORY(currTraj).Y(currEndTime),'filled','b');
        title(sprintf('Frame: %i', currFrame));

    end
    pause(.1)
    
    hold off
    %Save images
    if SAVE_DATA == 1
        saveas(gcf, sprintf('%s\\%.6d%s', saveDir, currFrame, IMAGE_TYPE));
    end
    
end
