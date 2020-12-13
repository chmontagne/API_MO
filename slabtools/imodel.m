function imodel( sx, sy, sz, xp, xn, yp, yn, zp, zn, mv, mz, mu )
% imodel - room image model visualization.
%
% imodel( sx, sy, sz, xp, xn, yp, yn, zp, zn, mv, mz, mu )
%
% sx, sy, sz             - source location
% xp, xn, yp, yn, zp, zn - positive and negative plane locations
% mv, mz, mu             - display mirror room flags
%
% imodel computes and displays 1st and 2nd-order reflections using a simple
% hard-coded image model (see [1] and imodelab.m for a general-purpose
% algorithm).
%
% To rotate axes and zoom, use the Figure Toolbar (see the Figure dialog View
% menu).
%
% Reference:
% [1] J. Allen and D. Berkley, "Image method for efficiently simulating
%     small-room acoustics", JASA 65(4), 1979.
%
% See Also: imodelui.m, imodelab.m, imodel_h.m

% modification history
% --------------------
%                ----  v5.0.2  ----
% 04.16.03  JDM  created
% 04.21.03  JDM  added Room() function, imodel_h, mirror flags; clean-up
% 04.22.03  JDM  added command-line image location output
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR
%
% JDM == Joel D. Miller

% Copyright (C) 2001-2018 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration (NASA).
% All Rights Reserved.
% 
% This software is distributed under the NASA Open Source Agreement (NOSA),
% version 1.3.  The NOSA has been approved by the Open Source Initiative.
% See the file NOSA.txt at the top of the distribution directory tree for the
% complete NOSA document.
% 
% THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY WARRANTY OF ANYKIND,
% EITHER EXPRESSED, IMPLIED, OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, ANY
% WARRANTY THAT THE SUBJECT SOFTWARE WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED
% WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM
% FROM INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR FREE,
% OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM TO THE SUBJECT
% SOFTWARE.

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% global variables and constants
imodel_h;

% parameter defaults
if nargin < 12, mu = 0; end;
if nargin < 11, mz = 0; end;
if nargin < 10, mv = 0; end;
if nargin <  9, zn = czn; end;
if nargin <  8, zp = czp; end;
if nargin <  7, yn = cyn; end;
if nargin <  6, yp = cyp; end;
if nargin <  5, xn = cxn; end;
if nargin <  4, xp = cxp; end;
if nargin <  3, sz = csz; end;
if nargin <  2, sy = csy; end;
if nargin <  1, sx = csx; end;

figure(gcf);

% axes
hold off;
lim = 30;
% plot3() used instead of line() to clear plot (clf() clears UI)
hx = plot3( [ -lim lim ], [ 0 0 ], [ 0 0 ], 'Color', [ 0.7 0.7 0.7 ] );
hy =  line( [ 0 0 ], [ -lim lim ], [ 0 0 ], 'Color', [ 0.7 0.7 0.7 ] );
hz =  line( [ 0 0 ], [ 0 0 ], [ -lim lim ], 'Color', [ 0.7 0.7 0.7 ] );
axis( [ -lim lim -lim lim -lim lim ] );
xlabel( 'x-axis' );
ylabel( 'y-axis' );
zlabel( 'z-axis' );
grid on;
hold on;

% rectangular room and room mirrors
room( xp, xn, yp, yn, zp, zn,  0,  0,  0 );

% v-type reflection room mirrors (1st-order refs)
if mv,
  room( xp, xn, yp, yn, zp, zn,  1,  0,  0 );
  room( xp, xn, yp, yn, zp, zn, -1,  0,  0 );
  room( xp, xn, yp, yn, zp, zn,  0,  1,  0 );
  room( xp, xn, yp, yn, zp, zn,  0, -1,  0 );
  room( xp, xn, yp, yn, zp, zn,  0,  0,  1 );
  room( xp, xn, yp, yn, zp, zn,  0,  0, -1 );
end;

% z-type reflection room mirrors (2nd-order refs)
if mz,
  room( xp, xn, yp, yn, zp, zn,  2,  0,  0 );
  room( xp, xn, yp, yn, zp, zn, -2,  0,  0 );
  room( xp, xn, yp, yn, zp, zn,  0,  2,  0 );
  room( xp, xn, yp, yn, zp, zn,  0, -2,  0 );
  room( xp, xn, yp, yn, zp, zn,  0,  0,  2 );
  room( xp, xn, yp, yn, zp, zn,  0,  0, -2 );
end;

