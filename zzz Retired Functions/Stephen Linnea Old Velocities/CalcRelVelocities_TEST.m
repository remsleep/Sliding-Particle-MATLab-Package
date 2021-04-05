

angle1=pi/2;
angle2=pi/2;
p1t1 = [1 0];
p1t2 = [1 0];
p2t1 = [2 0];
p2t2 = [3 0];


P1t1 = [ p1t1(1) .* cos(angle1) +  p1t1(2) .* sin(angle1)...
    ( -p1t1(1) .* sin(angle1) +  p1t1(2) .* cos(angle1)) ];

P1t2 = [ p1t2(1) .* cos(angle2) +  p1t2(2) .* sin(angle2)...
    ( -p1t2(1) .* sin(angle2) +  p1t2(2) .* cos(angle2))];

P2t1 = [ p2t1(1) .* cos(angle1) +  p2t1(2) .* sin(angle1)...
    ( -p2t1(1) .* sin(angle1) +  p2t1(2) .* cos(angle1))];

P2t2 = [ p2t2(1) .* cos(angle2) +  p2t2(2) .* sin(angle2)...
    ( -p2t2(1) .* sin(angle2) +  p2t2(2) .* cos(angle2))];


Vx=  (( P2t2(:,1) - P1t2(:,1) ) - ( P2t1(:,1) - P1t1(:,1) ) )./ (abs(1)) ;
Vy=  (( P2t2(:,2) - P1t2(:,2) ) - ( P2t1(:,2) - P1t1(:,2) ) )./ (abs(1)) ;



%FLIPPED SIGNS
% P1t1 = [ p1t1(1) .* cos(angle1) +  p1t1(2) .* sin(angle1)...
%     p1t1(1) .* sin(angle1) -  p1t1(2) .* cos(angle1)];
% 
% P1t2 = [ p1t2(1) .* cos(angle2) +  p1t2(2) .* sin(angle2)...
%     p1t2(1) .* sin(angle2) -  p1t2(2) .* cos(angle2)];
% 
% P2t1 = [ p2t1(1) .* cos(angle1) +  p2t1(2) .* sin(angle1)...
%     p2t1(1) .* sin(angle1) -  p2t1(2) .* cos(angle1)];
% 
% P2t2 = [ p2t2(1) .* cos(angle2) +  p2t2(2) .* sin(angle2)...
%     p2t2(1) .* sin(angle2) -  p2t2(2) .* cos(angle2)];
% 
% 
% Vx=  (( P2t2(:,1) - P1t2(:,1) ) - ( P2t1(:,1) - P1t1(:,1) ) )./ (abs(1)) ;
% Vy=  (( P2t2(:,2) - P1t2(:,2) ) - ( P2t1(:,2) - P1t1(:,2) ) )./ (abs(1)) ;



