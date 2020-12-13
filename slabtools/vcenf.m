% vcenf - verify HRTF database collection energy using freq-domain metrics.
%
% vcenf() calls hcom() for all SLHs found in current dir.
% hcom() params are set in source code.
% A table of metrics is generated and summary plots displayed.
% This script is used for metrics, vcen.m is used for visualization.
%
% Behavior flags exist at beginning of script.
%
% See also: vcen, hcom, cipic2slab, listen2slab, sarc

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.09.11  JDM  created
%                ----  v6.7.1  ----
% 01.02.13  JDM  added stat prints and bounds, outliers
% 01.11.13  JDM  added minThresh
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
cipic = 0;      % cipic 1, listen 0
mat = 0;        % use pre-processed MAT file
cb = 0;         % use hcom() critical band option
highlight = 0;  % highlight suspects with vertical line
bBounds = 1;    % display SD bounds
bPrint = 0;     % save plots as PNGs
bOverride = 0;  % override thresholds

% hcom() stat names
names = [ 'total'; 'maxL '; 'minL '; 'meanL'; 'maxR '; 'minR '; 'meanR'; ...
          'maxD '; 'minD '; 'meanD'; 'maxID'; 'maxF '; 'minF '; 'meanF'; ...
          'maxE '; 'minE '; 'meanE' ];

% ----  generate metrics  ----
if mat,
  if cipic,
    load vcenf_cb_cipic.2012.04.18.mat
  else
    load vcenf_cb_listen.2012.04.18.mat
  end;
else
  d = dir('*.slh');
  allstats = [];
  for k = 1:length(d),
    h = slab2sarc( d(k).name );
    fprintf('%2d ',k);
    stats = hcom( h, [], 'l', -1, -1, 0, 0, 0, 0, cb, 1 );
    allstats = [ allstats; stats ];
  end;
end;

% tailor to database collection
len = size(allstats,1);
if cipic,
  name = 'CIPIC';
  lcName = 'cipic';
  %suspects = [9];  % visual suspects

  n = 1:len;  % no outliers for pass 1
  % omit outliers from pass 1:    3 6      19       23 34    44
  %n = [ 1 2 4 5 7:18 20:22 24:33 35:43 45 ];                       % pass 2
  % omit outliers from pass 2:    3 6   11 19       23 34 42 44
  %n = [ 1 2 4 5 7:10 12:18 20:22 24:33 35:41 43 45 ];             % pass 3

  % omit ITD rejects
  % ITD kept (none are energy outliers)
  %n = [ 1     5     8    12    14    21    24    28    31    32 ...
  %     37    40    45 ];  % pass 1
  % outliers from pass 1:  2 3 6 7 10 11 19 20 22 23 26 27 34 42 44
  % (all alredy omitted)

  % applying Listen thresholds to CIPIC (above n for pass 1, see if0s in code)
  % omit outliers from pass 1:
  %   1  2  3  4  6  7  8  9  10 11 14 17 18 19 20 21 22 23 24 25
  %   26 27 30 31 33 34 36 37 42 43 44
  %n = [       5          12                      28          32 ...
  %           40    45 ];  % pass 2
  % outliers the same as pass 1

  suspects = setdiff(1:len,n);
else
  name = 'Listen';
  lcName = 'listen';
  %suspects = [13 20 25 28 43];  % visual suspects

  n = 1:len;  % no outliers for pass 1
  % omit outliers from pass 1:     28
  %n = [ 1:27 29:51 ];                       % pass 2
  % omit outliers from pass 2:     28 43
  %n = [ 1:27 29:42 44:51 ];                 % pass 3
  % omit outliers from pass 3:  25 28 43
  %n = [ 1:24 26:27 29:42 44:51 ];           % pass 4
  % outliers from pass 4:  25 28 43 (all already omitted)

  % omit ITD rejects
  % ITD kept:
  %    [ 1     2     3     4     6     9    11    14    16    17 ...
  %     18    20    21    22    25    30    33    34    35    36 ...
  %     39    40    42    43    44    46    48    50 ];
  % of ITD kept, 25 and 43 are energy outliers
  %n = [ 1     2     3     4     6     9    11    14    16    17 ...
  %     18    20    21    22          30    33    34    35    36 ...
  %     39    40    42          44    46    48    50 ];  % pass 1
  % omit outliers from pass 1:  20 24 25 28 38 43 (only 20 is new)
  %n = [ 1     2     3     4     6     9    11    14    16    17 ...
  %     18          21    22          30    33    34    35    36 ...
  %     39    40    42          44    46    48    50 ];  % pass 2
  % outliers from pass 2:  5 13 20 24 25 28 38 43 45 (all alredy omitted)

  suspects = setdiff(1:len,n);
