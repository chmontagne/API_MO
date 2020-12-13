% vcsym - verify HRTF database collection spectra.
%
% vcsym calls vsym1() for all SLHs found in the current directory.
%
% See also: vsym, cipic2slab, listen2slab, sarc

% modification history
% --------------------
%                ----  v6.6.0  ----
% 02.09.11  JDM  created
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

d = dir('*.slh');
%d = dir('subject_*.slh');  % verify cipic
%d = dir('IRC_*.slh');  % verify Listen
% original suspects, last 3, energy outliers
%d(1).name = 'IRC_1016.slh';  % 13, hot high freqs left EL45, band EL60
%d(2).name = 'IRC_1025.slh';  % 20, lower freq band right EL15
%d(3).name = 'IRC_1031.slh';  % 25, low high freqs in EL45,30
%d(4).name = 'IRC_1034.slh';  % 28, numerous low energy locations
%d(5).name = 'IRC_1051.slh';  % 43, low high freqs in EL60

for hk = 1:length(d),
  h = slab2sarc( d(hk).name );
  disp( d(hk).name );

  % view all az mags per el simultaneously
  % (can use vsym1() or vsym())
  for k=90:-h.elinc:-90,
    vsym1(h,[],k,0);  % 4th param 1 for log freq
    %vsyms(h,k);  % see vsyms() comment below
    pause;
  end;

  % being one needs to use the figure "Rotate 3D" tool for checking
  % symmetry, this is actually more useful as a directional frequency
  % response visualization
  %vsyms(h); pause;

  % all az mags for el 0 simultaneously
  %vsym1(h,[],0);
  %pause(0.1);  % as animation

  % all el mags per az simultaneously
  %for k=-180:h.azinc:180, vsym1(h,k,[]); pause; end;

  % can also compare:
  if 0,  % for cut'n'pasting to command window
    % \CIPIC_hrtf_database\standard_hrir_database\show_data\hor_show_data
    % to
    h = slab2sarc('subject_003.slh');  % match hor_show_data subject
    vsym(h,[],0,1);  % all azs
    % or
    % \CIPIC_hrtf_database\standard_hrir_database\show_data\show_data
    % to
    h = slab2sarc('subject_003.slh');  % match show_data subject
    vsym(h,0,[],1);           % all els (compare to cipic -45 to 90)
    figure;
    vsym(h,180,[],1);         % all els (compare to cipic 90 to 231)
    subplot(1,2,1); axis ij;  % flip up/down
    subplot(1,2,2); axis ij;  % flip up/down

    % Snapshot-measured slab3d default
    hj = slab2sarc('\slab3d\hrtf\jdm.slh');
    for k=90:-18:-90,vsym(hj,[],k);pause;end;   % all azs
    for k=-180:30:180,vsym(hj,k,[]);pause;end;  % all els
  end;

end;
