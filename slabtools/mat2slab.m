function mat2slab( fileName, inHRIR, inITD, inMap, azInc, elInc, ...
                   numPts, strName, strComment, fs, scale, itdMap )
% mat2slab - writes HRTF data to slab3d-format file.
%
% mat2slab( fileName, inHRIR, inITD, inMap, azInc, elInc,
%           numPts, strName, strComment, fs, scale, itdMap )
%
% fileName   - slab3d HRTF database filename
% inHRIR     - input HRIR matrix
% inITD      - input ITD vector, in samples
% inMap      - input azimuth and elevation map matrix
% azInc      - output azimuth increment (see below)
% elInc      - output elevation increment (see below)
% numPts     - number of FIR points in each HRIR (default = 128)
% strName    - name of head (< 32 chars) (default = empty)
% strComment - comment string (< 256 chars) (default = empty)
% fs         - sample rate (default = 44100)
% scale      - scale HRIR to +/- 1.0 flag (default = 1)
% itdMap     - use in place of inMap for ITDs (default = inMap)
%
% mat2slab requires map2map.
%
% mat2slab outputs the slab3d map grid defined below:
%   az = [180:-azInc:-180]; el = [90:-elInc:-90];
%   mapslab = [kron(ones(size(az)),el); kron(az,ones(size(el)))];

% modification history
% --------------------
% 11.19.99  JDM  created (see tron2slab and mat2tron)
% 03.06.00  JDM  added grid check to avoid unnecessary interpolation
% 05.04.00  JDM  added no-scale flag
% 04.02.01  JDM  new HRTF database format, "Version 2"
% 06.18.01  JDM  added azInc and elInc defaults; removed hrtf_h, slab_h
% 09.04.01  JDM  added ITD copy when grids identical
% 08.26.02  JDM  minor clean-up
%                ----  v6.6.0  ----
% 02.11.11  JDM  added map2map() progress meter
% 03.14.11  JDM  added itdMap param
%                ----  v6.8.1  ----
% 03.16.17  JDM  added all()'s for if && vector results, e.g.,
%                ~any(mapslab ~= inMap) to all(all(mapslab == inMap))
%                (row of 1s and 0s with && appeared to cause an implicit
%                all() in the past, now explicit)
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

% parameter defaults
if nargin < 12, itdMap = inMap; end;
if nargin < 11, scale = 1; end;
if nargin < 10, fs = 44100; end;
if nargin < 9, strComment = ''; end;
if nargin < 8, strName = ''; end;
if nargin < 7, numPts = 128; end;
if nargin < 6, elInc = 18; end;
if nargin < 5, azInc = 30; end;

% verify parameters

if( (azInc == 0) || (elInc == 0) ),
  disp('mat2slab: ERROR - azInc and elInc must be nonzero.');
  return;
end;

if( azInc == 1 ),
  disp('mat2slab: WARNING - azInc = 1!  Outdated parameter usage?');
end;

if (nargin < 4),
  disp('mat2slab: ERROR - Not enough input arguments.');
  return;
end;

if ~ischar(fileName),
  disp('mat2slab: ERROR - Input argument fileName not a string.');
  return;
end;

if ((nargin < 12) && (size(inHRIR,2) ~= 2*size(inITD,2))) || ...
   (size(inHRIR,2) ~= 2*size(inMap,2)) || (size(inITD,2) ~= size(itdMap,2)),
  disp('mat2slab: ERROR - HRIR, ITD, and MAP have incompatible sizes.');
  return;
elseif ((size(inMap,1) ~= 2)),
  disp('mat2slab: ERROR - MAP must have two rows.');
  return;
end;

% form slab3d grid, group by azimuth (all el's at 180, at 150, etc.)
az = 180:-azInc:-180;
el = 90:-elInc:-90;
mapslab = [kron(ones(size(az)),el); kron(az,ones(size(el)))];

% if the grids are identical, no need to interp
if (nargin < 12) && all(size(mapslab) == size(inMap)) && ...
   all(all(mapslab == inMap)),
  irL = inHRIR( :, [1:size(inMap,2)] );
  irR = inHRIR( :, [1:size(inMap,2)] + size(inMap,2) );
  itdslab = inITD;
else
  % different grids, interpolate input HRTF to slab3d grid

  % interpolate impulse responses
  fprintf('Interpolating left HRIRs...\n');
  irL = map2map(inMap, inHRIR(:,[1:size(inMap,2)]), mapslab, 1);
  fprintf('Interpolating right HRIRs...\n');
  irR = map2map(inMap, inHRIR(:,[1:size(inMap,2)]+size(inMap,2)), mapslab, 1);

  % interpolate interaural time delays
  fprintf('Interpolating ITDs...\n');
  itdslab = map2map(itdMap, inITD, mapslab, 1);
end;

% interleave left and right ear responses
index = [1:size(mapslab,2)];

hrirslab = zeros( numPts, 2*size(mapslab,2) );
hrirslab( 1:numPts, 2*index-1 ) = irL(1:numPts,:);
hrirslab( 1:numPts, 2*index   ) = irR(1:numPts,:);

% scale impulse response
if( scale ),
  hrirslab = hrirslab/max(max(abs(hrirslab)));
end;

% save HRTF to file
fid = fopen(fileName, 'w', 'l');
if (fid == -1),
  disp(['mat2slab: ERROR - Can''t create file <', fileName, '>.']);
  return;
else
  % create 32 character name string
  outName = zeros(1,32);
  if( length(strName) > 31 ),
    outName(1:31) = strName(1:31);
  else
    outName(1:length(strName)) = strName(:);
  end;

  % create 256 character comment string
  outComment = zeros(1,256);
  if( length(strComment) > 255 ),
    outComment(1:255) = strComment(1:255);
  else
    outComment(1:length(strComment)) = strComment(:);
  end;

  % create 8 character date string
  [y,m,d] = datevec(date);
  outDate = sprintf( '%02d%02d%4d', m, d, y );

  % write header
  fwrite(fid,[2],'short');            % database format version
  fwrite(fid,outName,'char');         % name string
  fwrite(fid,outDate,'char');         % date string
  fwrite(fid,outComment,'char');      % comment string
  fwrite(fid,azInc,'short');          % azimuth increment
  fwrite(fid,elInc,'short');          % elevation increment
  fwrite(fid,numPts,'short');         % number of HRIR pts
  fwrite(fid,fs,'long');              % sample rate

  % write data
  fwrite(fid,hrirslab,'float');
  fwrite(fid,itdslab,'float');

  fclose(fid);
  disp(['mat2slab: INFO - wrote HRTF to ', fileName]);
end;
