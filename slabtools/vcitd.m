% vcitd - verify HRTF database collection ITDs.
%
% vcitd calls vitd() for all SLHs found in the current dir.  Metrics are
% generated and three summary figures are displayed at the end.
%
% Behavior flags exist at beginning of script.
%
% See also: vitd, cipic2slab, listen2slab, sarc

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.09.11  JDM  created
%                ----  v6.6.1  ----
% 01.20.12  JDM  detect CIPIC&Listen, set sld
% 04.10.12  JDM  added maxdis and PNG print
%                ----  v6.7.1  ----
% 12.28.12  JDM  stats and thresholds, outliers
% 01.17.13  JDM  added suspects and highlight vars, stem symbols,
%                best 2/3 thresholds figure
% 02.08.13  JDM  added asym and dis max/mean comparison
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

%clear all;
%close all;

% ----  behavior flags  ----
bPause = 1;     % pause after each ITD curve displayed
bPrint = 0;     % print PNG plot files
bBounds = 1;    % display means and error bounds on Mag and Thresh plots
highlight = 0;  % highlight suspects with vertical line

% vitd() stat names
names = [ 'max  '; 'min  '; 'bias '; 'ndif '; 'dif  '; 'mag  '; 'under'; ...
          'over '; 'dis  '; 'shift'; 'masym'; 'mdis '; 'dbias'; 'asym ' ];

% find SLH HRTF databases
d = dir('*.slh');
%d = dir('subject_*.slh');  % verify CIPIC
%d = dir('IRC_*.slh');  % verify Listen

% to view one database (see sld below):
% vitd(slab2sarc('IRC_1014.slh'),[],[],0,'b.-',1,1,1,sld);

if isempty(d)
  disp('vcitd error - no SLH HRTF databases found!');
  return;
end;

% vitd()'s spherical reference is from sitd():
%   itd = sitd( az, el, hr, sld )
%   hr  - head radius, m (default 0.09m)
%   sld - source-listener distance, m (default 0.9m)
%
% sld differs for ACD, CIPIC, and Listen (see below).
%
% !!!! Note re hr: morphological data presently not used.
% The greatest impact is on dif and ndif.

% examine SLH prefix to determine collection (if any)
%   CIPIC   subject_*.slh
%   Listen  IRC_*.slh
slhPre = d(1).name(1:3);
len = length(d);  % #databases in collection
if strcmp(slhPre,'sub')  % CIPIC collection
  sld = 1.0;
  name = 'CIPIC';
  lcName = 'cipic';
  n = 1:len;  % no outliers for pass 1
  % omit outliers from pass 1:  6 9
  %n = [ 1:5 7 8 10:len ];  % pass 2
elseif strcmp(slhPre,'IRC')  % Listen collection
  sld = 1.9;
  name = 'Listen';
  lcName = 'listen';
  n = 1:len;  % no outliers for pass 1
  % omit outliers from pass 1:  28
  %n = [ 1:27 29:len ];  % pass 2
elseif strcmp(slhPre,'jdm')  % slab3d
  sld = 1.0;
  name = 'Slab3d';
  lcName = 'slab3d';
  n = 1:len;  % no outliers assumed
else  % ACD HeadZap or other
  sld = 0.9;
  name = 'Other';
  lcName = 'other';
  n = 1:len;  % no outliers assumed
end;

suspects = setdiff(1:len,n);

itdstats = [];
for k = 1:length(d),
  h = slab2sarc( d(k).name );
  % view all ITDs simultaneously
  fprintf('%2d ',k);
  % display ITDs, one EL AZ-ring after the other, top to bottom
  stats = vitd(h,[],[],0,'b.-',1,1,1,sld);
  %stats = vitd(h,[],[],0,'b.-',0,1,1,sld);  % no bottom plot

  % ITD/energy metric cross-validation
  if 0,
  switch h.name(1:8)
    case 'IRC_1054'  % good shift/dbias metrics
      print(gcf,'-dpng','vcitd_irc_1054_good_itd.png');
    case 'IRC_1059'  % bad shift (yaw error)
      print(gcf,'-dpng','vcitd_irc_1059_shift7.5.png');
    case 'IRC_1013'  % bad dbias (y/interaural axis error if not diagonal,
                     %            roll if diagonal)
      print(gcf,'-dpng','vcitd_irc_1013_dbias73.8.png');
  end;      
  end;

  itdstats = [ itdstats; [stats k] ];
  if bPause,
    pause;
  end;
end;

% ----  plot itdstats  ----

