function ffeqtest()
% ffeqtest - tests ffeq(), a free-field eq inverse filter design function.
%
% See ffeq() for information regarding processing artifacts.  This function
% and ffeq() can be used to visualize these artifacts.

% modification history
% --------------------
%                ----  v5.6.0  ----
% 11.17.04  JDM  separated from ffeq()
% 11.19.04  JDM  hanning/in/out window
% 11.22.04  JDM  lengths in ms instead of samples; added testeqorg,
%                NASA ff data
% 02.28.05  JDM  clean-up
%                ----  v5.8.0  ----
% 09.15.05  JDM  NASA FF demo data to slabtools
% 09.28.05  JDM  added to SUR
%                ----  v6.0.0  ----
% 10.03.06  JDM  added ffbl() warning
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

% read free-field measurement

if 0,
% IRCAM FF data, stereo, 8192 samples
% Note: IRCAM IRC_M_KNO_1.wav contains 24-bit samples and wavread() only
% supports up to 16.  WAV converted to 16-bit in Sound Forge.
% Response before noise floor ~= 4000 samples (incl. long, low osc).
[y,fs,nbits] = wavread('C:\AMAT\IRCAM_KU100\IRC_M_KNO_1_16.wav');
% fs = 44100
% size(y,1) = 8192 % ff length
start = 236; % window start index, by eye
end;

if 1,
% NASA FF data, stereo, 1024 samples, measured using:
% [ resp, clip, err ] = onezap( [29], [1 2], 44100, 11, 1024, 1, 1 );
% [ resp, clip, err ] = onezap( [29], [1 2], 96000, 11, 1024, 1, 1 );
bufstr = load( 'ff44_10.mat' );
fs = 44100;
%bufstr = load( 'ff96_10.mat' );
%fs = 96000;
y = bufstr.resp; % 1024x2
[ dummy start ] = max( y(:,1) );
start = start - 5;
end;

% max signal length
% round( 92.880 * 44100/1000 ) = 4096
%NSms = 92.880; % ms
NSms = 10.0; % ms
NS = round( NSms * fs/1000 ); % samples

NF = 8192; % freqz() length, should be larger than NS

% limit signal length to NS, extract left ch
ly = size(y,1);
if ly > NS,
  ly = NS;              % max signal length
  ynorm = y(1:ly,1);    % truncate, left ch
else,
  ynorm = y(:,1);       % left ch
end;

% normalize
maxabs = max( abs( ynorm ) );
ynorm = ynorm/maxabs;

% length of window applied to ff measurement
% 256/96   =  2.67ms, AuSIM
% 200/44.1 =  4.54ms, CIPIC
% 512/44.1 = 11.61ms, JDM tests with IRCAM data
% round( 4.535 * 44100/1000 ) = 200
lwinms = 4.535; % window length, ms
lwin = round( lwinms * fs/1000 ); % samples

% create a window with hanning tapered leadin leadout
% (windowing based on CIPIC script)

% leadin length
% round( 0.454 * 44100/1000 ) = 20
w_inms = 0.454; % length of leading hanning window, ms
w_in   = round( w_inms * fs/1000 ); % samples

% leadout length
% round( 2.268 * 44100/1000 ) = 100
w_outms = 2.268; % length of trailing hanning window, ms
w_out   = round( w_outms * fs/1000 ); % samples

w1  = hanning( w_in ); % lead in
w1  = w1( 1:round(w_in/2) );
w2  = hanning( w_out ); % lead out
w2  = w2( round(w_out/2)+1:end );
win = [ w1; ones(lwin-(length(w1)+length(w2)),1); w2 ]; % full window

% window input
switch 3, % numbers defined below
  case 1 % no window
    sig = ynorm;
  case 2 % rect window
    sig = ynorm( start:(start+lwin-1) ); % window response, manual start pt
  case 3 % hanning/in/out window
    [m n] = max( ynorm );
    sig = win .* ynorm( (n-round(w_in/2)):(n-round(w_in/2)+lwin-1) );

    % window and windowed ff data
    figure;
    subplot(2,1,1);
    plot( 1:length(ynorm), ynorm, 'b', ...
      (n-round(w_in/2)):(n-round(w_in/2)+lwin-1), win, 'r' );
    title( 'ff measurement, hanning/in/out window' );
    axis( [ 1 length(ynorm) -1.1 1.1 ] );
    grid;
    subplot(2,1,2);
    plot( sig );
    axis( [ 1 length(sig) -1 1 ] );
    grid;
		
    % window mag and phase (with boxcar() reference)
    figure;
    [h1,w1] = freqz( win, [1], NF, fs );
    [h2,w2] = freqz( boxcar(length(win)), [1], NF, fs );
    subplot(2,1,1); % mag
    plot( w1, 20*log10(abs(h1)), 'b', w2, 20*log10(abs(h2+eps)), 'r' );
    title( 'window, r = rect, b = hanning/in/out' );
    ylabel( 'magnitude' );
    grid;
    axis( [ min(w1) max(w1) -60 60 ] );
    subplot(2,1,2); % phase
    plot( w1, angle(h1), 'b', w2, angle(h2), 'r' );
    ylabel( 'phase' );
    grid;
    axis( [ min(w1) max(w1) -pi pi ] );
end;

% create band-limited free-field eq inverse filter;
% (JDM, 10/3/06, normalization warning - see ffbl())
[ invfilt, sigmp ] = ffeq( sig, fs );

% plot frequency responses
[h1,w1] = freqz( sig,     [1], NF, fs ); % original ff
[h2,w2] = freqz( sigmp,   [1], NF, fs ); % mp of original ff
[h3,w3] = freqz( invfilt, [1], NF, fs ); % inv of mp
figure;
subplot(2,1,1);
semilogx( w1, 20*log10(abs(h1)), 'r',  w2, 20*log10(abs(h2)), 'b--', ...
          w3, 20*log10(abs(h3)), 'g' );
title( 'mag, r=original, b=original/mp, g=inv/BL/mp' );
grid;
axis( [ 20 20000 -25 25 ] );
subplot(2,1,2);
plot( w1, angle(h1), 'r', w2, angle(h2), 'b', w3, angle(h3), 'g' );
title( 'phase' );
grid;
axis( [ 20 20000 -pi pi ] );

% inverse filter applied to original FF response
testeqorg = conv( ynorm, invfilt );

% inverse filter applied to windowed FF response
testeqinv = conv( sig, invfilt );

% inverse filter applied to minphase windowed FF response
testeqmp = conv( sigmp, invfilt );

LC = size( testeqinv, 1 );

% plot
figure;
plot( 1:LC, testeqinv, 'r.-', 1:LC, testeqmp,'b.-' );
grid;
title('inv applied to windowed FF (red) and windowed/mp FF (blue)');

% plot applied filters
[h1,w1] = freqz( testeqinv, [1], NF, fs ); % windowed*inv
[h2,w2] = freqz( testeqmp,  [1], NF, fs ); % windowed_mp*inv
[h3,w3] = freqz( testeqorg, [1], NF, fs ); % original*inv
figure;
subplot(2,1,1);
semilogx( w1, 20*log10(abs(h1)), 'r', w2, 20*log10(abs(h2)), 'b--', ...
          w3, 20*log10(abs(h3)), 'g:' );
title( 'mag, g = inv*fforg, r = inv*ffwin, b = inv*ffwinmp' );
grid;
axis( [ 20 20000 -5 5 ] );
subplot(2,1,2);
plot( w1, angle(h1), 'r', w2, angle(h2), 'b', w3, angle(h3), 'g:' );
title( 'phase' );
grid;
axis( [ 20 20000 -pi pi ] );
