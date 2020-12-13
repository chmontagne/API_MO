function mitd( file_in, file_out, az, el )
% mitd - Sets all ITDs to the ITD at the specified location.
%
% mitd( file_in, file_out, az, el )
%
% file_in  - input database
% file_out - output database
% az       - azimuth (degrees)
% el       - elevation (degrees)
%
% The original ir's are preserved.

% modification history
% --------------------
% 03.06.00  JDM   created (m = modify)
% 05.01.02  JDM   updated mat2slab() call
% 11.13.02  JDM   added SLH header info
%
% JDM == Joel David Miller

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

% read source database
[ srcIr,srcItd,srcMap,version,name,strDate,comment,azInc,elInc,numPts,fs ] ...
  = slab2mat( file_in );

% append comment explaining operation
comment2 = sprintf( '%s, itds equal', comment );

% set all itds to the az,el itd
meItd = zeros( 1, size( srcMap, 2 ) );
meItd(:) = srcItd( hindex( az, el, srcMap ) );

% write all-itds-equal database
mat2slab( file_out, srcIr, meItd, srcMap, azInc, elInc, numPts, name, ...
          comment2, fs, 0 );
