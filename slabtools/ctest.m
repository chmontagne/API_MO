% ctest - test and examine cipic2slab() processing.
%
% Note: This is a rough development script for testing and visualizing
%       cipic2slab() processing.
%
% See also: cipic2slab

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.15.13  JDM  created
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

% slab3d default HRIR length
slabLen = 128;

% rect window
win = ones(slabLen,1);

% replace end of rect window with hanning taper;
% reduces high-freq trunc artifacts, smooths response
winLen = 32;
winStart = winLen/2 + 1;
winTaper = hanning(winLen);
win(slabLen-winLen/2+1:slabLen) = winTaper(winStart:winLen);

% only load and process cipic data once
if ~exist('subName','var'),

% CIPIC directory structure:
% CIPIC_hrtf_database\standard_hrir_database\subject_127\hrir_final.mat
% (initial tests performed with subject 127)
%
% user should be cd'd to: CIPIC_hrtf_database\standard_hrir_database\
subName = 'subject_003';  % subject 003 largest IR(128) value
cmat = load( [ subName '\hrir_final.mat' ] );

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
  disp('ctest error: cipic hrir data dims do not match default cipic grid.');
  return;
end;

% number of response pairs
resp = cazNum * celNum;

% cipic HRIR length
irLen = size(cmat.hrir_l,3);

% slab array formatting (post-processed jdm.slh example)
% [ hrir, itd, sgrid, v, n, d, c, a, e, p, f ] = slab2mat( 'jdm.slh' );
% hrir:   128x286 (128-point IRs, all L followed by all R)
% itd:    1x143
% sgrid:  2x143 (az inc 30, el inc 18, full spherical uniform grid)
%         143 = (1+360/30) * (1+180/18), note duplicate az

% cipic hrirs (not-minphase) to slab hrirs (minphase),
% the two also use different array formats;
% zero-pad rceps() minphase calc to reduce IR ripple
zeroPad = 1024;
%cshrir = zeros( zeroPad, resp*2 );
cshrir = zeros( slabLen, resp*2 );

% use sarcs to compare entire databases (see cipic2sarc.m);
% was used for hanning taper analysis
%
% sarc struct
% smake( name, source, comment, ir, itd, dgrid, finc, fs, mp, tgrid, ...
%        eqfs, eqm, eqf, fgrid, eqd, eqb, eqh, hcom )
if 1,
hr = smake( subName, 'cipic_raw', '', [], [], [], 0 );
hp = smake( subName, 'cipic_proc', '', [], [], [], 0 );
hr.ir = zeros( irLen, resp * 2 );
hr.azinc = length(caz);
hr.elinc = length(cel);
hp.azinc = length(caz);
hp.elinc = length(cel);
% hr/hp init finished in and after for/for below
end;

% cipic ITD (unsigned) to slab ITD (signed)
csitd = zeros(1,resp);

% cipic grid (cipic coords) to slab grid (slab coords)
csgrid = zeros(2,resp);

% convert measurement grid, HRIRs, and ITDs
i = 1;
for az=1:cazNum,
  for el=1:celNum,
    % cipic raw HRIRs in sarc format
    % (post-free-field EQ, no headphone EQ)
    hr.ir( :, (az-1)*celNum + el ) = squeeze(cmat.hrir_l(az,el,:));
    hr.ir( :, (az-1)*celNum + el + resp ) = squeeze(cmat.hrir_r(az,el,:));

    % convert cipic's HRIRs to minphase
    [ dummy mpL ] = rceps( [ squeeze(cmat.hrir_l(az,el,:)); zeros(zeroPad-irLen,1) ] );
    cshrir( :, (az-1)*celNum + el ) = win .* mpL(1:slabLen);
    %cshrir( :, (az-1)*celNum + el ) = mpL;
    %cshrir( :, (az-1)*celNum + el ) = mpL(1:slabLen);
    [ dummy mpR ] = rceps( [ squeeze(cmat.hrir_r(az,el,:)); zeros(zeroPad-irLen,1) ] );
    cshrir( :, (az-1)*celNum + el + resp ) = win .* mpR(1:slabLen);
    %cshrir( :, (az-1)*celNum + el + resp ) = mpR;
    %cshrir( :, (az-1)*celNum + el + resp ) = mpR(1:slabLen);

    % cipic OnL-OnR is signed version of cipic ITD;
    % in slab:  src L, -az, -itd, lag right 
    %           src R, +az, +itd, lag left
    csitd(i) = cmat.OnL(az,el) - cmat.OnR(az,el);

    % convert measurement grid from cipic interaural polar coords to
    % slab3d vertical polar coords
    [ saz sel ] = c2s( cgrid(2,i), cgrid(1,i) );
    csgrid(:,i) = [sel;saz];

    i = i + 1;
  end;
