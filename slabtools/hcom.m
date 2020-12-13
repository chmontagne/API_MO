function statret = hcom( h1, h2, ear, azp, elp, magplot, table, energy, ...
                         itd, bcbe, nout )
% hcom - HRTF database comparison utility.
%
% ed = hcom( h1, h2, ear, az, el, magplot, table, energy, itd, bcbe, nout );
%
% h1:       slab3d archive struct
%
% h2:       slab3d archive struct for comparison.  If not specified, hcom()
%           performs a symmetric head test (default = []).
%
% ear:      Ear to compare, 'l' or 'r' (default = 'l').
%
% az:       Azimuth to view (see h1.dgrid(2,:) for acceptable values).
%           If az = -1 and el ~= -1, plot freq vs az vs difference for el
%           (default = -1).
%
% el:       Elevation to view (see h1.dgrid(1,:) for acceptable values).
%           If el = -1 and az ~= -1, plot freq vs el vs difference for az
%           (default = -1).
%
% magplot:  Flag, display HRIR magnitude response plot (default = 0).
%
% table:    Flag, display metrics for each grid location (default = 0).
%
% energy:   Flag, display frequency-computed energy plots for each HRTF
%           database (default = 0).
%
% itd:      Flag, display ITDs for each HRTF database (default = 0).
%
% bcbe:     Flag, use critical band energy when calculating spectral difference
%           (default = 1).
%
% nout:     do not generate figures or verbose text (default = 0)
%
% hcom() provides a variety of displays for HRTF comparison.  hcom also
% calculates the following difference metrics:
%     SED(w), SED RMS, CBED(w), CBED RMS
% SED(w) is the spectral energy ratio difference (i.e., the difference
% between two log-scale magnitude responses).  SED RMS, the RMS of the SED(w)
% difference sequence, captures the difference across all frequency bands.
% Critical-Band (CB) filtering (20 bands between 20Hz and 20kHz) can be
% performed to improve the perceptual significance of the difference.
% In this case, CBED(w) and CBED RMS are calculated in place of SED(w) and
% SED RMS.
%
% hcom() can display a difference table and the following figures:
%    1) az vs el vs RMS difference
%    2) for a single az, freq vs el vs difference
%    3) for a single el, freq vs az vs difference
%    4) for an (az,el) pair, freq vs mag and freq vs difference
%    5) h1 ITD
%    6) h2 ITD
%    7) h1/h2 ITD differences
%    8) left ear energy
%    9) right ear energy
%   10) h1/h2 energy differences
%
% Note: All gray colormaps are inverted, i.e., large values dark.
%
% See Also: hlab.m, hen.m, vir.m, vitd.m

% modification history
% --------------------
% 05.17.01  JDM  created for paper "HRTF Error Analysis using Spectral Power
%                Ratios", Stanford, MUS151, Spring01
% 05.30.01  JDM  added "week later" repeated measurement test and interp test
%                ----  v5.3.0  ----
% 08.27.03  JDM  hcom.m created from aderr.m and adsurf.m
%                ----  v5.4.0  ----
% 11.05.03  JDM  added symmetric ITD comparison
% 11.07.03  JDM  abs'd itdd
% 11.19.03  JDM  added 10*log10() and length() div to energy calc
% 11.21.03  JDM  updated to new v4 sarc
% 11.24.03  JDM  added energy displays
% 12.01.03  JDM  added caxis() to surf plots; changed axis ranges and view
%                angles; added title means
% 12.08.03  JDM  removed rmsvec12 (now use emat); added stats()
% 12.10.03  JDM  improved defaults, error checks; made itd test optional;
%                added reflected az exist check (ircam data); hrir1 -> h.ir;
%                map1 -> h.dgrid; az/el inc calc to sarc field; added li;
%                44100 -> h.fs
% 12.15.03  JDM  az/el loop incs to grid inc for CIPIC data
% 12.16.03  JDM  added table, energy, itd args; changed arg order; added imgoff,
%                bWater, axis xy to water
% 01.07.04  JDM  added colormap help note; updated comments
%                ----  v5.5.0  ----
% 06.09.04  JDM  magplot now supports non-fixed-inc grids; changed azp,elp
%                wildcard from 1 to -1 so index 1 can be viewed for
%                non-fixed-inc grids
% 08.30.04  JDM  added mins to stats()
%                ----  v5.8.0  ----
% 02.28.06  JDM  added cbe()
% 03.08.06  JDM  increased cbe() bands to 24 for 96kHz data so 20 bands in
%                audible range
%                ----  v5.8.1  ----
% 06.14.06  JDM  h/hc -> h1/h2; symmetric head test rewrite; cbe as option;
%                calc one location w/o calc all
% 06.21.06  JDM  "error" -> "difference"
% 06.25.06  JDM  emax axis() const to errmax to avoid conflict with energy;
%                removed view(2) from image plots (leftover from surf method);
%                added imagesc scale; errmax applied to all error axes
%                ----  v6.6.0  ----
% 04.20.11  JDM  added nout param and statret return
%                ----  v6.6.1  ----
% 04.18.12  JDM  added IID
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
  disp( 'hcom: missing arguments.' );
  return;
