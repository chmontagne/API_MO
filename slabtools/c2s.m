function [ saz sel x y z ] = c2s( caz, cel )
% c2s - CIPIC interaural-polar coords to slab3d vertical-polar/rectangular coords.
%
% [ saz sel x y z ] = c2s( caz, cel )
%
% saz   - slab3d azimuth, positive right, -180 to +180, degrees.
% sel   - slab3d elevation, positive up, -90 to +90, degrees.
% x,y,z - saz,sel unit vector components (slab3d coords).
% caz   - CIPIC azimuth, positive right, -90 to +90, degrees.
% cel   - CIPIC elevation, positive up-to-behind, -90 to +270, degrees.
%
% See also: c2r(), grids()

% modification history
% --------------------
%                ----  v6.6.0  ----
% 03.16.11  JDM  created
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

% cipic az,el to slab3d x,y,z
x = cos( caz*pi/180 ) * cos( cel*pi/180 );
y = sin( caz*pi/180 ) * -1.0;
z = cos( caz*pi/180 ) * sin( cel*pi/180 );

% slab3d x,y,z to slab3d az,el
% (see also: slabmath.cpp RectToPolar())
saz = atan2(-y,x)*180/pi;
sel = asin(z/sqrt(x*x+y*y+z*z))*180/pi;
%sel = atan2(z,sqrt(x*x+y*y))*180/pi;  % equivalent
