function [trajectoryParams] = FUNC_getTrajectoryParameters(MT_DATA, IMAGES, framesTot)
%FUNC_GETTRAJECTORYPARAMETERS This function takes in a 5xN array containing
%temporal, dimensional, and postiional data of N microtubules detected in
%IMAGES. The order of the data is [FRAMES, LENGTH, ANGLE, X_POS, Y_POS].
%FRAMESTOT is a scalar indicating that the script will analyze the first
%FRAMESTOT images.

    %Set detection parameters
    MAX_DISPLACEMENT = 100;    %in pixels
    MAX_ROTATION     = 0.05;   %in Radians
    MAX_SCALE        = 0.05;   %in Percent
    MIN_FRAMES       = 3;     %How many frames does the MT need to be in before it counts?
    trajectoryParams = [MAX_DISPLACEMENT MAX_ROTATION MAX_SCALE MIN_FRAMES];

    %Define extent of analysis if unspecified by user
    if nargin == 2
        framesTot = 20;
    end

    %Define variable to indicate inputted parameters are acceptable
    notSatisfied = 1;

    %% Finding suitable parameters
    %Begin loop to search for acceptable length and width parameters
    while notSatisfied
        figure()
        [TRAJECTORY] = FUNC_TrajectoryTracker(MT_DATA, trajectoryParams, framesTot);
        FUNC_TrajectoryOverlayViewerImg(TRAJECTORY, IMAGES, 0, 20);
        [trajectoryParams, notSatisfied] = updateParameters(trajectoryParams);
        close
    end

end
%% Additional Functions
function [trajectoryParams, notSatisfied] = updateParameters(trajectoryParams)
%%This function prompts the user fo updated parameters and returns said
%%parameters, along with an updated NOTSATISFIED boolean indicating if
%%acceptable paramteters have been found.
    
    %Reset parameter change trigger
    stringtrigger = -1;
    possibleResponses = ['1', 'yes', 'Yes', '0', 'no', 'No'];

    %Split tracer parameters
    MAX_DISPLACEMENT = trajectoryParams(1);
    MAX_ROTATION = trajectoryParams(2);
    MAX_SCALE = trajectoryParams(3);
    MIN_FRAMES = trajectoryParams(4);
    
    fprintf('\n');
    %Prompt user for new parameters. Needs help :((
    while ~ismember(stringtrigger, possibleResponses)
        %Adjust MAX_DISPLACEMENT, if necessary
        fprintf('Current MAX_DISPLACEMENT: %f; Would you like to update this value? ',...
            MAX_DISPLACEMENT);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(8:end))
            notSatisfied = 0;
        elseif ismember(stringtrigger, possibleResponses(1:7))
            MAX_DISPLACEMENT = input('Please input a new MAX_DISPLACEMENT: '); 
            notSatisfied = 1;
        end
        %Adjust MAX_ROTATION, if necessary
        fprintf('Current MAX_ROTATION: %f; Would you like to update this value? ',...
            MAX_ROTATION);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(8:end)) && (notSatisfied == 0)
            notSatisfied = 0;
        elseif ismember(stringtrigger, possibleResponses(1:7))
            MAX_ROTATION = input('Please input a new MAX_ROTATION: '); 
            notSatisfied = 1;
        end
        %Adjust MAX_SCALE, if necessary
        fprintf('Current MAX_SCALE: %f; Would you like to update this value? ',...
            MAX_SCALE);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(8:end)) && (notSatisfied == 0)
            notSatisfied = 0;
        elseif ismember(stringtrigger, possibleResponses(1:7))
            MAX_SCALE = input('Please input a new MAX_SCALE: '); 
            notSatisfied = 1;
        end
        %Adjust MIN_FRAMES, if necessary
        fprintf('Current convolving angular resolution: %d. Would you a like new value? ',...
            MIN_FRAMES);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(8:end)) && (notSatisfied == 0)
            notSatisfied = 0;
        elseif ismember(stringtrigger, possibleResponses(1:7))
            MIN_FRAMES = input('Please input a new MIN_FRAMES: ');
            stringtrigger = 'y';
            notSatisfied = 1;
        end
    end
    
    %Tell user new parameters are being used
    if notSatisfied == 1
        disp('Processing with new parameters...')
    end
    
    %Recombine parameters for output
    trajectoryParams = [MAX_DISPLACEMENT MAX_ROTATION MAX_SCALE MIN_FRAMES];
end
