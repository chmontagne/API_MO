% ccheck - check suspicious cipic2slab HRTFs.
%
% ccheck displays suspicious CIPIC SLHs in their native format.
%
% See also: cipic2slab, lcheck

% modification history
% --------------------
%                ----  v6.6.0  ----
% 03.31.11  JDM  created
%                ----  v6.7.2  ----
% 10.16.13  JDM  added to slab3d\slabtools\
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

% Suspect Databases
%
% cd H:\slab\cipic_cd\CIPIC_hrtf_database\standard_hrir_database\subject_018
%
% subject_018 - large ITD discontinuities
% vitd() output - note under metric
% subject_018  bias -10.4  absmag 36.8  mag -27.8  under -363.5  over  71.2
%              dis 1.929  shift    3.125
%
% L/R energy differences were found using the hen() script.
% hen.m analysis performed on post-cipic2slab() data.
% ccheck.m analysis performed on CIPIC data.
% The examination threshold is hen.m abs(L-R) >= 2dB.
%
% subject_009 Energy:  L 5.1 dB  R  1.1 dB  L-R  4.0 dB
% subject_020 Energy:  L 2.4 dB  R  0.0 dB  L-R  2.4 dB
% subject_050 Energy:  L 0.4 dB  R  3.8 dB  L-R -3.4 dB
% subject_060 Energy:  L 1.8 dB  R -1.8 dB  L-R  3.5 dB
% subject_135 Energy:  L 1.1 dB  R  3.3 dB  L-R -2.2 dB
% subject_158 Energy:  L 2.1 dB  R  4.0 dB  L-R -1.9 dB
% subject_163 Energy:  L 3.7 dB  R  0.5 dB  L-R  3.3 dB

s = load( 'hrir_final.mat' );

%        OnR: [25x50 double]
%        OnL: [25x50 double]
%        ITD: [25x50 double]
%     hrir_r: [25x50x200 double]
%     hrir_l: [25x50x200 double]
%       name: 'subject_018'

% cipic grid
% els-grouped-by-az (e.g., all els at -80 az and so on)
% cgrid( 1, index ) = el; cgrid( 2, index ) = az
caz = [ -80 -65 -55 -45:5:45 55 65 80 ];
cel = -45 + 5.625*(0:49);
cgrid = [kron(ones(size(caz)),cel); kron(caz,ones(size(cel)))];

% sample rate
fs = 44100;
samp2us = 1000000/fs;
us2samp = 1/samp2us;

resp = length(caz) * length(cel);
itd = zeros(1,resp);
spitd = zeros(1,resp);
hrirs = zeros( size(s.hrir_l,3), resp*2 );
sgrid = [];
i = 0;
for az=1:length(caz),
  for el=1:length(cel),
    i = i + 1;
    % cipic interaural polar to slab3d vertical polar
    [ saz sel ] = c2s( cgrid(2,i), cgrid(1,i) );
    sgrid = [ sgrid [sel;saz] ];
    hrirs( :, (az-1)*length(cel) + el ) = squeeze(s.hrir_l(az,el,:));
    hrirs( :, (az-1)*length(cel) + el + resp ) = squeeze(s.hrir_r(az,el,:));

    % cipic OnL-OnR is signed version of cipic ITD;
    % in slab3d:  src L, -az, -itd, lag right 
    %             src R, +az, +itd, lag left
    itd(i) = s.OnL(az,el) - s.OnR(az,el);
    spitd(i) = sitd( saz, sel, 0.09, 1.0 ) * us2samp;
  end;
end;

% plot cipic and spherical head model ITDs
%   subject_018 - large ITD discontinuities
plot(itd,'b.-');
hold on;
plot(spitd,'r.-');
grid on;
title('ITDs');

% total energy left and right (see hen.m)
%   subject_009 - large L/R energy diff
%                 Energy:  L 5.1 dB  R 1.1 dB  L-R 4.0 dB
index = [1:resp]';
indexL = index;
indexR = index + resp;
gainL = sum(hrirs(:,indexL).*hrirs(:,indexL));
gainR = sum(hrirs(:,indexR).*hrirs(:,indexR));
gL = 10*log10(mean(gainL));
gR = 10*log10(mean(gainR));
fprintf( 'Energy:  L %4.1f dB  R %4.1f dB  L-R %4.1f dB\n', gL, gR, gL-gR );
