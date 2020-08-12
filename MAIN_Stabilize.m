%This code is meant to stabilize a pair of Tracer and Bundle images
%together
clear all
%% Select Experiment
BASE_PATH = 'C:\Users\BezBez\Google Drive\Graduate_Research\Writing\BundlePaper\Data\';
DATA_PATH = '0p25PEG_Example';
%C:\Users\BezBez\Google Drive\Graduate_Research\Writing\BundlePaper\Data\test
%DATA_PATH = '\1p0PEG_BundlesWTracers_K14\Comet_SingleBundle';
TRACER_PATH=[ BASE_PATH DATA_PATH '\Tracer'];
BUNDLE_PATH=[ BASE_PATH DATA_PATH '\Kinesin'];

TRACER_SAVE_PATH = [ BASE_PATH DATA_PATH '\Tracer_STABLE\'];
BUNDLE_SAVE_PATH = [ BASE_PATH DATA_PATH '\Kinesin_STABLE\'];
%We are going to stabilize off of the Bundle images

BUNDLE_FILES = dir([BUNDLE_PATH '\*.tif']);
TRACER_FILES = dir([TRACER_PATH '\*.tif']);
t_end = length(BUNDLE_FILES);

clear IMAGE
clear IMAGE_TRACER
IMAGE(:,:,1)   =  imread([BUNDLE_FILES(1).folder '\' BUNDLE_FILES(1).name]);
IMAGE_TRACER(:,:,1)   =  imread([TRACER_FILES(1).folder '\' TRACER_FILES(1).name]);

%Adjust the images
for t = 1:(t_end-1)
%     t
    IMAGE_TEMP         =  imread([BUNDLE_FILES(t+1).folder '\' BUNDLE_FILES(t+1).name]);
    IMAGE_TEMP_TRACER  =  imread([TRACER_FILES(t+1).folder '\' TRACER_FILES(t+1).name]);
    % We now use the image registration code to register f and g within 0.01
    % pixels by specifying an upsampling parameter of 100
    usfac = 100;
    [output, ~] = dftregistration(fft2(IMAGE(:,:,t)),fft2(IMAGE_TEMP),usfac);
    YSHIFT(t) = output(3);
    XSHIFT(t) = output(4);
    
    %IMAGE2 = uint16(abs(ifft2(Greg)));
    IMAGE(:,:,end+1) = imtranslate(IMAGE_TEMP(:,:),[XSHIFT(t), YSHIFT(t)]);
    IMAGE_TRACER(:,:,end+1) = imtranslate(IMAGE_TEMP_TRACER(:,:),[XSHIFT(t), YSHIFT(t)]);
    %figure();
    %imagesc(IMAGE2)
end

%% Crop and save


for t = 1:t_end
    [Y_SIZE, X_SIZE] = size(IMAGE(:,:,t));
    X1 = max([max(XSHIFT)+1,1]) ;
    Y1 = max([max(YSHIFT)+1,1]) ;
    X2 = min([X_SIZE+min(XSHIFT)-1 , X_SIZE-1]);
    Y2 = min([Y_SIZE+min(YSHIFT)-1 , Y_SIZE-1]);
    
    FINAL_IMAGE = imcrop(IMAGE(:,:,t),[X1 Y1 X2 Y2] ); 
    FINAL_IMAGE_TRACER = imcrop(IMAGE_TRACER(:,:,t),[X1 Y1 X2 Y2] ); 
    
    %save the image
    imwrite(FINAL_IMAGE,[BUNDLE_SAVE_PATH num2str(t,'%04.f') '.tif'],'tif');
    imwrite(FINAL_IMAGE_TRACER,[TRACER_SAVE_PATH num2str(t,'%04.f') '.tif'],'tif');
end