end;

% ----  plot 1  ----

% plot metrics
figure;
hh1 = plot(allstats(:,[2 3 4]), 'b.-');
hold on;
hh2 = plot(allstats(:,[5 6 7]), 'r.-');
hh3 = plot(allstats(:,1), 'g.-');
hh4 = plot(allstats(:,11), 'k.-');
grid on;
axis([ 0 len+1 -30 30 ]);
legend( 'maxL', 'minL', 'meanL', 'maxR', 'minR', 'meanR', 'total', 'maxID', ...
        'Location', 'NorthEastOutside' );
xlabel('database index');
ylabel('dB');
title(['Energy Magnitude Metrics - ' name]);

% display mean and 3SD bounds as horizontal lines
if bBounds,
  bound(allstats(n,2),get(hh1(1),'Color'),3,len);  % maxL
  bound(allstats(n,3),get(hh1(2),'Color'),3,len);  % minL
  bound(allstats(n,4),get(hh1(3),'Color'),3,len);  % meanL
  bound(allstats(n,5),get(hh2(1),'Color'),3,len);  % maxR
  bound(allstats(n,6),get(hh2(2),'Color'),3,len);  % minR
  bound(allstats(n,7),get(hh2(3),'Color'),3,len);  % meanR
  bound(allstats(n,1),get(hh3,'Color'),3,len);     % Total
  bound(allstats(n,11),get(hh4,'Color'),3,len);    % mIID
end;
% can analyze L/R together (max, min, mean) assuming head symmetry
if bBounds,
  bound([allstats(n,2); allstats(n,5)],get(hh1(1),'Color'),3,len);  % max
  bound([allstats(n,3); allstats(n,6)],get(hh1(2),'Color'),3,len);  % min
  bound([allstats(n,4); allstats(n,7)],get(hh1(3),'Color'),3,len);  % mean
  bound(allstats(n,1),get(hh3,'Color'),3,len);      % Total
  bound(allstats(n,11),get(hh4,'Color'),3,len);     % mIID
end;

% highlight suspects with vertical line
if highlight,
  for s=suspects,hl=line([s s],[-31 31]);set(hl,'Color',0.7*ones(1,3)),end;
end;

if bPrint,
  print(gcf,'-dpng',['vcenf_plot1_' lcName ]);
end;

% numerical stat summary
nn = [ 2 3 4 5 6 7 1 11 ];
mm = mean(allstats(n,nn));
ss = std(allstats(n,nn));
fprintf('\n');
fprintf('           maxL    minL   meanL    maxR    minR   meanR   total   maxID\n');
fprintf('max:     %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f\n', ...
        max(allstats(n,nn)));
fprintf('min:     %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f\n', ...
        min(allstats(n,nn)));
fprintf('mean:    %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f\n', ...
        mm);
fprintf('median:  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f\n', ...
        median(allstats(n,nn)));
fprintf('stddev:  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f\n', ...
        ss);
fprintf('mn+3sd:  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f\n', ...
        mm + 3*ss);
fprintf('mn-3sd:  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f  %6.1f\n', ...
        mm - 3*ss);

% find and print outliers
out = [];
for k=1:length(nn),
  fprintf('\n');
  fprintf('%s  over  %8.3f:  ', names(nn(k),:), mm(k)+3*ss(k));
  ff = find( allstats(:,nn(k)) > mm(k) + 3*ss(k) );
  out = [ out; ff ];
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
  fprintf('\n');
  fprintf('       under %8.3f:  ', mm(k)-3*ss(k));
  ff = find( allstats(:,nn(k)) < mm(k) - 3*ss(k) );
  out = [ out; ff ];
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
end;
fprintf('\n');

