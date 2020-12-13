function [ ncbe, ff ] = cbe( h, az, el, left, bands, lowfreq, quiet, pcbf, ...
                             pmag, pcbe, pc, poff )
% cbe - display sarc critical band energy.
%
% [ ncbe, f ] = cbe( h, az, el, left, bands, lowfreq, quiet, pcbf, pmag,
%                    pcbe, pc, poff );
%
%   ncbe       Normalized Critical Band Energy
%   f          center frequencies
%
%   h          sarc struct
%   az, el     azimuth and elevation of desired HRTF, default = 0,0
%   left       1 = left ear, 0 = right ear, default = 1
%   bands      number of critical bands, default = 20
%   lowfreq    lowest frequency critical band, default = 100 Hz
%   quiet      0 = display output, 1 = no output, default = 0
%   pcbf       plot flag, HRTF critical band filter response, default = 0
%   pmag       plot flag, HRTF magnitude, default = 1
%   pcbe       plot flag, HRTF critical band energy, default = 1
%   pc         plot color, default = 'k'
%   poff       plot dB offset, default = 0
%
% This function requires the "Auditory Toolbox":
% https://engineering.purdue.edu/~malcolm/interval/1998-010/

% modification history
% --------------------
%                ----  v5.8.0  ----
% 09.08.05  JDM  created
% 09.22.05  JDM  made sarc tool
% 10.18.05  JDM  added return values, flipud(), quiet
% 10.20.05  JDM  increased N from 1024 to 2048 (measured ir length = 1024)
% 02.23.06  JDM  added params pcbf-poff
%                ----  v6.6.1  ----
% 04.24.12  JDM  ncbe no longer returned in dB
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

% defaults

if nargin < 1,
  % HRTF database, sarc
  h = slab2sarc( '\slab3d\hrtf\jdm.slh' );
end;

if nargin < 2,   az = 0;         end;
if nargin < 3,   el = 0;         end;
if nargin < 4,   left = 1;       end;
if nargin < 5,   bands = 20;     end;
if nargin < 6,   lowfreq = 100;  end; % Hz
if nargin < 7,   quiet = 0;      end;
if nargin < 8,   pcbf = 0;       end;
if nargin < 9,   pmag = 1;       end;
if nargin < 10,  pcbe = 1;       end;
if nargin < 11,  pc = 'k';       end;
if nargin < 12,  poff = 0;       end; % dB

%[ az, el, left, bands, lowfreq, quiet, pcbf, pmag, pcbe, poff ]

fs = h.fs;
N = 2048;
N2 = N/2;
NF = (N/2)+1; % FFT fs/2 bin (bins: dc,f,fs/2,f)
freqScale = (0:N2)/N2*(fs/2);

if left,
  index = hil( az, el, h.dgrid );
  strEar = 'left';
else, % right
  index = hir( az, el, h.dgrid );
  strEar = 'right';
end;

% HRTF mag response
H0 = abs( fft( h.ir(:,index), N ) );
% vir(h,1,1,0,0)

% critical band ERB filter bank
fcoefs = MakeERBFilters( fs, bands, lowfreq );
% center freqs
f = ERBSpace( lowfreq, fs/2, bands );
ff = flipud(f);

% impulse responses of filter bank
y = ERBFilterBank( [1 zeros(1,N-1)], fcoefs );
y = y';
H1 = abs( fft(y) );

% Rayleigh Energy Theorem (Parseval's Theorem) (pg.118 320 Reader)
en = sum(y.*y);
%(1/size(H,1))*sum(H(:,1:end).^2)

% HRTF filtered through filter bank
y2 = ERBFilterBank( [ h.ir(:,index); zeros(N-size(h.ir,1),1) ], ...
                    fcoefs );
y2 = y2';
H2 = abs( fft(y2) );

% normalized critical band energy
en2 = sum(y2.*y2);
%ncbe = flipud( 10*log10(en2') - 10*log10(en') );  % dB
ncbe = flipud( (en2./en)' );  % linear

% output - text and plots

if ~quiet,

if 0,
disp( ' ' );
disp( 'Critical Band Center Frequencies (Hz)' );
format bank
ff
disp( 'Normalized Critical Band Energy (dB)' );
10*log10(ncbe)
format
end;

figure(gcf);

% HRTF response
if pmag,
  semilogx( freqScale, poff + 20*log10( H0(1:NF) ), pc );
  hold on;
end;

% cb bank energy
%semilogx( f, 10*log10(en), 'o' );

% cb bank HRTF energy without offset
%semilogx( f, 20*log10(en2), 'ko-' );

% cb bank HRTF energy with offset
if pcbe,
  semilogx( f, poff + 10*log10(en2) - 10*log10(en), [ pc 'o:' ] );
% semilogx( f, poff + 10*log10(en2) - 10*log10(en), [ pc 'o' ] );
  hold on;
end;

% cb bank response
%semilogx( freqScale, 20*log10( H1(1:NF,1:end) ), ':' );

% cb bank HRTF response
if pcbf,
  semilogx( freqScale, poff + 20*log10( H2(1:NF,1:end) ) );
  hold on;
end;

axis( [ 0 fs/2 -60 20 ] );
xlabel( 'Frequency, Hz' );
ylabel( 'Energy, dB' );
title( sprintf( 'Normalized Critical Band Energy (%s ear, az = %d, el = %d)', ...
       strEar, az, el ) );
%grid;
hold off;

end; % quiet

%------------------------------------------------------------------------------
% NOTES

% from MakeERBFilters.m
if 0,
fcoefs = MakeERBFilters(16000,10,100);
y = ERBFilterBank([1 zeros(1,511)], fcoefs);
resp = 20*log10(abs(fft(y')));
freqScale = (0:511)/512*16000;
semilogx(freqScale(1:255),resp(1:255,:));
axis([100 16000 -60 0])
xlabel('Frequency (Hz)'); ylabel('Filter Response (dB)');
end;

% from test_auditory.m

if 0,
disp('DesignLyonFilters test');
figure;
filts=DesignLyonFilters(16000);
size(filts)
filts(1:5,:)
resp2=soscascade([1 zeros(1,255)],filts);
freqResp=20*log10(abs(fft(resp2(1:5:88,:)')));
freqScale2=(0:255)/256*16000;
semilogx(freqScale2(1:128),freqResp(1:128,:))
axis([100 10000 -60 20]);
end;

if 0,
disp('FreqResp test');
figure;
filts=DesignLyonFilters(16000);
f=10:10:7990;
resp2=FreqResp(filts(2, :), f, 16000);
semilogx(f,resp2);
axis([100 10000 -50 20]);
end;
