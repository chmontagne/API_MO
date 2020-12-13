function dataOut = map2map(mapIn, dataIn, mapOut, bProgress)
% map2map - resample hrtf data to new grid.
%
% DATAOUT = map2map(MAPIN, DATAIN, MAPOUT) resamples DATAIN measured on the
% grid MAPIN to the new grid MAPOUT.  Each column of MAPIN specifies the
% direction associated with the corresponding column of DATAIN.  Similarly,
% DATAOUT contains the set of desired output directions.  The first rows of
% MAPIN and MAPOUT specify elevation above the horizontal plane, measured
% in degrees; the second rows specify azimuth in the horizontal plane, with
% zero degrees being in front of the subject, and 90 degrees being to the
% right of the subject.
%
% Note!
% If a given map direction appears more than once, the output can be corrupted
% (e.g., contain Inf's and/or NaN's).  If this occurs, you might see a MATLAB
% warning regarding a matrix being singular or badly scaled.
%
% See slab_sua.rtf regarding intellectual property restrictions.

% (c) Copyright 1996 Abel Innovations.  All rights reserved.
%
% Jonathan Abel
% Created: 14-Jan-96
% Version: 1.0
%
% slab3d release map2map usage agreement:
%
% map2map is the intellectual property of Jonathan Abel and is covered under
% the same usage restrictions outlined in the "SLAB Software Usage Agreement"
% (see slab_sua.rtf in this directory).
%
% This software may be used, copied, and provided to others only as permitted
% under the terms of the contract or other agreement under which it was acquired.
% Neither title to nor ownership of the software is hereby transferred.
% This notice shall remain on all copies of the software.
%
% Many thanks to Jonathan Abel for allowing map2map to be released with the
% slab3d release.

% modification history
% --------------------
% 10.09.02  JDM  added usage agreement
% 12.04.02  JDM  verified and added Note!, removed "See also: INTERPS."
%                ----  v6.6.0  ----
% 02.11.11  JDM  %% -> % (%% = Cell Mode); added progress meter
%
% JDM == Joel David Miller

% verify input
if nargin < 3,
    disp(['map2map: ERROR - not enough input arguments.']);
    return;
end;

if nargin < 4,
  bProgress = 0;
end;

% check size compatibility
if (size(mapIn,2) ~= size(dataIn,2)),
    disp(['map2map: ERROR - input grid MAPIN and input data DATAIN have incompatible dimensions.']);
    return;
elseif ((size(mapIn,1) ~= 2) | (size(mapOut,1) ~= 2)),
    disp(['map2map: ERROR - MAPIN and MAPOUT must be elevation-azimuth pairs.']);
    return;
end;

% initialization

% number of input and output grid points
[rIn cIn] = size(dataIn);
cOut = size(mapOut,2);

% find direction cosines
dIn = [ cos(mapIn(1,:)*pi/180) .* cos(mapIn(2,:)*pi/180); ...
        cos(mapIn(1,:)*pi/180) .* sin(mapIn(2,:)*pi/180); ...
        sin(mapIn(1,:)*pi/180)];

dOut = [cos(mapOut(1,:)*pi/180) .* cos(mapOut(2,:)*pi/180); ...
        cos(mapOut(1,:)*pi/180) .* sin(mapOut(2,:)*pi/180); ...
        sin(mapOut(1,:)*pi/180)];

% biharmonic spline

% form basis
basis = zeros(cIn,cIn);
for i = [1:cIn],
    temp = dIn - dIn(:,i)*ones(1,cIn);
    d2 = sum(temp.*temp);
    basis(i,:) = d2 .* (log(d2+eps)/2 - 1);
end;

% loop through input data rows
nProgress = 0;
dataOut = zeros(rIn,cOut);
for i = [1:rIn],
    if bProgress,
      fprintf('.');
      nProgress = nProgress + 1;
      if nProgress == 60,
        fprintf('\n');
        nProgress = 0;
      end;
    end;

    % form weighting function
    weights = basis \ dataIn(i,:)';

    % loop through output directions
    for j = [1:cOut],
        % form row of square ranges
        temp = dIn - dOut(:,j)*ones(1,cIn);
        d2 = sum(temp.*temp);
        greens = d2 .* (log(d2+eps)/2 - 1);
    
        % compute output point
        dataOut(i,j) = greens * weights;
    end;
end;

if bProgress,
  fprintf('\n');
end;
