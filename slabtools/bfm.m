% bfm - MATLAB/Windows multichannel wave file test script

% modification history
% --------------------
%                ----  v6.0.0  ----
% 11.09.06  JDM  created
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

% ----  MATLAB multi-ch wave write and read  ----

if 0,
% 1 second of four harmonics, fundamental = 20Hz
amp = 0.5;
y1 = amp * sin(20*2*pi*(1:44100)/44100);
y2 = amp * sin(40*2*pi*(1:44100)/44100);
y3 = amp * sin(60*2*pi*(1:44100)/44100);
y4 = amp * sin(80*2*pi*(1:44100)/44100);

wavwrite( [ y1' y2' y3' y4' ], 44100, 16, 'mch4ch.wav' );

[y,fs,nbits,opts] = wavread( 'mch4ch.wav' );

figure;
plot(y(1:fs/20,:));  % plot first 1/20 th second of file
grid on;
end;

% ----  multi-ch wave display  ----

% 4ch test waveform (waveforms can be generated with SLABForm.exe)
[y,fs,nbits,opts] = wavread( 'mch4ch.wav' );

% plot 4ch test waveform
figure;
plot( y(:,4) + 7 )
hold on
plot( y(:,3) + 5 )
plot( y(:,2) + 3 )
plot( y(:,1) + 1 )
grid on
