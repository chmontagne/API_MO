function [enuE, enuN, enuU ] = ecef2enu(ecefX, ecefY, ecefZ, oLat, oLon, oH)
% ecef2enu() - ECEF to ENU coordinate conversion
%
%   oLat, oLon, oH - LLH origin reference for local ENU coordinate system
%
% Coordinate System Acronyms:
%   LLH  - Latitude, Longitude, Height
%   ECEF - Earth-Centered, Earth-Fixed
%   ENU  - East, North, Up
%
% Reference: S.P. Drake, "Converting GPS Coordinates (LLH) to Navigation
%            Coordinates (ENU)", DSTO-TN-0432.pdf
%
% See srapi_state.cpp ECEF2ENU().
%
% See also: llh2ecef(), wgstest3

% modification history
% --------------------
%                ----  v6.8.1  ----
% 11.16.16  JDM  created
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

% origin translation, originLLH in ECEF coords for applying translation
[otX otY otZ] = llh2ecef(oLat, oLon, oH);

% origin translation
x = ecefX - otX;
y = ecefY - otY;
z = ecefZ - otZ;

% origin rotation

% degs to rads
oLat = oLat * pi / 180;
oLon = oLon * pi / 180;

cosLat = cos(oLat);
sinLat = sin(oLat);
cosLon = cos(oLon);
sinLon = sin(oLon);

matRot = ...
[ ...
  [ -sinLon,           cosLon,          0.0    ]; ...
  [ -sinLat * cosLon, -sinLat * sinLon, cosLat ]; ...
  [  cosLat * cosLon,  cosLat * sinLon, sinLat ]  ...
];

% C++ to matlab, so...
enuE = matRot(1,1) * x + matRot(1,2) * y + matRot(1,3) * z;
enuN = matRot(2,1) * x + matRot(2,2) * y + matRot(2,3) * z;
enuU = matRot(3,1) * x + matRot(3,2) * y + matRot(3,3) * z;

%enu = matRot * [x y z]';
%enuE = enu(1);
%enuN = enu(2);
%enuU = enu(3);
