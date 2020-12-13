function vall( h, az, el, tf, tflog, lr, of, win )
% vall - view all el's for az or all az's for el in HRTF database.
%
% vall( h, az, el, tf, tflog, lr, of, win )
%
% h     - sarc struct
% az    - azimuth (degrees) (see below)
% el    - elevation (degrees) (see below)
% tf    - view transfer functions flag (default = 0)
% tflog - log frequency flag (default = 0)
% lr    - 0 = left, 1 = right (default = 0)
% of    - data offset (default = 1)
% win   - data window (default = length of IR - of + 1)
%
% If az specified and el == [], vall() displays all el's at az.
% If el specified and az == [], vall() displays all az's at el.

% modification history
% --------------------
%                ----  v5.4.0  ----
% 11.11.03  JDM  created from vir()
% 11.12.03  JDM  merged lall and rall into all; prefixed ITD before proc IR;
%                added log freq axis, IR scale range
% 11.14.03  JDM  added elinc
% 11.21.03  JDM  updated to new v4 sarc
% 12.17.03  JDM  added imgoff
%                ----  v5.8.0  ----
% 05.04.06  JDM  added log freq XTickLabel
%                ----  v6.6.0  ----
% 03.02.11  JDM  removed log freq XTickLabel, label errors with zoom/resize
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
  disp( 'vall error: not enough input arguments.' );
  return;
end;

% defaults
if nargin < 3,  el    = [];  end;
if nargin < 4,  tf    = 0;   end;  % don't view transfer functions
if nargin < 5,  tflog = 0;   end;  % linear freq axis
if nargin < 6,  lr    = 0;   end;

inc = 0;
if isempty(el),
  inc = h.elinc;
else,
  inc   = h.azinc;
  elinc = h.elinc;
end;

if ~isempty( h.itd ),
  maxitd = round( max( abs( h.itd ) )/2 );
else,
  maxitd = 0;
end;

[taps num] = size(h.ir);

% more defaults
if nargin < 7,  of  = 1;              end;
if nargin < 8,  win = taps - of + 1;  end;

% check if fixed-inc data
if h.finc == 0,
  plot( [-1 1], [0 0] );
  text( -0.1, 0.1, 'no data' );
  return;
end;

% HRTF locations to view
if isempty(el),
  % view set of el's
  posBegin = hindex( az, max(h.dgrid(1,:)), h.dgrid );
  posEnd   = hindex( az, min(h.dgrid(1,:)), h.dgrid );
  gridinc  = 1;
  dim      = 1; % el's in h.dgrid(1,:)
  imgoff   = ceil(h.elinc/2);
else, % isempty(az) == 1
  % view set of az's
  posBegin = hindex( max(h.dgrid(2,:)), el, h.dgrid );
  posEnd   = hindex( min(h.dgrid(2,:)), el, h.dgrid );
  gridinc  = (max(h.dgrid(1,:)) - min(h.dgrid(1,:))) / elinc + 1;
  dim      = 2; % az's in h.dgrid(2,:)
  imgoff   = ceil(h.azinc/2);
end;

% make sure requested location exists
if isempty( posBegin ) | isempty( posEnd ),
  plot( [-1 1], [0 0] );
  text( -0.1, 0.1, 'no data' );
  return;
end;

all = [];
for i = [ posBegin : gridinc : posEnd ],

  % rect windowing and zero padding of hrir
  if of > taps, % window offset starts after hrir
    hrirc = zeros( win, 1 );
  else,
    z = 0;
    i2 = of + win - 1; % index 2 (index 1 = of)
    if i2 > taps,
      z  = i2 - taps; % zero padding
      i2 = taps;
    end;
    if lr == 0,
      % left
      hrirc = [ h.ir(of:i2,i); zeros(z,1) ];
    else,
      % right
      hrirc = [ h.ir(of:i2,i+size(h.dgrid,2)); zeros(z,1) ];
    end;
  end;

  % if tf flag set, view transfer functions (mags)
  if tf,
    N = 1024;
    [resp,ft] = freqz( hrirc, 1, N, h.fs );

    % dB mag, omit DC
    dB = 20*log10(abs(resp(2:N)));

    % log freq axis
    if tflog,
      % see CIPIC show_data freq_resp.m
      f = logspace( log10(ft(2)), log10(ft(N)), N-1 );
      dB = interp1( ft(2:N), dB, f )';
    else,
      f = ft(2:N);
    end;

    all = [ all, dB ];
  else, % view impulse responses
    % prefix data with ITD
    if maxitd,
      if lr == 0, % left
        hriri = [ zeros( maxitd + round(h.itd(i)/2), 1 ); hrirc; ...
                  zeros( maxitd - round(h.itd(i)/2), 1 ) ];
      else, % right
        hriri = [ zeros( maxitd - round(h.itd(i)/2), 1 ); hrirc; ...
                  zeros( maxitd + round(h.itd(i)/2), 1 ) ];
      end;
      all = [ all, hriri ];
    else,
      all = [ all, hrirc ];
    end;
  end;

end;

% get current figure
figure( gcf );
colormap('gray');

% viewing data for left or right ear
if lr == 0,
  lrtxt = 'Left';
else,
  lrtxt = 'Right';
end;

% display mags
if tf,
  if tflog,
    %waterfall( log10(f), h.dgrid(dim,posBegin):-inc:h.dgrid(dim,posEnd), all' );
    imagesc( log10(f), h.dgrid(dim,posBegin):-inc:h.dgrid(dim,posEnd), all' );
    axis xy;
    axis( [ log10(f(1)) log10(20000) ...
            h.dgrid(dim,posEnd)-imgoff h.dgrid(dim,posBegin)+imgoff ] );
    xlabel( 'Log Frequency (log10(Hz))' );
    %view(55,50);
    %colormap('default');
  else,
    imagesc( f, h.dgrid(dim,posBegin):-inc:h.dgrid(dim,posEnd), all' );
    axis xy;
    axis( [ f(1) 20000 ...
            h.dgrid(dim,posEnd)-imgoff h.dgrid(dim,posBegin)+imgoff ] );
    xlabel( 'Frequency (Hz)' );
  end;
  impmag = 'Magnitude';
else, % display IRs
  maxval = max(max(abs(all)));
  imagesc( 1:size(all,1), h.dgrid(dim,posBegin):-inc:h.dgrid(dim,posEnd), all', ...
           [ -maxval maxval ] );
  axis xy;
  axis( [ 1 size(all,1) ...
          h.dgrid(dim,posEnd)-imgoff h.dgrid(dim,posBegin)+imgoff ] );
  xlabel( 'Taps' );
  impmag = 'Impulse';
end;

% viewing all el's or az's
if isempty(el),
  ylabel( 'Elevation' );
  title( sprintf( '%s Ear %s Response (az = %.0f)', lrtxt, impmag, az ) );
else, % isempty(az) == 1
  ylabel( 'Azimuth' );
  title( sprintf( '%s Ear %s Response (el = %.0f)', lrtxt, impmag, el ) );
end;
