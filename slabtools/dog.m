function [ G, Gb, Gc ] = dog(sig,sig2,r,th,N)
% dog - difference of gaussians, Gb(sig1) - Gc(sig2)
%
% [ G, Gb, Gc ] = dog( sig1, sig2, r, th, N )
%
% Based on doog2.m
% Modified by Joel D. Miller, 10/6/05
%
% Original comments below:
%
% G=doog2(sig,r,th,N);
% Make difference of offset gaussians kernel
% theta is in degrees
% (see Malik & Perona, J. Opt. Soc. Amer., 1990)
%
% Example:
% >> imagesc(doog2(1,12,0,64,1))
% >> colormap(gray)
%
% by Serge Belongie

% modification history
% --------------------
%                ----  v5.8.0  ----
% 10.06.05  JDM  created from doog2.m
%
% JDM == Joel D. Miller

% This software is distributed under the GPL (see gpl.txt).
% See also: doog.txt

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

no_pts=N;  % no. of points in x,y grid

[x,y]=meshgrid(-(N/2)+1/2:(N/2)-1/2,-(N/2)+1/2:(N/2)-1/2);
X=[x(:) y(:)];

phi=pi*th/180;
R=[cos(phi) -sin(phi); sin(phi) cos(phi)];

sigy=sig;
sigx=r*sig;
C=R*diag([sigx,sigy])*R';
Gb=gaussian(X,[0 0]',C);
Gb=reshape(Gb,N,N);

% Joel mods, see mdog.m comments for reference info

sigy=sig2;
sigx=r*sig2;
C=R*diag([sigx,sigy])*R';
Gc=gaussian(X,[0 0]',C);
Gc=reshape(Gc,N,N);

G = Gb - Gc;

% original code
if 0,

m=R*[0 sig]';
Ga=gaussian(X,m,C);
Ga=reshape(Ga,N,N);
Gc=rot90(Ga,2);

a=-1;
b=2;
c=-1;

G = a*Ga + b*Gb + c*Gc;

end;
