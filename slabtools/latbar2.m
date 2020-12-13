function latbar2
% latbar2 - latency bar graph

% modification history
% --------------------
% 12.10.04  JDM  created from latbar.m
%                ----  v6.7.3  ----
% 12.02.13  JDM  added to slabtools
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

fs       = 44.1;            % samples/ms
asio_in  = 96;              % samples
asio_ims = asio_in / fs;    % ms
asio_out = 94;              % samples
asio_oms = asio_out / fs;   % ms
buf_sz   = 64;              % samples
buf_ms   = 64 / fs;         % ms
fms1     = 0.1;             % frame proc time, ms
fms2     = 0.13;            % frame proc time with API-to-DSP translation, ms
dspms    = 0.19;            % DSP algorithm latency, ms

figure(gcf);
clf;

global b;
b = 0;
w = .65;

% callback 1
dbar( buf_ms-asio_ims, asio_ims, w, 'c' );
dbar( buf_ms,          asio_oms, w, 'b', 0 );

% callback 2
dbar( 2*buf_ms-asio_ims, asio_ims, w, 'c' );
dbar( 2*buf_ms,          asio_oms, w, 'b', 0 );

% frame proc
dbar( -buf_ms,        fms1, w, 'y' );
dbar( -buf_ms+fms1,   fms1, w, 'y', 0 );
dbar( 0.0,            fms1, w, 'y', 0 );
dbar( fms1,           fms1, w, 'y', 0 );
dbar( buf_ms,         fms2, w, 'r', 0 );
dbar( buf_ms+fms2,    fms1, w, 'y', 0 );
dbar( 2*buf_ms,       fms1, w, 'y', 0 );
dbar( 2*buf_ms+fms1,  fms1, w, 'y', 0 );
dbar( 3*buf_ms,       fms1, w, 'y', 0 );
dbar( 3*buf_ms+fms1,  fms1, w, 'y', 0 );

% DSP algorithm latency
dbar( buf_ms-asio_ims-dspms, dspms,  w, 'm' );
dbar( buf_ms,                buf_ms, w, 'm', 0 );

% variability
dbar( fms1+fms1, buf_ms-fms1-fms1, w, 'g' );

% api latency min
dbar( buf_ms, buf_ms+asio_oms, w, 'g' );
hold on;
plot( buf_ms, b, 'ks' );

% api latency max
dbar( fms1+fms1, buf_ms-fms1-fms1+buf_ms+asio_oms, w, 'g' );
plot( fms1+fms1, b, 'ks' );

% I/O latency
dbar( buf_ms-asio_ims-dspms, dspms+asio_ims+buf_ms+asio_oms, w, 'g' );

% variability and api latency min begin/end vertical lines
line( [ buf_ms buf_ms buf_ms ], [ -3 -5 -6 ], ...
      'Color', 'k', 'Marker', '.', 'LineStyle', '--' );

% variability and api latency max/min begin/end vertical lines
line( [ fms1+fms1 fms1+fms1 fms1+fms1 ], [ -3 -5 -7 ], ...
      'Color', 'k', 'Marker', '.', 'LineStyle', '--' );
line( [ 2*buf_ms+asio_oms 2*buf_ms+asio_oms ...
        2*buf_ms+asio_oms 2*buf_ms+asio_oms ], [ -2 -6 -7 -8 ], ...
      'Color', 'k', 'Marker', '.', 'LineStyle', '--' );
line( [ buf_ms+asio_oms buf_ms+asio_oms buf_ms+asio_oms ], [ -1 -6 -7 ], ...
      'Color', 'k', 'Marker', '.', 'LineStyle', '--' );

% I/O latency begin/end vertical lines
line( [ buf_ms-asio_ims buf_ms-asio_ims ], [ -1 -4 ], ...
      'Color', 'k', 'Marker', '.', 'LineStyle', '--' );
line( [ buf_ms-asio_ims-dspms buf_ms-asio_ims-dspms ], [ -4 -8 ], ...
      'Color', 'k', 'Marker', '.', 'LineStyle', '--' );

% line style, etc.:
% h=line( [ -1 -1 ], [ -1 -8 ] );
% get(h), set(h)

h=gca;
set( h, 'YTick', b:-1 );
set( h, 'YLim', [ b-w, -w ] );
set( h, 'YTickLabel', flipud( [
     '    CB1';
     '    CB2';
     '  Frame';
     'DSP Alg';
     'API Var';
     'API Min';
     'API Max';
     'I/O Lat' ] ) );
set( h, 'XTick', -buf_ms:buf_ms:4*buf_ms );
set( h, 'XLim', [ -buf_ms-0.2, 4*buf_ms ] );
x = [];
for i = -buf_ms:buf_ms:4*buf_ms,
  t = sprintf( '%5.2f', i );
  x = [ x; t ];
end;
set( h, 'XTickLabel', x );
xlabel( 'ASIO Callback Time (ms)', 'FontSize', 8 );
title( 'Latency Timing Diagram', 'FontSize', 8 );
grid;

% "help graph3d" to see available colormaps
%colormap( 1 - jet );
%brighten( .5 );

set( gca, 'FontSize', 8 );
% 0 0 w h
set( gcf, 'PaperPosition', [ 0 0 4.0 3.2 ] );
print( '-dtiff', 'latbar2.tif' );

%------------------------------------------------------------------------------
% dbar - draw horizontal bar
%
% xb = x begin
% xe = e end
% w  = bar width
% c  = color, letter or RGB triple

function dbar( xb, xe, w, c, inc )

if nargin < 5,
  inc = 1; % bar line increment
end;

global b;
w = w/2;
b = b-inc;
xe = xe+xb;
patch( [ xb xe xe xb ], [ b+w b+w b-w b-w], c );
