%% Find TRACER MTS
function [MT_FRAME, MT_LENGTH, MT_ORIENT, MT_X, MT_Y] = FUNC_TracerFinder(TRACER_PATH,~,WIDTH,LENGTH)

%%WIDTH and LENGTH are the reference width and length of our generated MT
%%before convolution in pixels
%% OUTPUT :

MT_FRAME = [];
MT_LENGTH = [];
MT_ORIENT = [];
MT_X = [];
MT_Y = [];

FILES = dir([TRACER_PATH '\*.tif']);

plotting=0; %Engages plotting
t_end = length(FILES); 

for t = 1:t_end
    
    %% Get image and remove brightest pixels 
    IMAGE   =  imread([FILES(t).folder '\' FILES(t).name]);

    %Used for bright pixel removal%%%%%%%%%%%%%%%%
%     indices = abs(IMAGE)>MAX_PIX_VALUE; %Remove pixels brigher than some limit  %400 for 0 PEG
%     IMAGE(indices) = min(min(IMAGE)); %don't set them to 0, that's confusing
%     IMAGE = rescale(IMAGE);
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
  %  J = adapthisteq(IMAGE,'NumTiles',[round(length(IMAGE(:,1))/32) round(length(IMAGE(1,:))/32)]);
%  IMAGE = wiener2(IMAGE,[5 5]); %Blur
  %J = histeq(IMAGE);
    %IMAGE = adapthisteq(IMAGE,'Distribution','rayleigh','NumTiles',[round(length(IMAGE(:,1))/32) round(length(IMAGE(1,:))/32)]);
    %IMAGE = adapthisteq(IMAGE,'NumTiles',[round(length(IMAGE(:,1))/32) round(length(IMAGE(1,:))/32)]);
  %  IMAGE = adapthisteq(IMAGE);
%imshow(J, [50 250]);
    
    %% Convolve the image with MTs to try and get a better image.
        %At bin 2, a MT is ~5 pixels wide, with a halfwidth of about 2 pixels
    ANGULAR_RESOLUTION = 20;
    BOUNDING_BOX_SIZE = round(LENGTH*2);
    TEMPLATES = FUNC_Generate_2DGauss(BOUNDING_BOX_SIZE, WIDTH, LENGTH, ANGULAR_RESOLUTION);
    
    %correlate and binarize each angle
    for aa = 1:length(TEMPLATES(1,1,:))
        TEMP_CORR = normxcorr2(TEMPLATES(:,:,aa),IMAGE);
        TEMP_CORR = TEMP_CORR((BOUNDING_BOX_SIZE/2):(end-(BOUNDING_BOX_SIZE/2)), ...
            (BOUNDING_BOX_SIZE/2):(end-(BOUNDING_BOX_SIZE/2)));
        
        %TEMP_CORR = wiener2(TEMP_CORR,[2 2]); %Blur
        U16_CROSS_CORR = uint16((65535/2)*(TEMP_CORR+1) );
        %THIS 0.35 IS NORMALLY 0.2, IF YOU ARE READING THIS, CHANGE IT
        %BACK!! IT's ONLY 0.35 FOR 1% PEG BECAUSE OF IMAGING ISSUES
        BINARY_temp(:,:,aa) = imbinarize(U16_CROSS_CORR,adaptthresh(U16_CROSS_CORR, 0.2));
        
       % imshow(BINARY_temp(:,:,aa));
    end
    
    BINARY = sum(BINARY_temp(:,:,:),3);
   
    if plotting==1
        figure;        colormap('gray'), imshow(BINARY);
    end

    % %Compute the area of connected component:
    CC = bwconncomp(BINARY);
    S = regionprops(CC, 'Area');
    %Remove >2000 and <50 pixel objects:
    L = labelmatrix(CC);
    BINARY = ismember(L, find(  [S.Area] >= 20  &  [S.Area] <= 3000   )   );
    CC = bwconncomp(BINARY);
    S = regionprops(CC, 'centroid','MajorAxisLength','Orientation','MinorAxisLength');
    
    % Remove data from S if it's not microtubule shaped
    remove = [];
    for q = 1:length([S.MajorAxisLength])
        if S(q).MajorAxisLength < 4*S(q).MinorAxisLength    %%Selects for "length to width ratio"
                %    TRACER_DATA(q,:) = [];
           remove = [remove q];
        end
    end
    S(remove) = [];
 
    if plotting==1       
        %plot the extracted info over the image
        %autocontrast scale the image
        imcontrastscale(1)=min(min(IMAGE));
        imcontrastscale(2)=mean(mean(IMAGE))*2;
        
        %Plot Centroids and Sticks and Ellipses
        order=10;
        phi = linspace(0,2*pi,50); cosphi = cos(phi); sinphi = sin(phi);
        figure1 = figure('color',[1 1 1]);
        colormap ('gray'), imshow(IMAGE,imcontrastscale);
        hold on
        for k = 1:length(S)
            %Dot
        scatter(S(k).Centroid(1),S(k).Centroid(2),'filled');
        %Stick
        x1 = S(k).Centroid(1) + cos(deg2rad(pi-S(k).Orientation)).*order;
        y1 = S(k).Centroid(2) + sin(deg2rad(pi-S(k).Orientation)).*order;
        x2 = S(k).Centroid(1) - cos(deg2rad(pi-S(k).Orientation)).*order;
        y2 = S(k).Centroid(2) - sin(deg2rad(pi-S(k).Orientation)).*order;
        plot([x1 x2], [y1 y2], 'LineWidth',2, 'color','r');
         %Ellipse
        xbar = S(k).Centroid(1);  ybar = S(k).Centroid(2);
            a = S(k).MajorAxisLength/2;   b = S(k).MinorAxisLength/2;  theta = pi*S(k).Orientation/180;
            R = [ cos(theta)   sin(theta)
                -sin(theta)   cos(theta)];
            xy = [a*cosphi; b*sinphi];  xy = R*xy;
            x = xy(1,:) + xbar;  y = xy(2,:) + ybar;
            plot(x,y,'r','LineWidth',2);
        end
        hold off
        pause
    end
    
    % Store the rest of the Data
    MT_FRAME = [MT_FRAME; t*ones(length(S),1)];
    for k = 1:length(S)
        MT_LENGTH(end+1) = S(k).MajorAxisLength;
        MT_ORIENT(end+1) = deg2rad(S(k).Orientation); %convert to radians   
        MT_X(end+1) = S(k).Centroid(1);
        MT_Y(end+1) = S(k).Centroid(2);
%         BEZ_LENGTH = [BEZ_LENGTH; S(k).MajorAxisLength];
%         BEZ_ORIENT = [BEZ_ORIENT; deg2rad(S(k).Orientation)]; %convert to radians   
%         BEZ_X = [BEZ_X; S(k).Centroid(1)];
%         BEZ_Y = [BEZ_Y; S(k).Centroid(2)];
    end
end

end