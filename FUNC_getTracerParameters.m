function [tracerParams] = FUNC_getTracerParameters(TRACER_PATH, N)
%%This function looks in the directory TRACER_PATH, detects objects in the first N frames
%%using FUNC_TracerFinderRedo, then prompts the user for updated detection
%%parameters, if necessary.

%Set default parameters
LENGTH = 5;                 %in pixels
WIDTH = 3;                  %in pixels
pixelMin = 50;              %in pixels
pixelMax = 2000;            %in pixels
ANGULAR_RESOLUTION = 20;    %in degrees
tracerParams = [LENGTH WIDTH pixelMin pixelMax ANGULAR_RESOLUTION];

%Define extent of analysis if unspecified by user
if nargin == 1
    N = 20;
end

%Define variable to indicate inputted parameters are acceptable
notSatisfied = 1;

%% Finding suitable parameters
%Begin loop to search for acceptable length and width parameters
while notSatisfied
    figure()
    tic
    [MT_DATA, IMAGES] = FUNC_TracerFinderRedo(TRACER_PATH, tracerParams, N);
    toc
    plotObjects(MT_DATA, IMAGES);
    title(num2str(tracerParams))
    [tracerParams, notSatisfied] = updateParameters(tracerParams);
%     close
end

end

%% Additional Functions
function [] = plotObjects(MT_DATA, IMAGES)
%%This simple function loops through all frames in IMAGES, displays them,
%%and overlays the microtubules detected in each

frameTot = size(IMAGES, 3);
for currFrame = 1:frameTot
    FUNC_overlayMTsImage(MT_DATA(currFrame).MTs, IMAGES(:,:,currFrame));
    pause(.1);
end
end

%%
function [tracerParams, notSatisfied] = updateParameters(tracerParams)
%%This function prompts the user fo updated parameters and returns said
%%parameters, along with an updated NOTSATISFIED boolean indicating if
%%acceptable paramteters have been found.
    
    %Reset parameter change trigger
    stringtrigger = -1;
    possibleResponses = ['1', 'yes', 'Yes', '0', 'no', 'No'];

    %Split tracer parameters
    LENGTH = tracerParams(1);
    WIDTH= tracerParams(2);
    pixelMin = tracerParams(3);
    pixelMax = tracerParams(4);
    ANGULAR_RESOLUTION = tracerParams(5);
    
    fprintf('\n');
    while ~ismember(stringtrigger, possibleResponses)
        %Adjust LENGTH and WIDTH, if necessary
        fprintf('Current MT LENGTH: %d; Current MT WIDTH: %d.\nWould you like new values? ',...
            LENGTH,WIDTH);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(8:end))
            notSatisfied = 0;
        elseif ismember(stringtrigger, possibleResponses(1:7))
            LENGTH = input('Please input a new LENGTH: '); 
            WIDTH = input('Please input a new WIDTH: ');
            notSatisfied = 1;
        end
        %Adjust pixelMin and pixelMax, if necessary
        fprintf('Current MT pixelMin: %d; Current MT pixelMax: %d.\nWould you like new values? ',...
            pixelMin,pixelMax);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(8:end)) && (notSatisfied == 0)
            notSatisfied = 0;
        elseif ismember(stringtrigger, possibleResponses(1:7))
            pixelMin = input('Please input a new pixelMin: ');
            pixelMax = input('Please input a new pixelMax: '); 
            notSatisfied = 1;
        end
        %Adjust ANGULAR_RESOLUTION, if necessary
        fprintf('Current convolving angular reoslution: %d.\nWould you a like new value? ',...
            ANGULAR_RESOLUTION);
        stringtrigger = input('Please type response: ','s');
        if ismember(stringtrigger, possibleResponses(8:end)) && (notSatisfied == 0)
            notSatisfied = 0;
        elseif ismember(stringtrigger, possibleResponses(1:7))
            ANGULAR_RESOLUTION = input('Please input a new ANGULAR_RESOLUTION: ');
            stringtrigger = 'y';
            notSatisfied = 1;
        end
    end
    
    %Tell user new parameters are being used
    if notSatisfied == 1
        disp('Processing with new parameters...')
    end
    
    %Recombine parameters for output
    tracerParams = [LENGTH, WIDTH, pixelMin, pixelMax, ANGULAR_RESOLUTION];
end