end;

if 1,
hr.dgrid = csgrid;
hp.dgrid = csgrid;
hp.ir = cshrir;
end;

end;

% at this point, mat2slab() could be used to write SLH

% ----  minphase and windowing  ----

if 1,

% see also ffeq.m and ffeqtest.m re rceps and windowing

% find largest discontinuity at slabLen;
% high-freq truncation artifacts most pronounced around or above 20kHz
[mx,mi] = max(abs(cshrir(slabLen,1:2*resp)));

% find most energy after slabLen;
% above results in more obvious high-freq mag response window diffs;
% truncation and hanning tapers mainly smooth the response
%[mx,mi] = max(sum(abs(cshrir(slabLen+1:irLen,1:2*resp))));

% mi 89 of subject 127 illustrates rceps() no-zero-pad IR ripple issue well
% mi = 89;

% if right ear max (slab indexing), change index to left
maxR = 0;
if mi > resp,
  mi = mi - resp;
  maxR = 1;
  disp('max right');
else
  disp('max left');
end;

% slab indexing to cipic indexing
mazi = floor((mi-1)/celNum) + 1;
meli = mod((mi-1),celNum) + 1;

azi = mazi;
eli = meli;

% cipic indexing to slab indexing
si = (azi-1)*celNum + eli;

disp('max window point (and indexing check)');
[mi si]

disp('[el;az]');
csgrid(:,si)

irL = squeeze(cmat.hrir_l(azi,eli,:));
irR = squeeze(cmat.hrir_r(azi,eli,:));
irpL = cshrir(:,si);
irpR = cshrir(:,si+resp);

% plot raw and processed IRs
figure;
% raw
subplot(2,1,1);
plot(irL,'b');
hold on;
plot(irR,'r');
title('cipic raw');
grid on;
% processed
subplot(2,1,2);
plot(irpL,'b');
hold on;
plot(irpR,'r');
plot(win,'k');  % window
title('processed');
grid on;

% to experiment with hanning taper
if 0,
figure;
winLen = 32;
winStart = winLen/2 + 1;
winTaper = hanning(winLen);
[ max(winTaper) min(winTaper) ]  % for len 16, 0.99 0.03
% rect window with hanning taper
win = ones(slabLen,1);
win(slabLen-winLen/2+1:slabLen) = winTaper(winStart:winLen);
plot(win,'k.-');
grid on;
hold on;
plot(irpR,'b');
% apply window (used on subject 003 R ear, large mp IR(128) discontinuity)
irpR = win .* irpR(1:slabLen);
plot(irpR,'r');
end;

figure;
fs = 44100;
if maxR,
  plotresp(irR,4096,fs,'g',20,fs/2,-60,20,1);
  hold on;
  plotresp(irpR,4096,fs,'r',20,fs/2,-60,20,1);
else
  plotresp(irL,4096,fs,'g',20,fs/2,-60,20,1);
  hold on;
  plotresp(irpL,4096,fs,'b',20,fs/2,-60,20,1);
end;

% compare entire raw and processed databases
%hcom(hr,hp,'l',-1,-1,0,0,0,0,0);  % subject_127
% raw to proc SED mean
% 1024 mp                                 0.05 dB
% mp rect win 128                         0.16 dB
% mp rect w/ 8pt hanning taper win 128    0.16 dB