end;

% defaults
if nargin < 2,   h2 = [];      end;
if nargin < 3,   ear = 'l';    end;
if nargin < 4,   azp = -1;     end;
if nargin < 5,   elp = -1;     end;
if nargin < 6,   magplot = 0;  end;
if nargin < 7,   table = 0;    end;
if nargin < 8,   energy = 0;   end;
if nargin < 9,   itd = 0;      end;
if nargin < 10,  bcbe = 1;     end;
if nargin < 11,  nout = 0;     end;

% if database comparison
if ~isempty( h2 ),
  % databases must have identical grids
  if h2.dgrid ~= h1.dgrid,
    disp( 'hcom: sarc grids not compatible.' );
    return;
  end;

  % increment type check
  if h2.finc ~= h1.finc,
    disp( 'hcom: sarc increment types not compatible.' );
    return;
  end;

  % same inc check
  if h2.azinc ~= h1.azinc | h2.elinc ~= h1.elinc,
    disp( 'hcom: sarc increments not compatible.' );
    return;
  end;

  % same sample rate check
  if h2.fs ~= h1.fs,
    disp( 'hcom difference: sarc sample rates not compatible.' );
    return;
  end;
end;

% fixed-inc az,el groupings or alternate coord sys groupings
if h1.finc,
  azmap = [ max(h1.dgrid(2,:)) : -h1.azinc : min(h1.dgrid(2,:)) ];
  elmap = [ max(h1.dgrid(1,:)) : -h1.elinc : min(h1.dgrid(1,:)) ];
  if azp == -1,
    imgoff = ceil(h1.azinc/2);
  else,
    imgoff = ceil(h1.elinc/2);
  end;
else, % for CIPIC data
  azmap = [ 1:h1.azinc ];  % index instead of actual az
  elmap = [ 1:h1.elinc ];  % index instead of actual el
  imgoff = 0.5;
end;

aznum = length(azmap);          % # az locations
elnum = length(elmap);          % # el locations
N     = 1024;
finc  = h1.fs/(2*N);            % freq bin inc in freqz()
li    = ceil(20/finc) + 1;      % low freq bin index of interest
mi    = floor(20000/finc) + 1;  % max freq bin index of interest
emat  = zeros( aznum, elnum );  % RMS difference
e1    = zeros( aznum, elnum );  % HRIR 1 energy
e2    = zeros( aznum, elnum );  % HRIR 2 energy
ed    = zeros( aznum, elnum );  % energy difference
itd1  = zeros( aznum, elnum );  % ITD 1
itd2  = zeros( aznum, elnum );  % ITD 2
itdd  = zeros( aznum, elnum );  % ITD difference
e1lin = zeros( 1, aznum*elnum );  % HRIR 1 energy, linear scale
e2lin = zeros( 1, aznum*elnum );  % HRIR 2 energy, linear scale
allAzEl = [];
errmax  = 10;

