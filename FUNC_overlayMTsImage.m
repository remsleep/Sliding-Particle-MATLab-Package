function [] = FUNC_overlayMTsImage(MTs, IMAGE)
%%This function plots all microtubules with coordinates, sizes, and 
%%orientations stored in the MTS structure (with fields Centroid, 
%%MajorAxisLength, MinorAxisLength, and Orientation) over IMAGE. SAVE_DATA
%%is a boolean that triggers file saving: 1 to save files, 0 to not save.
%%IMAGE can also be a string containing the directory of the exact file to
%%be loaded.

    %Check number of arguments
    if isa(IMAGE, 'string')
        IMAGE = imload(IMAGE);
    end
    
    %plot the extracted info over the image
    %autocontrast scale the image
    imcontrastscale(1)=min(min(IMAGE));
    imcontrastscale(2)=mean(mean(IMAGE))*2;

    %Plot Centroids and Sticks and Ellipses
    order=10;
    phi = linspace(0,2*pi,50); cosphi = cos(phi); sinphi = sin(phi);
    colormap ('gray'), imagesc(IMAGE);
    hold on
    
    %Iterate through each microtubule in MTs
    for currMT = 1:length(MTs)
        %Plot line along semimajor axis
        x1 = MTs(currMT).Centroid(1) + cos(deg2rad(pi-MTs(currMT).Orientation)).*order;
        y1 = MTs(currMT).Centroid(2) + sin(deg2rad(pi-MTs(currMT).Orientation)).*order;
        x2 = MTs(currMT).Centroid(1) - cos(deg2rad(pi-MTs(currMT).Orientation)).*order;
        y2 = MTs(currMT).Centroid(2) - sin(deg2rad(pi-MTs(currMT).Orientation)).*order;
        plot([x1 x2], [y1 y2], 'LineWidth',2, 'color','r');
        %Plot Ellipse indicating orientation, semimajor, and semiminor axes
        xbar = MTs(currMT).Centroid(1);  ybar = MTs(currMT).Centroid(2);
        a = MTs(currMT).MajorAxisLength/2;   b = MTs(currMT).MinorAxisLength/2;
        theta = pi*MTs(currMT).Orientation/180;
        R = [ cos(theta)   sin(theta)           % x-axis parallel, y-axis is perp.
            -sin(theta)   cos(theta)];
        xy = [a*cosphi; b*sinphi];  xy = R*xy;
        x = xy(1,:) + xbar;  y = xy(2,:) + ybar;
        plot(x,y,'r','LineWidth',2);
    end
    hold off
    
end