% ltest - test and examine listen2slab() processing.
%
% Note: This is a rough development script for testing and visualizing
%       listen2slab() processing.
%
% See also: listen2slab

% modification history
% --------------------
%                ----  v6.6.0  ----
% 03.03.11  JDM  created
%                ----  v6.6.1  ----
% 01.16.12  JDM  added group delay ITD extraction method
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

% See: http://recherche.ircam.fr/equipes/salles/listen/download.html
%
% Impulse responses sampling rate is 44100 Hz, measurement length is
% 8192 points, and quantification is 24 bits.

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

% !!!! _R0195_ 1.95m measurement sphere
% (Snapshot varies, HeadZap 0.9m, CIPIC 1m)

% !!!! demonstrates rceps() NaNs
%subNum = 1055;

%subNum = 1002;  % first database, nice ITD curve
subNum = 1056;
% EL15  97
% EL30  121
% EL45  145
gstart = 1;  % HRIR to start with
dispGD = 0;  % display group delay details
strName = sprintf( 'IRC_%04d', subNum );
rawName = [ strName '_R_HRIR' ];
compName = [ strName '_C_HRIR' ];

hr = load(rawName);
hc = load(compName);

% ----  raw data  ----

% IRC_1002:  -0.3629  0.3051
fprintf('Raw IR min max:  %.2f  %.2f\n', min(min(hr.l_hrir_S.content_m)), ...
        max(max(hr.l_hrir_S.content_m)));
mr = 0.4;

if 0,

% hr.l_hrir_S: [1x1 struct]
% hr.r_hrir_S: [1x1 struct]
%
% hr.l_hrir_S
%          type_s: 'FIR'
%          elev_v: [187x1 double]
%          azim_v: [187x1 double]
%     sampling_hz: 44100
%       content_m: [187x8192 double] - IR length = 8192

% Listen grid
lgrid = [ hr.l_hrir_S.elev_v hr.l_hrir_S.azim_v ]';

% [ min(lgrid(1,:)) max(lgrid(1,:)) ] = -45    90  % els
% [ min(lgrid(2,:)) max(lgrid(2,:)) ] =   0   345  % azs

% el horizontal plane 0 degrees, -45 below to 90 above
% az forward 0 degrees, ccw positive 0 to 345

figure;
resp = size(lgrid,2);
irLen = size(hr.l_hrir_S.content_m,2);
n = 512;
for k = 1:resp,
  plot( 1:n, hr.l_hrir_S.content_m(k,1:n), 'b', ...
        1:n, hr.r_hrir_S.content_m(k,1:n), 'r' );
  axis( [ 1 n -1 1 ] );
  title (lgrid(:,k));
  grid on;
  pause;
end;

end;

% ----  compensated data  ----

% !!!! diffuse-field eq
% (Snapshot also diffuse, HeadZap and CIPIC free-field eq)

% hc.l_eq_hrir_S: [1x1 struct]
% hc.r_eq_hrir_S: [1x1 struct]
%
% hc.l_eq_hrir_S
%          elev_v: [187x1 double]
%          azim_v: [187x1 double]
%          type_s: 'FIR'
%     sampling_hz: 44100
%       content_m: [187x512 double] - IR length = 512

% same grid as above
lgrid = [ hc.l_eq_hrir_S.elev_v hc.l_eq_hrir_S.azim_v ]';

% IRC_1002:  -1.5390  0.9274
fprintf('EQ  IR min max:  %.2f  %.2f\n', min(min(hc.l_eq_hrir_S.content_m)), ...
        max(max(hc.l_eq_hrir_S.content_m)));

% !!!! not-1.0-normalized!
% (neither was cipic)

resp = size(lgrid,2);
irLen = size(hc.l_eq_hrir_S.content_m,2);

if 0,
figure;
n = irLen;
for k = 1:resp,
  plot( 1:n, hc.l_eq_hrir_S.content_m(k,1:n), 'b', ...
        1:n, hc.r_eq_hrir_S.content_m(k,1:n), 'r' );
  axis( [ 1 n -1 1 ] );
  title (lgrid(:,k));
  grid on;
  pause;
end;
end;

% ----  all IRs - raw and post-diff-eq  ----

if 0,
figure;