% if h2 not provided, prepare for symmetric head test
if isempty( h2 ),
  h2 = h1;
  h2.name = [ h1.name ' (symmetric)' ];
  numresps = size( h2.dgrid, 2 );
  for i = 1:numresps,
    az = h2.dgrid( 2, i );
    el = h2.dgrid( 1, i );
    % if symmetric az exists, replace current az IR and ITD with -az
    if ~isempty( hindex( -az, el, h1.dgrid ) ) | az == 180,
      if az == 180,
        zz = az;
      else,
        zz = -az;
      end;

      % h2 left ear az = h1 right ear -az
      h2.ir( :, hindex( az, el, h2.dgrid ) ) = ...
      h1.ir( :, hindex( zz, el, h1.dgrid ) + numresps );
      % right ear
      h2.ir( :, hindex( az, el, h2.dgrid ) + numresps ) = ...
      h1.ir( :, hindex( zz, el, h1.dgrid ) );
    
      if ~isempty( h1.itd ),
         h2.itd( hindex( az, el, h2.dgrid ) ) = ...
        -h1.itd( hindex( zz, el, h1.dgrid ) );
      end;
    end;
  end;
else % if comparing two databases, display ear compared
  if ear == 'r',
    fprintf( '\nRight Ear Analysis\n' );
  else,
    fprintf( '\nLeft Ear Analysis\n' );
  end;
end;

% database names
if ~nout,
  fprintf( '\nHRTF 1: %s\n', h1.name );
  if ~isempty( h2 ),
    fprintf( 'HRTF 2: %s\n', h2.name );
  end;
else
  fprintf( '%s  ', h1.name );
end;

% table heading
if table,
  fprintf( '\n   Az     El     Energy1 Energy2  adif   RMS Diff  ITD1(us) ITD2(us)    adif\n' );
end;

% flag indicating hcom examining all database locations
bAllLoc = (azp == -1 & elp == -1);

