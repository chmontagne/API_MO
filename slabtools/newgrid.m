function gridout = newgrid( azInc, elInc, azMax, azMin, elMax, elMin )
% newgrid - generates slab3d grid (elevations-grouped-by-azimuth).
%
% gridout = newgrid( azInc, elInc, azMax, azMin, elMax, elMin )
%
% defaults: 30, 18, 180, -180, 54, -36

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% modification history
% --------------------
%                ----  v5.3.0  ----
% 09.15.03  JDM  created from newmap.m
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

% defaults
if nargin < 6
  elMin = -36;
end;
if nargin < 5;
  elMax = 54;
end;
if nargin < 4;
  azMin = -180;
end;
if nargin < 3;
  azMax = 180;
end;
if nargin < 2;
  elInc = 18;
end;
if nargin < 1;
  azInc = 30;
end;

% form slab3d grid, els-grouped-by-az (all el's at 180, at 150, etc.)
az  = [azMax:-azInc:azMin];
el  = [elMax:-elInc:elMin];
gridout = [kron(ones(size(az)),el); kron(az,ones(size(el)))];
