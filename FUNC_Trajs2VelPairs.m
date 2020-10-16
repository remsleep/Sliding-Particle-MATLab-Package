function [outData] = FUNC_Trajs2VelPairs(dataDir,outDir,csvName,dt, pixelConv, timeConv)
%FUNC_TRAJS2VELPAIRS This function takes in a directory DATADIR where it
%can search for a file named tracks.mat. This file should constitute a Nx5
%or Nx6 array, with columns corresponding to
%[x,y,frame,orientation,ID,channel]. Alternatively, the array can be passed
%directly as an argument in place of DATADIR. OUTDIR is the full directory
%where the outputted data will be saved in a csv file named CSVNAME.csv.
%The function will also return the velocity pairs with all other associated
%data as the array OUTDATA: [
%DT is a time step over which velocities are calculated. The default time
%step should be 1, but can be increased to average over larger time steps.

%The script loads data, then iterates chronologically to find the sliding
%velocities of objects relative to one another. This is done by first
%locating all pairs of objects present in a pair of consecutive frames
%(separated by dt, in frames), rotating those objects into the
%parallel-perpendicular reference frame of one of the two objects in each
%pair (the reference particle), and then taking the difference of their
%positional differences divided by time separation. This results in
%relative sliding velocities between pairs along parallel and perpendicular
%axes.

%% Initiatilization

%Define variables if undefined
if nargin == 3
    dt = 1; pixelConv = 1; timeConv = 1;
elseif nargin == 4
    pixelConv = 1; timeConv = 1;
end

%Prepare a variable on the disk to save to periodically to speed things up
%and prevent memory issues. This will be a datastore.
%make new directory for saving data.  This will be a datastore for analysis.
mkdir(outDir);
savename=fullfile(outDir, [csvName,'.csv']);

%Write the File Headers to the csv file.
fileID= fopen(savename, 'w');
%Output this:  [Rsep RelAngle DeltaA DeltaS DeltaVpar DeltaVperp Vpara Vperp];
fprintf(fileID,...
    '%12s, %12s, %12s, %12s, %12s, %12s, %12s, %12s , %12s, %12s \n',...
    'Rsep', 'RelAngle', 'DeltaA', 'Vpar', 'Vperp', 'Time', 'Ch1', 'Ch2', 'ParSep', 'PerpSep');
fclose(fileID);

%Save every X frames.
DumpEvery=200;

%Load trajectory data if dataDir is not a data array
if size(dataDir,1) < 5
    trStruct = load(fullfile(dataDir,'tracks.mat'));  
    fields = cell2mat(fieldnames(trStruct));
    ogData = trStruct.(fields);
else
    ogData = dataDir;
end

%Add channel row, if missing
if size(ogData,2) == 5
    ogData = [ogData, ones(size(ogData,1),1)];
end

%Initialize output data matrix
outData =[];

%% Iterate through data chronologically

%Order data chronologically
TrackData = sortrows(ogData,3); %sort by frame #
uniqueData = unique(TrackData(:,3));  %unique FRAME #s
endFrame=size(uniqueData,1)-dt;

progBar = waitbar(0,'Calculating Interframe Rod Pair Data');
rawdata=[];

%Iterate chronologically
for currFrame=1:endFrame
    waitbar(currFrame/endFrame,progBar);
    
    Ind1=[]; Ind2=[];  %CLEAR OUT SHIT!
    rows1=[]; rows2=[]; IDs1=[]; IDs2=[];
    P1t1=[]; P1t2=[]; P2t1=[]; P2t2=[];
    Vpar=[]; Vperp=[]; Rsep=[]; RelAngle=[]; time=[]; DeltaA=[];
    
    %advance the frame numbers over which V is calcualted.
    frame1=uniqueData(currFrame);
    frame2=uniqueData(currFrame+dt);
    
    %find the rows in the data that correspond only each frame number.
    rows1= (TrackData(:,3) == frame1);
    rows2= (TrackData(:,3) == frame2);
    
    %tracks.mat format = [  X  Y  Frame#  Orientation  ID#  Channel#];
    %Extract the data for each Frame and find the IDs that exist in each Frame
    Data1=TrackData(rows1,:);    %FRAME 1
    Data2=TrackData(rows2,:);    %FRAME 2
    
    %Very rough patch: removal of double trajectories within the same frame
    excData1 = ( diff(Data1(:,5)) == 0 ); 
    excData2 = ( diff(Data2(:,5)) == 0 );
    Data1 = Data1(~excData1,:); Data2 = Data2(~excData2,:);
    
    %Iterate through channels to assign unique IDs to all objects, if there
    %are multiple channels. Channels are denoted by positive definite integers
    uniqueChannels = unique([Data1(:,6); Data2(:,6)]');
    tempID1 = Data1(:,5); tempID2 = Data2(:,5);
    for currChan = uniqueChannels(1:end-1)
        time1CurrChan = find(Data1(:,6) == currChan);
        time2CurrChan = find(Data2(:,6) == currChan);
        %Ensure there are objects in the given channel at both times
        if ( numel(time1CurrChan)>0 && numel(time2CurrChan)>0)
            %Get max ID in both times in current channel
            maxIDCurrChan = ...
                max( Data1(max(time1CurrChan),5), Data2(max(time2CurrChan),5) );
            %Update tempID vectors
            tempID1(1:max(time1CurrChan)) = Data1(1:max(time1CurrChan),5);
            tempID2(1:max(time2CurrChan)) = Data2(1:max(time2CurrChan),5);
            tempID1( (max(time1CurrChan)+1):end ) = ...
                Data1(max(time1CurrChan)+1:end,5) + maxIDCurrChan;
            tempID2( (max(time2CurrChan)+1):end ) = ...
                Data2(max(time2CurrChan)+1:end,5) + maxIDCurrChan;
        end
    end
    %Assign altered IDs to Data1 and Data2
    Data1(:,5) = tempID1; Data2(:,5) = tempID2;
    
    %Define ID vectors
    IDs1=Data1(:,5); IDs2=Data2(:,5);
    IDs=IDs1(ismember(IDs1,IDs2)==1);  %these are the ID#s that are the same in both frames.
    
    %Write conditional for the case when IDs is a single number less than
    %and greater than two.  There has to be at least a pair of numbers for
    %the rest of the code to work.  ex: size(unique(IDs),1) >= 2
    
    if size(unique(IDs),1) >= 2  %Ensures there is at least one pair of particles to process. Otherwise Combos numel=1 ;
        
        combos = nchoosek(IDs,2);  %here are the combinations of all IDs of which interframe stats need to be calculated.
        
        %For each pair, you need the XY pos for each particle in each frame.
        %Find the ID#s which are the same in Both frames in order to compare
        %interframe velocities.  Make Combos out of all these.
        
        %Gather the Indices of the XY positions for Particle 1&2 at times 1&2.
        for j=1:size(combos,1)
            if j==22
            end
            Ind1(j,1:2)=[ find(Data1(:,5)==combos(j,1))  find(Data1(:,5)==combos(j,2)) ]; %Index [Particle1 Particle2] at time1
            Ind2(j,1:2)=[ find(Data2(:,5)==combos(j,1))  find(Data2(:,5)==combos(j,2)) ]; %Index [Particle1 Particle2] at time2
        end
        
        %Find object positions rotated into reference object's
        %parallel-perpendicular reference frame at both selected times
        P1t1 = [ Data1(Ind1(:,1),1) .* cos(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,1),2) .* sin(Data1(Ind1(:,1),4))...
            -Data1(Ind1(:,1),1) .* sin(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,1),2) .* cos(Data1(Ind1(:,1),4))];
        
        P1t2 = [ Data2(Ind2(:,1),1) .* cos(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,1),2) .* sin(Data2(Ind2(:,1),4))...
            -Data2(Ind2(:,1),1) .* sin(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,1),2) .* cos(Data2(Ind2(:,1),4)) ];
        
        P2t1 = [ Data1(Ind1(:,2),1) .* cos(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,2),2) .* sin(Data1(Ind1(:,1),4))...
            -Data1(Ind1(:,2),1) .* sin(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,2),2) .* cos(Data1(Ind1(:,1),4)) ];
        
        P2t2 = [ Data2(Ind2(:,2),1) .* cos(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,2),2) .* sin(Data2(Ind2(:,1),4))...
            -Data2(Ind2(:,2),1) .* sin(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,2),2) .* cos(Data2(Ind2(:,1),4)) ];
        
        %Calculate quantities of interest
        % Separation between rods in pixels (r).
        Rsep= sqrt( ( P2t2(:,1) - P1t2(:,1) ).^2 + ( P2t2(:,2) - P1t2(:,2) ).^2 ) ;
        
        %Velocity components
        Vpar1 = (P1t2(:,1) - P1t1(:,1)) ./ (abs(frame2-frame1));
        Vpar2 = (P2t2(:,1) - P2t1(:,1)) ./ (abs(frame2-frame1));
        Vperp1 = (P1t2(:,2) - P1t1(:,2)) ./ (abs(frame2-frame1));
        Vperp2 = (P2t2(:,2) - P2t1(:,2)) ./ (abs(frame2-frame1));
        
        %Relative Velocities
        Vpar =  Vpar2 - Vpar1;
        Vperp =  Vperp2 - Vperp1;
               
        %RelativeAngle
        RelAngle = atan2(  ( P2t2(:,2) - P1t2(:,2) ) , ( P2t2(:,1) - P1t2(:,1) )  );
        RelAngle=mod(RelAngle,2*pi);
        
        %Separation along Parallel and Perp Axes
        [ParSep,PerpSep] = pol2cart(RelAngle,Rsep);
        ParSep = ParSep * pixelConv;
        PerpSep = PerpSep * pixelConv;
        
        %   Delta Angle?  (are the rods pointing in the same direction?)
        %   This should measure the smallest angle between two directions the rods are pointing.
        %   It will be less than pi/2.
        %tracks.mat format = [  X  Y  Frame#  Orientation  ID#  Channel#];
        DeltaA = abs( Data1(Ind1(:,2),4) - Data1(Ind1(:,1),4) ) ;
        DeltaA(DeltaA > pi/2) = pi - DeltaA(DeltaA > pi/2) ;
        
        %Define a time column
        time=frame1.*ones(size(Rsep,1),1);
        %Define channel columns
        ch1 = Data1(Ind1(:,1),6); ch2 = Data1(Ind1(:,2),6);
        
        % Concatenate data into a local variable to save
        rawdata = [rawdata ; Rsep RelAngle DeltaA Vpar Vperp time ch1 ch2 ParSep PerpSep];
        
        
    end
    
    %Save the data every X iterations to a csv file.
    if mod(currFrame,DumpEvery)==0
        %Convert units from pixels and frames to um and seconds
        rawdata(:,[1 4 5]) = rawdata(:,[1 4 5]) * pixelConv;
        rawdata(:,4:5) = rawdata(:,4:5) / timeConv;
        rawdata(:,6) = rawdata(:,6) * timeConv;
        %Save data
        dlmwrite(savename,rawdata,'-append');
        outData = [outData; rawdata];
        rawdata=[];
    elseif currFrame==endFrame
        %Convert units from pixels and frames to um and seconds
        rawdata(:,[1 4 5]) = rawdata(:,[1 4 5]) * pixelConv;
        rawdata(:,4:5) = rawdata(:,4:5) / timeConv;
        rawdata(:,6) = rawdata(:,6) * timeConv;
        %Save data
        dlmwrite(savename,rawdata,'-append');
        outData = [outData; rawdata];
        rawdata=[];
    end
    
end
close(progBar);
end

