% vcen - verify HRTF database collection energy using time-domain metrics.
%
% vcen() calls hen() for all SLHs found in current dir.
% hen() params are set in source code.
% A table of metrics is generated and a summary plot displayed.
% This script is used for visualization, vcenf.m is used for metrics.
%
% See also: vcenf, hen, hencb, cipic2slab, listen2slab, sarc

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.09.11  JDM  created
%                ----  v6.6.1  ----
% 04.24.12  JDM  added hencb()
%                ----  v6.7.2  ----
% 10.15.13  JDM  added to slab3d\slabtools\
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

d = dir('*.slh');
%d = dir('subject_*.slh');  % verify cipic
%d = dir('IRC_*.slh');  % verify Listen
% to view subset
%d(1).name = 'subject_009.slh';  % 3
%d(2).name = 'subject_050.slh';  % 19
%d(1).name = 'IRC_1059.slh';
%d(2).name = 'IRC_1031.slh';

allstats = [];
for k = 1:length(d),
  h = slab2sarc( d(k).name );

  % hen( h, int, dtext, haL, haR, oneLine, top-bottom, bSphere, bIID, nGrid )
  fprintf('%2d ',k);
  bIID = 0;
  nGrid = -1;  % -1 = none, 0 = slab3d, 1 = CIPIC, 2 = Listen, 3 = ACD
  stats = hen(h,0,0,[],[],1,1,1,bIID,nGrid);
  %stats = henitd(h,0,0,[],[],1,1,1,nGrid);  % top-down sphere IID/ITD
  %stats = henitd(h,1,0,[],[],1,1,0,nGrid);  % top-down surface IID/ITD

  % ITD/energy metric cross-verification
  if 0,
  switch h.name(1:8)
    case 'IRC_1054'  % good shift/dbias metrics
      %print(gcf,'-dpng','vcen_irc_1054_54dB_span.png');  % span set in hen()
      print(gcf,'-dpng','vcen_irc_1054_2dB_span.png');
    case 'IRC_1059'  % bad shift (yaw error)
      print(gcf,'-dpng','vcen_irc_1059_shift7.5.png');
    case 'IRC_1013'  % bad dbias (y/interaural axis error if not diagonal,
                     %            roll if diagonal)
      print(gcf,'-dpng','vcen_irc_1013_dbias73.8.png');
  end;      
  end;

  % hencb( h, tb, bSphere, table, oneLine, cbn, bSave, bQuiet )
  % defaults: hencb( h, 1, 0, 0, 0, 1, 0, 0 )
  %stats = hencb(h,1,1,0,1,20,0,1);

  % stats = [ mAll maxL minL mlAll maxR minR mrAll
  %                maxL-maxR minL-minR mlAll-mrAll maxabsLR ];
  allstats = [ allstats; stats ];

  pause;
end;

% ----  plot allstats  ----

figure;
len = size(allstats,1);

name = '';
%name = ' - CIPIC';
%name = ' - Listen';

subplot(2,1,1);
plot(allstats(:,[2 3 4]), 'b.-');
hold on;
plot(allstats(:,[5 6 7]), 'r.-');
plot(allstats(:,1), 'g.-');
plot(allstats(:,11), 'k.-');
grid on;
axis([ 0 len+1 -30 30 ]);
legend( 'maxL', 'minL', 'meanL', 'maxR', 'minR', 'meanR', 'Total', 'mIID', ...
        'Location', 'EastOutside' );
xlabel('database index');
ylabel('dB');
title(sprintf('Energy Max,Min,Mean,MaxIID%s',name));

subplot(2,1,2);
plot(allstats(:,8), 'r.-');
hold on;
plot(allstats(:,9), 'b.-');
plot(allstats(:,10), 'g.-');
grid on;
axis([ 0 len+1 -6 6 ]);
legend( 'maxD', 'minD', 'meanD', 'Location', 'EastOutside' );
xlabel('database index');
ylabel('dB');
title('Energy Metric Differences');

% tail energy
if 0,
figure;
len = size(allstats,1);
plot(allstats(:,[2 3 4]), 'b.-');
hold on;
plot(allstats(:,[5 6 7]), 'r.-');
plot(allstats(:,1), 'g.-');
grid on;
axis([ 0 len+1 -65 -15 ]);
legend( 'maxL', 'minL', 'meanL', 'maxR', 'minR', 'meanR', 'Total', ...
        'Location', 'EastOutside' );
xlabel('database index');
ylabel('dB');
title(sprintf('Tail Energy%s',name));
end;

% vcen.m vs vcenf.m (after running vcen)
% Listen: less than a dB diff for all metrics except L&R mins and maxIID for
% database indices 1-12 (see high freqs)
% CIPIC: less than half dB for all metrics
if 0,
x = load('vcenf_cb_listen');
plot(allstats(:,1:11)-x.allstats(:,1:11));
grid on;
legend('t','l','l','l','r','r','r','d','d','d','i');
end;
