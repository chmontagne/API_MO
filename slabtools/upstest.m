% upstest - slab3d interp delay line and source upsample test script.
%
% Impulse repsonse measurements were obtained using the SLABScape settings
% below.  The fractional delay line was indexed at different delay
% offsets to verify the C code implementation was functioning properly.
% The delay offsets were obtained by using a series of increasing
% source-listener distances (hence increasing propagation delays).
%
% SLABScape Settings:
%
% Render Plugin: Spatial
% Sound Output Type: File
% Smooth Time: 0
% Listener HRTF: slabimp.slh
% Source Files: ImpDelay_11.wav, ImpDelay_22.wav, ImpDelay_44.wav
% Source File One-Shot: checked
% Source Spread: 0
% Source X Locations (Y=0,Z=0) in meters: 0.00, 0.01, 0.02, 0.03, 0.04, 0.05
%
% Relevant slab3d code:
%   spatial.cpp:  CSpatial::DelayLine()
%   ssi.h:        CSSI::operator[]( float fSubscript )
%
% See also: upslp.m, ups.m
function upstest

% modification history
% --------------------
%                ----  v5.6.1  ----
% 06.01.05  JDM  created
% 06.13.05  JDM  added energy analysis and plots() function
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

% propagation delays in samples (.0x = distance in meters, 44100 = render
% sampling rate in samples/s, 346 = speed of sound in m/s)
fprintf( [ '\nPropagation Delays:\n\n' ...
           '  fs = 44100 samples/s\n' ...
           '  speed of sound = 346 m/s\n\n' ] );
j = 0;
for i=0.00:0.01:0.05,
  fprintf( '  index: %d  distance: %4.2f m  delay: %3.1f samples\n', j, i, ...
           i*44100/346 );
  j = j + 1;
end;
fprintf( [ '\n' ...
  'Total energy of impulse responses follows.  The first row is computed\n' ...
  'in the frequency domain, the second in the time domain.\n' ...
  'According to Parseval''s Theorem these two calculations should produce\n' ...
  'identical values.\n\n' ] );

% plot time window
win = 42;

if 0,
% Source fs = 22050.
% This test includes spatial's linear delay line interp for the first
% frame.  For the delay line, a time constant of 0 means the target is
% immediately set to the target, but we still linearly interp to the target
% when incrementing through the frame.  Since the scene is static, this
% frame interp will only occur during the first frame of processing.
y = zeros(win,7);
[yy,fs,nbits]=wavread('C:\slab3d\wavs\ImpFull1024_22.wav');
y(:,1) = yy(1:1+win-1,1);
i1 = 1;
i2 = 1+win-1;
for i=2:7,
  [yy,fs,nbits]=wavread( sprintf( 'slaboutu%d.wav', i-2 ) );
  y(:,i) = yy(i1:i2,1);
end;
figure;
plot( y, '.-' );
title('Source 22050 kHz, impulse in transient region');
xlabel( 'Samples (render fs = 44100 samples/s)' );
ylabel( 'Amplitude' );
grid;
axis( [ 0 win+1 -0.2 1.2 ] );
legend( 's', '0', '1', '2', '3', '4', '5', 1 );
end;

% For fs = 11025 and 22050, the impulse responses show the
% expected 2x downsampled lowpass FIR (the FIR is applied
% to the zero-stuffed 88200 delay line which is fractionally indexed at
% 44100, hence 2x downsampling for the lowpass FIR).

% R values below relative to 44100, not 88200.  The square root of the max
% EDS value is R as expected (see O&S resample discussion).

% source fs = 11025
plots( 4, 11025, win );

% source fs = 22050
plots( 2, 22050, win );

% source fs = 44100
plots( 1, 44100, win );

%------------------------------------------------------------------------------
% plots() - impluse response and energy density spectrum plots.

function plots( R, fs, win )

fst = sprintf('%d',fs);
y = zeros(win,7);
% impulse at sample index 128
[yy,fs,nbits]=wavread(sprintf('C:\\slab3d\\wavs\\ImpDelay_%s.wav',fst(1:2)));
y(:,1) = yy(128:128+win-1,1);
i1 = 128*R;
i2 = 128*R+win-1;
for i=2:7,
  [yy,fs,nbits]=wavread( sprintf( 'slaboutd%c%d.wav', fst(1), i-2 ) );
  y(:,i) = yy(i1:i2,1);
end;
figure;
plot( y, '.-' );
title(sprintf('Source %s kHz, delayed impulse',fst));
xlabel( 'Samples (render fs = 44100 samples/s)' );
ylabel( 'Amplitude' );
grid;
axis( [ 0 win+1 -0.2 1.2 ] );
legend( 's', '0', '1', '2', '3', '4', '5', 1 );

% energy
fftn = 2^nextpow2(win);
binw = 44100/fftn; % bin width
eds = fftshift(abs(fft(y,fftn)).^2,1);
sum(eds)/2^nextpow2(win)
% see Parseval's Theorem (O&S, pg.58), above and below should be equal
sum(y.*y)
figure;
% energy density spectrum plot
plot(-44100/2:binw:44100/2-binw,eds,'.-');
grid;
maxeds = max(max(eds));
axis( [ -44100/2 44100/2 0 maxeds+0.1 ] );
title(sprintf('Energy Density Spectrum (source fs %s Hz)',fst));
xlabel( 'Frequency (Hz)' );
ylabel( 'Energy' );
legend( 's', '0', '1', '2', '3', '4', '5', 0 );
% 88.2 kHz delay line is fractionally indexed at 44.1 kHz.  The worst case
% (in magnitude) lowpass occurs when index lies between two 88.2 delay line
% samples (fractional index 0.25).
% worst-case linear interp moving average lowpass filter
% (for phase effects see "freqz([.5 .5]),hold on,pause,freqz([.6 .4])")
lp88 = fftshift(abs(fft([.5 .5],fftn*2)).^2);
lp88 = maxeds .* lp88(fftn/2+1:3*fftn/2); % scale to show envelope effect
hold on;
plot(-44100/2:binw:44100/2-binw,lp88,'o');
hold off;