% max(max(abs(hr.l_hrir_S.content_m))) = 0.3629
% max(max(abs(hr.r_hrir_S.content_m))) = 0.5097
mx = 0.6;
subplot(2,2,1);
plot(hr.l_hrir_S.content_m');
axis([1 1024 -mx mx]);  % HRIR length 8192
grid on;
title('left');

subplot(2,2,3);
plot(hr.r_hrir_S.content_m');
axis([1 1024 -mx mx]);
grid on;
title('right');

% max(max(abs(hc.l_eq_hrir_S.content_m))) = 1.5390
% max(max(abs(hc.r_eq_hrir_S.content_m))) = 1.6903
mx = 1.7;
subplot(2,2,2);
plot(hc.l_eq_hrir_S.content_m');
axis([1 512 -mx mx]);  % HRIR length 512
grid on;
title('left d-eq');

subplot(2,2,4);
plot(hc.r_eq_hrir_S.content_m');
axis([1 512 -mx mx]);
grid on;
title('right d-eq');

end;

% ----  grids  ----

% slab3d grid, group by azimuth (all el's at 180, at 150, etc.)
if 0,
az = 180:-30:-180;  % pos right
el = 90:-18:-90;    % pos up
sgrid = [kron(ones(size(az)),el); kron(az,ones(size(el)))];
end;

% sgrid(:,1:20)
%   Columns 1 through 14
%     90    72    54    36    18     0   -18   -36   -54   -72   -90    90    72    54
%    180   180   180   180   180   180   180   180   180   180   180   150   150   150
%   Columns 15 through 20
%     36    18     0   -18   -36   -54
%    150   150   150   150   150   150

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

% Listen az   0 to 165 maps to slab3d 0 to -165 (-az left)
% Listen az 180 to 345 maps to slab3d 180 to 15 (+az right)
%
% els equivalent

% Listen az to slab3d az
lgrid(2,:) = -lgrid(2,:);

% ----  mat2slab() formatting  ----

tic;

% slab array formatting (post-processed jdm.slh example)
% [ hrir, itd, sgrid, v, n, d, c, a, e, p, f ] = slab2mat( 'jdm.slh' );
% hrir:   128x286 (128-point IRs, all L followed by all R)
% itd:    1x143
% sgrid:  2x143 (az inc 30, el inc 18, full spherical uniform grid)
%         143 = (1+360/30) * (1+180/18), note duplicate az

% slab3d default sample rate
fs = 44100;  % check against hc.l_eq_hrir_S.sampling_hz
samp2us = 1000000/fs;
us2samp = 1/samp2us;

% slab3d default HRIR length
numPts = 128;

% rect window
win = ones(numPts,1);

% replace end of rect window with hanning taper;
% reduces high-freq (~20kHz) artifacts but smooths low freqs
winLen = 32;
winStart = winLen/2 + 1;
winTaper = hanning(winLen);
win(numPts-winLen/2+1:numPts) = winTaper(winStart:winLen);

% Listen hrirs (not-minphase) to slab hrirs (minphase),
% the two also use different array formats;
% zero-pad rceps() minphase calc to reduce IR ripple
zeroPad = 1024;
hrir = zeros( numPts, resp*2 );

% ITDs, in samples
itd = zeros(1,resp);
itdC = zeros(1,resp);  % centroid
itdX = zeros(1,resp);  % xcorr
itdG = zeros(1,resp);  % group delay
itdW = zeros(1,resp);  % weighted group delay
itdR = zeros(1,resp);  % above but rejecting extreme group delays
itdT = zeros(1,resp);  % threshold

% minphase/win/format HRIRs and extract ITDs
for g=gstart:resp,
  % convert Listen's HRIRs to minphase
  irLeq = [ hc.l_eq_hrir_S.content_m(g,:)'; zeros(zeroPad-irLen,1) ];
  irReq = [ hc.r_eq_hrir_S.content_m(g,:)'; zeros(zeroPad-irLen,1) ];
  [ dummy mpLeq ] = rceps( irLeq );
  hrir( :, g ) = win .* mpLeq(1:numPts);
  [ dummy mpReq ] = rceps( irReq );
  hrir( :, g + resp ) = win .* mpReq(1:numPts);

  % compare Listen post-diffuse-eq IR and post-mp/win IR
  if 0,
  figure(gcf);
  plotresp(irLeq,8192,fs,'g',20,fs/2,-60,20,1);
  hold on;
  %plotresp(hr.l_hrir_S.content_m(g,:),8182,fs,'k',20,fs/2,-60,20,1);
  plotresp(hrir(:,g),8192,fs,'b',20,fs/2,-60,20,1);
  subplot(2,1,1);
  title( sprintf( 'L (%d,%d)', lgrid(2,g), lgrid(1,g) ) );
  hold off;
  pause;
  end;

  % ----  spherical head model ITDs  ----

  % sitd(), spherical head ITD
  %   itd = sitd( az, el, hr, sld ), itd in us
  %   hr  - head radius, m (default 0.09m)
  %   sld - source-listener distance, m (default 0.9m)
  %
  % http://recherche.ircam.fr/equipes/salles/listen/infomorph_display.php?
  %   subject=IRC_1059 (not available for IRC_1002)
  % HEAD_WIDTH_X1 : 152 mm
  % HEAD_DEPTH_X3 : 195 mm
  % head_radius = ((152+195)/2)/2; % = 86.75
  % head_radius = head_radius / 1000;  % mm to m
  % HEAD_CIRCUMFERENCE_X16 : 590 
  % head_radius*2*pi = 545
  % DISTANCE : 1.95 m
  sld = 1.95;
  % typical sitd() max/min ~+/-700us
  itd(g) = sitd( lgrid(2,g), lgrid(1,g), 0.09, sld ) * us2samp;

  % ----  extracted ITDs  ----

  % use raw HRIRs for ITD extraction

  % over-estimates, thinking signal-to-noise issue...
  % examining all IRs simultaneously, sample 240 looked like a good window
  % start point, the shorter the window, the closer to spherical ITDs
  %irL = hr.l_hrir_S.content_m(g,:)';
  %irR = hr.r_hrir_S.content_m(g,:)';

  % time window (similar to Snapshot's start 32 from max, 128 long)
  [mxL startL] = max(abs(hr.l_hrir_S.content_m(g,:)));
  [mxR startR] = max(abs(hr.r_hrir_S.content_m(g,:)));
  % post-eq: xcorr much worse, centroid, less robust but not far off
  %[mxL startL] = max(abs(hc.l_eq_hrir_S.content_m(g,:)));
  %[mxR startR] = max(abs(hc.r_eq_hrir_S.content_m(g,:)));
  start = min([startL startR]) - 32;
  if start < 1,
    start = 1;
  end;
  % window to capture actual HRIR, increase signal-to-noise, and omit
  % potential reflections; zero pad to reduce rceps artifacts;
  % examined IR decay towards noise - occurs in 100-200 span after "start";
  % examined ITDs relative to spherical head model ITDs with the main
  % criterion being the reduction of discontinuities in the difference plot;
  % 346 m/s * 256 samples / 44100 samples/s ~= 2m
  % speaker-subject dist = 1.95m
  itdWin = 256;

  % rect window with hanning taper
  winI = ones(itdWin,1);
  winLen = 32;
  winStart = winLen/2 + 1;
  winTaper = hanning(winLen);
  winI(itdWin-winLen/2+1:itdWin) = winTaper(winStart:winLen);

  winL = winI.*hr.l_hrir_S.content_m(g,start:start+itdWin-1)';
  winR = winI.*hr.r_hrir_S.content_m(g,start:start+itdWin-1)';

  % zero padding for weighted group delay method:
  % - algorithm can have trouble with notches in freq region of interest
  %   (though better than without weights)
  % - increasing zero padding increases the number of group delays averaged
  % - extreme zero padding (8192) tends to smooth the oscillations in the freq
  %   region (but not always)
  % - for the N values below, most ITDs stay the same, comments re the few ITDs
  %   that change value
  % (HP dv9000 laptop)
  % 1024 Elapsed time is 2.564612 seconds. (46 averaged)
  %   prone to odd ITDs seen as curve discontinuities, e.g., two similar values
  %   in a row, group delays tend to oscillate
  % 2048 Elapsed time is 4.569485 seconds. (93 averaged)
  %   definite improvement over above, ITDs more uniformly spaced
  % 4092 Elapsed time is 13.924455 seconds. (186 averaged)
  %   more uniform trend continues (slightly), fairly smooth group delay plot
  % 8192 Elapsed time is 45.743630 seconds. (372 averaged)
  %   and more so, but very slightly

  zeroPadI = 4096;
  irL = [ winL; zeros(zeroPadI-itdWin,1) ];
  irR = [ winR; zeros(zeroPadI-itdWin,1) ];

  %irL = [ hc.l_eq_hrir_S.content_m(g,start:start+itdWin-1)'; zeros(zeroPadI-itdWin,1) ];
  %irR = [ hc.r_eq_hrir_S.content_m(g,start:start+itdWin-1)'; zeros(zeroPadI-itdWin,1) ];

  % to see rceps artifacts without zero pad
  %irL = hr.l_hrir_S.content_m(g,start:start+itdWin-1)';
  %irR = hr.r_hrir_S.content_m(g,start:start+itdWin-1)';

  % ???? IRC_1002, g = 18, itdWin = 200, mpL NaNs!? (the IR in irL does appear
  % to be trunc'd a bit early)
  % ???? IRC_1055, g = 153 (45,-120), itdWin = 256, mpR NaNs!?
  % (winR looks fine)
  %
  % non-pow2 IR length seems to eliminate NaNs should they occur
  [ dummy mpL ] = rceps( irL );
  if any(isnan(mpL)),
    disp('ltest warning: rceps NaNs, trying non-pow2 IR length.');
    [ dummy mpL ] = rceps( irL(1:end-1) );
    mpL = [mpL;0];
  end;
  [ dummy mpR ] = rceps( irR );
  if any(isnan(mpR)),
    disp('ltest warning: rceps NaNs, trying non-pow2 IR length.');
    [ dummy mpR ] = rceps( irR(1:end-1) );
    mpR = [mpR;0];
  end;
  len = length(mpL);

  % time-windowed and zero-padded HRIRs
  if 0,
  figure(gcf);
  plot(1:len,irL,'b',1:len,irR,'r');
  %hold on;
  %plot(1:len,mpL,'k',1:len,mpR,'g');
  axis([1 len -0.5 0.5]);
  grid on;
  hold off;
  pause;
  end;

  % validate minphase conversion
  if 0,
  figure(gcf);
  plotresp(irL,8182,fs,'g',20,fs/2,-60,20,1);
  hold on;
  plotresp(mpL,8182,fs,'b',20,fs/2,-60,20,1);
  hold off;
  pause;
  end;

  % left time delay calc using xcorr
  xL = xcorr( irL, mpL );     % xcorr raw and minphase
  [mx mi] = max( xL );        % max xcorr value
  tl = mi - length(mpL);      % offset by raw IR length

  % right time delay calc using xcorr
  xR = xcorr( irR, mpR );
  [mx mi] = max( xR );
  tr = mi - length(mpR);

  % xcorr ITD calc
  itdX(g) = tl-tr;

  % display xcorr results - prone to odd values
  if 0,
  % raw data
  figure(gcf);
  nz = 128;  % zoom
  % raw left and right
  subplot(2,2,1);
  plot(1:nz,irL(1:nz),'b',1:nz,irR(1:nz),'r');
  axis([1 nz -mr mr]); grid;
  title( sprintf('g=%d (%d,%d) sITD=%.1f xITD=%.1f', ...
    g, lgrid(2,g), lgrid(1,g), itd(g), itdX(g) ) );
  % minphase left and right
  subplot(2,2,3);
  plot(1:nz,mpL(1:nz),'b',1:nz,mpR(1:nz),'r');
  axis([1 nz -mr mr]); grid;
  title('minphase');
  % xcorrs
  subplot(2,2,2);
  plot( xL ); grid;
  title('left corr');
  subplot(2,2,4);
  plot( xR ); grid;
  title('right corr');
  pause;
  end;

  % time delay calc using 10%-of-max threshold;
  % !!!! breaks down with negative peaks before positive peaks;
  % using squared IR values instead results in more intuitive results;
  % Minnaar, HeadZap, and CIPIC describe/use unsquared IR values
  % Note: sqrt(0.1) = 0.3162, HeadZap uses 0.33 threshold

  % left time delay calc using 10%-of-max threshold
  winL2 = resample( winL, 8, 1 );
  winL2 = winL2.*winL2;
  mxL = max(winL2);
  threshL = find( winL2 > mxL*0.1, 1 )/8;

  % right time delay calc using 10%-of-max threshold
  winR2 = resample( winR, 8, 1 );
  winR2 = winR2.*winR2;
  mxR = max(winR2);
  threshR = find( winR2 > mxR*0.1, 1 )/8;

  % threshold ITD calc
  itdT(g) = threshL - threshR;

  % Delay calcs based on group delay of excess phase.
  % Operating on irLeq,mpLeq,etc does change the resultant ITDs, more so for
  % the unweighted - more discontinuous.  There are LARGE oscillations in the
  % post-eq group delays (relative to pre-eq) in the region of interest
  % increasing into the lower freqs.  There is much more spectral activity.
  [gdL,f] = grpdelay(ifft(fft(irL)./fft(mpL)),1,len,fs);
  [gdR,f] = grpdelay(ifft(fft(irR)./fft(mpR)),1,len,fs);
  % Re test with subject 1002:
  % Reducing 2000Hz (H&S) to 1500 (M) expanded the weighted ITDs slightly to
  % overlap with the unweighted (M).  One bad unweighted ITD went away and one
  % got worse.  In both cases, the weighting weights-out the large
  % discontinuities in the group delay that resulted in the bad ITD.  One can
  % see the weights doing this, in general, so they definitely serve a
  % useful purpose (Nam,Abel,Smith).
  % For 1024 freqs, this reduces the number of freqs examined from 69 to 46.
  %     4096 freqs, 279 -> 186 (or 93 if discarding 50% (see below))
  %                            (or 56               30%            )
  fmean = find((f>=500).*(f<=1500));
  flen = length(fmean);
  gdLmean = mean(gdL(fmean));
  gdRmean = mean(gdR(fmean));
  itdG(g) = gdLmean - gdRmean;

  % delay calcs based on weighted group delay;
  % weights based on magnitude response
  [HL,f] = freqz(irL,1,len,fs);
  [HR,f] = freqz(irR,1,len,fs);

  % first pass ITD estimate
  magL = abs(HL(fmean));
  magR = abs(HR(fmean));
  enL2 = sum(magL.*magL)/flen;  % normalization
  enR2 = sum(magR.*magR)/flen;
  gdLw2 = (1/enL2)*magL.*magL.*gdL(fmean);  % weights
  gdRw2 = (1/enR2)*magR.*magR.*gdR(fmean);
  gdLwmean = mean(gdLw2);
  gdRwmean = mean(gdRw2);
  itdW(g) = gdLwmean - gdRwmean;

  % peaks in the group delay values can cause bad gd means, thus it is often
  % best to eliminate them
  threshPeak = 250;  % gd peak threshold

  % If there is considerable sidelobe activity, the weights actually work
  % quite well without peak removal.  But, under a certain sidelobe threshold,
  % a bias gets introduced in the gd mean.  This bias can be corrected by
  % removing the peak from the mean.
  threshSide = 7500;  % gd sidelobe threshold
  trimPk = 0.35;      % amount to trim around peak

  % find left peak
  [gdLpeak,gdLi] = max(abs(gdL(fmean)-gdLwmean));
  % estimate sidelobe activity
  gdLside = sum(abs(diff(diff(gdL(fmean)))));
  % if a peak exists without too much sidelobe activity, remove it
  if gdLpeak > threshPeak && gdLside < threshSide,
    pk1 = gdLi - floor(flen*trimPk) - 1;
    pk2 = gdLi + floor(flen*trimPk) + 1;
    fkeepL = fmean([1:pk1 pk2:end]);
  else
    fkeepL = fmean;
  end;

  % find right peak
  [gdRpeak,gdRi] = max(abs(gdR(fmean)-gdRwmean));
  % estimate sidelobe activity
  gdRside = sum(abs(diff(diff(gdR(fmean)))));
  % if a peak exists without too much sidelobe activity, remove it
  if gdRpeak > threshPeak && gdRside < threshSide,
    pk1 = gdRi - floor(flen*trimPk) - 1;
    pk2 = gdRi + floor(flen*trimPk) + 1;
    fkeepR = fmean([1:pk1 pk2:end]);
  else
    fkeepR = fmean;
  end;

  % second pass ITD estimate after peak removal (if any)
  magTL = abs(HL(fkeepL));
  magTR = abs(HR(fkeepR));
  enTL2 = sum(magTL.*magTL)/length(fkeepL);  % normalization
  enTR2 = sum(magTR.*magTR)/length(fkeepR);
  gdTLw2 = (1/enTL2)*magTL.*magTL.*gdL(fkeepL);  % weights
  gdTRw2 = (1/enTR2)*magTR.*magTR.*gdR(fkeepR);
  gdTLwmean = mean(gdTLw2);
  gdTRwmean = mean(gdTRw2);
  itdR(g) = gdTLwmean - gdTRwmean;

  if 1,
  % flen = 186 for zero pad 4096
  fprintf( ['%3d (%4d,%3d)  %3d  %3d  %5.1f  %5.1f  %5.1f  %7.1f  %7.1f  ' ...
    '%7.1f  %7.1f\n'], ...
    g, lgrid(2,g), lgrid(1,g), flen - length(fkeepL), flen - length(fkeepR), ...
    itd(g), itdW(g), itdR(g), gdLpeak, gdRpeak, gdLside, gdRside );
  end;

  % ----  display group delay results  ----
  if dispGD,
  % raw data
  figure(gcf);
  nz = 128;  % zoom

  % raw left and right
  subplot(2,3,1);
  plot(1:nz,irL(1:nz),'b',1:nz,irR(1:nz),'r');
  h = line([gdTLwmean gdTLwmean],[-mr mr]);
  set(h,'Color',[0 1 1]);
  h = line([gdTRwmean gdTRwmean],[-mr mr]);
  set(h,'Color',[1 1 0]);
  h = line([gdLmean gdLmean],[-mr mr]);
  set(h,'Color',[0 0 1]);
  h = line([gdRmean gdRmean],[-mr mr]);
  set(h,'Color',[1 0 0]);
  h = line([gdLwmean gdLwmean],[-mr mr]);
  set(h,'Color',[0 0 0]);
  h = line([gdRwmean gdRwmean],[-mr mr]);
  set(h,'Color',[0 1 0]);
  axis([1 nz -mr mr]); grid;
  title( sprintf('%d (%d,%d) s=%.1f g=%.1f w=%.1f', ...
    g, lgrid(2,g), lgrid(1,g), itd(g), itdG(g), itdW(g) ) );

  % minphase left and right
  subplot(2,3,4);
  plot(1:nz,mpL(1:nz),'b',1:nz,mpR(1:nz),'r');
  axis([1 nz -mr mr]); grid;
  title('minphase');

  % raw mag
  subplot(2,3,2);
  semilogx(f,20*log10(abs(HL)),'b-',f,20*log10(abs(HR)),'r-');
  axis([20 20000 -60 0]);
  grid on;
  title('mag');
  % raw phase
  subplot(2,3,5);
  semilogx(f,unwrap(angle(HL)),'b-',f,unwrap(angle(HR)),'r-');
  axis([20 20000 -200 10]);
  grid on;
  title('phase');

  % group delay
  subplot(2,3,3);
  semilogx(f,gdL,'b-',f(fmean),gdL(fmean),'b', ...
           f,gdR,'r-',f(fmean),gdR(fmean),'r');
  f1 = f(min(fmean));
  f2 = f(max(fmean));
  h = line([f1 f2],[gdTLwmean gdTLwmean]);
  set(h,'Color',[0 1 1]);
  h = line([f1 f2],[gdTRwmean gdTRwmean]);
  set(h,'Color',[1 1 0]);
  h = line([f1 f2],[gdLmean gdLmean]);
  set(h,'Color',[0 0 1]);
  h = line([f1 f2],[gdRmean gdRmean]);
  set(h,'Color',[1 0 0]);
  h = line([f1 f2],[gdLwmean gdLwmean]);
  set(h,'Color',[0 0 0]);
  h = line([f1 f2],[gdRwmean gdRwmean]);
  set(h,'Color',[0 1 0]);
  grid on;
  title('group delay');
  axis([20 20000 -200 600]);

  % weighted group delay
  subplot(2,3,6);
  semilogx(f(fmean),gdL(fmean),'b.-',f(fmean),gdLw2,'kx-', ...
           f(fmean),gdR(fmean),'r.-',f(fmean),gdRw2,'gx-');
  % if peak eliminated in left gd
  if length(fkeepL) ~= length(fmean),
    hold on;
    semilogx(f(fkeepL),gdTLw2,'ko');
    hold off;
  end;
  % if peak eliminated in right gd
  if length(fkeepR) ~= length(fmean),
    hold on;
    semilogx(f(fkeepR),gdTRw2,'go');
    hold off;
  end;
  h = line([f1 f2],[gdTLwmean gdTLwmean]);
  set(h,'Color',[0 1 1]);
  h = line([f1 f2],[gdTRwmean gdTRwmean]);
  set(h,'Color',[1 1 0]);
  h = line([f1 f2],[gdLmean gdLmean]);
  set(h,'Color',[0 0 1]);
  h = line([f1 f2],[gdRmean gdRmean]);
  set(h,'Color',[1 0 0]);
  h = line([f1 f2],[gdLwmean gdLwmean]);
  set(h,'Color',[0 0 0]);
  h = line([f1 f2],[gdRwmean gdRwmean]);
  set(h,'Color',[0 1 0]);
  grid on;
  title('weighted group delay');
  axis([f1 f2 0 100]);

  pause;
  end;

  % delay calcs based on IR centroid
  % - Minnaar et al, "The Interaural Time Difference in Binaural Synthesis",
  %   AES 108th Convention, Paris, 2000, Preprint 5133
  % - Elmore Delay

  % raw IR and minphase IR energies (see also hen.m)
  irL2 = irL.*irL;
  irR2 = irR.*irR;
  mpL2 = mpL.*mpL;
  mpR2 = mpR.*mpR;

  % left time delay calc using centroid
  centL = sum(irL2.*[1:len]')/sum(irL2);
  centLmp = sum(mpL2.*[1:len]')/sum(mpL2);
  tl = centL - centLmp;

  % right time delay calc using centroid
  centR = sum(irR2.*[1:len]')/sum(irR2);
  centRmp = sum(mpR2.*[1:len]')/sum(mpR2);
  tr = centR - centRmp;

  % centroid ITD calc
  itdC(g) = tl-tr;

  % validate centroid and threshold time delays
  if 0,
  figure(gcf);
  len = 128;
  subplot(2,1,1);
  plot([irL(1:len) mpL(1:len)]);
  hold on;
  stem([centL centLmp],[0.02 0.02],'r');
  stem(threshL,0.02,'b');
  axis([1 len 0 0.04]);
  grid on;
  title(sprintf('left (%d,%d)',lgrid(2,g),lgrid(1,g)));
  hold off;

  subplot(2,1,2);
  plot([irR(1:len) mpR(1:len)]);
  hold on;
  stem([centR centRmp],[0.02 0.02],'r');
  stem(threshR,0.02,'b');
  axis([1 len 0 0.04]);
  grid on;
  title('right');
  hold off;
  pause;
  end;

end;

% compare ITD methods
if 1,
figure;
plot(samp2us*[itd;itdW;itdR]','.-');
legend('spherical','weighted','reject','Location','SouthEast');
%plot(samp2us*[itd;itdX;itdW]','.-');
%legend('spherical','xcorr','weighted','Location','SouthEast');
%plot(samp2us*[itd;itdX;itdG;itdW;itdC]','.-');
%legend('spherical','xcorr','group','weighted','centroid', ...
%       'Location','SouthEast');
%plot(samp2us*[itd;itdX;itdC;itdT;itdC-itd]','.-');
%legend('spherical','xcorr','centroid','threshold','centroid-spherical', ...
%       'Location','SouthEast');
%plot(samp2us*[itd;itdC;itdT;itdC-itd;itdT-itd]','.-');
%legend('spherical','centroid','threshold','centroid-spherical', ...
%       'threshold-spherical','Location','SouthEast');
grid on;
title('ITDs');
xlabel('response index (azs grouped by el)');
ylabel('us');
end;

% best uniform slab3d grid match to Listen grid
azInc = 15;
elInc = 15;

% use mat2slab() to finish conversion (uniform grid, scaling, etc.)
if 0,
slabFileName = [ strName '.slh' ];
strComment = [];
scale = 1;
mat2slab( slabFileName, hrir, itdC, lgrid, azInc, elInc, numPts, ...
          strName, strComment, fs, scale );
end;
toc;
