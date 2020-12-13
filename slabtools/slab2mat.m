function [ir,itd,map,version,name,strDate,comment,azInc,elInc,numPts,fs] ...
  = slab2mat( fileName )
% slab2mat - reads a slab3d-format HRTF file.
%
% [ hrir, itd, map, v, n, d, c, a, e, p, f ] = slab2mat( slabfile )
%
% slabfile - slab3d HRTF database file (.slh)
%
% hrir - all left-ear followed by all right-ear impulse responses
% itd  - interaural time delays
% map  - measurement grid
% v    - version number
% n    - name string
% d    - date string
% c    - comment string
% a    - azimuth increment
% e    - elevation increment
% p    - number of HRIR points
% f    - sample rate
%
% slab2mat returns the HRTF data and header contained in the slab3d-format file
% slabfile.
%
% Note: header return values are only valid for slab3d Version 2 HRTF databases.
%
% See also: mat2slab()

% modification history
% --------------------
% 02.18.99  JDM  created (see tron2mat())
% 06.18.01  JDM  added support for default SLAB version 2 databases
% 06.22.01  JDM  added support for all SLAB version 2 databases
% 11.12.02  JDM  bug fix: 128 to numPts in v2 reshape
% 11.13.02  JDM  added header return values
%                ----  v5.5.0  ----
% 06.18.04  JDM  added ir=[] if error
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

% verify input arguments
if (nargin < 1),
  disp('slab2mat: ERROR - Not enough input arguments.');
  ir = [];
  return;
end;

if ~isstr(fileName),
  disp('slab2mat: ERROR - Input argument fileName not a string.');
  ir = [];
  return;
end;

% open file, read data
fid = fopen(fileName, 'r', 'l');
if (fid == -1),
  disp(['slab2mat: ERROR - Can''t open file <', fileName, '>.']);
  ir = [];
  return;
end;

% determine database version from file size
fseek( fid, 0, 'eof' );

% SLAB Version 1 database
if( ftell( fid ) == 146718 ),
  fseek( fid, 0, 'bof' );

  % define SLAB map
  azGrid = [180:-30:-180]; naz = length(azGrid);
  elGrid = [90:-18:-90];  nel = length(elGrid);
  map = [kron(ones(1,naz),elGrid); kron(azGrid,ones(1,nel))];

  [dataIR countIR] = fread(fid,naz*nel*2*256,'short');
  [dataITD countITD] = fread(fid,naz*nel,'short');
  fclose(fid);
  if ((countIR ~= naz*nel*2*256) | (countITD ~= naz*nel)),
    disp(['slab2mat: INFO - read hrtf ', fileName]);
  end;
  
  % assemble hrir, itd
  temp = reshape(dataIR, 256, naz*nel*2)/32767;
  ir = [temp(:,[1:2:(naz*nel*2-1)]) temp(:,[2:2:(naz*nel*2)])];
else, % assume slab3d version 2 database
  % get header (first 308 bytes)
  fseek( fid, 0, 'bof' );
  [version,name,strDate,comment,azInc,elInc,numPts,fs] = shead2(fid);

  % define slab3d map
  azGrid = [180:-azInc:-180]; naz = length(azGrid);
  elGrid = [90:-elInc:-90];  nel = length(elGrid);
  map = [kron(ones(1,naz),elGrid); kron(azGrid,ones(1,nel))];

  [dataIR countIR] = fread( fid, naz*nel*2*numPts, 'float' );
  [dataITD countITD] = fread( fid, naz*nel, 'float' );
  fclose(fid);
  if ((countIR ~= naz*nel*2*numPts) | (countITD ~= naz*nel)),
    disp(['slab2mat: ERROR - reading HRTF ', fileName]);
  end;
  
  % assemble hrir, itd
  temp = reshape(dataIR, numPts, naz*nel*2);
  ir = [temp(:,[1:2:(naz*nel*2-1)]) temp(:,[2:2:(naz*nel*2)])];
end;

itd = dataITD(:)';
