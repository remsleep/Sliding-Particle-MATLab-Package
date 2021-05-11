function Edited_BinInterframeRodPairDetails2(directory)


%% Input Settings.  Simplified. 
%directory='G:\Linnea\Data_Acquisition_2\2016_08_05\Neo_2bin_100x_300msexp_1sint_25uMATP_1';



BinWidth=16; % Width of the Box in pixels. 

Vwidth=0.005; %pixels/frame  %making this small is best.
%Since the velocities can range from 0 to infinity, select a cap which is
%much larger than the largest velocities. Usually, eyball the largest
%velocity in the sample and then multiply by 2 or 4 or something.
MaxV=70; % in pixels/frame.

% Select a Minimum alignment angle. This is the degree to which two rods
% must be pointing along the same direction.  Make this very small to
% restric the analysis to algined mono-domains in the nematic and ignore
% regions of high bend.
anglecut=pi/20;

FrameData=[0 Inf];  %First and last frame to find data for. In Frame #.


%For plotting 
InterpStep = 15 ; %(in um)
MaxInterpDimension = 200; %(in um) width of the Interpolated pretty plot in um.

%Quiver w/ inputs of dual X/Y coordinates gives a warning. Kill it here.
w = warning ('off','all');
%warning(w);

%% Set Filenames and directories
analysisdir=strcat(directory,'');
datastorename=strcat(analysisdir,'\LinneaOgVelPairs_unscaled_forLinneaBinScript_unflippedVels.csv');
savename2=strcat(analysisdir,'');

%delete the old analysis.mat file (NOT CSV) in case of appending.
if exist(savename2,'file')==2 ;
    delete(savename2);
end

%Load old settings.  This should contain the imsize and other needed parts.
% load(strcat(directory,'\Particle_Tracking_Settings.mat'));
imsize = 1280;
% timestep = 1;
% PixCal = 1;
timestep = 0.35;
PixCal = 6.5*2/100;

%make datastore out of the analysis data.
ds=datastore(datastorename);
DatastoreInfo = dir(datastorename);

% enable all the data in datastore.
ds.SelectedVariableNames = {'Rsep','RelAngle', 'DeltaA', 'Vx','Vy','time'};
reset(ds); 

%% Make Bin edges for the histogramming.

%XY Coordinate BINS
%I want the bins to include zero as an edge, so do it this way:
diagsize = sqrt( max(imsize)^2 + max(imsize)^2 ) + BinWidth; %largest possible image size, plus an extra bin width for good measure.
edgesXY =  [  -1.*fliplr( [BinWidth : BinWidth : diagsize]) , 0 , BinWidth : BinWidth : diagsize ];

%Bin Center coordinates for plotting. Add 1/2 the bin width as histogram
%input uses bin edges. These are also symetric
Y= repmat(edgesXY, size(edgesXY,2) , 1) + (BinWidth/2) ;
X=Y';
%Try without using bin centers.
%Y= repmat(edgesXY, size(edgesXY,2) , 1) ;
%X=Y';

%Velocity Coordinate BINS
edgesV = [  -1.*fliplr([Vwidth: Vwidth: MaxV]) , 0 , Vwidth: Vwidth: MaxV ];
%Again the histograming uses edges, but I think averages should have bin
%centers, so divide the width/2 and add it to the edge array.
 V=edgesV + (Vwidth/2);
%Try without using bin centers.
%V=edgesV ;

%set up empty arrays for binning and finding linear coordinates.
VxArray = zeros( size(edgesXY,2) , size(edgesXY,2) , size(edgesV,2) );
VyArray = VxArray;
VxArray_E = VxArray;
VyArray_E = VxArray;
VxArray_C = VxArray;
VyArray_C = VxArray;

%Find the index of where the XY positions go from negative to positive.
% 1:neg are indecies of the negative sort.
% pos: end are indecies of positive sort.
pos=ceil(size(X,1)/2)  ;  %Positive values
neg=floor(size(X,1)/2) ;  %Negative Values.
rmax=1; %set how far out to plot flow field
XYend= (pos+neg-rmax);
% XYend= (pos+neg-10);

%And for the V array positions:
Vpos=ceil(size(V,2)/2)  ;  %Positive values
Vneg=floor(size(V,2)/2) ;  %Negative Values.
Vend= size(V,2);


