function bound( data, color, sdev, plotEnd, low )
% bound - add mean and std dev lines to plot.
%
% Support script (e.g., vcenf.m).
%
% bound( data, color, sdev, plotEnd, low )

% modification history
% --------------------
%                ----  v6.7.1  ----
% 12.22.12  JDM  created
%                ----  v6.7.2  ----
% 10.16.13  JDM  added to slab3d\slabtools\
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

if nargin < 4,
  plotEnd = length(data);
end;
if nargin < 5,
  low = 1;
end;

hold on;
meanUnder = mean(data);
stdUnder = std(data);

hl = line( [ 1 plotEnd ], [ meanUnder meanUnder ] );
set(hl,'Color',color);
set(hl,'LineStyle','--');

high = meanUnder + sdev*stdUnder;
hl = line( [ 1 plotEnd ], [ high high ] );
set(hl,'Color',color);

if low,
  low  = meanUnder - sdev*stdUnder;
  hl = line( [ 1 plotEnd ], [ low low ] );
  set(hl,'Color',color);
end;
