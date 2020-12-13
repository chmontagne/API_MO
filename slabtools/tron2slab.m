function tron2slab( tronFileName, slabFileName, azInc, elInc, ...
                    numPts, strName, strComment, fs, scale )
% tron2slab - converts 44.1kHz tron-format file to slab-format file.
%
% tron2slab( tronFileName, slabFileName, azInc, elInc,
%            numPts, strName, strComment, fs, scale )
%
% tronFileName - Convolvotron HRTF database filename
% slabFileName - slab3d HRTF database filename
% azInc        - output azimuth increment (default = 30)
% elInc        - output elevation increment (default = 18)
% numPts       - number of FIR points in each HRIR (default = 128)
% strName      - name of head (< 32 chars) (default = empty)
% strComment   - comment string (< 256 chars) (default = empty)
% fs           - sample rate (default = 44100)
% scale        - scale HRIR to +/- 1.0 flag (default = 1)
%
% tron2slab requires the Snapshot function tron2mat.m.
%
% tron2slab outputs the slab3d map grid defined below:
%   az = [180:-azInc:-180]; el = [90:-elInc:-90];
%   mapslab = [kron(ones(size(az)),el); kron(az,ones(size(el)))];

% modification history
% --------------------
% 06.18.01  JDM   created from mat2slab()
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

if( nargin < 2 ),
  disp('tron2slab: ERROR - missing parameters.');
  return;
end;

[hrir, itd, map] = tron2mat( tronFileName );

switch( nargin ),
  case 2,  mat2slab( slabFileName, hrir, itd, map );
  case 3,  mat2slab( slabFileName, hrir, itd, map, azInc );
  case 4,  mat2slab( slabFileName, hrir, itd, map, azInc, elInc );
  case 5,  mat2slab( slabFileName, hrir, itd, map, azInc, elInc, numPts );
  case 6,  mat2slab( slabFileName, hrir, itd, map, azInc, elInc, numPts, ...
                     strName );
  case 7,  mat2slab( slabFileName, hrir, itd, map, azInc, elInc, numPts, ...
                     strName, strComment );
  case 8,  mat2slab( slabFileName, hrir, itd, map, azInc, elInc, numPts, ...
                     strName, strComment, fs );
  case 9,  mat2slab( slabFileName, hrir, itd, map, azInc, elInc, numPts, ...
                     strName, strComment, fs, scale );
  otherwise, disp('tron2slab: ERROR - too many parameters.');
end;
