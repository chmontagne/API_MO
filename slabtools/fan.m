% fan - Club Fritz Analysis

% modification history
% --------------------
%                ----  v5.8.0  ----
% 04.19.06  JDM  created
% 04.20.06  JDM  added sminp(), time windowing, HUT support
%                ----  v5.8.1  ----
% 06.28.06  JDM  added CIPIC raw data
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

% IRCAM
% -----
% measured data (no processing, i.e., no freefield eq, no headphone eq)
% fs = 44100 samples/s
% 
% 1517.sarc:
% s2=cam2sarc('1517raw','Fritz Knowles','IRCAM Neumann KU-100 measurement with Knowles mics and silicon ear canal plugs','1517');
% 
% 1518.sarc:
% hi=cam2sarc('1518raw','Fritz Neumann','IRCAM Neumann KU-100 measurement with internal Neumann mics','1518');
% 
% CIPIC
% -----
% measured data (with freefield eq, no headphone eq)
% freefield eq = speakers
% fs = 44100 samples/s
% 
% fritzcn.sarc:
% hc=cipic2sarc('hrir_fin','','CIPIC Fritz Neumann Mics','fritzcn');
% 
% fritzce.sarc:
% he=cipic2sarc('hrir_fin','','CIPIC Fritz Etymotic Mics','fritzce');
%
% fritzcnr.sarc:  (no freefield eq)
% hcr=cipic2sarc('hrir_raw','','CIPIC Fritz Neumann Mics','fritzcnr');
%
% NASA
% ----
% measured data (no processing, i.e., no freefield eq, no headphone eq)
% fs = 96000 samples/s

% load Club Fritz sarcs if not loaded already
if ~exist('hie'),
  hie = sload('1517');          % IRCAM external mics
  hii = sload('1518');          % IRCAM internal mics
  hce = sload('fritzce');       % CIPIC external mics
  hci = sload('fritzcnr');      % CIPIC internal mics, raw
  hne = sload('fritz081904m');  % NASA  external mics
  hni = sload('fritzm1m');      % NASA  internal mics

  % normalize IRs
  scale  = max(max(abs(hie.ir)));
  hie.ir = hie.ir ./ scale;
  scale  = max(max(abs(hii.ir)));
  hii.ir = hii.ir ./ scale;
  scale  = max(max(abs(hce.ir)));
  hce.ir = hce.ir ./ scale;
  scale  = max(max(abs(hci.ir)));
  hci.ir = hci.ir ./ scale;
  scale  = max(max(abs(hne.ir)));
  hne.ir = hne.ir ./ scale;
  scale  = max(max(abs(hni.ir)));
  hni.ir = hni.ir ./ scale;

  % convert all sarcs to minphase for time windowing
  disp('sminp hie...');
  hie = sminp(hie);       % window 120 (bump around 200)
  disp('sminp hii...');
  hii = sminp(hii);       % window 200
  disp('sminp hce...');
  hce = sminp(hce);       % window 100 (bump between 130-180)
  disp('sminp hci...');
  hci = sminp(hci);       % same
  disp('sminp hne...');
  hne = sminp(hne);       % window 130 (bump around 200)
  disp('sminp hni...');
  hni = sminp(hni);       % same
  disp('sminp done.');

  % use plot(hie.ir) to look for time window limit, can see reflections or
  % bumps of energy after HRIR

  load grid1010;  % for CIPIC grid mapping
  nearaz = 10;
  nearel = 10;
end;

%-----------------------------------------------
% hie = 
%        name: 'Fritz Knowles'
%        date: '11/25/2003'
%      source: 'ircam'
%     comment: 'IRCAM Neumann KU-100 measurement with Knowles mics and silicon ear canal plugs'
%          ir: [1024x4032 double]
%         itd: []
%       dgrid: [2x2016 double]
%        finc: 1
%       azinc: 5
%       elinc: 5
%          fs: 44100
%          mp: 0
%       tgrid: []
%        eqfs: 0
%         eqm: []
%         eqf: []
%       fgrid: []
%         eqd: []
%         eqb: []
%         eqh: []
%        hcom: ''
%     version: 4
%
% max(max(abs(hie.ir))) = 1.0000
%
% IRCAM grid
% AZ
% max(hie.dgrid(2,:)) =  180
% min(hie.dgrid(2,:)) = -175
% EL
% max(hie.dgrid(1,:)) =  90
% min(hie.dgrid(1,:)) = -45
%-----------------------------------------------
% hii = 
%        name: 'Fritz Neumann'
%        date: '11/21/2003'
%      source: 'ircam'
%     comment: 'IRCAM Neumann KU-100 measurement with internal Neumann mics'
%     (see above)
%
% max(max(abs(hii.ir))) = 0.7334
%-----------------------------------------------
% hce = 
%        name: 'fritz_etymo'
%        date: '11/25/2003'
%      source: 'cipic'
%     comment: 'CIPIC Fritz Etymotic Mics'
%          ir: [200x2500 double]
%         itd: []
%       dgrid: [2x1250 double]
%        finc: 0
%       azinc: 0
%       elinc: 0
%          fs: 44100
%          mp: 0
%       tgrid: []
%        eqfs: 0
%         eqm: []
%         eqf: []
%       fgrid: []
%         eqd: []
%         eqb: []
%         eqh: []
%        hcom: ''
%     version: 4
%
% max(max(abs(hce.ir))) = 1.3751
% Note: no azinc, elinc (older sarc, see below)
%-----------------------------------------------
% hci = 
%        name: 'fritz_neuma'
%        date: '11/21/2003'
%      source: 'cipic'
%     comment: 'CIPIC Fritz Neumann Mics'
%          ir: [200x2500 double]
%         itd: []
%       dgrid: [2x1250 double]
%        finc: 0
%       azinc: 25
%       elinc: 50
%       (see above)
%
% max(max(abs(hci.ir))) = 0.9950
%-----------------------------------------------
% hne = 
%        name: 'fritz                           '
%        date: '08/20/2004'
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
%
% max(max(abs(hne.ir))) = 0.0952
%
% NASA grid
% AZ
% max(hne.dgrid(2,:)) =  180
% min(hne.dgrid(2,:)) = -170
% EL
% max(hne.dgrid(1,:)) =   70
% min(hne.dgrid(1,:)) =  -40
%-----------------------------------------------
% hni = 
%        name: 'fritzm1                         '
%        date: '11/26/2003'
%        (see above)
%
% max(max(abs(hni.ir))) = 0.0273
%-----------------------------------------------

