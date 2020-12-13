function s = ffmake( mic, speaker, source, fs, ff_l, ff_r, ffgrid, range, ...
                     coordsys, comment )
% ffmake - makes a Club Fritz free-field EQ database struct.
%
% s = ffmake( mic, speaker, source, fs, ff_l, ff_r, fgrid, range, coordsys, ...
%             comment )
%
% mic      - mic manufacturer and model (e.g., 'Panasonic WM-61')
% speaker  - speaker manufacturer and model (e.g., 'AuSIM AuPBE101')
% source   - source of data (e.g., 'ACD HeadZap')
% fs       - sample rate, samples-per-second
% ff_l     - left-mic free-field EQ data
% ff_r     - right-mic free-field EQ data
% ffgrid   - mapping of free-field EQ data to HRIR data, degrees
% range    - speaker-to-mic distance, meters
% coordsys - 'polar' or 'cipic' (default = 'polar')
% comment  - comment string (default = [], e.g., 'measured by JDM')
%
% s - Club Fritz free-field EQ database struct
%
% ffmake returns a Club Fritz free-field EQ database struct initialized from the
% ffmake parameters.
%
% The following fields of s are initialized internally:
%   date
%   version
%
% See also: fmake(), fsave(), fview()

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

% first 8 params required
if nargin < 8,
  disp( 'ffmake error: not enough input arguments.' );
  s = [];
  return;
end;

% parameter defaults
if nargin <  9,  coordsys = 'polar';   end;
if nargin < 10,  comment  = [];        end;

% create date string
[y,m,d] = datevec(date);
fdate = sprintf( '%02d/%02d/%4d', m, d, y );

% function parameters plus date and version
s = struct( 'mic', mic, 'speaker', speaker, 'date', fdate, ...
            'source', source, ...
            'comment', comment, 'fs', fs, 'coordsys', coordsys, ...
            'range', range, 'version', 1, 'ff_l', ff_l, ...
            'ff_r', ff_r, 'ffgrid', ffgrid );
