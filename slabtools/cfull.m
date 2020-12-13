% cfull - convert the entire CIPIC database to slab3d format.
%
% cfull requires the user to be cd'd to the CIPIC database directory
% standard_hrir_database\ installed on a hard drive.
%
% Output filenames are formatted subject_#.slh, e.g., subject_127.slh.
%
% See also: cipic2slab, lfull, dmap

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.09.11  JDM  created
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

d = dir('subject_*');
% should be 45 dirs, subject_003 thru subject_165
% (there are gaps in the numbering)
for c = 1:length(d),
  if d(c).isdir,
    fprintf( '\nFound %s:\n', d(c).name );
    subNum = str2double( d(c).name(9:11) );
    cipic2slab( subNum );
  end;
end;
