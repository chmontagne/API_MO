function henfilt( h, int, dtext, haL, haR )
% henfilt - displays table and graph of HRIR energies.
%
% henfilt( h, int, dtext, haL, haR )
%
% h      - slab3d archive struct
% int    - interpolated surface plot flag (default = 0)
% dtext  - display text output flag (default = 1)
% haL    - handle to axis for left ear (default = [])
% haR    - handle of axis for right ear (default = [])
%
% If haL and haR are [], henfilt() uses gcf.
%
% henfilt() calculates HRIR energies.  It also performs a filter operation on
% white noise to demonstrate the use of the total energy metric as an
% approximate gain value.
%
% See also: hen()

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
% 11.24.03  JDM  name change, hpower() to henfilt() (see Duda notes,
%                "total power" not quite right, "total energy" better)
% 01.07.04  JDM  added colormap,view,caxis code from hen.m
%                ----  v5.7.0  ----
% 07.12.05  JDM  added "scalar gain" check
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
if nargin < 2,  int   = 0;   end;
if nargin < 3,  dtext = 1;   end;
if nargin < 4,  haL   = [];  end;
if nargin < 5,  haR   = [];  end;

if h.finc == 0,
  disp( 'henfilt error: requires fixed-inc grid.' );
  return;
end;

nMap = length(h.dgrid);
index = [1:nMap]';
indexL = index;
indexR = index + nMap;

% total energy
% (see NASA5, pg.71, NASA7, pg.31)
gainL = sum(h.ir(:,indexL).*h.ir(:,indexL));
gainR = sum(h.ir(:,indexR).*h.ir(:,indexR));

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

% x = az, y = el
%[x,y] = meshgrid(-180:30:180,-90:18:90);
[x,y] = meshgrid( ...
          min(h.dgrid(2,:)):h.azinc:max(h.dgrid(2,:)), ...
          min(h.dgrid(1,:)):h.elinc:max(h.dgrid(1,:)) );

% uniformly distributed noise signal for analysis, 2048 samples
% + 256 for the partial-filtered data discard after HRIR filter
n1=(rand( 2048 + 256, 1 )*2-1.0);
n1rms = 10*log10(mean(n1.*n1));

if dtext,
  fprintf( '\nNoise RMS: %5.1fdB\n', n1rms );
  fprintf( '\n  az, el:    L      R     L-R    F:L    F:R   F:L-R   D:L    D:R\n' );
%            'xxxx,xxx:  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f'
end;

adiffGL = [];
adiffGR = [];

for i=1:nMap,
  gL = 10*log10(gainL(i));
  gR = 10*log10(gainR(i));
  gLR = gL - gR;

  % scalar gain equivalent
% fL = sqrt( gainL(i) ) * n1;
% fR = sqrt( gainR(i) ) * n1;
  fL = filter( h.ir(:,i), [1], n1 );
  fR = filter( h.ir(:,i+nMap), [1], n1 );

  fL = fL(256:256+2047);
  fR = fR(256:256+2047);
  frmsL = 10*log10(mean(fL.*fL));
  frmsR = 10*log10(mean(fR.*fR));

  [r,caz] = find( x == h.dgrid(2,i) );
  [rel,c] = find( y == h.dgrid(1,i) );
  zL( rel(1), caz(1) ) = gL;
  zR( rel(1), caz(1) ) = gR;
% zL( rel(1), caz(1) ) = frmsL - n1rms;
% zL( rel(1), caz(1) ) = h.itd(i);

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
  % (if Jonathan's dB binaural intensity in hrtfview.m were differenced, it
  % appears the result would be equivalent to a dB difference of total energy
  % because the 1/N in the intensity means would cancel in the ratio of
  % intensities (log(a/b)=log(a)-log(b)) (actually, these already cancel when
  % he normalizes by the maximum intensity))
  if( abs(gLR) > maxabsLR ),
    maxabsLR = abs(gLR);
    maxabsinLR = i;
  end;

  diffGL = gL - (frmsL - n1rms);
  diffGR = gR - (frmsR - n1rms);
  adiffGL = [ adiffGL diffGL ];
  adiffGR = [ adiffGR diffGR ];

  if dtext,
    fprintf( '%4d,%3d:  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f  %5.1f\n', ...
             h.dgrid(2,i), h.dgrid(1,i), gL, gR, gL - gR, ...
             frmsL - n1rms, frmsR - n1rms, frmsL - frmsR, diffGL, diffGR );
  end;
end;

fprintf( '\nStatistics:\n\nMaximum Left  Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
         maxL, h.dgrid(2,maxinL), h.dgrid(1,maxinL) );
fprintf( 'Minimum Left  Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
         minL, h.dgrid(2,mininL), h.dgrid(1,mininL) );
fprintf( 'Maximum Right Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
         maxR, h.dgrid(2,maxinR), h.dgrid(1,maxinR) );
fprintf( 'Minimum Right Ear Energy:  %5.1f dB  (%4d,%3d)\n', ...
         minR, h.dgrid(2,mininR), h.dgrid(1,mininR) );
fprintf( 'Maximum IID (L-R):         %5.1f dB  (%4d,%3d)\n\n', ...
         maxabsLR, h.dgrid(2,maxabsinLR), h.dgrid(1,maxabsinLR) );

fprintf( 'Mean of HRIR and noise-filtered HRIR energy differences L:  %6.3f dB\n', ...
         mean( adiffGL ) );
fprintf( 'Mean of HRIR and noise-filtered HRIR energy differences R:  %6.3f dB\n\n', ...
         mean( adiffGR ) );

% interp surface
if int,
  [xi,yi] = meshgrid(-180:3:180,-90:3:90);
  ziL = interp2( x,y,zL,xi,yi,'bicubic' );
  ziR = interp2( x,y,zR,xi,yi,'bicubic' );
end;

% if no axes args (ha1, ha2)
if isempty( haL ) & isempty( haR ),
  figure(gcf);
  subplot(1,2,1); % left ear
  drawL = 1;
  drawR = 1; % using gcf
elseif ~isempty( haL ),
  axes( haL );
  drawL = 1;
  drawR = 0; % unknown at this point
else,
  drawL = 0;
  drawR = 0; % unknown at this point
end;

% left ear
if drawL,
if int,
  surf(xi,yi,ziL);
else,
  surf(x,y,zL);
end;
shading flat;
axis tight;
%xlabel('Azimuth (degrees)');
%ylabel('Elevation (degrees)');
xlabel('AZ');
ylabel('EL');
zlabel('dB');
title('Left Ear HRIR Energy');
colormap(jet);
view(-30,25);
caxis( [ -30 5 ] );
end;

% if using gcf
if drawR,
  subplot(1,2,2);
elseif ~isempty( haR ),
  axes( haR );
  drawR = 1; % now known
end;

% right ear
if drawR,
if int,
  surf(xi,yi,ziR);
else,
  surf(x,y,zR);
end;
shading flat;
axis tight;
xlabel('AZ');
ylabel('EL');
zlabel('dB');
title('Right Ear HRIR Energy');
colormap(jet);
view(-30,25);
caxis( [ -30 5 ] );
end;

if 0,
% default view: -37.5az, 30el
view( -37.5, 30 );
pause(1);
view( -127.5, 30 );
pause(1);
view( -217.5, 30 );
pause(1);
view( -307.5, 30 );
end;
