function [rgrid rx ry rz ] = grids( azInc, elInc, gtype )
% grids - CIPIC/Listen/ACD/slab3d HRTF measurement/database grids.
%
% [rgrid rx ry rz ] = grids( azInc, elInc, gtype )
%
% azInc - slab3d azimuth increment in degrees (default = 30)
% elInc - slab3d elevation increment in degrees (default = 18)
% gtype - return grid type (default = -1)
%          -1 = none, show figure (figure not shown for options below)
%           0 = slab3d
%           1 = CIPIC
%           2 = Listen
%           3 = ACD
%
% slab3d Coordinate System
%
% Location
%   +x front, through nose
%   +y left, through left ear
%   +z top, through top of head
% 
% Orientation
%   -yaw right
%   +yaw left
%   -pitch up
%   +pitch down
%   +roll right
%   -roll left
% 
% Polar
%   +azimuth right
%   -azimuth left
%   +elevation up
%   -elevation down
%   +range forward
%   -range backward
%
% See also: cipic2slab, listen2slab, c2s, c2r, r2p, p2r

% modification history
% --------------------
%                ----  v5.4.0  ----
% 10.15.03  JDM  created
% 10.30.03  JDM  removed from cipic2sarc.m;
%                bug fix: SLAB el calc
%                ----  v6.6.0  ----
% 02.09.11  JDM  added azInc and elInc params, commented-out portions to
%                increase speed
% 03.16.11  JDM  x,y,z now in slab3d coords; added Listen; cgrid.m -> grids.m
%                ----  v6.7.1  ----
% 03.13.13  JDM  added gtype param and grid return values
% 03.21.13  JDM  added ACD grid
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

if nargin < 1,
  azInc = 30;
end;
if nargin < 2,
  elInc = 18;
end;
if nargin < 3,
  gtype = -1;  % no return values, display grids in figure window
end;

% for non-slab3d grid return
if gtype > 0,  % not slab3d
  azInc = 30;
  elInc = 18;
end;

% slab3d and Listen grids
%
% sgrid(:,1:20)
%   Columns 1 through 14
%     90    72    54    36    18     0   -18   -36   -54   -72   -90    90    72    54
%    180   180   180   180   180   180   180   180   180   180   180   150   150   150
%   Columns 15 through 20
%     36    18     0   -18   -36   -54
%    150   150   150   150   150   150
%
% lgrid = [ hc.l_eq_hrir_S.elev_v hc.l_eq_hrir_S.azim_v ]';
%
% lgrid(:,1:28)
%   Columns 1 through 14
%    -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45
%      0    15    30    45    60    75    90   105   120   135   150   165   180   195
%   Columns 15 through 28
%    -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -30   -30   -30   -30
%    210   225   240   255   270   285   300   315   330   345     0    15    30    45
%
% Note: Listen grid not uniform.
%
% lgrid(:,end-20:end)
%   Columns 1 through 14
%     45    45    60    60    60    60    60    60    60    60    60    60    60    60
%    330   345     0    30    60    90   120   150   180   210   240   270   300   330
%   Columns 15 through 21
%     75    75    75    75    75    75    90
%      0    60   120   180   240   300     0
%
% Listen az   0 to 165 maps to slab3d 0 to -165 (-az left)
% Listen az 180 to 345 maps to slab3d 180 to 15 (+az right)
%
% els equivalent

% switch on the grid type selected by the user;
% either return a grid or display all grids
switch gtype
  case 0  % slab3d
    [rgrid rx ry rz ] = sgridgen(azInc, elInc);
  case 1  % CIPIC
    [rgrid rx ry rz ] = cgridgen();
  case 2  % Listen
    [rgrid rx ry rz ] = lgridgen();
  case 3  % ACD
    [rgrid rx ry rz ] = agridgen();
  otherwise  % grid not selected, display all grids
    figure(gcf);
    clf;
    grid;
    colormap('white');
    sphere(12);
    hold on;

    % slab3d
    [sgrid sx sy sz ] = sgridgen(azInc, elInc);
    plot3(sx,sy,sz,'ro');
    % CIPIC
    [cgrid cx cy cz ] = cgridgen();
    plot3(cx,cy,cz,'bx');
    % Listen
    [lgrid lx ly lz ] = lgridgen();
    plot3(lx,ly,lz,'g*');
    % ACD
    [agrid ax ay az ] = agridgen();
    plot3(ax,ay,az,'ms');

    view(-140,30);
    dim = 1.5;
    axis( [ -dim dim -dim dim -dim dim ] );
    xlabel('x');
    ylabel('y');
    zlabel('z');
    legend('sphere','slab3d','CIPIC','Listen','ACD');
    title( sprintf( 'azInc %d, elInc %d', azInc, elInc ) );
    hold off;

    % function return values
    rgrid = [];
    rx = [];
    ry = [];
    rz = [];
