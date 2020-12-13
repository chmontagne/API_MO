function [x,y,z] = llh2ecef(lat, lon, height)
% llh2ecef() - LLH to ECEF coordinate conversion
%
%   lat       latitude  (degrees, +90N to -90S)
%   lon       longitude (degrees, -180W to +180E)
%   height    height    (meters)
%
% Coordinate System Acronyms:
%   LLH  - Latitude, Longitude, Height
%   ECEF - Earth-Centered, Earth-Fixed
%   ENU  - East, North, Up
%
% Reference: S.P. Drake, "Converting GPS Coordinates (LLH) to Navigation
%            Coordinates (ENU)", DSTO-TN-0432.pdf
%
% See srapi_state.cpp LLH2ECEF().
%
% See Also: ecef2enum(), wgstest3

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

% degs to rads
lat = lat * pi / 180;
lon = lon * pi / 180;

% WGS-84 "a" ellipsoid constant used in LLH/ECEF/ENU conversions,
% major axis length in meters (center of ellipsoid to equator)
WGS84_a = 6378137.0;

% WGS-84 "b" ellipsoid constant used in LLH/ECEF/ENU conversions,
% minor axis length in meters (center of ellipsoid to north/south poles)
WGS84_b = 6356752.31414;

% WGS-84 "e" ellipsoid constant used in LLH/ECEF/ENU conversions,
% first eccentricity squared
WGS84_e2 = (1.0 - (WGS84_a/WGS84_b)*(WGS84_a/WGS84_b));

sinLat = sin(lat);
tmp = WGS84_a / sqrt(1 - WGS84_e2 * sinLat * sinLat);

x = (tmp + height) * cos(lat) * cos(lon);
y = (tmp + height) * cos(lat) * sin(lon);
z = (tmp * (1 - WGS84_e2) + height) * sinLat;
