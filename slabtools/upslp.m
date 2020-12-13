% upslp - upsampling lowpass filter analysis.
%
% Demonstrate 11025/22050/44100 to 88200 upsampling filter design using
% interp() and two lowpass filter design methods.
%
% ups.m focuses on the signal.  This function focuses on lowpass filter design.
%
% The following parameters can be changed in the code:
%   R     - upsample factor, selects the sound source sample rate
%   bSnd  - play sound flag, 1 or 0
%   yy,fs - source signal and sample rate (optional, see wavread() in code)
%
% See also: ups.m, upstest.m

% modification history
% --------------------
%                ----  v5.6.1  ----
% 05.19.05  JDM  created from ups.m
% 05.31.05  JDM  polished into general design script; added R = 4 taps output
%                for SLAB
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

y = [];
fs = 0;

% upsample factor (ignored for wave file sources)
% (slab3d sample rate = 44100, delay line 2x upsampled to 88200)
% R = 2, 44100 to 88200
% R = 4, 22050 to 88200
% R = 8, 11025 to 88200
R = 8;

% play sounds flag
bSnd = 1;

% ---- insert wavread() here for wave file source signals ----
% For use, see examples below.  If no file specified, noise used.

% 22050 Hz, 16 bit, stereo
%[y,fs,nbits]=wavread('C:\WINDOWS\Media\chimes.wav');
%yy=y(:,1);

%[yy,fs,nbits] = wavread('C:\test_sounds\delta11k16b.wav');

% if wave file used as source signal, set upsample factor
if fs > 0,
%  lyy = length(yy); % cropped to 743ms
  lyy = 0; % no crop
  switch fs,
    case 44100
      R = 2;
      if lyy > 32768,
        y = yy(1:32768);
      else,
        y = yy;
      end;
    case 22050
      R = 4;
      if lyy > 16384,
        y = yy(1:16384);
      else,
        y = yy;
      end;
    case 11025
      R = 8;
      if lyy > 8192,
        y = yy(1:8192);
      else,
        y = yy;
      end;
    otherwise
      disp( 'error - unsupported wave file sample rate.' );
      return;
  end;
else,
  % noise source signal if wave file not used;
  % 0.5 gain allows room for filter gain;
  % rand()*2.0 - 1.0 adjusts range: 0 to 1 -> -1 to 1
  switch R,
    case 2
      fs = 44100;
      y = 0.5 * (rand(32768,1)*2.0 - 1.0);
    case 4
      fs = 22050;
      y = 0.5 * (rand(16384,1)*2.0 - 1.0);
    case 8
      fs = 11025;
      y = 0.5 * (rand(8192,1)*2.0 - 1.0);
    otherwise
      disp( 'error - unsupported upsampling factor.' );
      return;
  end;
end;

% play original sound with slight pause
ly = length(y);
pt = ly/fs + .5; % pause time
if bSnd,
  sound(y,fs);
  pause(pt);
end;

%------------------------------------------------------------------------------
% Rx upsample using interp() filter
%
% Notes:
% * Works great for fs = 22050, R = 4, L = 4,5, alias band above 20k
% * Bad for fs = 11025, R = 8, L = 4,5,6 - fairly serious aliasing in band
%   ~14k to ~19k.
%------------------------------------------------------------------------------

% interp() IR length = 2*R*L+1
% (see NASA7 notebook, pgs.174-175 for MAC analysis)
switch R,
  case 2
    L = 8; % IRL = 33 (33 equivalent to 2x half-sample method MACs)
  case 4
    L = 5; % IRL = 41 (43.7 equivalent to 2x half-sample method MACs)
  case 8
    L = 4; % IRL = 65 (74.1 equivalent to 2x half-sample method MACs)
  otherwise
    disp( 'error - unsupported upsampling factor.' );
    return;
end;

% lb = length(b) = 2*R*L+1 (e.g., for R=2,L=4, 2*2*4+1 = 17)
% note: for R = 2, (lb-1)/2 zeros, 1 one, thus (lb-1)/2 multiplies
[yR,bR]=interp(y,R,L,.5);
if 0, % disabled because basically same as yRp
  sound(yR,R*fs);
  pause(pt);
end;

% should be equivalent to above (actually, some diffs at begin and end)
lz=floor(length(bR)/2); % FIR sinc max (time delay)
yiR=zeros(R*ly+lz,1);
yiR(1:R:R*(ly-1)+1)=y;
yRp=filter(bR,1,yiR);
% remove leading zeros
yRp=yRp(lz+1:end);
% play interp() FIR output
if bSnd,
  sound(yRp,R*fs);
  pause(pt);
end;

%------------------------------------------------------------------------------
% Rx upsample using lowpass filter design, 2 methods.
%
% Notes:
%
% See fdatool, FIR lowpass functions, and Sig Proc Toolbox book.
% 'Equiripple' = remez()
% 'Least-Squares' = firls()
% 'Window' = fir1()
%
% Post zero-insert lowpass filter cut-off frequency, fc, will be fs/2.
% Normalized fc = 1/R = (fs/2)/(R*fs/2).
%
% There will be significant aliasing in the transition band and a fair amount
% in the stop band, especially for large R (e.g., R = 8).  This can be heard
% as additional high-freq content in the upsampled signal.
%------------------------------------------------------------------------------

% ---- fir1()
% kaiserord() can be used to estimate design params:
% e.g., for 2x ups kept increasing stopband until n = 33
% [ passband stopband ], passband/stopband and p/s ripple
% [n,Wn,beta,typ] = kaiserord( [11025 17000], [1 0], [0.01 0.1], 88200 );
% yields [ 33, 0.3177, 3.3953, 'low' ]

