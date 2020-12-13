function stats = vitd( h, azp, elp, table, style, sdiff, stext, neg180, sld )
% vitd - ITD viewing utility.
%
% stats = vitd( h, az, el, table, style, sdiff, stext, neg180, sld )
%
% h      - sarc struct
% az     - az to view, [] = all az's (default = [])
% el     - el to view, [] = all el's (default = [])
% table  - flag, display ITD table (incl. sphere model) (default = 0)
% style  - optional plot style (default = 'b.-')
% sdiff  - flag, display database-spherical difference (default = 0)
% stext  - flag, stats text (default = 0)
% neg180 - omit -180 from analysis (default = 0)
% sld    - spherical head source-listener distance, m (default 0.9m)
%
% For sdiff and stext:
%   spherical ITD >= 0, mag diff = database  - spherical
%   spherical ITD <  0, mag diff = spherical - database
%   bias = mean( database ITD )
%
% example:  vitd(h1a,[],[],0,'b.-',1)  % display difference plot

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% modification history
% --------------------
% 06.20.01  JDM  created
% 10.18.02  JDM  renamed, itds -> vitd
% 11.13.02  JDM  itd,map input to sarc
%                ----  v5.3.0  ----
% 08.15.03  JDM  updated to new sarc format
% 08.28.03  JDM  44.1 to h.pfs/1000.0
%                ----  v5.4.0  ----
% 11.10.03  JDM  added pgrid exist check
% 11.21.03  JDM  updated to new v4 sarc
%                ----  v5.5.0  ----
% 09.01.04  JDM  added azp, elp, table, YTick; '-ob' -> 'b.-'
%                ----  v5.8.1  ----
% 06.21.06  JDM  table: ms to us; plot: samples to us; added sphere model,
%                sdiff plot; yellow el lines replaced by x grid lines
% 06.25.06  JDM  sdiff 'r.-' to style
%                ----  v6.6.0  ----
% 02.25.11  JDM  spherical plot style 'k.:' -> 'r-';
%                added stext param; spherical-database plot and stats now
%                include database-spherical for mag diff analysis;
%                added stats return; added derivatives
%                ----  v6.6.1  ----
% 01.20.12  JDM  added sld param; DIS plot abs(-spherical)
% 04.10.12  JDM  added diagBias
%                ----  v6.7.1  ----
% 12.24.12  JDM  asym mean to max
% 12.26.12  JDM  added ups var for higher shift resolution
% 12.27.12  JDM  revised metric plot title and curve order
% 12.28.12  JDM  improved dis metric by removing EL ring and +/-90,0 slope
%                transitions
% 02.08.13  JDM  brought back asym mean
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

if nargin < 1
  disp( 'vitd error: not enough input arguments.' );
  return;
end;

if nargin < 2,  azp = [];       end;
if nargin < 3,  elp = [];       end;
if nargin < 4,  table = 0;      end;
if nargin < 5,  style = 'b.-';  end;
if nargin < 6,  sdiff = 0;      end;
if nargin < 7,  stext = 0;      end;
if nargin < 8,  neg180 = 0;     end;
if nargin < 9,  sld = 0.9;      end;  % ACD HeadZap

if isempty( h.itd ),
  disp( 'vitd error: requires itd data.' );
  return;
end;

if isempty( azp ),
  azMax = max( h.dgrid(2,:) );
  azMin = min( h.dgrid(2,:) );
else
  azMax = azp;
  azMin = azp;
end;

if isempty( elp ),
  elMax = max( h.dgrid(1,:) );
  elMin = min( h.dgrid(1,:) );
else
  elMax = elp;
  elMin = elp;
end;

% ITD specified as a left or right ear lag relative to the opposite ear,
% positive = lag left ear, negative = lag right ear, us,
% +az to the right
%
%                right             left
% azs:  180, 165, ..., 15, 0, -15, ..., -165
% itds:   0    +        +  0    -          -

%azs = [azMax:-h.azinc:azMin];
azs = [];
for az = azMax:-h.azinc:azMin
  if (neg180 == 1) && (az == -180),
    % do nothing
  else
    azs = [ azs, az ];
  end;
end;
els = [elMax:-h.elinc:elMin];

% the block below is similar to the ol':
% disp('az        el        ITD (samples)        ITD (ms)');
% [[h.dgrid(2,:);h.dgrid(1,:)];h.itd;h.itd/44.1]'