% itdstats:
%
% 1    2    3     4     5    6    7      8     9    10     11     12    13
% max  min  bias  ndif  dif  mag  under  over  dis  shift  masym  mdis  dbias
% 14
% asym
%
% color order:  blue, green, red, cyan, magenta, yellow, black
%
% Note: ndif and masym tend to follow one another and both reflect bias, dis,
% and shift.  So, there is a fair amount of metric overlap.

% ----  plot 1 - ITD Magnitude Metrics  ----

% magnitude/expected-mean/use-outliers metrics
figure;
itdstats1 = itdstats(:,[1 2 8 7]);
itdstats1(:,1) =  itdstats1(:,1)-400;  % max ITD
itdstats1(:,2) = -itdstats1(:,2)-400;  % min ITD
itdstats1(:,4) = -itdstats1(:,4);      % under
hh = plot(itdstats1,'.-');
grid on;
axis([ 0 len+1 0 400 ]);
legend( 'max-400', '-min-400', 'over', 'under', ...
        'Location', 'NorthEastOutside' );
xlabel('database index');
ylabel('us');
title(['ITD Magnitude Metrics - ' name]);

% show mean and std dev bounds (color can be a name, e.g., 'red');
if bBounds,
  % left and right hemispheres should yield similar ITD max/mins
  %bound([itdstats1(n,1); itdstats1(n,2)],get(hh(1),'Color'),3,len);
  bound(itdstats1(n,1),get(hh(1),'Color'),3,len);
  bound(itdstats1(n,2),get(hh(2),'Color'),3,len);
  bound(itdstats1(n,3),get(hh(3),'Color'),3,len);
  bound(itdstats1(n,4),get(hh(4),'Color'),3,len);
end;

% highlight suspects with vertical line
if highlight,
  for s=suspects,hl=line([s s],[-1 401]);set(hl,'Color',0.7*ones(1,3)),end;
end;

if bPrint,
  % !!!! PRINT() BETTER FOR DOCS!
  % saving from figure window results in smaller text
  print(gcf,'-dpng',['vcitd_plot1_' lcName ]);
end;

% numerical stat summary
nn = [1 2 8 7];
mm = mean(itdstats(n,nn));
ss = std(itdstats(n,nn));
fprintf('\n');
fprintf('           max     min     over    under  (all us)\n');
fprintf('max:     %6.1f  %6.1f  %6.1f  %6.1f\n',max(itdstats(n,nn)));
fprintf('min:     %6.1f  %6.1f  %6.1f  %6.1f\n',min(itdstats(n,nn)));
fprintf('mean:    %6.1f  %6.1f  %6.1f  %6.1f\n',mm);
fprintf('median:  %6.1f  %6.1f  %6.1f  %6.1f\n',median(itdstats(n,nn)));
fprintf('stddev:  %6.1f  %6.1f  %6.1f  %6.1f\n',ss);
fprintf('mn+3sd:  %6.1f  %6.1f  %6.1f  %6.1f\n',mm + 3*ss);
fprintf('mn-3sd:  %6.1f  %6.1f  %6.1f  %6.1f\n',mm - 3*ss);

% find and print outliers
out = [];
for k=1:length(nn),
  fprintf('\n');
  fprintf('%s  over   %8.3f:  ', names(nn(k),:), mm(k)+3*ss(k));
  ff = find( itdstats(:,nn(k)) > mm(k) + 3*ss(k) );
  out = [ out; ff ];
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
  fprintf('\n');
  fprintf('       under  %8.3f:  ', mm(k)-3*ss(k));
  ff = find( itdstats(:,nn(k)) < mm(k) - 3*ss(k) );
  out = [ out; ff ];
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
end;
fprintf('\n');

% ----  plot 2 - ITD Threshold Metrics  ----

% want-near-zero/threshold metrics
figure;
itdstats(:,10) = abs(itdstats(:,10));   % abs(shift)
itdstats2 = itdstats(:,[10 13 11 12]);  % abs(shift), dbias, masym, mdis
itdstats2(:,1) = 10*itdstats2(:,1);     % 10*abs(shift)
%h2 = plot(itdstats2,'.-');
%h2 = stem(itdstats2);
h2 = [];
h2(1) = stem(itdstats2(:,1),'bo');  % 10*abs(shift)
hold on;
h2(2) = stem(itdstats2(:,2),'cd');  % dbias
h2(3) = stem(itdstats2(:,3),'k^');  % masym
h2(4) = stem(itdstats2(:,4),'rs');  % mdis
grid on;
axis([ 0 len+1 0 200 ]);
legend( 'shift*10', 'dbias', 'masym', 'mdis', ...
        'Location', 'NorthEastOutside' );