%%
MTsVsTime=[]; RatioVsTime=[]; iteration=0;
h = waitbar(0,'Binning Rod Data');  %initiate waitbar.
while hasdata(ds);
    %%
    data=[]; info=[]; bins=[]; iteration=iteration+1;
    [data ,info]= read(ds);
    waitbar(info.Offset/DatastoreInfo.bytes,h);  %PROGRESS BAR INFO.
    
    
    %%FILTER DATA based on deltaA.
    %badA=find(data.DeltaA < pi/8 );
    badA=find(data.DeltaA > anglecut );
    data(badA,:)=[];
    
    %%FILTER DATA based on velocity out of range..
    badV=find( data.Vx < -MaxV | data.Vx > MaxV | data.Vy < -MaxV | data.Vy > MaxV );
    data(badV,:)=[];
    
    %%FILTER DATA based on time.
    badT=find(data.time < FrameData(1) | data.time > FrameData(2));
    data(badT,:)=[];
    
   
    %Put leftover data into cartesian coords.
    [Xpos,Ypos] = pol2cart( data.RelAngle , data.Rsep );
    
    %Find the bin number (array coordinate)
    [~,~,binx] = histcounts( Xpos , edgesXY );
    [~,~,biny] = histcounts( Ypos , edgesXY );
    [~,~,binvx] = histcounts(data.Vx,edgesV);
    [~,~,binvy] = histcounts(data.Vy,edgesV);
    bins=[binx,biny,binvx,binvy];
    
    %Convert all of the indices to linear indices.
    %The X an Y positions are the Rsep and RelAngle index.
    %The Vx or the Vy index is the 3rd dimension.
    linearIndVx = sub2ind( size(VxArray) , bins(:,1) , bins(:,2) , bins(:,3)); %X Vels
    linearIndVy = sub2ind( size(VyArray) , bins(:,1) , bins(:,2) , bins(:,4)); %Y Vels
    
    %Do the binning for the NET.
    for i=1:size(linearIndVx,1);
        VxArray(linearIndVx(i))=VxArray(linearIndVx(i))+1; %Bin Xs
        VyArray(linearIndVy(i))=VyArray(linearIndVy(i))+1; %Bin Ys
    end
    
    
    %% Sort the CONTRACTILE and EXTENSILE MT pairs.
    [row_E] = [...
        find( (bins(:,1) >= pos ) & (bins(:,3) >= Vpos) ) ; ...
        find( (bins(:,1) <= neg ) & (bins(:,3) <= Vneg) ) ];
    
    [row_C] = [...
        find( (bins(:,1) >= pos ) & (bins(:,3) <= Vneg) ) ; ...
        find( (bins(:,1) <= neg ) & (bins(:,3) >= Vpos) ) ];
    
    %Convert all of the indices to linear indices.
    linearIndVx_E = sub2ind( size(VxArray) , bins(row_E,1) , bins(row_E,2) , bins(row_E,3)); %X Vels
    linearIndVy_E = sub2ind( size(VyArray) , bins(row_E,1) , bins(row_E,2) , bins(row_E,4)); %Y Vels
    linearIndVx_C = sub2ind( size(VxArray) , bins(row_C,1) , bins(row_C,2) , bins(row_C,3)); %X Vels
    linearIndVy_C = sub2ind( size(VyArray) , bins(row_C,1) , bins(row_C,2) , bins(row_C,4)); %Y Vels
    
    %Do the binning for the Extensile.
    for i=1:size(linearIndVx_E,1);
        VxArray_E(linearIndVx_E(i))=VxArray_E(linearIndVx_E(i))+1; %Bin Xs
        VyArray_E(linearIndVy_E(i))=VyArray_E(linearIndVy_E(i))+1; %Bin Ys
    end
    %Do the binning for the Contractile.
    for i=1:size(linearIndVx_C,1);
        VxArray_C(linearIndVx_C(i))=VxArray_C(linearIndVx_C(i))+1; %Bin Xs
        VyArray_C(linearIndVy_C(i))=VyArray_C(linearIndVy_C(i))+1; %Bin Ys
    end
    
    
    %%
    
    %Rough metric of the number of MT pairs vs time.
    MTsVsTime(iteration,1:2)=[ median(data.time)  size(Xpos,1)/(1+max(data.time)-min(data.time)) ];
    
    %Find the ratio of the number of extending vs contracting rods at each
    %data load.
    RatioVsTime(iteration,1:2)=[ min(data.time)  size(linearIndVx_E,1)/(size(linearIndVx_E,1)+size(linearIndVx_C,1)) ];
    
    
    %%
    
end

%% Make Weighted averages from the raw velocity distributions.

Vx=[]; Vy=[]; Counts=[]; %THE NET field
Vx_C=[]; Vy_C=[]; Counts_C=[]; %JUST CONTRACTILE
Vx_E=[]; Vy_E=[]; Counts_E=[]; %JUST EXTENSILE



