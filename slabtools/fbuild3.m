% fbuild3.m - build an HRTF database submission using the Club Fritz format.
%
% Run from C:\nasa\amat\cf\acd3.
%
% See also: fload3.m, fview.m

% modification history
% --------------------
%                ----  v6.0.0  ----
% 01.11.07  JDM  created from fbuild2.m for ACD submission acd3
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

% All IRs appeared to be negated when measured.  They are corrected below.

% ----  raw HRTF data  ----

% sarc, raw, neumann
srn = sload( 'C:\nasa\amat\hrtf03\fritz010907am' );

% make a Club Fritz HRIR struct to work with
n = size(srn.dgrid,2);  % number of responses
frn = fmake( 'Fritz', 'ACD HeadZap', srn.fs, ...
             -srn.ir(:,1:n), -srn.ir(:,n+1:end), srn.dgrid, 0.9, 'polar', ...
             'measured 1/9/07 by JDM, Fritz Neumann KU-100 mics' );

% verify L,R:
figure;
i = 116;  % frn.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frn.hrir_l(:,i),'b',1:1024,frn.hrir_r(:,i),'r');
title( sprintf('frn az = %d, el = %d',frn.hgrid(2,i),frn.hgrid(1,i)) );

% recorded level:
fprintf( 'frn max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frn.hrir_l))), max(max(abs(frn.hrir_r))) );
% 0.1256,  0.1191

% save the Club Fritz HRIR struct to a MATLAB .mat;
% acd = lab, 1 = submission 1, r = raw data
fsave( frn, 'acd1r' );

% ----  raw HRTF data (repeat 1)  ----

% sarc, raw, neumann
srn = sload( 'C:\nasa\amat\hrtf03\fritz010907bm' );

% make a Club Fritz HRIR struct to work with
n = size(srn.dgrid,2);  % number of responses
frn = fmake( 'Fritz', 'ACD HeadZap', srn.fs, ...
             -srn.ir(:,1:n), -srn.ir(:,n+1:end), srn.dgrid, 0.9, 'polar', ...
             'repeat 1, measured 1/9/07 by JDM, Fritz Neumann KU-100 mics' );

% verify L,R:
figure;
i = 116;  % frn.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frn.hrir_l(:,i),'b',1:1024,frn.hrir_r(:,i),'r');
title( sprintf('frn az = %d, el = %d',frn.hgrid(2,i),frn.hgrid(1,i)) );

% recorded level:
fprintf( 'frn max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frn.hrir_l))), max(max(abs(frn.hrir_r))) );
% 0.1273,  0.1205

% save the Club Fritz HRIR struct to a MATLAB .mat
fsave( frn, 'acd2r' );

% ----  raw HRTF data (repeat 2)  ----

% sarc, raw, neumann
srn = sload( 'C:\nasa\amat\hrtf03\fritz011107m' );

% make a Club Fritz HRIR struct to work with
n = size(srn.dgrid,2);  % number of responses
frn = fmake( 'Fritz', 'ACD HeadZap', srn.fs, ...
             -srn.ir(:,1:n), -srn.ir(:,n+1:end), srn.dgrid, 0.9, 'polar', ...
             'repeat 2, measured 1/11/07 by JDM, Fritz Neumann KU-100 mics' );

% verify L,R:
figure;
i = 116;  % frn.hgrid(:,116) == [ 0; 90 ] == [ el; az ]
plot(1:1024,frn.hrir_l(:,i),'b',1:1024,frn.hrir_r(:,i),'r');
title( sprintf('frn az = %d, el = %d',frn.hgrid(2,i),frn.hgrid(1,i)) );

% recorded level:
fprintf( 'frn max L,R = %7.4f, %7.4f\n', ...
         max(max(abs(frn.hrir_l))), max(max(abs(frn.hrir_r))) );
% 0.1290,  0.1207

% save the Club Fritz HRIR struct to a MATLAB .mat
fsave( frn, 'acd3r' );
