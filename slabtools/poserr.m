function [ap,ep,rp] = poserr( az, el, r, x, y, z, yaw, pitch, roll )
% poserr - applies a subject-positioning error in x, y, z, yaw, pitch, roll.
%
% [ap,ep,rp] = poserr( az, el, r, x, y, z, yaw, pitch, roll )
%
% az - azimuth, degrees
% el - elevation, degrees
% r  - range, meters
% x,y,z,yaw,pitch, roll - subject positioning error, m, degrees (default 0)
%
% See also: sitderr

%234567890 234567890 234567890 234567890 234567890 234567890 234567890 234567890

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

% modification history
% --------------------
%                ----  v6.6.1  ----
% 04.11.12  JDM  created from sitd.m
%                ----  v6.7.1  ----
% 04.26.13  JDM  now independent of sitd.m;
%                sitderr.m -> poserr.m
%                ----  v6.7.2  ----
% 08.12.13  JDM  to slabtools
%
% JDM == Joel D. Miller

if nargin < 4, x = 0; end;
if nargin < 5, y = 0; end;
if nargin < 6, z = 0; end;
if nargin < 7, yaw = 0; end;
if nargin < 8, pitch = 0; end;
if nargin < 9, roll = 0; end;

d2r = pi/180;  % degs to rads
dEl = el*d2r;  % radians
dAz = az*d2r;  % radians

% apply listener positioning error to source

% SRAPI coords
%
% right-handed front-left-top x,y,z
% orientation +CCW looking down axis towards origin
%
% +x front
% +y left
% +z top
% +yaw left
% +pitch down
% +roll right
% +az right
% +el up

% slabmath.cpp RadsToRect() with x,y,z source translation
dXYRange = cos( dEl ) * r;
dX = cos( dAz ) * dXYRange - x;
dY = sin( dAz ) * dXYRange * -1.0 - y;
dZ = sin( dEl ) * r - z;

% viewing yaw,pitch,roll as mobile frame rotations:
% http://en.wikipedia.org/wiki/Euler_angles
% #Euler_angles_as_composition_of_intrinsic_rotations
%
% also helpful:
% http://en.wikipedia.org/wiki/Rotation_formalisms_in_three_dimensions
% #Rotation_matrix_.E2.86.94_Euler_angles
% http://en.wikipedia.org/wiki/Rotation_matrix#Euler_angles
% http://46dogs.blogspot.com/2011/04/right-handed-rotation-matrix-for.html

% mobile frame yaw,pitch,roll = rotation roll,pitch,yaw;
% y,p,r of subject = -y,-p,-r of source
% rotation matrix below from last ref above, their angles (or axes)
% opposite mine so no need to negate y,p,r
yaw = yaw*d2r;
pitch = pitch*d2r;
roll = roll*d2r;
rot = [ cos(pitch)*cos(yaw), ...
        -sin(yaw)*cos(roll) + cos(yaw)*sin(pitch)*sin(roll), ...
        sin(roll)*sin(yaw) + cos(yaw)*sin(pitch)*cos(roll);
        cos(pitch)*sin(yaw), ...
        cos(yaw)*cos(roll) + sin(pitch)*sin(yaw)*sin(roll), ...
        -sin(roll)*cos(yaw) + sin(pitch)*sin(yaw)*cos(roll);
        -sin(pitch), ...
        cos(pitch)*sin(roll), ...
        cos(pitch)*cos(roll) ];
dRot = [ dX dY dZ ] * rot;
dX = dRot(1);
dY = dRot(2);
dZ = dRot(3);

% slabmath.cpp RectToRads()
rp = sqrt( dX*dX + dY*dY + dZ*dZ );
ap = -atan2( dY, dX ) / d2r;
ep = asin( dZ / rp ) / d2r;
