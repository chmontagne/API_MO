% ithresh - ITD shift/dbias/asym/maxdis threshhold determination.
%
% ithresh determines ITD thresholds for the Listen and CIPIC HRTF
% database collections.  vcitd must be executed for each collection
% prior to executing ithresh.  ithresh uses variables left in the
% workspace by vcitd.
%
% See also: vcitd

% modification history
% --------------------
%                ----  v6.7.1  ----
% 01.18.13  JDM  created
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

% ----  determine CIPIC and Listen rejection thresholds  ----

% threshC and threshL are left in the workspace by vcitd.m after being run on
% CIPIC and Listen
threshAll = [ threshC; threshL ];   % shift dbias asym maxdis
nAll = size(threshAll,1);           % total # databases
nBest = nAll*(2/3);                 % select best X databases
sorted = sort(threshAll);           % sort low-to-high
sorted = sorted(1:nBest,:);         % lower values better
mm = mean(sorted);
ss = std(sorted);
tHigh = mm + 3*ss;  % The Thresholds
tLow  = mm - 3*ss;
fprintf('\nTotal:  %d  Using:  %d\n\n', nAll, nBest);
fprintf('           shift   dbias   asym    maxdis\n');
fprintf('           degs    us      us      us/deg\n');
fprintf('max:     %6.1f  %6.1f  %6.1f  %6.1f\n',max(sorted));
fprintf('min:     %6.1f  %6.1f  %6.1f  %6.1f\n',min(sorted));
fprintf('mean:    %6.1f  %6.1f  %6.1f  %6.1f\n',mm);
fprintf('median:  %6.1f  %6.1f  %6.1f  %6.1f\n',median(sorted));
fprintf('stddev:  %6.1f  %6.1f  %6.1f  %6.1f\n',ss);
fprintf('mn+3sd:  %6.1f  %6.1f  %6.1f  %6.1f  <<<<  THRESHOLDS\n',tHigh);
fprintf('mn-3sd:  %6.1f  %6.1f  %6.1f  %6.1f\n',tLow);

% determine Listen kept databases
shiftL  = find(threshL(:,1) < tHigh(1));
dbiasL  = find(threshL(:,2) < tHigh(2));
asymL   = find(threshL(:,3) < tHigh(3));
maxdisL = find(threshL(:,4) < tHigh(4));
intL = intersect(shiftL, dbiasL);
intL = intersect(intL, asymL);
intL = intersect(intL, maxdisL);

% determine CIPIC kept databases
shiftC  = find(threshC(:,1) < tHigh(1));
dbiasC  = find(threshC(:,2) < tHigh(2));
asymC   = find(threshC(:,3) < tHigh(3));
maxdisC = find(threshC(:,4) < tHigh(4));
intC = intersect(shiftC, dbiasC);
intC = intersect(intC, asymC);
intC = intersect(intC, maxdisC);

% #databases that passed each threshold
fprintf('keptL:       %2d      %2d      %2d      %2d  intersect:  %2d\n', ...
  length(shiftL), length(dbiasL), length(asymL), length(maxdisL), ...
  length(intL));
fprintf('keptC:       %2d      %2d      %2d      %2d  intersect:  %2d\n', ...
  length(shiftC), length(dbiasC), length(asymC), length(maxdisC), ...
  length(intC));

% display kept database
intL = intL';
intC = intC';
intL
intC

% plot Best 2/3 ITD Threshold Metrics
figure;
h2 = [];
h2(1) = stem(threshAll(:,1)*10,'bo');
hold on;
h2(2) = stem(threshAll(:,2),'cd');
h2(3) = stem(threshAll(:,3),'k^');
h2(4) = stem(threshAll(:,4),'rs');
grid on;
axis([ 0 nAll+1 0 200 ]);
legend( 'shift*10', 'dbias', 'asym', 'maxdis', ...
        'Location', 'NorthEastOutside' );
xlabel('CIPIC 1-45, Listen 46-96');
ylabel('deg,us,us/deg');
title('ITD Best 2/3 Thresholds');

% display means and thresholds
tHigh(1) = tHigh(1)*10;
for t = 1:4,
  hl = line( [ 1 nAll ], [ mm(t) mm(t) ] );
  set(hl,'Color',get(h2(t),'Color'));
  set(hl,'LineStyle','--');
  hl = line( [ 1 nAll ], [ tHigh(t) tHigh(t) ] );
  set(hl,'Color',get(h2(t),'Color'));
end;

% highlight suspects with vertical lines
suspects = setdiff(1:nAll,[ intC size(threshC,1)+intL ]);
for s = suspects,
  hl = line( [s s], [-1 201 ]);
  set(hl,'Color',0.7*ones(1,3));
end;

% save PNG
%print(gcf,'-dpng','vcitd_thresholds');
