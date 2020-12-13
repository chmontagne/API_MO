% lcheck - check suspicious listen2slab HRTFs.
%
% lcheck displays suspicious Listen SLHs in their native format.
%
% See also: listen2slab, ccheck

% modification history
% --------------------
%                ----  v6.6.0  ----
% 03.21.11  JDM  created
%                ----  v6.7.2  ----
% 10.16.13  JDM  added to slab3d\slabtools\
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
% hc.r_eq_hrir_S: [1x1 struct]
% hc.l_eq_hrir_S: [1x1 struct]
%
% hc.l_eq_hrir_S
%          elev_v: [187x1 double]
%          azim_v: [187x1 double]
%          type_s: 'FIR'
%     sampling_hz: 44100
%       content_m: [187x512 double] - IR length = 512

% Grids
%
% % slab3d grid, group by azimuth (all el's at 180, at 150, etc.)
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
% els equivalent

% Suspect Databases (see range and view below)
%
% Coords in slab3d coords.
%
h = load('IRC_1016_C_HRIR');
%  75,45 L - IR oscillating
% 150,60 L - oddly hot
%
%h = load('IRC_1025_C_HRIR');
% 120,15 R - low IR
%
%h = load('IRC_1031_C_HRIR');
% -75,45 and -135,45 L,R - lowpass (fc 13kHz)
%
%h = load('IRC_1034_C_HRIR');
% Looping through responses, one notices several flat (just noise) IRs
% (e.g., -45,-15, -45,-30).
%
%h = load('IRC_1051_C_HRIR');
% 30,60 L,R - lowpass (fc 14kHz)

% raw: _hrir_S
% EQd: _eq_hrir_S
raw = 0;

% measurement locations
if raw,
  lgrid = [ h.l_hrir_S.elev_v h.l_hrir_S.azim_v ]';
else
  lgrid = [ h.l_eq_hrir_S.elev_v h.l_eq_hrir_S.azim_v ]';
end;

% Listen az to slab3d az
lgrid(2,:) = -lgrid(2,:);

% Listen az range to slab3d az range
f = find( lgrid(2,:) <= -180 );
lgrid(2,f) = lgrid(2,f) + 360;

% #responses, IR length
if raw,
  [ resp N ] = size(h.l_hrir_S.content_m);
else
  [ resp N ] = size(h.l_eq_hrir_S.content_m);
end;

% sample rate
if raw,
  fs = h.l_hrir_S.sampling_hz;      % 44100
else
  fs = h.l_eq_hrir_S.sampling_hz;   % 44100
end;

% IRC_1016 - view IRs
range = [ hindex(75,45,lgrid) hindex(120,60,lgrid) hindex(150,60,lgrid) ...
          hindex(180,60,lgrid) ];
viewIRs = 1;

% IRC_1025 - view IRs
%range = [ hindex(105,15,lgrid) hindex(120,15,lgrid) hindex(135,15,lgrid) ];
%viewIRs = 1;

% IRC_1031 - view mags
%range = hindex(-75,45,lgrid)-1:hindex(-135,45,lgrid)+1;
%viewIRs = 0;

% IRC_1034 - view all IRs
%range = 1:resp;
%viewIRs = 1;

% IRC_1051 - view mags
%range = hindex(30,60,lgrid)-1:hindex(30,60,lgrid)+1;
%viewIRs = 0;

figure(gcf);
for k = range,
  if raw,
    irL = h.l_hrir_S.content_m(k,:);
    irR = h.r_hrir_S.content_m(k,:);
  else
    irL = h.l_eq_hrir_S.content_m(k,:);
    irR = h.r_eq_hrir_S.content_m(k,:);
  end;
  if viewIRs,
    % IRs
    plot( 1:N, irL, 'b', 1:N, irR, 'r' );
    axis( [ 0 N -1 1 ] );
    grid on;
  else
    % mag resps
    logDisp = 1;
    plotresp(irL,8192,fs,'b',20,fs/2,-55,15,logDisp,1);
    hold on;
    plotresp(irR,8192,fs,'r',20,fs/2,-55,15,logDisp,1);
    hold off;
  end;
  title (sprintf('(%d, %d)',lgrid(2,k),lgrid(1,k)));
  pause;
end;
