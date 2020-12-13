function vsyms( h, el, tflog )
% vsyms - view all HRTF magnitudes for a given el on two spheres (L/R).
%
% vsyms( h, el, tflog )
%
% h     - sarc struct
% el    - elevation (degrees)
% tflog - log frequency flag (default = 0)
%
% Each sphere contains both left and right magnitude responses (north/south
% poles = low frequencies).  This allows the spheres to be viewed from the
% top to visualize azimuth frequency trends and from the side to visualize
% symmetry.
%
% See also: vall, vsym1, vcsym

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.23.11  JDM  created from vall.m
%                ----  v6.7.2  ----
% 10.16.13  JDM  clean-up; added to slab3d\slabtools\
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
  disp( 'vsyms error: sarc input required.' );
  return;
end;

% defaults
if nargin < 2, el = 0; end;
if nargin < 3, tflog = 0; end;  % linear freq axis

% check if fixed-inc data
if h.finc == 0,
  disp('vsyms error: not fixed-inc data.');
  return;
end;

% get current figure
figure(gcf);

% view all az HRTF locations for a given el
posBegin = hindex( max(h.dgrid(2,:)), el, h.dgrid );
posEnd   = hindex( min(h.dgrid(2,:)), el, h.dgrid );
gridinc  = (max(h.dgrid(1,:)) - min(h.dgrid(1,:))) / h.elinc + 1;

% make sure requested locations exist
if isempty( posBegin ) || isempty( posEnd ),
  disp('vsyms error: requested locations do not exist.');
  return;
end;

resps = size(h.dgrid,2);
N = 512;
NN = N-1;
locs = posBegin : gridinc : posEnd;
len = length(locs);
allL = zeros( 2*NN, len );
allR = zeros( 2*NN, len );
for k = 1:len,
  iL = locs(k);
  iR = locs(len-k+1);
  [respL,ft] = freqz( h.ir(:,iL), 1, N, h.fs );
  [respR,ft] = freqz( h.ir(:,iR + resps), 1, N, h.fs );
  dBl = 20*log10(abs(respL(2:N)));  % omit DC
  dBr = 20*log10(abs(respR(2:N)));  % omit DC

  % if log freq axis
  if tflog,
    % see CIPIC show_data freq_resp.m
    f = logspace( log10(ft(2)), log10(ft(N)), N-1 );
    dBl = interp1( ft(2:N), dBl, f )';
    dBr = interp1( ft(2:N), dBr, f )';
  else
    f = ft(2:N);
  end;

  % find the last freq under 20kHz
  endF = min(find(ft>20000))-1;
  allL(1:2*endF,k) = [dBl(1:endF);flipud(dBr(1:endF))];
  allR(1:2*endF,k) = [dBr(1:endF);flipud(dBl(1:endF))];
end;

% reduce to freqs under 20kHz
allFL = allL(1:2*endF,:);
% for symmetry vis (see iR in loop above)
allFR = fliplr(allR(1:2*endF,:));

% 90 to -90
NNN = size(allFL,1)-1;
elmap = 90-((0:NNN)/NNN)*180;
azmap = h.dgrid(2,locs);
minMag = min(min(allFL));  % assume R similar
maxMag = max(max(allFL));
cax = [ minMag maxMag ];
%fprintf('%5.1f  %5.1f\n', minMag, maxMag);
%cax = [ -103 16 ];  % cipic
%cax = [ -90 8 ];  % listen
if 0,
if minMag < cax(1),
  fprintf('Warning: mag value below cax  min %.1f  (max %.1f)  dB\n', ...
          minMag, maxMag);
end;
if maxMag > cax(2),
  fprintf('Warning: mag value above cax  (min %.1f)  max %.1f  dB\n', ...
          minMag, maxMag);
end;
end;

titleL = sprintf('Left/SymRight Freq Resp EL %d',el);
titleR = sprintf('Right/SymLeft Freq Resp EL %d',el);
% top-bottom, no-bottom
lrsphere( azmap, elmap, allFL, allFR, titleL, titleR, cax, 1, 0 );

%view(90,0);
%print(gcf,'-dpng','vsyms_irc_1002.png');
