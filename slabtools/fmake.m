function s = fmake( name, source, fs, hrir_l, hrir_r, hgrid, range, ...
                    coordsys, comment )
% fmake - makes a Club Fritz HRIR database struct.
%
% s = fmake( name, source, fs, hrir_l, hrir_r, hgrid, range, coordsys, comment )
%
% name     - subject name (e.g., 'Fritz')
% source   - source of data (e.g., 'ACD HeadZap')
% fs       - sample rate, samples-per-second
% hrir_l   - left-ear HRIR data
% hrir_r   - right-ear HRIR data
% hgrid    - measurement grid, degrees
% range    - speaker-to-mic distance, meters
% coordsys - 'polar' or 'cipic' (default = 'polar')
% comment  - comment string (default = [], e.g., 'measured by JDM')
%
% s - Club Fritz HRIR database struct
%
% fmake returns a Club Fritz HRIR database struct initialized from the fmake
% parameters.
%
% The following fields of s are initialized internally:
%   date
%   version
%
% See also: ffmake(), fsave(), fview()

% modification history
% --------------------
%                ----  v5.5.0  ----
% 10.20.04  JDM  created
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

% first 7 params required
if nargin < 7,
  disp( 'fmake error: not enough input arguments.' );
  s = [];
  return;
end;

% parameter defaults
if nargin < 8,  coordsys = 'polar';   end;
if nargin < 9,  comment  = [];        end;

% create date string
[y,m,d] = datevec(date);
fdate = sprintf( '%02d/%02d/%4d', m, d, y );

% function parameters plus date and version
s = struct( 'name', name, 'date', fdate, 'source', source, ...
            'comment', comment, 'fs', fs, 'coordsys', coordsys, ...
            'range', range, 'version', 1, 'hrir_l', hrir_l, ...
            'hrir_r', hrir_r, 'hgrid', hgrid );