% ----  plot 2  ----

% plot metrics
figure;
allstats(:,8:10) = abs(allstats(:,8:10));
hh1 = plot(allstats(:,8), 'r.-');
hold on;
hh2 = plot(allstats(:,9), 'b.-');
hh3 = plot(allstats(:,10), 'g.-');
grid on;
axis([ 0 len+1 0 6 ]);
legend( 'maxD', 'minD', 'meanD', 'Location', 'NorthEastOutside' );
xlabel('database index');
ylabel('dB');
title(['Energy Global Asymmetry Threshold Metrics - ' name]);

% display mean and 3SD bounds as horizontal lines
if bBounds,
  bound(allstats(n,8),get(hh1,'Color'),3,len,0);   % maxD
  bound(allstats(n,9),get(hh2,'Color'),3,len,0);   % minD
  bound(allstats(n,10),get(hh3,'Color'),3,len,0);  % meanD
end;

% highlight suspects with vertical line
if highlight,
  for s=suspects,hl=line([s s],[-1 7]);set(hl,'Color',0.7*ones(1,3)),end;
end;

if bPrint,
  print(gcf,'-dpng',['vcenf_plot2_' lcName ]);
end;

% numerical stat summary
nn = [ 8 9 10 ];
mm = mean(allstats(n,nn));
ss = std(allstats(n,nn));
fprintf('\n');
fprintf('           maxD    minD   meanD\n');
fprintf('max:     %6.1f  %6.1f  %6.1f\n', max(allstats(n,nn)));
fprintf('min:     %6.1f  %6.1f  %6.1f\n', min(allstats(n,nn)));
fprintf('mean:    %6.1f  %6.1f  %6.1f\n', mm);
fprintf('median:  %6.1f  %6.1f  %6.1f\n', median(allstats(n,nn)));
fprintf('stddev:  %6.1f  %6.1f  %6.1f\n', ss);
fprintf('mn+3sd:  %6.1f  %6.1f  %6.1f\n', mm + 3*ss);
fprintf('mn-3sd:  %6.1f  %6.1f  %6.1f\n', mm - 3*ss);

% minimum threshold
minThresh = 1;               % dB
tt2 = mm + 3*ss;             % thresholds, dB
ti = find(tt2 < minThresh);  % thresholds under minThresh
tt2(ti) = minThresh;         % override low thresholds
if ~isempty(ti),
  fprintf('\nThresholds set to %.1f dB:\n', minThresh);
  names(nn(ti),:)
end;

% override thresholds with min CIPIC/Listen thresholds
%tt2
if bOverride,
% from workspace after ITD rejects removed
tt2C = [ 3.1767    1.6895    2.4794 ];  % pass 1 overriden with Listen
%        1.5299    1.1788    1.3346     % pass 2 after using Listen below
tt2L = [ 1.3746    1.0000    1.0000 ];
tt2min = min([tt2C;tt2L]);
tt2
tt2min
tt2 = tt2min;
end;

% find and print outliers
for k=1:length(nn),
  fprintf('\n');
  fprintf('%s  over   %8.3f:  ', names(nn(k),:), tt2(k));
  ff = find( allstats(:,nn(k)) > tt2(k) );
  out = [ out; ff ];
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
  fprintf('\n');
  fprintf('       *under %8.3f:  ', mm(k)-3*ss(k));
  ff = find( allstats(:,nn(k)) < mm(k) - 3*ss(k) );
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
end;
fprintf('\n');

% ----  plot 3  ----

% plot metrics
figure;
% L/R freq band RMS energy differences
hh1 = plot(allstats(:,12),'r.-');
hold on;
hh2 = plot(allstats(:,13), 'b.-');
hh3 = plot(allstats(:,14), 'g.-');
% L/R energy differences
hh4 = plot(allstats(:,15),'m.-');
hh5 = plot(allstats(:,16), 'k.-');
hh6 = plot(allstats(:,17), 'c.-');
grid on;
axis([ 0 len+1 0 10 ]);
legend( 'maxF', 'minF', 'meanF', 'maxE', 'minE', 'meanE', ...
        'Location', 'NorthEastOutside' );