maxIID = 0.0;
gi = 0;
for azi = 1:aznum,
for eli = 1:elnum,
  gi = gi + 1;
  az = h1.dgrid(2,gi);
  el = h1.dgrid(1,gi);

  % flag indicating add current az,el to an all-az or all-el plot
  bAllAzElLoc = ...
   (h1.finc == 1 & ((azp == -1 & elp == el ) | (azp == az  & elp == -1 ))) | ...
   (h1.finc == 0 & ((azp == -1 & elp == eli) | (azp == azi & elp == -1 )));

  % flag indicating hcom only examining current location
  bOneLoc = (h1.finc == 1 & (azp == az  & elp == el)) | ...
            (h1.finc == 0 & (azp == azi & elp == eli));

  % examine current az,el?
  if bAllLoc | bOneLoc | bAllAzElLoc,

    % frequency domain data
    if ear == 'r',
      % right ear h
      [H1,frq] = freqz( h1.ir(:,hir(az,el,h1.dgrid)), 1, N, h1.fs );
      % right ear h2
      [H2,frq] = freqz( h2.ir(:,hir(az,el,h1.dgrid)), 1, N, h1.fs );
      % h1 opposite ear, for IID metric (see vcenf.m)
      [Ho,frq] = freqz( h1.ir(:,hil(az,el,h1.dgrid)), 1, N, h1.fs );
    else,
      % left ear h
      [H1,frq] = freqz( h1.ir(:,hil(az,el,h1.dgrid)), 1, N, h1.fs );
      % left ear h2
      [H2,frq] = freqz( h2.ir(:,hil(az,el,h1.dgrid)), 1, N, h1.fs );
      % h1 opposite ear, for IID metric (see vcenf.m)
      [Ho,frq] = freqz( h1.ir(:,hir(az,el,h1.dgrid)), 1, N, h1.fs );
    end;

    % remove frequencies outside 20-20000 Hz from analysis
    % (comment-out to compare freq energy to time energy)
    frq  = frq(li:mi);
    
    % energy magnitude
    h1p = abs(H1(li:mi)).^2;
    h2p = abs(H2(li:mi)).^2;

    % find maximum interaural intensity difference
    iid = abs( 10*log10(sum(abs(Ho(li:mi)).^2)/N) - 10*log10(sum(h1p)/N) );
    if iid > maxIID,
      maxIID = iid;
    end;

    if ~bcbe,
      % energy
      h1dB = 10*log10(h1p);
      h2dB = 10*log10(h2p);
    else,
      % calculate using critical band energy
      bandn1 = 20;
      bandn2 = 20;
      if h1.fs == 96000,
        bandn1 = 24;
      end;
      if h2.fs == 96000,
        bandn2 = 24;
      end;
      bandHigh = 20;  % high-freq band#
      [ ncbe1, frq ] = cbe( h1, az, el, ear == 'l', bandn1, 100, 1 );
      [ ncbe2, frq ] = cbe( h2, az, el, ear == 'l', bandn2, 100, 1 );
      h1dB = 10*log10(ncbe1(1:bandHigh));
      h2dB = 10*log10(ncbe2(1:bandHigh));
      frq = frq(1:bandHigh);
    end;

    % difference in dB = abs( 10*log10( h1p / h2p ) )
    errdiff = abs( h1dB - h2dB );

    % spectral energy ratio difference RMS;
    % calculate RMS difference (RMS Error formula = standard deviation formula)
    rms_err = sqrt( sum( errdiff.^2 ) / (length(errdiff)-1) );

    emat( azi, eli ) = rms_err;

    % mag plot
    if magplot,
      if bcbe,
        sym = 'o';
      else,
        sym = '';
      end;
      % plot magnitude responses on subplot 1 of mag plot
      subplot(2,1,1);
      semilogx( frq, h1dB, ['r-' sym], frq, h2dB, ['b--' sym] );
      title( sprintf( 'HRTF Magnitude Repsonses (%.0f,%.0f)', az, el ) );
      xlabel( 'Frequency (Hz)' );
      ylabel( 'Magnitude (dB)' );
      axis([20 20000 -50 25]); grid;
      legend( 'HRTF1', 'HRTF2', 4 );

      % plot difference on subplot 2 of mag plot
      subplot(2,1,2);
      semilogx( frq, errdiff, ['k-' sym] );
      title( sprintf( 'Spectral Energy Difference (%5.2f)', rms_err ) );
      xlabel( 'Frequency (Hz)' );
      ylabel( 'Difference (dB)' );
      axis([20 20000 0 2*errmax]); grid;
    end;

    % errdiff by-az or by-el plot
    if bAllAzElLoc,
      allAzEl = [ allAzEl, errdiff ];
    end;

    % print az el left_energy right_energy energy_diff rms_err;
    % freq energy approximates IR-based energy (see henfilt())
    e1lin(gi) = sum(h1p)/length(h1p);
    e2lin(gi) = sum(h2p)/length(h2p);
    e1( azi, eli ) = 10*log10( e1lin(gi) );
    e2( azi, eli ) = 10*log10( e2lin(gi) );
    ed( azi, eli ) = abs( e1( azi, eli ) - e2( azi, eli ) );
    if ~isempty( h1.itd ) & ~isempty( h2.itd ), % compare
      itd1( azi, eli ) = h1.itd( hindex(az,el,h1.dgrid) )/(h1.fs/1000000.0);
      itd2( azi, eli ) = h2.itd( hindex(az,el,h1.dgrid) )/(h2.fs/1000000.0);
    end;
    itdd( azi, eli ) = abs( itd1( azi, eli ) - itd2( azi, eli ) );

    if table,
      fprintf( '%7.2f %6.2f %7.2f %7.2f %8.2f %7.2f   %8.1f %8.1f %8.1f\n', ...
        az, el, e1( azi, eli ), e2( azi, eli ), ed( azi, eli ), rms_err, ...
        itd1( azi, eli ), itd2( azi, eli ), itdd( azi, eli ) );
    end;

    if magplot && (azp == -1 || elp == -1),
      pause;
    end;

  end;
