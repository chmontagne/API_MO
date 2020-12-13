function stats = hencb( h, tb, bSphere, table, oneLine, cbn, bSave, bQuiet )
% hencb - display HRTF critical-band energy.
%
% stats = hencb( h, tb, bSphere, table, oneLine, cbn, bSave, bQuiet )
%
% h       - slab3d archive struct
% tb      - display top-down or top-bottom views (default = 1)
% bSphere - display sphere instead of surface (default = 0)
% table   - display energy table (default = 0)
% oneLine - one line text summary output (default = 0)
% cbn     - critical band number for stats generation (default = 1)
% bSave   - save critical band data to a MAT file (default = 0)
% bQuiet  - suppress verbose text and critical-band loop (default = 0)
%
% Note:  This script uses the Auditory Toolbox.
%        https://engineering.purdue.edu/~malcolm/interval/1998-010/
%
% Critical Bands (fs = 44100 Hz)
%
% 1     100 Hz
% 2     177 Hz
% 3     272 Hz
% 4     390 Hz
% 5     535 Hz
% 6     715 Hz
% 7     936 Hz
% 8    1209 Hz
% 9    1547 Hz
% 10   1963 Hz
% 11   2478 Hz
% 12   3113 Hz
% 13   3897 Hz
% 14   4865 Hz
% 15   6061 Hz
% 16   7537 Hz
% 17   9359 Hz
% 18  11609 Hz
% 19  14386 Hz
% 20  17816 Hz
%
% See also: hencbmat, hencbview, hen

% modification history
% --------------------
%                ----  v6.6.0  ----
% 04.27.11  JDM  created from hen()
%                ----  v6.6.1  ----
% 04.24.12  JDM  made bQuiet more hen()-like (for vcen.m);
%                energy means now pre-dB (modified cbe())
%                ----  v6.7.2  ----
% 08.12.13  JDM  to slabtools
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

% default args
if nargin < 2, tb = 1; end;
if nargin < 3, bSphere = 0; end;
if nargin < 4, table = 0; end;
if nargin < 5, oneLine = 0; end;
if nargin < 6, cbn = 1; end;
if nargin < 7, bSave = 0; end;
if nargin < 8, bQuiet = 0; end;

if h.finc == 0,
  disp( 'hencb error: requires fixed-inc grid.' );
  return;
end;

nMap = length(h.dgrid);

gainL = zeros(1,nMap);
gainR = zeros(1,nMap);

maxL       = -1000.0;
maxR       = -1000.0;
maxinL     = -1;
maxinR     = -1;
minL       = 1000.0;
minR       = 1000.0;
mininL     = -1;
mininR     = -1;
maxabsLR   = 0.0;
maxabsinLR = -1;

azmap = min(h.dgrid(2,:)):h.azinc:max(h.dgrid(2,:));
elmap = min(h.dgrid(1,:)):h.elinc:max(h.dgrid(1,:));
zL = zeros( length(elmap), length(azmap), 20 );
zR = zeros( length(elmap), length(azmap), 20 );

if table,
  fprintf( '\n  az, el:    L      R     L-R\n' );
%            'xxxx,xxx:  %5.1f  %5.1f  %5.1f'
end;

% number of critical bands (if used)
if h.fs == 96000,
  bandn = 24;
else
  bandn = 20;
end;

