% fbuild2.m - build an HRTF database submission using the Club Fritz format.
%
% Run from C:\nasa\amat\cf\acd2.
%
% See also: fload2.m, fload.m, fview.m

% modification history
% --------------------
%                ----  v6.0.0  ----
% 12.05.06  JDM  created from fbuild.m for ACD submission acd2
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

% The steps that follow are described in the Club Fritz PDF.

%------------------------------------------------------------------------------
% Neumann KU 100 Mics (Built-In Fritz Mics)
%------------------------------------------------------------------------------

% !!!! Fritz presently broken!  Built-in data unavailable.  Corresponding
% free-field measurement was taken, however.

% ----  free-field EQ data - B&K mics  ----

% speaker elevations
els = 70:-10:-40;

% az's per speaker elevation
azs = 180:-10:-170;

% map free-field eq data to HRIR measurements
for i = 1:length(els),
  ffgrid( :, 1:length(azs), i ) = [ els(i) * ones(1,length(azs)); azs ];
end;

% KU 100 mics should not be removed from Fritz.  Assume flat and use a
% measurement mic instead.
% mic = Bruel & Kjaer Type 4003,
% preamp = Danish Pro Audio HMA 4000
[IRdata, TDdata, subject, comments, srate, responses, location, taps, ...
 resolution, conversion, axiss, vectorSeq, eq, encryption, window, headsize, ...
 bassBoost, hdtrk, hdtrkData] = ...
   AHMread( 'C:\nasa\amat\ffeq.12.07.06\ff120706c.ahm' );
ffir = reshape(IRdata,256,24);

% make a Club Fritz free-field EQ data struct to work with;
% one mic in left ch, righ ch unused
ffb = ffmake( 'Bruel & Kjaer Type 4003', 'AuSIM AuPBE101', 'ACD HeadZap', ...
              srate, ffir(:,1:2:23), ffir(:,1:2:23), ffgrid, 0.9, 'polar', ...
              'measured 12/7/06 by JDM and MG' );

% save the Club Fritz free-field struct to a MATLAB .mat file;
% acd = lab, 1 = submission 1, ff = free field
fsave( ffb, 'acd1ff' );

% to load:
% ffb = load( 'acd1ff' );

% ----  free-field EQ data - B&K mics (repeat)  ----

[IRdata, TDdata, subject, comments, srate, responses, location, taps, ...
 resolution, conversion, axiss, vectorSeq, eq, encryption, window, headsize, ...
 bassBoost, hdtrk, hdtrkData] = ...
   AHMread( 'C:\nasa\amat\ffeq.12.07.06\ff120706d.ahm' );
ffir = reshape(IRdata,256,24);

% make a Club Fritz free-field EQ data struct to work with
ffb = ffmake( 'Bruel & Kjaer Type 4003', 'AuSIM AuPBE101', 'ACD HeadZap', ...
              srate, ffir(:,1:2:23), ffir(:,1:2:23), ffgrid, 0.9, 'polar', ...
              'repeat, measured 12/7/06 by JDM and MG' );

% save the Club Fritz free-field struct to a MATLAB .mat file
fsave( ffb, 'acd2ff' );

%------------------------------------------------------------------------------
% Panasonic WM-61 Insert Mics
%------------------------------------------------------------------------------

% ----  raw HRTF data  ----

% sarc, raw, panasonic
srp = sload( 'C:\nasa\amat\hrtf03\fritz1m' );

% make a Club Fritz HRIR struct to work with
n = size(srp.dgrid,2);  % number of responses
frp = fmake( 'Fritz', 'ACD HeadZap', srp.fs, ...
             srp.ir(:,1:n), srp.ir(:,n+1:end), srp.dgrid, 0.9, 'polar', ...
             'measured 8/1/06 by JDM, Panasonic WM-61 insert mics' );

% verify L,R:
figure;
i = 116;  % frp.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frp.hrir_l(:,i),'b',1:1024,frp.hrir_r(:,i),'r');
title( sprintf('frp az = %d, el = %d',frp.hgrid(2,i),frp.hgrid(1,i)) );

