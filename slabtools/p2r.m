function [ x y z ] = p2r( az, el, r )
% p2r - slab3d az,el,r to slab3d x,y,z.
%
% [ x y z ] = p2r( az, el, r )
%
% See also: r2p(), grids()

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

% slab3d az,el to slab3d x,y,z
% (see also: slabmath.cpp PolarToRect())
degs2rads = pi/180;
xyr = cos(el*degs2rads) * r;
x = cos( az*degs2rads ) * xyr;
y = sin( az*degs2rads ) * xyr * -1.0;
z = sin( el*degs2rads ) * r;
