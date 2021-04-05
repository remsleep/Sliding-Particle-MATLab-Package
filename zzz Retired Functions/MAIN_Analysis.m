%This code is meant to find, and track MT tracers from an image and then
%analyze them

%% MTs batch 1
 DATA_PATH = 'D:\Alex Two Color MT Data\Data Set 1\Channel 1 1150 frames';
 TRACER_PATH= DATA_PATH;
%  BUNDLE_PATH=[ BASE_PATH DATA_PATH '\Kinesin_STABLE'];
 UNITS_CONVERSION = 1*11 / 20 / 40; %bin * micron/pixel / sec/frame / mag
 THRESHOLD = 0.6; %# between 1 and 0, Lower includes more of the bundle
 MAX_PIX_VALUE = 400; WIDTH = 3; LENGTH = 5;



%%
% TRACER_PATH=[ BASE_PATH DATA_PATH '\Tracer'];
% BUNDLE_PATH=[ BASE_PATH DATA_PATH '\Bleach'];

%% 1 Find Individual MTs in Individual Frames
%will need to play with the parameters for each data set
[FRAME, LENGTH, ANGLE, X_POS, Y_POS] = FUNC_TracerFinder(TRACER_PATH,MAX_PIX_VALUE,WIDTH,LENGTH);

%% 2 Mask out anything not in a bundle
% MASK = FUNC_MaskMaker(BUNDLE_PATH,THRESHOLD);
% [FRAME, LENGTH, ANGLE, X_POS, Y_POS] = FUNC_MaskApplier(MASK, FRAME, LENGTH, ANGLE, X_POS, Y_POS);

%% 3 Create paths of MTs throughout the Frames, and record their Positions and Angles
[TRAJECTORY] = FUNC_Tracer_Trajectory_Tracker(FRAME', LENGTH', ANGLE', X_POS', Y_POS');

%% 4 Calculate Veloocities
WINDOW = 2; %How many time points should be used to calculate velocity
[TRAJECTORY_WITH_VEL] = FUNC_Find_Velocity(TRAJECTORY, WINDOW);

%% 5 Calculate Relative Velocities
[REL_VEL, DISTANCE] = FUNC_PairwiseVelocity(TRAJECTORY_WITH_VEL);

%% Plot the Results
dist = 30;
REL_VEL_BY_DIST = REL_VEL(DISTANCE < dist); %50 for bin2 60x, 37.5 for bin1 40x
REL_VEL_BY_DIST(isnan(REL_VEL_BY_DIST))=[];
figure();
histogram(1000*UNITS_CONVERSION*REL_VEL_BY_DIST,'BinWidth',3,'FaceAlpha', 0.2, 'EdgeAlpha', 0.0);
xlabel('Relative Velocity (nm/s)','FontName','Raleway');
ylabel('Counts','FontName','Raleway'); 
set(gca,'FontName','Raleway','FontSize',14)
xlim([-100 100])

%% Plot some trajectories
figure;
hold on;
for i = 1:1:length(TRAJECTORY)
   
    plot(TRAJECTORY(i).X,TRAJECTORY(i).Y)
    
end
xlim([0 max([TRAJECTORY.X])])
ylim([0 max([TRAJECTORY.Y])])

