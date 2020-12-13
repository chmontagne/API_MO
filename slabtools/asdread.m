function data = asdread( filename )
% asdread - reads an AvadeServer data collection file.
%
% asdread( filename )
%
% filename - name of data collection file
%
% filename format: asd<#columns>_<data_type>_<client_prefix>.<timestamp>.bin

% modification history
% --------------------
%                ----  v6.8.2  ----
% 08.21.17  JDM  created
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

% 1 param required
if nargin ~= 1,
  disp( 'asdread error: fsave() requires 1 input argument, filename.' );
  return;
end;

fid = fopen( filename );

% read entire file where each value is a float
floatData = fread( fid, 'single' );

% the number of data columns is appended to the "asd" (AvadeServer Data) prefix
col = sscanf( filename, 'asd%d' );

% reshape the data into a matrix with col columns
data = reshape( floatData, col, length(floatData)/col )';

fclose( fid );
