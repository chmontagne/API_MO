% lfull - convert multiple Listen databases to slab3d format.
%
% lfull requires the user to be cd'd to a directory containing multiple
% Listen .mats.  Both the raw and compensated .mats are required for each
% database.
%
% Output filenames are formatted IRC_####.slh, e.g., IRC_1002.slh.
%
% See also: listen2slab, cfull, dmap

% modification history
% --------------------
%                ----  v6.6.0  ----
% 03.11.11  JDM  created
%                ----  v6.7.2  ----
% 08.12.13  JDM  to slabtools
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

d = dir('IRC_*_C_HRIR.mat');
% as of 3/11/11, all Listen .mats in dir, 51 .mats found, IRC_1002_C_HRIR.mat
% thru IRC_1059_C_HRIR.mat (there are gaps in the numbering)
for c = 1:length(d),
  fprintf( '\nFound %s:\n', d(c).name );
  subNum = str2double( d(c).name(5:8) );
  listen2slab( subNum );
end;
