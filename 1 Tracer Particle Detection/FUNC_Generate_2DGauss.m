% CUSTOMGAUSS    Generate a 2D gaussian at every 5 degree angle
%
%    gauss = customgauss(gsize, sigmax, sigmay, theta, offset, factor, center)
%
%          gsize     Size of the output 'gauss' square
%          sigmax    Std. dev. in the X direction
%          sigmay    Std. dev. in the Y direction
%          theta     Rotation in degrees

function ret = FUNC_Generate_2DGauss(gsize, sigmax, sigmay,res)

ret     = zeros(gsize,gsize,round(180/res)); 
rbegin  = -round(gsize / 2);
cbegin  = -round(gsize / 2);
for theta = 1:length(ret(1,1,:))
for r=1:gsize
    for c=1:gsize
        ret(r,c,theta) = rotgauss(rbegin+r,cbegin+c, (theta-1)*res, sigmax, sigmay);
    end
end
end

function val = rotgauss(x, y, theta, sigmax, sigmay)
xc      = 0;
yc      = 0;
theta   = (theta/180)*pi - pi/2;
xm      = (x-xc)*cos(theta) - (y-yc)*sin(theta);
ym      = (x-xc)*sin(theta) + (y-yc)*cos(theta);
u       = (xm/sigmax)^2 + (ym/sigmay)^2;
val     = exp(-u/2);