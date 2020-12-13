% mimp - generates slab3d HRTF database containing impulses.
%
% mimp is a macro - see source

% modification history
% --------------------
% 03.13.00  JDM   created, mm == map modify
% 10.18.02  JDM   name change, mmimp -> mimp (m = modify)
%
% JDM == Joel David Miller

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

% all HRIRs = impulse
Ir = zeros( 256, 286 );
Ir( 1, 1:286 ) = 32767;

% set all itds to 0
Itd = zeros( 1, 143 );

% form slab3d grid, group by azimuth (all el's at 180, at 150, etc.)
az = [180:-30:-180];
el = [90:-18:-90];
Map = [kron(ones(size(az)),el); kron(az,ones(size(el)))];

% write impulses-only database
mat2slab( 'slab_imp.slh', Ir, Itd, Map );
