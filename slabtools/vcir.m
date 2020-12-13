% vcir - verify HRTF database collection HRIRs.
%
% vcir is a simple all-IRs-at-once visualization script.
%
% See also: cipic2slab, listen2slab, sarc

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.09.11  JDM  created
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

d = dir('*.slh');
%d = dir('subject_*.slh');  % verify cipic
%d = dir('IRC_*.slh');  % verify Listen
for k = 1:length(d),
  h = slab2sarc( d(k).name );

  % view all HRIRs simultaneously
  figure(gcf);
  plot( h.ir );
  axis([0 132 -1 1]);
  grid on;
  % prevent tex underscore-to-subscript
  title( d(k).name, 'Interpreter', 'none' );
  % if rect window (i.e., no hanning taper)
  %fprintf('%s max_tail = %.3f\n', d(k).name, max(abs(h.ir(128,:))));

  pause;
end;