% (n-1)-order FIR lowpass filter, window method, kaiser window
n = length(bR);  % filter length
Wn = fs/(R*fs);  % normalized freq (1.0 = sample_rate/2)
beta = 4;        % larger beta -> wider main lobe, decreased sidelobes
lpir1 = fir1( n-1, Wn, 'low', kaiser( n, beta ) ) .* R;

% filter and play lpir1
ylp=filter(lpir1,1,yiR);
% remove leading zeros
ylp=ylp(lz+1:end);
% play lowpass output
if bSnd,
  sound(ylp,R*fs);
  pause(pt);
end;

% ---- least-squares filter
% Doesn't appear to be better than Kaiser window method.
% Transition band hardcoded for R = 8.
% 0.5 = -6dB point
% lpir2 = firls( n-1, [0 1/R (1/R)+0.07 1], [1 0.5 0 0] ) .* R;
%
% Method: constrained least-squares
% Order: n-1
% Cutoff frequency: (fs/2)/(R*fs/2)
% Passband and stopband deviations: 0.01
lpir2 = fircls1( n-1, (fs/2)/(R*fs/2), 0.01, 0.01 ) .* R;

% ---- remez() (aka equiripple, Parks-McClellan)
% O&S, pg.484: this method should produce a lower-order filter than window
% method for similar specs. So, better filter than window method for same
% order?
% 11025-to-88200 fdatool design: 65, 88200, 5512.5, 8000, 1, 80
% Transition band hardcoded for fs = 11025
% Lower sidelobes for larger transition band.
%lpir2 = remez( n-1, [ 0 1/R 8000/44100 1 ], [ 1 0.5 0 0 ], [ .01 1 ] ) .* R;
%lpir2 = remez( n-1, [ 0 1/R 7700/44100 1 ], [ 1 0.5 0 0 ], [ .01 1 ] ) .* R;

% filter and play lpir2
ylp=filter(lpir2,1,yiR);
% remove leading zeros
ylp=ylp(lz+1:end);
% play lowpass output
if bSnd,
  sound(ylp,R*fs);
  pause(pt);
end;

%------------------------------------------------------------------------------
% plots
%------------------------------------------------------------------------------

% print design params
fprintf( '\nUpsample: %d Hz to %d Hz\n', fs, R*fs );
fprintf( 'Upsample factor: %d\n', R );
fprintf( 'Cutoff frequency, fc: %.1f Hz\n', fs/2 );
fprintf( 'Post zero-insert normalized fc: %.3f\n', 1/R );
fprintf( 'Source signal length: %d\n', ly );
fprintf( 'IR length: %d\n', n );

% filter taps
figure;
plot( 1:n, bR, 'ro-', 1:n, lpir1, 'co-', 1:n, lpir2, 'bo-' );
axis( [ 1 n -0.5 1.5 ] );
title( sprintf( 'Filter Taps, length = %d, %d Hz to %d Hz, R = %d', ...
                n, fs, R*fs, R ) );
legend( 'interp()', 'lpir1', 'lpir2', 2 ); % 2 = upper-left
grid;
fprintf( '\ninterp(), lpir1, lpir2:\n' );
[ bR lpir1' lpir2' ]

% freqz freq bins
freqzN = 8192;

% upsampled with interp() filter
[ HR fr ] = freqz( bR, 1, freqzN, R*fs );
HRmag = 20*log10(abs(HR));
HRphase = unwrap(angle(HR));

% upsampled with lowpass filter
[ Hlp flp ] = freqz( lpir1, 1, freqzN, R*fs );
HLP1mag = 20*log10(abs(Hlp));
HLP1phase = unwrap(angle(Hlp));

% upsampled with lpir2 lowpass filter
[ Hlp flp ] = freqz( lpir2, 1, freqzN, R*fs );
HLP2mag = 20*log10(abs(Hlp));
HLP2phase = unwrap(angle(Hlp));

% mag
figure;
subplot(2,1,1);
semilogx( fr, HRmag, 'r', fr, HLP1mag, 'c', fr, HLP2mag, 'b' );
title( sprintf( 'Filter Response, %d Hz to %d Hz, R = %d', fs, R*fs, R ) );
legend( 'interp()', 'lpir1', 'lpir2', 3 ); % 3 = lower-left
xlabel('Log Frequency (Hz)');
ylabel('Magnitude (dB)');
grid;
axis( [ 0 fr(end) min([HRmag; HLP1mag; HLP2mag]) ...
                  max([HRmag; HLP1mag; HLP2mag])+10 ] );

% phase
subplot(2,1,2);
plot( fr, HRphase, 'r', fr, HLP1phase, 'c', fr, HLP2phase, 'b' );
xlabel('Frequency (Hz)');
ylabel('Unwrapped Phase (radians)');
grid;
axis( [ 0 fr(end) min([HRphase; HLP1phase; HLP2phase]) ...
                  max([HRphase; HLP1phase; HLP2phase]) ] );

% R = 4 taps for slab3d dli.cpp Upsample4()
if 0,
format long
flipud(bR(2:4:end))
flipud(bR(3:4:end))
flipud(bR(4:4:end))
format short
end;

% R = 8 taps for slab3d dli.cpp Upsample8()
if 0,
format long
flipud(bR(2:8:end))
flipud(bR(3:8:end))
flipud(bR(4:8:end))
flipud(bR(5:8:end))
flipud(bR(6:8:end))
flipud(bR(7:8:end))
flipud(bR(8:8:end))
format short
end;
