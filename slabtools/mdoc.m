% mdoc - make slabtools documentation
%
% * m2html should be in matlab path, e.g., C:\Apps\m2html
% * m2html file mfileparse.m mex file code block (line 145) should be
%   commented-out to avoid matlab v7.7.0 error
% * run mdoc from slabtools directory
% * mdoc simply executes:
%    >> m2html('mfiles','slabtools','htmldir','docm','source','off');
% * move docm dir to \slab3d\doc and rename slabtools
%
% Reference: m2html

% modification history
% --------------------
%                ----  v6.3.0  ----
% 02.27.09  CJM  created
%
% CJM == Joel D. Miller, Copyright Joel D. Miller (see below)

%23456789 123456789 123456789 123456789 123456789 123456789 123456789 1234567890

% Copyright (C) 2006-2018 Joel D. Miller.  All Rights Reserved.
%
% This software constitutes a "Modification" to the SLAB software system and is
% distributed under the NASA Open Source Agreement (NOSA), version 1.3.
% The NOSA has been approved by the Open Source Initiative.  See the file
% NOSA.txt at the top of the distribution directory tree for the complete NOSA
% document.

m2html('mfiles','slabtools','htmldir','docm','source','off');
