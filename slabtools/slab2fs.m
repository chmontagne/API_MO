% slab2fs - resamples the default HRTF database

% modification history
% --------------------
%                ----  v5.7.0  ----
% 08.01.05  JDM  created
%                ----  v6.0.1  ----
% 10.26.07  CJM  added 8000 Hz database
%
% JDM == Joel D. Miller
% CJM == Joel D. Miller, Copyright Joel D. Miller (see below)

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

% CJM modifications:
%
% Copyright (C) 2006-2018 Joel D. Miller.  All Rights Reserved.
%
% This software constitutes a "Modification" to the SLAB software system and is
% distributed under the NASA Open Source Agreement (NOSA), version 1.3.
% The NOSA has been approved by the Open Source Initiative.  See the file
% NOSA.txt at the top of the distribution directory tree for the complete NOSA
% document.

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% hrir - all left-ear followed by all right-ear impulse responses
% itd  - interaural time delays
% map  - measurement grid
% v    - version number
% n    - name string
% d    - date string
% c    - comment string
% a    - azimuth increment
% e    - elevation increment
% pts  - number of HRIR points
% f    - sample rate
[ hrir44, itd44, map, v, n, d, c, a, e, pts, f ] = ...
  slab2mat( '\slab3d\hrtf\jdm.slh' );

% out_rate = (p/q) * in_rate

% 8192 = (2048/11025) * 44100
% see factor(8192) and factor(44100), eliminate dupes and use prod()
p = 2048;
q = 11025;
hrirPQ = resample( hrir44, p, q );
itdPQ = itd44*(p/q);
mat2slab( '\slab3d\hrtf\jdm8.slh', hrirPQ, itdPQ, map, a, e, ...
          size(hrirPQ,1), n, c, f*(p/q) );

% 11025 = (1/4) * 44100
p = 1;
q = 4;
hrirPQ = resample( hrir44, p, q );
itdPQ = itd44*(p/q);
mat2slab( '\slab3d\hrtf\jdm11.slh', hrirPQ, itdPQ, map, a, e, ...
          size(hrirPQ,1), n, c, f*(p/q) );

% 22050 = (1/2) * 44100
p = 1;
q = 2;
hrirPQ = resample( hrir44, p, q );
itdPQ = itd44*(p/q);
mat2slab( '\slab3d\hrtf\jdm22.slh', hrirPQ, itdPQ, map, a, e, ...
          size(hrirPQ,1), n, c, f*(p/q) );

% 48000 = (160/147) * 44100
p = 160;
q = 147;
hrirPQ = resample( hrir44, p, q );
itdPQ = itd44*(p/q);
mat2slab( '\slab3d\hrtf\jdm48.slh', hrirPQ, itdPQ, map, a, e, ...
          size(hrirPQ,1), n, c, f*(p/q) );

% 8000 = (80/441) * 44100
p = 80;
q = 441;
hrirPQ = resample( hrir44, p, q );
itdPQ = itd44*(p/q);
mat2slab( '\slab3d\hrtf\jdm8000.slh', hrirPQ, itdPQ, map, a, e, ...
          size(hrirPQ,1), n, c, f*(p/q) );
% to verify:
% h8=slab2sarc('jdm8000.slh');
% h4=slab2sarc('jdm.slh');
% hlab(h8,h4)