% Can use hlab() to compare IRs and mag responses (use Follow 1).
%
% For IRCAM data:
% Window Length = 1024.
%
% For CIPIC data:
% Different coord sys, pass as first sarc, NearGrid = 5,5,
% Window Length >= 200.
%
% For NASA data:
% Significant reflection, Window Length = 704.
% Inc = 10 (versus IRCAM 5), so pass NASA sarc as first param.
%
% hlab(hce,hie)
% hlab(hci,hii)

% plot overlapped mags (code from hlab())

figure(gcf);

% see also HUT section below
s1 = hci;       % CIPIC
s2 = hni;       % NASA
s3 = hii;       % IRCAM
winlen1 = 130;  % also used by HUT section
winlen2 = 130;
winlen3 = 130;

% vir() params
tf      = 0;
logfreq = 1;
edisp   = 0;  % 0 = left, 1 = right, 2 = both
winoff  = 1;

if edisp == 0,
  earc = 'L';
else,
  earc = 'R';
end;

% NASA   AZ -170 : 10 : 180
%        EL  -40 : 10 :  70
%
% IRCAM  AZ -175 :  5 : 180
%        EL  -45 :  5 :  90

for el2 = 0,
for az2 = 0,
%for el2 = [ 60 30 0 -30 ],  % HUT Els that overlap with NASA ELs
%for el2 =  70 : -nearel :  -40,
%for az2 = 180 : -nearaz : -170,
clf;

% az1,el1 can change during near grid comp if CIPIC
%az2 = 0;
%el2 = 0;
az1 = az2;
el1 = el2;

ngridstr = '';
% if not fixed-inc, i.e., if CIPIC, find closest measurement location to
% desired az,el
if ~s1.finc,
  % find nearest az to az1 value
  azr = round(az1/nearaz) * nearaz;
  % find nearest el to el1 value
  elr = round(el1/nearel) * nearel;
  % mapping from fixed-inc grid to non-fixed-inc grid
  naz = (180-azr)/nearaz + 1;
  nel = ( 90-elr)/nearel + 1;
  index = ngrid( naz, nel, 1 );
  az1 = s1.dgrid(2,index);
  el1 = s1.dgrid(1,index);
  % true-to-neargrid distance (cm's assuming 1m radius sphere)
  ngridstr = sprintf( '  CIPIC( %.1f, %.1f, d=%5.2f cm )', az1, el1, ...
                      ngrid( naz, nel, 2 )*100.0 );
end;

if 0,
vir( s1, tf, logfreq, az1, el1, edisp, 'b', 'b', 0, winoff, winlen1 );
hold on;
% by eye amp scaling
vir( s2, tf, logfreq, az2, el2, edisp, 'r', 'r', 0, winoff, winlen2, 0.6 );
vir( s3, tf, logfreq, az2, el2, edisp, 'g', 'g', 0, winoff, winlen3 );
end;

ps = 'g';  % non-NASA plot style
vir( s1, tf, logfreq, az1, el1, edisp, ps, ps, 0, winoff, winlen1 );
hold on;
% by eye amp scaling
vir( s2, tf, logfreq, az2, el2, edisp, 'k', 'k', 0, winoff, winlen2, 0.5 );
vir( s3, tf, logfreq, az2, el2, edisp, ps, ps, 0, winoff, winlen3 );

% HUT data
if ~isempty( intersect( el2, [ 60 30 0 -30 ] ) ),
  azt = az2;
  if azt < 0,
    azt = 360 + az2;
  end;
  if el2 < 0,
    elc = 'm';  % minus
  else
    elc = 'p';  % plus
  end;
  % ku07 = external mics
  % ku11 = internal mics
  meas = 'ku11';
  filename = sprintf( 'C:\\AMAT\\cf\\HUT\\head_hrirs\\%s_\\%s_ra0\\%s_%c%02d\\ra%03d%c%02d', ...
                      meas, meas, meas, elc, abs( el2 ), azt, elc, abs( el2 ) );
  loadvar = load( filename, '-mat' );
  ir = loadvar.hrtf(:,1+edisp);
  irlen = length( ir );
  [ dummy, tempir ] = rceps( [ ir; zeros(8192-irlen,1) ] );
  ir = 22 * tempir(1:winlen1);  % 22 chosen by eye using IR display
  if tf == 1,
    [h,w] = freqz( ir, 1, 4096, 48000 );
    semilogx( w, 20*log10(abs(h)), ps );
  else,
    plot( ir, ps );
  end;
% legend('CIPIC','NASA','IRCAM','HUT',3);
else,
% legend('CIPIC','NASA','IRCAM',3);
end;

hold off;
title( sprintf( 'Internal Mics %c ( %d, %d )%s', earc, az2, el2, ngridstr ) );
%title('Inter-lab Comparison, Neumann KU100, (0,0) Left Ear');
grid on;
if tf,
% axis( [ 1000 16000 -40 20 ] );
  axis( [ 2000 16000 -25 10 ] );
end;

pause;
end;  % for az
end;  % for el
