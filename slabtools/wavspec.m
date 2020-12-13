function wavspec( play )
% wavspec - displays the impulse response and spectrum of wave file data.
%
% wavspec without an argument will display impulse response plots and spectrum
% plots and write the plots to the files:
%   \imimp.tif and \imspec.tif
%
% See the variables fontSize, dimLength, and dimWidth to modify the font size
% and TIFF dimensions.
%
% wavespec(1) does the above and plays the file:
%   \SLABData\wavs\sqam_voice_me.wav
% followed by the file filtered with each impulse response.
%
% Impulse responses are read from the following wave files:
%    slabout1.wav, slabout2.wav, slabout3.wav, slabout4.wav
%
% The default .wav's demonstrate slab3d reflection processing.
%
% Acoustic Scene Parameters:
%
% Src = ImpulseFull1024.wav, one-shot, auto-stop
% Gain = 20.0 dB
% Relative src location = 60 az, 0 el, 0.25m range
% Radius = 10cm
% Spread = 1 (normal)
% Smooth Time = 0ms
% Room = depth 4.0m, width 3.0m, height 3.2m
% Listener is 1.8288m (6') above floor.  (SLABScape LST_HEIGHT)
% Perfect reflector walls.
%
% slabout1 = direct
% slabout2 = right wall reflection
% slabout3 = 1 and 2 together
% slabout4 = direct and 6 reflections
%
% Note: This function places several large variables in the global workspace
% (see 'whos global').  To clear, 'clear global'.

% modification history
% --------------------
% 05.21.04  JDM  created
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR, updated comments
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

if nargin < 1,
  play = 0;
end;

global s1 s2 s3 s4 ss
if isempty(s1),
  s1 = wavread( 'slabout1.wav' );
  s2 = wavread( 'slabout2.wav' );
  s3 = wavread( 'slabout3.wav' );
  s4 = wavread( 'slabout4.wav' );
  ss = wavread( '\SLABData\wavs\sqam_voice_mg_3s.wav' );
%  ss = wavread( '\SLABData\wavs\sqam_voice_me.wav' );
end;

fontSize = 8;
dimLength = 11;
dimWidth = 7;

pts = size(s1,1);
te = [0 pts-1]/44.1;    % time endpoints
t = (0:(pts-1))/44.1;   % time sequence

figure;

% display impulse responses
wsdispw(t,te,s1,1,fontSize);
wsdispw(t,te,s2,3,fontSize);
wsdispw(t,te,s3,5,fontSize);
wsdispw(t,te,s4,7,fontSize);

% image for papers
set( gcf, 'PaperPosition', [ 0 0 dimWidth dimLength ] );
print( '-dtiff', '\\imimp' );

figure;

% display spectrums
wsdisps(s1,1,fontSize);
wsdisps(s2,3,fontSize);
wsdisps(s3,5,fontSize);
wsdisps(s4,7,fontSize);

% image for papers
set( gcf, 'PaperPosition', [ 0 0 dimWidth dimLength ] );
print( '-dtiff', '\\imspec' );

if play,

global y1 y2 y3 y4

disp 'Hit a key to play dry sound';
pause;
sound( ss, 44100 );

if isempty(y1),
  disp 'Convolving 1...'
  y1L = filter( s1(:,1), 1, ss );
  y2R = filter( s1(:,2), 1, ss );
  y1 = [ y1L y2R ];
end;

disp 'Hit a key to play direct sound';
pause;
sound( y1, 44100 );

if isempty(y2),
  disp 'Convolving 2...'
  y1L = filter( s2(:,1), 1, ss );
  y2R = filter( s2(:,2), 1, ss );
  y2 = [ y1L y2R ];
end;

disp 'Hit a key to play one lone reflection';
pause;
sound( y2, 44100 );

if isempty(y3),
  disp 'Convolving 3...'
  y1L = filter( s3(:,1), 1, ss );
  y2R = filter( s3(:,2), 1, ss );
  y3 = [ y1L y2R ];
end;

disp 'Hit a key to play direct + lone reflection';
pause;
sound( y3, 44100 );

if isempty(y4),
  disp 'Convolving 4...'
  y1L = filter( s4(:,1), 1, ss );
  y2R = filter( s4(:,2), 1, ss );
  y4 = [ y1L y2R ];
end;

disp 'Hit a key to play direct + six reflections';
pause;
sound( y4, 44100 );

end;


%------------------------------------------------------------------------------
% wavspec display wave
function wsdispw(t,te,s,loc,fontSize)

subplot(4,2,loc);
plot(t,s(:,1),'b');
axis( [ te -1 1] );
set( gca, 'FontSize', fontSize );
xlabel( 'Time (ms)', 'FontSize', fontSize );
ylabel( 'Amplitude', 'FontSize', fontSize );
title( 'Impulse Response - Left', 'FontSize', fontSize );

subplot(4,2,loc+1);
plot(t,s(:,2),'r');
axis( [ te -1 1] );
set( gca, 'FontSize', fontSize );
xlabel( 'Time (ms)', 'FontSize', fontSize );
ylabel( 'Amplitude', 'FontSize', fontSize );
title( 'Impulse Response - Right', 'FontSize', fontSize );


%------------------------------------------------------------------------------
% wavspec display spectrum
function wsdisps(s,loc,fontSize);

subplot(4,2,loc);
[sh,sf] = freqz( s(:,1), 1, 1024, 44100 );
plot( sf, 20*log10(abs(sh)), 'b' );
axis( [ min(sf) max(sf) -60 15 ] );
set( gca, 'FontSize', fontSize );
xlabel( 'Frequency (Hz)', 'FontSize', fontSize );
ylabel( 'Magnitude (dB)', 'FontSize', fontSize );
title( 'Spectrum - Left', 'FontSize', fontSize );
grid;

subplot(4,2,loc+1);
[sh,sf] = freqz( s(:,2), 1, 1024, 44100 );
plot( sf, 20*log10(abs(sh)), 'r' );
axis( [ min(sf) max(sf) -60 15 ] );
set( gca, 'FontSize', fontSize );
xlabel( 'Frequency (Hz)', 'FontSize', fontSize );
ylabel( 'Magnitude (dB)', 'FontSize', fontSize );
title( 'Spectrum - Right', 'FontSize', fontSize );
grid;
