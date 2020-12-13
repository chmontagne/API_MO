function vsym( h, az, el, tflog )
% vsym - view all HRTF az or el magnitude responses.
%
% vsym( h, az, el, tflog )
%
% h     - sarc struct
% az    - azimuth (degrees) (see below)
% el    - elevation (degrees) (see below)
% tflog - log frequency flag (default = 0)
%
% If az specified and el == [], vsym() displays all els at az.
% If el specified and az == [], vsym() displays all azs at el.
% Either az or el must be [], but not both.
%
% This function is similar to vall.m, but focuses on displaying the left
% and right magnitude responses simultaneously.  The right ear az is the
% opposite of the left so that the left and right ears can be compared
% for symmetry.  This can aid in detecting anomalies.

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.23.11  JDM  created from vall.m
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
  disp( 'vsym error: not enough input arguments.' );
  return;
end;

% defaults
if nargin < 3, el = []; end;    % all els
if nargin < 4, tflog = 0; end;  % log freq axis

if isempty(az) && isempty(el),
  disp('vsym error: either az or el must be non-empty.');
  return;
end;

% check if fixed-inc data
if h.finc == 0,
  disp('vsym error: not fixed-inc data.');
  return;
end;

% get current figure
figure(gcf);
colormap('gray');

% for all azs, plot ipsilateral top (L neg az, R pos az) to contralateral
% bottom (L pos az, R neg az)

% left ear
subplot(1,2,1);
draw( h, az, el, tflog, 1 );
if isempty(el),  % all els
  axis xy;  % order els pos to neg
end;
% else all azs, az neg to pos as noted above

% right ear
subplot(1,2,2);
% use opposite az for right ear
if isempty(el),  % all els
  draw( h, -az, el, tflog, 0 );
  axis xy;  % order els pos to neg
else  % all azs
  draw( h, az, el, tflog, 0 );
  axis xy;  % flip vertical axis so azs ordered opposite left ear azs
end;

%------------------------------------------------------------------------------

function draw( h, az, el, tflog, leftIR )

% HRTF locations to view
if isempty(el),  % all els
  inc      = h.elinc;
  posBegin = hindex( az, max(h.dgrid(1,:)), h.dgrid );
  posEnd   = hindex( az, min(h.dgrid(1,:)), h.dgrid );
  gridinc  = 1;
  dim      = 1; % els in h.dgrid(1,:)
  imgoff   = ceil(h.elinc/2);
else  % all azs
  inc      = h.azinc;
  posBegin = hindex( max(h.dgrid(2,:)), el, h.dgrid );
  posEnd   = hindex( min(h.dgrid(2,:)), el, h.dgrid );
  gridinc  = (max(h.dgrid(1,:)) - min(h.dgrid(1,:))) / h.elinc + 1;
  dim      = 2; % azs in h.dgrid(2,:)
  imgoff   = ceil(h.azinc/2);
end;

% make sure requested location exists
if isempty( posBegin ) || isempty( posEnd ),
  disp('vsym error: requested location does not exist.');
  return;
end;

resps = size(h.dgrid,2);
N = 1024;
locs = posBegin : gridinc : posEnd;
all = zeros( N-1, length(locs) );
k = 1;
for i = locs,
  % dB mag, omit DC
  if leftIR,
    [resp,ft] = freqz( h.ir(:,i), 1, N, h.fs );
  else  % right
    [resp,ft] = freqz( h.ir(:,i + resps), 1, N, h.fs );
  end;
  dB = 20*log10(abs(resp(2:N)));

  % if log freq axis
  if tflog,
    % see CIPIC show_data freq_resp.m
    f = logspace( log10(ft(2)), log10(ft(N)), N-1 );
    dB = interp1( ft(2:N), dB, f )';
  else
    f = ft(2:N);
  end;

  all(:,k) = dB;
  k = k + 1;
end;

if tflog,
  imagesc( log10(f), h.dgrid(dim,posBegin):-inc:h.dgrid(dim,posEnd), all' );
  axis( [ log10(f(1)) log10(20000) ...
          h.dgrid(dim,posEnd)-imgoff h.dgrid(dim,posBegin)+imgoff ] );
  xlabel( 'Log Frequency (log10(Hz))' );
else
  imagesc( f, h.dgrid(dim,posBegin):-inc:h.dgrid(dim,posEnd), all' );
  axis( [ f(1) 20000 ...
          h.dgrid(dim,posEnd)-imgoff h.dgrid(dim,posBegin)+imgoff ] );
  xlabel( 'Frequency (Hz)' );
end;

if leftIR,
  lr = 'Left';
else
  lr = 'Right';
end;

if isempty(el),  % all els
  ylabel( 'Elevation' );
  title( sprintf( '%s Ear Magnitude Response (az = %.0f)', lr, az ) );
else  % all azs
  ylabel( 'Azimuth' );
  title( sprintf( '%s Ear Magnitude Response (el = %.0f)', lr, el ) );
end;
