function mhrir( file_in, file_out, az, el )
% mhrir - sets all HRIRs to the HRIR at the specified location.
%
% mhrir( file_in, file_out, az, el )
%
% file_in  - input slab3d HRTF database
% file_out - output slab3d HRTF database
% az       - azimuth (degrees)
% el       - elevation (degrees)
%
% The original itd is preserved.

% modification history
% --------------------
% 03.06.00  JDM   created (m = modify)
% 05.04.00  JDM   added noscale flag to mat2slab()
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
comment2 = sprintf( '%s, hrirs equal', comment );

% set all HRIRs to the az,el HRIR
% all left ear IRs
meIr( 1:size(srcIr,1), 1:size(srcMap,2) ) = ...
  srcIr( :, ones(1,size(srcMap,2)) * hindex( az, el, srcMap ) );
% all right ear IRs
meIr( 1:size(srcIr,1), [1:size(srcMap,2)] + size(srcMap,2) ) = ...
  srcIr( :, ones(1,size(srcMap,2)) * (hindex( az, el, srcMap )+size(srcMap,2)) );

% write all-hrirs-equal database
mat2slab( file_out, meIr, srcItd, srcMap, azInc, elInc, numPts, name, ...
          comment2, fs, 0 );