%Make Weighted averages. This part cycles through each XY coordinate on the
%VxArray and finds a weighted average from the 3rd Dimension velocity
%distribution.
for i=1:size(edgesXY ,2); %X dimension
    for j=1:size(edgesXY ,2); % Y dimension
        
        X_dist = reshape( VxArray(i,j,:) , 1 , [] ) ;
        Y_dist = reshape( VyArray(i,j,:) , 1 , [] ) ;
        
        %Make Weighted averages.
        Vx(i,j)= nansum( X_dist.*V ) / nansum( X_dist )  ;
        Vy(i,j)= nansum( Y_dist.*V ) / nansum( Y_dist )  ;
        %Sum of the rod pairs counted at each XY position.
        Counts(i,j)=nansum(X_dist);
        
        
        %EXTENSILE
        X_dist_E = reshape( VxArray_E(i,j,:) , 1 , [] ) ;
        Y_dist_E = reshape( VyArray_E(i,j,:) , 1 , [] ) ;
        
        %Make Weighted averages.
        Vx_E(i,j)= nansum( X_dist_E.*V ) / nansum( X_dist_E )  ;
        Vy_E(i,j)= nansum( Y_dist_E.*V ) / nansum( Y_dist_E )  ;
        %Sum of the rod pairs counted at each XY position.
        Counts_E(i,j)=nansum(X_dist_E);
        
        %CONTRACTILE
        X_dist_C = reshape( VxArray_C(i,j,:) , 1 , [] ) ;
        Y_dist_C = reshape( VyArray_C(i,j,:) , 1 , [] ) ;
        
        %Make Weighted averages.
        Vx_C(i,j)= nansum( X_dist_C.*V ) / nansum( X_dist_C )  ;
        Vy_C(i,j)= nansum( Y_dist_C.*V ) / nansum( Y_dist_C )  ;
        %Sum of the rod pairs counted at each XY position.
        Counts_C(i,j)=nansum(X_dist_C);
        
    end
end

N_Extending = nansum(nansum(Counts_E));
N_Contracting = nansum(nansum(Counts_C));

ratio=Counts_E./Counts;



RatioExtending = N_Extending / nansum(N_Extending,N_Contracting);
disp(strcat('Ratio of Extending MT Pairs is :' , num2str(RatioExtending*100), ' %'));

%% Convert everything from pixels/frame to um/s

MTsVsTime(:,1)=MTsVsTime(:,1).*timestep;

X= X.*PixCal;
Y= Y.*PixCal;
Vx = Vx.*(PixCal/timestep);
Vy = Vy.*(PixCal/timestep);
Vx_E = Vx_E.*(PixCal/timestep); Vx_C = Vx_C.*(PixCal/timestep);
Vy_E = Vy_E.*(PixCal/timestep); Vy_C = Vy_C.*(PixCal/timestep);


%%

close(h) ;

%% Plot the raw, un averaged flow field.

figure1 = figure('Color',[1 1 1]);
pcolor(X,Y,Counts);
colormap(parula);
shading interp ;
hold on
quiver( X, Y, Vx, Vy ,'AutoScaleFactor',3,'LineWidth',1.5,'color',[1 1 1]) ;
title('Raw Velocity Field + Counts')
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Distance, R (um)','FontSize',22);
colorbar
set(gca,'FontSize',16)


figure2 = figure('Color',[1 1 1]);

subplot(1,2,1)
pcolor(X,Y,Counts_E);
colormap(parula);
shading interp ;
hold on
quiver( X, Y, Vx_E, Vy_E ,'AutoScaleFactor',3,'LineWidth',1.5,'color',[1 1 1]) ;
title('Raw Extensile')
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Distance, R (um)','FontSize',22);
colorbar
set(gca,'FontSize',16)

subplot(1,2,2)
pcolor(X,Y,Counts_C);
colormap(parula);
shading interp ;
hold on
quiver( X, Y, Vx_C, Vy_C ,'AutoScaleFactor',3,'LineWidth',1.5,'color',[1 1 1]) ;
title('Raw Contractile')
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Distance, R (um)','FontSize',22);
colorbar
set(gca,'FontSize',16)




%% Average the NET data into the 1st quadrant.

%quad 1
q1_X =   X( pos:XYend, pos:XYend);
q1_Y =   Y( pos:XYend, pos:XYend);
q1_Vx = Vx( pos:XYend, pos:XYend);
q1_Vy = Vy( pos:XYend, pos:XYend);
q1_C=Counts( pos:XYend, pos:XYend);

%quad 2

% q2_Vx =  flipud( Vx( 1:neg, pos:XYend) .* -1)  ;
% q2_Vy =  flipud( Vy( 1:neg, pos:XYend));
% q2_C=    flipud(Counts( 1:neg, pos:XYend));
q2_Vx =  flipud( Vx( rmax:neg, pos:XYend) .* -1)  ;
q2_Vy =  flipud( Vy( rmax:neg, pos:XYend));
q2_C=    flipud(Counts( rmax:neg, pos:XYend));
%quad 3

