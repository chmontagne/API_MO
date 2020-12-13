function h = cam2sarc( matName, name, comment, sarcName )
% cam2sarc - converts IRCAM raw HRIR .mat to slab3d archive.
%
% h = cam2sarc( matName, name, comment, sarcName )
%
% matName  - name of .mat file
% name     - subject name
% comment  - comment string
% sarcName - if present, saves sarc to file (do not include .sarc extension)
%
% h - slab3d archive struct

% modification history
% --------------------
%                ----  v5.3.0  ----
% 09.15.03  JDM  created
%                ----  v5.4.0  ----
% 11.21.03  JDM  updated to new v4 sarc
% 01.07.04  JDM  added IRCAM readme comment
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

% From IRCAM ReadMe.txt:
% Measurements supplied have not been equalized in any way. Provided are
% 3 calibration files which are the "free-field" measures of the
% loudspeaker-mic system without subject. These could be used to free-field
% equalize 1517.

if nargin < 1,
  disp( 'cam2sarc error: not enough input arguments.' );
  return;
end;

% parameter defaults
if nargin < 2,
  name = 'noname';
end;
if nargin < 3,
  comment = '';
end;

% raw data to processed data:
%   Snapshot: RAW2DTF.M
%   HeadZap:  mat2ahm.m

% load 1517raw.mat
%
% l_hrir_S       1x1         16547962  struct array
% r_hrir_S       1x1         16547962  struct array
%
%          type_s: 'FIR'
%          elev_v: [2016x1 double]
%          azim_v: [2016x1 double]
%     sampling_hz: 44100
%       content_m: [2016x1024 double]

fprintf( 'Opening %s ...\n', matName );
s = load( matName, '-mat' );

% slab3d +az right (-175:180), IRCAM +az left (0:355)
% convert IRCAM az (0:5:355) to slab3d az (0:-5:-175,180:-5:5)
imgrid = [ s.l_hrir_S.elev_v'; -s.l_hrir_S.azim_v' ];
for i = 1:size( imgrid, 2 ),
  if( imgrid(2,i) <= -180 ),
    imgrid(2,i) = imgrid(2,i) + 360;
  end;
end;

% slab3d grid corresponding to IRCAM grid
%   SLAB, els-grouped-by-az, az's (180:-180) and el's (90:-90) decrease
%   IRCAM, azs-grouped-by-el, az's (0:-5:-175,180:-5:5) decrease and
%     el's (-45:5:90) increase
smgrid = newgrid( -min(diff(imgrid(2,1:100))), max(diff(imgrid(1,1:100))), ...
                  max(imgrid(2,:)), min(imgrid(2,:)), ...
                  max(imgrid(1,:)), min(imgrid(1,:)) );

% sarc struct
% smake( name, source, comment, ir, itd, dgrid, finc, fs, mp, tgrid, ...
%        eqfs, eqm, eqf, fgrid, eqd, eqb, eqh, hcom )
h = smake( name, 'ircam', comment, [], [], smgrid, 1, s.l_hrir_S.sampling_hz );

% MUCH faster to pre-allocate array (i.e., this line can be omitted but much
% slower execution results)
h.ir = zeros( size(s.l_hrir_S.content_m,2), 2*size(s.l_hrir_S.content_m,1) );

fprintf( 'Format conversion...\n' );

% left ear responses
for i = 1:size( smgrid, 2 ),
  h.ir(:,i) = ...
    s.l_hrir_S.content_m( hil( smgrid(2,i), smgrid(1,i), imgrid ), : )';
  if ~mod(i,10),
    fprintf('.'); % status indicator
  end;
  if ~mod(i,600),
    fprintf('\n');
  end;
end;

% right ear responses
for j = 1:size( smgrid, 2 ),
  i = i + 1;
  h.ir(:,i) = ...
    s.r_hrir_S.content_m( hil( smgrid(2,j), smgrid(1,j), imgrid ), : )';
  if ~mod(i,10),
    fprintf('+'); % status indicator
  end;
  if ~mod(i,600),
    fprintf('\n');
  end;
end;

fprintf('\n');

% save sarc
if nargin > 3,
  fprintf( 'Saving %s.sarc ...\n', sarcName );
  ssave( h, sarcName );
end;

fprintf( 'Done.\n\n' );
