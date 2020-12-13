function ffbltest()
% ffbltest - tests ffbl(), the free-field eq band-limit function.

% modification history
% --------------------
%                ----  v5.6.0  ----
% 11.05.04  JDM  created from ffeq1()
% 11.17.04  JDM  bandlimit() replaced by ffbl(); renamed, ffeq2 -> ffbltest;
%                added analysis code from ffbl.m
%                ----  v5.8.0  ----
% 09.15.05  JDM  updated alias/rcepswindow comments
% 09.28.05  JDM  added to SUR
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

% investigate band-limiting with ffbl()

NF = 256;       % length of filter
LI = NF;        % length of inverse filter
fs = 44100;

in = 0.5*ones(NF,1);

% plot discarded phase of input (input has real and imag components, but
% we operate only on the abs(), ignoring angle(), resulting in real output)
figure;
plot(angle(in(1:NF/2+1)),'r.-');
title('band-limit, discarded phase');
grid;

% plot mag of input
figure;
plot(abs(in),'r.-');
hold on;
title('band-limit, r=mag in, b=freq win, g=out');
grid;

% band-limit frequency domain data
[ invresp, win ] = ffbl( in, fs, 400, 17000 );

% plot freq win and output (plot held above)
plot(win,'b.-');
plot(invresp,'g.-');

% time domain inverse filter
leftinvc = ifft( invresp ); % complex
leftinv = real( leftinvc ); % real

% The xhat signal in rceps() will contain a time-aliased signal with negative
% time wrapping in from the right (i.e., similar to the input).
% The rceps() wn window will zero-out the negative time aliased portion.

% above behavior similar to a time-aliased sinc
% plot(ifft([0,0,1,1,1,1,1,0,0,0,1,1,1,1,1,0]),'o-');

n = length(leftinv);
xhat = real(ifft(log(abs(fft(leftinv)))));
wn = [1; 2*ones(n/2-1,1); 1; zeros(n/2-1,1)];
mp = real(ifft(exp(fft(wn.*xhat))));
figure;
plot(xhat,'r.-');
hold on;
plot(wn,'b.-');
plot(mp,'g.-');
title('rceps');

% plot
figure;
plot( 1:LI, leftinv, 'r.-', 1:LI, imag(leftinvc), 'b.-' );
grid;
title( 'impulse resp ( r=real, b=imag )');

% WHEN AND WHY NOT TO ZERO PAD WHEN CALLING RCEPS
%
% Bandlimiting with ffbl() introduces rect/sinc-like time-domain aliasing.
% The window used in rceps can reduce the effects of this aliasing by
% zeroing-out the aliased portion.  Zero padding moves some or all of the
% aliased response into the non-zero portion of the rceps window.
%
% If no zero padding is used in the mp rceps(), the end filt/invfilt response
% will be flatter than if no mp done.  So, we do want mp at this stage.
%
% If zero padding is used, the end response is similar to no mp!
% E.g., if 512 resp pts and 1536 zeros, the same filter is basically returned
% after truncating back down to 512 pts.  Before truncation, data exists after
% 512; it looks like a smaller version of 1:512.

%[ dummy leftinv ] = rceps( [ leftinv; zeros(512-LI,1) ] );
figure;
plot(leftinv,'r.-');
hold on;
%[ dummy leftinv ] = rceps( [ leftinv; zeros(4096-LI,1) ] );
[ dummy leftinv ] = rceps( leftinv );
plot(leftinv,'g.-');
title('impulse resp ( r=non-mp, g=mp )');
grid;

% plot frequency responses
[h1,w1] = freqz( leftinvc, [1], NF, fs ); % win inv
[h3,w3] = freqz( leftinv,  [1], NF, fs ); % mp win inv
figure;
subplot(2,1,1);
semilogx( w1, 20*log10(abs(h1)), 'r.-', ...
          w3, 20*log10(abs(h3)), 'g.-' );
title( 'mag, r=win inv, g=mp win inv' );
grid;
axis( [ 20 20000 -10 5 ] );
subplot(2,1,2);
plot( w1, angle(h1), 'r.-', ...
      w3, angle(h3), 'g.-' );
title( 'phase' );
grid;
axis( [ 20 20000 -pi pi ] );
