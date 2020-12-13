function [ az el r ] = r2p( x, y, z )
% r2p - slab3d x,y,z to slab3d az,el,r.
%
% [ az el r ] = r2p( x, y, z )
%
% See also: p2r(), grids()

% modification history
% --------------------
%                ----  v6.7.1  ----
% 03.21.13  JDM  created
%                ----  v6.7.2  ----
% 08.12.13  JDM  to slabtools
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

% slab3d x,y,z to slab3d az,el
% (see also: slabmath.cpp RectToPolar())
r  = sqrt( x*x + y*y + z*z );
az = atan2(-y,x)*180/pi;
el = asin(z/r)*180/pi;
%el = atan2(z,sqrt(x*x+y*y))*180/pi;  % equivalent
