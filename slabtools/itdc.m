function itdc( map, itd, r, graph, style )
% itdc - compares HRTF ITD modeling techniques.
%
% itdc( map, itd, r, graph, style )
%
% Parameters:
%   map       az,el indices (default = newgrid(30,18,180,-180, 90,-90))
%   itd       measured ITD data
%   r         range (default = 1m)
%   graph     measured, arc model, dist model (default = '111')
%   style     measured plot style (default = '-ob')
%
% Warning! Use newmap() if map read from Snapshot archive.  Snapshot archive
% maps are floating-point; itdc() expects integer.
%
% This function is based on a similar function from the course paper:
% Miller, Joel D., "Modeling Interaural Time Difference Assuming a Spherical
% Head", Music 150, Musical Acoustics, Stanford University, December 2, 2001.
% http://www.sonisphere.com/SLAB/MUS150Paper.pdf
% The author has allowed this function to be included in the slab3d release.

%234567890 234567890 234567890 234567890 234567890 234567890 234567890 234567890

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

% modification history
% --------------------
% 11.13.01  JDM  created for MUS150 final project
%                ----  v5.5.0  ----
% 06.16.04  JDM  reversed itd, map param order; added map, itd defaults;
%                x-axis ticks more general; HeadZap test; copyright notice;
%                SLABLab to slabtools
%                ----  v5.8.1  ----
% 06.21.06  JDM  1500 -> 1000 us plot max
%
% JDM == Joel D. Miller

% default map
if nargin < 1
  map = newgrid(30,18,180,-180, 90,-90);
end;

% default itd
if nargin < 2
  itd = zeros(1,size(map,2));
end;

% default listener-source range, meters
if nargin < 3
  r = 1;
end;

% default data to graph - measured, model1, model2
if nargin < 4
  graph = '111';
end;

% default plot style
if nargin < 5
  style = '-ob';
end;

% JDM's head: approx ellipse 17.5cm x 19.5cm, say 18cm spherical
% JDM's head and Fritz's head
hr = 0.18/2;         % head radius, meters

% ANSI/ASA Manikin
%hr = 0.152/2;       % head radius, meters

sos = 343;           % speed of sound, m/s (343 in paper, 346 in slabdefs.h)
d2r = pi/180;        % degs to rads
r2d = 180/pi;        % rads to degs
fs  = 44100/1000000; % sampling rate, samples/us
tmp = [];

% sound source cannot be within head
if r < hr,
  r = hr;
end;

% HeadZap ITD test
% Change newgrid() inc's to 10 above.
% Use round samples in fprintf() below.
%hr = .340/2;         % head radius, meters (mics ~1ms apart)
%fs = 96000/1000000;  % sampling rate, samples/us
%r  = 0.8890;         % 35" * 0.0254 m/inch

azMax = max( map(2,:) );
azMin = min( map(2,:) );
% assume az's ordered from max to min
azInc = azMax - map( 2, min( find( map(2,:) ~= azMax ) ) );

elMax = max( map(1,:) );
elMin = min( map(1,:) );
% assume el's ordered from max to min
elInc = elMax - map( 1, min( find( map(1,:) ~= elMax ) ) );

% if only one elevation (i.e. ring12)
if( isempty( elInc ) ),
  elInc = 1;
end;