% q3_Vx = rot90( Vx( 1:neg, 1:neg)  .* -1 ,2) ;
% q3_Vy = rot90( Vy( 1:neg, 1:neg)  .* -1 ,2) ;
% q3_C=   rot90( Counts( 1:neg, 1:neg) ,2);
q3_Vx = rot90( Vx( rmax:neg, rmax:neg)  .* -1 ,2) ;
q3_Vy = rot90( Vy( rmax:neg, rmax:neg)  .* -1 ,2) ;
q3_C=   rot90( Counts( rmax:neg, rmax:neg) ,2);
%quad 4

% q4_Vx = fliplr( Vx( pos:XYend, 1:neg) );
% q4_Vy = fliplr( Vy( pos:XYend, 1:neg)  .* -1) ;
% q4_C=   fliplr(Counts( pos:XYend, 1:neg) );
q4_Vx = fliplr( Vx( pos:XYend, rmax:neg) );
q4_Vy = fliplr( Vy( pos:XYend, rmax:neg)  .* -1) ;
q4_C=   fliplr(Counts( pos:XYend, rmax:neg) );
%Weighted average of quadrants all in mirrored and folded into Quad1:
q1_netC = ( q1_C + q2_C + q3_C + q4_C ) ;
q1_netVx =  ( q1_Vx.*q1_C  + q2_Vx.*q2_C + q3_Vx.*q3_C + q4_Vx.*q4_C ) ./ q1_netC ;
q1_netVy =  ( q1_Vy.*q1_C  + q2_Vy.*q2_C + q3_Vy.*q3_C + q4_Vy.*q4_C ) ./ q1_netC ;


%% Average the EXTENSILE data into the 1st quadrant.
%quad 1
q1_X_E =   X( pos:XYend, pos:XYend);
q1_Y_E =   Y( pos:XYend, pos:XYend);
q1_Vx_E = Vx_E( pos:XYend, pos:XYend);
q1_Vy_E = Vy_E( pos:XYend, pos:XYend);
q1_C_E=Counts_E( pos:XYend, pos:XYend);
%quad 2

% q2_Vx_E =  flipud( Vx_E( 1:neg, pos:XYend) .* -1)  ;
% q2_Vy_E =  flipud( Vy_E( 1:neg, pos:XYend));
% q2_C_E=    flipud(Counts_E( 1:neg, pos:XYend));
q2_Vx_E =  flipud( Vx_E( rmax:neg, pos:XYend) .* -1)  ;
q2_Vy_E =  flipud( Vy_E( rmax:neg, pos:XYend));
q2_C_E=    flipud(Counts_E( rmax:neg, pos:XYend));
%quad 3
%flip X & Y velocities

% q3_Vx_E = rot90( Vx_E( 1:neg, 1:neg)  .* -1 ,2) ;
% q3_Vy_E = rot90( Vy_E( 1:neg, 1:neg)  .* -1 ,2) ;
% q3_C_E=   rot90( Counts_E( 1:neg, 1:neg) ,2);

q3_Vx_E = rot90( Vx_E( rmax:neg, rmax:neg)  .* -1 ,2) ;
q3_Vy_E = rot90( Vy_E( rmax:neg, rmax:neg)  .* -1 ,2) ;
q3_C_E=   rot90( Counts_E( rmax:neg, rmax:neg) ,2);
%quad 4
%flip Y velocities.

% q4_Vx_E = fliplr( Vx_E( pos:XYend, 1:neg) );
% q4_Vy_E = fliplr( Vy_E( pos:XYend, 1:neg)  .* -1) ;
% q4_C_E=   fliplr(Counts_E( pos:XYend, 1:neg) );
q4_Vx_E = fliplr( Vx_E( pos:XYend, rmax:neg) );
q4_Vy_E = fliplr( Vy_E( pos:XYend, rmax:neg)  .* -1) ;
q4_C_E=   fliplr(Counts_E( pos:XYend, rmax:neg) );
%Weighted average of quadrents all in mirrored and folded into Quad1:
q1_netC_E = ( q1_C_E + q2_C_E + q3_C_E + q4_C_E ) ;
q1_netVx_E =  ( q1_Vx_E.*q1_C_E  + q2_Vx_E.*q2_C_E + q3_Vx_E.*q3_C_E + q4_Vx_E.*q4_C_E ) ./ q1_netC_E ;
q1_netVy_E =  ( q1_Vy_E.*q1_C_E  + q2_Vy_E.*q2_C_E + q3_Vy_E.*q3_C_E + q4_Vy_E.*q4_C_E ) ./ q1_netC_E ;