xlabel('database index');
ylabel('dB');
title(['Energy Local Asymmetry Threshold Metrics - ' name]);

% display mean and 3SD bounds as horizontal lines
if bBounds,
  bound(allstats(n,12),get(hh1,'Color'),3,len,0);  % maxR
  bound(allstats(n,13),get(hh2,'Color'),3,len,0);  % minR
  bound(allstats(n,14),get(hh3,'Color'),3,len,0);  % meanR
  bound(allstats(n,15),get(hh4,'Color'),3,len,0);  % maxD
  bound(allstats(n,16),get(hh5,'Color'),3,len,0);  % minD
  bound(allstats(n,17),get(hh6,'Color'),3,len,0);  % meanD
end;

% highlight suspects with vertical lines
if highlight,
  for s=suspects,hl=line([s s],[-1 11]);set(hl,'Color',0.7*ones(1,3)),end;
end;

if bPrint,
  print(gcf,'-dpng',['vcenf_plot3_' lcName ]);
end;

% numerical stat summary
nn = 12:17;
mm = mean(allstats(n,nn));
ss = std(allstats(n,nn));
fprintf('\n');
fprintf('           maxF    minF   meanF    maxE      minE   meanE\n');
fprintf('max:     %6.1f  %6.1f  %6.1f  %6.1f  %8.3f  %6.1f\n', ...
        max(allstats(n,nn)));
fprintf('min:     %6.1f  %6.1f  %6.1f  %6.1f  %8.3f  %6.1f\n', ...
        min(allstats(n,nn)));
fprintf('mean:    %6.1f  %6.1f  %6.1f  %6.1f  %8.3f  %6.1f\n', ...
        mm);
fprintf('median:  %6.1f  %6.1f  %6.1f  %6.1f  %8.3f  %6.1f\n', ...
        median(allstats(n,nn)));
fprintf('stddev:  %6.1f  %6.1f  %6.1f  %6.1f  %8.3f  %6.1f\n', ...
        ss);
fprintf('mn+3sd:  %6.1f  %6.1f  %6.1f  %6.1f  %8.3f  %6.1f\n', ...
        mm + 3*ss);
fprintf('mn-3sd:  %6.1f  %6.1f  %6.1f  %6.1f  %8.3f  %6.1f\n', ...
        mm - 3*ss);

% minimum threshold
minThresh = 1;               % dB
tt3 = mm + 3*ss;             % thresholds, dB
ti = find(tt3 < minThresh);  % thresholds under minThresh
tt3(ti) = minThresh;         % override low thresholds
if ~isempty(ti),
  fprintf('\nThresholds set to %.1f dB:\n', minThresh);
  names(nn(ti),:)
end;

% override thresholds with min CIPIC/Listen thresholds
%tt3
if bOverride,
% from workspace after ITD rejects removed
tt3C = [ 8.1795    1.3444    3.2995    6.3166    1.0000    2.3732 ]; % pass 1
%        7.5559    1.2077    2.7392    5.2714    1.0000    1.1771      pass 2
tt3L = [ 6.8308    1.0844    2.6853    5.9260    1.0000    1.5664 ];
tt3min = min([tt3C;tt3L]);
tt3
tt3min
tt3 = tt3min;
end;

% find and print outliers
for k=1:length(nn),
  fprintf('\n');
  fprintf('%s  over   %8.3f:  ', names(nn(k),:),tt3(k));
  ff = find( allstats(:,nn(k)) > tt3(k) );
  out = [ out; ff ];
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
  fprintf('\n');
  fprintf('       *under %8.3f:  ', mm(k)-3*ss(k));
  ff = find( allstats(:,nn(k)) < mm(k) - 3*ss(k) );
  if isempty(ff),
    ff = 0;
  end;
  fprintf('%d ', ff);
end;
fprintf('\n');

%---------------------------------------

% unique outliers from all plots and metrics
fprintf('\n\nOutliers:  ');
fprintf('%d ', unique(out));
fprintf('\n\n');

% to generate MAT files
if 0,
  if cipic,
    save vcenf_cb_cipic allstats
  else
    save vcenf_cb_listen allstats
  end;
end;
