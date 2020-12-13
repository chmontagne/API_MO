function vir( h, tf, tflog, az, el, lr, ls, rs, nrm, of, win, scale )
% vir - impulse response viewing utility.
%
% vir( h, tf, tflog, az, el, lr, ls, rs, nrm, of, win, scale )
%
% h     - sarc struct
% tf    - view transfer functions flag (default = 0)
% tflog - log frequency flag (default = 1)
% az    - azimuth (degrees) (see below)
% el    - elevation (degrees) (see below)
% lr    - 0 = left, 1 = right, 2 = both (default = 2)
% ls    - left line style (default = 'b')
% rs    - right line style (default = 'r')
% nrm   - normalize data flag (default = 1)
% of    - data offset (default = 1)
% win   - data window (default = length of IR - of + 1)
% scale - IR scale factor (default = 1)
%
% If az and el are not specified, vir iterates through all database locations.
% If az specified and el == [], vir iterates through all el's at az.
% If az specified and el not specified, vir displays the AZ,EL at the grid
% location passed in az.
%
% When iterating, hitting a key advances to the next location.

% modification history
% --------------------
% 11.19.99  JDM  created
% 03.29.00  JDM  added magnitude view
% 02.22.01  JDM  cleaned-up plot labels
% 05.31.01  JDM  fixed logs
% 06.18.01  JDM  added taps var, freq axis(), amplitude +/-1
% 06.22.01  JDM  fixed ITD display
% 10.18.02  JDM  name change, vmap -> vir
% 11.13.02  JDM  SLH input to sarc struct
%                ----  v5.3.0  ----
% 08.15.03  JDM  updated to new sarc format
% 08.19.03  JDM  added raw param
%                ----  v5.4.0  ----
% 10.24.03  JDM  added tflog semilogx(), "no data" check
% 10.29.03  JDM  added isempty posBegin,posEnd check
% 10.30.03  JDM  added az grid specification option, min() for az,el spec in
%                case of multiple entries
% 11.03.03  JDM  added lr, ls, rs, pls, prs, nrm
% 11.07.03  JDM  ITD from text() to title()
% 11.11.03  JDM  added fs
% 11.21.03  JDM  updated to new v4 sarc
%                ----  v5.5.0  ----
% 06.07.04  JDM  made normalization more efficient for single location display
%                ----  v5.8.0  ----
% 11.16.05  JDM  "== []" to isempty
% 04.20.06  JDM  freqz N 1024 to 4096
%                ----  v5.8.1  ----
% 06.28.06  JDM  added abs() in nrm calc; added scale
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
  disp( 'vir error: not enough input arguments.' );
  return;
end;

% defaults
if nargin < 2,  tf    = 0;      end;  % don't view transfer functions
if nargin < 3,  tflog = 1;      end;  % log freq
if nargin < 6,  lr    = 2;      end;
if nargin < 7,  ls    = 'b';    end;
if nargin < 8,  rs    = 'r';    end;
if nargin < 9,  nrm   = 1;      end;

% if normalizing data, find scale factor
if nrm,
  scale = 1.0 / max(max(abs(h.ir)));
end;

[taps num] = size(h.ir);

% more defaults
if nargin < 10,  of  = 1;              end;
if nargin < 11,  win = taps - of + 1;  end;
if nargin < 12,  scale = 1;            end;

% HRTF locations to view
if nargin < 4,        % view all az,el's
  posBegin = 1;
  posEnd   = length( h.dgrid );
elseif nargin == 4,   % view specific grid location
  posBegin = az;
  posEnd   = az;
else                  % view set of el's or specific az,el
  if isempty(el),
    % view set of el's
    posBegin = hindex( az, max(h.dgrid(1,:)), h.dgrid );
    posEnd   = hindex( az, min(h.dgrid(1,:)), h.dgrid );
  else,
    % min() in case of multiple entries
    posBegin = min( hindex( az, el, h.dgrid ) );
    posEnd   = posBegin;
  end;
end;

% make sure requested location exists
if isempty( posBegin ) | isempty( posEnd ),
  plot( [-1 1], [0 0] );
  text( -0.1, 0.1, 'no data' );
  return;
end;

% get current figure
figure( gcf );

for i = [ posBegin : posEnd ],

  azi = h.dgrid(2,i);
  eli = h.dgrid(1,i);

  if of > taps,
    hrirL = zeros( win, 1 );
    hrirR = zeros( win, 1 );
  else,
    z = 0;
    i2 = of + win - 1; % index 2 (index 1 = of)
    if i2 > taps,
      z  = i2 - taps; % zero padding
      i2 = taps;
    end;
    if nrm,
      hrirL = [ h.ir(of:i2,i)*scale; zeros(z,1) ];
      hrirR = [ h.ir(of:i2,i+size(h.dgrid,2))*scale; zeros(z,1) ];
    else,
      hrirL = [ h.ir(of:i2,i); zeros(z,1) ];
      hrirR = [ h.ir(of:i2,i+size(h.dgrid,2)); zeros(z,1) ];
    end;
  end;

  % apply linear scalar
  hrirL = hrirL * scale;
  hrirR = hrirR * scale;

  % if tf flag set, view transfer functions
  if tf,
    [lh,lw] = freqz( hrirL, 1, 4096, h.fs );
    [rh,rw] = freqz( hrirR, 1, 4096, h.fs );
    if tflog,
      switch lr
        case 0
          semilogx( lw, 20*log10(abs(lh)), ls );
        case 1
          semilogx( rw, 20*log10(abs(rh)), rs );
        case 2
          semilogx( lw, 20*log10(abs(lh)), ls, rw, 20*log10(abs(rh)), rs );
      end;
    else,
      switch lr
        case 0
          plot( lw, 20*log10(abs(lh)), ls );
        case 1
          plot( rw, 20*log10(abs(rh)), rs );
        case 2
          plot( lw, 20*log10(abs(lh)), ls, rw, 20*log10(abs(rh)), rs );
      end;
    end;
    axis( [ 20 20000 -80 20 ] );
    xlabel( 'Frequency' );
    ylabel( 'Magnitude' );
    impmag = 'Magnitude';
  else, % view impulse responses
    switch lr
      case 0
        plot( 1:win, hrirL, ls );
      case 1
        plot( 1:win, hrirR, rs );
      case 2
        plot( 1:win, hrirL, ls, 1:win, hrirR, rs );
    end
    axis( [1 win -1 1] );
    xlabel( 'Sample Index' );
    ylabel( 'Amplitude' );
    impmag = 'Impulse';
  end;

  if isempty( h.itd ),
    [strTitle] = sprintf( '%s Response (%.0f,%.0f)', impmag, azi, eli );
  else,
    [strTitle] = sprintf( ...
    '%s Repsonse (%.0f,%.0f)  (ITD: %6.2f samples)', impmag, azi, eli, h.itd(i) );
  end;
  title( strTitle );
  grid;

  if nargin < 4 | (nargin == 5 & isempty(el)),
    pause;
  end;

end;
