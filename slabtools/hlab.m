function varargout = hlab(varargin)
% hlab - HRTF Lab, HRTF analysis and visualization application.
%
% hlab( s1, s2 )
%
% s1:  slab3d archive struct 1 (required)
% s2:  slab3d archive struct 2 (optional)
%
% hlab() provides a graphical user interface for the command-line utilities
% vir(), vall(), hen(), and vitd().
%
% When viewing two sarcs, if an ITD is displayed above the figure, it is the
% ITD of HRTF 2.
%
% When loading CIPIC sarcs, use s1.  s1 includes the NearGrid feature that
% maps the CIPIC grid to a fixed-increment grid.  The distance from the
% actual CIPIC grid location to the "near grid" location is shown in cm's
% assuming a 1m radius sphere.  This feature is for comparing CIPIC sarcs
% to fixed-grid sarcs.  If not comparing to other sarcs, the GRID slider
% can be used to increment through the HRTF locations.  The locations are
% ordered el-grouped-by-az in CIPIC coordinates.  The values displayed on
% the screen, however, are in slab3d coordinates.  To visualize this mapping,
% run grids().
%
% See also: vir, vall, hen, grids, vitd

% modification history
% --------------------
%                ----  v5.4.0  ----
% 10.27.03  JDM  created using GUIDE, based on virui()
% 10.29.03  JDM  added UI handlers
% 10.30.03  JDM  added GRID slider
% 10.31.03  JDM  added second sarc
% 11.03.03  JDM  added ear selection, vir() styles, mdata2
% 11.07.03  JDM  added neargrid, follow1
% 11.10.03  JDM  added saved neargrid
% 11.12.03  JDM  added vall()
% 11.21.03  JDM  updated to new v4 sarc; window resizable
% 11.24.03  JDM  added "Figure Window" and energy displays
%                ----  v5.5.0  ----
% 06.23.04  JDM  swapped azr,elr var names in neargrid(); added usage comments
% 09.01.04  JDM  integrated vitd()
%                ----  v5.8.0  ----
% 04.19.06  JDM  added IR and mag legend()
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

