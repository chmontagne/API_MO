% fload2.m - load the Club Fritz data created by fbuild2.m.
%
% See also: fbuild2.m, fview.m

% modification history
% --------------------
%                ----  v6.0.0  ----
% 12.12.06  JDM  created from fload.m
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

% load Club Fritz free-field eq structs;
% since KU 100 mics should not be removed from Fritz, these will contain the
% speaker_to_measurement_mic response
if ~exist('ffn1'),
  % acd = lab, 1 = submission 1, ff = free field
  ffn1 = load( 'acd1ff' );

  % repeatability measurement
  ffn2 = load( 'acd2ff' );
end;

%------------------------------------------------------------------------------
% Panasonic WM-61 Insert Mics
%------------------------------------------------------------------------------

if ~exist('frp1'),
  % acd = lab, 1 = submission 1, r = raw
  frp1 = load( 'acd1r' );

  % repeatability measurements
  frp2 = load( 'acd2r' );
  frp3 = load( 'acd3r' );

  % ff eq data with Panasonic insert mics
  ffp1 = load( 'acd3ff' );
  ffp2 = load( 'acd4ff' );
end;
