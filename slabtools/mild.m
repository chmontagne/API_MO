function mild( file_in, file_out )
% mild - sets all HRIRs to their scalar gain equivalent.
%
% mild( file_in, file_out )
%
% file_in  - input slab3d HRTF database
% file_out - output slab3d HRTF database
%
% The original itd is preserved.

% modification history
% --------------------
%                ----  v5.7.0  ----
% 07.12.05  JDM  created from mhrir.m (see also henfilt.m "scalar gain")
% 07.13.05  JDM  numPts = 1
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
comment2 = sprintf( '%s, ILDs', comment );

% set all HRIRs to their scalar gain equivalent
numPts = 1;
meIr = zeros( numPts, size(srcIr,2) );
meIr( 1, 1:size(srcIr,2) ) = ...
  sqrt(sum(srcIr(:,1:size(srcIr,2)).*srcIr(:,1:size(srcIr,2))));

% write all-hrirs-equal database
mat2slab( file_out, meIr, srcItd, srcMap, azInc, elInc, numPts, name, ...
          comment2, fs, 0 );
