function fview( fstr, vtype )
% fview - view Club Fritz data.
%
% fview( fstr, vtype )
%
%   fstr  - Club Fritz HRTF or Free-Field EQ struct
%   vtype - view type, 1-4
%
%           HRTF Data
%           1 = L/R IR plot, loop through all locations, no prompt!
%           2 = all az image, loop through el, hit space to advance
%           3 = all az waterfall, loop through el, hit space to advance
%
%           Free-Field EQ Data
%           4 = all free-field EQ IRs
%
% See also: fmake(), ffmake(), fsave()

% modification history
% --------------------
%                ----  v5.8.0  ----
% 05.17.06  JDM  created
% 05.18.06  JDM  added free-field eq view
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

figure(gcf);
clf;

% max HRTF database IR value
if isfield( fstr, 'hrir_l' ),
  m = max( [ max(max(abs(fstr.hrir_l))) max(max(abs(fstr.hrir_r))) ] );
end;

% waterfall view() az,el
% note: view() can cause hidden line removal to break
vaz = 30;
vel = 10;

% view type
switch vtype,

case 1  % ----  IR plot  ----

% plot IRs, loop thru all locations
n = size( fstr.hrir_l, 1 );         % number of HRIR pts
for i = 1 : size( fstr.hgrid, 2 ),  % number of measured locations per ear
  plot( 1:n, fstr.hrir_l(:,i), 'b', 1:n, fstr.hrir_r(:,i), 'r' );
  axis( [ 1 n -m m ] );
  grid on;
  title( sprintf( 'az,el = %d,%d', fstr.hgrid(2,i), fstr.hgrid(1,i) ) );
  pause(0.1);
end;

case 2  % ----  image plot  ----

% image plot of all azimuths for each elevation
cm = colormap(gray);
els = fliplr( sort( unique( fstr.hgrid(1,:) ) ) );  % unique elevations
for i = 1:length(els),
  % left ear
  subplot(1,2,1);
  imagesc( fstr.hrir_l(:,find( fstr.hgrid(1,:) == els(i) ))', [ -m m ] );
  colormap(cm);
  title( sprintf( 'left ear el = %d', els(i) ) );

  % right ear
  subplot(1,2,2);
  imagesc( fstr.hrir_r(:,find( fstr.hgrid(1,:) == els(i) ))', [ -m m ] );
  colormap(cm);
  title( sprintf( 'right ear el = %d', els(i) ) );

  pause;
end;

case 3  % ----  waterfall plot  ----

% waterfall plot of all azimuths for each elevation

els = fliplr( sort( unique( fstr.hgrid(1,:) ) ) );  % unique elevations
for i = 1:length(els),
  azi = find( fstr.hgrid(1,:) == els(i) );   % az indices
  azs = fstr.hgrid( 2, azi );                % az degrees
  irlen = size( fstr.hrir_l( :, azi ), 1 );  % IR length

  % left ear
  subplot(1,2,1);
  waterfall( 1:irlen, azs, fstr.hrir_l( :, azi )' );
  axis( [ 1 irlen min(azs) max(azs) -m m ] );
  title( sprintf( 'left ear el = %d', els(i) ) );
  ylabel( 'Az (degrees)' );
  view( vaz, vel );
  caxis( [ -m m ] );

  % right ear
  subplot(1,2,2);
  waterfall( 1:irlen, azs, fstr.hrir_r( :, azi )' );
  axis( [ 1 irlen min(azs) max(azs) -m m ] );
  title( sprintf( 'right ear el = %d', els(i) ) );
  ylabel( 'Az (degrees)' );
  view( vaz, vel );
  caxis( [ -m m ] );

  pause;
end;

case 4  % ----  free-field eq waterfall plot  ----

% make sure struct is free-field eq struct
if ~isfield( fstr, 'ff_l' ),
  disp( 'fview() error: this view type requires free-field eq struct input.' );
  return;
end;

m = max( [ max(max(abs(fstr.ff_l))) max(max(abs(fstr.ff_r))) ] );
[ irlen irnum ] = size( fstr.ff_l );

subplot(1,2,1);
waterfall( 1:irlen, 1:irnum, fstr.ff_l' )
axis( [ 1 irlen 1 irnum -m m ] );
caxis( [ -m m ] );
title( 'free-field eq data, left ch' );
view( vaz, vel );

subplot(1,2,2);
waterfall( 1:irlen, 1:irnum, fstr.ff_r' )
axis( [ 1 irlen 1 irnum -m m ] );
caxis( [ -m m ] );
title( 'free-field eq data, right ch' );
view( vaz, vel );

otherwise  % ----  invalid view type  ----

disp( 'fview() error: invalid view type, valid = 1-4.' );

end;  % switch
