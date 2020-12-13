% bf3 - beamformer algorithm 3, voice pitch FFT bin phase delay and sum
%
% See Also: bf2.m, SLABForm BF3, bfpitch.m
%
% BF2 is a standard xcorr-based delay and sum beamformer.
%
% BF3 is also a somewhat standard delay and sum beamformer but the delays
% are extracted from FFT phase at the voice pitch period rather than using
% an xcorr.  The hope was to improve performance in reverberant environments.
% This project was paused shortly after the initial version of the algorithm
% was developed.

% modification history
% --------------------
%                ----  v6.0.0  ----
% 04.26.07  JDM  created from bf2.m
%                ----  v6.0.1  ----
% 06.14.07  JDM  applied recent bf2 mods to bf3, e.g., delays to corrective
%                delays
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

% ----  knobs  ----

% environment params
diam = 30;  % circular array diameter, cm
sos = 346;  % speed of sound, m/s

% signal params
%
% values depend on wave file used

% not so long mouth moves; need pitch period resolution; need to capture
% array dimensions time lag; how frequently relates to mouth speed, lag noise
framelen = 1024;
frameinc = 1024;
bin      = 4;         % see pitch period analysis below

if 0,
[ym,fs,nbits,opts] = wavread( 'lab_array1.wav' );
% wave not normalized
magGate = 10      % mag gate
fUpdateTime = 50  % tracking filter time constant, ms
end;

if 0,
% very similar to EQ version but a bit less linear, more 0 lag ch movement
[ym,fs,nbits,opts] = wavread( 'space4ch30.wav' );
% wave not normalized
magGate = 24;       % mag gate
fUpdateTime = 130;  % tracking filter time constant, ms
end;

if 1,
[ym,fs,nbits,opts] = wavread( 'space4ch30_eq.wav' );
% wave not normalized
magGate = 24;       % mag gate
fUpdateTime = 130;  % tracking filter time constant, ms
end;

% ----  pitch period analysis  ----

% 1/0.008 = 125 Hz, pitch period of male voice
% use bin 4, framelen = 1024, (4-1)*48000/1024 = 140.6 Hz
% bins: 0, 47, 94, 141, 188, ... Hz at fs = 48000
%       0, 43, 86, 129, 172, ... Hz at fs = 44100
pitchPeriod = 8;  % ms
freq = (bin-1)*fs/framelen;
rads2samps = (fs/freq)/(2*pi);
fprintf( '\nfs = %d samples/s\n', fs );
fprintf( 'pitch period = %d ms (%.1f Hz)  bin %d (of %d) = %.1f Hz\n\n', ...
         pitchPeriod, 1000/pitchPeriod, bin, framelen, freq );

% ----  init  ----

% normalize
%ymmax = max(max(abs(ym)));
%ym = ym / ymmax;

% length of input, number of channels
[ ymlen numch ] = size(ym);

% max corrective delay in samples
% circular array diameter (cm) / (cm/sample)
% e.g., 30 cm -> 38.23 samples (fs = 44100)
maxdel = -ceil( diam / (sos*100/fs) );  % max delay in samples
maxdels = ones(1,numch) * maxdel;

if frameinc >= framelen,
  numframes = floor( ymlen/frameinc );
  lastframe = (numframes-1) * frameinc + 1;   % base index of last frame
else,
  numframes = floor( ymlen/framelen );        % for lastframe calc
  lastframe = (numframes-1) * framelen + 1;   % base index of last frame
  numframes = numframes*framelen/frameinc - 1;
end;

% ----  parameter tracking  ----

% leaky integrator forgetting factor
if fUpdateTime == 0,
  fTrackerAlpha = 0;
else
  % tracker time constant tau = fUpdateTime * (fs/1000) / frameinc
  fTrackerAlpha = exp( -1 / (fUpdateTime * (fs/1000) / frameinc) );
end;

% ----  frame increment  ----

trackLags = [ 0 0 0 0 ];
allRaws   = [];   % pre-proc ch lags by frame
allLags   = [];   % post-proc ch lags by frame
allPhases = [];
allMags   = [];
tic;
for ib = 1:frameinc:lastframe,  % ib = index begin
  ie = ib + framelen - 1;       % ie = index end

  % !!!! window definately makes a difference!
% X = fft( (hanning(framelen)*ones(1,4)) .* ym(ib:ie,:), framelen );
  X = fft( ym(ib:ie,:), framelen );
  Xa = angle( X(bin,:) );
  Xm = abs( X(bin,:) );

  % if any neighbor diffs (for ease of coding) are > pi, wrap neg value
  if sum( abs(diff(Xa)) > pi ) > 0,
    Xa( Xa < 0 ) = Xa( Xa < 0 ) + 2*pi;
  end;

  allPhases = [ allPhases; Xa ];
  allMags   = [ allMags;   Xm ];

  % radians to samples
  lags = rads2samps*Xa;

  % ----  mag gate  ----
  if sum(Xm) < magGate,
    % !!!! this can result in all negative delays, i.e., min delay tracking
    % towards zero halts on value on the way to zero
    lags = trackLags;  % use current param tracker lags

    allRaws = [ allRaws; lags ];
  else,
    % corrective lags
    lags = min(lags) - lags;

    allRaws = [ allRaws; lags ];

    % ----  reject delays that aren't physically realistic  ----
    % ???? which is better method?
    % maxdel set better with lab_array1.wav
    % lags( lags < maxdels ) = trackLags( lags < maxdels );
    lags( lags < maxdels ) = maxdel;

    % ----  parameter tracking  ----
    fTarget = lags;
    % track = (1 - alpha) * target + alpha * track
    trackLags = fTarget + fTrackerAlpha * (trackLags - fTarget);
    lags = trackLags;
  end;

  % to compare to C-code, reduce numframes and disable normalization
  %fprintf( '--  %8.3f %8.3f %8.3f %8.3f  %8.3f %8.3f %8.3f %8.3f\n', ...
  %         lags(1), lags(2), lags(3), lags(4), Xm(1), Xm(2), Xm(3), Xm(4) );

  allLags = [ allLags; lags ];
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
    'magGate = %.1f, timeconst = %.1f ms' ], ...
  framelen, framelen/(fs/1000), frameinc, maxdel, magGate, fUpdateTime ) );
line( [ 1 numframes+1 ], [ maxdel maxdel ] );

subplot(3,1,2);
plot(allMags);
hold on;
plot(sum(allMags,2),'k');
axis([1 size(allMags,1) 0 max(sum(allMags,2))]);
legend('1','2','3','4');
grid on;
title( 'freq bin mags' );
line( [ 1 numframes+1 ], [ magGate magGate ] );

subplot(3,1,3);
plot( (0:(ymlen-1))/fs, ym, '-' );
grid on;
axis( [ 0 (ymlen-1)/fs -1 1 ] );
title( 'input' );
