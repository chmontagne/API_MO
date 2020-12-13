% fload3.m - load the Club Fritz data created by fbuild3.m.
%
% See also: fbuild3.m, fview.m

% modification history
% --------------------
%                ----  v6.0.0  ----
% 01.11.07  JDM  created from fload2.m
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

%------------------------------------------------------------------------------
% Neumann KU 100 Mics (Built-In Fritz Mics)
%------------------------------------------------------------------------------

if ~exist('frn1'),
  % acd = lab, 1 = submission 1, r = raw
  frn1 = load( 'acd1r' );  % f = fritz, r = raw, n = neumann

  % repeatability measurements
  frn2 = load( 'acd2r' );
  frn3 = load( 'acd3r' );
end;
