function JUDE_OverlaySingleTrajectory(TrajNum,IMAGES,TRAJECTORY)
%JUDE_OVERLAYSINGLETRAJECTORY This function takes in a trajectory and
%overlays that trajectory on top of its corresponding image. The objection
%of this function is to debug the trajectory tracking code and to resolve
%the issue where trajectories zigzag between neighboring microtubules.
FRAMES_TOTAL = size(IMAGES, 3);

TFMat = FUNC_TrajectoryInFrameMatrix(TRAJECTORY, FRAMES_TOTAL);

CURR_TRAJ_MAT = TFMat(TrajNum,:);
CURR_TRAJ_INFO = TRAJECTORY(TrajNum);

MTFrames = find(CURR_TRAJ_MAT == 1);
endFrame = MTFrames(end);

currImg = IMAGES(:,:,endFrame);
imagesc(currImg);
colormap(gray)
hold on



plot(CURR_TRAJ_INFO.X,CURR_TRAJ_INFO.Y,...
            'r','Linewidth', 2);
%Scatter newest point
scatter(CURR_TRAJ_INFO.X,CURR_TRAJ_INFO.Y,'filled','b');
title(['Trajectory Num: ' num2str(TrajNum)]);
hold off
end

