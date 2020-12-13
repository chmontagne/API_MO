function imodelab
% imodelab - Allen-Berkley image model.
%
% imodelab uses the Allen-Berkley image model algorithm to generate a room
% impulse response.
%
% Reference:
% [1] J. Allen and D. Berkley, "Image method for efficiently simulating
%     small-room acoustics", JASA 65(4), 1979.
%
% See Also: imodel.m, imodelui.m

% modification history
% --------------------
%                ----  v5.0.2  ----
% 04.11.03  JDM  created from Allen-Berkley Fortran code
% 04.21.03  JDM  imodel.m to imodelab.m; clean-up
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR
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

% The functions sroom and lthimage are intentionally kept as similar to the
% source Fortran code as possible for easy comparison.

% parameters for [1] FIG.2

X  = [ 30, 100, 40  ];  % vector talker location, sample periods
Xp = [ 50, 10,  60  ];  % vector microphone location, sample periods
rL = [ 80, 120, 100 ];  % room, sample lengths

% reflection coefficients
%         x    y    z
beta = [ 0.9, 0.9, 0.7; ...
         0.9, 0.9, 0.7 ];

fs = 8000;  % Hz
T = 0.256;  % s

ht = sroom( Xp, X, rL, beta, fs * T );

% displays [1] FIG.2 plot
plot( ht );
figure(gcf);

% Function: sroom
% Function to calculate a room impulse response.
% r    = vector radius to receiver in sample periods = length/(c*t)
% r0   = vector radius to source in sample periods
% rL   = vector of box dimensions in sample periods
% beta = vector of six wall reflection coefs (0 < beta <= 1)
% ht   = impulse resp array
% npts = # of points of ht to be computed
% Zero delay is in ht(1).

function ht = sroom( r, r0, rL, beta, npts )

% Dimensions: r(1,3), r0(1,3), rL(1,3), beta(2,3), delp(1,8).
% Note: nx,ny,nz is used in place of 'NR'.

ht = zeros(1,npts);

% check for mic and source at same location
dis = 0;
for i = 1:3,
  dis = (r(i)-r0(i))^2 + dis;
end;
dis = sqrt( dis );
if( dis < 0.5 ),
  ht(1) = 1;
  break;
end;

% find range of sum
n1 = floor(npts/(rL(1)*2)) + 1;
n2 = floor(npts/(rL(2)*2)) + 1;
n3 = floor(npts/(rL(3)*2)) + 1;
for nx = -n1:n1,
  for ny = -n2:n2,
    for nz = -n3:n3,
      % get eight image locations for mode # nr
      delp = lthimage( r, r0, rL, nx, ny, nz );
      i0 = 0;
      for l = 0:1,
        for j = 0:1,
          for k = 0:1,
            i0 = i0 + 1;
            % make delay an integer
            id = floor( delp( i0 ) + 0.5 );
            fdm1 = id;
            id = id + 1;
            if( id <= npts ),
              % put in loss factor once for each wall reflection
              gid = beta(1,1)^abs(nx-l) * beta(2,1)^abs(nx) * ...
                    beta(1,2)^abs(ny-j) * beta(2,2)^abs(ny) * ...
                    beta(1,3)^abs(nz-k) * beta(2,3)^abs(nz) / fdm1;
              ht(id) = ht(id) + gid;
            end; % if
          end; % k
        end; % j
      end; % l
    end; % nz
  end; % ny
end; % nx

% impulse resp has been computed
% filter with hi pass filt of 1% of sampling freq (i.e. 100 Hz)
% if this step is not desired, omit
w  = 2*4*atan(1)*100;
t  = 1e-4;
r1 = exp(-w*t);
r2 = r1;
b1 = 2*r1*cos(w*t);
b2 = -r1*r1;
a1 = -(1+r2);
a2 = r2;
y1 = 0;
y2 = 0;
y0 = 0;
% filter ht
for i = 1:npts,
  x0 = ht(i);
  ht(i) = y0 + a1*y1 + a2*y2;
  y2 = y1;
  y1 = y0;
  y0 = b1*y1 + b2*y2 + x0;
end;


% Function: lthimage
% Function to compute eight images of a point in box.
% dr   is vector radius to receiver in sample periods
% dr0  is vector radius to source in sample periods
% rL   is vector of box dimensions in sample periods
% nr   is vector of mean image number (note: nx, ny, nz)
% delp is vector of eight source to image distances in sample periods

function delp = lthimage( dr, dr0, rL, nx, ny, nz )

% Dimensions: dr(1,3), dr0(1,3), rL(1,3).

delp = zeros(1,8);
r2L  = zeros(1,3);
rp   = zeros(3,8);

% loop over all sign permutations and compute r +/- r0
i0 = 1;
for l=-1:2:1,
  for j=-1:2:1,
    for k=-1:2:1,
      % nearest image is l = j = k = -1
      rp(1,i0) = dr(1) + l*dr0(1);
      rp(2,i0) = dr(2) + j*dr0(2);
      rp(3,i0) = dr(3) + k*dr0(3);
      i0 = i0 + 1;
    end; % k
  end; % j
end; % l

% add in mean radius to eight vectors to get total delay
r2L(1) = 2.0 * rL(1) * nx;
r2L(2) = 2.0 * rL(2) * ny;
r2L(3) = 2.0 * rL(3) * nz;
for i=1:8,
  delsq = 0;
  for j = 1:3,
    r1 = r2L(j) - rp(j,i);
    delsq = delsq + r1^2;
  end;
  delp(i) = sqrt( delsq );
end;
