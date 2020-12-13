function logbins( n, inc )
% logbins - calculates the number of linear frequency FFT bins in log10 bins
%
% logbins( n, inc )
%
%   n   = FFT size
%   inc = log increment
%
% Defaults:
%   n   = 256
%   inc = log10(2) = log10( freq2 ) - log10( freq1 ) where freq0 = 0 Hz, DC
%
% fs = 44100 samples/s

% modification history
% --------------------
% 10.09.03  JDM  created
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR, updated comments and code
%
% JDM == Joel D. Miller

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

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

if nargin < 1,
  n = 256;
end;

if nargin < 2,
  inc = log10(2);
end;

fprintf( '\nN = %d, inc = %f\n\n', n, inc );

fs      = 44100;
f       = 0 : fs/n : fs/2;
endlogf = log10( fs/2 );
logf    = 10.^( log10(f(2)) : inc : (endlogf+inc) );
bins    = zeros( 1, length(logf) );
curbin  = 1;

for i=1:(n/2)+1,
  if f(i) <= logf( curbin ) + 0.0001,
    bins( curbin ) = bins( curbin ) + 1;
  else,
    curbin = curbin + 1;
    bins( curbin ) = 1;
  end;
end;

format bank;
[ logf; bins ]'
format;

% should be N/2 + 1, f(N/2 + 1) = fs/2, f(1)= DC
sum(bins)