% to see critical-band frequencies
if 0,
f = ERBSpace( 100, 44100/2, 20 );
fprintf( '%d  %.0f Hz\n', [ 1:20; flipud(f)' ] );
f = ERBSpace( 100, 96000/2, 24 );
fprintf( '%d  %.0f Hz\n', [ 1:24; flipud(f)' ] );
end;

for i=1:nMap,
  az = h.dgrid(2,i);
  el = h.dgrid(1,i);

  % calculate using critical band energy
  [ cbeL, fcb ] = cbe( h, az, el, 1, bandn, 100, 1 );  % left
  [ cbeR, fcb ] = cbe( h, az, el, 0, bandn, 100, 1 );  % right
  gainL(i) = cbeL(cbn);
  gainR(i) = cbeR(cbn);
  cbeL = 10*log10(cbeL);
  cbeR = 10*log10(cbeR);

  % 1 to 20 valid
  gL = cbeL(cbn);
  gR = cbeR(cbn);
  gLR = gL - gR;

  azi = find( az == azmap );
  eli = find( el == elmap );
  zL( eli, azi, : ) = cbeL;
  zR( eli, azi, : ) = cbeR;

  % find maximum left ear energy
  if( gL > maxL ),
    maxL = gL;
    maxinL = i;
  end;

  % find maximum right ear energy
  if( gR > maxR ),
    maxR = gR;
    maxinR = i;
  end;

  % find minimum left ear energy
  if( gL < minL ),
    minL = gL;
    mininL = i;
  end;

  % find minimum right ear energy
  if( gR < minR ),
    minR = gR;
    mininR = i;
  end;

  % find maximum interaural intensity difference
  if( abs(gLR) > maxabsLR ),
    maxabsLR = abs(gLR);
    maxabsinLR = i;
  end;

  if table,
    fprintf( '%4d,%3d:  %5.1f  %5.1f  %5.1f\n', ...
             h.dgrid(2,i), h.dgrid(1,i), gL, gR, gL - gR );
  end;

end;

% avg energies in dB
mL = mean(gainL);
mR = mean(gainR);
mlAll = 10*log10(mL);
mrAll = 10*log10(mR);
mAll  = 10*log10(mean([mL mR]));

stats = [ mAll maxL minL mlAll maxR minR mrAll ...
          maxL-maxR minL-minR mlAll-mrAll maxabsLR ];

if oneLine,
  fprintf( [ '%s  T %4.1f  L %4.1f %5.1f %4.1f  ' ...
    'R %4.1f %5.1f %4.1f  D %4.1f %4.1f %4.1f  IID %4.1f\n' ], ...
    h.name, stats );
elseif ~bQuiet
  fprintf( '\nStatistics:\n\n' );
  fprintf( 'Mean dB:                      %5.1f dB\n', mAll );
  fprintf( 'Mean Left Ear dB:             %5.1f dB\n', mlAll );
  fprintf( 'Mean Right Ear dB:            %5.1f dB\n', mrAll );
  fprintf( 'Maximum Left  Ear CB Energy:  %5.1f dB  (%4d,%3d)\n', ...
           maxL, h.dgrid(2,maxinL), h.dgrid(1,maxinL) );
  fprintf( 'Minimum Left  Ear CB Energy:  %5.1f dB  (%4d,%3d)\n', ...
           minL, h.dgrid(2,mininL), h.dgrid(1,mininL) );
  fprintf( 'Maximum Right Ear CB Energy:  %5.1f dB  (%4d,%3d)\n', ...
           maxR, h.dgrid(2,maxinR), h.dgrid(1,maxinR) );
  fprintf( 'Minimum Right Ear CB Energy:  %5.1f dB  (%4d,%3d)\n', ...
           minR, h.dgrid(2,mininR), h.dgrid(1,mininR) );
  fprintf( 'Maximum CB IID (L-R):         %5.1f dB  (%4d,%3d)\n\n', ...
           maxabsLR, h.dgrid(2,maxabsinLR), h.dgrid(1,maxabsinLR) );
end;

% save critical-band data to a file
if bSave,
  filename = sprintf('%s.cb.mat',h.name);
  save( filename, 'azmap', 'elmap', 'zL', 'zR', 'fcb' );
end;

% display critical-band energy spheres or surfaces
cax = [ -50 15 ];  % color axis, dB
if ~bQuiet,
  for cb = 1:20,
    if bSphere
      lrsphere( azmap, elmap, zL(:,:,cb), zR(:,:,cb), ...
        sprintf('Left Ear CB Energy, %.0f Hz',fcb(cb)), ...
        sprintf('Right Ear CB Energy, %.0f Hz',fcb(cb)), cax, tb );
    else
      lrsurf( azmap, elmap, zL(:,:,cb), zR(:,:,cb), ...
        sprintf('Left Ear CB Energy, %.0f Hz',fcb(cb)), ...
        sprintf('Right Ear CB Energy, %.0f Hz',fcb(cb)), cax, tb, 0, [], [] );
    end;
    pause;
  end;
else
  if bSphere
    lrsphere( azmap, elmap, zL(:,:,cbn), zR(:,:,cbn), ...
      sprintf('Left Ear CB Energy, %.0f Hz',fcb(cbn)), ...
      sprintf('Right Ear CB Energy, %.0f Hz',fcb(cbn)), cax, tb );
  else
    lrsurf( azmap, elmap, zL(:,:,cbn), zR(:,:,cbn), ...
      sprintf('Left Ear CB Energy, %.0f Hz',fcb(cbn)), ...
      sprintf('Right Ear CB Energy, %.0f Hz',fcb(cbn)), cax, tb, 0, [], [] );
  end;
end;

