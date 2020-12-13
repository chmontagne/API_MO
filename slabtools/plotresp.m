function [ax1,ax2] = plotresp( x, N, fs, fmt, xmin, xmax, ymin, ymax, ...
                               blog, nophase, unwrp, pmin, pmax )
% plotresp - plot mag and phase response.
%
% [ax1,ax2] = plotresp( x, N, fs, fmt, xmin, xmax, ymin, ymax, blog,
%                       nophase, unwrap, pmin, pmax )
%
% ax1 - mag axis handle
% ax2 - phase axis handle
%
% x       - signal
% N       - FFT length
% fs      - sample rate, Hz
% fmt     - line format string
% xmin    - freq axis min, default = 20 Hz
% xmax    - freq axis max, default = fs/2 Hz
% ymin    - mag axis min, default = -100 dB
% ymax    - mag axis max, default =  100 dB
% blog    - log axis flag, default = 0
% nophase - no phase plot flag, default = 0
% unwrap  - unwrap phase plot flag, default = 0
% pmin    - phase freq axis min, default = -pi
% pmax    - phase freq axis max, default = pi

% modification history
% --------------------
%                ----  v5.8.0  ----
% 01.19.06  JDM  created
% 02.27.06  JDM  added xmax,ymin,ymax,blog
%                ----  v6.0.0  ----
% 09.14.06  JDM  added ax1,ax2 return values
% 09.20.06  JDM  added nophase param
%                ----  v6.6.1  ----
% 04.27.12  JDM  added unwrap, pmin, pmax params
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

if nargin <  5, xmin =   20; end;  % Hz
if nargin <  6, xmax = fs/2; end;  % Hz
if nargin <  7, ymin = -100; end;  % dB
if nargin <  8, ymax =  100; end;  % dB
if nargin <  9, blog    = 0; end;
if nargin < 10, nophase = 0; end;
if nargin < 11, unwrp   = 0; end;
if nargin < 12, pmin    = -pi; end;
if nargin < 13, pmax    = pi; end;

bh = ishold;

H = fft(x,N);
Hmag = abs(H);
if unwrp,
  Hphase = unwrap(angle(H));
else
  Hphase = angle(H);
end;
len = (N/2)+1;

% mag
if nophase,
  ax1 = gca;
else
  ax1 = subplot(2,1,1);
end;
if bh,
  hold on;
else
  hold off;
end;
plot( (1:len)*fs/(2*len), 20*log10( Hmag(1:len) + eps ), fmt );
if blog,
  set(gca,'XScale','log');
end;
axis( [ xmin xmax ymin ymax ] );
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Frequency Response');

% phase
if nophase,
  ax2 = 0;
else
  ax2 = subplot(2,1,2);
  if bh,
    hold on;
  else
    hold off;
  end;
  plot( (1:len)*fs/(2*len), Hphase(1:len), fmt );
  if blog,
    set(gca,'XScale','log');
  end;
  axis( [ xmin xmax pmin pmax ] );
  grid on;
  xlabel('Frequency (Hz)');
  ylabel('Phase (radians)');
end;
