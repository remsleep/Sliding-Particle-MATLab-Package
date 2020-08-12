%% function to plot all the MTs in a frame with their trajectories


function FUNC_plot_trajectories(TRACER_PATH, TRAJECTORY, frame)

FILES = dir([TRACER_PATH '\*.tif']);

clear index
index = find(arrayfun(@(TRAJECTORY) ismember(frame, TRAJECTORY.FRAME), TRAJECTORY)); 

IMAGE = imread([FILES(frame).folder '\' FILES(frame).name]);
a = double(IMAGE);
imcontrastscale(1)=min(min(a));
imcontrastscale(2)=mean(mean(a))*2;
figure('color',[1 1 1]);
colormap ('gray'), imshow(a,imcontrastscale);

hold on

DISP=[];

for i=1:length(index)
    plot(TRAJECTORY(index(i)).X,TRAJECTORY(index(i)).Y,'Linewidth',2);
    scatter(TRAJECTORY(index(i)).X(1),TRAJECTORY(index(i)).Y(1),'filled');
    DISP=[DISP, sqrt((TRAJECTORY(index(i)).X(end)-TRAJECTORY(index(i)).X(1))^2+(TRAJECTORY(index(i)).Y(end)-TRAJECTORY(index(i)).Y(1))^2)];
    %DELTAY=[DELTAY, TRAJECTORY(index(i)).Y(end)-TRAJECTORY(index(i)).Y(1)];
end