%% Tests binning done in Linnea's BinInterframeRodPairDetails script
% Summary of example objective


%% Input Settings.  Simplified. 
BinWidth=100; % Width of the Box in pixels. 
Vwidth=0.005; %pixels/frame  %making this small is best.
MaxV=70; % in pixels/frame.
anglecut=pi/20;
FrameData=[0 Inf];  %First and last frame to find data for. In Frame #.
imsize = 1280;
timestep = 0.35;
PixCal  = 6.5*2/100;
fields = {'Rsep','RelAngle', 'DeltaA', 'Vx','Vy','time'};

%% Set Filenames and directories
directory='G:\Linnea\Data_Acquisition_2\2016_08_05\Neo_2bin_100x_300msexp_1sint_25uMATP_1';
analysisdir=strcat(directory,'');
datastorename=strcat(analysisdir,'\246p1538um_BinSize100 - Copy_copy.csv');
savename2=strcat(analysisdir,'');

%% delete the old analysis.mat file (NOT CSV) in case of appending.
if exist(savename2,'file')==2 
    delete(savename2);
end

%make datastore out of the analysis data.
ds=datastore(datastorename);
DatastoreInfo = dir(datastorename);

% enable all the data in datastore.
ds.SelectedVariableNames = fields;
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

%Find the index of where the XY positions go from negative to positive.
% 1:neg are indecies of the negative sort.
% pos: end are indecies of positive sort.
pos=ceil(size(X,1)/2)  ;  %Positive values
neg=floor(size(X,1)/2) ;  %Negative Values.
rmax=1; %set how far out to plot flow field
XYend= (pos+neg-rmax);

%%
iteration=0;
h = waitbar(0,'Binning Rod Data');  %initiate waitbar.
while hasdata(ds)
    %%
    iteration=iteration+1;
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
    
end



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
