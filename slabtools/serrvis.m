% serrvis - subject positioning error ITD visualization

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% modification history
% --------------------
%                ----  v6.6.1  ----
% 04.11.12  JDM  created from vitd.m
%                ----  v6.7.2  ----
% 08.12.13  JDM  to slabtools
% 08.27.13  JDM  added Snowman-based IID vis
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

% ITD specified as a left or right ear lag relative to the opposite ear,
% positive = lag left ear, negative = lag right ear, us,
% +az to the right
%
%                right             left
% azs:  180, 165, ..., 15, 0, -15, ..., -165
% itds:   0    +        +  0    -          -

% SRAPI coords
%
% right-handed front-left-top x,y,z
% orientation +CCW looking down axis towards origin
%
% +x front
% +y left
% +z top
% +yaw left
% +pitch down
% +roll right
% +az right
% +el up

% subject positioning error
x = 0.0;  % meters, pos skews pos ITDs to the left, neg to the right
y = 0.0;  % meters, pos biases ITDs up
z = 0.0;  % meters, pos expands high EL ITDs and compresses low EL ITDs
yaw = 0.0;  % degrees, pos shifts right, discont. at extreme EL transitions
pitch = 0.0;  % degrees, does nothing (remember, smooth sphere model)
roll = 0.0;  % degrees, diagonal bias, pos, low-to-high

t = 'Spherical Head Model ITDs, subject ';
ti = 'Snowman IIDs, subject ';
ts = 'origin'; f = 'origin';
%x = 0.5; ts = 'x = 0.5m'; f = 'x';
%y = 0.05; ts = 'y = 0.05m'; f = 'y';
%z = 0.15; ts = 'z = 0.15m'; f = 'z';
yaw = 30.0; ts = 'yaw = 30 degrees'; f = 'yaw';
%pitch = 20.0; ts = 'pitch = 20 degrees'; f = 'pitch';
%roll = 5.0; ts = 'roll = 5 degrees'; f = 'roll';

sld = 0.9;      % ACD HeadZap
azMax = 180;
azMin = -165;
azinc = 15;
elMax = 90;
elMin = -90;
elinc = 15;

azs = azMax:-azinc:azMin;
els = elMax:-elinc:elMin;

len = length(azs) * length(els);
gridSort = zeros(3,len);
gridSortE = zeros(3,len);  % with subject-pos errors
itdSort = zeros(1,len);
itdSphere = zeros(1,len);
k = 1;
for el = els
  for az = azs
    gridSort(:,k) = [el;az;sld];
    % reference ITD in us
    itdSphere(k) = sitdw( az, el, 0.09, sld );
    % apply listener positioning error to source (p = prime)
    [azp,elp,sldp] = poserr(az, el, sld, x, y, z, yaw, pitch, roll);
    itdSort(k) = sitdw( azp, elp, 0.09, sldp );  % near field
    %itdSort(k) = sitdw( azp, elp, 0.09, sldp, 1 );  % far field
    %itdSort(k) = sitd( azp, elp, 0.09, sldp );  % near-field-only model
    %[ az azp; el elp; sld sldp ]
    gridSortE(:,k) = [elp;azp;sldp];
    k = k + 1;
  end;
end;

% to vis changes to az,el,r
%figure;
%plot([gridSort'-gridSortE'],'.-');
%legend('el','az','r');

% plot ITDs
figure;
plot( 1:length(itdSort), itdSort, 'b.-', 1:length(itdSort), itdSphere, 'r-' );
axis( [ 0 length(itdSort)+1 -700 700 ] );
%title( sprintf( 'ITDs %.1f %.1f %.1f %.1f %.1f', x, y, z, yaw, pitch ) );
title( [ t ts ] );
xlabel('elevation');
ylabel('us');
set(gca,'YTick',[-1000:100:1000]);

% x tick every new el
set( gca, 'XTick', 1:length(azs):length(itdSort) );
set( gca, 'XTickLabel', num2str(els') );
grid on;

%print(gcf,'-dpng',['serrvis_' f ]);

%--------------------------------------------------------------------------
% CIPIC Snowman-based IID subject-pos error vis.
% !!!! Requires CIPIC's Snowman model matlab scripts in path!
% See also: snow2sarc.m
if 0,

% database grid = slab3d fixed-inc grid
dgrid = grids(5,5,0);  % azInc, elInc, gridType

% number of database az,el locations
numLocs = size(dgrid,2);

% sarc struct
% smake( name, source, comment, ir, itd, dgrid, finc, fs, mp, tgrid, ...
%        eqfs, eqm, eqf, fgrid, eqd, eqb, eqh, hcom )
hLen = 256;  % HRIR length
h = smake( 'Snow Mann', 'SnowmanModel', 'synthetic database', ...
           zeros(hLen, numLocs*2), zeros(numLocs,1), dgrid );

% generate HRIRs
fprintf( 'Creating Snowman database...\n' );
imp = [ 1; zeros(hLen-1,1) ];  % impulse
for dg=1:length(h.dgrid),
  % apply listener positioning error to source (p = prime)
  az = h.dgrid(2,dg);
  el = h.dgrid(1,dg);
  [azp,elp,sldp] = poserr(az, el, sld, x, y, z, yaw, pitch, roll);
  % CIPIC's vertical-polar to interaural-polar conversion script
  [ipAz ipEl] = vp2ip(azp, elp);
  % CIPIC's Snowman model script
  out = snowman_filter_model( imp, ipAz, ipEl );
  h.ir(:, dg)           = out(:,1);  % left HRIR
  h.ir(:, dg + numLocs) = out(:,2);  % right HRIR
end;
fprintf( 'Done.\n\n' );

% IID with slab3d grid overlay;
% use hacked lrsphere.m for single column and 15,15 inc
figure;
hen(h,0,0,[],[],1,1,1,1,0);
%subplot(2,1,1);
%title( [ ti ts ] );
%set(gcf,'PaperPosition',[ 0.5 0.5 4 8 ]);
%print(gcf,'-dpng',['serrvisIID_' f ]);

end;
