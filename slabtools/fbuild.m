% fbuild.m - build an HRTF database submission using the Club Fritz format.
%
% See also: fload.m, fview.m

% modification history
% --------------------
%                ----  v5.8.0  ----
% 05.03.06  JDM  created
% 05.10.06  JDM  added insert mic and ff data
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

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
% The NASA ACD data used in this file is preliminary test data and is
% NOT an "official" Club Fritz submission!  It is being provided to demonstrate
% the Club Fritz submission format and to provide an initial rough submission
% while we finalize the development of our measurement system.
%
% NOTE: There exist significant known anomalies in the data!
%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%------------------------------------------------------------------------------
% Neumann KU 100 Mics (Built-In Fritz Mics)
%------------------------------------------------------------------------------

% ----  raw HRTF data  ----

% sarc, raw, neumann
srn = sload( 'fritzm1m' );

%        name: 'fritzm1                         '
%        date: '11/26/2003'
%      source: 'headzap'
%     comment: [1x256 char]
%          ir: [1024x864 double]
%         itd: []
%       dgrid: [2x432 double]
%        finc: 1
%       azinc: 10
%       elinc: 10
%          fs: 96000
%          mp: 0
%       tgrid: [6x432 double]
%        eqfs: 0
%         eqm: []
%         eqf: []
%       fgrid: []
%         eqd: []
%         eqb: []
%         eqh: []
%        hcom: ''
%     version: 4

% make a Club Fritz HRIR struct to work with
% (!!!! -ir corrects for a phase inversion in the test data)
n = size(srn.dgrid,2);  % number of responses
frn = fmake( 'Fritz', 'ACD HeadZap', srn.fs, ...
             -srn.ir(:,1:n), -srn.ir(:,n+1:end), srn.dgrid, 0.9, 'polar', ...
             'rough test measured by JDM, KU 100 mics' );

%         name: 'Fritz'
%         date: '05/10/2006'
%       source: 'ACD HeadZap'
%      comment: 'rough test measured by JDM, KU 100 mics'
%           fs: 96000
%     coordsys: 'polar'
%        range: 0.9000
%      version: 1
%       hrir_l: [1024x432 double]
%       hrir_r: [1024x432 double]
%        hgrid: [2x432 double]

% verify L,R:
figure;
i = 116;  % frn.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frn.hrir_l(:,i),'b',1:1024,frn.hrir_r(:,i),'r');
title( sprintf('frn az = %d, el = %d',frn.hgrid(2,i),frn.hgrid(1,i)) );

% recorded level:
fprintf( 'frn max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frn.hrir_l))), max(max(abs(frn.hrir_r))) );
% 0.0273, 0.0245
% !!!! Low compared to insert mic data.

% save the Club Fritz HRIR struct to a MATLAB .mat;
% in fsave(), struct fields are converted to vars before saving to .mat
% so that the functional version of load recreates struct;
% acd = lab, 1 = submission 1, r = raw data
fsave( frn, 'acd1r' );

% to load the Club Fritz .mat HRIR database into struct st:
% frn = load( 'acd1r' );

% ----  processed HRTF data  ----

% !!!! Since this was simply test data, it was processed using the default
% hz_speaker_and_panasonic_mic free-field EQF.

% sarc, processed, neumann
% !!!! Old filtering bug anomalies at end of IR.
spn = sload( 'fritzm1p' );

% the data is processed for use by SLAB, thus the data is interpolated to a
% uniform grid, hence more locations than the measured data database

%        name: 'fritzm1                         '
%        date: '11/26/2003'
%      source: 'headzap'
%     comment: [1x256 char]
%          ir: [128x1406 double]
%         itd: [1x703 double]
%       dgrid: [2x703 double]
%        finc: 1
%       azinc: 10
%       elinc: 10
%          fs: 44100
%          mp: 1
%       tgrid: []
%        eqfs: 96000
%         eqm: []
%         eqf: [256x24 double]
%       fgrid: [2x12 double]
%         eqd: []
%         eqb: []
%         eqh: [256x2 double]
%        hcom: 'Headphone model: HD580;   type: Circumaural;   coupling: Open     '
%     version: 4

% make a Club Fritz HRIR struct to work with
n = size(spn.dgrid,2);  % number of responses
fpn = fmake( 'Fritz', 'ACD HeadZap', spn.fs, ...
             spn.ir(:,1:n), spn.ir(:,n+1:end), spn.dgrid, 0.9, 'polar', ...
             'rough test measured by JDM, KU 100 mics' );

%         name: 'Fritz'
%         date: '05/10/2006'
%       source: 'ACD HeadZap'
%      comment: 'rough test measured by JDM, KU 100 mics'
%           fs: 44100
%     coordsys: 'polar'
%        range: 0.9000
%      version: 1
%       hrir_l: [128x703 double]
%       hrir_r: [128x703 double]
%        hgrid: [2x703 double]

% save the Club Fritz HRIR struct to a MATLAB .mat;
% acd = lab, 1 = submission 1, p = processed data
fsave( fpn, 'acd1p' );

% ----  free-field EQ data  ----

% KU 100 mics should not be removed from Fritz.  Assume flat and use a
% measurement mic instead.
% mic = Bruel & Kjaer Type 4003,
% preamp = Danish Pro Audio HMA 4000
% !!!! Use EQF data instead of sarc data because sarc contains Panasonic data.
[IRdata, TDdata, subject, comments, srate, responses, location, taps, ...
 resolution, conversion, axiss, vectorSeq, eq, encryption, window, headsize, ...
 bassBoost, hdtrk, hdtrkData] = AHMread('\AMAT\jdmff\ff_EQ96kHz_mics4.eqf');
ffir = reshape(IRdata,256,24);

% 70, -10, 96000
fprintf( 'AHM FF EQ elevOrg = %d, elevInt = %d, srate = %d\n', ...
         location.elevOrg, location.elevInt, srate );

% spn contains ff eq data used to process srn, use the two sarcs to determine
% mapping of ff eq data to HRTF data

% speaker elevations (az row not used)
els = spn.fgrid(1,:);
%    70    60    50    40    30    20    10     0   -10   -20   -30   -40

% find az's per speaker elevation
azs = srn.dgrid( 2, find( srn.dgrid(1,:) == spn.fgrid(1,1) ) );
%   180   170   160   150   140   130   120   110   100    90    80    70    60    50    40    30
%    20    10     0   -10   -20   -30   -40   -50   -60   -70   -80   -90  -100  -110  -120  -130
%  -140  -150  -160  -170

% map free-field eq data to HRIR measurements
for i = 1:length(els),
  ffgrid( :, 1:length(azs), i ) = [ els(i) * ones(1,length(azs)); azs ];
end;

% make a Club Fritz free-field EQ data struct to work with
ffb = ffmake( 'Bruel & Kjaer Type 4003', 'AuSIM AuPBE101', 'ACD HeadZap', ...
              srate, ffir(:,2:2:24), ffir(:,2:2:24), ffgrid, 0.9, 'polar', ...
              'rough test measured by JDM' );

%          mic: 'Bruel & Kjaer Type 4003'
%      speaker: 'AuSIM AuPBE101'
%         date: '05/10/2006'
%       source: 'ACD HeadZap'
%      comment: 'rough test measured by JDM'
%           fs: 96000
%     coordsys: 'polar'
%        range: 0.9000
%      version: 1
%         ff_l: [256x12 double]
%         ff_r: [256x12 double]
%       ffgrid: [2x36x12 double]

% save the Club Fritz free-field struct to a MATLAB .mat;
% acd = lab, 1 = submission 1, ff = free field
fsave( ffb, 'acd1ff' );

% to load:
% ffb = load( 'acd1ff' );

%------------------------------------------------------------------------------
% Panasonic WM-61 Insert Mics
%------------------------------------------------------------------------------

% ----  raw HRTF data  ----

% sarc, raw, panasonic
% !!!! 30 degree els inverted!
srp = sload( 'fritz081904m' );

% make a Club Fritz HRIR struct to work with
n = size(srp.dgrid,2);  % number of responses
frp = fmake( 'Fritz', 'ACD HeadZap', srp.fs, ...
             srp.ir(:,1:n), srp.ir(:,n+1:end), srp.dgrid, 0.9, 'polar', ...
             'rough test measured by JDM, Panasonic WM-61 insert mics' );

% verify L,R:
figure;
i = 116;  % frp.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frp.hrir_l(:,i),'b',1:1024,frp.hrir_r(:,i),'r');
title( sprintf('frp az = %d, el = %d',frp.hgrid(2,i),frp.hgrid(1,i)) );