%hcom(hr,hp);  % subject_127
% raw to proc SED mean - critical band analysis
% 1024 mp                                 0.00 dB
% mp rect win 128                         0.07 dB
% mp rect w/ 8pt hanning taper win 128    0.08 dB
% mp rect w/ 16pt hanning taper win 128   0.08 dB
% mp rect w/ 32pt hanning taper win 128   0.11 dB - low-freq smoothing

% subject_003 - worst case trunc-at-128 discontinuities
% hcom(hr,hp,'l',-1,-1,0,0,0,0,0);  hcom(hr,hp,'r',-1,-1,0,0,0,0,0);
% hcom(hr,hp,'l');                  hcom(hr,hp,'r');
%   no taper 0.26 0.39  0.09 0.11
%  8pt taper 0.25 0.36  0.09 0.17
% 16pt taper 0.26 0.36  0.09 0.13
% 24pt taper 0.28 0.37  0.09 0.12
%
% listening tests were performed in SLABScape between no-taper and 16pt-taper
% with no differences heard

% to view rceps() freq-domain artifacts and the need for zero padding
if 0,
figure;
plotresp(irL,4096,fs,'b',20,fs/2,-60,20);
hold on;
[ dummy irL2mp ] = rceps( [ irL; zeros(1024-irLen,1) ] );
plotresp(irL2mp,4096,fs,'r',20,fs/2,-60,20);
end;

end;

% ----  ITD  ----

if 1,

us2samp = 1000000/44100;
xitds=zeros(1,resp);
sitds=zeros(1,resp);
i = 1;
%figure;
%for a=550:555,
for a=1:resp,
  % slab indexing to cipic indexing
  azi = floor((a-1)/celNum) + 1;
  eli = mod((a-1),celNum) + 1;
  irL = squeeze(cmat.hrir_l(azi,eli,:));
  irR = squeeze(cmat.hrir_r(azi,eli,:));

  % left time delay calc
  [dummy ml] = rceps( irL );  % minphase
  xL = xcorr( irL, ml );      % xcorr raw and minphase
  [mx mi] = max( xL );        % max xcorr value
  tl = mi - length(ml);       % offset by raw IR length

  % right time delay calc
  [dummy mr] = rceps( irR );
  xR = xcorr( irR, mr );
  [mx mi] = max( xR );
  tr = mi - length(mr);

  % xcorr ITD calc
  xitd = tl-tr;
  xitds(i) = xitd;

  % spherical head model ITD
  sitds(i) = sitd( csgrid(2,a), csgrid(1,a) ) / us2samp;

  % display results
  if 0,
  % raw data
  subplot(2,2,1);
  plot(1:200,irL,'b',1:200,irR,'r');
  axis([1 200 -2 2]); grid;
  title( sprintf('i=%d s(%.1f,%.1f) c(%.1f,%.1f) cITD=%.1f xITD=%.1f', ...
    a, csgrid(2,a), csgrid(1,a), cgrid(2,a), cgrid(1,a), csitd(a), xitd ) );
  % minphase left and right
  subplot(2,2,3);
  plot(1:200,ml,'b',1:200,mr,'r');
  axis([1 200 -2 2]); grid;
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

  i = i + 1;
end;

% compare cipic, xcorr, and spherical head model ITDs
figure;
plot([csitd;xitds;sitds;csitd-xitds]');
grid on;
title('ITDs');
legend('cipic','xcorr','spherical','cipic-xcorr','Location','SouthEast');
xlabel('response index (els grouped by az)');
ylabel('samples');

% !!!! subject_127, bad large xitds(552) value, xcorr has two large clumps
% instead of typical somewhat symmetrical one clump
% - would need more sophisticated ITD extraction than simple xcorr
% - use cipic values (appears performed on 8x upsampled HRIRs)

end;

% ----  all IRs  ----

% after minphase and trunc
if 1,
figure;
plot( cshrir );
grid on;
title( 'post-mp-trunc' );
end;

% after SLH created with cipic2slab()'s mat2slab() (map2map(), scaling)
if 0,
figure;
h = slab2sarc('subject_127_5_5.slh');
plot( h.ir );
grid on;
title( 'post-cipic2slab' );
% IR tails bounded by +/- 0.02, so though not tapered (straight rect window),
% still fades to 2% of 1.0 peak
end;
