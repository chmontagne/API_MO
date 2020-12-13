function h = slab2sarc( slabhrtf, sarcName )
% slab2sarc - converts a slab3d HRTF database to slab3d archive.
%
% h = slab2sarc( slabhrtf, sarcName )
%
% slabhrtf - slab3d HRTF database (.slh)
% sarcName - if present, saves sarc to file (do not include .sarc extension)
%
% h - slab3d archive struct

% modification history
% --------------------
% 11.13.02  JDM  created
%                ----  v5.3.0  ----
% 08.15.03  JDM  updated to new smake()
% 09.15.03  JDM  added slab2mat usage example
%                ----  v5.4.0  ----
% 11.21.03  JDM  updated to new v4 sarc
%                ----  v5.5.0  ----
% 06.18.04  JDM  added slab2mat() error check
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
  disp( 'slab2sarc error: not enough input arguments.' );
  return;
end;

% slab3d HRTF usage example:
%
% >> [hrir,itd,map]=slab2mat('\slab3d\hrtf\jdm.slh');
% >> whos
%   Name       Size           Bytes  Class
%
%   hrir     128x286         292864  double array
%   itd        1x143           1144  double array
%   map        2x143           2288  double array
%
% map els-grouped-by-azimuth.
%
% >> hinfo('jdm.slh');
%
% Filename:             jdm.slh
% Size:                 147312 bytes
% Version:              slab3d 2
% Name:                 Joel David Miller
% Date:                 11/08/2002
% Azimuth Increment:    30
% Elevation Increment:  18
% HRIR Points:          128
% Sampling Rate:        44100
% Comment:
%   ITDs corrected
%
% Name is 32 chars and Comment is 256 chars.

% slab3d HRTF database data and header
[ ir, itd, map, version, name, strDate, comment, azInc, elInc, numPts, fs ] ...
  = slab2mat( slabhrtf );

% check for slab2mat() error
if isempty( ir ),
  disp('slab2sarc: ERROR - slab2mat() failed.');
  h = [];
  return;
end;

% sarc struct (finc = 1, mp = 1)
h = smake( name, 'slabslh', comment, ir, itd, map, 1, fs, 1 );

% save sarc
if nargin > 1,
  ssave( h, sarcName );
end;
