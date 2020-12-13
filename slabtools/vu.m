% vu.m - VU meter analysis
%
% See Also:  peak.m, sd.m

% modification history
% --------------------
%                ----  v6.0.2  ----
% 01.11.08  CJM  created from silence detect script sd.m
%
% CJM == Joel D. Miller, Copyright Joel D. Miller (see below)
%
% References:
% http://en.wikipedia.org/wiki/VU_Meter
% http://en.wikipedia.org/wiki/Root_mean_square
% http://en.wikipedia.org/wiki/Time_constant
% http://en.wikipedia.org/wiki/Rise_time
% http://en.wikipedia.org/wiki/Decibel
% http://en.wikipedia.org/wiki/DBFS

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% Copyright (C) 2006-2018 Joel D. Miller.  All Rights Reserved.
%
% This software constitutes a "Modification" to the SLAB software system and is
% distributed under the NASA Open Source Agreement (NOSA), version 1.3.
% The NOSA has been approved by the Open Source Initiative.  See the file
% NOSA.txt at the top of the distribution directory tree for the complete NOSA
% document.

fp = 15;  % frequency of value poll (in Hz)

% From wikipedia:
%
% The typical VU scale is from -20 to +3. The rise and fall times of the meter
% are both 300 milliseconds, meaning that if a constant sine wave of amplitude
% 0 VU is applied suddenly, the meter will take 300 milliseconds to reach the
% 0 on the scale.
%
% This appears to be implying that the 0 VU reference is near, but less than,
% 0.9 peak.
% rise time = time from 0.1 env peak to 0.9 env peak
% below, env peak oscillates between ~0.6610 to ~0.6615
% 0.9 * 0.66125 = 0.595, occurs at time ~314 ms
% This is consistent with the graphically-determined reference below.

% At t = 300ms (0 VU):
Vref = 0.5874;  % env at t = 1.3 s using Figure Data Cursor

% VU Meter test signal:
%
% Pavg = Vrms^2/R, Pavg = 1mW, R = 600 ohms
% Vrms = sqrt( Pavg*R ) = sqrt( 0.6 ) = 0.775 Vrms
% Vp = sqrt( 2 ) * Vrms = sqrt( 1.2 ) = 1.0954 V
%
% RC lowpass time constant and rise/fall time relationship:
%
% v(t) = Vp * (1-exp(-t/tau)),  tau = attack time constant
%
% From wikipedia Rise Time article:
% rise/fall time = tau * log(9), log(9) = 2.1972
%
% tau = 0.3/2.197 = 0.1365 secs

% VU test waveform: 1s silence, 2s sin, 1s silence
fs = 8000;       % Hz
Vp = sqrt(1.2);  % V
ftest = 1000;    % Hz
w = 2*pi*ftest;
x = [ zeros(1,fs) Vp*sin(w*(0:1/fs:2-1/fs)) zeros(1,fs) ];
% x = [ zeros(1,fs) ones(1,2*fs) zeros(1,fs) ];  % to test dBFS meter
% wavplay( x, fs );

% at t = ta into step, env = 0.63 Vp
ta = 0.3/2.197;  % attack time constant, seconds
tr = 0.3/2.197;  % release time constant, seconds

ga = exp( -1.0 / (fs * ta) );
gr = exp( -1.0 / (fs * tr) );

fprintf( '\nta = %f s\ntr = %f s\nga = %f\ngr = %f\n\n', ta, tr, ga, gr );

len = length( x );
env = zeros( len+1, 1 );
for i = 2:(len+1),
  % full-wave rectification
  in = abs( x(i-1) );

  % envelope
  if( in > env(i-1) ),
    % attack
    env(i) = (1-ga) * in + ga * env(i-1);
  else,
    % release
    env(i) = (1-gr) * in + gr * env(i-1);
  end;
end;

% display waveform, envelope, and envelope polling
figure;
t = (0:len-1)/fs;
plot( t, x, 'b', t, env(2:(len+1)), 'g' );
grid on;
% envelope value poll
tp = t(1):1/fp:t(len);  % seconds
np = round( tp*fs );    % samples, 0 base index
hold on;
plot( np/fs, env(2+np), 'go' );
hold off;
title( 'Test Waveform and Full-Wave Rectified Envelope' );
ylabel( 'Amplitude' );
xlabel( 'Time (seconds)' );

% VU Meter vs dBFS Meter
figure;
plot( t, 20*log10( eps + env(2:(len+1))/Vref ) );
hold on;
% Vref = 0.5874, 20*log10(Vref) = -4.6213 dB offset
plot( t, 20*log10( eps + env(2:(len+1)) ), 'r' );
grid on;
axis( [ 0 4 -20 3 ] );  % VU scale -20 to 3
title( 'VU Meter (blue) vs dBFS Meter (red)' );
xlabel( 'Time (seconds)' );
ylabel( 'Level (VU, dBFS)' );
