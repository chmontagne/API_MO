% gridprint - CIPIC/Listen/ACD/slab3d HRTF measurement/database grid PNGs.
%
% See also: grids

% modification history
% --------------------
%                ----  v6.7.3  ----
% 11.15.13  JDM  created from grids
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

figure(gcf); clf;
%figure;
grid;
colormap('white');
sphere(12);
hold on;
view(-140,30);
dim = 1.5;
axis( [ -dim dim -dim dim -dim dim ] );
axis square;
xlabel('x');
ylabel('y');
zlabel('z');

% slab3d
%[sgrid sx sy sz ] = grids(30,18,0);  % jdm.slh
[sgrid sx sy sz ] = grids(15,15,0);  % Listen, IRC_1002.slh
[sgrid5 sx5 sy5 sz5 ] = grids(5,5,0);  % CIPIC, subject_003.slh

% CIPIC
[cgrid cx cy cz ] = grids(0,0,1);

% Listen
[lgrid lx ly lz ] = grids(0,0,2);

% ACD
[agrid ax ay az ] = grids(0,0,3);

% grids default figure
if 0,
plot3(sx,sy,sz,'ro');
plot3(cx,cy,cz,'bx');
plot3(lx,ly,lz,'g*');
plot3(ax,ay,az,'ms');
legend('sphere','slab3d','CIPIC','Listen','ACD');
title( 'azInc 30, elInc 18' );
end;

if 0,
plot3(cx,cy,cz,'b.');
title( 'CIPIC Grid' );
print(gcf,'-dpng','grids_cipic.png');
end;

if 0,
plot3(sx5,sy5,sz5,'b.');
title( 'CIPIC SLH Grid Az 5 El 5' );
print(gcf,'-dpng','grids_cipic_slh_5_5.png');
end;

if 0,
plot3(sx5,sy5,sz5,'rx');
plot3(cx,cy,cz,'b.');
title( 'CIPIC SLH Grid Az 5 El 5' );
print(gcf,'-dpng','grids_cipic_and_slh_5_5.png');
end;

if 0,
plot3(lx,ly,lz,'bo');
title( 'Listen Grid' );
print(gcf,'-dpng','grids_listen.png');
end;

if 0,
plot3(sx,sy,sz,'bo');
title( 'Listen SLH Grid Az 15 El 15' );
print(gcf,'-dpng','grids_listen_slh_15_15.png');
end;

if 1,
plot3(sx,sy,sz,'rx');
plot3(lx,ly,lz,'bo');
title( 'Listen SLH Grid Az 15 El 15' );
print(gcf,'-dpng','grids_listen_and_slh_15_15.png');
end;
