% latmc - monte carlo latency analysis

% modification history
% --------------------
% 01.17.03  JDM  created
% 07.16.03  JDM  removed 0.9 delay line latency
%                ----  v6.7.3  ----
% 12.02.13  JDM  added to slabtools
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

% tracker update period (ms)
TUP = 1000/120;

% output buffer size (ms)
OBS = (4096/4)/44.1;

% write buffer size (ms)
WBS = (512/4)/44.1;

% monte carlo trials
N = 100000;

fprintf( 'TUP = %3.1f, OBS = %4.1f, WBS = %3.1f, N = %d\n', TUP, OBS, WBS, N );

% monte carlo latency
mc = TUP * rand(N,1) + 3.5 + 1.5 + 0.45 + OBS - WBS*rand(N,1) + 2.1;

[n,x] = hist( mc, 11 );
bar( x, n );
figure(gcf);
h=gca;
set(h,'XTick',x);
set(h,'XLim',[min(x)-1,max(x)+1]);

xl=[];
for i=1:length(x), xl = [ xl; sprintf( '%4.1f', x(i) ) ]; end;
set( h, 'XTickLabel', xl );

xlabel('latency (ms)');
ylabel('bin N');
title(sprintf('Monte Carlo Latency Histogram (N = %d)',N));
colormap( jet );

tmin = 0.0 + 3.5 + 1.5 + 0.4 + OBS - WBS + 2.1;
tmax = (1000/120) + 3.5 + 1.5 + 0.5 + OBS + 2.1;
tavg = (tmin + tmax) / 2;
mmin = min(mc);
mmax = max(mc);
mavg = mean(mc);
fprintf( 'tmin = %4.1f, tmax = %4.1f, tavg = %4.1f\n', tmin, tmax, tavg );
fprintf( 'mmin = %4.1f, mmax = %4.1f, mavg = %4.1f\n', mmin, mmax, mavg );
