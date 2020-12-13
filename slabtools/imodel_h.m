% imodel_h - global variables and constants for the imodel functions.
%
% See Also: imodel.m, imodelui.m, imodel_cb.m

% modification history
% --------------------
%                ----  v5.0.2  ----
% 04.21.03  JDM  created
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR
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

% global constants (used by imodel.m and images.m)
global csx csy csz cxp cxn cyp cyn czp czn;
csx = 5; csy = 4; csz = 3;
cxp = 6; cxn = -6; cyp = 5; cyn = -5; czp = 4; czn = -4;

% global handles, sliders, slider values text, mirror buttons
global hsx hsy hsz hxp hxn hyp hyn hzp hzn hst hbv hbz hbu;
