function gen( fd )
% gen - slab3d generator visualization.
%
% gen( fd )
%
% fd = desired frequency, default = 440 Hz

% modification history
% --------------------
%                ----  v5.7.0  ----
% 07.11.05  JDM  created, square, triangle
% 08.02.05  JDM  added sin, tableX() funcs
%                ----  v5.8.0  ----
% 01.18.06  JDM  added sin table SNR test and results (Moore, pg.164)
% 01.19.06  JDM  added band-limited table-based triangle (Moore, pg.170)
% 01.20.06  JDM  added table band-limited sawtooth and square, bSaveTables
%                ----  v6.8.2  ----
% 10.06.17  JDM  added (-1)^k to bl-saw sum and removed pi phase, saw now
%                starts at 0 instead of -1; added maxHarmonic and both
%                ascending and descending saws; one table length, len;
%                added arbitrary harmonic bl-triangle; add maxHarmonic to
%                table filenames
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

% RESULTS
%
% sin table length = 256
%
% >> gen(1)
% desired f = 1.0 Hz, fs = 44100.0 Hz
% integer half period = 22050 samples, resulting f = 1.0 Hz
% RMS st = 0.707107, s2 = 0.707071, err = 0.000039
% SNR(s2,err) = 85.193894 dB
%
% >> gen
% desired f = 440.0 Hz, fs = 44100.0 Hz
% integer half period = 50 samples, resulting f = 441.0 Hz
% RMS st = 0.707907, s2 = 0.707871, err = 0.000039
% SNR(s2,err) = 85.193951 dB
%
% >> gen(20000)
% desired f = 20000.0 Hz, fs = 44100.0 Hz
% integer half period = 1 samples, resulting f = 22050.0 Hz
% RMS st = 0.494313, s2 = 0.494286, err = 0.000028
% SNR(s2,err) = 84.994686 dB
%
% sin table length = 512
%
% desired f = 440.0 Hz, fs = 44100.0 Hz
% RMS st = 0.707907, s2 = 0.707898, err = 0.000010
% SNR(s2,err) = 97.236423 dB
%
% sin table length = 1024
%
% desired f = 440.0 Hz, fs = 44100.0 Hz
% RMS st = 0.707907, s2 = 0.707905, err = 0.000002
% SNR(s2,err) = 109.276583 dB
%
% Note: STK recently lengthened sin table from 256 to 1024.

if nargin < 1,
  fd = 440; % desired freq, Hz
end;

% a wave table up to harmonic 11 will not alias under 2000 Hz
% (44100/2000)/2 = 11.0250, (fs/max_freq)/2 = max_harmonic
%maxHarmonic = 11;

% find harmonic for D5# to maximize harmonic content
% (44100/622.253967)/2 = 35.4357 max harmonic for D5#
maxHarmonic = 35;

% waveform table length
len = 1024;

% whether to save tables to file (sin, triangle, saw, square)
bSaveTables = 0;

% tableX() function member vars;
% table approach better for real-time update of freq and phase
global s;

% !!!! parameters that make triangle aliasing and sine SNR near perfect:
% fs = 48000, fd = 3000, 48000/3000 = 16 samples/period, 1024/16 = 64 periods
% in alias analysis window; integer number of periods so no windowing artifacts

%fs = 48000;  % sampling rate
fs = 44100;  % sampling rate
%pd = pi/2;   % desired phase, radians
pd = 0;      % desired phase, radians
amp = 1.0;   % amplitude

fprintf( '\ndesired f = %.1f Hz, fs = %.1f Hz\n', fd, fs );

% half-period method vars
thalf = floor( fs / (2*fd) );  % integer half period, samples
f = (fs/2)/thalf;  % actual freq due to integer half period constraint

fprintf( 'integer half period = %d samples, resulting f = %.1f Hz\n', thalf, f );

% ----  integer half-period square  ----

% one period of square wave
sqp = amp * [ ones(thalf,1); -ones(thalf,1) ];

% ----  integer half-period triangle  ----

% triangle wave slope
slope = 2*amp/thalf;
% one period of triangle wave
trp = [ [-amp:slope:amp]'; [(amp-slope):-slope:(-amp+slope)]' ];

% ----  table-based triangle  ----

tableInit( [ 0 1 0 -1 ], 4, fs );
tableSetPhase( pd );
tableSetFreq( fd );

% generate approx two periods
tr2 = zeros(length(sqp)*2,1);
for i=1:length(tr2),
  tr2(i) = tableGenSample;
end;

