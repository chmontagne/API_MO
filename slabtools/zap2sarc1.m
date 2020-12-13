function [ hp, hm ] = zap2sarc1( prefix, ff, bb )
% zap2sarc1 - converts 2006-era HeadZap output to slab3d archive.
%
% [ hp, hm ] = zap2sarc1( prefix, ff, bb )
%
% prefix - initials of subject with optional measurement number appended
%          (e.g., 'jdm1' for first time jdm measured)
% ff     - free-field EQF file, filename string or:
%            1       = 'C:\AuSIM\EQ\ff_EQ96kHz.eqf'
%            0       = none
%            default = 1
% bb     - bass-boost EQF file, filename string or:
%            1       = 'C:\AuSIM\EQ\BassBoost96k.eqf'
%            0       = none
%            default = 0
%
% hp - processed data slab3d archive struct
% hm - measured data slab3d archive struct
%
% The following input files must exist:
%   prefix.slh - slab3d HRTF database generated by AHMTools
%   prefix.ahm - AHM HRTF database generated by HeadZap
%   prefix.mat - raw data MAT-file generated by HeadZap
%
% The following input file is optional:
%   prefix.eqf - headphone EQ data generated by PhonEQ
%
% Output:
%   <prefix>p.sarc - slab3d archive file, processed data
%   <prefix>m.sarc - slab3d archive file, measured data

% modification history
% --------------------
% 11.13.02  JDM  created
%                ----  v5.2.1  ----
% 07.23.03  JDM  added AHMread
%                ----  v5.3.0  ----
% 08.15.03  JDM  main functionality
% 08.19.03  JDM  grid, raw ir, headphone ir extraction
% 08.20.03  JDM  fgrid, eqf, eqb extraction
% 09.12.03  JDM  added hdtrkData copy (AR fixed AHMread() bug), ff_EQ96kHz.eqf
%                comment
% 09.23.03  JDM  updated tracking data comments
%                ----  v5.4.0  ----
% 10.29.03  JDM  added h.mazinc,h.melinc set
% 11.21.03  JDM  updated to new v4 sarc
% 11.26.03  JDM  added second save fprintf()
%                ----  v5.5.0  ----
% 06.18.04  JDM  added slab2sarc() error check; made headphone eqf optional
% 08.20.04  JDM  added new PhonEQ/eqf comments
%                ----  v5.7.0  ----
% 07.14.05  JDM  added PhoneQ measured data extraction (sarc version not
%                incremented because no tools presently use eqh)
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
  disp( 'zap2sarc error: not enough input arguments.' );
  return;
end;

% parameter defaults
if nargin < 2,
  ff = 1;
end;
if nargin < 3,
  bb = 0;
end;

% filename defaults
if ff == 1,
  ff = 'C:\AuSIM\EQ\ff_EQ96kHz.eqf';
end;
if bb == 1,
  bb = 'C:\AuSIM\EQ\BassBoost96k.eqf';
end;

% HeadZap processed data is in an SLH file
slh = sprintf( '%s.slh', prefix );
fprintf( 'Opening %s ...\n', slh );

% processed data sarc
hp = slab2sarc( slh );

% check for slab2sarc() error
if isempty( hp ),
  disp('zap2sarc: ERROR - slab2sarc() failed.');
  hp = [];
  hm = [];
  return;
end;

% HeadZap is the actual source of the data
hp.source = 'headzap';

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
% hdtrkData		 -   head tracking data stored in an array of format:
%                   [location1(x),location1(y),location1(z),...
%                   location1(yaw),location1(pitch),location1(roll),...
%                   location2(x),location2(y),location2(z),...
%                   location2(yaw),location2(pitch),location2(roll),...]

% AHM
ahm = sprintf( '%s.ahm', prefix );
fprintf( 'Opening %s ...\n', ahm );
[ IRdata, TDdata, subject, comments, Srate, responses, location, taps, ...
  resolution, conversion, axis, vectorSeq, eq, encryption, window, headsize, ...
  bassBoost, hdtrk, hdtrkData ] = AHMread( ahm );

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

% measured data grid (from AHM)

% construct measured grid from AHM's location and responses variables
azimDest = (location.azimOrg + location.azimInt * (responses.azimuth-1));
az = location.azimOrg : location.azimInt : azimDest;
elevDest = (location.elevOrg + location.elevInt * (responses.elevation-1));
el = location.elevOrg : location.elevInt : elevDest;
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
% (according to Bryan Cook).  y,p,r appear to be in degrees.