end;
end;

% stats

if ~nout,
  fprintf( '\nRMS Difference Stats:\n\n' );
end;
[ meanrms rmedian rstd rmax rmaxaz rmaxel rmin ] = ...
  stats( emat, azmap, elmap, nout );

if ~nout,
  fprintf( '\nITD Difference Stats:\n\n' );
end;
[ meanitd imedian istd imax imaxaz imaxel imin ] = ...
  stats( itdd, azmap, elmap, nout );

if ~nout,
  fprintf( '\nEnergy Difference Stats:\n\n' );
end;
[ meaned emedian estd emax emaxaz emaxel emin ] = ...
  stats( ed, azmap, elmap, nout );

% Note re hcom()/hen() metric values:
% If all frequencies are included, the hcom() frequency-domain and hen()
% time-domain energy values are consistent (as expected due to the
% Rayleigh Energy Theorem (or Parseval's Theorem)).
% (O&S, pg.58, 320 Reader pg.118)

% max/min energies in dB
maxL = max(max(e1));
minL = min(min(e1));
maxR = max(max(e2));
minR = min(min(e2));

% avg energies in dB
mL = mean(e1lin);
mR = mean(e2lin);
mlAll = 10*log10(mL);
mrAll = 10*log10(mR);
mAll  = 10*log10(mean([mL mR]));

statret = [ mAll maxL minL mlAll maxR minR mrAll ...
            maxL-maxR minL-minR mlAll-mrAll maxIID...
            rmax rmin meanrms emax emin meaned ];

if nout, % terse output
  fprintf( [ 'T %4.1f  L %4.1f %5.1f %4.1f  ' ...
    'R %4.1f %5.1f %4.1f  D %4.1f %4.1f %4.1f  IID %4.1f  ' ...
    'RMS %4.1f %4.1f %4.1f  E %4.1f %4.1f %4.1f\n' ], statret );
else
  fprintf( '\n' );
end;

% image plot
if ~nout && ~isempty(allAzEl),
  figure;

  % invert gray colormap
  colormap('gray');
  map=colormap;
  colormap(ones(size(map))-map);

  if azp == -1,
    imagesc( frq, azmap, allAzEl', [ 0 errmax ] );
    axis( [ 20 20000 min(azmap)-imgoff max(azmap)+imgoff ] );
    axis xy;
    ylabel('Azimuth');
    title( sprintf( 'Spectral Energy Difference (%d degrees elevation)', ...
           elp ) );
  else,
    imagesc( frq, elmap, allAzEl', [ 0 errmax ] );
    axis( [ 20 20000 min(elmap)-imgoff max(elmap)+imgoff ] );
    axis xy;
    ylabel('Elevation');
    title( sprintf( 'Spectral Energy Difference (%d degrees azimuth)', ...
           azp ) );
  end;
  xlabel('Frequency (Hz)');
end;

% surface plot view angle
viewaz = -65;
viewel = 40;

% RMS Difference surface plot
if ~nout,
figure;
surf( azmap, elmap, emat' );
axis( [ min(azmap) max(azmap) min(elmap) max(elmap) 0 errmax ] );
xlabel('Azimuth');
ylabel('Elevation');
zlabel('RMS Difference (dB)');
title( sprintf('Spectral Energy Difference (mean = %.2f)',meanrms) );
colormap('gray');
map=colormap;
colormap(ones(size(map))-map);
view( viewaz, viewel );
caxis( [ 0 errmax ] );
end;

% energy plots
if ~nout && energy,

% energy 1 surface plot
figure;
surf( azmap, elmap, e1' );
axis( [ min(azmap) max(azmap) min(elmap) max(elmap) -30 5 ] );
xlabel('Azimuth');
ylabel('Elevation');
zlabel('Energy (dB)');
title('HRIR 1 Frequency Energy');
colormap(JET);
view( viewaz, viewel );
caxis( [ -30 5 ] );

% energy 2 surface plot
figure;
surf( azmap, elmap, e2' );
axis( [ min(azmap) max(azmap) min(elmap) max(elmap) -30 5 ] );
xlabel('Azimuth');
ylabel('Elevation');
zlabel('Energy (dB)');
title('HRIR 2 Frequency Energy');
colormap(JET);
view( viewaz, viewel );
caxis( [ -30 5 ] );

end;

% energy difference surface plot
if ~nout,
figure;
surf( azmap, elmap, ed' );
axis( [ min(azmap) max(azmap) min(elmap) max(elmap) 0 7 ] );
%axis tight;
xlabel('Azimuth');
ylabel('Elevation');
zlabel('Energy (dB)');
title( sprintf('HRIR Frequency Energy Difference (mean = %.2f)',meaned) );
colormap('gray');
map=colormap;
colormap(ones(size(map))-map);
view( viewaz, viewel );
caxis( [ 0 7 ] );
end;

% ITD plots
if ~nout && itd,

% ITD HRIR 1 surface plot
figure;
surf( azmap, elmap, itd1' );
axis( [ min(azmap) max(azmap) min(elmap) max(elmap) -1100 1100 ] );
xlabel('Azimuth');
ylabel('Elevation');
zlabel('us');
title('ITD1');
colormap(JET);
% below hard to see, this might be better...
%view( -50, 4 );
view( viewaz, viewel );
caxis( [ -1100 1100 ] );

% ITD HRIR 2 surface plot
figure;
surf( azmap, elmap, itd2' );
axis( [ min(azmap) max(azmap) min(elmap) max(elmap) -1100 1100 ] );
xlabel('Azimuth');
ylabel('Elevation');
zlabel('us');
title('ITD2');
colormap(JET);
view( viewaz, viewel );
caxis( [ -1100 1100 ] );

end;

% ITD difference surface plot
if ~nout,
figure;
surf( azmap, elmap, itdd' );
axis( [ min(azmap) max(azmap) min(elmap) max(elmap) 0 500 ] );
xlabel('Azimuth');
ylabel('Elevation');
zlabel('us');
title( sprintf('ITD Difference (mean = %.2f)',meanitd) );
colormap('gray');
map=colormap;
colormap(ones(size(map))-map);
view( viewaz, viewel );
caxis( [ 0 500 ] );
end;

%------------------------------------------------------------------------------
% stats() - compute stats

function [ smean, smedian, sstd, smax, smaxaz, smaxel, smin ] = ...
  stats( smat, azmap, elmap, nout )

% mean
smean = mean(mean(smat));
% need 1d array for median() and std()
smat1 = reshape(smat,size(smat,1)*size(smat,2),1);
% median
smedian = median( smat1 );
% std
sstd = std( smat1 );
% max az and el
[ maxs azs ] = max( smat );
[ smax smaxel ] = max( maxs );
smaxaz = azs( smaxel );
% min az and el
[ mins azs ] = min( smat );
[ smin sminel ] = min( mins );
sminaz = azs( sminel );

if ~nout,
fprintf( '  Mean:          %7.2f\n', smean );
fprintf( '  Median:        %7.2f\n', smedian );
fprintf( '  Standard Dev:  %7.2f\n', sstd );
fprintf( '  Min:           %7.2f\n', smin );
fprintf( '  Min Az:        %7d\n',   azmap( sminaz ) );
fprintf( '  Min El:        %7d\n',   elmap( sminel ) );
fprintf( '  Max:           %7.2f\n', smax );
fprintf( '  Max Az:        %7d\n',   azmap( smaxaz ) );
fprintf( '  Max El:        %7d\n',   elmap( smaxel ) );
end;
