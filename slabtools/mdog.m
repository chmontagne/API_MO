% mdog - make DOG image
%
% by Joel D. Miller, 10/6/05
%
% Notes:
%
% doog2.m from http://www.cs.berkeley.edu/~stellayu/code.html
%
% doog2 example:
%
% doog2(sig,r,th,N)
%   sig ~ size
%   r   ~ skew, >1 flattened
%   th  ~ rotation
%   N   ~ width/height
% imagesc(doog2(1,12,0,64))
%
% DOOG to DOG
%
% DOG formula from http://viaserver.vialab.org/methods_course/Lectures/
% Stetten_lecture2_OperatTransf.ppt, slide 25

% modification history
% --------------------
%                ----  v5.8.0  ----
% 10.06.05  JDM  created
% 10.13.05  JDM  added arcsin warp
%
% JDM == Joel D. Miller

% This software is distributed under the GPL (see gpl.txt).
% See also: doog.txt

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% parameters
N = 256; % for bitmap
%N = 64; % good for screen visualization
sig1 = 1500;
sig2 = 2048;
warp = 1;
%brightamt = 0.25; % good for screen visualization
brightamt = 0.0; % for bitmap

% sig1, sig2, r, th, N
[ G Gb Gc ] = dog( sig1, sig2, 1, 0, N ); % Gb(sig1) - Gc(sig2)

zmin = min(min(G));
zmax = max( [ max(max(Gb)) max(max(Gc)) ] );

figure;
colormap(brighten(gray,brightamt));

subplot(2,3,1);
imagesc(Gb);
title('Gb');
subplot(2,3,4);
mesh(Gb);
axis([ 0 N 0 N zmin zmax ]);

subplot(2,3,2);
imagesc(Gc);
title('Gc');
subplot(2,3,5);
mesh(Gc);
axis([ 0 N 0 N zmin zmax ]);

subplot(2,3,3);
imagesc( G );
title('G');
subplot(2,3,6);
mesh( G );
axis([ 0 N 0 N zmin zmax ]);

gmin = min(min(G));
fprintf( '\nG:    sum = %9.6f    max = %9.6f    min = %9.6f\n\n', ...
         sum(sum(G)), max(max(G)), gmin );

% offset and normalize to 0:1
G = G - gmin;
gmax = max(max(G));
G = G / gmax;

% warp values to exagerate difference between low intensities
if 1,
figure;
colormap( gray );
x = 0:1/256:1;
G = (1-asin(1-G)/(pi/2)).^warp;
subplot(2,2,1);
imagesc( G );
subplot(2,2,3);
mesh( G );
axis([ 0 N 0 N 0 1 ]);
subplot(2,2,4);
plot( x, (1-asin(1-x)/(pi/2)).^warp );
title( 'arcsine warp' );
grid;
end;

% save bitmap
imwrite( G, 'mdog.bmp', 'bmp' );
