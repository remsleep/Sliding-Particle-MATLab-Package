% CUSTOMGAUSS    Generate a 2D gaussian at every 5 degree angle
%
%    gauss = customgauss(gsize, sigmax, sigmay, theta, offset, factor, center)
%
%          gsize     Size of the output 'gauss' square
%          sigmax    Std. dev. in the X direction
%          sigmay    Std. dev. in the Y direction
%          theta     Rotation in degrees

function ret = FUNC_Generate_2DGaussRev(gsize, sigmax, sigmay,res)
 
    xbegin  = -round(gsize / 2);
    ybegin  = -round(gsize / 2);
    x = (xbegin+1:1:xbegin+gsize);
    y = (ybegin+1:1:ybegin+gsize);

    theta = (0:res:180-res);
    rad = (theta/180)*pi - pi/2;%%convert from degrees to radians

    xc = 0;
    yc = 0;

    %%calculating xm
    xcos = (x-xc).*cos(rad)';%%creates 2D matrix where each entry is an element 
    %%of (x-xc) multiplied by an element of cos(rad)
    ysin = (y-yc).*sin(rad)';
    xm   = superCombine(xcos,ysin,'subtract',gsize,res);%%makes 3D matrix with entries equal to
    %%(x-xc)*cos(theta) - (y-yc)*sin(theta) where x is dim1, y is dim2, theta is dim3

    %%calculating ym
    xsin = (x-xc).*sin(rad)';
    ycos = (y-yc).*cos(rad)';
    ym  = superCombine(xsin,ycos,'add',gsize,res);

    %%calculating guassian
    u  = (xm/sigmax).^2 + (ym/sigmay).^2;
    ret = exp(-u/2);
    
end

function val = superCombine(a,b,sign,size,resolution)%%sign is either 'add' or 'subtract'
%%this function combines two 2D matrices into a 3D matrix so that each
%%element of a is added(or subtracted) to each element of b
    X = repmat(a,1,size);
    X = reshape(X,[round(180/resolution),size,size]);%%these two lines create 3D matrix 
    %%with size "sheets" of 2D matrix a
    X = permute(X,[2,3,1]);%%need to rearrange 3D matrix to add each term of X to each term of Y

    Y = repmat(b,1,size);
    Y = reshape(Y,[round(180/resolution),size,size]);
    Y = permute(Y,[3,2,1]);
    
    if isequal(sign,'add')
        val = X + Y;
    elseif isequal(sign,'subtract')
        val = X - Y;
    end
end