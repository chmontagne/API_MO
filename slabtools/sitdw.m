function itd = sitdw( az, el, Dh, r, par )
% sitdw - compute Woodworth/Schlosberg spherical-head model ITD.
%
% itd = sitdw( az, el, Dh, r, par )
%
% itd - ITD specified as a left or right ear lag relative to the opposite ear,
%       positive = lag left ear, negative = lag right ear, us
% az  - azimuth, degrees
% el  - elevation, degrees
% Dh  - head radius (D half), m (default 0.09m)
% r   - source-listener distance, m (default 0.9m)
% par - assume parallel sound incidence, r >> Dh (default 0)
%
% This function is based on the Woodworth-Schlosberg model as it appears in
% Jens Blauert's book "Spatial Hearing".
%
% See also: sitd

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
%                ----  v6.6.0  ----
% 03.04.11  JDM  created
%
% JDM == Joel D. Miller

% in case of error
itd = 0;

if nargin < 2,
  disp( 'sitdw error: az,el parameters required.' );
  return;
end;

% default head radius, meters
if nargin < 3
  Dh = 0.09;  % Fritz and JDM head radius
end;

% default source-listener distance, meters
% (ACD Snapshot and CIPIC 1m, Listen 1.95m)
if nargin < 4
  r = 0.9;  % ACD HeadZap speaker-sphere_center distance
end;

% default parallel sound incidence
if nargin < 5
  par = 0;  % do not assume parallel sound incidence
end;

% sound source cannot be within head
if r < Dh,
  disp( 'sitdw error: sound source in head.' );
  return;
end;

sos = 346;     % speed of sound, m/s (346 in slabdefs.h)
d2r = pi/180;  % degs to rads
elr = el*d2r;  % radians
azr = az*d2r;  % radians

% rotated x,y plane, az only method (pg49, NASA6)
% (see also Larcher and Jot extension in Minnaar)
azr = asin( cos(elr) * sin(azr) );

% if assuming parallel sound incidence
if par,
  itd = Dh * (azr + sin(azr));
else
  % if point source near head with sound reaching both ears by indirect paths
  if abs(sin(azr)) <= Dh/r,
    itd = 2*Dh*azr;
  else
    s = 1;  % sign
    if azr < 0,
      azr = -azr;  % else asymmetric
      s = -1;
    end;

    n = (r - Dh)/(2*Dh);
    ep = asin( Dh / r );
    itd = s*2*Dh * ( (n+0.5)*cos(ep) + 0.5*(azr+ep) - ...
            sqrt(n*n+n+0.5-(n+0.5)*sin(azr)) );
  end;
end;

itd = 1000000 * itd / sos;
