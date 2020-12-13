function varargout = imodel_cb( h, eventdata, handles, varargin )
% imodel_cb - UI callback routine for imodel.m.
%
% See Also: imodelui.m, imodel_h.m

% modification history
% --------------------
%                ----  v5.0.2  ----
% 04.16.03  JDM  created
% 04.21.03  JDM  added imodel_h, mirror buttons; clean-up
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

% global variables and constants
imodel_h;

sx = get(hsx,'Value');
sy = get(hsy,'Value');
sz = get(hsz,'Value');
xp = get(hxp,'Value');
xn = get(hxn,'Value');
yp = get(hyp,'Value');
yn = get(hyn,'Value');
zp = get(hzp,'Value');
zn = get(hzn,'Value');
mv = get(hbv,'Value');
mz = get(hbz,'Value');
mu = get(hbu,'Value');

imodel( sx, sy, sz, xp, xn, yp, yn, zp, zn, mv, mz, mu );

% display slider values
str = sprintf( '%-3.1f %-3.1f %-3.1f %-3.1f %-3.1f %-3.1f %-3.1f %-3.1f %-3.1f', ...
               sx, sy, sz, xp, xn, yp, yn, zp, zn );
set( hst, 'String', str );

for i = 1:nargout,
  varargout{i} = []; % Cell array assignment
end;