% recorded level:
fprintf( 'frp max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frp.hrir_l))), max(max(abs(frp.hrir_r))) );
% 0.1892,  0.1641

% save the Club Fritz HRIR struct to a MATLAB .mat;
% acd = lab, 1 = submission 1, r = raw data
fsave( frp, 'acd1r' );

% ----  raw HRTF data (repeat 1)  ----

% sarc, raw, panasonic
srp = sload( 'C:\nasa\amat\hrtf03\fritz3m' );

% make a Club Fritz HRIR struct to work with
n = size(srp.dgrid,2);  % number of responses
frp = fmake( 'Fritz', 'ACD HeadZap', srp.fs, ...
             srp.ir(:,1:n), srp.ir(:,n+1:end), srp.dgrid, 0.9, 'polar', ...
             'repeat 1, measured 8/1/06 by JDM, Panasonic WM-61 insert mics' );

% verify L,R:
figure;
i = 116;  % frp.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frp.hrir_l(:,i),'b',1:1024,frp.hrir_r(:,i),'r');
title( sprintf('frp az = %d, el = %d',frp.hgrid(2,i),frp.hgrid(1,i)) );

% recorded level:
fprintf( 'frp max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frp.hrir_l))), max(max(abs(frp.hrir_r))) );
% 0.1901,  0.1883

% save the Club Fritz HRIR struct to a MATLAB .mat
fsave( frp, 'acd2r' );

% ----  raw HRTF data (repeat 2)  ----

% sarc, raw, panasonic
srp = sload( 'C:\nasa\amat\hrtf03\fritz4m' );

% make a Club Fritz HRIR struct to work with
n = size(srp.dgrid,2);  % number of responses
frp = fmake( 'Fritz', 'ACD HeadZap', srp.fs, ...
             srp.ir(:,1:n), srp.ir(:,n+1:end), srp.dgrid, 0.9, 'polar', ...
             'repeat 2, measured 8/1/06 by JDM, Panasonic WM-61 insert mics' );

% verify L,R:
figure;
i = 116;  % frp.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frp.hrir_l(:,i),'b',1:1024,frp.hrir_r(:,i),'r');
title( sprintf('frp az = %d, el = %d',frp.hgrid(2,i),frp.hgrid(1,i)) );

% recorded level:
fprintf( 'frp max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frp.hrir_l))), max(max(abs(frp.hrir_r))) );
% 0.1886,  0.1807

% save the Club Fritz HRIR struct to a MATLAB .mat
fsave( frp, 'acd3r' );

% ----  free-field EQ data - Panasonic mics  ----

[IRdata, TDdata, subject, comments, srate, responses, location, taps, ...
 resolution, conversion, axiss, vectorSeq, eq, encryption, window, headsize, ...
 bassBoost, hdtrk, hdtrkData] = ...
   AHMread( 'C:\nasa\amat\ffeq.12.07.06\ff120706a.ahm' );
ffir = reshape(IRdata,256,24);

% make a Club Fritz free-field EQ data struct to work with
ffp = ffmake( 'Panasonic WM-61', 'AuSIM AuPBE101', 'ACD HeadZap', ...
              srate, ffir(:,1:2:23), ffir(:,2:2:24), ffgrid, 0.9, 'polar', ...
              'measured 12/7/06 by JDM and MG' );

% save the Club Fritz free-field struct to a MATLAB .mat file
fsave( ffp, 'acd3ff' );

% ----  free-field EQ data - Panasonic mics (repeat)  ----

[IRdata, TDdata, subject, comments, srate, responses, location, taps, ...
 resolution, conversion, axiss, vectorSeq, eq, encryption, window, headsize, ...
 bassBoost, hdtrk, hdtrkData] = ...
   AHMread( 'C:\nasa\amat\ffeq.12.07.06\ff120706b.ahm' );
ffir = reshape(IRdata,256,24);

% make a Club Fritz free-field EQ data struct to work with
ffp = ffmake( 'Panasonic WM-61', 'AuSIM AuPBE101', 'ACD HeadZap', ...
              srate, ffir(:,1:2:23), ffir(:,2:2:24), ffgrid, 0.9, 'polar', ...
              'repeat, measured 12/7/06 by JDM and MG' );

% save the Club Fritz free-field struct to a MATLAB .mat file
fsave( ffp, 'acd4ff' );
