function h = cipic2sarc( matName, name, comment, sarcName )
% cipic2sarc - converts a CIPIC .mat to a slab3d archive.
%
% h = cipic2sarc( matName, name, comment, sarcName )
%
% matName  - name of .mat file ('' and default = 'hrir_final.mat')
% name     - subject name (default = 'noname')
% comment  - comment string (default = '')
% sarcName - if present, saves sarc to file (do not include .sarc extension)
%
% h - slab3d archive struct
%
% If 'name' field found in .mat file, it is used for the subject name.
% Currently, no sarc eq fields are set.
%
% See also: cipic2slab

% modification history
% --------------------
%                ----  v5.4.0  ----
% 10.15.03  JDM  created
% 10.30.03  JDM  core code
% 11.21.03  JDM  updated to new v4 sarc
% 01.07.04  JDM  added CIPIC readme comment
%                ----  v5.5.0  ----
% 06.09.04  JDM  added azinc, elinc init
%                ----  v6.6.0  ----
% 03.16.11  JDM  inline coord conversion to c2s()
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

% Raw data to processed data:
%   Snapshot: RAW2DTF.M
%   HeadZap:  mat2ahm.m

% parameter defaults
if nargin < 1,  matName = 'hrir_final.mat';  end;
if nargin < 2,  name    = 'noname';          end;
if nargin < 3,  comment = '';                end;

if isempty( matName ),
  matName = 'hrir_final.mat';
end;

% From "Fritz CIPIC Data" README.TXT:
%
% Data in the freefield/ directory was recorded using an Earthworks M30
% microphone and 5 Bose satellite speakers. Contained in the file ffraw.mat
% are 5 impulse response vectors, named bose_1, bose_2 ..., bose_5, these
% correspond to each of the Bose loudspeakers.
%
% Data files named hrir_final.mat contain free field compensated records in the
% standard CIPIC data format. (see hrir_data_documentation.pdf)
%
% Data files named hrir_raw.mat contain the raw (no compensation) data used in
% making the hrir_final file. (in the standard CIPIC data format)

% Currently, the freefield data mentioned above is not added to the sarc.

% >> load hrir_final
% >> whos
%   Name         Size           Bytes  Class
%
%   ITD         25x50           10000  double array
%   OnL         25x50           10000  double array
%   OnR         25x50           10000  double array
%   hrir_l      25x50x200     2000000  double array
%   hrir_r      25x50x200     2000000  double array
%   name         1x11              22  char array

fprintf( 'Opening %s ...\n', matName );
s = load( matName, '-mat' );

if isfield( s, 'name' ),
  name = s.name;
end;

% sarc struct
% smake( name, source, comment, ir, itd, dgrid, finc, fs, mp, tgrid, ...
%        eqfs, eqm, eqf, fgrid, eqd, eqb, eqh, hcom )
h = smake( name, 'cipic', comment, [], [], [], 0 );

% cipic grid map
% els-grouped-by-az (e.g., all els at -80 az and so on)
% cmap( 1, index ) = el; cmap( 2, index ) = az
caz = [ -80 -65 -55 -45:5:45 55 65 80 ];
cel = -45 + 5.625*(0:49);
cmap = [kron(ones(size(caz)),cel); kron(caz,ones(size(cel)))];

if size(s.hrir_l,1) ~= length(caz) | size(s.hrir_l,2) ~= length(cel),
  disp('cipic2sarc error: hrir data doesn''t match default cipic grid.');
  return;
end;

resp = length(caz) * length(cel);
% MUCH faster to pre-allocate array
h.ir = zeros( size(s.hrir_l,3), resp * 2 );

% Use the fixed-inc increment vars as grouping parameters.  Even though the
% CIPIC definitions of az and el differ from sarc, the data are still ordered
% el grouped by az (e.g., 50 els at one az over 25 azs).
h.azinc = length(caz);
h.elinc = length(cel);

% cipic measurement grid and data to sarc format
fprintf( 'Format conversion...\n' );
h.dgrid = [];
i = 0;
for az=1:length(caz),
  for el=1:length(cel),
    i = i + 1;
    % cipic interaural polar to slab3d vertical polar
    [ saz sel ] = c2s( cmap(2,i), cmap(1,i) );
    h.dgrid = [ h.dgrid [sel;saz] ];
    h.ir( :, (az-1)*length(cel) + el ) = squeeze(s.hrir_l(az,el,:));
    h.ir( :, (az-1)*length(cel) + el + resp ) = squeeze(s.hrir_r(az,el,:));
  end;
end;

% save sarc
if nargin > 3,
  fprintf( 'Saving %s.sarc ...\n', sarcName );
  ssave( h, sarcName );
end;

fprintf( 'Done.\n\n' );
