function ha = ahm2sarc( ahmFile, writeSarc, verbose )
% ahm2sarc - converts an AuSIM .ahm to a slab3d archive.
%
% ha = ahm2sarc( ahmFile, writeSarc, verbose )
%
% ahmFile   - AHM filename without AHM suffix
% writeSarc - 1 = save sarc to file, 0 = don't save (default 0)
% verbose   - 1 = verbose, 0 = not (default 0)
%
% ha - AHM data slab3d archive struct

% modification history
% --------------------
%                ----  v5.8.1  ----
% 06.07.06  JDM  created from zap2sarc()
%                ----  v6.7.5  ----
% 03.18.15  JDM  upgraded from 2006-era tools to 2015 HRTFDevKit;
%                added writeSarc param; ahmFile param now without suffix;
%                removed appended 'a' from output sarc filename
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

if nargin < 1,
  disp( 'ahm2sarc error: not enough input arguments.' );
  return;
end;

if nargin < 2,
  writeSarc = 0;
end;

if nargin < 3,
  verbose = 0;
end;

% default HRTFDevKit.msi (received 2/3/2015) matlab tools install:
% 'C:\Program Files (x86)\AuSIM\AuSIMMat'

% C:\Program Files (x86)\AuSIM\AuSIM3D\doc\HRTF_DevelKitGuide.pdf
% Document v0.9
% 30 January 2015

% >>help ausimmat (read subset)
% Contents of AuSIMMat:
% 
% AHMconstants - list of AHM constants
% AHMheader    - provides header structure format for AHM/AFM/EQF file readers
% AHMIO_read   - reads an AHM/AFM/EQF file through AHMIO mex

% >> ahmio_read()
% AHMIO_read version 1.360 

% [header data] = AHMIO_read('jws44')
% 
% header = 
% 
%             version: 1.5000
%            filetype: 0
%            filename: 'jws44'
%                date: 'Tue May 08 00:29:21 2001 '
%             subject: 'Joel Storckman                 '
%            comments: [1x83 char]
%               sinks: 2
%               srate: 44100
%     total_responses: 144
%             section: [1x1 struct]
%                 map: [1x1 struct]
%             datafmt: [1x1 struct]
%               units: [1x1 struct]
%             sources: [1x1 struct]
%                  eq: [1x1 struct]
%             enhance: [1x1 struct]
%          components: 0
%            headsize: 0.1500
%        speedOfSound: 0.0078
%          encryption: 0
%        virtualnodes: 0
%       trianglecount: 0
%          sectionSeq: [1x1 struct]
%           vectorSeq: [1x1 struct]
%         responseSeq: [1x1 struct]
%           regionSeq: [1x1 struct]
%            bonusSeq: [1x1 struct]
% 
% 
% data = 
% 
%     Responses: [128x2x72 double]
%        Delays: [72x2 double]
%        Levels: [72x2 double]

% >> header.comments
% 
% Measured with Snapshot 17May2000 in AuSIM Los Altos conference room.
% Full cylinder.
% 
% >> header.section
% 
%            total: 1
%         zerocoef: 128
%         polecoef: 0
%     optimization: 0
%           window: 1
% 
% >> header.map
% 
%       azimuth: 12
%     elevation: 6
%         range: 1
%        origin: [1x1 struct]
%      interval: [1x1 struct]
%        incrop: [1x1 struct]
%          axis: 4 - Spherical_ZYR, AuSIM/CRE/UWMadison
% 
% >> header.map.origin
% 
%       azimuth: -180
%     elevation: 54
%         range: 1
% 
% >> header.map.interval
% 
%       azimuth: 30
%     elevation: -18
%         range: 0
% 
% >> header.map.incrop - increment operation
% 
%       azimuth: 1 - add
%     elevation: 1 - add
%         range: 2 - multiply
% 
% >> header.datafmt
% 
%           type: [1x1 struct]
%     resolution: [1x1 struct]
%     conversion: 1
% 
% >> header.datafmt.type - float or fixed
% 
%       coef: 2 - fixed
%       time: 2
%      level: 2
%     weight: 2
% 
% >> header.datafmt.resolution - #bits
% 
%       coef: 32
%       time: 32
%      level: 32
%     weight: 32
% 
% >> header.units
% 
%     distance: 4  - meters
%        angle: 17 - degrees
%         time: 32 - samples
%        level: 48 - linear
% 
% >> header.sources
% 
%         left: 1
%        right: 1
%     northcap: 0
%     southcap: 0
% 
% >> header.eq
% 
%     headphone: 12 - custom
%         field: 0
%         level: 0
%      normtype: 0
% 
% >> header.enhance
% 
%     method: 1
%       freq: [700 0] - low high ????
%      slope: 0
% 
% >> header.sectionSeq
% 
%     fld: [1 0 0 0 0 0 0] - #sections
%     flg: 1               - multiplier + flag, zeros preceed poles
% 
% >> header.vectorSeq
% 
%     fld: [3 1 2 0 0 0 0] - range, azimuth, elevation
%     flg: 0               - no flags
% 
% >> header.responseSeq
% 
%     fld: [10 11 12 0 0 0 0] - response, time delay, level
%     flg: 3                  - three above L/R interleaved
% 
% >> header.regionSeq
% 
%     fld: [1 2 3 0 0 0 0] - rectangular map grid, north cap, south cap
%     flg: 0               - no caps ????
% 
% >> header.bonusSeq
% 
%     fld: [0 0 0 0 0 0 0]
%     flg: 0

