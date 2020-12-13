% bf2 - beamformer algorithm 2, xcorr delay and sum
%
% See Also: bf3.m, SLABForm BF2

% modification history
% --------------------
%                ----  v6.0.0  ----
% 03.22.07  JDM  created
% 04.02.07  JDM  real-world measurements, param tweak, EQ
% 04.19.07  JDM  added filter and FFT
% 04.24.07  JDM  FFT delays and trackLags bad value replacement
% 05.17.07  JDM  overhaul, improved alg, sync'd with beamform.cpp
% 05.29.07  JDM  added butter()
% 05.30.07  JDM  frame inc tune, maxlag xcorr
%                ----  v6.0.1  ----
% 06.18.07  JDM  bf2.m/bf3.m code organization sync
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

% ----  notes  ----

% test waveform: can generate 4ch wave file with SLABForm

% xcorr length depends on array size, need signal segment overlap, but not
% so long target location changes;
% maxdel*2 ensures maxdel samples in one ch is in another assuming max lag,
% e.g., 2^nextpow2( maxdel*2 ) = 128 for 30cm array (fs 44100, 48000)
% note, though, this is in ideal conditions, practical values were found to
% be much larger

% big update time values sound bad in real-time dynamic display, e.g.,
% move mouth, speak, lag heard as timbre change

% for helmet recording:
% frame lengths < 1024 (fs 48000) produced less smooth trajectories;
% larger lengths smooth the trajectory but capture more mouth motion,
% e.g., 2048, mouth speed 0.50 m/s, 2.96 samples;
% frame inc 512 (len 1024) less smooth versus 1024;
% frame inc 2048 (len 1024) smoother than 1024 - at 1024, values clump on
% either side of trendline (param tracker), so tracker pulled towards extremes;
% inc 2048, len 1024 nice params due to approx three pitch periods in frame
% 48*8 = 384, 384 * 3 = 1152, and minimal extremes clumping

% ----  knobs  ----

% environment params
diam = 30;   % circular array diameter, cm, (30cm -> 38.23 samples at 44.1)
sos  = 346;  % speed of sound, m/s

% signal params
%
% values depend on wave file used
%
% xcorr gate is multiplied by framelen before it is used so that it can be
% used as a parameter independent of framelen

framelen = 1024;  % frame length, xcorr length, samples
frameinc = 2048;  % frame increment, samples, div or mult of framelen

if 0,
[ym,fs,nbits,opts] = wavread( 'lab_array1.wav' );
% wave not normalized
gate        = 0.00005;  % framelen-independent xcorr gate
fUpdateTime = 40;       % tracking filter time constant, ms
end;

if 0,
[ym,fs,nbits,opts] = wavread( 'space4ch30.wav' );
% wave not normalized, using lowpass code below
gate        = 0.0002;  % framelen-independent xcorr gate
fUpdateTime = 130;     % tracking filter time constant, ms
end;

if 1,
[ym,fs,nbits,opts] = wavread( 'space4ch30_eq.wav' );
% wave not normalized
gate        = 0.0002;  % framelen-independent xcorr gate
fUpdateTime = 130;     % tracking filter time constant, ms
end;

% ----  mouthspeed analysis  ----

% mouthspeed / delay-change relationship;
% might want to decrease frameinc if the delay change gets too high
% (see notebook 3/27/07)
mouthspeed = 0.5; % m/s
fprintf( ...
  [ '\nmax delay change after frameinc (%d) samples assuming max\n' ...
    'mouth speed of %.2f m/s = %.2f samples\n' ], frameinc, mouthspeed, ...
  (mouthspeed/sos)*frameinc );
fprintf( 'inside frame (%d samples) = %.2f samples\n\n', framelen, ...
         (mouthspeed/sos)*framelen );

% ----  lowpass filter  ----

% space4ch30.wav and
% spectrogram(ym(1:800000,1),hamming(8192),4096,8192,48000)
% similar to Sound Forge 8 Spectrum View for ch1_eq_none.wav
% see also: ch1_eq_113_7200.wav
% Sony Graphic EQ, 20 Band, 20,28,40,56,80,113,160...
% first 5 = -Inf. kills low-freq distortion
% 1/8ms = 125Hz - don't corrupt pitch period freq!

% below yields similar results to Sound Forge bandpass approach;
% from fdatool, Highpass, IIR Butterworth, order 2, fs 48000 Hz, fc 100 Hz,
% File | Generate M-file
if 0,
Fs = 48000;  % Sampling Frequency
N  = 2;    % Order
Fc = 100;  % Cutoff Frequency
% Calculate the zpk values using the BUTTER function.
[z,p,k] = butter(N, Fc/(Fs/2), 'high');
% To avoid round-off errors, do not use the transfer function.  Instead
% get the zpk representation and convert it to second-order sections.
[sos_var,g] = zp2sos(z, p, k);
f = dfilt.df2sos(sos_var, g);
ym = filter( f.sosMatrix(1:3), f.sosMatrix(4:6), ym );
end;

% ----  init  ----

% normalize
%ymmax = max(max(abs(ym)));
%ym = ym / ymmax;

% length of input, number of channels
[ ymlen numch ] = size(ym);

