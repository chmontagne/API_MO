function vsym1( h, az, el, tflog )
% vsym1 - view all HRTF az or el magnitude responses, left and symmetric right.
%
% vsym1( h, az, el, tflog )
%
% h     - sarc struct
% az    - azimuth (degrees) (see below)
% el    - elevation (degrees) (see below)
% tflog - log frequency flag (default = 0)
%
% If az specified and el == [], vsym1() displays all els at az.
% If el specified and az == [], vsym1() displays all azs at el.
% Either az or el must be [], but not both.
%
% This function is similar to vall.m, but focuses on displaying the left
% and right magnitude responses simultaneously.  The right ear az is the
% negated left ear az so that the left and right ears can be compared
% for symmetry.  This can aid in detecting anomalies.
%
% vsym1() combines the vsym() figures into one image in an effort to
% improve vsym()'s symmetry-based anomaly detection.

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.23.11  JDM  created from vall.m
%                ----  v6.7.1  ----
% 02.13.13  JDM  created from vsym.m
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

if nargin < 2,
  disp( 'vsym1 error: not enough input arguments.' );
  return;
end;

% defaults
if nargin < 3, el = []; end;    % all els
if nargin < 4, tflog = 0; end;  % log freq axis

if isempty(az) && isempty(el),
  disp('vsym1 error: either az or el must be non-empty.');
  return;
end;

% check if fixed-inc data
if h.finc == 0,
  disp('vsym1 error: not fixed-inc data.');
  return;
end;

% get current figure
figure(gcf);
%colormap('gray');

% color axis
cmin = -60;
cmax = 10;

% HRTF locations to view
resps = size(h.dgrid,2);
if isempty(el),  % all els
  posBegin = hindex( az, max(h.dgrid(1,:)), h.dgrid );
  posEnd   = hindex( az, min(h.dgrid(1,:)), h.dgrid );
  locsL = posBegin : posEnd;
  posBegin = hindex( -az, max(h.dgrid(1,:)), h.dgrid );
  posEnd   = hindex( -az, min(h.dgrid(1,:)), h.dgrid );
  locsR = (posBegin : posEnd) + resps;
else  % all azs
  % els grouped by az, e.g., 90:-5:-90;180 then 90:-5:-90;175, etc.,
  % CCW rear/right/left/rear
  posBegin = hindex( max(h.dgrid(2,:)), el, h.dgrid );
  posEnd   = hindex( min(h.dgrid(2,:)), el, h.dgrid );
  gridinc  = (max(h.dgrid(1,:)) - min(h.dgrid(1,:))) / h.elinc + 1;
  % CCW to CW
  locsL = posEnd : -gridinc : posBegin;
  % note: matrix filled in opposite above so actually same az axis as locsL
  locsR = fliplr(locsL) + resps;
end;
len = length(locsL);

% make sure requested location exists
if isempty( posBegin ) || isempty( posEnd ),
  disp('vsym1 error: requested location does not exist.');
  return;
end;

N = 1024;
all = ones( N-1, 3*len+2 ) * cmin;
for k = 1:len,
  [respL,ft] = freqz( h.ir(:,locsL(k)), 1, N, h.fs );
  [respR,ft] = freqz( h.ir(:,locsR(k)), 1, N, h.fs );
  % omit DC and freqs over 20k;
  % for N = 1024, ft(2) = 21.5 Hz
  endF = min(find(ft>20000))-1;
  dBl = 20*log10(abs(respL(2:endF)));
  dBr = 20*log10(abs(respR(2:endF)));
  f = ft(2:endF);

  % if log freq axis
  if tflog,
    % see CIPIC show_data freq_resp.m
    f = logspace( log10(f(1)), log10(f(end)), endF-1 );
    dBl = interp1( ft(2:endF), dBl, f )';
    dBr = interp1( ft(2:endF), dBr, f )';
  end;

  % find the last freq under 20kHz
  all(1:endF-1,len-k+1) = dBr;
  all(1:endF-1,len+k+1) = dBl;
  all(1:endF-1,end-k+1) = dBr;
end;

% reduce to actual elements used
allF = all(1:endF-1,:);

% display mag responses image
if tflog,
  imagesc( 1:3*len+2, log10(f), allF );
  axis( [ 0.5 3*len+2.5 log10(f(1)) log10(f(end)) ] );
  ylabel( 'Log Frequency (log10(Hz))' );
else
  imagesc( 1:3*len+2, f/1000, allF );
  axis( [ 0.5 3*len+2.5 f(1)/1000 f(end)/1000 ] );
  ylabel( 'Frequency (kHz)' );
end;
axis xy;

% title
if isempty(el),  % all els
  xlabel( 'Elevation (sym-right/left/sym-right ears)' );
  tt = sprintf( '%s  az = %.0f', h.name, az );
else  % all azs
  xlabel( 'Azimuth (right/left/right ears)' );
  tt = sprintf( '%s  el = %.0f', h.name, el );
end;
title( tt, 'Interpreter', 'none' );

% color axis
% Listen  IRC_1055.slh  -90.1 dB
%         IRC_1045.slh    7.8 dB
% CIPIC -103 to 16 dB
cax = [ cmin cmax ];
if 0,
minMag = min(min(allF));
maxMag = max(max(allF));
%[ minMag maxMag ]
if minMag < cax(1),
  fprintf('Warning: low cax  min %.1f  (max %.1f)  dB\n', minMag, maxMag);
end;
if maxMag > cax(2),
  fprintf('Warning: high cax  (min %.1f)  max %.1f  dB\n', minMag, maxMag);
end;
end;
caxis( cax );
hold on;
colorbar;
hold off;
