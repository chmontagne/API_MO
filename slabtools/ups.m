% ups - upsampling signal analysis.
%
% Demonstrate 11025/22050/44100 to 88200 upsampling by displaying the interpolated
% waveform and spectrum.  Upsampling techniques include slab3d's legacy half-sample
% method (44.1k to 88.2k) and two zero-stuff lowpass methods (interp(), Kaiser
% window).
%
% upslp.m focuses on lowpass filter design.  This function focuses on the signal.
%
% The following parameters can be changed in the code:
%   R     - upsample factor, selects the sound source sample rate
%   bSnd  - play sound flag, 1 or 0
%   yy,fs - source signal and sample rate (optional, see wavread() in code)
%
% See also: upslp.m, upstest.m

% modification history
% --------------------
%                ----  v5.6.1  ----
% 05.11.05  JDM  created
% 05.12.05  JDM  added lowpass
% 05.16.05  JDM  improved display and comparisons
% 05.18.05  JDM  test wave file support
% 06.06.05  JDM  clean-up
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
R = 2;

% play sounds flag
bSnd = 1;

% ---- insert wavread() here for wave file source signals ----
% For use, see examples below.  If no file specified, noise used.

% 22050 Hz, 16 bit, stereo
%[y,fs,nbits]=wavread('C:\WINDOWS\Media\chimes.wav');
%y=y(:,1);

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

fprintf( 'Upsample factor = %d\nSource signal length = %d\n', R, ly );

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
    L = 8; % IRL = 33 (33 equivalent to half-sample MACs)
  case 4
    L = 5; % IRL = 41 (43.7 equivalent to half-sample MACs)
  case 8
    L = 4; % IRL = 65 (74.1 equivalent to half-sample MACs)
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
% Rx upsample using lowpass filter design
%------------------------------------------------------------------------------

% (n-1)-order FIR lowpass filter, window method, kaiser window
n = length(bR);  % filter length
Wn = fs/(R*fs);  % normalized freq (1.0 = sample_rate/2)
beta = 4;        % larger beta -> wider main lobe, decreased sidelobes
blp = fir1( n-1, Wn, 'low', kaiser( n, beta ) ) .* R;

ylp=filter(blp,1,yiR);
% remove leading zeros
ylp=ylp(lz+1:end);
% play lowpass output
if bSnd,
  sound(ylp,R*fs);
  pause(pt);
end;

%------------------------------------------------------------------------------
% 2x upsample using half-sample calc and interleave
%
% This is the legacy filter applied to upsample 44100 input to 88200.
%------------------------------------------------------------------------------

% compute half sample signal
if R == 2,

