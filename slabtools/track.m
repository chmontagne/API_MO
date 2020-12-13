function track( smoothtime, nframes, framesz, seed )
% track - demonstrates slab3d DSP parameter tracking.
%
% track( smoothtime, nframes, framesz, seed )
%
%   smoothtime - slab3d's leaky integrator tracking filter time constant (ms)
%   nframes    - number of DSP frames to display
%   framesz    - DSP processing frame size in samples
%   seed       - if negative, parameter targets are random, seeded with -seed;
%                if positive, all targets equal seed
%
% Defaults: 15, 128, 32, -1

% modification history
% --------------------
% 03.24.00  JDM  created from test.m; examined pure track (no linear interp)
%                using hacked update.m
% 07.31.00  JDM  recode
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR, updated comments and code, added pure track
%
% JDM == Joel D. Miller
%
% Note: Original leaky integrator demo code was provided by Jonathan Abel.

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

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

% defaults
if nargin < 1,
  smoothtime = 15;  % tracking filter time constant, ms
end;
if nargin < 2,
  nframes = 128;
end;
if nargin < 3,
  framesz = 32;     % processing frame size, samples
end;
if nargin < 4,
  seed = -1;
end;

% protect against divide-by-zero's
if smoothtime == 0,
  smoothtime = eps;
end;

SceneUp = 120.0;  % scene update rate, Hz
dspFs   = 44100;  % sampling rate, Hz

% frames per scene update period
fps = dspFs/(SceneUp*framesz);

% generate scene update DSP parameter targets
targets(1) = 0.0;
if( seed < 0 ),
  % targets set to random values seeded by seed
  rand( 'state', -seed );
  targets( 2 : ceil(nframes/fps) ) = ...
    floor( rand(1,ceil(nframes/fps)-1) * 3.5 ); % values = 0,1,2,3
else,
  % targets set to a constant (seed)
  targets( 2 : ceil(nframes/fps) ) = seed;
end;

% tracker time constant, frames
tau = smoothtime * (dspFs/1000) / framesz;

% leaky integrator forgetting factor
dspTrackerAlpha = exp(-1/tau);

% pure param track instead of linear interp during frame
% (for comparing linear interp method to pure method)
dspTrackerAlpha2 = exp(-1/(smoothtime * (dspFs/1000)));

% simulate slab3d delay line index update
last_delay = 0.0;
last_delay2 = 0.0;
foo = [];
foo2 = [];
thing = [];
for frame = [1:nframes],
  % -1 because we're heading towards previous target when new scene info
  % received, thus the last previous target occurs after the scene update
  target_delay = targets( floor((frame-1)/fps) + 1 );

  % the following three lines implement leaky integrator parameter tracking
  % for frame-interval values with linear interp between frame values

  % find next frame last delay
  new_last_delay = target_delay + ...
                   dspTrackerAlpha * (last_delay - target_delay);

  % form frame delays
  delays = last_delay + (new_last_delay - last_delay) * ...
                        [1:framesz] / framesz;

  % set next frame last delay
  last_delay = new_last_delay;

  thing = [thing delays];  % index values updated every sample (linear)
  foo = [foo last_delay];  % index values updated every frame  (leaky int.)

  % pure param track method
  for i = 1:framesz,
    last_delay2 = target_delay + dspTrackerAlpha2 * (last_delay2 - target_delay);
    foo2 = [foo2 last_delay2];
  end;
end;

% plot frame index, delay index, and scene update DSP parameter values
% ('g' = 32 points between 'o's)
figure(gcf);
scene = floor(.120*nframes*framesz/(dspFs/1000)) + 1;
plot( [1:nframes] * framesz * (1000/dspFs), foo(1:nframes), 'bo', ...
      [1:nframes*framesz] * (1000/dspFs), ...
      thing(1:nframes*framesz), 'b-', ...
      [1:nframes*framesz] * (1000/dspFs), ...
      foo2(1:nframes*framesz), 'r:', ...
      [0:1/.120:nframes*framesz/(dspFs/1000)], targets(1:scene), 'ks' );
legend( 'frame value', 'delay index', 'pure track', 'target', 0 );

% format plot
h = gca;  % get current axis
% ticks at scene updates
xtick = [0:1/.120:nframes*framesz/(dspFs/1000)];
set( h, 'XTick', xtick );
for i = 1:size(xtick,2),
  xtickLabel(i,:) = sprintf( '%5.1f', xtick(1,i) );
end;
set( h, 'XTickLabel', xtickLabel );
grid;
title('Parameter Tracked Delay Line Index Trajectory');
xlabel('time (ms)'); ylabel('delay (samples)');
