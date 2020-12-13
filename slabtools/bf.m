% bf - mic array beamforming response

% modification history
% --------------------
%                ----  v6.0.0  ----
% 02.15.07  JDM  created
% 02.20.07  JDM  interference and sensitivity plots
% 02.27.07  JDM  units, steering, clean-up
% 03.02.07  JDM  freq resp for one point
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

% test signal frequency and period
f = 2000;  % Hz
T = 1/f;   % s

% steering location, cm
sx1 = -5;
sy1 = -5;
%sx1 = 0;
%sy1 = 0;
fprintf( '\nsteering location = ( %.1f cm, %.1f cm )\n', sx1, sy1 );

% frequency response location, cm
%sx2 = sx1;
%sy2 = sy1;
sx2 = 0;
sy2 = 0;

% speed of sound (from slabdefs.h)
dSoundSpeed = 346.0;        % meters/s
soscm = dSoundSpeed * 100;  % cm/s

% Nt discreet-time samples, one period of test signal
Nt = 50;
t = 0 : (T/(Nt-1)) : T;     % seconds

% mic positions

% arc array
r  = 15;                    % circle radius, cm
x5 =  r*cos(60*pi/180);     % 5 o'clock angle relative to 3 oc
y5 = -r*sin(60*pi/180);
x  = [ -r -x5 x5 r ];       % 9, 7, 5, 3 oc
y  = [  0  y5 y5 0 ];

% circular array
%x  = [ -r -x5 x5 r -x5  x5 ];       % 9, 7, 5, 3, 11, 1 oc
%y  = [  0  y5 y5 0 -y5 -y5 ];

% linear array
%x  = [ -10  -5   0   5  10 ];
%y  = [ -10 -10 -10 -10 -10 ];

Nm = length(x);           % number of mics
mw = (1/Nm)*ones(1,Nm);   % array weights

% delays from steering location to mic
md = sqrt( (x-sx1).^2 + (y-sy1).^2 ) / soscm;  % seconds
% delays relative to mic 1
md = md - md(1);

% location of mics
fprintf( '\nmic locations x,y (cm), weights, delays (us):\n\n' );
fprintf( '%5.1f  %5.1f  %4.2f  %6.1f\n', [ x; y; mw; md*1000000 ] );

% dimensions of analysis area = 2*dd x 2*dd
dd = 20;     % cm
inc = 0.25;  % simulation grid increment, cm
simgrid = -dd:inc:dd;

% responses
resps = zeros( 2*dd/inc, 2*dd/inc );  % 1 period summed response
respi = zeros( 2*dd/inc, 2*dd/inc );  % interference pattern

% sample x,y space
c = 1;  % col == x
for sx = simgrid,
  r = 1;  % row == y
  for sy = simgrid,
    sr = zeros( Nt, 1 );    % sum of signals reaching mics
    si = 0;                 % interference pattern
    for m = 1 : Nm,  % for each mic
      % source-mic distance and delay for mic m
      dist = sqrt( (x(m)-sx)^2 + (y(m)-sy)^2 );   % distance, cm
      del = dist / soscm;                         % delay, s

      % spread rolloff, recorded level at 1cm or less = 1
      rolloff = 1;
      if dist > 1,
        rolloff = 1/dist;
      end;
      sr = sr + rolloff * mw(m) * sin( 2*pi*f * (t + del - md(m)) )';
      si = si + sin( 2*pi*f * (del - md(m)) );
    end;
    resps( r, c ) = 20*log10( sqrt( sum(sr.*sr)/Nt )/0.707 );
    respi( r, c ) = si;
    r = r + 1;
  end;
  c = c + 1;
end;

figure;

% mic array response, dB
subplot(2,1,1);
imagesc( simgrid, simgrid, resps, [ -60 0 ] );
hold on;
grid on;
plot(x,y,'ks',sx1,sy1,'kd',sx2,sy2,'ko');
xlabel('x (cm)');
ylabel('y (cm)');
axis xy;
axis( [ -dd dd -dd dd ] );
colormap('jet');  % see also: copper, gray
colorbar;
title( sprintf( 'f = %.1f Hz, T = %.2f ms, L = %.1f cm', f, T*1000, soscm*T ) );

% mic array interference pattern
subplot(2,1,2);
imagesc( simgrid, simgrid, respi, [ -Nm Nm ] );
hold on;
grid on;
plot(x,y,'ks',sx1,sy1,'kd',sx2,sy2,'ko');
xlabel('x (cm)');
ylabel('y (cm)');
axis xy;
axis( [ -dd dd -dd dd ] );
colormap('jet');
colorbar;
title( 'Interference Pattern' );

fprintf('\n');

% if the steering point were not adaptive to mouth location, the mouth would
% move through a series of different frequency responses, possibily
% contributing to speech recognition errors or poor fidelity

% frequency response at one point in space
sx = sx2;
sy = sy2;
Nt = 25;
frange = [ 1 200:200:20000 ];
respm = zeros( length( frange ), 1 );
fi = 0;
for f = frange,
  T = 1/f;  % new time sequence for each f for proper resolution
  t = 0 : (T/(Nt-1)) : T;  % seconds
  fi = fi + 1;
  sr = zeros( Nt, 1 );    % sum of signals reaching mics
  for m = 1 : Nm,  % for each mic
    % source-mic distance and delay for mic m
    dist = sqrt( (x(m)-sx)^2 + (y(m)-sy)^2 );   % distance, cm
    del = dist / soscm;                         % delay, s

    % spread rolloff, recorded level at 1cm or less = 1
    rolloff = 1;
    if dist > 1,
      rolloff = 1/dist;
    end;
    sr = sr + rolloff * mw(m) * sin( 2*pi*f * (t + del - md(m)) )';
  end;
  respm( fi ) = 20*log10( sqrt( sum(sr.*sr)/Nt )/0.707 );
end;

figure;
plot( frange, respm, '.-' );
grid on;
axis( [ 0 20000 -60 0 ] );
title( sprintf( 'frequency response at ( %.1f, %.1f ) cm', sx, sy ) );
xlabel( 'frequency, Hz' );
ylabel( 'dB' );