% recorded level:
fprintf( 'frp max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frp.hrir_l))), max(max(abs(frp.hrir_r))) );
% 0.0952, 0.0751
% !!!! This might be a little low.

% save the Club Fritz HRIR struct to a MATLAB .mat;
% acd = lab, 2 = submission 2, r = raw data
fsave( frp, 'acd2r' );

% ----  processed HRTF data  ----

% sarc, processed, panasonic
% !!!! Some interpolated HRIRs a little odd.
spp = sload( 'fritz081904p' );

% make a Club Fritz HRIR struct to work with
n = size(spp.dgrid,2);  % number of responses
fpp = fmake( 'Fritz', 'ACD HeadZap', spp.fs, ...
             spp.ir(:,1:n), spp.ir(:,n+1:end), spp.dgrid, 0.9, 'polar', ...
             'rough test measured by JDM, Panasonic WM-61 insert mics' );

% save the Club Fritz HRIR struct to a MATLAB .mat;
% acd = lab, 2 = submission 2, p = processed data
fsave( fpp, 'acd2p' );

% ----  free-field EQ data  ----

% In a sarc, the free-field EQ data is stored in the processed data sarc.
% !!!! AuSIM changed the FF EQF format!  Newer sarcs contain speaker_mic
% inverse filters instead of raw speaker_mic measurements!

% speaker elevations (az row not used)
els = spp.fgrid(1,:);
%    70    60    50    40    30    20    10     0   -10   -20   -30   -40

% find az's per speaker elevation
azs = srp.dgrid( 2, find( srp.dgrid(1,:) == spp.fgrid(1,1) ) );
%   180   170   160   150   140   130   120   110   100    90    80    70    60    50    40    30
%    20    10     0   -10   -20   -30   -40   -50   -60   -70   -80   -90  -100  -110  -120  -130
%  -140  -150  -160  -170

% map free-field EQ data to HRIR measurements
for i = 1:length(els),
  ffgrid( :, 1:length(azs), i ) = [ els(i) * ones(1,length(azs)); azs ];
end;

% make a Club Fritz free-field EQ data struct to work with
n = size(spp.fgrid,2);  % number of responses
ffp = ffmake( 'Panasonic WM-61', 'AuSIM AuPBE101', 'ACD HeadZap', spp.eqfs, ...
              spp.eqf(:,1:n), spp.eqf(:,n+1:end), ffgrid, 0.9, 'polar', ...
              'rough test measured by JDM' );

% save the Club Fritz free-field struct to a MATLAB .mat file;
% acd = lab, 2 = submission 2, ff = free field
fsave( ffp, 'acd2ff' );
