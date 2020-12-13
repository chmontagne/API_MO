% bfds - delay and sum beamformer demo

% modification history
% --------------------
%                ----  v6.0.0  ----
% 03.06.07  JDM  created
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

% test waveform (see SLABForm.exe)
[ym,fs,nbits,opts] = wavread( 'lab_array1.wav' );
[ ymlen numch ] = size(ym);

% ch1 closest in test file, swap with ch2 to verify alg works for other cases
if 0,
ymtemp = ym(:,1);
ym(:,1) = ym(:,2);
ym(:,2) = ymtemp;
end;

% circular array diameter (cm) / (cm/sample)
% 30 cm -> 38.23 samples
maxdel = 30 / (34600/fs);  % max delay in samples
fprintf( '\nmax delay for 30cm array = %4.1f samples\n\n', maxdel );

% maxdel*2 to ensure maxdel samples in one ch is in another assuming max lag
% and max lead of maxdel
winlen = 2^nextpow2( maxdel*2 );  % 128 for 30cm array

% note: ch max's can differ significantly from xcorr values!
% max                 0   908  1051  1062
% xcorr (winlen 128)  0     8    21    33
% xcorr (winlen 256)  0     9    22    34
% could be corrupted by reflections, etc.

% assume winlen/2 silence preceeds utterance;
[mx mi] = max( ym );  % max in each ch
[cm ci] = max( mx );  % max ch
% center analysis window at max value
wb = mi( ci ) - winlen/2 + 1;  % window begin
we = wb + winlen - 1;          % window end

% get winlen length channel fragments
y = ym(wb:we,:);

% compute xcorr's
xc = zeros( winlen*2 - 1, numch );
for k = 1:numch,
  [ xc(:,k) xclags ] = xcorr(y(:,1),y(:,k));
end;
[ lm li ] = max( xc );
disp( 'raw xcorr lags in samples' );
lags = xclags(li)         % samples (e.g., 0 -8 -21 -33 )
disp( 'lags relative to max lag in samples' );
lags = lags - max(lags)   % one 0 lag ch, the rest negative
disp( 'relative lags in cm' );
(34600/fs) * lags         % cm's, sos/fs (cm/sample) * lags (samples)

% plot ch xcorr's
figure;
plot( xc, '.-' );
grid on;
axis tight;
title( 'cross-correlations' );

% plot ch waveforms and delays;
% normalize to better visualize time alignment and waveform shape
figure;
for k = 1:numch,
  % waveforms
  plot( y(:,k)/mx(k) + 2*(numch-1) - 2*(k-1), '.-' );
  hold on;
  % delays
  plot( winlen/2 - lags(k), ...
        y( winlen/2 - lags(k), k )/mx(k) + 2*(numch-1) - 2*(k-1), 'ro' );
end;
grid on;
title( 'channel waveforms and delays' );

plags = lags - min(lags);
ys = zeros( ymlen - max(plags), 1 );

% plot overlapped sync'd waveforms and sum waveform
ydels = [];
ysum = zeros( winlen, 1 );
for k = 1:numch,
  % normalize to better visualize time alignment
  ydels = [ ydels ym( (wb:we) - lags(k), k )/mx(k) ];
  % equal weights, not normalized
  ysum = ysum + ym( (wb:we) - lags(k), k );

  ys = ys + ym( 1-lags(k) : end-plags(k), k );
end;
ysum = ysum / max(abs(ysum));

figure;
plot( [ ydels ysum ], '.-' );
grid on;
legend( [ cellstr(num2str((1:numch)')); 'DS sum' ] );
title( 'synchronized waveforms and DS sum' );

yy = sum( ym(1:end-max(plags),:), 2 );
yy = yy/max(abs(yy));
y1 = ym(1:end-max(plags),1)/max(abs(ym(:,1)));
y4 = ym(1:end-max(plags),4)/max(abs(ym(:,4)));
ys = ys/max(abs(ys));

figure;
plot( [ y1 ys ] );
grid on;
legend( 'ch1', 'DS sum' );

figure;
plot( [ yy ys ] );
grid on;
legend( 'sum', 'DS sum' );

% play original and D'n'S
if 1,
if 0,
disp('play input ch1...');
pause;
wavplay(y1,fs);
disp('play input ch4...');
pause;
wavplay(y4,fs);
end;
disp('play sum...');
pause;
wavplay(yy,fs);
disp('play DS sum...');
pause;
wavplay(ys,fs);
end;
