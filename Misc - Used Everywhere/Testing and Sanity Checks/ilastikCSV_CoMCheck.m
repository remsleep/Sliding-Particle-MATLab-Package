%% Define data directory and file name
dataDir = 'E:\To be sorted\Polar Bears\MSD Dead Nematic\2021-02-22\1201_2x2bin_100xObj_2fps_Zyla5p5_RED_100msExp_maxPower_1';
dataName = 'backSubbed_cropped_CSV-Table.csv';
pixelConv = 6.5*2/100*1000;                     %In nm/pix
timeConv = 1;                                   %In sec/frame
%% Instantiate .csv reader object and storage array
dataStore = datastore(fullfile(dataDir,dataName));
storedData = [];

%% Fill storage array with object times and centers
while hasdata(dataStore)
    currData = read(dataStore);
    storedData = [storedData; currData(:,[1 2 3 39 40])];
end
storedData = table2array(storedData);
storedData = [storedData, zeros(size(storedData,1),1)];
%Mark all particles without trajectories
storedData(storedData(:,3) == -1,6) = -1;

%% Reorder array based on ID number, then time
[~,sortInds] = sort(storedData(:,3));
sortedData = storedData(sortInds,:);
%% Iterate through trajectories and calculate change in CoM position between frames
for currTraj = 2:max(sortedData(:,3))
   
    trajInds = sortedData(:,3) == currTraj;
    sortedData(trajInds, 6) = ...
        [-1; findSep( diff(sortedData(trajInds, 4)), diff(sortedData(trajInds, 5)) )];
    
end

%% Show distribution of shifts in CoM between frames
validData = sortedData(sortedData(:,6) > 0,:);
scaledData = [validData(:,1)*timeConv, validData(:,2:3), validData(:,4:6)*pixelConv];
histogram(scaledData(:,6),0:5:500);

%% Scatter plot particle positions
imgDir = 'E:\To be sorted\Polar Bears\MSD Dead Nematic\2021-02-22\1201_2x2bin_100xObj_2fps_Zyla5p5_RED_100msExp_maxPower_1\Cropped';
imgNames = dir(imgDir);
imagesc(imread(fullfile(imgDir, imgNames(3).name)));

for currTime = 1:1:max(validData(:,1))
    partsInFrame = validData(validData(:,1) == currTime,:);
    hold on
%     scatter(partsInFrame(:,4), partsInFrame(:,5),[],...
%         [(222-(222-162)*currTime/max(validData(:,1))), (132-(132-168)*currTime/max(validData(:,1))), (16-(16-50)*currTime/max(validData(:,1)))]/255, ...
%         'filled')    
    scatter(partsInFrame(:,4), partsInFrame(:,5),'filled')
%     hold off
    pause(.1)
end

%% Plot single trajectory over time
trajNum = 18;
imgDir = 'E:\To be sorted\Polar Bears\MSD Dead Nematic\2021-02-22\1201_2x2bin_100xObj_2fps_Zyla5p5_RED_100msExp_maxPower_1\Cropped';
imgNames = dir(imgDir);
figure
imagesc(imread(fullfile(imgDir, imgNames(3).name)));
colormap('gray')

currTrajData = scaledData(validData(:,3) == trajNum,:);
hold on
plot(currTrajData(:,4), currTrajData(:,5),'r','LineWidth',2);

%% Make cell out of single traj
track = cell(1,1);
track{1} = currTrajData(:,[1 4 5]);
ma = msdanalyzer(2, 'nm', 's');
ma = ma.addAll(track);

ma.plotTracks;
ma.plotMeanMSD;

%% Isolate all steps data with change in CoM less than three pixels
smallData = scaledData(validData(:,6) <= 3,:);
% smallData = validData;
% Load into new msdanalyzer object and get tracks
ma = msdanalyzer(2,'nm','s');
tracks = cell(numel(unique(smallData(:,3))),1);

for currTraj = unique(smallData(:,3))'
    trackInds = smallData(:,3) == currTraj;
    tracks{currTraj-1} = smallData(trackInds, [1 4 5]);
end

% Add tracks to msdanalyzer object
ma = ma.addAll(tracks);
disp(ma)

ma.plotMeanMSD


%% Additional functions
function [r] = findSep(x,y)

r = sqrt(x.^2 + y.^2);

end


