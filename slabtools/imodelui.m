function imodelui
% imodelui - room image model visualization with user-interface.
%
% imodelui provides a user interface for imodel.  The SX, SY, and SZ sliders
% control source location (note: the source can be placed outside of the room).
% The XP-ZN sliders control the location of the walls.  The first letter of the
% slider label indicates the axis; the second letter indicates the positive (P)
% or negative (N) side of the axis.  This convention is used for labeling the
% reflections as well.  The V, Z, and U (see below) check boxes enable and
% disable the display of mirror rooms ([1], Fig.1).
%
% In the 3D-plot, the sound source is denoted by an 'x'.  1st-order reflections
% are displayed using red lower-case letters, 2nd-order using blue.  Mirror
% rooms are dotted.  The command-line lists the image locations by reflection
% label (D = 'direct path', aa (1st-order) and aabb (2nd-order) = surface(s)
% reflected off of).
%
% The following terms are defined to aid in visualization (the first letter
% is chosen to roughly resemble the sound path):
%   V-type = 1st-order reflection, labeled aa
%   Z-type = 2nd-order reflection, parallel walls, labeled aPaN and aNaP
%   U-type = 2nd-order reflection, orthogonal walls, labeled aabb (aabb is
%            equivalent to bbaa, i.e., the algorithm doesn't know which wall
%            was encountered first)
%
% To rotate axes and zoom, use the Figure Toolbar (see the Figure dialog View
% menu).
%
% Reference:
% [1] J. Allen and D. Berkley, "Image method for efficiently simulating
%     small-room acoustics", JASA 65(4), 1979.
%
% See Also: imodel.m, imodelab.m, imodel_cb.m, imodel_h.m

% modification history
% --------------------
%                ----  v5.0.2  ----
% 04.16.03  JDM  created
% 04.21.03  JDM  added imodel_h, mirror buttons; clean-up
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR
%
% JDM == Joel D. Miller
%
% Notes:
%
% The Figure Toolbar allows zooming and axis rotation.  Displaying GUI controls
% hides the Figure Toolbar.  The toolbar can be displayed using the View menu
% on the Figure dialog.

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

% display sound images figure, use defaults
imodel;

% original string UI callback, replaced by imodel_cb()
%s = [ 'global hsx hsy hsz hxp hxn hyp hyn hzp hzn;', ...
%      'images( get(hsx,''Value''), get(hsy,''Value''), get(hsz,''Value''),', ...
%              'get(hxp,''Value''), get(hxn,''Value''), get(hyp,''Value''),', ...
%              'get(hyn,''Value''), get(hzp,''Value''), get(hzn,''Value'') );'];

% slider labels and values
uicontrol( 'Style', 'text', 'Position', [ 5 100 175 11 ], 'String', ...
           'SX  SY  SZ  XP  XN  YP  YN  ZP ZN', 'HorizontalAlignment', 'left' );
hst = uicontrol( 'Style', 'text', 'Position', [ 5 88 175 11 ] );

% source location and room dimension sliders
hsx = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', csx, ...
                 'Position', [   5 5 15 80 ], 'Callback', 'imodel_cb' );
hsy = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', csy, ...
                 'Position', [  25 5 15 80 ], 'Callback', 'imodel_cb' );
hsz = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', csz, ...
                 'Position', [  45 5 15 80 ], 'Callback', 'imodel_cb' );
hxp = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', cxp, ...
                 'Position', [  65 5 15 80 ], 'Callback', 'imodel_cb' );
hxn = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', cxn, ...
                 'Position', [  85 5 15 80 ], 'Callback', 'imodel_cb' );
hyp = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', cyp, ...
                 'Position', [ 105 5 15 80 ], 'Callback', 'imodel_cb' );
hyn = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', cyn, ...
                 'Position', [ 125 5 15 80 ], 'Callback', 'imodel_cb' );
hzp = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', czp, ...
                 'Position', [ 145 5 15 80 ], 'Callback', 'imodel_cb' );
hzn = uicontrol( 'Style', 'slider', 'Min', -10, 'Max', 10, 'Value', czn, ...
                 'Position', [ 165 5 15 80 ], 'Callback', 'imodel_cb' );

% mirror room checkboxes
uicontrol( 'Style', 'text', 'Position', [ 185, 23, 15, 15 ], 'String', 'V' );
hbv = uicontrol( 'Style', 'checkbox', 'Position', [ 185, 5, 15, 15 ], ...
                 'Callback', 'imodel_cb' );
uicontrol( 'Style', 'text', 'Position', [ 205, 23, 15, 15 ], 'String', 'Z' );
hbz = uicontrol( 'Style', 'checkbox', 'Position', [ 205, 5, 15, 15 ], ...
                 'Callback', 'imodel_cb' );
uicontrol( 'Style', 'text', 'Position', [ 225, 23, 15, 15 ], 'String', 'U' );
hbu = uicontrol( 'Style', 'checkbox', 'Position', [ 225, 5, 15, 15 ], ...
                 'Callback', 'imodel_cb' );