end

% az,el verison of matlab's sphere.m
if 0,
n = 20;
% -pi <= az <= pi, row vector
az = (-n:2:n)/n*pi;
% -pi/2 <= el <= pi/2, column vector
el = (-n:2:n)'/n*pi/2;
%sinaz = sin(az); %sinaz(1) = 0; sinaz(n+1) = 0;
cosel = cos(el); %cosel(1) = 0; cosel(n+1) = 0;
x = cosel*cos(az);
%y = cosel*sinaz;
y = cosel*sin(az);
z = sin(el)*ones(1,length(cosel));
surf(x,y,z);
end;

%-------------------------------------------------------------------------------
% slab3d grid

function [sgrid sx sy sz ] = sgridgen(azInc,elInc)
% slab3d grid in slab3d coords
% els-grouped-by-az (e.g., all els at 180 az and so on)
sazs = 180:-azInc:-180;
sels = 90:-elInc:-90;
sgrid = [kron(ones(size(sazs)),sels); kron(sazs,ones(size(sels)))];
sx = zeros(1,size(sgrid,2));
sy = zeros(1,size(sgrid,2));
sz = zeros(1,size(sgrid,2));
for i=1:size(sgrid,2),
  % slab3d az,el to slab3d x,y,z
  [ sx(i) sy(i) sz(i) ] = p2r( sgrid(2,i), sgrid(1,i), 1.0 );
end;

%-------------------------------------------------------------------------------
% ACD grid

function [sgrid sx sy sz ] = agridgen()
% ACD HeadZap grid in slab3d coords
% els-grouped-by-az (e.g., all els at 180 az and so on)
sazs = 180:-10:-170;
sels = 70:-10:-40;
sgrid = [kron(ones(size(sazs)),sels); kron(sazs,ones(size(sels)))];
sx = zeros(1,size(sgrid,2));
sy = zeros(1,size(sgrid,2));
sz = zeros(1,size(sgrid,2));
for i=1:size(sgrid,2),
  % slab3d az,el to slab3d x,y,z
  [ sx(i) sy(i) sz(i) ] = p2r( sgrid(2,i), sgrid(1,i), 1.0 );
end;

%-------------------------------------------------------------------------------
% Listen grid

function [lgrid lx ly lz ] = lgridgen()
% Listen grid in slab3d coords
% azs-grouped-by-el (e.g., all azs at -45 el and so on)
lels = -45:15:45;
lazs15 = [ 0:-15:-165 180:-15:15 ];  % lels
lazs30 = [ 0:-30:-150 180:-30:30 ];  % el 60
lazs60 = [ 0:-60:-120 180:-60:60 ];  % el 75
% and az,el 90,0
lgrid15 = [ kron(lels,ones(size(lazs15))); kron(ones(size(lels)),lazs15) ];
lgrid30 = [ 60*ones(size(lazs30)); lazs30 ];
lgrid60 = [ 75*ones(size(lazs60)); lazs60 ];
lgrid = [ lgrid15 lgrid30 lgrid60 [ 90; 0 ] ];
lx = zeros(1,size(lgrid,2));
ly = zeros(1,size(lgrid,2));
lz = zeros(1,size(lgrid,2));
for i=1:size(lgrid,2),
  % slab3d az,el to slab3d x,y,z
  [ lx(i) ly(i) lz(i) ] = p2r( lgrid(2,i), lgrid(1,i), 1.0 );
end;

%-------------------------------------------------------------------------------
% CIPIC grid

function [cgrid cx cy cz ] = cgridgen()
% cipic grid in cipic coords (interaural polar)
% els-grouped-by-az (e.g., all els at -80 az and so on)
cels = -45 + 5.625*(0:49);
cazs = [ -80 -65 -55 -45:5:45 55 65 80 ];
cgrid = [kron(ones(size(cazs)),cels); kron(cazs,ones(size(cels)))];
cx = zeros(1,size(cgrid,2));
cy = zeros(1,size(cgrid,2));
cz = zeros(1,size(cgrid,2));
%tic
for i=1:size(cgrid,2),
  % cipic az,el to slab3d x,y,z
  caz = cgrid(2,i);
  cel = cgrid(1,i);
  % inline, full loop = 0.3ms
  cx(i) = cos( caz*pi/180 ) * cos( cel*pi/180 );
  cy(i) = sin( caz*pi/180 ) * -1.0;
  cz(i) = cos( caz*pi/180 ) * sin( cel*pi/180 );
  %[ cx(i) cy(i) cz(i) ] = c2r( caz, cel );  % full loop = 5ms
  %[ saz sel cx(i) cy(i) cz(i) ] = c2s( caz, cel ); % full loop = 14ms
end;
%toc