% JA's filter taps sent via email 7/15/99.
% JA email 6/1/05: "It seems to be something like the following.
% order = 16; h = kaiser(order,4.5) .* sinc([1:order]'-(order+1)/2);"

h = [ ...
  -0.00377043454538 ...
   0.00771406763337 ...
  -0.01646169629546 ...
   0.03184927034863 ...
  -0.05727227443133 ...
   0.10129413898138 ...
  -0.19575549164107 ...
   0.63099283597631 ...
   0.63099283597631 ...
  -0.19575549164107 ...
   0.10129413898138 ...
  -0.05727227443133 ...
   0.03184927034863 ...
  -0.01646169629546 ...
   0.00771406763337 ...
  -0.00377043454538 ];

% form upsampled signal
even = filter( h, [1], [ y; zeros(8,1) ] );
even = even(9:end);
y2 = zeros(2*ly,1);
y2(1:2:2*ly-1) = y;
y2(2:2:2*ly) = even;

% play half-sample output
if bSnd,
  sound(y2,2*fs);
  pause(pt);
end;

end;

%------------------------------------------------------------------------------
% plots
%------------------------------------------------------------------------------

figure(gcf);
bn = 100;  % show bn samples at beginning
en = 100;  % show en samples at end
% beginning of data
subplot(1,2,1);
plot( 1:bn, yR(1:bn),  'k.-', ...
      1:bn, yRp(1:bn), 'r.:', ...
      1:bn, ylp(1:bn), 'c.-', ...
      1:bn, yiR(1:bn), 'bo' );
title( [ 'beginning, b=source, k=interp(), r=interp() FIR, c=lowpass, ' ...
         '(g=half-sample)' ] );
axis( [ 1 bn -1 1 ] );
grid;
% half sample method
if R == 2,
  hold on;
  plot( 1:bn, y2(1:bn), 'g.-' );
  hold off;
end;
% end of data
subplot(1,2,2);
plot( 1:en+1, yR(end-en:end),        'k.-', ...
      1:en+1, yRp(end-en:end),       'r.:', ...
      1:en+1, ylp(end-en:end),       'c.-', ...
      1:en+1, yiR(end-en-lz:end-lz), 'bo' );
title( [ 'end, b=source, k=interp(), r=interp() FIR, c=lowpass, ' ...
         '(g=half-sample)' ] );
axis( [ 1 en+1 -1 1 ] );
grid;
% half sample method
if R == 2,
  hold on;
  plot(1:en+1,y2(end-en:end),'g.-');
  hold off;
end;

fprintf( 'IR length = %d\n', n );

% original signal
FN = 2^nextpow2(ly);
fprintf( 'Source signal analysis window = %d\n', FN );
H = fft( y, FN );
Hmag = 20*log10(abs(H(1:FN/2+1)));
Hphase = unwrap(angle(H(1:FN/2+1)));

FNR = 2^nextpow2(R*ly);
fprintf( 'Upsampled signal analysis window = %d\n', FNR );

% upsampled with interp() filter
HR = fft( yRp, FNR );
HRmag = 20*log10(abs(HR(1:FNR/2+1)));
HRphase = unwrap(angle(HR(1:FNR/2+1)));

% upsampled with lowpass filter
HLP = fft( ylp, FNR );
HLPmag = 20*log10(abs(HLP(1:FNR/2+1)));
HLPphase = unwrap(angle(HLP(1:FNR/2+1)));

if R == 2,
  FN2 = 2^nextpow2(2*ly);
  H2 = fft( y2, FN2 );
  H2mag = 20*log10(abs(H2(1:FN2/2+1)));
  H2phase = unwrap(angle(H2(1:FN2/2+1)));
end;

figure;

% mag
subplot(2,1,1);
semilogx( 0:fs/FN:fs/2,      Hmag,   'b', ...
          0:R*fs/FNR:R*fs/2, HRmag,  'r', ...
          0:R*fs/FNR:R*fs/2, HLPmag, 'c' );
title('response, b=source, r=interp() FIR, c=lowpass, (g=half-sample)');
xlabel('log frequency (Hz)');
ylabel('mag (dB)');
grid;
if R == 2,
  hold on;
  semilogx( 0:2*fs/FN2:2*fs/2, H2mag, 'g' );
  hold off;
  axis( [ 0 R*fs/2 min([Hmag; HRmag; H2mag]) max([Hmag; HRmag; H2mag]) ] );
else,
  axis( [ 0 R*fs/2 min([Hmag; HRmag]) max([Hmag; HRmag]) ] );
end;

% phase
subplot(2,1,2);
plot( 0:fs/FN:fs/2,      Hphase,   'b', ...
      0:R*fs/FNR:R*fs/2, HRphase,  'r', ...
      0:R*fs/FNR:R*fs/2, HLPphase, 'c' );
xlabel('frequency (Hz)');
ylabel('unwrapped phase (radians)');
grid;
if R == 2,
  hold on;
  plot( 0:2*fs/FN2:2*fs/2, H2phase, 'g' );
  hold off;
  axis( [ 0 R*fs/2 ...
          min([Hphase; HRphase; H2phase]) max([Hphase; HRphase; H2phase]) ] );
else,
  axis( [ 0 R*fs/2 min([Hphase; HRphase]) max([Hphase; HRphase]) ] );
end;

% interp(), lowpass, and half-sample filter taps
figure;
if R == 2,
  % format half-sample IR like zero-stuff/lowpass IR
  hh = zeros( length(h)*2+1, 1 );
  hh(2:2:length(h)*2) = h;
  hh(length(h)+1) = 1.0;
  plot( 1:n, bR, 'ro-', 1:n, blp, 'co-', 1:n, hh, 'go-' );
  axis( [ 1 n -0.5 1.0 ] );
  fprintf( '\ninterp() FIR taps, lowpass taps, half-sample taps:\n' );
  [ bR blp' hh ]
else,
  plot( 1:n, bR, 'ro-', 1:n, blp, 'co-' );
  axis( [ 1 n -0.5 1.1 ] );
  fprintf( '\ninterp() FIR taps, lowpass taps:\n' );
  [ bR blp' ]
end;
title('filter taps, r=interp() FIR, c=lowpass, (g=half-sample)');
grid;