mapSort = [];
itdSort = [];
itdDist = [];
itdArc  = [];
fprintf('\n  Az  El    ITD (us)\n');
for el = elMax:-elInc:elMin
  for az = azMax:-azInc:azMin
    mapSort = [ mapSort [el;az] ];
    itdCur = itd( hindex( az, el, map ) )/.0441;
    itdSort = [ itdSort, itdCur ];

    % ---- source-ear distance difference model ----

    % calculate ITD as difference between distance to both ears
    elr = el*d2r;
    azr = az*d2r;
    xyR = r * cos(elr);  % x,y plane range
    x = xyR * sin(azr);
    y = xyR * cos(azr);
    z = r * sin(elr);
    dl = sqrt( (x + hr)^2 + y^2 + z^2 );
    dr = sqrt( (x - hr)^2 + y^2 + z^2 );
    itdDcur = (dl - dr)*1000000/sos;
    itdDist = [ itdDist, itdDcur ];

    % ---- Spherical Head Model ----
    %
    % As derived in:
    % Miller, J.D., "Modeling Interaural Time Difference Assuming a Spherical
    % Head", Music 150, Musical Acoustics, Stanford University,
    % December 2, 2001.

    % rotated x,y plane, az only method (pg49, NASA6)
    azp = asin( cos(elr) * sin(azr) );
    dlp = sqrt( r^2 + hr^2 + 2*r*hr*sin(azp) ); % same as dl above
    drp = sqrt( r^2 + hr^2 - 2*r*hr*sin(azp) ); % same as dr above

    % arc length correction
    L = sqrt( r^2 - hr^2 ); % distance to spherical head tangent point
    al = pi/2 + azp;        % angle to left ear
    ar = pi/2 - azp;        % angle to right ear

    % verify add arc length condition equivalence
    % tmp = [ tmp; [ az el dl  L (pi/2+azp-acos(hr/r)) ...
    %                (dl > L) ((pi/2+azp-acos(hr/r)) > 0) ] ];

    c = '-';
    if( dlp > L ),
      dlp = L + (al - acos(hr/r))*hr;
      c = 'L';
    end;

    if( drp > L ),
      drp = L + (ar - acos(hr/r))*hr;
      if( c == 'L' ) c = 'B'; else c = 'R'; end;
    end;

    itdAcur = (dlp - drp)*1000000/sos;
    itdArc = [ itdArc, itdAcur ];

    % ---- Spherical Head Model ----
    %
    % Larcher and Jot extension of the Woodworth and Schlosberg formula as
    % described in:
    % P. Minnaar et al., "The Interaural Time Difference in Binaural Synthesis,"
    % 108th Convention of the Audio Engineering Society, Paris, France, 2000.
    %
    % This model produces the same ITD values as Joel Miller's model.

    wD = hr*2;
    wphi = abs(azp);
    wr = r;
    if( sin( wphi ) <= wD /(2*wr) ),
      wdels = wD * wphi;
      wc = 'B';
    else
      wn = (wr - wD/2)/wD;
      weps = asin( wD/(2*wr) );
      % !!!! wphi must be positive else wITD slightly asymmetric
      wdels = wD*((wn + 0.5)*cos(weps) + 0.5*(wphi + weps) - ...
                  sqrt( wn^2 + wn + 0.5 - (wn + 0.5)*sin(wphi) ) );
      wc = 'A';
    end;
    wITD = wdels * 1000000 / sos;

    % az, el, measured itd, dist itd, jdm itd, w&s itd
    fprintf( '%4d %3d: %6.1f %6.1f %6.1f %c %6.1f %c\n', az, el, ...
             itdCur, itdDcur, itdAcur, c, wITD, wc ); % in us
% %          round(itdCur*fs), round(itdDcur*fs), round(itdAcur*fs), ...
% %          c, round(wITD*fs), wc ); % in round samples
%            itdCur*fs, itdDcur*fs, itdAcur*fs, c, wITD*fs, wc ); % in samples
  end;
end;

% plot ITDs
figure(gcf);
%clf;
hold on;
if str2num( graph(1) )
  plot( 1:length(itdSort), itdSort, style );
end;
if str2num( graph(2) )
  plot( 1:length(itdArc), itdArc, '-ok' );
end;
if str2num( graph(3) )
  plot( 1:length(itdDist), itdDist, ':or' );
end;
axis( [ 0 length(itdSort)+1 -1000 1000 ] );
title('ITDs');
set(gca,'XTick',1:10:size(map,2));
set(gca,'XTickLabel',mapSort(2,1:10:size(map,2)));
% for paper
%set(gca,'XTick',1:3:100);
%set(gca,'FontSize',8); % if x labels too dense
%set(gca,'XTickLabel',kron(ones(1,6),[180:-(3*azInc):(-180+3*azInc)]));
xlabel('Azimuth Grouped by Elevation (degrees)');
ylabel('us');
set(gca,'YGrid','on');
hold off;

% highlight new elevation
% if more than one elevation...
if( elInc ~= 1 ),
	hold on;
	newEl = [ 1 find( diff(mapSort(1,:)) ) + 1 ];
	plot( kron(newEl-.5,[1 1 1]), ...
        kron(ones(1,length(newEl)),[-1050 1000 -1050]), ':y' );
	for i=1:length(newEl)
      text(newEl(i)+1,950,num2str(mapSort(1,newEl(i))));
	end;
	hold off;
end;