%% Average the Contractile data into the 1st quadrant.
%quad 1
q1_X_C =   X( pos:XYend, pos:XYend);
q1_Y_C =   Y( pos:XYend, pos:XYend);
q1_Vx_C = Vx_C( pos:XYend, pos:XYend);
q1_Vy_C = Vy_C( pos:XYend, pos:XYend);
q1_C_C=Counts_C( pos:XYend, pos:XYend);
%quad 2
%flip X velocities.

% q2_Vx_C =  flipud( Vx_C( 1:neg, pos:XYend) .* -1)  ;
% q2_Vy_C =  flipud( Vy_C( 1:neg, pos:XYend));
% q2_C_C=    flipud(Counts_C( 1:neg, pos:XYend));
q2_Vx_C =  flipud( Vx_C( rmax:neg, pos:XYend) .* -1)  ;
q2_Vy_C =  flipud( Vy_C( rmax:neg, pos:XYend));
q2_C_C=    flipud(Counts_C( rmax:neg, pos:XYend));
%quad 3
%flip X & Y velocities

% q3_Vx_C = rot90( Vx_C( 1:neg, 1:neg)  .* -1 ,2) ;
% q3_Vy_C = rot90( Vy_C( 1:neg, 1:neg)  .* -1 ,2) ;
% q3_C_C=   rot90( Counts_C( 1:neg, 1:neg) ,2);
q3_Vx_C = rot90( Vx_C( rmax:neg, rmax:neg)  .* -1 ,2) ;
q3_Vy_C = rot90( Vy_C( rmax:neg, rmax:neg)  .* -1 ,2) ;
q3_C_C=   rot90( Counts_C( rmax:neg, rmax:neg) ,2);
%quad 4
%flip Y velocities.

% q4_Vx_C = fliplr( Vx_C( pos:XYend, 1:neg) );
% q4_Vy_C = fliplr( Vy_C( pos:XYend, 1:neg)  .* -1) ;
% q4_C_C=   fliplr(Counts_C( pos:XYend, 1:neg) );
q4_Vx_C = fliplr( Vx_C( pos:XYend, rmax:neg) );
q4_Vy_C = fliplr( Vy_C( pos:XYend, rmax:neg)  .* -1) ;
q4_C_C=   fliplr(Counts_C( pos:XYend, rmax:neg) );

%Weighted average of quadrants all in mirrored and folded into Quad1:
q1_netC_C = ( q1_C_C + q2_C_C + q3_C_C + q4_C_C ) ;
q1_netVx_C =  ( q1_Vx_C.*q1_C_C  + q2_Vx_C.*q2_C_C + q3_Vx_C.*q3_C_C + q4_Vx_C.*q4_C_C ) ./ q1_netC_C ;
q1_netVy_C =  ( q1_Vy_C.*q1_C_C  + q2_Vy_C.*q2_C_C + q3_Vy_C.*q3_C_C + q4_Vy_C.*q4_C_C ) ./ q1_netC_C ;


%% Plot the averaged flow field in Quadrant 1.

figure3 = figure('Color',[1 1 1]);
quiver( q1_X, q1_Y, q1_netVx, q1_netVy, 2)
title('Averaged Velocity Field - 1st Quadrant')
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Distance, R (um)','FontSize',22);
set(gca,'FontSize',16)

figure4 = figure('Color',[1 1 1]);

subplot(1,2,1)
quiver( q1_X, q1_Y, q1_netVx_E, q1_netVy_E, 2)
title('Quad 1 - Extensile')
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Distance, R (um)','FontSize',22);
colorbar
set(gca,'FontSize',16)

subplot(1,2,2)
quiver( q1_X, q1_Y, q1_netVx_C, q1_netVy_C, 2)
title('Quad 1 - Contractile')
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Distance, R (um)','FontSize',22);
colorbar
set(gca,'FontSize',16)



%% Measure the perpendicular and parallel flow field.
% From the 1st Quadrant average.

%NET
par_X = q1_X(:,1);
par_Vx = q1_netVx(:,1);
perp_Y = q1_Y(1,:);
perp_Vy = q1_netVy(1,:);

%EXTENSILE
par_X_E = q1_X_E(:,1);
par_Vx_E = q1_netVx_E(:,1);
perp_Y_E = q1_Y_E(1,:);
perp_Vy_E = q1_netVy_E(1,:);
%CONTRACTILE
par_X_C = q1_X_C(:,1);
par_Vx_C = q1_netVx_C(:,1);
perp_Y_C = q1_Y_C(1,:);
perp_Vy_C = q1_netVy_C(1,:);


