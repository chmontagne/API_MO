function vallh( s )
% vallh - uses vall() to view all horizontal-plane azimuths in an HRTF database.
%
% vallh( s )
%
% s - sarc struct

% modification history
% --------------------
%                ----  v6.8.1  ----
% 03.13.17  JDM  created
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

if nargin < 1,
  disp( 'vallh error: not enough input arguments.' );
  return;
end;

% tested with:
%
% s1 = slab2sarc('jdm.slh');
% s2 = slab2sarc('MartineG070805A.slh');
%
% caxis values s1 L/R, s2 L/R:
%   -69.2449    4.9595
%   -70.3064    3.6823
% 
%   -68.7625    5.6640
%   -66.8299    9.5556

% !!!! specific dims necessary because XTickLabel labels will not resize
%      properly!
% x, y, width, height
figure('units','normalized','position',[ 0.1 0.4 0.5 0.4 ])

subplot(1,2,1);
vall(s,[],0,1,1);
set(gca,'XTickLabel',num2str(round(10.^str2num(get(gca,'XTickLabel')))));
xlabel('Hz');
colorbar('SouthOutside');
caxis([-70.4 9.6]);  % based on jdm.slh and MartineG070805A.slh

subplot(1,2,2);
vall(s,[],0,1,1,1);
set(gca,'XTickLabel',num2str(round(10.^str2num(get(gca,'XTickLabel')))));
xlabel('Hz');
colorbar('SouthOutside');
caxis([-70.4 9.6]);

colormap('default');  % jet
