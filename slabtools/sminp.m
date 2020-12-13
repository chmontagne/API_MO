function hout = sminp( h )
% sminp - converts sarc IRs to minimum phase.
%
% hout = sminp( h );
%
% h    - sarc struct input
% hout - sarc struct output

% modification history
% --------------------
%                ----  v5.8.0  ----
% 04.20.06  JDM  created
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

[numpts,numpos] = size( h.ir );

hout = h;
for i=1:numpos,
  % pad rceps() to reduce low-freq artifacts (see ffeq.m)
  [ dummy, tempir ] = rceps( [ h.ir(:,i); zeros(8192-numpts,1) ] );
  hout.ir(:,i) = tempir(1:numpts);
end;

hout.mp = 1;