% generate 1024 samples for frequency response analysis, look for aliasing;
% to display harmonic freqs and amps:
% >> format bank;h=1:2:21;[h' 2000.*h' 20*log10(1./h.^2)'],format
if 0,
Nalias = 1024;
tr2long = zeros(1024,1);
tableReset;
for i=1:1024,
  tr2long(i) = tableGenSample;
end;
htr2long = figure;
plotresp( tr2long, Nalias, fs, 'b' );
end;

% ----  band-limited table-based triangle  ----

% band-limit to avoid wave table aliasing (Moore, pg.170)
% (triangle ref: http://en.wikipedia.org/wiki/Triangle_wave)

% original bl-triangle table up to harmonic 11
if 0,
% make table, fundamental and five odd harmonics
tinc  = 1*2*pi/len;
table =         ( 1/1  ) * sin( 0:tinc:(1*2*pi-tinc) );
tinc  = 3*2*pi/len;
table = table + (-1/9  ) * sin( 0:tinc:(3*2*pi-tinc) );
tinc  = 5*2*pi/len;
table = table + ( 1/25 ) * sin( 0:tinc:(5*2*pi-tinc) );
tinc  = 7*2*pi/len;
table = table + (-1/49 ) * sin( 0:tinc:(7*2*pi-tinc) );
tinc  = 9*2*pi/len;
table = table + ( 1/81 ) * sin( 0:tinc:(9*2*pi-tinc) );
tinc  = 11*2*pi/len;
table = table + (-1/121) * sin( 0:tinc:(11*2*pi-tinc) );
end;

table = zeros(1,len);
for k=1:2:maxHarmonic,
  tinc  = k*2*pi/len;
  table = table + (-1)^((k-1)/2) * (1/k^2) * sin( 0:tinc:(k*2*pi-tinc) );
end;

% normalize table max amp to 1;
% for len = 1024 and five odd harmonics, the scalar is 0.8388;
% in theory, the scalar should be 8/pi^2 = 0.8106
table = table/max(abs(table));

global tableTri;
tableTri = table;

% plot table and table spectrum
if 0,
figure;
plot( table, '.-' );
%figure;
%freqz( table, 1, len/2, fs );
end;

% save table to file for use by gslab
if bSaveTables,
filename = sprintf( 'tabtri%02d.cpp', maxHarmonic );
fid = fopen( filename, 'wt' );
for i=1:len,
  fprintf( fid, '  %18.15ff,\n', table(i) );
end;
fclose( fid );
end;

% init wave table functions
tableInit( table, len, fs );
tableSetPhase( pd );
tableSetFreq( fd );

% generate approx two periods
trbl = zeros(length(sqp)*2,1);
for i=1:length(trbl),
  trbl(i) = tableGenSample;
end;

% generate 1024 samples for frequency response analysis
if 0,
trbllong = zeros(1024,1);
tableReset;
for i=1:1024,
  trbllong(i) = tableGenSample;
end;
figure(htr2long);
hold on;
plotresp( trbllong, Nalias, fs, 'r' );
hold off;
subplot(2,1,1);
title( 'Frequency Response of Non-BL and BL Triangles' );
end;

% ----  table-based sin  ----

tinc = 2*pi/len;
table = sin( 0:tinc:(2*pi-tinc) );

% save table to file for use by gslab
if bSaveTables,
fid = fopen( 'tabsin.cpp', 'wt' );
for i=1:len,
  fprintf( fid, '  %18.15ff,\n', table(i) );
end;
fclose( fid );
end;

tableInit( table, len, fs );
tableSetPhase( pd );
tableSetFreq( fd );

% generate approx two periods
s2 = zeros(length(sqp)*2,1);
st = s2;
for i=1:length(s2),
  st(i) = sin( 2*pi*fd*(i-1)/fs );  % true sin
  s2(i) = tableGenSample;
end;

% calculate SNR (determined by table length, Moore, pg.166)
s2rms = sqrt(mean(s2.^2));
erms  = sqrt(mean((st-s2).^2));  % table error relative to true sin
fprintf( '\nRMS st = %f, s2 = %f, err = %f\nSNR(s2,err) = %f dB\n\n', ...
  sqrt(mean(st.^2)), s2rms, erms, 20*log10( s2rms/erms ) );

% plot true sin, table sin, and difference
if 0,
figure;
plot( [ st s2 ], '-o' ); grid;
figure;
plot( st-s2, '-o' ); grid;
end;

% ----  band-limited table-based sawtooth  ----

% band-limit to avoid wave table aliasing (Moore, pg.170);
% sawtooth ref: http://en.wikipedia.org/wiki/Sawtooth_wave

% sum fundamental and harmonics above
table = zeros(1,len);

for k=1:maxHarmonic,
  tinc  = k*2*pi/len;

  % descending (aka reverse or inverse) saw
  table = table + (1/k) * (-1)^k * sin( 0:tinc:(k*2*pi-tinc) );

  % version v6.8.1 and before:
  % phase shifted 180 degrees such that waveform rises -1 to +1 in table;
  % with (-1)^k, the saw waveform is similar to the sine/square/triangle
  % waveshape with positive values followed by negative values
  %table = table + (1/k) * sin( pi + (0:tinc:(k*2*pi-tinc)) );
end;

% normalize table max amp to 1;
% for len = 1024 and 11 harmonics, scalar = 0.5817;
% in theory, scalar = 2/pi = 0.6366
% descending saw
%table = table/max(abs(table));
% ascending saw
table = -table/max(abs(table));

% plot table and table spectrum
if 0,
figure;
plot( table, '.-' ); grid;
figure;
freqz( table, 1, len/2, fs );
end;

% save table to file for use by gslab
if bSaveTables,
filename = sprintf( 'tabsaw%02d.cpp', maxHarmonic );
fid = fopen( filename, 'wt' );
for i=1:len,
  fprintf( fid, '  %18.15ff,\n', table(i) );
end;
fclose( fid );
end;

% init wave table functions
tableInit( table, len, fs );
tableSetPhase( pd );
tableSetFreq( fd );

% generate two periods
global saw;
% to listen, global saw and use:
% >> samples35 = repmat(saw,200,1);
% >> wavplay(samples35,44100)
saw = zeros(length(sqp)*2,1);
for i=1:length(saw),
  saw(i) = tableGenSample;
end;

% ----  band-limited table-based square  ----

% band-limit to avoid wave table aliasing (Moore, pg.170);
% square ref: http://en.wikipedia.org/wiki/Square_wave

% sum fundamental and harmonics above
table = zeros(1,len);
for k=1:2:maxHarmonic,
  tinc  = k*2*pi/len;
  table = table + (1/k) * sin( 0:tinc:(k*2*pi-tinc) );
end;

% normalize table max amp to 1;
% for len = 1024 and 6 harmonics (incl. fund.), scalar = 1.0779;
% in theory, scalar = 4/pi = 1.2732
table = table/max(abs(table));

% plot table and table spectrum
if 0,
figure;
plot( table, '.-' ); grid;
%figure;
%freqz( table, 1, len/2, fs );
end;

% save table to file for use by gslab
if bSaveTables,
filename = sprintf( 'tabsquare%02d.cpp', maxHarmonic );
fid = fopen( filename, 'wt' );
for i=1:len,
  fprintf( fid, '  %18.15ff,\n', table(i) );
end;
fclose( fid );
end;

% init wave table functions
tableInit( table, len, fs );
tableSetPhase( pd );
tableSetFreq( fd );

% generate approx two periods
sqr = zeros(length(sqp)*2,1);
for i=1:length(sqr),
  sqr(i) = tableGenSample;
end;

% ----  plot  ----

% plot two periods
sq = [ sqp; sqp ];
tr = [ trp; trp ];
figure;
plot( [ sq tr tr2 trbl s2 saw sqr ], 'o-' );
grid;
legend( 'half-period square', 'half-period triangle', 'table triangle', ...
        'table band-limited triangle', 'table sin', ...
        'table band-limited saw', 'table band-limited square', 3 );
title( 'signal generators' );
axis( [ 1 length(sq) -1.2 1.2 ] );

%------------------------------------------------------------------------------
function tableInit( table, length, fs )
global s;
inc = 2*pi/length;
s = struct( 'table', table, 'length', length, 'inc', inc, 'finc', 0, ...
            'offset', 0, 'index', 0, 'fs', fs );

%------------------------------------------------------------------------------
function tableReset()
global s;
s.index = 0;

%------------------------------------------------------------------------------
function tableSetPhase( phase )
global s;
% radian phase to table sample offset
s.offset = phase / s.inc;

%------------------------------------------------------------------------------
function tableSetFreq( freq )
global s;
% finc depends on desired freq (freq) and sample rate (fs)
s.finc = (s.length/s.fs)*freq;

%------------------------------------------------------------------------------
function sample = tableGenSample()
global s;

pindex = mod( s.index + s.offset, s.length );
i1 = floor( pindex );
i2 = i1 + 1;
if i2 > s.length-1,
  i2 = 0;
end;
wt2 = pindex - i1;
wt1 = 1.0 - wt2;
sample = wt1 * s.table( 1+i1 ) + wt2 * s.table( 1+i2 );
s.index = mod( s.index + s.finc, s.length );