numAzs = length(azs);
len = length(azs) * length(els);
mapSort = zeros(2,len);
itdSort = zeros(1,len);
itdSphere = zeros(1,len);
itdAsym = zeros(1,len);
if table,
  fprintf('\n  Az  El    ITD  ITD (us)  Sphere\n');
end;
maxBias = 0;
maxRing = 0;
minBias = 0;
minRing = 0;
k = 1;
neg90 = -1;
pos90 = -1;
for el = els
  for az = azs
    % remember 90,0 and -90,0 indices
    if el == 0,
      if az == 90,
        pos90 = k;
      elseif az == -90
        neg90 = k;
      end;
    end;
    % ITD in us
    mapSort(:,k) = [el;az];
    itdCur = h.itd( hindex( az, el, h.dgrid ) );  % ITD in samples
    itdSort(k) = itdCur/(h.fs/1000000.0);  % ITD in us
    itdAsym(k) = abs(itdCur+h.itd(hindex(-az,el,h.dgrid)))/(2*h.fs/1000000.0);
    itdSphere(k) = sitd( az, el, 0.09, sld );  % near field
    %itdSphere(k) = sitdw( az, el, 0.09, sld, 1 );  % far field
    if table,
      fprintf( '%4d %3d: %6.2f %7.2f %7.2f\n', az, el, itdCur, ...
               itdCur/(h.fs/1000000.0), itdSphere(end) );
    end;
    k = k + 1;
  end;
  % for diagonal bias detection
  ringBias = mean(itdSort(k-numAzs:k-1));
  if ringBias > maxBias,
    maxBias = ringBias;
    maxRing = el;
  elseif ringBias < minBias,
    minBias = ringBias;
    minRing = el;
  end;
end;

% calc diagonal bias metric
diagBias = maxBias - minBias;

% plot ITDs
figure(gcf);
bIsHold = ishold;
if sdiff,
  subplot(2,1,1);
  if bIsHold,
    hold on;
  end;
end;
%plot( 1:length(itdSort), itdSort, style, 1:length(itdSort), itdSphere, 'k.:' );
plot( 1:length(itdSort), itdSort, style, 1:length(itdSort), itdSphere, 'r-' );
axis( [ 0 length(itdSort)+1 -1000 1000 ] );
title( sprintf( 'ITDs ("%s")', h.name ), 'Interpreter', 'none' );
xlabel('elevation');
ylabel('us');
set(gca,'YTick',[-1000:100:1000]);

if 0,  % new method below
% highlight new elevation
set(gca,'YGrid','on');
hold on;
% find the itdSort and mapSort indices where the el changes to a new el
newEl = [ 1 find( diff(mapSort(1,:)) ) + 1 ];
% x = [ a a a b b b ... ], y = [ -60 50 -60 -60 50 -60 ... ]
% up, down, over, up, down, over... - series of u's where the bottom of the u
% is beneath the figure axis
plot( kron(newEl-.5,[1 1 1]), kron(ones(1,length(newEl)),[-850 800 -850]), ':y' );
for i=1:length(newEl)
  % X = newEl(i)+1 looks better for all azs/els (i.e., many grid pts)
  text(newEl(i)+4,750,num2str(mapSort(1,newEl(i))));
end;
hold off;
end;

