function stats = hen( h, int, dtext, haL, haR, oneLine, tb, bSphere, bIID, ...
                      nGrid, bYaw )
% hen - display HRIR energy.
%
% stats = hen( h, int, dtext, haL, haR, oneLine, tb, bSphere, bIID, nGrid, bYaw )
%
% h       - slab3d archive struct
% int     - interpolated surface plot flag (default = 0)
% dtext   - display text output flag (default = 1)
% haL     - handle to axis for left ear (default = [])
% haR     - handle of axis for right ear (default = [])
% oneLine - flag, one line text summary output (default = 0)
% tb      - display top-bottom 2D (1) or 3D (0) (default = 0)
% bSphere - display sphere (1) or surface (0) (default = 0)
% bIID    - display energies (0) or IIDs (1) (default = 0)
% nGrid   - display database/measurement grid on sphere (default = -1, none)
%           0 = slab3d, 1 = CIPIC, 2 = Listen, 3 = ACD
% bYaw    - flag to narrow IID color axis for yaw error vis (default = 0)
%
% If haL and haR are [], hen() uses gcf.
%
% See also: hencb, henfilt

% modification history
% --------------------
% 05.15.00  JDM  created
%                ----  v5.3.0  ----
% 08.20.03  JDM  iid() to hint(); sarc-ified
% 08.22.03  JDM  replaced constant x,y meshgrid with pgrid calc
% 08.25.03  JDM  hint() to hpower(); simplified to focus on total power; added
%                right-ear view
%                ----  v5.4.0  ----
% 11.19.03  JDM  added int
% 11.21.03  JDM  updated to new v4 sarc
% 11.24.03  JDM  name change, hpower() to hen() (see Duda notes, "total power"
%                not quite right, "total energy" better); added caxis();
%                moved shading flat to interp surf(); added azmap, elmap
%                ----  v6.6.0  ----
% 02.28.11  JDM  z dB max from 5 to 6; added oneLine param, stats return;
%                added sphere display
%                ----  v6.7.1  ----
% 03.06.13  JDM  added az0,az180 IID/ITD text output
% 03.13.13  JDM  added bIID
%                ----  v6.7.5  ----
% 05.06.15  JDM  added bYaw
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
if nargin < 2, int = 0; end;
if nargin < 3, dtext = 1; end;
if nargin < 4, haL = []; end;
if nargin < 5, haR = []; end;
if nargin < 6, oneLine = 0; end;
if nargin < 7, tb = 0; end;
if nargin < 8, bSphere = 0; end;
if nargin < 9, bIID = 0; end;
if nargin < 10, nGrid = -1; end;
if nargin < 11, bYaw = 0; end;

if h.finc == 0,
  disp( 'hen error: requires fixed-inc grid.' );
  return;
end;

nMap = length(h.dgrid);
index = [1:nMap]';
indexL = index;
indexR = index + nMap;

% total energy
% (see NASA5, pg.71, NASA7, pg.31, Duda notes)
gainL = sum(h.ir(:,indexL).*h.ir(:,indexL));
gainR = sum(h.ir(:,indexR).*h.ir(:,indexR));
% tail energy
%gainL = sum(h.ir(97:128,indexL).*h.ir(97:128,indexL));
%gainR = sum(h.ir(97:128,indexR).*h.ir(97:128,indexR));

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
zL = zeros( length(elmap), length(azmap) );
zR = zeros( length(elmap), length(azmap) );

if dtext,
  fprintf( '\n  az, el:    L      R     L-R\n' );
%            'xxxx,xxx:  %5.1f  %5.1f  %5.1f'
end;

% init with obvious bad value, dB
az0 = 100;
az0itd = 100;
az180 = 100;
az180itd = 100;

for i=1:nMap,
  az = h.dgrid(2,i);
  el = h.dgrid(1,i);

  gL = 10*log10(gainL(i));
  gR = 10*log10(gainR(i));
  gLR = gL - gR;

  % get IIDs for 0,0 and 180,0
  if el == 0,
    if az == 0,
      az0 = gLR;
      az0itd = h.itd(i);
    elseif az == 180,
      az180 = gLR;
      az180itd = h.itd(i);
    end;
  end;

  azi = find( az == azmap );
  eli = find( el == elmap );
  zL( eli, azi ) = gL;
  zR( eli, azi ) = gR;

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

  if dtext,
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
  %fprintf('%s %5.1f %5.1f %5.1f %5.1f\n', h.name, az0, az180, az0itd, az180itd);
else
  fprintf( '\nStatistics:\n\n' );
  fprintf( 'Mean Total Energy:         %5.1f dB\n', mAll );
  fprintf( 'Mean Left Ear Energy:      %5.1f dB\n', mlAll );
  fprintf( 'Mean Right Ear Energy:     %5.1f dB\n', mrAll );
  fprintf( 'Maximum Left  Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
           maxL, h.dgrid(2,maxinL), h.dgrid(1,maxinL) );
  fprintf( 'Minimum Left  Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
           minL, h.dgrid(2,mininL), h.dgrid(1,mininL) );
  fprintf( 'Maximum Right Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
           maxR, h.dgrid(2,maxinR), h.dgrid(1,maxinR) );
  fprintf( 'Minimum Right Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
           minR, h.dgrid(2,mininR), h.dgrid(1,mininR) );
  fprintf( 'Maximum IID (L-R):         %5.1f dB  (%4d,%3d)\n\n', ...
           maxabsLR, h.dgrid(2,maxabsinLR), h.dgrid(1,maxabsinLR) );
end;

% color axis, dB
% colorbar jet: dark_blue/blue/cyan/green(0)/yellow/red/burgundy
if bIID,
  if bYaw,
    cax = [ -1 1 ];    % for subject yaw vis
  else
    cax = [ -27 27 ];  % based on Listen and CIPIC IID spans
  end;
else
  cax = [ -30 6 ];
end;
% tail energy
%cax = [ -65 -15 ];

% see grids() for Listen/CIPIC measurement grids
if bSphere,
  if bIID,
    % last 3 params = show bottom, show line, show grid
    % (0,1,2,3 slab3d/CIPIC/Listen/ACD)
    lrsphere( azmap, elmap, zL-zR, zR-zL, 'L-R IID', ...
              'R-L IID', cax, tb, 1, 1, nGrid );
  else
    lrsphere( azmap, elmap, zL, zR, 'Left Ear HRIR Energy', ...
             'Right Ear HRIR Energy', cax, tb, 1, 0, nGrid );
  end;
else
  if bIID,
    lrsurf( azmap, elmap, zL-zR, zR-zL, 'L-R IID', ...
            'R-L IID', cax, tb, int, haL, haR );
  else
    lrsurf( azmap, elmap, zL, zR, 'Left Ear HRIR Energy', ...
            'Right Ear HRIR Energy', cax, tb, int, haL, haR );
  end;
end;

