%%FOr Comparing Stephen's and Linnea's Velocity Analysis


%%loading test data from appropriate directory
directory = 'C:\Users\Jude\Documents\MATLAB\2020-07-31 For Jude\Fake Data';
% load(fullfile(directory, 'SameDirectionParallel.mat'));
% load(fullfile(directory, 'SameDirectionPerpendicular.mat'));
% load(fullfile(directory, 'OppositeDirectionParallel.mat'));
% load(fullfile(directory, 'OppositeDirectionPerpendicular.mat'));
% load(fullfile(directory, 'TowardsParallel.mat'));
% load(fullfile(directory, 'TowardsPerpendicular.mat'));

%%creating test case structure so that for loop can run through each test case
testCases = struct();
testCases(1).case = SameDir_Parallel;
testCases(2).case = SameDir_Perpendicular;
testCases(3).case = OppDir_Parallel;
testCases(4).case = OppDir_Perpendicular;
testCases(5).case = TowardsParallel;
testCases(6).case = TowardsPerpendicular;

%%copying parameters from functions
pixelConv = 1;%6.5*2/100;      %%In um/pix
timeConv = 1;%0.35;            %%In seconds/frame
WINDOW = 2;                 %%Window of integration for which velocities are calculated
angleCutOff = 10;           %%Max angle in degrees allowed between MTs
%%**change pixelConv and timeConv to one for no conversion**

%%initializing results structures
outputsStephen = struct();
outputsLemma = struct();
outputsComparison = struct();

%%for clarifying comparison structure
AnalyzerName = {'Stephen 1';'Stephen 2';'Lemma 1';'Lemma 2'};
AnalyzerName = cell2table(AnalyzerName,'VariableNames',{'Name of Analyzer'});

%%running through each test case
for caseNum = 1:numel(testCases)

    %%Stephen's Method
    velInfoStephen = FORTEST_Stephen_CalcRelVelocities2(testCases(caseNum).case);
    % Calculate parallel and perpendicular separation from Rsep and RelAngle
    velInfoStephen(:,7) = velInfoStephen(:,1).*cos(velInfoStephen(:,2));
    velInfoStephen(:,8) = velInfoStephen(:,1).*sin(velInfoStephen(:,2));
    % Rescale velocities positions using pixel and time conversion values
    velInfoStephen(:,1) = velInfoStephen(:,1)*pixelConv;
    velInfoStephen(:,4) = velInfoStephen(:,4)*pixelConv/timeConv;
    velInfoStephen(:,5) = velInfoStephen(:,5)*pixelConv/timeConv;
    velInfoStephen(:,7) = velInfoStephen(:,7)*pixelConv;
    velInfoStephen(:,8) = velInfoStephen(:,8)*pixelConv;
    %rearranging data for comparison
    velInfoStephen = [velInfoStephen(:,1) velInfoStephen(:,3:8) velInfoStephen(:,2)];
    velInfoStephen = array2table(velInfoStephen,'VariableNames', {'Relative Separation',...
            'DeltaA','Relative Parallel Velocity','Relative Perpendicular Velocity'...
            'Frame', 'Relative Parallel Separation','Relative Perpendicular Separation','Relative Angle'});   
    %entering case results into results structure
    outputsStephen(caseNum).case = velInfoStephen;
    
    
    
    %%Lemma's Method
     %rearranging data to plug into function
     updatedTestCase = testCases(caseNum).case';
     velInfoLemma = FUNC_FindVelocityFromArray(updatedTestCase,WINDOW,pixelConv,timeConv);
     %data being organized into a structure instead of an array
     velInfoLemma = circshift(velInfoLemma, 3, 1);
     velInfoLemma = FUNC_Array2Structure(velInfoLemma, {'ID', 'PARVEL', 'PERPVEL', 'X', 'Y', 'FRAME', 'ORIENT'});
     %finding relative values
%      [relParVel, relPerpVel, Distance, Coords, DeltaAng, Frames] = ...
%                        FUNC_PairwiseParPerpVelocitiesSameChannelArray(velInfoLemma, WINDOW, deg2rad(angleCutOff)); 
     [relParVel, relPerpVel, Distance, Coords, DeltaAng, Frames] = ...
                        FUNC_PairwiseParPerpVelocitiesSameChannelArrayLower(velInfoLemma, WINDOW, deg2rad(angleCutOff));
     %rearraning data for comparison
     allVelInfo = [Distance; DeltaAng; relParVel; relPerpVel; Frames; Coords(1,:); Coords(2,:); [999,999]]';
     reorganizedVelInfo = array2table(allVelInfo,'VariableNames',{'Relative Separation','DeltaA','Relative Parallel Velocity',...
         'Relative Perpendicular Velocity','Frame','Relative Parallel Separation','Relative Perpendicular Separation', 'Relative Angle'});
     %emteromg case results into case structure 
     outputsLemma(caseNum).case = reorganizedVelInfo;
     
     %%comparing outputs of both analyses
     outputsComparison(caseNum).case = [velInfoStephen; reorganizedVelInfo];
     outputsComparison(caseNum).case = [AnalyzerName outputsComparison(caseNum).case];
end

