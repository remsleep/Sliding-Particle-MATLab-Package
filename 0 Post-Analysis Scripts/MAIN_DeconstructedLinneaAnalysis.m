function MAIN_DeconstructedLinneaAnalysis(directory)


%% Input Settings.  Simplified. 

BinWidth=100; % Width of the Box in pixels. 

Vwidth=0.005; %pixels/frame  %making this small is best.
%Since the velocities can range from 0 to infinity, select a cap which is
%much larger than the largest velocities. Usually, eyball the largest
%velocity in the sample and then multiply by 2 or 4 or something.
MaxV=70; % in pixels/frame.

reducedV = -10:.1:10;

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

%% Set Filenames and directories
analysisdir=strcat(directory,'');
datastorename=strcat(analysisdir,'\LinneaOgFirst500_unscaled_copy.csv');
savename2=strcat(analysisdir,'');

%delete the old analysis.mat file (NOT CSV) in case of appending.
if exist(savename2,'file')==2 
    delete(savename2);
end

%Load old settings.  This should contain the imsize and other needed parts.
% load(strcat(directory,'\Particle_Tracking_Settings.mat'));
imsize = 1280;
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
while hasdata(ds)
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
    for i=1:size(linearIndVx,1)
        VxArray(linearIndVx(i))=VxArray(linearIndVx(i))+1; %Bin Xs
        VyArray(linearIndVy(i))=VyArray(linearIndVy(i))+1; %Bin Ys
    end
    
    
    %%
    
    %Rough metric of the number of MT pairs vs time.
    MTsVsTime(iteration,1:2)=[ median(data.time)  size(Xpos,1)/(1+max(data.time)-min(data.time)) ];
%     
%     %Find the ratio of the number of extending vs contracting rods at each
%     %data load.
%     RatioVsTime(iteration,1:2)=[ min(data.time)  size(linearIndVx_E,1)/(size(linearIndVx_E,1)+size(linearIndVx_C,1)) ];
    
end

%% Make Weighted averages from the raw velocity distributions.

Vx=[]; Vy=[]; Counts=[]; %THE NET field

%Make Weighted averages. This part cycles through each XY coordinate on the
%VxArray and finds a weighted average from the 3rd Dimension velocity
%distribution.
for i=1:size(edgesXY ,2) %X dimension
    for j=1:size(edgesXY ,2) % Y dimension
        
        X_dist = reshape( VxArray(i,j,:) , 1 , [] ) ;
        Y_dist = reshape( VyArray(i,j,:) , 1 , [] ) ;
        
        %Make Weighted averages.
        Vx(i,j)= nansum( X_dist.*V ) / nansum( X_dist )  ;
        Vy(i,j)= nansum( Y_dist.*V ) / nansum( Y_dist )  ;
        %Sum of the rod pairs counted at each XY position.
        Counts(i,j)=nansum(X_dist);
        
    end
end


%% Convert everything from pixels/frame to um/s

MTsVsTime(:,1)=MTsVsTime(:,1).*timestep;

X= X.*PixCal;
Y= Y.*PixCal;
Vx = Vx.*(PixCal/timestep);
Vy = Vy.*(PixCal/timestep);

%%

close(h) ;


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

%% Unflipped velocities
VParAxis = squeeze(sum(VxArray(10:29,19:20,:),2));
% regionEdges = X(20:29,1);
figure
hold on
for index = size(VParAxis,1)/2:-1:1
    
    currCounts = VParAxis(index,:) + VParAxis(end-index+1,:);   %should be even
    scatter(-V*PixCal/timestep, currCounts,'filled');
%     index
%     20-index+1
end

figure
hold on

[~,~,reducedBinInds] = histcounts(-V*PixCal/timestep,reducedV);
redBinVals = unique(reducedBinInds);
for index = size(VParAxis,1)/2:-1:1
    
    rebinnedCounts = zeros(numel(redBinVals),1);
    currCounts = VParAxis(index,:) + VParAxis(end-index+1,:);   %should be even
    for currSuperBin = 1:numel(redBinVals)
        
        rebinnedCounts(currSuperBin) = sum(currCounts(reducedBinInds == currSuperBin));
    end

    scatter(reducedV, rebinnedCounts,'filled');
    
end
    
%% Flipped velocities
VParAxis = squeeze(sum(VxArray(10:29,19:20,:),2));
regionVals = q1_X(1:10,1);
mirrorV = V((end/2 + 1):end);

% regionEdges = X(20:29,1);
figure
hold on
for index = size(regionVals,1):-1:1
    
    currCountsNeg = VParAxis(index,:);
    currCountsPos = VParAxis(end-index+1,:);
    currCounts = fliplr(currCountsNeg) + currCountsPos;   %should be even
    scatter(V*PixCal/timestep, currCounts','filled');

end

figure
hold on

[~,~,reducedBinInds] = histcounts(V*PixCal/timestep,reducedV);
redBinVals = unique(reducedBinInds);
for index = size(VParAxis,1)/2:-1:1
    
    rebinnedCounts = zeros(numel(redBinVals),1);
    currCountsNeg = VParAxis(index,:);
    currCountsPos = VParAxis(end-index+1,:);
    currCounts = fliplr(currCountsNeg) + currCountsPos;   %should be even
    for currSuperBin = 1:numel(redBinVals)
        
        rebinnedCounts(currSuperBin) = sum(currCounts(reducedBinInds == currSuperBin));
    end

    scatter(reducedV, rebinnedCounts,'filled');
    
end
    
%% Get mean of flipped velocities
   
    % regionEdges = X(20:29,1);
    
[~,~,reducedBinInds] = histcounts(V*PixCal/timestep,reducedV);
redBinVals = unique(reducedBinInds);
fineMean = zeros(size(VParAxis,1)/2,1);
coarseMean = zeros(size(VParAxis,1)/2,1);

figure
hold on
for index = size(VParAxis,1)/2:-1:1
    
    currCountsNeg = VParAxis(index,:);
    currCountsPos = VParAxis(end-index+1,:);
    currCountsFine = fliplr(currCountsNeg) + currCountsPos;   %should be even
%     scatter(V*PixCal/timestep, currCounts','filled');

    
    rebinnedCounts = zeros(numel(redBinVals),1);
    currCountsNeg = VParAxis(index,:);
    currCountsPos = VParAxis(end-index+1,:);
    currCountsCoarse = fliplr(currCountsNeg) + currCountsPos;   %should be even
    
    for currSuperBin = 1:numel(redBinVals)
        
        rebinnedCounts(currSuperBin) = sum(currCountsCoarse(reducedBinInds == currSuperBin));
    end

    fineMean(index) = sum(currCountsFine.*(V*(PixCal/timestep)))/sum(currCountsFine);
    coarseMean(index) = sum(rebinnedCounts'.*(reducedV))/sum(rebinnedCounts');
%     scatter(reducedV, rebinnedCounts,'filled');
    

    
    
end
hold on
scatter(regionVals, fliplr(fineMean'),'filled')
scatter(regionVals, fliplr(coarseMean'),'filled')

end