% x tick every new el
set( gca, 'XTick', 1:length(azs):length(itdSort) );
set( gca, 'XTickLabel', num2str(els') );
grid on;

% database-spherical difference
dif = itdSort - itdSphere;
% ITD specified as a left or right ear lag relative to the opposite ear,
% positive = lag left ear, negative = lag right ear, us.
% So, to more easily visualize magnitude differences:
% spherical >= 0, database  - spherical 
% spherical <  0, spherical - database 
z = find( itdSphere < 0 );
difM = dif;
difM(z) = -dif(z);

% compute azimuth shift of all-els-azs ITD curve
if h.azinc > 5
  ups = 8;  % e.g., az/ups = 15/8 = 1.875 degs resolution
else
  ups = 4;  % e.g., 5/4 = 1.25 degs
end;
resSort = resample( itdSort, ups, 1 );
resSphere = resample( itdSphere, ups, 1 );
x = xcorr( resSphere, resSort, 360/h.azinc );
[ mx mi ] = max(x);
mid = ceil(length(x)/2);
shift = ((mid - mi)/ups)*h.azinc;

% metric indicating database/spherical difference
absdif = mean(abs(dif));

% metric indicating database/spherical magnitude difference
% (easily corrupted by biases and curve shifts - tend to lower value)
mag = mean(difM);

% Low values tend to indicate database/spherical difference due to mag
% differences and the mag value is fairly accurate (though errors might
% still exist, e.g., a bias that doesn't cause canceling mags).
% High values tend to indicate an error, e.g., a bias or curve shift.
% normalize dif by removing mag
% expanded:
% ndif = mean(abs(itd-sph)) - abs(mean([itdP-sphP sphN-itdN]));
ndif = absdif - abs(mag);

asym = mean(itdAsym);
masym = max(itdAsym);

% use derivatives to check for discontinuities
diffD = [ 0 diff(itdSort) ];
diffS = [ 0 diff(itdSphere) ];
diffD = diffD/h.azinc;
diffS = diffS/h.azinc;

% remove EL ring transitions
diffS(numAzs+1:numAzs:len) = 0;
diffD(numAzs+1:numAzs:len) = 0;

% remove 90,0 and -90,0 extreme slope transitions;
% this region contains large pos-to-neg and neg-to-pos SHM slope jumps
% resulting in the exageration of error relative to other +/-90 az regions
if pos90 > 0,
  diffS([pos90 pos90+1]) = 0;  % pt before to 90, 90 to pt after
  diffD([pos90 pos90+1]) = 0;
end;
if neg90 > 0,
  diffS([neg90 neg90+1]) = 0;  % pt before to -90, -90 to pt after
  diffD([neg90 neg90+1]) = 0;
end;

% curve discontinuity relative to spherical head model
% note: mean(discon) includes the zeroed values above
discon = abs(diffD-diffS);

% 1    2    3     4     5       6    7      8     9    10     11
% max  min  bias  ndif  absdif  mag  under  over  dis  shift  masym
% 12    13        14
% mdis  diagBias  asym
stats = [ max(itdSort) min(itdSort) mean(itdSort) ndif absdif mag ...
          min(difM) max(difM) mean(discon) shift masym max(discon) ...
          diagBias asym ];

% database-spherical difference plot
if sdiff,
  subplot(2,1,2);
  if bIsHold,
    hold on;
  end;
  % DIF and MAG
  plot( 1:length(itdSort), dif+600, 'b', ...
        1:length(itdSort), difM+100, 'b' );
  hold on;
  % ASYM
  plot( itdAsym-400, 'b' );
  % DIS
  plot( 10*abs(diffD-diffS)-800, 'b' );
  hold off;
  title( sprintf( [ 'Max %.1f  Min %.1f  Dif %.1f  Mag %.1f (%.1f to %.1f)' ...
    '  Shift %.1f  DBias %.1f  MAsym %.1f  Asym %.1f  MDis %.1f  Dis %.1f' ], ...
    stats([1 2 5 6 7 8 10 13 11 14 12 9]) ) );
  axis( [ 0 length(itdSort)+1 -1000 1000 ] );
  xlabel('elevation');
  ylabel('us');
  set( gca, 'XTick', 1:length(azs):length(itdSort) );
  set( gca, 'XTickLabel', num2str(els') );
  set(gca,'YTick',[-1000:100:1000]);
  grid on;
  text(5,750,' DIF','Color',[0 0 1]);
  text(5,250,' MAG','Color',[0 0 1]);
  text(5,-250,' ASYM','Color',[0 0 1]);
  text(5,-650,' 10*DIS','Color',[0 0 1]);
end;

% database-spherical difference stats
if stext,
  fprintf( [ '%s  max %5.1f  min %6.1f  bias %5.1f  ndif %4.1f  ' ...
    'dif %4.1f  mag %5.1f  under %6.1f  ' ...
    'over %5.1f  dis %5.3f  shift %6.2f  masym %5.1f  mdis %6.3f' ], ...
    h.name, stats(1:12) );
  fprintf( '  maxBias %5.1f %3d  minBias %5.1f %3d  diagBias %5.1f  asym%5.1f\n', ...
    maxBias, maxRing, minBias, minRing, diagBias, asym );
end;

% to view h.itd - all els at each az
if 0,
figure;
plot(h.itd,'b.-');
% x tick every azimuth
set(gca,'XTick', find(diff(h.dgrid(2,:)) ~= 0)+1 );
grid on;
end;