figure5 = figure('Color',[1 1 1]);
hold on
plot(par_X, par_Vx,'linewidth',3)
plot(perp_Y, perp_Vy,'linewidth',2)
plot(par_X_E, par_Vx_E,'linewidth',2)
plot(par_X_C, par_Vx_C,'linewidth',2)
hold off
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Velocity (um/s)','FontSize',22);
legend({'Net Parallel Flow','Net Perpendicular Flow', 'EXTENSILE - Xprofile', 'CONTRACTILE - Xprofile'})
set(gca,'FontSize',16)


figure6 = figure('Color',[1 1 1]);
hold on
plot(par_X, par_Vx,'linewidth',3)
plot(perp_Y, perp_Vy,'linewidth',2)
plot(perp_Y_E, perp_Vy_E,'linewidth',2)
plot(perp_Y_C, perp_Vy_C,'linewidth',2)
hold off
% Create xlabel
xlabel('Distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Velocity (um/s)','FontSize',22);
legend({'Net Parallel Flow','Net Perpendicular Flow', 'EXTENSILE - Yprofile', 'CONTRACTILE -Yprofile'})
set(gca,'FontSize',16)

%% Make a full 360 degree Flow field from the 1st quadrant average.
%Do this by mirroring and flipping the net quad1 data back around.

%test:
% full_X = [rot90(q3_X ,2) , flipud(q2_X) ; fliplr(q4_X) , q1_X ];
% full_Y = [rot90(q3_Y ,2) , flipud(q2_Y) ; fliplr(q4_Y) , q1_Y ];

full_X = [rot90(q1_X ,2).*-1 , flipud(q1_X).*-1 ; fliplr(q1_X) , q1_X ];
full_Y = [rot90(q1_Y ,2).*-1 , flipud(q1_Y) ; fliplr(q1_Y).*-1 , q1_Y ];
full_C = [rot90(q1_netC ,2) , flipud(q1_netC) ; fliplr(q1_netC) , q1_netC ]; 
%flip the X and Y velocities where appropriate for the mirror
full_Vx = [rot90(q1_netVx ,2).*-1 , flipud(q1_netVx).*-1 ; fliplr(q1_netVx) , q1_netVx ]; 
full_Vy = [rot90(q1_netVy ,2).*-1 , flipud(q1_netVy) ; fliplr(q1_netVy).*-1 , q1_netVy ];

figure6 = figure('Color',[1 1 1]);
% pcolor(full_X,full_Y,full_C);
% colormap(parula);
% shading interp ;
% colorbar
hold on
quiver( full_X, full_Y, full_Vx , full_Vy, 'AutoScaleFactor',2,'LineWidth',1.5,'color',[0 0 0])
% Create xlabel
xlabel('Distance, R (pixels)','FontSize',22);
% Create ylabel
ylabel('Distance, R (pixels)','FontSize',22);
title('The Symmetric Mirrored Flow Field')
set(gca,'FontSize',16)

%extensile only
full_X_E = [rot90(q1_X_E ,2).*-1 , flipud(q1_X_E).*-1 ; fliplr(q1_X_E) , q1_X_E ];
full_Y_E = [rot90(q1_Y_E ,2).*-1 , flipud(q1_Y_E) ; fliplr(q1_Y_E).*-1 , q1_Y_E ];
full_C_E = [rot90(q1_netC_E ,2) , flipud(q1_netC_E) ; fliplr(q1_netC_E) , q1_netC_E ]; 
%flip the X and Y velocities where appropriate for the mirror
full_Vx_E = [rot90(q1_netVx_E ,2).*-1 , flipud(q1_netVx_E).*-1 ; fliplr(q1_netVx_E) , q1_netVx_E ]; 
full_Vy_E = [rot90(q1_netVy_E ,2).*-1 , flipud(q1_netVy_E) ; fliplr(q1_netVy_E).*-1 , q1_netVy_E ];

figure7 = figure('Color',[1 1 1]);
% pcolor(full_X,full_Y,full_C);
% colormap(parula);
% shading interp ;
% colorbar
hold on
quiver( full_X_E, full_Y_E, full_Vx_E , full_Vy_E, 'AutoScaleFactor',2,'LineWidth',1.5,'color',[0 0 0])
% Create xlabel
xlabel('Distance, R (pixels)','FontSize',22);
% Create ylabel
ylabel('Distance, R (pixels)','FontSize',22);
title('The Symmetric Mirrored Flow Field: Extensile')
set(gca,'FontSize',16)

%contractile only
full_X_C = [rot90(q1_X_C ,2).*-1 , flipud(q1_X_C).*-1 ; fliplr(q1_X_C) , q1_X_C ];
full_Y_C = [rot90(q1_Y_C ,2).*-1 , flipud(q1_Y_C) ; fliplr(q1_Y_C).*-1 , q1_Y_C ];
full_C_C = [rot90(q1_netC_C ,2) , flipud(q1_netC_C) ; fliplr(q1_netC_C) , q1_netC_C ]; 
%flip the X and Y velocities where appropriate for the mirror
full_Vx_C = [rot90(q1_netVx_C ,2).*-1 , flipud(q1_netVx_C).*-1 ; fliplr(q1_netVx_C) , q1_netVx_C ]; 
full_Vy_C = [rot90(q1_netVy_C ,2).*-1 , flipud(q1_netVy_C) ; fliplr(q1_netVy_C).*-1 , q1_netVy_C ];