% HLAB Application M-file for hlab.fig
%    FIG = HLAB launch hlab GUI.
%    HLAB('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 24-Nov-2003 12:00:45

% Notes:
% * Sometimes az,el sliders are disabled due to a non-fixed-inc grid.

if nargin == 0,
  disp( 'hlab error - sarc handle parameter required.' );
  return;
end;

% launch GUI for 1 or 2 sarc args
if nargin < 3,

	fig = openfig(mfilename,'new');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it.
  % This struct is also used for global data.
	handles = guihandles(fig);

  % store sarc struct (HRTF)
  s = varargin{1};
  handles.s = s;

  % hrtf2 sliders follow hrtf1 sliders flag
  handles.follow1 = 0;
  set( handles.hfollow1, 'Value', handles.follow1 );

  % mag log freq axis flag
  handles.logfreq = 1;
  set( handles.hlogfreq, 'Value', handles.logfreq );

  % ear display
  handles.edisp = 2; % both
  UpdateEar( handles );

  % window length
  winlen = [32:32:1024]';
  set( handles.hwinlen, 'String', winlen );
  handles.winlen = get( handles.hwinlen, 'Value' ) * 32;

  % init window offset sliders
  n = 512;
  set( handles.hwinoff,  'Min', 1, 'Max', n, 'Value', 1, ...
       'SliderStep', [ 1/n 1/n ] );
  set( handles.htwinoff, 'String', '1' );
  handles.winoff = 1;
  set( handles.hwinoff2, 'Min', 1, 'Max', n, 'Value', 1, ...
       'SliderStep', [ 1/n 1/n ] );
  set( handles.htwinoff2, 'String', '1' );
  handles.winoff2 = 1;

  %----------------------------------------------------------------------------
  % the following code should match the sarc 2 code below

  % sarc name
  set( handles.hthrtf1, 'String', s.name );

  % if fixed-increment az,el, init az,el sliders
  if s.finc,
		% processed az's ordered from max to min
		handles.azMax = max( s.dgrid(2,:) );
		handles.azMin = min( s.dgrid(2,:) );
		
		% processed el's ordered from max to min
		handles.elMax = max( s.dgrid(1,:) );
		handles.elMin = min( s.dgrid(1,:) );

    % slider steps
		handles.azstep = 1/((handles.azMax-handles.azMin)/s.azinc + 1);
		handles.elstep = 1/((handles.elMax-handles.elMin)/s.elinc + 1);

		% azimuth slider
		set( handles.haz, 'Min', handles.azMin, 'Max', handles.azMax, ...
         'Value', 0, 'SliderStep', [ handles.azstep handles.azstep ] );
    % elevation slider
		set( handles.hel, 'Min', handles.elMin, 'Max', handles.elMax, ...
         'Value', 0, 'SliderStep', [ handles.elstep handles.elstep ] );
  else,
    % disable az and el sliders
    set( handles.haz, 'Enable', 'off' );
    set( handles.hel, 'Enable', 'off' );

    % enable near grid button
    set( handles.hnear, 'Enable', 'on' );
  end;

  % init GRID slider
  glen = size( s.dgrid, 2 );
  set( handles.hgrid, 'Min', 1, 'Max', glen, 'Value', 1, ...
       'SliderStep', [ 1/glen 1/glen ] );

  % default az,el
  handles.az  = 0;
  handles.el  = 0;
  handles.az2 = 0;
  handles.el2 = 0;

	guidata(fig, handles);

  % GUIDE/Tools/Application Options.../Command-line accessibility must be
  % set to On to access the app figure from here; Callback will cause a new
  % figure window to be opened if no other figure exists.

	% update IR and mag displays
  UpdateDisplay( handles, handles.hir, handles.hmag );

  % end of sarc 2 matching code
  %----------------------------------------------------------------------------

	if nargout > 0
		varargout{1} = fig;
	end
end;

% -----------------------------------------------------------------------------
% if second sarc arg
if nargin == 2,
  % store sarc struct (HRTF)
  s = varargin{2};
  handles.s2 = s;

  % sarc name
  set( handles.hthrtf2, 'String', s.name );

  % init slider vars
  if s.finc,
		% processed az's ordered from max to min
		handles.azMax2 = max( s.dgrid(2,:) );
		handles.azMin2 = min( s.dgrid(2,:) );
		
		% processed el's ordered from max to min
		handles.elMax2 = max( s.dgrid(1,:) );
		handles.elMin2 = min( s.dgrid(1,:) );

    % slider steps
		handles.azstep2 = 1/((handles.azMax2-handles.azMin2)/s.azinc + 1);
		handles.elstep2 = 1/((handles.elMax2-handles.elMin2)/s.elinc + 1);

		% azimuth slider
		set( handles.haz2, 'Min', handles.azMin2, 'Max', handles.azMax2, ...
         'Value', 0, 'SliderStep', [ handles.azstep2 handles.azstep2 ] );
    % elevation slider
		set( handles.hel2, 'Min', handles.elMin2, 'Max', handles.elMax2, ...
         'Value', 0, 'SliderStep', [ handles.elstep2 handles.elstep2 ] );
  else,
    % disable az and el sliders
    set( handles.haz2, 'Enable', 'off' );
    set( handles.hel2, 'Enable', 'off' );
  end;

  % init GRID slider
  glen = size( s.dgrid, 2 );
  set( handles.hgrid2, 'Min', 1, 'Max', glen, 'Value', 1, ...
       'SliderStep', [ 1/glen 1/glen ] );

	guidata(fig, handles);

  % GUIDE/Tools/Application Options.../Command-line accessibility must be
  % set to On to access the app figure from here; Callback will cause a new
  % figure window to be opened if no other figure exists.

	% update IR and mag displays
  UpdateDisplay( handles, handles.hir, handles.hmag );
end;

% -----------------------------------------------------------------------------
% INVOKE NAMED SUBFUNCTION OR CALLBACK
if ischar(varargin{1})
	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end
end


% -----------------------------------------------------------------------------
function UpdateEar( handles )

switch handles.edisp
  case 0
    set( handles.hleft,  'Value', 1 );
    set( handles.hright, 'Value', 0 );
    set( handles.hboth,  'Value', 0 );
  case 1
    set( handles.hleft,  'Value', 0 );
    set( handles.hright, 'Value', 1 );
    set( handles.hboth,  'Value', 0 );
  case 2
    set( handles.hleft,  'Value', 0 );
    set( handles.hright, 'Value', 0 );
    set( handles.hboth,  'Value', 1 );
end;


% -----------------------------------------------------------------------------
function ng = neargrid( azInc, elInc, inGrid )
fprintf( 'Computing neargrid\n' );
ng = zeros( 360/azInc, 180/elInc + 1, 2 ); % size alloc
azi = 0;
for az = 180:-azInc:(-180+azInc),
  azi = azi + 1;
%  fprintf('\n%4d',az);
  eli = 0;
  for el = 90:-elInc:-90,
    eli = eli + 1;
    x = cos( pi*el/180 ) * sin( pi*az/180 );
    y = cos( pi*el/180 ) * cos( pi*az/180 );
    z = sin( pi*el/180 );

    % find min distance of inGrid locations to current slab location
    dist = zeros( 1, size(inGrid,2) );
    for i=1:size(inGrid,2),
      elr = pi*inGrid(1,i)/180;
      azr = pi*inGrid(2,i)/180;
      xi = cos( elr ) * sin( azr );
      yi = cos( elr ) * cos( azr );
      zi = sin( elr );
      dist(i) = (xi-x)*(xi-x) + (yi-y)*(yi-y) + (zi-z)*(zi-z);
    end;
    [ minval minindex ] = min( dist );
    ng( azi, eli, 1 ) = minindex;
    ng( azi, eli, 2 ) = sqrt( minval );
    fprintf( '%4d (%2d) %3d (%2d) %4d (%6.1f,%6.1f) %f\n', ...
             az, azi, el, eli, minindex, ...
             inGrid(2,minindex), inGrid(1,minindex), ng( azi, eli, 2 ) );
%    fprintf('.');
  end;
end;
fprintf('\n');


%------------------------------------------------------------------------------
function UpdateDisplay( handles, hview1, hview2 )

% vall() ear display only left or right
edisp = handles.edisp;
% vall() both ears to left ear
if edisp == 2,
  edisp = 0;
end;
tflog = handles.logfreq;

disp = get( handles.hazelview, 'Value' );
switch disp,
  case 1 % az,el
    VirDisplay( handles, hview1, hview2 );
  case 2 % all az IRs
    az  = [];
    el  = handles.el;
    az2 = [];
    el2 = handles.el2;
    tf  = 0;
  case 3 % all el IRs
    az  = handles.az;
    el  = [];
    az2 = handles.az2;
    el2 = [];
    tf  = 0;
  case 4 % all az mags
    az  = [];
    el  = handles.el;
    az2 = [];
    el2 = handles.el2;
    tf  = 1;
  case 5 % all el mags
    az  = handles.az;
    el  = [];
    az2 = handles.az2;
    el2 = [];
    tf  = 1;
  case 6 % energy 1
    hen( handles.s, 0, 0, hview1, hview2 );
  case 7 % energy 2
    if isfield( handles, 's2' ),
      hen( handles.s2, 0, 0, hview1, hview2 );
    else,
      NoData( hview1, hview2 );
    end;
  case 8 % energy table 1
    hen( handles.s, 0, 1, hview1, hview2 );
  case 9 % energy table 2
    if isfield( handles, 's2' ),
      hen( handles.s2, 0, 1, hview1, hview2 );
    else,
      NoData( hview1, hview2 );
    end;
  case 10 % energy L
    hen( handles.s, 0, 0, hview1, [] );
    if isfield( handles, 's2' ),
      hen( handles.s2, 0, 0, hview2, [] );
    else,
      NoData( hview2 );
    end;
  case 11 % energy R
    hen( handles.s, 0, 0, [], hview1 );
    if isfield( handles, 's2' ),
      hen( handles.s2, 0, 0, [], hview2 );
    else,
      NoData( hview2 );
    end;
  case 12 % all az ITDs
    axes( hview1 );
    vitd( handles.s, [], handles.el );
    axes( hview2 );
    if isfield( handles, 's2' ),
      vitd( handles.s2, [], handles.el2 );
    else,
      NoData( hview2 );
    end;
  case 13 % all el ITDs
    axes( hview1 );
    vitd( handles.s, handles.az, [] );
    axes( hview2 );
    if isfield( handles, 's2' ),
      vitd( handles.s2, handles.az2, [] );
    else,
      NoData( hview2 );
    end;
  case 14 % all ITDs
    axes( hview1 );
    vitd( handles.s );
    axes( hview2 );
    if isfield( handles, 's2' ),
      vitd( handles.s2 );
    else,
      NoData( hview2 );
    end;
  case 15 % compare az ITDs
    axes( hview1 );
    vitd( handles.s, [], handles.el );
    if isfield( handles, 's2' ),
      hold on;
      vitd( handles.s2, [], handles.el2, 0, 'r.-' );
      hold off;
    end;
    axes( hview2 );
    NoData( hview2 );
  case 16 % compare el ITDs
    axes( hview1 );
    vitd( handles.s, handles.az, [] );
    if isfield( handles, 's2' ),
      hold on;
      vitd( handles.s2, handles.az2, [], 0, 'r.-' );
      hold off;
    end;
    axes( hview2 );
    NoData( hview2 );
  case 17 % compare ITDs
    axes( hview1 );
    vitd( handles.s );
    if isfield( handles, 's2' ),
      hold on;
      vitd( handles.s2, [], [], 0, 'r.-' );
      hold off;
    end;
    axes( hview2 );
    NoData( hview2 );
end;

% all az's or el's display
if disp >= 2 & disp <= 5,
  axes( hview1 );
  vall( handles.s, az, el, tf, tflog, edisp, ...
        handles.winoff, handles.winlen );
  axes( hview2 );
  if isfield( handles, 's2' ),
    vall( handles.s2, az2, el2, tf, tflog, edisp, ...
          handles.winoff2, handles.winlen );
  else;
    plot( [-1 1], [0 0] );
    text( -0.1, 0.1, 'no data' );
  end;
end;


%------------------------------------------------------------------------------
function VirDisplay( handles, hview1, hview2 )

% vir() args:
% vir( h, tf, tflog, raw, az, el, lr, ls, rs, pls, prs, nrm )

% update IR display
axes( hview1 );
vir( handles.s, 0, 0, handles.az, handles.el, ...
     handles.edisp, 'b', 'r', 0, handles.winoff, handles.winlen );

if isfield( handles, 's2' ),
  hold on;
  vir( handles.s2, 0, 0, handles.az2, handles.el2, ...
       handles.edisp, 'k:', 'g:', 0, handles.winoff2, handles.winlen );
  grid on;
  if handles.edisp == 2,
    legend('HRTF 1 L','HRTF 1 R','HRTF 2 L','HRTF 2 R',4);
  else,
    if handles.edisp == 0,
      legend('HRTF 1 L','HRTF 2 L',4);
    else,
      legend('HRTF 1 R','HRTF 2 R',4);
    end;
  end;
  hold off;
end;

% update mag display
axes( hview2 );
vir( handles.s, 1, handles.logfreq, handles.az, handles.el, ...
     handles.edisp, 'b', 'r', 0, handles.winoff, handles.winlen );

if isfield( handles, 's2' ),
  hold on;
  vir( handles.s2, 1, handles.logfreq, handles.az2, handles.el2, ...
       handles.edisp, 'k:', 'g:', 0, handles.winoff2, handles.winlen );
  grid on;
  if handles.edisp == 2,
    legend('HRTF 1 L','HRTF 1 R','HRTF 2 L','HRTF 2 R',4);
  else,
    if handles.edisp == 0,
      legend('HRTF 1 L','HRTF 2 L',4);
    else,
      legend('HRTF 1 R','HRTF 2 R',4);
    end;
  end;
  hold off;
end;


%------------------------------------------------------------------------------
% NoData() - 'no data' message to left or right plot

function NoData( ha1, ha2 )

axes( ha1 );
plot( [-1 1], [0 0] );
text( -0.1, 0.1, 'no data' );

if nargin == 2,
  axes( ha2 );
  plot( [-1 1], [0 0] );
  text( -0.1, 0.1, 'no data' );
end;


%------------------------------------------------------------------------------
%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.
% -----------------------------------------------------------------------------


% --------------------------------------------------------------------
function varargout = haz_Callback(h, eventdata, handles, varargin)

% get new az value from slider (can be off by a few degrees due to scaling)
az = get( handles.haz, 'Value' );
% find nearest az to slider value
azr = round(az/handles.s.azinc) * handles.s.azinc;

% if using neargrid (for non-fixed inc grids), find actual az,el
if isfield( handles, 'neargrid' ),
  % find nearest el to el slider value
  el = get( handles.hel, 'Value' );
  elr = round(el/handles.s.elinc) * handles.s.elinc;
  % mapping from fixed-inc grid to non-fixed-inc grid
  naz = (180-azr)/handles.s.azinc + 1;
  nel = ( 90-elr)/handles.s.elinc + 1;
  index = handles.neargrid( naz, nel, 1 );
  handles.az = handles.s.dgrid(2,index);
  handles.el = handles.s.dgrid(1,index);
  % true-to-neargrid distance (cm's assuming 1m radius sphere)
  set( handles.htdist, 'String', ...
       sprintf( '%5.2f', handles.neargrid( naz, nel, 2 )*100.0 ) );
  % update grid slider
  set( handles.hgrid, 'Value', index );
  set( handles.htgrid, 'String', sprintf( '( %6.1f, %5.1f )', ...
       handles.az, handles.el ) );
else,
  handles.az = azr;
end

guidata(gcbo,handles); % store the changes

UpdateDisplay( handles, handles.hir, handles.hmag );

% display slider value
set( handles.htaz, 'String', sprintf( '%-4.0f', azr ) );

if handles.follow1,
  set( handles.haz2, 'Value', azr );
  haz2_Callback( h, eventdata, handles, varargin );
end;


% --------------------------------------------------------------------
function varargout = hel_Callback(h, eventdata, handles, varargin)

% get new el value from slider (can be off by a few degrees due to scaling)
el = get( handles.hel, 'Value' );
% find nearest el to slider value
elr = round(el/handles.s.elinc) * handles.s.elinc;

% if using neargrid (for non-fixed inc grids), find actual az,el
if isfield( handles, 'neargrid' ),
  % find nearest az to az slider value
  az = get( handles.haz, 'Value' );
  azr = round(az/handles.s.azinc) * handles.s.azinc;
  % mapping from fixed-inc grid to non-fixed-inc grid
  naz = (180-azr)/handles.s.azinc + 1;
  nel = ( 90-elr)/handles.s.elinc + 1;
  index = handles.neargrid( naz, nel, 1 );
  handles.az = handles.s.dgrid(2,index);
  handles.el = handles.s.dgrid(1,index);
  % true-to-neargrid distance (cm's assuming 1m radius sphere)
  set( handles.htdist, 'String', ...
       sprintf( '%5.2f', handles.neargrid( naz, nel, 2 )*100.0 ) );
  % update grid slider
  set( handles.hgrid, 'Value', index );
  set( handles.htgrid, 'String', sprintf( '( %6.1f, %5.1f )', ...
       handles.az, handles.el ) );
else,
  handles.el = elr;
end

guidata(gcbo,handles); % store the changes

UpdateDisplay( handles, handles.hir, handles.hmag );

% display slider value
set( handles.htel, 'String', sprintf( '%-3.0f', elr ) );

if handles.follow1,
  set( handles.hel2, 'Value', elr );
  hel2_Callback( h, eventdata, handles, varargin );
end;


% --------------------------------------------------------------------
function varargout = hgrid_Callback(h, eventdata, handles, varargin)

% get new grid value from slider (can be off by a few degrees due to scaling)
gindex = round( get( handles.hgrid, 'Value' ) );

% az and el from grid index
handles.az = handles.s.dgrid( 2, gindex );
handles.el = handles.s.dgrid( 1, gindex );

guidata(gcbo,handles); % store the changes

UpdateDisplay( handles, handles.hir, handles.hmag );

% display slider value
set( handles.htgrid, 'String', sprintf( '( %6.1f, %5.1f )', ...
     handles.az, handles.el ) );

if handles.follow1,
  set( handles.hgrid2, 'Value', gindex );
  hgrid2_Callback( h, eventdata, handles, varargin );
end;


% --------------------------------------------------------------------
function varargout = haz2_Callback(h, eventdata, handles, varargin)

% get new az value from slider (can be off by a few degrees due to scaling)
az = get( handles.haz2, 'Value' );
% find nearest az to slider value
handles.az2 = round(az/handles.s2.azinc) * handles.s2.azinc;

guidata(gcbo,handles); % store the changes

UpdateDisplay( handles, handles.hir, handles.hmag );

% display slider value
set( handles.htaz2, 'String', sprintf( '%-4.0f', handles.az2 ) );


% --------------------------------------------------------------------
function varargout = hel2_Callback(h, eventdata, handles, varargin)

% get new el value from slider (can be off by a few degrees due to scaling)
el = get( handles.hel2, 'Value' );
% find nearest el to slider value
handles.el2 = round(el/handles.s2.elinc) * handles.s2.elinc;

guidata(gcbo,handles); % store the changes

UpdateDisplay( handles, handles.hir, handles.hmag );

% display slider value
set( handles.htel2, 'String', sprintf( '%-3.0f', handles.el2 ) );


% --------------------------------------------------------------------
function varargout = hgrid2_Callback(h, eventdata, handles, varargin)

% get new grid value from slider (can be off by a few degrees due to scaling)
gindex = round( get( handles.hgrid2, 'Value' ) );

% az and el from grid index
handles.az2 = handles.s2.dgrid( 2, gindex );
handles.el2 = handles.s2.dgrid( 1, gindex );

guidata(gcbo,handles); % store the changes

UpdateDisplay( handles, handles.hir, handles.hmag );

% display slider value
set( handles.htgrid2, 'String', sprintf( '( %6.1f, %5.1f )', ...
     handles.az2, handles.el2 ) );


% --------------------------------------------------------------------
function varargout = hlogfreq_Callback(h, eventdata, handles, varargin)

handles.logfreq = get( handles.hlogfreq, 'Value' );
guidata(gcbo,handles); % store the changes
UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hleft_Callback(h, eventdata, handles, varargin)

% display left ear flag
handles.edisp = 0;
guidata(gcbo,handles); % store the changes
UpdateEar( handles );
UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hright_Callback(h, eventdata, handles, varargin)

% display right ear flag
handles.edisp = 1;
guidata(gcbo,handles); % store the changes
UpdateEar( handles );
UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hboth_Callback(h, eventdata, handles, varargin)

% display both ears flag
handles.edisp = 2;
guidata(gcbo,handles); % store the changes
UpdateEar( handles );
UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hwinlen_Callback(h, eventdata, handles, varargin)

handles.winlen = get( handles.hwinlen, 'Value' ) * 32;
guidata(gcbo,handles); % store the changes
UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hwinoff_Callback(h, eventdata, handles, varargin)

handles.winoff = round( get( handles.hwinoff, 'Value' ) );
set( handles.htwinoff, 'String', sprintf( '%d', handles.winoff ) );
guidata(gcbo,handles); % store the changes
UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hwinoff2_Callback(h, eventdata, handles, varargin)

handles.winoff2 = round( get( handles.hwinoff2, 'Value' ) );
set( handles.htwinoff2, 'String', sprintf( '%d', handles.winoff2 ) );
guidata(gcbo,handles); % store the changes
UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hnear_Callback(h, eventdata, handles, varargin)

nearaz = str2num( get( handles.hnearaz, 'String' ) );
nearel = str2num( get( handles.hnearel, 'String' ) );

% since 5,5 and 10,10 grids take a while to compute, use saved versions
if nearaz == 5 & nearel == 5,
  load grid55;
  handles.neargrid = ngrid;
elseif nearaz == 10 & nearel == 10,
  load grid1010;
  handles.neargrid = ngrid;
else,
  handles.neargrid = neargrid( nearaz, nearel, handles.s.dgrid );
  % to create .mat files used above:
  %ngrid = handles.neargrid;
  %save('grid1010.mat','ngrid');
end;

% measured az's ordered from max to min
handles.azMax = 180;
handles.azMin = -180 + nearaz;

% measured el's ordered from max to min
handles.elMax = 90;
handles.elMin = -90;

% slider steps
handles.azstep = 1/((handles.azMax-handles.azMin)/nearaz + 1);
handles.elstep = 1/((handles.elMax-handles.elMin)/nearel + 1);

handles.s.azinc = nearaz;
handles.s.elinc = nearel;

% enable sliders
set( handles.haz, 'Enable', 'on' );
set( handles.hel, 'Enable', 'on' );

% azimuth slider
set( handles.haz, 'Min', handles.azMin, 'Max', handles.azMax, ...
     'Value', 0, 'SliderStep', [ handles.azstep handles.azstep ] );
% elevation slider
set( handles.hel, 'Min', handles.elMin, 'Max', handles.elMax, ...
     'Value', 0, 'SliderStep', [ handles.elstep handles.elstep ] );

guidata(gcbo,handles); % store the changes


% --------------------------------------------------------------------
function varargout = hnearaz_Callback(h, eventdata, handles, varargin)
% needs to be here but doesn't need to do anything

% --------------------------------------------------------------------
function varargout = hnearel_Callback(h, eventdata, handles, varargin)
% needs to be here but doesn't need to do anything


% --------------------------------------------------------------------
function varargout = hfollow1_Callback(h, eventdata, handles, varargin)

% hrtf2 sliders follow hrtf1 sliders flag
handles.follow1 = get( handles.hfollow1, 'Value' );
guidata(gcbo,handles); % store the changes


% --------------------------------------------------------------------
function varargout = hazelview_Callback(h, eventdata, handles, varargin)

UpdateDisplay( handles, handles.hir, handles.hmag );


% --------------------------------------------------------------------
function varargout = hfigwin_Callback(h, eventdata, handles, varargin)

figure;
hv1 = subplot(1,2,1);
hv2 = subplot(1,2,2);
UpdateDisplay( handles, hv1, hv2 );
