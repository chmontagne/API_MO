function ahm2slab( fileName )
% ahm2slab - converts an AuSIM .ahm to a slab3d HRTF database (SLH).
%
% ahm2slab( fileName )
%
% fileName - AHM file without .ahm suffix
%
% See also: ahm2sarc.m, mat2slab, cipic2slab, listen2slab

% modification history
% --------------------
%                ----  v6.7.5  ----
% 03.19.15  JDM  created
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
  disp('ahm2slab error: missing AHM filename.');
  return;
end;

ha = ahm2sarc( fileName );

% spherical interp function map2map() in mat2slab() doesn't like
% multiple entries for the same location (e.g., multiple EL +/-90s)
% (e.g., BMC44.ahm has +/-90 entries for each az)
pos90 = find(ha.dgrid(1,:)==90);
neg90 = find(ha.dgrid(1,:)==-90);
if length(pos90) > 1 || length(neg90) > 1,
  rStep = size(ha.dgrid,2);
  non90 = find(abs(ha.dgrid(1,:))~=90);
  extractGrid = [ pos90(1) neg90(1) non90 ];
  ha.dgrid = ha.dgrid(:,extractGrid);
  ha.itd = ha.itd(extractGrid);
  ha.ir = ha.ir(:,[ extractGrid extractGrid+rStep ]);
end;

% reduce map2map() ITD biases by tying down slab3d az 0,180 and el +/-90,
% unmeasured grid locations to 0 ITD;
% find the missing elevations for az 0 and 180 in the fixed-inc database,
% first above, then below

% E.g., for ARO44.ahm:
%  +-- az0 (incl. el +/-90)      +-- az180         +-- regular data
% 90    76   -62   -76   -90    76   -62   -76    56    42    28    14     0 ...
%  0     0     0     0     0   180   180   180   180   180   180   180   180 ...

% (ARO44.ahm's azInc of 14 required the location specification shown below)

% els for az 0 (include the +/-90 el locations with az 0)
el0 = [ 90:-ha.elinc:(max(ha.dgrid(1,find(ha.dgrid(2,:)==0)))+ha.elinc) ...
        fliplr(-90:ha.elinc:(min(ha.dgrid(1,find(ha.dgrid(2,:)==0)))-ha.elinc)) ];

% els for az 180
el180 = [ 90-ha.elinc:-ha.elinc:(max(ha.dgrid(1,find(ha.dgrid(2,:)==180)))+ha.elinc) ...
          fliplr(-90+ha.elinc:ha.elinc:(min(ha.dgrid(1,find(ha.dgrid(2,:)==180)))-ha.elinc)) ];

grid0 = [ [ el0; zeros(size(el0)) ] [ el180; 180*ones(size(el180)) ] ]
itdGrid = [ grid0 ha.dgrid ];
itd = [ zeros(1,size(grid0,2)) ha.itd ];

% the slab3d grid must be uniform
% 180:-azInc:0:-azInc:-180, 90:-elInc:0:-elInc:-90
% (e.g., ARO44.ahm violates this with an azInc of 14)

% valid az incs
azIncs=[];
for k=1:180,
  if mod(180,k) == 0,
    azIncs = [azIncs k];
  end;
end;

% if ha.azinc doesn't evenly divide into 180, find an azInc that does
azInc = ha.azinc;
if mod(180,azInc) ~= 0,
  [m,i] = min(abs(azIncs-azInc));
  azInc = azIncs(i);
end;

% valid el incs
elIncs=[];
for k=1:90,
  if mod(90,k) == 0,
    elIncs = [elIncs k];
  end;
end;

% if ha.elinc doesn't evenly divide into 90, find an elInc that does
elInc = ha.elinc;
if mod(90,elInc) ~= 0,
  [m,i] = min(abs(elIncs-elInc));
  elInc = elIncs(i);
end;

% slab3d HRTFs are 44.1kHz by default (see also slab2fs.m)
if ha.fs == 48000,
  disp('Resampling 48000 Hz to 44100 Hz...');
  ha.ir = resample(ha.ir, 147, 160);
  ha.fs = 44100;
end;

% use mat2slab() to finish conversion (uniform grid, scaling, etc.)
slabFileName = [ fileName '.slh' ];
mat2slab( slabFileName, ha.ir, itd, ha.dgrid, azInc, elInc, ...
  size(ha.ir,1), ha.name, ha.comment, ha.fs, 1, itdGrid );
