function win = ffbl2(fLOW,fHI,fs,fftlen)
% ffbl2 - free-field eq band-limit window design.
%
% win = ffbl2( fLOW, fHI, fs, fftlen )
%
% parameter frequencies in Hertz
%
% Example:  win = ffbl2(400,17000,96000,2048);
%
% Note:  Values above from HeadZap headphone eq.  Free-field eq values the
%        same except fftlen = 256.

% modification history
% --------------------
%                ----  v5.6.0  ----
% 11.08.04  JDM  created
% 11.17.04  JDM  renamed, ffeq3.m -> ffbl2.m
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR
%                ----  v6.0.0  ----
% 08.30.06  JDM  added transition band info, return value, plots
% 09.14.06  JDM  now more about trap window than bin calc
%
% JDM == Joel D. Miller

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

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

% often, the two bin calcs are the same, but they can differ:
%
% >> ffbl2(700,17000,20000,256)
% OLD
% LOW:  bin =  10    703 Hz
% HI:   bin = 220  17109 Hz
% NEW
% LOW:  bin =   9    625 Hz
% HI:   bin = 219  17031 Hz
%
% >> ffbl2(700,17000,96000,256)
% OLD
% LOW:  bin =   2    375 Hz
% HI:   bin =  46  16875 Hz
% NEW
% LOW:  bin =   2    375 Hz
% HI:   bin =  47  17250 Hz

% if run as macro instead of function
if 0,
fLOW   = 400;
fHI    = 17000;
fs     = 96000;
fftlen = 2048;
end;

fprintf( '\nwindow = 1 edge indices:\n\n' );

% OLD eqns
if 0,
bin_fLOW = ceil(fLOW/((fs/2)/(fftlen/2+1)));
bin_fHI  = ceil(fHI /((fs/2)/(fftlen/2+1)));
fprintf( 'OLD\n' );
fprintf( 'LOW:  bin = %4d  %5.0f Hz\n', bin_fLOW, (bin_fLOW-1)*fs/fftlen );
fprintf( 'HI:   bin = %4d  %5.0f Hz\n', bin_fHI,  (bin_fHI -1)*fs/fftlen );
fprintf( '\nNEW\n' );
end;

% bins
bin_fLOW = floor( fLOW / (fs/fftlen) ) + 1;
bin_fHI  = ceil(  fHI  / (fs/fftlen) ) + 1;
% freqs
bin_fLOWf = (bin_fLOW-1)*fs/fftlen;
bin_fHIf  = (bin_fHI -1)*fs/fftlen;

fprintf( 'LOW:  bin = %4d  %5.0f Hz\n', bin_fLOW, bin_fLOWf );
fprintf( 'HI:   bin = %4d  %5.0f Hz\n', bin_fHI,  bin_fHIf  );

% construct band-limiting window (applied to dB scale freq resp)
% (see ffbl.m)
win = ones(fftlen/2+1,1);
fadeLength = 30;	% length of fade bins
win(1) = 0; % don't compensate for DC
win(2:bin_fLOW) = linspace(0, 1, bin_fLOW-1);
win(bin_fHI:min(bin_fHI+fadeLength-1,length(win))) = ...
  linspace(1, 0, min(length(win(bin_fHI:length(win))),fadeLength));
win(min(bin_fHI+fadeLength,length(win)):length(win)) = 0;
win = [win;flipud(win(2:length(win)-1))];

fprintf('\nwindow nonzero fade indices:\n\n');
flen = fftlen/2 + 1;
lobin = min(find(win(1:flen)>0));
hibin = max(find(win(1:flen)>0));
lobinf = (lobin-1)*fs/fftlen;
hibinf = (hibin-1)*fs/fftlen;
fprintf( 'LOW:  bin = %4d  %5.0f Hz\n', lobin, lobinf );
fprintf( 'HI:   bin = %4d  %5.0f Hz\n', hibin, hibinf );

fprintf( '\ntrapezoidal window (Hz):\n\n' );
fprintf( '       %5.0f  %5.0f\n', fLOW, fHI );
fprintf( '%5.0f  %5.0f  %5.0f  %5.0f\n\n', ...
         lobinf, bin_fLOWf, bin_fHIf, hibinf );

% plot window
% f actually starts at 0 but that causes log of zero error in semilogx()
figure;
f = (fs/fftlen) * (1:flen-1);
semilogx( [1 f], win(1:flen), 'b.-' );  % DC not shown
hold on;
grid on;
axis( [ 20 max(f) -0.1 1.1 ] );
xlabel( 'frequency (Hz)' );
title( sprintf('band-limit window dB FFT bin scalar ( %d Hz, %d Hz, %d, %d )', ...
       fLOW, fHI, fs, fftlen ) );
semilogx( [ 1 fLOW-1 fLOW fHI fHI+1 fs/2 ], ...
          [ 0 0 1 1 0 0 ], 'r-' );
legend( 'scalar', 'spec', 2 );

% plot IR and minphase IR
figure;
db = -12.0;
win = 10.^( win * db / 20 );  % apply window to flat db offset filter
win = 1 ./ win;               % inverse filter
winfilt = real(ifft(win));
[dummy winfiltmp] = rceps(winfilt);
plot( winfilt, 'g' );
hold on;
plot( winfiltmp, 'b' );
grid on;
title( 'IR of band-limit window applied to constant attenuation filter' );
legend( 'non-min-phase', 'min-phase', 1 );

% plot frequency response
figure;

% zero-padded filter response
plotresp(winfiltmp,16384,96000,'b',20,48000,-5,-db+5,1);
hold on;

% for ffbl2 params 400,17000,96000,2048, plotresp() zero-padding will
% result in different winfilt and winfiltmp mag responses (note spike at end
% of winfilt IR, winfiltmp tapers towards zero)
% plotresp(winfilt,16384,96000,'r',20,48000,-100,10,1);

% non-zero-padded filter response
[ax1,ax2] = plotresp(winfiltmp,fftlen,96000,'m',20,48000,-5,-db+5,1);

% ideal response
axes(ax1);
semilogx( [ 1 fLOW-1 fLOW fHI fHI+1 fs/2 ], ...
          [ 0 0 -db -db 0 0 ], 'r-' );
legend( 'FFT 16384', sprintf( 'FFT %d', fftlen ), 'ideal', 2 );
