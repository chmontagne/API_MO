% dmix - signal dynamics and mix analysis

% modification history
% --------------------
%                ----  v6.2.0  ----
% 03.20.08  JDM  created
%
% JDM == Joel D. Miller
%
% Limiter info:
% http://www2.hsu-hh.de/ant/dafx2002/DAFX_Book_Page/matlab.html
% ch5 - limiter.m, etc.

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

% one time wave file prep
if ~exist('s1'),
  [s1,fs,bits] = wavread( 'C:\SLABData\wavs\sqam_voice_fe.wav' );
  [ fs bits ]
  [s2,fs,bits] = wavread( 'C:\SLABData\wavs\sqam_voice_fg.wav' );
  [ fs bits ]
  [s3,fs,bits] = wavread( 'C:\SLABData\wavs\sqam_voice_me.wav' );
  [ fs bits ]
  [s4,fs,bits] = wavread( 'C:\SLABData\wavs\sqam_voice_mg.wav' );
  [ fs bits ]
  [a1,fs,bits] = wavread( 'C:\SLABData\wavs\alarm.wav' );
  [ fs bits ]

  % to determine start values used below
  if 0,
  figure;
  plot((1:size(s1,1))/fs,s1);
  grid on;
  figure;
  plot((1:size(s2,1))/fs,s2);
  grid on;
  figure;
  plot((1:size(s3,1))/fs,s3);
  grid on;
  figure;
  plot((1:size(s4,1))/fs,s4);
  grid on;
  end;

  secs = 4;   % extraction window, seconds
  start = 1;  % extraction start point, seconds
  s1 = s1((start*fs):((start+secs)*fs));
  s2 = s2((start*fs):((start+secs)*fs));
  s3 = s3((start*fs):((start+secs)*fs));
  % s4 male version of s2, avoid overlapping energy clusters
  start = 10;  % seconds
  s4 = s4((start*fs):((start+secs)*fs));
  % a1 alarm known to be ~1s
  start = 1;  % seconds
  a1 = [ zeros(start*fs,1); a1; zeros(secs*fs-start*fs-size(a1,1)+1,1) ];

  % 1.0-normalize
  s1 = s1/max(abs(s1));
  s2 = s2/max(abs(s2));
  s3 = s3/max(abs(s3));
  s4 = s4/max(abs(s4));
  a1 = a1/max(abs(a1));

  % time axis
  t = (0:(size(s1,1)-1))/fs;
end;

f = 1/1;  % sum factor
s = f * (s1 + s2 + s3 + s4 + a1);  % sum
figure;
plot( t, s1+8, 'b-', t, s2+6, 'b-', t, s3+4, 'b-', t, s4+2, 'b-', ...
      t, a1, 'b-', t, s-6, 'b-' );
grid on;
axis( [0 max(t) -9 +9 ] );
hold on;
% clip lines
plot( t, zeros(size(s,1),1)-5, 'r-' );
plot( t, zeros(size(s,1),1)-7, 'r-' );
title( f );
drawnow;
wavplay(s,fs);

% HRTF processing
if 0,
h = slab2sarc('/slab3d/hrtf/jdm.slh');
hL = conv( s1, h.ir(:,hil(-60,0,h.dgrid)) );
hR = conv( s1, h.ir(:,hir(-60,0,h.dgrid)) );
figure;
plot(hL);
hold on;
plot(hR,'r');
axis([1 size(hL,1) -1 1]);
grid on;
drawnow;
wavplay(s1,fs);
wavplay([hL hR],fs);
end;

% write test data to use with SLABScape v6.1.0 diotic display
%
% slab3d v6.1.0 wraps.
% slab3d v6.1.1 clips to +/- 1.0.
%
% audible artifacts with f=1 * sum (minor clipping):
%   matlab - minimal (clips to +/- 1.0)
%   slab3d v6.1.0 - much more noticeable (wraps)
%
% wavwrite note: a matlab 1 will clip, a -1 will not
if 0,
wavwrite(s,fs,'sum.wav');
% Warning: Data clipped during write to file:sum.wav
% > In wavwrite>PCM_Quantize at 241
%   In wavwrite>write_wavedat at 267
%   In wavwrite at 112
wavwrite(s1,fs,'s1.wav');
% Warning: Data clipped during write to file:s1.wav
% > In wavwrite>PCM_Quantize at 247
%   In wavwrite>write_wavedat at 267
%   In wavwrite at 112
wavwrite(s2,fs,'s2.wav');
wavwrite(s3,fs,'s3.wav');
wavwrite(s4,fs,'s4.wav');
wavwrite(a1,fs,'a1.wav');
% Warning: Data clipped during write to file:a1.wav
% > In wavwrite>PCM_Quantize at 247
%   In wavwrite>write_wavedat at 267
%   In wavwrite at 112
end;
