% hencbmat - calls hencb() to generate critical-band MAT files.
%
% hencbmat generates critical-band MAT files for all SLH files found in the
% current directory.  Use hencbview to view.
%
% See also: hencbview, hencb

% modification history
% --------------------
%                ----  v6.6.0  ----
% 05.04.11  JDM  created
%                ----  v6.6.1  ----
% 04.24.12  JDM  hencb(h,0,0,0,0,1,1,1) -> hencb(h,1,1,0,1,20,1,1)
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

% generate critical-band MAT files for all SLH files found in current dir
d = dir('*.slh');
disp('Generating critical-band MAT files in current directory...');
for k = 1:length(d),
  h = slab2sarc( d(k).name );
  % hencb( h, tb, bSphere, table, oneLine, cbn, bSave, bQuiet )
  hencb(h,1,1,0,1,20,1,1);
end;
disp('Done.');
