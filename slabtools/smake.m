function h = smake( name, source, comment, ir, itd, dgrid, finc, fs, mp, ...
  tgrid, eqfs, eqm, eqf, fgrid, eqd, eqb, eqh, hcom )
% smake - makes a slab3d archive struct.
%
% h = smake( name, source, comment, ir, itd, dgrid, finc, fs, mp, tgrid, ...
%            eqfs, eqm, eqf, fgrid, eqd, eqb, eqh, hcom )
%
% name    - subject name
% source  - source of data (e.g., 'snapshot', 'headzap', 'slabslh', 'cipic',
%           'custom' )
% comment - comment string
% ir      - HRIR data, all left ear data followed by all right ear data
% itd     - ITD data, #samples left lags right
% dgrid   - data grid (az,el order, elevations grouped by azimuth)
% finc    - dgrid fixed increment flag (default = 1)
% fs      - HRIR sample rate (default = 44100)
% mp      - HRIR minimum-phase flag (default = 0)
% tgrid   - measurement grid read by head-tracker (default = [])
% eqfs    - EQ sampling rate (default = 0)
% eqm     - mixed EQ (e.g., Snapshot eq) (default = [])
% eqf     - free-field EQ (default = [])
% fgrid   - free-field EQ grid (elevations grouped by azimuth) (default = [])
% eqd     - diffuse-field EQ (default = [])
% eqb     - bass-boost EQ (default = [])
% eqh     - headphone EQ (default = [])
% hcom    - headphone comment describing model, type, and coupling
%           (default = '')
%
% h - slab3d archive struct (see sarc.m)
%
% smake returns a slab3d archive constructed from the parameters.

% modification history
% --------------------
% 11.12.02  JDM  created
%                ----  v5.2.1  ----
% 07.23.03  JDM  new param notes
%                ----  v5.3.0  ----
% 08.15.03  JDM  new params for HeadZap data
% 08.20.03  JDM  added fgrid
%                ----  v5.4.0  ----
% 10.29.03  JDM  added pfinc, mfinc, etc., version to 3
% 11.21.03  JDM  sarc overhaul, version to 4
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

% first 6 params required
if nargin < 6,
  disp( 'smake error: not enough input arguments.' );
  return;
end;

% parameter defaults
if nargin <  7,  finc  = 1;       end;
if nargin <  8,  fs    = 44100;   end;
if nargin <  9,  mp    = 0;       end;
if nargin < 10,  tgrid = [];      end;
if nargin < 11,  eqfs  = 0;       end;
if nargin < 12,  eqm   = [];      end;
if nargin < 13,  eqf   = [];      end;
if nargin < 14,  fgrid = [];      end;
if nargin < 15,  eqd   = [];      end;
if nargin < 16,  eqb   = [];      end;
if nargin < 17,  eqh   = [];      end;
if nargin < 18,  hcom  = '';      end;

% create date string
[y,m,d] = datevec(date);
sdate = sprintf( '%02d/%02d/%4d', m, d, y );

azinc = 0;
elinc = 0;

% processed data fixed increment
if finc,
  % az's ordered from max to min
  azMax = max( dgrid(2,:) );
  azinc = azMax - dgrid( 2, min( find( dgrid(2,:) ~= azMax ) ) );
		
  % el's ordered from max to min
  elMax = max( dgrid(1,:) );
  elinc = elMax - dgrid( 1, min( find( dgrid(1,:) ~= elMax ) ) );

% another method (was in hpower() and hcom()):
% azinc = -min(diff(h.dgrid(2,:)))
% elinc = -min(diff(h.dgrid(1,:)))
end;

% sarc struct = function parameters plus date and version
h = struct( 'name', name, 'date', sdate, 'source', source, ...
            'comment', comment, 'ir', ir, 'itd', itd, 'dgrid', dgrid, ...
            'finc', finc, 'azinc', azinc, 'elinc', elinc, 'fs', fs, ...
            'mp', mp, 'tgrid', tgrid, 'eqfs', eqfs, 'eqm', eqm, ...
            'eqf', eqf, 'fgrid', fgrid, 'eqd', eqd, 'eqb', eqb, 'eqh', eqh, ...
            'hcom', hcom, 'version', 4 );