% max corrective delay in samples
% circular array diameter (cm) / (cm/sample)
% e.g., 30 cm -> 38.23 samples (fs = 44100)
maxdel = -ceil( diam / (sos*100/fs) );
maxdels = ones(1,numch) * maxdel;

if frameinc >= framelen,
  numframes = floor( ymlen/frameinc );
  lastframe = (numframes-1) * frameinc + 1;   % base index of last frame
else,
  numframes = floor( ymlen/framelen );        % for lastframe calc
  lastframe = (numframes-1) * framelen + 1;   % base index of last frame
  numframes = numframes*framelen/frameinc - 1;
end;

% absolute max xcorr value = framelen for 1.0-normalized samples
gateframe = gate * framelen;

% ----  parameter tracking  ----

% leaky integrator forgetting factor
if fUpdateTime == 0,
  fTrackerAlpha = 0;
else
  % tracker time constant tau = fUpdateTime * (fs/1000) / frameinc
  fTrackerAlpha = exp( -1 / (fUpdateTime * (fs/1000) / frameinc) );
end;

% ----  frame increment  ----

xc = zeros( -maxdel * 2 + 1, numch );  % xcorr output
allRaws   = [];  % pre-proc xcorr ch lags by frame
allLags   = [];  % post-proc ch lags by frame
allMaxs   = [];  % max xcorr value by frame
allRefs   = [];  % reference ch by frame
trackLags = [ 0 0 0 0 ];
tic;
for ib=1:frameinc:lastframe,  % ib = index begin
  ie = ib + framelen - 1;     % ie = index end

  % reference ch is the max energy frame
  [mx,refch] = max( sum( ym(ib:ie,:).^2 ) );
  yref = ym(ib:ie,refch);
  allRefs = [ allRefs; refch ];

  % ----  possible improvements  ----
  % - if cpu% wasn't an issue, could do more ch/ch xcorrs and average
  %   or feed the results into the following step
  % - track mouth location - use delays, array geometry, and acceptable mouth
  %   location area to determine if delays are physically realistic

  % xcorrs referenced to max energy frame
  for k = 1:numch,
    yn = ym(ib:ie,k);
    [ xc(:,k) xclags ] = xcorr( yref, yn, -maxdel );
  end;
  [ lm li ] = max( xc );
  lags = xclags(li);           % channel lags
  lagscor = min(lags) - lags;  % corrective delays

  % ----  xcorr gate  ----
  % for gate and physical tests, used to have xcorrLags and physLags vars that
  % kept most recent values that made it past test, but this yielded less
  % smooth lag trajectories, best to use present tracker trend, otherwise can
  % end up tracking towarnds an extreme value off trend line; also, makes alg
  % more complex, listening tests revealed two methods sounded fairly similar
  if lm >= gateframe,
    lags = lagscor;     % corrective delay
  else,
    lags = trackLags;   % current param tracker value
  end;

  allRaws = [ allRaws; lags ];  % raw delays

  % ----  reject delays that aren't physically realistic  ----
  % unconstrained xcorr() method
  % lags( lags < maxdels ) = trackLags( lags < maxdels );
  % even when constraining xcorr() lags, a corrective delay can exceed maxdel
  lags( lags < maxdels ) = maxdel;

  % ----  notes  ----
  % even though max mouth speed could be a constraining factor on
  % frame-to-frame delay values, it is difficult to detect actual mouth
  % motion delay changes versus noise

  % ----  parameter tracking  ----
  fTarget = lags;
  % track = (1 - alpha) * target + alpha * track
  trackLags = fTarget + fTrackerAlpha * (trackLags - fTarget);
  lags = trackLags;

  if 0,
  fprintf( '--  %5.1f %5.1f %5.1f %5.1f  %.6f %.6f %.6f %.6f\n', ...
           lags(1), lags(2), lags(3), lags(4), lm(1), lm(2), lm(3), lm(4) );
  end;

  allLags = [ allLags; lags ];
  allMaxs = [ allMaxs; lm ];
end;
toc;

% ----  visualization  ----

figure;

subplot(3,1,1);
plot(1:numframes,allLags,'.-');
legend('1','2','3','4');
grid on;
hold on;
plot(1:numframes,allRaws,'x:');
axis( [ 1 numframes+1 maxdel-5 5  ] );
title( sprintf( ...
  [ 'delays, framelen = %d (%.1f ms), frameinc = %d, maxdel = %d, ' ...
    'gate = %.5f, timeconst = %.1f ms' ], ...
  framelen, framelen/(fs/1000), frameinc, maxdel, gate, fUpdateTime ) );
line( [ 1 numframes+1 ], [ maxdel maxdel ] );

subplot(3,1,2);
plot(1:numframes,allMaxs/framelen,'.-');
legend('1','2','3','4');
grid on;
axis( [ 1 numframes+1 0 max(max(allMaxs))/framelen ] );
title( 'max xcorr value per frame' );
line( [ 1 numframes+1 ], [ gate gate ] );

subplot(3,1,3);
plot( (0:(ymlen-1))/fs, ones(ymlen,1) * [ 1 2 3 4 ] + abs(ym), '-' );
grid on;
hold on;
plot( (0:numframes-1)*frameinc/fs, allRefs, 'kx' );
axis( [ 0 (ymlen-1)/fs 1 5 ] );
title( 'rectified input' );
