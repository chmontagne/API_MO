% cwt - Continuous Wavelet Transform (work paused)
%
% A Continuous Wavelet Transform (CWT) based on Teolis and WaveLab.
% This effort was paused as focus shifted to wave_matlab scripts [3].
%
% References:
% [1] Anthony Teolis, "Computational Signal Processing with Wavelets"
% [2] http://www-stat.stanford.edu/~wavelab/, WaveLab 850 software
% [3] http://paos.colorado.edu/research/wavelets
%
% See also: morlet.m, wmdemo.m

% modification history
% --------------------
%                ----  v6.2.0  ----
% 05.15.08  JDM  created
%                ----  v6.3.0  ----
% 12.10.08  JDM  rewrite
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

% test signal
%
% log2(4096) = 12      Nyquist freq
% log2(200)  = 7.6439  sin segment 1
% log2(400)  = 8.6439  sin segment 2

x = zeros(8192,1);
x(500:2000)  = sin(2*pi*200*(500:2000)/8192);
x(4000:6000) = sin(2*pi*400*(4000:6000)/8192);
figure;
plot(x);
%wavplay(x,8192);

% WaveLab Notes
%
% cd to Wavelab850/ dir
% run WavePath.m to set paths
%
% WaveLab freq-domain Morlet wavelet
% second term often omitted, values extremely small
% see: http://en.wikipedia.org/wiki/Morlet_wavelet
% window = exp(-(ws - wc).^2 ./2) - exp(-(ws.^2 + wc.^2)/2);
%
% trans = CWT_Wavelab( x, 1, 'Morlet' );  % nvoice = 1
% ImageCWT( trans, 'Overall', 'jet' );

% WaveLab wavelet and scaling parameters
nvoice = 1;
oct = 2;     % WaveLab default = 2, can result in discontinuity at N/2
scale = 4;   % WaveLab default = 4
wc = 5;      % WaveLab default = 5

x = x(:)';
N = length(x);
X = fft(x);
w = [ 0:N/2 (-N/2)+1:-1 ] .* 2*pi/N;  % radians

noctave = floor(log2(N))-oct;
nscale = nvoice .* noctave;
trans = zeros(N,nscale);
mtime = zeros(N,nscale);
mfreq = zeros(N,nscale);

jj = 0;  % low to high freqs
for jo = 1:noctave,
  for jv = 1:nvoice,
    jj = jj+1;

    % WaveLab scaling
    a = scale .* 2^(jo - 1 + jv/nvoice);
    ws =  N .* w ./ a ;

    % freq-domain scaled Morlet wavelet
    % (Teolis pgs.65-70, Fourier Transform in notebook "NASA 8" 5/16/08)
    DsG = (1/sqrt(a)) .* exp(-(ws - wc).^2./2);
    mfreq(:,jj) = DsG;
    mtime(:,jj) = ifft(DsG);  % time-domain

    % apply filter, keep real part of time-domain result
    transC = ifft( DsG .* X );
    trans(1:N,jj) = real( transC )';
  end;
end;

figure;
subplot(3,1,1);
plot(mfreq);
title('freq');
subplot(3,1,2);
plot(fftshift(real(mtime)));
title('time - real');
subplot(3,1,3);
plot(fftshift(imag(mtime)));
title('time - imag');

% see also: WaveLab ImageCWT()
figure;
imagesc(1:N,jj:-1:1,trans');
h = gca;
set( h, 'YTickLabel', flipud(get(h,'YTickLabe')) );
grid on;
colorbar;