figure8 = figure('Color',[1 1 1]);
% pcolor(full_X,full_Y,full_C);
% colormap(parula);
% shading interp ;
% colorbar
hold on
quiver( full_X_C, full_Y_C, full_Vx_C , full_Vy_C, 'AutoScaleFactor',2,'LineWidth',1.5,'color',[0 0 0])
% Create xlabel
xlabel('Distance, R (pixels)','FontSize',22);
% Create ylabel
ylabel('Distance, R (pixels)','FontSize',22);
title('The Symmetric Mirrored Flow Field: Contractile')
set(gca,'FontSize',16)

%% Clean up the flow field for plotting
% This part does two things:
% 1) it smooths over the roughness in the flow field.
% 2) it reduces the number of grid points for plotting.  Too many arrows on
% the vector field looks terrible in ppt.

[cleanX,cleanY] = meshgrid( [ -1.*fliplr([ InterpStep: InterpStep: MaxInterpDimension ]) , 0 , InterpStep: InterpStep: MaxInterpDimension] );

cleanVx = griddata(full_X ,full_Y,full_Vx,cleanX,cleanY,'cubic');
cleanVy = griddata(full_X ,full_Y,full_Vy,cleanX,cleanY,'cubic');

figure7 = figure('Color',[1 1 1]);
Speed=sqrt(cleanVx.^2 + cleanVy.^2);
pcolor(cleanX, cleanY, Speed)
colormap(jet)
shading interp
hold on
quiver(cleanX,cleanY,cleanVx,cleanVy,'AutoScaleFactor',1,'LineWidth',2,'color',[0 0 0])
colorbar
% Create xlabel
xlabel('Parallel Flow Axis (um)','FontSize',22);
% Create ylabel
ylabel('Perpendicular Flow Axis (um)','FontSize',22);
title('The Pretty Flow Field (Color = Speed)')
set(gca,'FontSize',16)


%extensile
%[cleanX,cleanY] = meshgrid( [ -1.*fliplr([ InterpStep: InterpStep: MaxInterpDimension ]) , 0 , InterpStep: InterpStep: MaxInterpDimension] );

cleanVx_E = griddata(full_X_E ,full_Y_E,full_Vx_E,cleanX,cleanY,'cubic');
cleanVy_E = griddata(full_X_E ,full_Y_E,full_Vy_E,cleanX,cleanY,'cubic');

figure7 = figure('Color',[1 1 1]);
Speed=sqrt(cleanVx_E.^2 + cleanVy_E.^2);
pcolor(cleanX, cleanY, Speed)
colormap(jet)
shading interp
hold on
quiver(cleanX,cleanY,cleanVx_E,cleanVy_E,'AutoScaleFactor',1,'LineWidth',2,'color',[0 0 0])
colorbar
% Create xlabel
xlabel('Parallel Flow Axis (um)','FontSize',22);
% Create ylabel
ylabel('Perpendicular Flow Axis (um)','FontSize',22);
title('The Pretty Flow Field (Color = Speed): Extensile')
set(gca,'FontSize',16)

%contractile
%[cleanX,cleanY] = meshgrid( [ -1.*fliplr([ InterpStep: InterpStep: MaxInterpDimension ]) , 0 , InterpStep: InterpStep: MaxInterpDimension] );

cleanVx_C = griddata(full_X_C ,full_Y_C,full_Vx_C,cleanX,cleanY,'cubic');
cleanVy_C = griddata(full_X_C ,full_Y_C,full_Vy_C,cleanX,cleanY,'cubic');

figure7 = figure('Color',[1 1 1]);
Speed=sqrt(cleanVx_C.^2 + cleanVy_C.^2);
pcolor(cleanX, cleanY, Speed)
colormap(jet)
shading interp
hold on
quiver(cleanX,cleanY,cleanVx_C,cleanVy_C,'AutoScaleFactor',1,'LineWidth',2,'color',[0 0 0])
colorbar
% Create xlabel
xlabel('Parallel Flow Axis (um)','FontSize',22);
% Create ylabel
ylabel('Perpendicular Flow Axis (um)','FontSize',22);
title('The Pretty Flow Field (Color = Speed): Contractile')
set(gca,'FontSize',16)


%% Measure the perpendicular and parallel flow fields FROM THE INTERPOLATED DATA
% This is from the interpolated data.

