% vcfreqlog - verify HRTF database collection HRIR magnitude responses.
%
% vcfreqlog is a simple response visualization script.
%
% See also: vcfreq

% modification history
% --------------------
%                ----  v6.7.3  ----
% 11.12.13  JDM  created from vcfreq to verify CIPIC pinna notch freq
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

d = dir('*.slh');
az = 0;
el = 0;
for k = 1:length(d),
  h = slab2sarc( d(k).name );
  figure(gcf);
  clf;
  hold on;
  % to verify CIPIC 2001 paper freq-notch variability:
  % use Figure window "data cursor" to select left-most notch between approx:
  % 7600+3*1050 = 10750
  % 7600-3*1050 =  4450
  [ax1,ax2] = plotresp( h.ir(:,hil(az,el,h.dgrid)), 1024, h.fs, 'b-', ...
                        1000, 20000, -60, 10, 1 );
  [ax1,ax2] = plotresp( h.ir(:,hir(az,el,h.dgrid)), 1024, h.fs, 'r-', ...
                        1000, 20000, -60, 10, 1 );
  % prevent tex underscore-to-subscript
  title( ax1, sprintf('Frequency Response - %s (%d) el %.0f', d(k).name, ...
         k, el), 'Interpreter', 'none' );
  pause;
end;
