function spread( distance0dB, radiusBegin, distEnd, srcSpread )
% spread - illustrates slab3d's spherical spreading loss model.
%
% spread( distance0dB, radiusBegin, distEnd, srcSpread )
%
% distance0dB - 0 dB reference relative to center of head (meters)
% radiusBegin - source radius (meters)
% distEnd     - source-listener distance (meters)
% srcSpread   - spread exponent
%
% spread displays rolloff curves and a gain table for a range of source
% radii.  slab3d's spherical spreading loss model approximates a planar baffled
% cylindrical piston with spread gain calculated as follows:
%
%   spread_gain = (1 + (distance / radius)^2) ^ (-srcSpread / 2)
%
% The srcSpread parameter affects the rate at which the spread gain decreases as
% the source-listener distance increases.  The default value is 1.0.  To exaggerate
% spreading loss, a higher value can be used.  To disable spreading loss,
% a value of 0.0 can be used.
%
% A dotted reference line is provided for the inverse distance law:
%
%   spread_gain = interaural_radius / distance
%
%   interaural_radius = 0.0889 meters
%
% If the slab3d radius parameter is set to interaural_radius,
% the two models are nearly identical for distances >> interaural_radius,
% converging to within 1 dB at about 0.18 m (assuming a slab3d 0 dB
% reference of 0 m).
%
% As of slab3d v6.8.2, a 0 dB reference parameter was added that offsets
% the slab3d distance parameter above.  For distances < 0 dB reference,
% the gain is set to 0 dB.  For identical 0 dB reference values and a
% slab3d radius of IR, the two curves now converge to within 1 dB at
% 0.8 m.
% 
% Defaults:  spread( 0.0889, 0.022, 4.0, 1.0 )  % ir, ir/4 m, 4 m, 1

% modification history
% --------------------
% 05.11.00  JDM  created
% 05.19.00  JDM  added parameters and plot
% 11.15.02  JDM  added 1/d law, clean-up
% 12.04.02  JDM  updated srcSpread description
%                ----  v5.3.0  ----
% 09.05.03  JDM  corrected param comments
%                ----  v6.8.2  ----
% 11.09.17  JDM  added distance0dB reference; distBegin now defaults to ir
%                instead of 0.1
% 11.11.17  JDM  fewer parameters; radius defaults based on interaural
%                radius; distance starts at 0 with 400 points to end param;
%                added distance0dB param
%                ----  v6.8.3  ----
% 03.19.18  JDM  added source radii text to curves
% 06.13.18  JDM  fixed radiusBegin increment, radii text position, and
%                1/d curve distance0dB reference distance
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

% ----  defaults  ----

% ir = interaural radius in meters (center-of-head to ear);
% width of head = 7.0 inches (dINTERAURALin in SLABDEFS.h)
ir = (7.0 * 0.0254) / 2.0;  % 0.0889m

if( nargin < 4 ),
  srcSpread = 1.0;
end;

distBegin = 0;
if( nargin < 3 ),
  distEnd = 4.0;
end;

if( nargin < 2 ),
  radiusBegin = ir/4;
end;
%radius = [ ir/4 ir/2 ir 2*ir 4*ir 8*ir 16*ir ];
radius = radiusBegin * 2.^(0:6);

% distance from head to use as 0dB reference,
% less than this distance would be a constant 0dB
if( nargin < 1 ),
  distance0dB = ir;
end;

% ----  console gain matrix  ----

% print gain matrix labels
fprintf( '\n\nDst,Rad' );
for radiusI = radius,
  fprintf( '\t%6.2f', radiusI );
end;
fprintf( '\t ir/d\n(meters)' );

% create and print gain matrix
dist  = distBegin : ((distEnd-distBegin)/400) : distEnd;
for r = 1:length(dist),
  fprintf( '\n%6.3f:\t', dist(r) );
  for c = 1:length(radius),
    distance = dist(r) - distance0dB;
    if distance < 0, distance = 0; end;
    spgain(r,c) = 20*log10((1 + (distance/radius(c)).^2) .^ (-srcSpread/2));
    fprintf( '%6.2f\t', spgain(r,c) );
  end;
  fprintf( '%6.2f', 20*log10(distance0dB./dist(r)) );
end;
fprintf( '\n\n' );

% ----  plot spreading loss curves  ----

% plot gain matrix
distText = 3/4 * distEnd;
index = find(dist < distText, 1, 'last');  % index of 2m
figure(gcf);
plot( dist, spgain(:,:), '-' );
text( distText*ones(1,size(spgain,2)), spgain(index,:) + 1.5, ...
      num2str(radius', '%.2f m') );
hold on;
% inverse distance law with min distance at distance0dB
plot( dist, 20*log10(distance0dB./dist), '--k' );
hold off;
grid;
axis([ 0 distEnd -50 5 ]);
title('slab3d''s Spherical Spreading Loss Model');
xlabel('Distance (meters)');
ylabel('Attenuation (dB)');
