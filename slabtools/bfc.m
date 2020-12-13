% bfc - beamforming correlation - compute and visualize cross-correlation

% modification history
% --------------------
%                ----  v6.0.0  ----
% 03.06.07  JDM  created
% 03.14.07  JDM  added xcorr calculation
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

framesize = 32;
lag1 = 5;
lag2 = 12;

x  = rand(1,framesize);
x1 = [ zeros(1,lag1) x zeros(1,framesize-lag1) ];
x2 = [ zeros(1,lag2) x zeros(1,framesize-lag2) ];
xlen = framesize*2;

% see Ingle and Proakis, pgs.20-21
% [ xc lags ] = xcorr(x1,x2);
xf2 = conv(x1,fliplr(x2));   % same as xcorr xc
lags2 = -(xlen-1) : xlen-1;  % same as xcorr lags

% xcorr calculation
%
% xc[1] = x1[1] * x2[64]
% xc[2] = x1[1] * x2[63] + x1[2] * x2[64]
% xc[2] = x1[1] * x2[62] + x1[2] * x2[63] + x1[3] * x2[64]
% ...
% xc[125] = x1[62] * x2[1] + x1[63] * x2[2] + x1[64] * x2[3]
% xc[126] = x1[63] * x2[1] + x1[64] * x2[2]
% xc[127] = x1[64] * x2[1]
xc = zeros(1,xlen*2-1);
k = 2*xlen - 1;
for o = 1 : xlen,  % amount of overlap
  xc(o) = 0;
  xc(k) = 0;
  if o == k,
    for s = 1 : o,
      xc(o) = xc(o) + x1(s) * x2(xlen-o+s);
    end;
  else,
    for s = 1 : o,
      xc(o) = xc(o) + x1(s) * x2(xlen-o+s);
      xc(k) = xc(k) + x1(xlen-o+s) * x2(s);
    end;
  end;
  k = k - 1;
end;
% max(abs(xf2-xc))  % verify calc
% [m i] = max(xc)   % find lag
% lag = i - xlen

% conv( [1 2 3], [3 4 5] )
% ans = 3    10    22    22    15
%
% filter( [1 2 3], 1, [3 4 5] )
% ans = 3    10    22

% x3 = x2 shifted one half-sample to the right (by linear interpolation)
x3 = conv(x2,[.5 .5]);
x3 = x3(1:xlen);

xf3 = conv(x1,fliplr(x3));

[mx2 mi2] = max(xf2);
[mx3 mi3] = max(xf3);
% amount x2 and x3 lag x1
fprintf( 'Shifts:  true = %d,  whole = %d (%.1f),  half = %d (%.1f)\n', ...
         lag1-lag2, lags2(mi2), mx2, lags2(mi3), mx3 );

% depending on the random sequence, the half value can change by 1, e.g.,
%
% Shifts:  true = -7,  whole = -7 ( 8.6),  half = -8 (7.5)
% Shifts:  true = -7,  whole = -7 (11.2),  half = -7 (9.9)
%
% xf3(57)-xf3(56) = 1.7764e-015
% xf3(57)-xf3(56) = 0

% time
figure;
plot([x1' x2' x3'],'.-');
grid on;
legend('x1 reference','x2 whole-sample shift','x3 half-sample shift');
title( 'sample sequence and shifted versions' );

% xcorr
figure;
plot(1:127,xf2,'g.-',1:127,xf3,'r.--');
grid on;
legend('whole-sample shift','half-sample shift');
title( 'cross-correlations' );
