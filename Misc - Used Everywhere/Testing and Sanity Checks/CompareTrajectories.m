%% Define data directories
imgDir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Batch1\tifs';
tr1Dir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Batch1';
tr2Dir = 'E:\Two Channel Nematic\Linnea Data\forRemi\Linnea Original Data';


%% Tracks are assumed to be 5xN: [x,y,frame,orient,ID] and converted to structures
fields = {'ID','X', 'Y', 'FRAME', 'ORIENT'};
tr1Struct = load(fullfile(tr1Dir, 'calculatingTrajectoryData.mat'));
tr1Array = circshift(FUNC_Structure2Array(tr1Struct(1).RH_TRAJECTORY),1,1);
tr1 = FUNC_Array2Structure(tr1Array([1 3 4 2 6],:),fields);
tr2temp = load(fullfile(tr2Dir, 'tracks.mat'));
tr2 = FUNC_Array2Structure(circshift(tr2temp.tr',1,1),fields);

%% Get matrices of 
TF1Mat = FUNC_TrajectoryInFrameMatrix(tr1, numel(tr1));
TF2Mat = FUNC_TrajectoryInFrameMatrix(tr2, numel(tr2));

%% Iterate through frames and overlay tracks
currFrame = 0;

ds = datastore(fullfile(imgDir,'\*.tif'));
while hasdata(ds)
    
    currFrame = currFrame + 1;
    img = read(ds);
    imagesc(img);
    hold on
    
    %Overlay trajectory locations
    trajs1InCurrFrame = find(TF1Mat(:,currFrame)==1);
    trajs2InCurrFrame = find(TF2Mat(:,currFrame)==1);

    for index = 1:numel(trajs1InCurrFrame)
        currTraj = trajs1InCurrFrame(index);
        %Plot trajectories up to this point in time
        currEndTime = find(tr1(currTraj).FRAME == currFrame);                %This variable is used to determine how far in the trajcetory's evolution we are
        plot(tr1(currTraj).X(1:currEndTime),...
            tr1(currTraj).Y(1:currEndTime),...
            'r','Linewidth', 2);
        %Scatter newest point
        scatter(tr1(currTraj).X(currEndTime),tr1(currTraj).Y(currEndTime),'filled','r');
        title(sprintf('Frame: %i', currFrame));
    end
    
    for index = 1:numel(trajs2InCurrFrame)
        currTraj = trajs2InCurrFrame(index);
        %Plot trajectories up to this point in time
        currEndTime = find(tr2(currTraj).FRAME == currFrame);                %This variable is used to determine how far in the trajcetory's evolution we are
        plot(tr2(currTraj).X(1:currEndTime),...
            tr2(currTraj).Y(1:currEndTime),...
            'b','Linewidth', 2);
        %Scatter newest point
        scatter(tr2(currTraj).X(currEndTime),tr2(currTraj).Y(currEndTime),'filled','b');
        title(sprintf('Frame: %i', currFrame));
    end
    hold off
    pause(.1)
end
    
