function [ leftinv, leftmp ] = ffeq( sig, fs )
% ffeq - creates a band-limited free-field eq inverse filter.
%
% The following artifacts may exist:
% 1) phase distortion due to neglecting the minphase all-pass component
% 2) low frequency errors due to small rceps() vectors
% 3) time-domain aliasing due to inverse filter
% 4) time-domain aliasing due to band-limiting
%
% 1: In constructing the inverse filter using minimum-phase decomposition,
%    the all-pass component is ignored (allowing phase distortion
%    in the inverse filter). The result of this can be seen when the inverse
%    filter is applied to the original system measurement and the minphase
%    version (see phase (ideal = flat) and impulse response (ideal =
%    impulse)).
%
% 2: When using rceps() to compute minimum-phase, small vectors can
%    yield artifacts in the low frequencies.  Zero-padding reduces these
%    artifacts. To see this, reduce the padding in the code.
%
% 3: Since the inverse filter impulse response is a decaying exponential,
%    the IR will time-domain alias when taking the IFFT.  A long inverse
%    filter can greatly reduce this artifact.
%
% 4: The algorithm used for band-limiting, ffbl(), introduces rect/sinc-like
%    time-domain aliasing.  A long inverse filter can greatly reduce this
%    artifact.

% modification history
% --------------------
%                ----  v5.5.0  ----
% 09.27.04  JDM  created
% 10.06.04  JDM  clean-up
% 10.13.04  JDM  added bandlimit() (based on alg by Agnieszka Roginska)
%                ----  v5.6.0  ----
% 11.17.04  JDM  bandlimit() moved to ffbl.m; separated-out ffeqtest();
%                integrated some notes from ffeq4.m (original analysis func)
% 11.19.04  JDM  more ffeq4.m notes
% 11.22.04  JDM  added nextpow2()
% 02.28.05  JDM  clean-up
%                ----  v5.8.0  ----
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

% References:
%
% Mikio Tohyama and Tsunehiko Koike, "Fundamentals of Acoustic Signal
% Processing" (ch4.5,4.6 minphase, inv filter, ch8,9 inv filters)
%
% Julius Smith,
% http://ccrma.stanford.edu/~jos/filters/Minimum_Phase_Filters_Signals.html
% (time-domain aliasing, magnitude clipping)
%
% Julius Smith, Music 320 Reader (aliasing, spectrum analysis)
%
% William Gardner, "3-D Audio Using Loudspeakers", Appendix A (inv filter)

% MINPHASE IMPLEMENTATION
%
% rceps() minphase:
% n = length(x); % x power of 2
% xhat = real(ifft(log(abs(fft(x)))));
% wn = [1; 2*ones(n/2-1,1); 1; zeros(n/2-1,1)];
% mp = real(ifft(exp(fft(wn.*xhat))));
%
% JOS minphase (from web):
% sm = exp(fft(fold(ifft(log(clibdb(s,-100))))));
% % eliminate clibdb() and extend freq-to-freq to time-to-time
% mp = real(ifft(exp(fft(fold(ifft(log(abs(fft(x)))))))));
%
% exp/fft/wn/real/ifft = exp/fft/fold/ifft

L = length( sig );

% convert to minimum phase using cepstrum
% !!!! padN required! otherwise, low-f artifacts
bPad = 1; % flag, pad rceps() to length 8192
if bPad,
  padN = 8192-L;
else,
  padN = 0;
end;
[ dummy leftmp ] = rceps( [ sig; zeros(padN,1) ] );
leftmp = leftmp(1:L);

% plot speaker-mic response and minphase impulse response
figure;
plot( 1:L, sig, 'r.-', 1:L, leftmp, 'b.-' );
grid;
title('speaker-mic impulse response, left mic, r=original, b=minphase');

% freq domain
% !!!! 4*L decreases time-domain-aliasing (inverse imp resp infinite)
% (see Gardner)
%fftlen = L; % demonstrates time-domain-aliasing
fftlen = 4*(2^nextpow2(L));
preinv = fft(leftmp,fftlen);

% If a shorter filter length is desired, one can also eliminate peaks and
% valleys before inverting.
% JOS: time-domain aliasing is worse if filter isn't smooth.
% JOS example clips at 100dB below max.

fprintf( 'input (mp) length prior to FFT = %d\n', L );
fprintf( 'FFT length just prior to reciprocal inverse = %d\n', fftlen );

% inverse filter = freq reciprocal
invresp = 1./preinv;
LI = size( invresp, 1 ); % LI = length of inverse

% band-limit inverse filter
% !!!! this introduces serious rect/sinc-like time-aliasing in the IR.
% Cleaned-up by rceps() window below...
% (JDM, 10/3/06, normalization warning - see ffbl())
invresp = ffbl( invresp, fs, 400, 17000 );

% plot freq domain, real and imag, pre-inverse and post-inverse
figure;
plot( 1:LI, real(preinv),  'r.-', 1:LI, imag(preinv),  'b.-', ...
      1:LI, real(invresp), 'g.-', 1:LI, imag(invresp), 'c.-' );
grid;
title('freq domain, r/b=pre-inv/BL, g/c=post-inv/BL, r/g=real, b/c=imag');

% time domain inverse filter
leftinvc = ifft( invresp ); % complex
leftinv = real( leftinvc ); % real

% !!!! If band-limiting the frequency response, do not zero-pad this rceps()!
% The rceps() window eliminates time-aliasing introduced by the band-limit
% window.  See ffbltest() for a closer analysis of ffbl().  The fact that this
% rceps() can't be zero-padded argues for a long fft and, hence, long
% inverse filter.

figure;
plot( 1:LI, leftinv, 'r.-', 1:LI, imag(leftinvc), 'b.-' );
hold on;
%[ dummy leftinv ] = rceps( [ leftinv; zeros(4096-LI,1) ] );

[ dummy leftinv ] = rceps( leftinv );

plot( leftinv, 'g.-' );
grid;
%leftinv = leftinv(1:LI);
title( 'inv/BL, time domain, non-mp(r=real,b=imag), g=mp(real)' );
