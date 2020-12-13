function [ hp, hm ] = snap2sarc( snapSubject, cleanmap, sarcName )
% snap2sarc - converts Snapshot archive to slab3d archive.
%
% [ hp, hm ] = snap2sarc( snapSubject, cleanmap, sarcName )
%
% subject  - Snapshot archive subject name (see arclist)
% cleanmap - 'clean' map (see below)
% sarcName - if present, saves sarc to file (do not include .sarc extension)
%
% hp - processed data slab3d archive struct
% hm - measured data slab3d archive struct
%
% Regarding cleanmap:  The Snapshot archive 'map' var can be created from
% head tracker data.  The tracker map is stored in the sarc 'tgrid' field.
% Since the tracker data can contain errors, you must also provide a 'clean'
% map (i.e., intended locations (see newmap())).  The clean map is stored in
% the sarc 'dgrid' field.  To determine the newmap parameters, use arcload() to
% load the Snapshot archive and type 'map' to view the map variable.
%
% NOTE: Snapshot maps are grouped-by-elevation!  slab3d, tron, AHM, and sarc are
% grouped-by-azimuth.

% modification history
% --------------------
% 11.08.02  JDM  created
%                ----  v5.3.0  ----
% 08.15.03  JDM  updated to new smake()
%                ----  v5.4.0  ----
% 11.21.03  JDM  updated to new v4 sarc
%                ----  v5.5.0  ----
% 06.07.04  JDM  finished h to hp,hm mods
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

% Snapshot archive usage:
%
% >> hrtf_h - to make workspace variables global
% >> cd /amat/archive
% >> arclist - to list subjects in archive
% >> arcload('Joel3') - to load subject data (e.g. 'Joel3')
% >> whos - to view Snapshot workspace
%   Name          Size           Bytes  Class
%
%   eq          256x2             4096  double array (global)
%   file          1x12              24  char array (global)
%   fs            1x1                8  double array (global)
%   hrir        128x144         147456  double array (global)
%   itd           1x72             576  double array (global)
%   map           2x72            1152  double array (global)
%   notes         1x7               14  char array (global)
%   rawir       512x144         589824  double array (global)
%   subject       1x5               10  char array (global)
%
% eq = G(w) / ( DFR(w)P(w) )        (Ch.1 text)
% eq = 1 / ( DF(w)S(w)M(w)P(w) )    (Ch.5 text)
% equivalent if DF(w) = DFH(w)/G(w) (DFR(w) = DFH(w)S(w)M(w))
% Ch.5 is a little vague re raw data and eq.  The raw data is post-bias
% removal.  Windowing, range normalization, and bass extension occur
% before eq applied.  After eq applied, the hrir is converted to min phase.
% Note, the itd is calculated after windowing, but the itd calculation does
% not affect the hrir.
%
% file    = archive name (e.g. 'B37DD3B0.arc')
% fs      = sample rate (e.g. 44100)
% hrir    = processed hrir
% itd     = processed itd
% map     = head tracker map grid (grouped by elevation)
% notes   = notes entered when running Snapshot
% rawir   = post-bias removal ir
% subject = subject's name

if( nargin < 2 ),
  disp( 'snap2sarc error - not enough input arguments' );
  return;
end;

% nullify global Snapshot vars
hrtf_h;
eq      = [];
file    = [];
fs      = [];
hrir    = [];
itd     = [];
map     = [];
notes   = [];
rawir   = [];
subject = [];

% load Snapshot arhive
arcload( snapSubject );
if( length( file ) == 0 ),
  disp( 'snap2sarc error - subject invalid' );
  return;
end;

% find unique azimuth locations (result will be sorted)
u = unique( cleanmap(2,:) );

% group az's together in descending azimuth order
r = [];  % reorder indices
for i=length(u):-1:1,
  r = [ r find( cleanmap(2,:) == u(i) ) ];
end;

% reorder map, itd, ir, and rawir from grouped-by-el to grouped-by-az
rmap   = cleanmap(:,r);
ritd   = itd(r);
rir    = [ hrir(:,r) hrir(:,r+length(r)) ];
rrawir = [ rawir(:,r) rawir(:,r+length(r)) ];
rtmap  = map(:,r);

% sarc structs

% processed data
hp = smake( subject, 'snapshot', notes, rir, ritd, rmap, 1, fs, 1, [], ...
            fs, eq );

% measured data
hm = smake( subject, 'snapshot', notes, rrawir, [], rmap, 1, fs, 0, rtmap );

% a couple test locations
if 0,
clf; hold on;
plot(h.ir(:,hindex(0,0,h.map)),'b');
plot(h.ir(:,hindex(0,0,h.map)+length(h.map)),'r');
figure; hold on;
plot(h.ir(:,hindex(90,0,h.map)),'b');
plot(h.ir(:,hindex(90,0,h.map)+length(h.map)),'r');
end;

% save sarc
if( nargin > 2 ),
  ssave( hp, [ sarcName 'p' ] );
  ssave( hm, [ sarcName 'm' ] );
end;