% read AHM
[header data] = AHMIO_read( ahmFile );

if verbose,
header
fprintf('header.comments');
header.comments
fprintf('header.section');
header.section
fprintf('header.map');
header.map
fprintf('header.map.origin');
header.map.origin
fprintf('header.map.interval');
header.map.interval
fprintf('header.map.incrop');
header.map.incrop
fprintf('header.datafmt');
header.datafmt
fprintf('header.datafmt.type');
header.datafmt.type
fprintf('header.datafmt.resolution');
header.datafmt.resolution
fprintf('header.units');
header.units
fprintf('header.sources');
header.sources
fprintf('header.eq');
header.eq
fprintf('header.enhance');
header.enhance
fprintf('header.sectionSeq');
header.sectionSeq
fprintf('header.vectorSeq');
header.vectorSeq
fprintf('header.responseSeq');
header.responseSeq
fprintf('header.regionSeq');
header.regionSeq
fprintf('header.bonusSeq');
header.bonusSeq
fprintf('data');
data
end;

% vector of azimuths
mazBegin = header.map.origin.azimuth;
mazInc = header.map.interval.azimuth;
mazEnd = mazBegin + mazInc*(header.map.azimuth-1);
maz = mazBegin:mazInc:mazEnd;
maz = -maz;  % slab3d az definition opposite AuSIM (slab3d +az right)

wrap = find(maz > 180);
maz(wrap) = maz(wrap) - 360;
wrap = find(maz < -180);
maz(wrap) = maz(wrap) + 360;

if verbose,
  maz
end;

% vector of elevations
melBegin = header.map.origin.elevation;
melInc = header.map.interval.elevation;
melEnd = melBegin + melInc*(header.map.elevation-1);
mel = melBegin:melInc:melEnd;

if verbose,
  mel
end;

% measurement grid matrix
%    54    36    18     0   -18   -36    54    36  ...
%  -180  -180  -180  -180  -180  -180  -150  -150  ...
mgrid = [kron(ones(size(maz)),mel); kron(maz,ones(size(mel)))];

% for each response pair apply gain level
for r = 1:size(data.Levels,1),
  % left ear
  data.Responses(:,1,r) = data.Levels(r,1) * data.Responses(:,1,r);
  % right ear
  data.Responses(:,2,r) = data.Levels(r,2) * data.Responses(:,2,r);
end;

% all left-ear responses followed by right-ear responses
mir = [ squeeze(data.Responses(:,1,:)) squeeze(data.Responses(:,2,:)) ];

% #samples left lags right
mitd = data.Delays(:,1)' - data.Delays(:,2)';

% ahm data sarc (1 = fixed inc, minphase)
ha = smake( header.subject, 'ahm', header.comments, mir, mitd, mgrid, ...
            1, header.srate, 1 );

% AuSIM grids can be ordered in a variety of ways. Some grids violate the
% traditional slabtool ordering requiring a more general definition of
% azinc and elinc. These sarcs can still be used in raw form or
% turned into an SLH. E.g., BMC44.ahm.

% find az increments
d = diff(ha.dgrid(2,:));
di = find(d ~= 0);
% find min increment
ha.azinc = min(abs(d(di)));

% find el increments
d = diff(ha.dgrid(1,:));
di = find(d ~= 0);
% find min increment
ha.elinc = min(abs(d(di)));

% save sarc
if writeSarc == 1,
  ssave( ha, ahmFile );
  fprintf( 'Saved %s.sarc.\n', ahmFile );
end;
