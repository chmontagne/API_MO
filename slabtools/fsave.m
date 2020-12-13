function fsave( s, filename )
% fsave - saves a Club Fritz struct.
%
% fsave( s, filename )
%
% s        - Club Fritz struct (HRIR data or free-field EQ data)
% filename - name of Club Fritz .mat file (.mat extension not necessary)
%
% fsave saves the Club Fritz struct s to "<filename>.mat".
%
% See also: fmake(), ffmake(), fview()

% modification history
% --------------------
%                ----  v5.5.0  ----
% 10.20.04  JDM  created
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

% 2 params required
if nargin ~= 2,
  disp( 'fsave error: fsave() requires 2 input arguments.' );
  return;
end;

% convert fields to vars for saving
x = fieldnames(s);
for i=1:length(x),
  eval( [x{i} '= s.' x{i} ';'] ); % copy field value to var with field name
end;

% save vars
save( filename, x{:} );
