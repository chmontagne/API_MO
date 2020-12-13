% 5-sine SOS pitch and roll disturbance model

%function [dp,dr]=dist(phases,t,bNoOut)
% [ dp, dr ] = dist( phases, t, bNoOut )

% comment-out function above when using standAlone
standAlone = 1;

% modification history
% --------------------
%                ----  v6.6.1  ----
% 10.18.11  JDM  created from PFD version dated 9/10/09
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

if standAlone,
  t = 0:0.1:300;  % seconds
end;

if nargin < 3,
  bNoOut = false;
end;

% ----  SOS parameters  ----

% fundamental frequency = 0.012 Hz
% w = 2*pi * f
ffun = 2*pi * 0.012;

% frequencies chosen from prime number harmonics;
% number of harmonics (including fundamental) = 5

% primes:
% 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61,
% 67, 71, 73, 79, 83, 89, 97, 101

if 0,
h2 = 2;
h3 = 3;
h4 = 5;
h5 = 7;

h2 = 5;
h3 = 7;
h4 = 11;
h5 = 13;
end;

% harmonics selected
h2 = 3;
h3 = 5;
h4 = 7;
h5 = 11;

% gains are scaled by the inverse of the harmonic number,
% e.g., 1, 1/3, 1/5, 1/7, 1/11

% normalize summed gain to -1 to +1
gfun = 1/(1 + 1/h2 + 1/h3 + 1/h4 + 1/h5);

% ----  pitch  ----

gp1 = gfun;
fp1 = ffun;

gp2 = gp1 / h2;
fp2 = fp1 * h2;

gp3 = gp1 / h3;
fp3 = fp1 * h3;

gp4 = gp1 / h4;
fp4 = fp1 * h4;

gp5 = gp1 / h5;
fp5 = fp1 * h5;

% the phase of each sine is randomized at the beginning of each block
if standAlone,
  pp1 = 2*pi*rand();
  pp2 = 2*pi*rand();
  pp3 = 2*pi*rand();
  pp4 = 2*pi*rand();
  pp5 = 2*pi*rand();
else,
  pp1 = phases(1);
  pp2 = phases(2);
  pp3 = phases(3);
  pp4 = phases(4);
  pp5 = phases(5);
end;

dp = gp1*sin( fp1*t+pp1 ) + gp2*sin( fp2*t+pp2 ) + gp3*sin( fp3*t+pp3 ) + ...
     gp4*sin( fp4*t+pp4 ) + gp5*sin( fp5*t+pp5 );

% ----  roll  ----

gr1 = gfun;
fr1 = ffun;

gr2 = gr1 / h2;
fr2 = fr1 * h2;

gr3 = gr1 / h3;
fr3 = fr1 * h3;

gr4 = gr1 / h4;
fr4 = fr1 * h4;

gr5 = gr1 / h5;
fr5 = fr1 * h5;

if standAlone,
  pr1 = 2*pi*rand();
  pr2 = 2*pi*rand();
  pr3 = 2*pi*rand();
  pr4 = 2*pi*rand();
  pr5 = 2*pi*rand();
else,
  pr1 = phases(6);
  pr2 = phases(7);
  pr3 = phases(8);
  pr4 = phases(9);
  pr5 = phases(10);
end;

dr = gr1*sin( fr1*t+pr1 ) + gr2*sin( fr2*t+pr2 ) + gr3*sin( fr3*t+pr3 ) + ...
     gr4*sin( fr4*t+pr4 ) + gr5*sin( fr5*t+pr5 );

% ----  display  ----

if standAlone,
  figure(gcf);
  plot(t,dp,'b',t,dr,'r');
  axis([0 t(end) -1 1]);
  grid on;
  xlabel( 'seconds' );
  ylabel( 'amplitude' );
  title( 'SOS' );
  legend( 'pitch', 'roll' );
end;

if ~bNoOut,

fprintf( '\n5 sines\n3 SOS params g,f,p: g*sin(f*t+p), f in rads/s, p in rads\n' );
fprintf( '\npitch:\n' );
[ [gp1 fp1 pp1]; [gp2 fp2 pp2]; [gp3 fp3 pp3]; [gp4 fp4 pp4]; [gp5 fp5 pp5] ]
fprintf( 'roll:\n' );
[ [gr1 fr1 pr1]; [gr2 fr2 pr2]; [gr3 fr3 pr3]; [gr4 fr4 pr4]; [gr5 fr5 pr5] ]

fprintf( 'Max pitch SOS freq = %5.3f Hz\n', fp5/(2*pi) );
fprintf( 'Max roll  SOS freq = %5.3f Hz\n\n', fr5/(2*pi) );

fprintf( 'Pitch SOS max = %4.2f, min = %4.2f\n', max(dp), min(dp) );
fprintf( 'Roll  SOS max = %4.2f, min = %4.2f\n\n', max(dr), min(dr) );

end;
