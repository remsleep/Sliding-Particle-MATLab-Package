function rawdata=Stephen_CalcRelVelocities2(DataSet)
% This program measures the interframe velocity between rod pairs!
% For example, the program will find all of the rods which appear in consecutive frames (conserved particle IDs)
% and then calculates the relative velocities between those pairs.
%
% It also records the relative angle and separation distance between the
% rods.
%
%  Can do this calc in the rotated frame to make relangle easy to calc.
%
%   Input:
%       The Analysis directory where the tracks.mat file (From rod tracking)
%       tracks.mat format = [  X  Y  Frame#  Orientation  ID#  ];
%
%   Output:
%       Relative Rod velocity measurements:
%       'AnalysisData.csv' - A Matlab Datastore from which parts of the
%       full file can be accessed w/o opening the entire file to memory.
%       This is a LARGE TEXT FILE which contains the following headers:
%
%       'Rsep', 'RelAngle', 'DeltaA', 'Vx', 'Vy','time'
%
%   
%
%%

dt=1; %Set the inter-frame time-step over which velocities are measured IN Delta-FRAMES!!!! NOT SECONDS.
%This can help with smoothing velocities by measuring them over slightly large time steps.


%%
% % Prepare a variable on the disk to save to periodically to speed things up
% % and prevent memory issues. This will be a datastore.
% % make new directory for saving data.  This will be a datastore for analysis.
% analysisdir=strcat(directory,'\AnalysisDirectory3');   mkdir(analysisdir);
% savename=strcat(analysisdir,'\AnalysisDatachange2.csv');
% 
% % Write the File Headers to the csv file.
% fileID= fopen(savename, 'w');
% % Output this:  [Rsep RelAngle DeltaA DeltaS DeltaVx DeltaVy Vpara Vperp];
% fprintf(fileID,'%12s, %12s, %12s, %12s, %12s, %12s \n',...
%     'Rsep', 'RelAngle', 'DeltaA', 'Vx', 'Vy','time');
% fclose(fileID);
% 
% % Save every X frames.
% DumpEvery=200;




%Sort the incoming data by frame number.
TrackData = sortrows(DataSet,3); %sort by frame #
u = unique(TrackData(:,3));  %unique FRAME #s
endframe=size(u,1)-dt;


rawdata=[];
for i=1:endframe
    
    Ind1=[]; Ind2=[];  %CLEAR OUT SHIT!
    rows1=[]; rows2=[]; IDs1=[]; IDs2=[];
    P1t1=[]; P1t2=[]; P2t1=[]; P2t2=[];
    Vx=[]; Vy=[]; Rsep=[]; RelAngle=[]; time=[]; DeltaA=[];
    
    %advance the frame numbers over which V is calcualted.
    frame1=u(i);
    frame2=u(i+dt);
    
    %find the rows in the data that correspond only each frame number.
    rows1=find(TrackData(:,3) == frame1);
    rows2=find(TrackData(:,3) == frame2);
    
    %tracks.mat format = [  X  Y  Frame#  Orientation  ID#  ];
    %Extract the data for each Frame and find the IDs that exist in each Frame
    Data1=TrackData(rows1,:);  IDs1=Data1(:,5);  %FRAME 1
    Data2=TrackData(rows2,:);  IDs2=Data2(:,5);  %FRAME 2
    IDs=IDs1(ismember(IDs1,IDs2)==1);  %these are the ID#s that are the same in both frames.
    
    %Write conditional for the case when IDs is a single number less than
    %and greater than two.  There has to be at least a pair of numbers for
    %the rest of the code to work.  ex: size(unique(IDs),1) >= 2
    
    if size(unique(IDs),1) >= 2 ; %Ensures there is at least one pair of particles to process. Otherwise Combos numel=1 ;
        
        combos = nchoosek(IDs,2);  %here are the combinations of all IDs of which interframe stats need to be calculated.
        
        %For each pair, you need the XY pos for each particle in each frame.
        %Find the ID#s which are the same in Both frames in order to compare
        %interframe velocities.  Make Combos out of all these.
        
        %Gather the Indices of the XY positions for Particle 1&2 at times 1&2.
        for j=1:size(combos,1);
            Ind1(j,1:2)=[ find(Data1(:,5)==combos(j,1))  find(Data1(:,5)==combos(j,2)) ]; %Index [Particle1 Particle2] at time1
            Ind2(j,1:2)=[ find(Data2(:,5)==combos(j,1))  find(Data2(:,5)==combos(j,2)) ]; %Index [Particle1 Particle2] at time2
        end
        
        % Vx' = Vx Cos(theta) - Vy Sin(theta)
        % Vy' = Vx Sin(theta) + Vy Cos(theta)
        %rotate Particle2 into Particle1 reference frame.
        %FORMAT = [ X Y Angle]
%         P1t1 = [ Data1(Ind1(:,1),1) .* cos(Data1(Ind1(:,1),4)) -  Data1(Ind1(:,1),2) .* sin(Data1(Ind1(:,1),4))...
%             Data1(Ind1(:,1),1) .* sin(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,1),2) .* cos(Data1(Ind1(:,1),4))];
%         
%         P1t2 = [ Data2(Ind2(:,1),1) .* cos(Data2(Ind2(:,1),4)) -  Data2(Ind2(:,1),2) .* sin(Data2(Ind2(:,1),4))...
%             Data2(Ind2(:,1),1) .* sin(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,1),2) .* cos(Data2(Ind2(:,1),4)) ];
%         
%         P2t1 = [ Data1(Ind1(:,2),1) .* cos(Data1(Ind1(:,1),4)) -  Data1(Ind1(:,2),2) .* sin(Data1(Ind1(:,1),4))...
%             Data1(Ind1(:,2),1) .* sin(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,2),2) .* cos(Data1(Ind1(:,1),4)) ];
%         
%         P2t2 = [ Data2(Ind2(:,2),1) .* cos(Data2(Ind2(:,1),4)) -  Data2(Ind2(:,2),2) .* sin(Data2(Ind2(:,1),4))...
%             Data2(Ind2(:,2),1) .* sin(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,2),2) .* cos(Data2(Ind2(:,1),4)) ];
        
        P1t1 = [ Data1(Ind1(:,1),1) .* cos(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,1),2) .* sin(Data1(Ind1(:,1),4))...
            -Data1(Ind1(:,1),1) .* sin(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,1),2) .* cos(Data1(Ind1(:,1),4))];
        
        P1t2 = [ Data2(Ind2(:,1),1) .* cos(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,1),2) .* sin(Data2(Ind2(:,1),4))...
            -Data2(Ind2(:,1),1) .* sin(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,1),2) .* cos(Data2(Ind2(:,1),4)) ];
        
        P2t1 = [ Data1(Ind1(:,2),1) .* cos(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,2),2) .* sin(Data1(Ind1(:,1),4))...
            -Data1(Ind1(:,2),1) .* sin(Data1(Ind1(:,1),4)) +  Data1(Ind1(:,2),2) .* cos(Data1(Ind1(:,1),4)) ];
        
        P2t2 = [ Data2(Ind2(:,2),1) .* cos(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,2),2) .* sin(Data2(Ind2(:,1),4))...
            -Data2(Ind2(:,2),1) .* sin(Data2(Ind2(:,1),4)) +  Data2(Ind2(:,2),2) .* cos(Data2(Ind2(:,1),4)) ];
        
        
        %DO VECTOR MAGIC.
        % Separation between rods in pixels (r).
        Rsep= sqrt( ( P2t2(:,1) - P1t2(:,1) ).^2 + ( P2t2(:,2) - P1t2(:,2) ).^2 ) ;
        
        %Relative Velocities (components.
        Vx=  (( P2t2(:,1) - P1t2(:,1) ) - ( P2t1(:,1) - P1t1(:,1) ) )./ (abs(frame2-frame1)) ;
        Vy=  (( P2t2(:,2) - P1t2(:,2) ) - ( P2t1(:,2) - P1t1(:,2) ) )./ (abs(frame2-frame1)) ;
        
%         Vx=  (( P2t2(:,1) - P2t1(:,1) ) - ( P1t2(:,1) - P1t1(:,1) ) )./ (abs(frame2-frame1)) ;
%         Vy=  (( P2t2(:,2) - P2t1(:,2) ) - ( P1t2(:,2) - P1t1(:,2) ) )./ (abs(frame2-frame1)) ;
        
        %RelativeAngle
        RelAngle = atan2(  ( P2t2(:,2) - P1t2(:,2) ) , ( P2t2(:,1) - P1t2(:,1) )  );
        RelAngle=mod(RelAngle,2*pi);
        
        %   Delta Angle?  (are the rods pointing in the same direction?)
        %   This should measure the smallest angle between two directions the rods are pointing.
        %   It will be less than pi/2.
        %tracks.mat format = [  X  Y  Frame#  Orientation  ID#  ];
        DeltaA = abs( Data1(Ind1(:,2),4) - Data1(Ind1(:,1),4) ) ;
        DeltaA(DeltaA > pi/2) = pi - DeltaA(DeltaA > pi/2) ;
        
        %make a time Column for later in case you need it.
        time=frame1.*ones(size(Rsep,1),1);
        
        % concatenate them into a local variable to save a few at a time.
        rawdata = [rawdata ; Rsep RelAngle DeltaA Vx Vy time];
        
    end
    
    %Save the data every X iterations to a csv file.
%     if mod(i,DumpEvery)==0;
%         dlmwrite(savename,rawdata,'-append');
%         %secondpt=size(rawdata,1)+firstpt-1; %set the first index.
%         %m.rawdata(firstpt:secondpt,1:8) = rawdata;  %append the disk variable rawdata.
%         %firstpt=secondpt+1; %incriment the saving matrix index.
%         rawdata=[];
%     elseif i==endframe;
%         dlmwrite(savename,rawdata,'-append');
%         %secondpt=size(rawdata,1)+firstpt-1; %set the first index.
%         %m.rawdata(firstpt:secondpt,1:8) = rawdata;  %append the disk variable rawdata.
%         %firstpt=secondpt+1; %incriment the saving matrix index.
%         rawdata=[];
%     end
    
end



% ds=datastore(savename);




