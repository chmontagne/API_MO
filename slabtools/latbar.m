% latbar - latency bar graph

% modification history
% --------------------
% 06.28.03  JDM  created
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

OBSb = 4096;            % bytes
WBSb = 512;             % bytes
OBS = (OBSb/4)/44.1;    % ms
WBS = (WBSb/4)/44.1;    % ms
TUP = 1000/120;         % ms

tmin = 0.0 + 3.5 + 1.5 + 0.4 + OBS - WBS + 2.1;
tmax = TUP + 3.5 + 1.5 + 0.5 + OBS + 2.1;

l = [ 0.0, 3.5, 1.5, 0.4, OBS - WBS, 2.1; ...
      TUP, 3.5, 1.5, 0.5, OBS, 2.1 ];

barh( [ tmin, tmax ], l, .5, 'stacked' );
figure(gcf);
h=gca;
set( h, 'YTick', [ tmin, tmax ] );
set( h, 'YLim', [ tmin-16, tmax+16 ] );
set( h, 'YTickLabel', [ sprintf('%4.1f',tmin); ...
                        sprintf('%4.1f',tmax) ] );
xlabel('time (ms)');
ylabel('end-to-end latency (tmin,tmax) (ms)');
title( sprintf( 'Latency (TUP = %4.1fms, OBS = %4.1fms, WBS = %3.1fms)', ...
                TUP, OBS, WBS ) );

% "help graph3d" to see available colormaps
colormap( 1 - jet );
brighten( .5 );
