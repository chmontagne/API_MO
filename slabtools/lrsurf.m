function lrsurf( azmap, elmap, zL, zR, titleL, titleR, cax, tb, int, haL, haR )
% lrsurf - display left and right data surfaces (support script).
%
% See also: hen, hencb, hencbview

% modification history
% --------------------
%                ----  v6.6.0  ----
% 05.04.11  JDM  created from hen()
%                ----  v6.7.1  ----
% 02.11.13  JDM  bug fix: inc'd nargin < +1
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

% default args
if nargin < 9, int = 0; end;
if nargin < 10, haL = []; end;
if nargin < 11, haR = []; end;

% interp surface
if int,
  [xi,yi] = meshgrid(-180:3:180,-90:3:90);
  ziL = interp2( azmap,elmap,zL,xi,yi,'bicubic' );
  ziR = interp2( azmap,elmap,zR,xi,yi,'bicubic' );
end;

azmax = max( azmap );
azmin = min( azmap );
elmax = max( elmap );
elmin = min( elmap );

% if no axes args (ha1, ha2)
if isempty( [ haL haR ] ),
  figure(gcf);
  subplot(1,2,1); % left ear
  drawL = 1;
  drawR = 1; % using gcf
elseif ~isempty( haL ),
  axes( haL );
  drawL = 1;
  drawR = 0; % unknown at this point
else,
  drawL = 0;
  drawR = 0; % unknown at this point
end;

% left ear
if drawL,
if int,
  surf(xi,yi,ziL);
  shading flat;
else
  surf(azmap,elmap,zL);
end;
%axis tight;
axis( [ azmin azmax elmin elmax cax ] );
xlabel('AZ');
ylabel('EL');
zlabel('dB');
if tb,
  view(0,90);
else
  view(-30,25);
end;
title( titleL, 'Interpreter', 'none' );
colormap(jet);
caxis( cax );
end;

% if using gcf
if drawR,
  subplot(1,2,2);
elseif ~isempty( haR ),
  axes( haR );
  drawR = 1; % now known
end;

% right ear
if drawR,
if int,
  surf(xi,yi,ziR);
  shading flat;
else
  surf(azmap,elmap,zR);
end;
%axis tight;
axis( [ azmin azmax elmin elmax cax ] );
xlabel('AZ');
ylabel('EL');
zlabel('dB');
if tb,
  view(0,90);
else
  view(-30,25);
end;
title( titleR, 'Interpreter', 'none' );
colormap(jet);
caxis( cax );
end;
