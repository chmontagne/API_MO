function [version,name,strDate,comment,azInc,elInc,numPts,fs] = shead2(fid)
% shead2 - reads slab3d Version 2 HRTF database header.
%
% [v,n,d,c,a,e,p,f] = shead2( fid )
%
% fid - file identifier
%
% v - version number
% n - name string
% d - date string
% c - comment string
% a - azimuth increment
% e - elevation increment
% p - number of HRIR points
% f - sampling rate

% modification history
% --------------------
% 06.22.01  JDM   created
% 11.13.02  JDM   added char()' to string reads
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

% read header
version = fread( fid, 1,   'short' );          % database format version
name    = char( fread( fid, 32,  'char' ) )';  % head name
strDate = char( fread( fid, 8,   'char' ) )';  % date - month, day, year
comment = char( fread( fid, 256, 'char' ) )';  % comment string
azInc   = fread( fid, 1,   'short' );          % azimuth increment
elInc   = fread( fid, 1,   'short' );          % elevation increment
numPts  = fread( fid, 1,   'short' );          % number of HRIR pts
fs      = fread( fid, 1,   'long'  );          % sample rate