center = ceil(size(cleanX,1)/2);

par_X_interp = cleanX( center , center:size(cleanX,2) );
par_Vx_interp = cleanVx( center , center:size(cleanX,2) );

perp_Y_interp = cleanY( center:size(cleanY,1),  center);
perp_Vy_interp = cleanVy( center:size(cleanY,1), center );

% figure8 = figure('Color',[1 1 1]);
% plot(par_X_interp, par_Vx_interp,'linewidth',3)
% hold on
% plot(perp_Y_interp, perp_Vy_interp,'linewidth',2)
% hold off
% % Create xlabel
% xlabel('Distance, R (um)','FontSize',22);
% % Create ylabel
% ylabel('Velocity (um/s)','FontSize',22);
% legend({'Net Parallel Flow','Net Perpendicular Flow'})
% set(gca,'FontSize',16)



%% Measure the Flux out out
% This I actually don't know how to do easily in cartesian coordinates as I
% wind up integrating wrong.  So I do this in polar where rho is the ring
% size and theta marches around the ring in discreet steps.
%Make a new Grid with known polar coordinates. So first select the thata
%and rho. Pick a fine spacing just because I can. Do 1/2 the original bins
%selected at the start of the program (factor of 2).

thetaFlux=[ 0 : pi/20 : 2*pi ];
rhoFlux=[ InterpStep : InterpStep: MaxInterpDimension ]';

%Make a mesh grid of the polar coords.
thetaFlux=repmat(thetaFlux,size(rhoFlux,1),1);
rhoFlux=repmat(rhoFlux,1,size(thetaFlux,2));

%output X and Y coords for the fine polar grid.
[XFlux,YFlux] = pol2cart(thetaFlux,rhoFlux);

%Interpolate the averaged and folded data onto the new fine grid.
VxFlux=griddata(full_X,full_Y,full_Vx,XFlux,YFlux);
VyFlux=griddata(full_X,full_Y,full_Vy,XFlux,YFlux);

%calcuated the Flux (sum of the radial components of a circle at various rho).
PostFlux=[]; NormalVx2=[];
for blah=1:size(rhoFlux,1);
    NormalVx2 = VxFlux(blah,:).*cos(thetaFlux(1,:)) - VyFlux(blah,:).*sin(thetaFlux(1,:)) ;
    %NormalVy1 = meanVx(blah,:)'.*sin(theta(:,1)) + meanVy(blah,:)'.*cos(theta(:,1)) ;
    
    %This is the sum of the velocities perpendicular (radial) to the tangent of a
    %test circle at varying distance rho. In units of um/s /area.
    PostFlux(blah,1:2)= [ rhoFlux(blah,1) nansum(NormalVx2) ];
end

%Test the flow field is ok.
%quiver( XFlux,YFlux,VxFlux, VyFlux,2)

figure9 = figure('Color',[1 1 1]);
plot(PostFlux(:,1),PostFlux(:,2),'LineWidth',3)
hold off
% Create xlabel
xlabel('Radial distance, R (um)','FontSize',22);
% Create ylabel
ylabel('Flux (1/(um*s)','FontSize',22);
title('Flux vs Radius')
set(gca,'FontSize',16)


%% Other stuff


figure10 = figure('Color',[1 1 1]);

subplot(1,2,1)
plot( MTsVsTime(:,1), MTsVsTime(:,2),'LineWidth',2)
% Create xlabel
xlabel('time (s)','FontSize',22);
% Create ylabel
ylabel('# MT pairs tracked','FontSize',22);
title('#MTs tracked vs Time');
set(gca,'FontSize',16)

subplot(1,2,2)
%figure11 = figure('Color',[1 1 1]);
plot( RatioVsTime(:,1), RatioVsTime(:,2),'LineWidth',2)
ylim([0 1])
% Create xlabel
xlabel('time (s)','FontSize',22);
% Create ylabel
ylabel('Ratio of Extensile vs Contractile','FontSize',22);
title('Extensile Ratio');
set(gca,'FontSize',16)



%%  SAVE ALL THE DATA.
w = warning ('on','all');
save(savename2);

% ATPs1 = [1, 2.5, 5, 10, 18, 25, 50, 75, 100, 150, 250, 500, 750, 1000, 1500, 2000];
% ATPs2 = [1,10,100,2,20,200,3,30,300,4,40,400,5,50,500,6];
% m=find(ATPs1==ATP);
% savename3=strcat('G:\Linnea\FilamentSliding_ATP_Data\new_batch\CalcRelVel2\Vx','Analysis_',num2str(ATPs2(m)));%location and format for plotting multiple ATPs
% save(savename3);
% clc; 
% clc; 
%clo

disp('complete');




















