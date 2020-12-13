% fload.m - load the Club Fritz data created by fbuild.m.
%
% See also: fbuild.m, fview.m

% modification history
% --------------------
%                ----  v5.8.0  ----
% 05.10.06  JDM  created
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

%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
% The NASA ACD data used in this file is preliminary test data and is
% NOT an "official" Club Fritz submission!  It is being provided to demonstrate
% the Club Fritz submission format and to provide an initial rough submission
% while we finalize the development of our measurement system.
%
% NOTE: There exist significant known anomalies in the data!
%
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%------------------------------------------------------------------------------
% Neumann KU 100 Mics (Built-In Fritz Mics)
%------------------------------------------------------------------------------

% load the Club Fritz .mat HRIR database into a Club Fritz struct;
% raw neumann mic measurement data;
% acd = lab, 1 = submission 1, r = raw data
if ~exist('frn'),
  frn = load( 'acd1r' );
end;

% processed data corresponding to above;
% acd = lab, 1 = submission 1, p = processed data
if ~exist('fpn'),
  fpn = load( 'acd1p' );
end;

% load Club Fritz free-field eq struct;
% since KU 100 mics should not be removed from Fritz, this will contain the
% speaker_to_measurement_mic response;
% acd = lab, 1 = submission 1, ff = free field
if ~exist('ffn'),
  ffn = load( 'acd1ff' );
end;

%------------------------------------------------------------------------------
% Panasonic WM-61 Insert Mics
%------------------------------------------------------------------------------

if ~exist('frp'),
  % similar to above but insert mics
  frp = load( 'acd2r' );
  fpp = load( 'acd2p' );

  % this ff eq data contains the mics used in the insert mic measurement
  ffp = load( 'acd2ff' );
end;