xlabel('database index');
ylabel('deg,us,us/deg');
title(['ITD Threshold Metrics - ' name]);

% show mean and std dev bounds
if bBounds,
  bound(itdstats2(n,1),get(h2(1),'Color'),3,len,0);
  bound(itdstats2(n,2),get(h2(2),'Color'),3,len,0);
  bound(itdstats2(n,3),get(h2(3),'Color'),3,len,0);
  bound(itdstats2(n,4),get(h2(4),'Color'),3,len,0);
end;

% highlight suspects with vertical line
if highlight,
  for s=suspects,hl=line([s s],[-1 201]);set(hl,'Color',0.7*ones(1,3)),end;
end;

if bPrint,
  print(gcf,'-dpng',['vcitd_plot2_' lcName ]);
end;

% numerical stat summary
nn = [10 13 11 12];
mm = mean(itdstats(n,nn));
ss = std(itdstats(n,nn));
fprintf('\n');
fprintf('           shift   dbias   masym   mdis\n');
fprintf('           degs    us      us      us/deg\n');
fprintf('max:     %6.1f  %6.1f  %6.1f  %6.1f\n',max(itdstats(n,nn)));
fprintf('min:     %6.1f  %6.1f  %6.1f  %6.1f\n',min(itdstats(n,nn)));
fprintf('mean:    %6.1f  %6.1f  %6.1f  %6.1f\n',mm);
fprintf('median:  %6.1f  %6.1f  %6.1f  %6.1f\n',median(itdstats(n,nn)));
fprintf('stddev:  %6.1f  %6.1f  %6.1f  %6.1f\n',ss);
fprintf('mn+3sd:  %6.1f  %6.1f  %6.1f  %6.1f\n',mm + 3*ss);
fprintf('mn-3sd:  %6.1f  %6.1f  %6.1f  %6.1f\n',mm - 3*ss);

% find and print outliers
for k=1:length(nn),
  fprintf('\n');
  fprintf('%s  over   %8.3f:  ', names(nn(k),:), mm(k)+3*ss(k));
  ff = find( itdstats(:,nn(k)) > mm(k) + 3*ss(k) );
  out = [ out; ff ];
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
  fprintf('\n');
  fprintf('       *under %8.3f:  ', mm(k)-3*ss(k));
  ff = find( itdstats(:,nn(k)) < mm(k) - 3*ss(k) );
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
end;
fprintf('\n');

% compare asym and dis metric maxes and means
if 0,
figure;
plot(1:len,itdstats(:,11),'b.-', 1:len,3*itdstats(:,14),'g.-', ...
     1:len,itdstats(:,12),'r.-', 1:len,6*itdstats(:, 9),'c.-');
axis([ 0 len+1 0 200 ]);
grid on;
legend('masym','3*asym','mdis','6*dis');
xlabel('database index');
ylabel('us');
title(['asym and dis max/mean comparison - ' name]);
print(gcf,'-dpng',['vcitd_asymdis_' lcName ]);
end;

% ----  plot 3 - ITD Error  ----

% stacked bar graph, anomaly rating, rough "quality" measure;
% higher values -> higher likelihood of anomaly
% lower values -> higher quality
figure;
itdstats3 = itdstats(:,[10 13 11 12]);
itdstats3(:,1) = abs(itdstats3(:,1))*10;
itdstats3(:,3) = (itdstats3(:,3)-min(itdstats3(:,3)));
itdstats3(:,4) = (itdstats3(:,4)-min(itdstats3(:,4)));
bar(itdstats3,'stacked');
axis([ 0 len+1 0 200 ]);
grid on;
legend( 'shift*10', 'dbias', 'masym-min', 'mdis-min', ...
        'Location', 'NorthEastOutside' );
xlabel('database index');
ylabel('deg,us,us/deg');
title(['ITD Error - ' name]);

% highlight suspects with vertical line
if highlight,
  for s=suspects,hl=line([s s],[-1 201]);set(hl,'Color',0.7*ones(1,3)),end;
end;

if bPrint,
  print(gcf,'-dpng',['vcitd_plot3_' lcName ]);
end;

%---------------------------------------

% unique outliers from all plots and metrics
fprintf('\n\nOutliers:  ');
fprintf('%d ', unique(out));
fprintf('\n\n');

% vars needed by ithresh.m
if strcmp(name, 'Listen'),
  threshL = itdstats(:,[10 13 11 12]);  % shift dbias masym mdis
elseif strcmp(name, 'CIPIC'),
  threshC = itdstats(:,[10 13 11 12]);
end;
