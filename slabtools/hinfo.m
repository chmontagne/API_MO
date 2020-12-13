function [version,name,strDate,comment,azInc,elInc,numPts,fs]=hinfo(fileName)
% hinfo - displays HRTF database information.
%
% [v,n,d,c,a,e,p,f] = hinfo( fileName )
%
% fileName - HRTF database filename (slab3d and 44.1k tron)
%
% v - version number
% n - name string
% d - date string
% c - comment string
% a - azimuth increment
% e - elevation increment
% p - number of HRIR points
% f - sample rate
%
% Note: return values are only valid for slab3d Version 2 HRTF databases.

% modification history
% --------------------
% 06.18.01  JDM   created
% 06.22.01  JDM   removed SLAB Version 2 type check - Version 2 HRTF dbs can be
%                 different sizes; added return values, shead2()
% 11.13.02  JDM   removed str2mat()' - fixed strings in shead2()
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

% open HRTF database
fid = fopen(fileName, 'r', 'l');
if( fid == -1 ),
  disp(['hinfo: ERROR - Cannot open file <', fileName, '>.']);
  return;
end;

% determine database type
fseek( fid, 0, 'eof' );
type = ftell( fid );
fseek( fid, 0, 'bof' );

fprintf( '\n' );
% tron database
if( type == 73872 ),
  fprintf( 'Filename:             %s\n', fileName );
  fprintf( 'Size:                 %d bytes\n', type );
  fprintf( 'Version:              Tron\n' );
% slab3d Version 1 database
elseif( type == 146718 ),
  fprintf( 'Filename:             %s\n', fileName );
  fprintf( 'Size:                 %d bytes\n', type );
  fprintf( 'Version:              SLAB 1\n' );
  fprintf( 'Azimuth Increment:    30\n' );
  fprintf( 'Elevation Increment:  18\n' );
  fprintf( 'HRIR Points:          256\n' );
  fprintf( 'Sampling Rate:        44100\n' );
% assume slab3d Version 2 database
% ( type == 147312 for 30,18 az,el inc )
else,
  % read header
  [version,name,strDate,comment,azInc,elInc,numPts,fs] = shead2(fid);

  % display database information
  fprintf( 'Filename:             %s\n', fileName );
  fprintf( 'Size:                 %d bytes\n', type );
  fprintf( 'Version:              slab3d %d\n', version );
  fprintf( 'Name:                 %s\n', name );
  fprintf( 'Date:                 %s/%s/%s\n', ...
    strDate(1:2), strDate(3:4), strDate(5:8) );
  fprintf( 'Azimuth Increment:    %d\n', azInc   );
  fprintf( 'Elevation Increment:  %d\n', elInc   );
  fprintf( 'HRIR Points:          %d\n', numPts  );
  fprintf( 'Sampling Rate:        %d\n', fs      );
  fprintf( 'Comment:\n  %s\n',           comment );
end;
fprintf( '\n' );

fclose(fid);
