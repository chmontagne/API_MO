function peak( x, ta, tr, fp, fs )
% peak - illustrates peak detection.
%
% peak( x, ta, tr, fp, fs )
%
% x  = input waveform
% ta = attack time constant (in seconds)
% tr = release time constant (in seconds)
% fp = frequency of value poll (in Hz)
% fs = sample rate (in samples/second)
% 
% Defaults:  peak( x, 0.01, 1.5, 15, 44100 )
%
% References:  DAFX pgs.83-85, musicdsp.org Analysis

% modification history
% --------------------
%                ----  v5.4.1  ----
% 04.07.04  JDM  created
%                ----  v6.0.2  ----
% 01.09.08  CJM  fixed minor time axis errors
%
% JDM == Joel D. Miller
% CJM == Joel D. Miller, Copyright Joel D. Miller (see below)

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

% CJM modifications:
%
% Copyright (C) 2006-2018 Joel D. Miller.  All Rights Reserved.
%
% This software constitutes a "Modification" to the SLAB software system and is
% distributed under the NASA Open Source Agreement (NOSA), version 1.3.
% The NOSA has been approved by the Open Source Initiative.  See the file
% NOSA.txt at the top of the distribution directory tree for the complete NOSA
% document.

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% defaults

if( nargin < 5 ),
  fs = 44100;
end;

if( nargin < 4 ),
  fp = 15;
end;

if( nargin < 3 ),
  tr = 1.5;
end;

if( nargin < 2 ),
  ta = 0.01;
end;

% example waveform
% [x,fs,bits] = wavread( 'C:\SLABData\wavs\sqam_voice_me.wav' );
% len = length( x ); x1 = [ zeros(10000,1); x( (len-200000):len ) ];

ga = exp( -1.0 / (fs * ta) );
gr = exp( -1.0 / (fs * tr) );

fprintf( '\nga = %f\ngr = %f\n\n', ga, gr );

len = length( x );
env = zeros( len+1, 1 );
pkf = zeros( len+1, 1 );
for i = 2:(len+1),
  in = abs( x(i-1) );

  % envelope
  if( in > env(i-1) ),
    % attack
    env(i) = (1-ga) * in + ga * env(i-1);
  else,
    % release
    env(i) = (1-gr) * in + gr * env(i-1);
  end;

  % peak follower
  if( in >= pkf(i-1) ),
    pkf(i) = in;
  else,
    pkf(i) = gr * pkf(i-1);
  end;

end;

% waveform, envelope, peak
t = (0:len-1)/fs;
figure( gcf );
plot( t, x, 'b', t, env(2:(len+1)), 'g', t, pkf(2:(len+1)), 'r' );

% envelope/peak value poll
tp = t(1):1/fp:t(len);      % seconds
np = round( tp*fs );        % samples, 0 base index
hold on;
plot( np/fs, env(2+np), 'go', np/fs, pkf(2+np), 'ro' );
hold off;

title( sprintf( 'Peak Detection (ta=%5.3fs, tr=%5.3fs)', ta, tr ) );
ylabel( 'Normalized Amplitude' );
xlabel( 'Time (seconds)' );
