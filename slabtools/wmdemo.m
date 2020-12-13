% wmdemo.m - demo of wave_matlab code (audio freq)
%
% Execute in wave_matlab directory or have that directory in the matlab path.
%
% Reference:
% http://paos.colorado.edu/research/wavelets
%
% See also: morlet.m, cwt.m

% modification history
% --------------------
%                ----  v6.3.0  ----
% 12.16.08  JDM  created, based on wavetest.m
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

% audio test signal
fs = 4096;  % sample rate, samples/s
len = fs;
x = zeros(len,1);
x(500:1000)  = sin(2*pi*200*(500:1000)/fs);
x(1500:2000) = sin(2*pi*400*(1500:2000)/fs);
%figure;
%plot(x);
%wavplay(x,fs);
%freqz(x,1,4096,4096)

dt = 1/fs;              % sample period, seconds
time = [0:len-1]*dt;    % time array
xlim = [0,(len-1)/fs];  % plotting range
pad = 1;      % pad the time series with zeroes (recommended)
dj = 0.25;    % 4 sub-octaves per octave
s0 = 2*dt;    % scale starts at Nyquist period (highest valid freq)
j1 = 7/dj;    % 7 powers-of-two with dj sub-octaves each
mother = 'Morlet';

% Wavelet transform
[wave,period,scale,coi] = wavelet(x,dt,pad,dj,s0,j1,mother);
power = 10*log10( abs(wave).^2 );  % wavelet power spectrum, dB

freq = 1./period;  % Hz
Yticks = 2.^(fix(log2(min(freq))):fix(log2(max(freq))));

% ----  plot wavelet power spectrum  ----

dBmin = -40;
dBmax = 10;

% ---- contourf()
figure;
levels = dBmin:5:dBmax;
contourf( time, log2(freq), power, levels );
title('Wavelet Power Spectrum')
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
set(gca,'XLim',xlim);
set( gca, 'YLim', log2([min(freq),max(freq)]), ...
  'YTick', log2(Yticks), 'YTickLabel', Yticks );colorbar;
% cone-of-influence, anything "below" is dubious
hold on;
plot( time, log2(1./coi), 'k' );
% shows the values are under the max value but the max color is not used
% caxis([dBmin dBmax]);

% ---- imagesc()
figure;
imagesc( time, log2(freq), power, [dBmin dBmax] );
title('Wavelet Power Spectrum')
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
set(gca,'XLim',xlim);
set( gca, 'YLim', log2([min(freq),max(freq)]), 'YDir', 'normal', ...
  'YTick', log2(Yticks), 'YTickLabel', Yticks );colorbar;
% cone-of-influence, anything "below" is dubious
hold on;
plot( time, log2(1./coi), 'k' );

% ---- mesh() (or surf())

% limit floor of 3D plots
powFloor = -40;  % dB
powCeil = 10;
for r=1:size(power,1),
  for c=1:size(power,2),
    if( power(r,c) < powFloor ),
      power(r,c) = powFloor;
    end;
  end;
end;

figure;
minc = 32;
% surf() with "shading interp" for smooth surface
mesh( time(1:minc:end), log2(freq), power(:,1:minc:end) );
title('Wavelet Power Spectrum')
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
zlabel('dB');
set( gca, 'YLim', log2([min(freq),max(freq)]), ...
  'YTick', log2(Yticks), 'YTickLabel', Yticks );
