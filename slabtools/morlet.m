% morlet - Morlet wavelet visualization
%
% A simple visualization script to investigate different Morlet wavelet
% equations.
%
% References:
% [1] Anthony Teolis, "Computational Signal Processing with Wavelets"
% [2] http://www.eso.org/sci/data-processing/software/esomidas/doc/user/
%     98NOV/volb/node312.html, ESO-MIDAS documentation
%     Notes:  Cites [3] for Morlet wavelet definition.
% [3] P. Goupillaud, A. Grossmann, J. Morlet, "Cycle-octave and related
%     transforms in seismic signal analysis", Geoexploration, 23, 85-102,
%     1984-1985.
%     Notes: [4] also cites [3] but shows a formula with an extra term.
%     For certain parameters, this term can be omitted.
% [4] http://en.wikipedia.org/wiki/Morlet_wavelet
% [5] http://www-stat.stanford.edu/~wavelab/, WaveLab 850 software
%     Notes: CWT_Wavelab.m and RWT.m use extra term in [4].
%     Their implementation cites Mallat [6], 4.3.1 and 4.3.3.
% [6] Stéphane Mallat, “A Wavelet Tour of Signal Processing”, 2nd ed.,
%     Academic Press, 1999
%
% See also: cwt.m, wmdemo.m

% modification history
% --------------------
%                ----  v6.2.0  ----
% 04.10.08  JDM  created
%                ----  v6.3.0  ----
% 12.05.08  JDM  merged MIDAS and Teolis visualization
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

% MIDAS refers to the Morlet paper freq domain definition:
%   ghat(w) = exp(-2*pi^2*(v-v0)^2)
% Employing Euler's formula, MIDAS time domain version is equivalent to Teolis
% version with Teolis bandwidth gamma_b = 2.
% Euler's formula: A*e^(jx) = A*cos(x) + A*j*sin(x)
% MIDAS v0 is Teolis gamma_c, the center freq in Hz.
% MIDAS comment: "The admissibility condition is verified only if v0 > 0.8."
% Teolis: gamma_b*gamma_c^2 must be large enough to make the mean small because
% the Morlet wavelet is not zero-mean.

% MIDAS Figure 14.1, v0 ~= 0.8, gb = 2,
% Teolis FIGURE 4.4, pg.67, v0 = 1, gb = 1

%v0 = 0.8;        % center freq in Hz
v0 = 1;           % Teolis gamma_c center freq in MHz
%gb = 2;          % time-domain window width
gb = 1;           % Teolis gamma_b bandwidth, "unit variance"
t  = -6:0.01:6;   % time in seconds (Teolis us)
v  = -4:0.01:4;   % freq in Hz (Teolis MHz)

% g(t), Morlet wavelet time domain
g = (1/sqrt(pi*gb))*exp(j*2*pi*v0*t-t.^2/gb);

% ghat(v), Morlet wavelet freq domain
ghat = exp(-gb*pi^2*(v-v0).^2);

% figure formatted to look like Teolis figure

% plot time
subplot(2,1,1);
plot(t,real(g),'b-');
hold on;
plot(t,imag(g),'r-');
grid on;
xlabel( 'Time (us)' );  % or s
axis([-6 6 -1 1]);
title('Morlet');  % or g(t)

% plot freq
subplot(2,1,2);
plot(v,ghat,'b-');
grid on;
xlabel('Frequency (MHz)');  % or Hz
ylabel('Magnitude');
title('|Morlet\^|');  % or ghat(v)
axis([-4 4 -0.02 1.02]);
