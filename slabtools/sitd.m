function itd = sitd( az, el, hr, sld )
% sitd - compute spherical-head model ITD.
%
% itd = sitd( az, el, hr, sld )
%
% itd - ITD specified as a left or right ear lag relative to the opposite ear,
%       positive = lag left ear, negative = lag right ear, us
% az  - azimuth, degrees
% el  - elevation, degrees
% hr  - head radius, m (default 0.09m)
% sld - source-listener distance, m (default 0.9m)
%
% This function is based on a similar function from the course paper:
% Miller, Joel D., "Modeling Interaural Time Difference Assuming a Spherical
% Head", Music 150, Musical Acoustics, Stanford University, December 2, 2001.
% http://jdmiller.sonisphere.com/MUS150Paper.pdf
% The author has allowed this function to be included in the slab3d release.
%
% Note: sitdw.m was developed after this function.  sitd() is essentially a
%       subset of sitdw() (sitd() only supports the near field).
%
% See also: sitdw, sitds

%234567890 234567890 234567890 234567890 234567890 234567890 234567890 234567890

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

% modification history
% --------------------
%                ----  v5.8.1  ----
% 06.21.06  JDM  created from itdc.m (MUS150 final project script)
%                ----  v6.6.0  ----
% 03.04.11  JDM  bug fix: param defaults (hr was overwritten when using three
%                params); sld < hr now error; measurement radii comparison
%                ----  v6.6.1  ----
% 01.20.12  JDM  added near-field vs far-field plot comment
%
% JDM == Joel D. Miller

% in case of error
itd = 0;

if nargin < 2,
  disp( 'sitd error: az,el parameters required.' );
  return;
end;

% default head radius, meters
if nargin < 3
  hr = 0.09;  % Fritz and JDM approx head radius
end;

% default source-listener distance, meters
% (ACD Snapshot and CIPIC 1m, Listen 1.95m)
if nargin < 4
  sld = 0.9;  % ACD HeadZap speaker-sphere_center distance
end;

% sound source cannot be within head
if sld < hr,
  disp( 'sitd error: sound source in head.' );
  return;
end;

% Note re sld: near-field vs far-field.
% One often sees the Woodworth&Schlosberg far-field model in papers.
% sitd() produces values consistent with the W&S near-field model.
% CIPIC measured at 1.0m, Listen at 1.9m.
% (see sitds.m)
if 0,
r = [.09 1:10];
itd=[];
for k=r,itd=[itd,sitd(90,0,0.09,k)];end;
plot(r,itd,'o-')
h = line([min(r) max(r)],[668.7 668.7]);  % W&S far-field
set(h,'Color',[1 0 0]);
grid on;
xlabel('sld, m');ylabel('us');title('near-field vs far-field');
end;

sos = 346;     % speed of sound, m/s (346 in slabdefs.h)
d2r = pi/180;  % degs to rads
azr = az*d2r;  % radians
elr = el*d2r;  % radians

% rotated x,y plane, az only method (pg49, NASA6)
azp = asin( cos(elr) * sin(azr) );
dlp = sqrt( sld^2 + hr^2 + 2*sld*hr*sin(azp) );
drp = sqrt( sld^2 + hr^2 - 2*sld*hr*sin(azp) );

% arc length correction
L = sqrt( sld^2 - hr^2 );  % distance to spherical head tangent point
al = pi/2 + azp;           % angle to left ear
ar = pi/2 - azp;           % angle to right ear

if( dlp > L ),
  dlp = L + (al - acos(hr/sld))*hr;
end;

if( drp > L ),
  drp = L + (ar - acos(hr/sld))*hr;
end;

itd = (dlp - drp)*1000000/sos;
