function h = snow2sarc()
% snow2sarc - creates a slab3d archive from CIPIC's Snowman model.
%
% h = snow2sarc()
%
% h - slab3d archive struct
%
% Notes:
% - Requires CIPIC's Snowman model matlab scripts.
% - NOT minphase, no ITD extraction.
%
% See also: cipic2slab, CIPIC's snowman_filter_model.m

% modification history
% --------------------
%                ----  v6.7.1  ----
% 03.20.13  JDM  created
%                ----  v6.7.2  ----
% 08.12.13  JDM  to slabtools
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
fprintf( 'Creating database...\n' );
imp = [ 1; zeros(hLen-1,1) ];  % impulse
for dg=1:length(h.dgrid),
  % CIPIC's vertical-polar to interaural-polar conversion script
  [ipAz ipEl] = vp2ip(h.dgrid(2,dg), h.dgrid(1,dg));
  % CIPIC's Snowman model script
  out = snowman_filter_model( imp, ipAz, ipEl );
  h.ir(:, dg)           = out(:,1);  % left HRIR
  h.ir(:, dg + numLocs) = out(:,2);  % right HRIR
end;
fprintf( 'Done.\n\n' );
