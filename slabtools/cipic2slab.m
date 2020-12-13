function cipic2slab( subNum, azInc, elInc, numPts, strName, ...
                     strComment, scale )
% cipic2slab - converts a CIPIC .mat to a slab3d HRTF database (SLH).
%
% cipic2slab( subNum, azInc, elInc, numPts, strName, strComment, scale )
%
% subNum     - CIPIC subject number
% azInc      - output azimuth increment (default = 5)
% elInc      - output elevation increment (default = 5)
% numPts     - number of FIR points in each HRIR (default = 128)
% strName    - name of head (< 32 chars) (default = subject_###)
% strComment - comment string (< 256 chars) (default = empty)
% scale      - scale HRIR to +/- 1.0 flag (default = 1)
%
% cipic2slab() requires the user to be cd'd to the CIPIC database directory
% standard_hrir_database\ (installed on a hard drive).
%
% The output filename is formatted subject_###.slh, e.g., subject_127.slh.
%
% Output data is formatted to the slab3d grid defined below:
%   az = [180:-azInc:-180]; el = [90:-elInc:-90];
%   sgrid = [kron(ones(size(az)),el); kron(az,ones(size(el)))];
%
% See also: mat2slab, grids, cfull, ctest, c2s, cipic2sarc, listen2slab

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.09.11  JDM  created
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
  disp('cipic2slab error: incorrect number of parameters.');
  return;
end;

subName = sprintf( 'subject_%03d', subNum );

% parameter defaults
if nargin < 7, scale = 1; end;
if nargin < 6, strComment = ''; end;
if nargin < 5, strName = subName; end;
if nargin < 4, numPts = 128; end;
if nargin < 3, elInc = 5; end;
if nargin < 2, azInc = 5; end;

% CIPIC directory structure:
% CIPIC_hrtf_database\standard_hrir_database\subject_127\hrir_final.mat
%
% user should be cd'd to: CIPIC_hrtf_database\standard_hrir_database\
cmat = load( [ subName '\hrir_final.mat' ] );
fprintf( 'Processing %s...\n', subName );

% cipic HRIR length
irLen = size(cmat.hrir_l,3);

if numPts > irLen,
  fprintf( ['cipic2slab error: numPts must be less than or equal to ' ...
    'CIPIC IR length (%d)\n'], irLen );
  return;
end;

% cipic grid in cipic coords (interaural-polar coords)
% els-grouped-by-az (e.g., all els at -80 az and so on)
% el = cgrid( 1, index )
% az = cgrid( 2, index )
cel = -45 + 5.625*(0:49);
caz = [ -80 -65 -55 -45:5:45 55 65 80 ];
cgrid = [kron(ones(size(caz)),cel); kron(caz,ones(size(cel)))];
cazNum = length(caz);
celNum = length(cel);

% slab grid in slab coords (vertical-polar coords)
% el = [90:-elInc:-90];
% az = [180:-azInc:-180];
% sgrid = [kron(ones(size(az)),el); kron(az,ones(size(el)))];

if size(cmat.hrir_l,1) ~= cazNum || size(cmat.hrir_l,2) ~= celNum,
  disp('cipic2slab error: cipic hrir data dims do not match default cipic grid.');
  return;
end;

% number of response pairs
resp = cazNum * celNum;

% slab array formatting (post-processed jdm.slh example)
% [ hrir, itd, sgrid, v, n, d, c, a, e, p, f ] = slab2mat( 'jdm.slh' );
% hrir:   128x286 (128-point IRs, all L followed by all R)
% itd:    1x143
% sgrid:  2x143 (az inc 30, el inc 18, full spherical uniform grid)
%         143 = (1+360/30) * (1+180/18), note duplicate az

% cipic hrirs (not-minphase) to slab hrirs (minphase),
% the two also use different array formats
cshrir = zeros( numPts, resp*2 );

% cipic ITD (unsigned) to slab ITD (signed)
csitd = zeros(1,resp);

% cipic grid (cipic coords) to slab grid (slab coords)
csgrid = zeros(2,resp);

% zero-pad rceps() minphase calc to reduce IR ripple
zeroPad = 1024;

% rect window with 16-point hanning taper
win = ones(numPts,1);
winLen = 32;
winTaper = hanning(winLen);
win(numPts-winLen/2+1:numPts) = winTaper(winLen/2+1:winLen);

% sample rate
fs = 44100;
samp2us = 1000000/fs;
us2samp = 1/samp2us;

% convert measurement grid, HRIRs, and ITDs
i = 1;
for az=1:cazNum,
  for el=1:celNum,
    % convert cipic's HRIRs to minphase
    irL = [ squeeze(cmat.hrir_l(az,el,:)); zeros(zeroPad-irLen,1) ];
    [ dummy mpL ] = rceps( irL );
    cshrir( :, (az-1)*celNum + el ) = win .* mpL(1:numPts);
    irR = [ squeeze(cmat.hrir_r(az,el,:)); zeros(zeroPad-irLen,1) ];
    [ dummy mpR ] = rceps( irR );
    cshrir( :, (az-1)*celNum + el + resp ) = win .* mpR(1:numPts);

    % convert measurement grid from cipic interaural polar coords to
    % slab3d vertical polar coords
    [ saz sel ] = c2s( cgrid(2,i), cgrid(1,i) );
    csgrid(:,i) = [sel;saz];

    % reduce map2map() ITD biases by tying down the slab3d el +90
    % grid location to 0 ITD (concept continued after loop)
    if cgrid(1,i) == 90 && cgrid(2,i) == 0,
      csitd(i) = 0;
    else
      % cipic OnL-OnR is signed version of cipic ITD;
      % in slab3d:  src L, -az, -itd, lag right 
      %             src R, +az, +itd, lag left
      csitd(i) = cmat.OnL(az,el) - cmat.OnR(az,el);

      % spherical head model ITDs
      %csitd(i) = sitd( saz, sel, 0.09, 1.0 ) * us2samp;

      % ITD extraction using delay calcs based on IR centroid
      % (not used, for investigation purposes only)
      %
      % Note: This technique is for raw responses!
      % The CIPIC collection contains compensated data, thus the CIPIC
      % ITDs are used directly.
      %
      % Reference:
      % Minnaar et al, "The Interaural Time Difference in Binaural Synthesis",
      % AES 108th Convention, Paris, 2000, Preprint 5133
      if 0,
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
      csitd(i) = tl-tr;
      end;
    end;

    i = i + 1;
  end;
end;

% reduce map2map() ITD biases by tying down slab3d az 0,-180 and el -90
% unmeasured grid locations to 0 ITD
el0 = -50:-5:-90;    % els for az 0
el180 = -55:-5:-85;  % els for az 180
grid0 = [ [ el0; zeros(size(el0)) ] [ el180; 180*ones(size(el180)) ] ];
itdGrid = [ grid0 csgrid ];
itd = [ zeros(1,size(grid0,2)) csitd ];

% use mat2slab() to finish conversion (uniform grid, scaling, etc.)
slabFileName = [ subName '.slh' ];
mat2slab( slabFileName, cshrir, itd, csgrid, azInc, elInc, numPts, ...
          strName, strComment, 44100, scale, itdGrid );

% stop timer
% HP DV9000 Intel Core2 T7200 2GHz 2GB 32-bit Win7
% cipic2slab(127,30,18)  "Elapsed time is 61.500280 seconds."
% cipic2slab(127,10,10)  "Elapsed time is 91.142705 seconds."
% cipic2slab(127) (5,5)  "Elapsed time is 223.736632 seconds.
toc;
