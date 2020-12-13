% sd.m - silence detection
%
% See Also:  peak.m, vu.m

% modification history
% --------------------
%                ----  v6.0.2  ----
% 01.09.08  CJM  created from peak.m
% 01.16.08  CJM  added lastval, xfade, skipped
%
% CJM == Joel D. Miller, Copyright Joel D. Miller (see below)

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% Copyright (C) 2006-2018 Joel D. Miller.  All Rights Reserved.
%
% This software constitutes a "Modification" to the SLAB software system and is
% distributed under the NASA Open Source Agreement (NOSA), version 1.3.
% The NOSA has been approved by the Open Source Initiative.  See the file
% NOSA.txt at the top of the distribution directory tree for the complete NOSA
% document.

fp = 15;  % frequency of value poll (in Hz)

[ x, fs, nbits, opts ] = wavread( '\af\silence_detect.wav' );
size(x)
fs
nbits
opts.fmt
% wavplay( x, fs );

% at t = ta into step, env = 0.63 Vp
ta = 0.3/2.197;  % attack time constant, seconds
tr = 0.3/2.197;  % release time constant, seconds

ga = exp( -1.0 / (fs * ta) );
gr = exp( -1.0 / (fs * tr) );

fprintf( '\nta = %f s\ntr = %f s\nga = %f\ngr = %f\n\n', ta, tr, ga, gr );

len = length( x );
env = zeros( len+1, 1 );      % envelope follower values
x2 = zeros( len, 1 );         % output for visualizing
x3 = zeros( len, 1 );         % output for listening

% silence detection params
sThresh = 0.05;               % level threshold
sTime = 0.5;                  % time below level threshold, seconds
sSamples = fs * sTime;        % in samples
sCount = 0;                   % time counter, samples
sBack = round( (ta/2)*fs );   % exit silence mode fade in

s = 1;
skipped = 0;
for i = 2:(len+1),
  % rectify
  in = abs( x(i-1) );

  % envelope
  if( in > env(i-1) ),
    % attack
    env(i) = (1-ga) * in + ga * env(i-1);
  else,
    % release
    env(i) = (1-gr) * in + gr * env(i-1);
  end;

  % not in silence detect mode if level exceeds sThresh
  if( env(i) >= sThresh )
    if( sCount == sSamples )  % just out of silence mode
      % make sure we don't go back further than we've skipped
      if( skipped > sBack )
        skipped = sBack;
      end;
      % fade in
      for f = skipped-1:-1:1,
        xfade = (skipped-f)/skipped;
        x2(i-1-f) = (1-xfade) * lastval + xfade * x(i-1-f);
        x3(s) = x2(i-1-f);
        s = s + 1;
      end;
      skipped = 0;
    end;
    x2(i-1) = x(i-1);
    x3(s) = x(i-1);
    s = s + 1;
    sCount = 0;
    lastval = x(i-1);
  else,
    % if in silence detect mode, skip data
    if( sCount == sSamples )
      x2(i-1) = lastval;  % for plotting
      skipped = skipped + 1;
    else,  % increment towards silent mode
      sCount = sCount + 1;
      x2(i-1) = x(i-1);
      x3(s) = x(i-1);
      s = s + 1;
      lastval = x(i-1);
    end;
  end;
end;

% waveform, envelope
figure;
t = (0:len-1)/fs;
plot( t, x, 'b', t, env(2:(len+1)), 'g', t, x2, 'r' );
grid on;
% envelope value poll
tp = t(1):1/fp:t(len);  % seconds
np = round( tp*fs );    % samples, 0 base index
hold on;
plot( np/fs, env(2+np), 'go' );
hold off;
title( sprintf( 'Silence Detection (ta=%5.3fs, tr=%5.3fs)', ta, tr ) );
ylabel( 'Amplitude' );
xlabel( 'Time (seconds)' );
axis( [ 0 t(end) -1 1 ] );

% waveform with silence removed
figure;
plot( t, x3, 'r' );
title( 'Silence Removal' );
ylabel( 'Amplitude' );
xlabel( 'Time (seconds)' );
axis( [ 0 t(end) -1 1 ] );
grid on;
