function lrsphere( azmap, elmap, zL, zR, titleL, titleR, cax, tb, sb, bLine, gt)
% lrsphere - display left and right data spheres (support script).
%
% lrsphere( azmap, elmap, zL, zR, titleL, titleR, cax, tb, sb, bLine, gt )
%
% tb = top and bottom views
% sb = show bottom, default 1
% bLine = display, default 0
% gt = HRTF grid type, -1=none, 0=slab3d, 1=CIPIC, 2=Listen, default -1
%
% See also: hen, hencb, henview

% modification history
% --------------------
%                ----  v6.6.0  ----
% 05.04.11  JDM  created from hencb()
%                ----  v6.7.1  ----
% 02.11.13  JDM  added sb (show bottom) param
% 02.13.13  JDM  tb = 2 for alternate views
% 03.13.13  JDM  added bLine and gt
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

if nargin < 9,
  sb = 1;  % show bottom defaults to show
end;
if nargin < 10,
  bLine = 0;  % display median plane reference line
end;
if nargin < 11,
  gt = -1;  % no database grid display
end;

% database grid display string
gstr = 'w.';

% for the 3D spherical display, front is +90 deg,
% add vLR for the left display, subtract for the right
vLR = 20;

% to show measurement or database grid;
% note: for some reason, interp not as smooth when grid displayed
switch gt
  case 0  % slab3d
    [ cgrid, cx, cy, cz ] = grids(30,18,0);
  case 1  % CIPIC
    [ cgrid, cx, cy, cz ] = grids(0,0,1);
  case 2  % Listen
    [ cgrid, cx, cy, cz ] = grids(0,0,2);
  case 3  % ACD
    [ cgrid, cx, cy, cz ] = grids(0,0,3);
  otherwise
    gt = -1;  % no grid displayed
end;

figure(gcf);
colormap(jet);

az = azmap*pi/180;
el = elmap'*pi/180;
cosel = cos(el); %cosel(1) = 0; cosel(n+1) = 0;
x = cosel*cos(az);
y = -cosel*sin(az);
z = sin(el)*ones(1,length(az));

% left ear
if tb ~= 0,  % top-bottom
  if sb,  % show bottom
    subplot(2,2,1);
  else
    subplot(1,2,1);
  end;
else
  subplot(1,2,1);
end;
surf(x,y,z,zL);
if gt >= 0,
  hold on;
  plot3(cx,cy,cz,gstr);
end;
caxis( cax );
shading interp;
axis square;
xlabel('X');
ylabel('Y');
zlabel('Z');
title( titleL, 'Interpreter', 'none' );
if bLine,
  line([-1 1],[0 0],[1 1],'Color',[1 1 1]);
end;
if tb ~= 0,  % top-bottom
  if tb == 1,
    view(-90,90);
  else
    view(180,0);
  end;

  if sb,  % show bottom
    subplot(2,2,3);
    surf(x,y,z,zL);
    if gt >= 0,
      hold on;
      plot3(cx,cy,cz,gstr);
    end;
    caxis( cax );
    shading interp;
    axis square;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    view(-90,-90);
    set(gca,'XDir','reverse');
    if bLine,
      line([-1 1],[0 0],[-1 -1],'Color',[1 1 1]);
    end;
  end;
else
  aL = gca;
  view(90+vLR,15);

  ht = text(0.9,0,-0.9,'F');
  set(ht,'FontSize',18);
  ht = text(0,0.9,-0.9,'L');
  set(ht,'FontSize',18);
  ht = text(0,-0.9,-0.9,'R');
  set(ht,'FontSize',18);
end;

% right ear
if tb ~= 0,  % top-bottom
  if sb,  % show bottom
    subplot(2,2,2);
  else
    subplot(1,2,2);
  end;
else
  subplot(1,2,2);
end;
surf(x,y,z,zR);
if gt >= 0,
  hold on;
  plot3(cx,cy,cz,gstr);
end;
caxis( cax );
shading interp;
axis square;
xlabel('X');
ylabel('Y');
zlabel('Z');
title( titleR, 'Interpreter', 'none' );
if bLine,
  line([-1 1],[0 0],[1 1],'Color',[1 1 1]);
end;
if tb ~= 0,  % top-bottom
  if tb == 1,
    view(-90,90);
  else
    view(180,0);
  end;

  if sb,  % show bottom
    subplot(2,2,4);
    surf(x,y,z,zR);
    if gt >= 0,
      hold on;
      plot3(cx,cy,cz,gstr);
    end;
    caxis( cax );
    shading interp;
    axis square;
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    view(-90,-90);
    set(gca,'XDir','reverse');
    if bLine,
      line([-1 1],[0 0],[-1 -1],'Color',[1 1 1]);
    end;
  end;
else
  aR = gca;
  view(90-vLR,15);

  ht = text(0.9,0,-0.9,'F');
  set(ht,'FontSize',18);
  ht = text(0,0.9,-0.9,'L');
  set(ht,'FontSize',18);
  ht = text(0,-0.9,-0.9,'R');
  set(ht,'FontSize',18);
end;

% rotate (quick hack, size changes)
if 0,
  for vInc = 60:60:300,
    pause;
    view(aL,90+vLR+vInc,15);
    view(aR,90-vLR-vInc,15);
  end;
end;