mtgrid = reshape( hdtrkData, 6, length(hdtrkData)/6 );

% measured data (from HeadZap raw data .mat)

% >> load saj1.mat
%
% azimuth_array         1x36             288  double array (global)
% elevation_array       1x12              96  double array (global)
% ir_length             1x1                8  double array (global)
% rawData               2x1024x432   7077888  double array (global)
% srate                 1x1                8  double array (global)
% subject_name          1x4                8  char array (global)
% tdData                2x432           6912  double array (global)
%
% AHM TDdata grouped by az, .mat tdData grouped by el.
% tdData(2,:) all 0's.
% To see that the two tddata's are equivalent:
% a=[];for az=1:36, for el=1:12, a = [a tdData(1,(el-1)*36+az)], end, end;
%
% For rawData access, see ahmtool mat2ahm.m and HeadZap function getRawPair.m.
% By eye, rawData looks grouped-by-el:
% for i=1:432, plot(1:1024,rawData(1,:,i),'r',1:1024,rawData(2,:,i),'b');pause;end;
%
% All raw .mat data but rawData can be read from .ahm.
% One can generate *_array vars from ahm's responses and location vars.

% load raw data
mat = sprintf( '%s.mat', prefix );
fprintf( 'Opening %s ...\n', mat );
s = load( mat, '-mat' );

% copy azs-grouped-by-el hz raw data to els-grouped-by-az sarc
mir = zeros( size(s.rawData,2), size(mgrid,2) * 2 );
i = 0;
for el = max(mgrid(1,:)) : location.elevInt : min(mgrid(1,:))
  for az = max(mgrid(2,:)) : location.azimInt : min(mgrid(2,:))
    i = i + 1;  % hz raw data index
    % left
    mir( :, hil(az,el,mgrid) ) = s.rawData(1,:,i)';
    % right
    mir( :, hir(az,el,mgrid) ) = s.rawData(2,:,i)';
  end;
end;

% measured data sarc
hm = smake( hp.name, 'headzap', hp.comment, mir, [], mgrid, 1, Srate, 0, ...
            mtgrid );

% headphone EQF

eqf = sprintf( '%s.eqf', prefix );
fprintf( 'Opening %s ...\n', eqf );
fp = fopen(eqf);
if fp == -1,
  disp(['zap2sarc: WARNING - headphone eqf file <', eqf, '> not found.']);
else,
  fclose( fp );

	[ IRdata, TDdata, subject, comments, Srate, responses, location, taps, ...
      resolution, conversion, axis, vectorSeq, eq, encryption, window, headsize, ...
      bassBoost, hdtrk, hdtrkData ] = AHMread( eqf );
	
  % relevant vars
  %
	%   IRdata         512x1             4096  double array
	%   Srate            1x1                8  double array
	%   comments         1x68             136  char array
	%   responses        1x1              528  struct array
	%   subject          1x5               10  char array
	%   taps             1x1              660  struct array
	
	% New PhonEQ and headphone eqf format, tested 8/04.
  % This format includes the three raw measurements after the correction
  % filter.
	%
	%   IRdata        8192x1            65536  double array
	%   Srate            1x1                8  double array
	%   comments         1x57             114  char array
	%   responses        1x1              528  struct array
	%         total: 8
	%       azimuth: 1
	%     elevation: 4
	%         range: 1
	%   subject          1x1                2  char array
	%   taps             1x1              660  struct array
	%               ir: 1024
	%     optimization: 0
	%             zero: 1
	%             pole: 0
	%       components: 0

	% copy headphone inverse filter and responses
  % IRdata: L_inv,R_inv,(L_measure,R_measure)x3
	hp.eqh = reshape( IRdata, taps.ir, 8 );

	% copy headphone comments, sampling rate
	hp.hcom = comments;
	hp.eqfs = Srate;
end;

% free-field EQF

% ff_EQ96kHz.eqf: use AHMread, data in IRdata, max = 0.0156, min = -0.0102
% (range +/- 1.0, the max and min reflect the levels of the actual recording),
% several 256pt responses back-to-back.  The locations of the measured data is
% stored in header. For example, when measuring the free field eq of the setup
% at Ames, the information about the locations stored would contain all the
% elevations, +70:-10:-40.  The data is stored by elevation at az = 0,
% therefore you would have the left and right channel data of the first
% measured elevation followed by the second elevation and so on.

