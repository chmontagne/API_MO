function listcen2slab( subNum, azInc, elInc, numPts, strName, strComment, scale )
% listcen2slab - (see note) converts Listen .mats (R&C) to a slab3d HRTF database (SLH).
%
% listcen2slab( subNum, azInc, elInc, numPts, strName, strComment, scale )
%
% subNum     - Listen subject number (e.g., 1002)
% azInc      - output azimuth increment (default = 15)
% elInc      - output elevation increment (default = 15)
% numPts     - number of FIR points in each HRIR (default = 128)
% strName    - name of head (< 32 chars) (default = IRC_####)
% strComment - comment string (< 256 chars) (default = empty)
% scale      - scale HRIR to +/- 1.0 flag (default = 1)
%
% NOTE: This function contains centroid-based ITD extraction.  Development
%       shifted to a group-delay approach.  Please see listen2slab() for
%       the preferred and current Listen conversion function.
%
% listcen2slab() requires
%   IRC_####_C_HRIR.mat
%   IRC_####_R_HRIR.mat
% to be in the current directory (#### being the subject number specified
% by the subNum parameter).
%
% The output filename is formatted IRC_####.slh, e.g., IRC_1002.slh.
%
% Output data is formatted to the slab3d grid defined below:
%   az = [180:-azInc:-180]; el = [90:-elInc:-90];
%   sgrid = [kron(ones(size(az)),el); kron(az,ones(size(el)))];
%
% See also: mat2slab, grids, lfull, ltest, cipic2slab

% modification history
% --------------------
%                ----  v6.6.0  ----
% 03.10.11  JDM  created
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

% start timer
tic;

if nargin < 1 || nargin > 7,
  disp('listcen2slab error: incorrect number of parameters.');
  return;
end;

subName = sprintf( 'IRC_%04d', subNum );

% parameter defaults
if nargin < 7, scale = 1; end;
if nargin < 6, strComment = ''; end;
if nargin < 5, strName = subName; end;
if nargin < 4, numPts = 128; end;  % slab3d default HRIR length
% best uniform slab3d grid match to Listen grid
if nargin < 3, elInc = 15; end;
if nargin < 2, azInc = 15; end;

% Listen Downloads
%
% http://recherche.ircam.fr/equipes/salles/listen/download.html
%
% Zip Archive Format
%
% IRC_1002
%   COMPENSATED
%     MAT
%       HRIR
%         IRC_1002_C_HRIR.mat
%     WAV
%       IRC_1002_C
%         IRC_1002_C_R0195_T000_P000.wav
%         ...
%         IRC_1002_C_R0195_T345_P345.wav
%   RAW
%     MAT
%       HRIR
%         IRC_1002_R_HRIR.mat
%     WAV
%       IRC_1002_R
%         IRC_1002_R_R0195_T000_P000.wav
%         ...
%         IRC_1002_R_R0195_T345_P345.wav
%
% This function assumes all .mats have been placed in the same directory.
% In Windows7, one can drag'n'drop directly from the zip without extracting
% the entire zip.  If one prefers to extract-all and read from the extracted
% directory structure, modify the two lines below to include directory
% paths and modify lfull.m to mirror cfull.m.

rawName = [ subName '_R_HRIR' ];
compName = [ subName '_C_HRIR' ];

hr = load(rawName);   % raw
hc = load(compName);  % compensated, diffuse-field eq

% Raw Data
%
% hr.l_hrir_S: [1x1 struct]
% hr.r_hrir_S: [1x1 struct]
%
% hr.l_hrir_S
%          type_s: 'FIR'
%          elev_v: [187x1 double]
%          azim_v: [187x1 double]
%     sampling_hz: 44100
%       content_m: [187x8192 double] - IR length = 8192

% Compensated Data
%
% hc.l_eq_hrir_S: [1x1 struct]
% hc.r_eq_hrir_S: [1x1 struct]
%
% hc.l_eq_hrir_S
%          elev_v: [187x1 double]
%          azim_v: [187x1 double]
%          type_s: 'FIR'
%     sampling_hz: 44100
%       content_m: [187x512 double] - IR length = 512

% IRs not normalized (values for IRC_1002)
%
% max(max(hr.l_hrir_S.content_m)) =  0.3051
% min(min(hr.l_hrir_S.content_m)) = -0.3629
%
% max(max(abs(hr.l_hrir_S.content_m))) = 0.3629
% max(max(abs(hr.r_hrir_S.content_m))) = 0.5097
%
% max(max(hc.l_eq_hrir_S.content_m)) =  0.9274
% min(min(hc.l_eq_hrir_S.content_m)) = -1.5390
%
% max(max(abs(hc.l_eq_hrir_S.content_m))) = 1.5390
% max(max(abs(hc.r_eq_hrir_S.content_m))) = 1.6903

% HRIR Grids
%
% slab3d grid, group by azimuth (all el's at 180, at 150, etc.)
% az = 180:-30:-180;  % pos right
% el = 90:-18:-90;    % pos up
% sgrid = [kron(ones(size(az)),el); kron(az,ones(size(el)))];
%
% sgrid(:,1:20)
%   Columns 1 through 14
%     90    72    54    36    18     0   -18   -36   -54   -72   -90    90    72    54
%    180   180   180   180   180   180   180   180   180   180   180   150   150   150
%   Columns 15 through 20
%     36    18     0   -18   -36   -54
%    150   150   150   150   150   150
%
% Listen grid, group by elevation (all az's at -45, at -30, etc.)
% az forward 0 degrees, ccw positive 0 to 345
% el horizontal plane 0 degrees, -45 below to 90 above
% lgrid = [ hr.l_hrir_S.elev_v hr.l_hrir_S.azim_v ]';
% compensated grid same as raw grid
%
% lgrid(:,1:28)
%   Columns 1 through 14
%    -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -45
%      0    15    30    45    60    75    90   105   120   135   150   165   180   195
%   Columns 15 through 28
%    -45   -45   -45   -45   -45   -45   -45   -45   -45   -45   -30   -30   -30   -30
%    210   225   240   255   270   285   300   315   330   345     0    15    30    45
%
% Note: Listen grid not uniform.
%
% lgrid(:,end-20:end)
%   Columns 1 through 14
%     45    45    60    60    60    60    60    60    60    60    60    60    60    60
%    330   345     0    30    60    90   120   150   180   210   240   270   300   330
%   Columns 15 through 21
%     75    75    75    75    75    75    90
%      0    60   120   180   240   300     0
%
% Listen az   0 to 165 maps to slab3d 0 to -165 (-az left)
% Listen az 180 to 345 maps to slab3d 180 to 15 (+az right)
%
% Listen/slab3d els equivalent

% number of responses, compensated data IR length
[ resp irLen ] = size(hc.l_eq_hrir_S.content_m);

if numPts > irLen,
  disp('listcen2slab error: numPts > Listen database HRIR length.');
  return;
end;

% slab3d default sample rate is 44100
fs = hc.l_eq_hrir_S.sampling_hz;  % should be 44100
samp2us = 1000000/fs;
us2samp = 1/samp2us;
if fs ~= 44100,
  fprintf( 'listcen2slab warning: expected fs 44100, read %d.\n', fs );
end;

% rect window
win = ones(numPts,1);

% replace end of rect window with hanning taper;
% can reduce high-freq artifacts but can also smooth low freqs
winLen = 32;
winStart = winLen/2 + 1;
winTaper = hanning(winLen);
win(numPts-winLen/2+1:numPts) = winTaper(winStart:winLen);

% zero-pad rceps() minphase calc to reduce IR ripple artifacts
zeroPad = 1024;

% mat2slab() formatting
%
% slab array formatting (post-processed jdm.slh example)
% [ hrir, itd, sgrid, v, n, d, c, a, e, p, f ] = slab2mat( 'jdm.slh' );
% hrir:   128x286 (128-point IRs, all L followed by all R)
% itd:    1x143
% sgrid:  2x143 (az inc 30, el inc 18, full spherical uniform grid)
%         143 = (1+360/30) * (1+180/18), note duplicate az

% slab-format hrirs (minphase)
hrir = zeros( numPts, resp*2 );

% ITDs, in samples
itdC = zeros(1,resp);

% hrir grid
lgrid = [ hc.l_eq_hrir_S.elev_v hc.l_eq_hrir_S.azim_v ]';
lgrid(2,:) = -lgrid(2,:);  % Listen az to slab3d az

% minphase/win/format HRIRs and extract ITDs
for g=1:resp,
  % convert Listen's HRIRs to minphase, window result
  if irLen < zeroPad,
    irL = [ hc.l_eq_hrir_S.content_m(g,:)'; zeros(zeroPad-irLen,1) ];
    irR = [ hc.r_eq_hrir_S.content_m(g,:)'; zeros(zeroPad-irLen,1) ];
  else
    irL = hc.l_eq_hrir_S.content_m(g,:)';
    irR = hc.r_eq_hrir_S.content_m(g,:)';
  end;
  [ dummy mpL ] = rceps( irL );
  hrir( :, g ) = win .* mpL(1:numPts);
  [ dummy mpR ] = rceps( irR );
  hrir( :, g + resp ) = win .* mpR(1:numPts);

  % reduce map2map() ITD biases by tying down the el +90
  % grid location to 0 ITD (concept continued after loop)
  if lgrid(1,g) == 90,
    itdC(g) = 0;
  else
    % spherical head model ITDs
    % itdC(g) = sitd( lgrid(2,g), lgrid(1,g), 0.09, 1.95 ) * us2samp;

    % use raw HRIRs for ITD extraction
    %
    % delay calcs based on IR centroid:
    %   Minnaar et al, "The Interaural Time Difference in Binaural Synthesis",
    %   AES 108th Convention, Paris, 2000, Preprint 5133

    % window to capture actual HRIR, increase signal-to-noise, and omit
    % potential reflections; zero pad to reduce rceps artifacts
    [mxL startL] = max(abs(hr.l_hrir_S.content_m(g,:)));
    [mxR startR] = max(abs(hr.r_hrir_S.content_m(g,:)));
    start = min([startL startR]) - 32;
    if start < 1,
      start = 1;
    end;
    itdWin = 256;
    winL = hr.l_hrir_S.content_m(g,start:start+itdWin-1)';
    winR = hr.r_hrir_S.content_m(g,start:start+itdWin-1)';
    irL = [ winL; zeros(zeroPad-itdWin,1) ];
    irR = [ winR; zeros(zeroPad-itdWin,1) ];

    % minphase HRIRs
    % !!!! Note: IRC_1055 45,-120 produced mpR NaNs.
    % non-pow2 IR length seems to eliminate NaNs should they occur
    [ dummy mpL ] = rceps( irL );
    if any(isnan(mpL)),
      disp('listcen2slab warning: rceps NaNs, trying non-pow2 IR length.');
      [ dummy mpL ] = rceps( irL(1:end-1) );
      mpL = [mpL;0];
    end;
    [ dummy mpR ] = rceps( irR );
    if any(isnan(mpR)),
      disp('listcen2slab warning: rceps NaNs, trying non-pow2 IR length.');
      [ dummy mpR ] = rceps( irR(1:end-1) );
      mpR = [mpR;0];
    end;
    len = length(mpL);

    % raw IR and minphase IR energies
    irL = irL.*irL;
    irR = irR.*irR;
    mpL = mpL.*mpL;
    mpR = mpR.*mpR;

    % left time delay calc using centroid
    centL = sum(irL.*[1:len]')/sum(irL);
    centLmp = sum(mpL.*[1:len]')/sum(mpL);
    tl = centL - centLmp;

    % right time delay calc using centroid
    centR = sum(irR.*[1:len]')/sum(irR);
    centRmp = sum(mpR.*[1:len]')/sum(mpR);
    tr = centR - centRmp;

    % centroid ITD calc
    itdC(g) = tl-tr;
  end;
end;

% reduce map2map() ITD biases by tying down az 0,-180 and el -90
% unmeasured grid locations to 0 ITD
itdGrid = [ [ [-90; 0] [-75; 0] [-75; -180] [-60; 0] [-60; -180] ] lgrid ];
itd = [ 0 0 0 0 0 itdC ];

% use mat2slab() to finish conversion (uniform grid, scaling, etc.)
slabFileName = [ subName '.slh' ];
mat2slab( slabFileName, hrir, itd, lgrid, azInc, elInc, numPts, ...
          strName, strComment, fs, scale, itdGrid );

% stop timer
% HP DV9000 Intel Core2 T7200 2GHz 2GB 32-bit Win7
% listcen2slab(1002)  "Elapsed time is 7.631212 seconds."
toc;
