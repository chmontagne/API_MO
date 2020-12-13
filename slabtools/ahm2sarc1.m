function ha = ahm2sarc1( ahmfile )
% ahm2sarc1 - converts 2006-era HeadZap AHM file to slab3d archive.
%
% ha = ahm2sarc1( ahmfile )
%
% ahmfile - AHM filename (e.g., 'jdm1.ahm')
%
% ha - AHM data slab3d archive struct

% modification history
% --------------------
%                ----  v5.8.1  ----
% 06.07.06  JDM  created from zap2sarc()
%                ----  v6.7.5  ----
% 03.18.15  JDM  added '1' suffix to denote 2006-era first iteration
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
  disp( 'ahm2sarc error: not enough input arguments.' );
  return;
end;

% >> which ahmread
% c:\ausim\headzap\utils\AHMread.m

% >> help ahmread
%
% [IRdata, TDdata, subject, comments, srate, responses, location, taps, ...
%		resolution, conversion, axis, vectorSeq, eq, encryption, window, headsize, ...
%			bassBoost, hdtrk, hdtrkData] = AHMread(filename)
% filename      -   name of AHM file 
% IRdata        -   impulse response data stored as an Nx1 array 
%                   where the impulse response data is stored as:
%                      [left(1:taps.ir), right(1:taps.ir), left(1:taps.ir), right(1:taps.ir,...]
% TDdata        -   ITD data stored as an Nx1 array
%
% subject       -   subject name
% comments      -   comments
% srate         -   sampling rate
% responses     -   responses.total: total responses stored
%                   responses.azimuth: grid azimuth responses
%                   responses.elevation: grid elevation responses
%                   responses.range: grid range responses
% location      -   location.azimOrg:    azimuth of the origin measured location
%                   location.elevOrg:    azimuth of the origin measured location
%                   location.rangOrg:    range of the origin measured location
%                   location.azimInt:    azimuth interval between measured locations
%                   location.elevInt:    elevation interval between measured locations
%                   location.rangInt:    range interval between measured locations
% taps          -   taps.ir:            number of response taps
%                   taps.optimization:  compression optimization size
%                   taps.components:    response components (number of weights if PCA)
%                   taps.zero:          response tap zero coefficients (zeros per tap)     
%                   taps.pole:          response tap pole coefficients (poles per tap)     
% resolution    -   resolution.data:    bits per coefficient
%                   resolution.itd:     bits per delay
%                   resolution.weight:  bits per weight
% conversion    -   fixed point coefficient conversion value
% axis          -   axis configuration:  0=none,
%                                        1=Spherical_ZYR,    // CRE/UWMadison default
%                                        2=Spherical_YXR,    // UCDavis default
%                                        3=Spherical_XZR,
%                                        4=Cylindrical_ZHR,  // AuSIM AHM default
%                                        5=Cylindrical_YHR,
%                                        6=Cylindrical_XHR,
%                                        7=Cartesian_YZX
% vectorSeq     -   vector sequence:    stored as a three-element vector where 1=azim, 2=elev, 3=rang (e.g. [3 1 2])
% eq            -   eq.headphone: headphone equalization type: 
%                                        0=none,
%                                        1=headphones, 
%                                        2=nearphones, 
%                                        3=frontphones, 
%                                        4=rearphones,
%                                        5=SennheiserHD250,
%                                        6=SennheiserHD540,
%                                        7=SennheiserHD560,
%                                        8=SennheiserHD580,
%                                        9=SennheiserHD570,
%                                        10=SennheiserHD500,
%                                        11=SennheiserEH2200,
%                                        12=custom
%                                        
%                   eq.field: field equalization type: 
%                                        0=none,
%                                        1=diffuse,
%                                        2=free
%                                         
% encryption    -   encryption type:    0=none,
%                                       1=CRE,
%                                       2=AuSIM1
% window        -   window type:     0=none,
%                                    1=rectangular
%                                    2=bartlett
%                                    3=hamming
%                                    4=hanning    
%                                    5=kaiser
%                                    6=gausian
% headsize      -   interaural distance in range units
% bassBoost     -   bassBoost.on:       boost on (1) or off (0)
%                   bassBoost.freq:     bass boost frequency
% hdtrk         -   head tracking on (1) or off(0)
% hdtrkData		  -   head tracking data stored in an array of format:
%                   [location1(x),location1(y),location1(z),...
%                   location1(yaw),location1(pitch),location1(roll),...
%                   location2(x),location2(y),location2(z),...
%                   location2(yaw),location2(pitch),location2(roll),...]

% AHM
[ IRdata, TDdata, subject, comments, Srate, responses, location, taps, ...
  resolution, conversion, axis, vectorSeq, eq, encryption, window, headsize, ...
  bassBoost, hdtrk, hdtrkData ] = AHMread( ahmfile );

% >> whos
%   Name             Size           Bytes  Class
%
%   IRdata      221184x1          1769472  double array
%   Srate            1x1                8  double array
%   TDdata         432x1             3456  double array
%   ans              1x22              44  char array
%   axis             1x1                8  double array
%   bassBoost        1x1              264  struct array
%   comments         1x89             178  char array
%   conversion       1x1                8  double array
%   encryption       1x1                8  double array
%   eq               1x1              264  struct array
%   hdtrk            1x1                8  double array
%   hdtrkData        0x0                0  double array
%   headsize         1x1                8  double array
%   location         1x1              792  struct array
%   resolution       1x1              396  struct array
%   responses        1x1              528  struct array
%   subject          1x5               10  char array
%   taps             1x1              660  struct array
%   vectorSeq        1x3               24  double array
%   window           1x1                8  double array
%
% Grand total is 221786 elements using 1776144 bytes

% measured data
mirtemp = reshape( IRdata, taps.ir, length(IRdata)/taps.ir );
num = size(mirtemp,2);
mir(:,1:num/2)       = mirtemp(:,1:2:num);  % left ear
mir(:,1+(num/2):num) = mirtemp(:,2:2:num);  % right ear

% measured data grid (from AHM);
% construct measured grid from AHM's location and responses variables
azimDest = (location.azimOrg + location.azimInt * (responses.azimuth-1));
az = [ location.azimOrg : location.azimInt : azimDest ];
elevDest = (location.elevOrg + location.elevInt * (responses.elevation-1));
el = [ location.elevOrg : location.elevInt : elevDest ];
mgrid = [kron(ones(size(az)),el); kron(az,ones(size(el)))];

% measured data head-tracker grid (from AHM)
%
% This variable contains the head position errors read by the head tracker
% during measurement.
% Vector order: (x,y,z,yaw,pitch,roll)
% Polhemus coordinate system: +x forward, +y right, +z down,
%                             +yaw right, +pitch up, +roll right
%
% To compare this variable with AHMTools "Tracking data" display:
%   plot( h.dgrid(2,1:12:432), h.tgrid(1,1:12:432) )
%   x values at el=70 for all azimuths
%
% Units: In \AuSIM\HeadZap\headzap.tracker, "Units: 1" means x,y,z in cm's
% (according to AuSIM's Bryan Cook).  y,p,r appear to be in degrees.
mtgrid = reshape( hdtrkData, 6, length(hdtrkData)/6 );

% ahm data sarc (1 = finc, mp)
ha = smake( subject, 'headzap', comments, mir, TDdata', mgrid, 1, Srate, 1, ...
            mtgrid );

% save sarc
prefixa = [ ahmfile( 1 : findstr( ahmfile, '.' )-1 ) 'a' ];
fprintf( 'Saving %s.sarc ...\n', prefixa );
ssave( ha, prefixa );
fprintf( 'Done.\n\n' );