% u-type reflection room mirrors (2nd-order refs)
if mu,
  room( xp, xn, yp, yn, zp, zn,  1,  1,  0 );
  room( xp, xn, yp, yn, zp, zn,  1, -1,  0 );
  room( xp, xn, yp, yn, zp, zn, -1,  1,  0 );
  room( xp, xn, yp, yn, zp, zn, -1, -1,  0 );

  room( xp, xn, yp, yn, zp, zn,  1,  0,  1 );
  room( xp, xn, yp, yn, zp, zn, -1,  0,  1 );
  room( xp, xn, yp, yn, zp, zn,  0,  1,  1 );
  room( xp, xn, yp, yn, zp, zn,  0, -1,  1 );

  room( xp, xn, yp, yn, zp, zn,  1,  0, -1 );
  room( xp, xn, yp, yn, zp, zn, -1,  0, -1 );
  room( xp, xn, yp, yn, zp, zn,  0,  1, -1 );
  room( xp, xn, yp, yn, zp, zn,  0, -1, -1 );
end;

% source
text( sx, sy, sz , 'x' );
fprintf( '\nD    (x) %6.2f %6.2f %6.2f\n', sx, sy, sz );

% 1st-order reflections

rtext( 2*xp-sx, sy, sz, 'a', 'XP' );
rtext( 2*xn-sx, sy, sz, 'b', 'XN' );
rtext( sx, 2*yp-sy, sz, 'c', 'YP' );
rtext( sx, 2*yn-sy, sz, 'd', 'YN' );
rtext( sx, sy, 2*zp-sz, 'e', 'ZP' );
rtext( sx, sy, 2*zn-sz, 'f', 'ZN' );

% 2nd-order reflections

% 2D XxY "U"-type (xxyy == yyxx)
btext( 2*xp-sx, 2*yp-sy, sz, 'a', 'XPYP' );
btext( 2*xp-sx, 2*yn-sy, sz, 'b', 'XPYN' );
btext( 2*xn-sx, 2*yn-sy, sz, 'c', 'XNYN' );
btext( 2*xn-sx, 2*yp-sy, sz, 'd', 'XNYP' );

% 2D XxY "Z"-type
btext( 2*(xn-xp)+sx, sy, sz, 'e', 'XPXN' );
btext( sx, 2*(yn-yp)+sy, sz, 'f', 'YPYN' );
btext( 2*(xp-xn)+sx, sy, sz, 'g', 'XNXP' );
btext( sx, 2*(yp-yn)+sy, sz, 'h', 'YNYP' );

% 3D Z "Z"-type
btext( sx, sy, 2*(zp-zn)+sz, 'i', 'ZNZP' );
btext( sx, sy, 2*(zn-zp)+sz, 'j', 'ZPZN' );

% 3D Z "U"-type (zzxx == xxzz)
btext( 2*xp-sx, sy, 2*zp-sz, 'k', 'ZPXP' );
btext( 2*xn-sx, sy, 2*zp-sz, 'l', 'ZPXN' );
btext( sx, 2*yn-sy, 2*zp-sz, 'm', 'ZPYN' );
btext( sx, 2*yp-sy, 2*zp-sz, 'n', 'ZPYP' );
btext( 2*xp-sx, sy, 2*zn-sz, 'o', 'ZNXP' );
btext( 2*xn-sx, sy, 2*zn-sz, 'p', 'ZNXN' );
btext( sx, 2*yn-sy, 2*zn-sz, 'q', 'ZNYN' );
btext( sx, 2*yp-sy, 2*zn-sz, 'r', 'ZNYP' );

hold off;

%------------------------------------------------------------------------------
% rtext() - red text function

function rtext( a, b, c, d, e )
h = text( a, b, c, d );
set( h, 'Color', [1 0 0] );
fprintf( '%-4s (%c) %6.2f %6.2f %6.2f\n', e, d, a, b, c );

%------------------------------------------------------------------------------
% btext() - blue text function

function btext( a, b, c, d, e )
h = text( a, b, c, d );
set( h, 'Color', [0 0 1] );
fprintf( '%-4s (%c) %6.2f %6.2f %6.2f\n', e, d, a, b, c );

%------------------------------------------------------------------------------
% room() - room drawing function

function room( xp, xn, yp, yn, zp, zn, xdir, ydir, zdir )

% x,y,z offsets for mirror rooms
xoff = xdir * (xp - xn);
yoff = ydir * (yp - yn);
zoff = zdir * (zp - zn);

% mirror rooms are drawn dotted
if (xdir == 0) & (ydir == 0) & (zdir == 0),
  s = '-b';
else,
  s = ':b';
end;

% rectangular room; plot3() used instead of line() to set line type
% (3D refs: "help graphics" and "help graph3d")
plot3( xoff + [xp xp xn xn xp xp xp xp xn xn xp], ...
       yoff + [yp yn yn yp yp yp yp yn yn yp yp], ...
       zoff + [zn zn zn zn zn zp zp zp zp zp zp], s );
plot3( xoff + [xp xp], yoff + [yn yn], zoff + [zn zp], s );
plot3( xoff + [xn xn], yoff + [yp yp], zoff + [zn zp], s );
plot3( xoff + [xn xn], yoff + [yn yn], zoff + [zn zp], s );
