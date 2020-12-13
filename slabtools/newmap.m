function map = newmap( azInc, elInc, azMax, azMin, elMax, elMin )
% newmap - generates Snapshot map (grouped-by-elevation).
%
% map = newmap( azInc, elInc, azMax, azMin, elMax, elMin )
%
% defaults: 30, 18, 180, -150, 54, -36

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% modification history
% --------------------
% 06.20.01  JDM   created
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

% defaults
if nargin < 6
  elMin = -36;
end;
if nargin < 5;
  elMax = 54;
end;
if nargin < 4;
  azMin = -150;
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

az  = [azMax:-azInc:azMin];
el  = [elMax:-elInc:elMin];
map = [kron(el,ones(size(az))); kron(ones(size(el)),az)];