if ischar( ff ),
  fprintf( 'Opening %s ...\n', ff );
  [ IRdata, TDdata, subject, comments, Srate, responses, location, taps, ...
    resolution, conversion, axis, vectorSeq, eq, encryption, window, headsize, ...
    bassBoost, hdtrk, hdtrkData ] = AHMread( ff );

	%  IRdata        6144x1            49152  double array
	%  location         1x1              792  struct array
	%    azimOrg: 0
	%    azimInt: 0
	%    elevOrg: 70
	%    elevInt: -10
	%    rangOrg: 0.5000
	%    rangInt: 0
	%  responses        1x1              528  struct array
	%        total: 24
	%      azimuth: 1
	%    elevation: 12
	%        range: 1
	%  subject          1x13              26  char array
	%    free field EQ
	%  taps             1x1              660  struct array
	%              ir: 256
	%    optimization: 0
	%            zero: 1
	%            pole: 0
	%      components: 0

	% construct grid from AHM's location and responses variables
	azimDest = (location.azimOrg + location.azimInt * (responses.azimuth-1));
	if location.azimInt == 0,
    location.azimInt = -1;  % 0:0:0 returns empty matrix, 0:-1:0 returns [0]
	end;
	az = [ location.azimOrg : location.azimInt : azimDest ];
	elevDest = (location.elevOrg + location.elevInt * (responses.elevation-1));
	el = [ location.elevOrg : location.elevInt : elevDest ];
	hp.fgrid = [kron(ones(size(az)),el); kron(az,ones(size(el)))];
  	
  % both hz and sarc grouped-by-az;
	% copy left, right concatenated to all individual left responses,
  % all individual right responses
	hp.eqf = zeros( taps.ir, responses.total );
	i = 1;
  for az = max(hp.fgrid(2,:)) : location.azimInt : min(hp.fgrid(2,:))
    for el = max(hp.fgrid(1,:)) : location.elevInt : min(hp.fgrid(1,:))
      % left
      hp.eqf( :, hil(az,el,hp.fgrid) ) = IRdata(i:(i+taps.ir-1));
      i = i + taps.ir;
      % right
      hp.eqf( :, hir(az,el,hp.fgrid) ) = IRdata(i:(i+taps.ir-1));
      i = i + taps.ir;
    end;
	end;
end;

% bass-boost EQF

if ischar( bb ),
  fprintf( 'Opening %s ...\n', bb );
  [ IRdata, TDdata, subject, comments, Srate, responses, location, taps, ...
    resolution, conversion, axis, vectorSeq, eq, encryption, window, headsize, ...
    bassBoost, hdtrk, hdtrkData ] = AHMread( bb );

	%   IRdata         512x1             4096  double array
	%   Srate            1x1                8  double array
  %     96000
	%   location         1x1              792  struct array
	%     azimOrg: 0
	%     azimInt: 0
	%     elevOrg: 0
	%     elevInt: 0
	%     rangOrg: 0.5000
	%     rangInt: 0
	%   responses        1x1              528  struct array
	%         total: 2
	%       azimuth: 1
	%     elevation: 1
	%         range: 1
	%   subject          1x10              20  char array
  %     bass boost
	%   taps             1x1              660  struct array
	%               ir: 256
	%     optimization: 0
	%             zero: 1
	%             pole: 0
	%       components: 0

  % copy bass-boost response;
  % HeadZap will correct for this filter, thus this is a -2dB low-freq cut,
  % 0dB high-pass filter (e.g., see freqz(h.eqb(:,1)))
  hp.eqb(:,1) = IRdata( 1 : taps.ir );
  hp.eqb(:,2) = IRdata( taps.ir+1 : 2*taps.ir );
end;

% save sarc
prefixp = [ prefix 'p' ];
prefixm = [ prefix 'm' ];
fprintf( 'Saving %s.sarc ...\n', prefixp );
ssave( hp, prefixp );
fprintf( 'Saving %s.sarc ...\n', prefixm );
ssave( hm, prefixm );
fprintf( 'Done.\n\n' );
