% vcfreq - verify HRTF database collection HRIR magnitude responses.
%
% vcfreq is a simple ring-of-responses-at-once visualization script.
%
% See also: vcir

% modification history
% --------------------
%                ----  v6.6.1  ----
% 04.27.12  JDM  created
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
for k = 1:length(d),
  h = slab2sarc( d(k).name );

  % For the Listen data, the vcen-vcenf metrics differed by more than 1dB
  % for the first 12 databases.  This seems to indicate something changed
  % in regards to DC bias or high-freq (>20k) response for the first 12
  % versus the rest.
  %
  % !!!! It looks like the responses are pinched in the high freqs to
  % -10dB for the first 12 Listen databases!  Perceptible?
  %
  % Using vcir.m, one can see an oscillation in the IRs for the first
  % 12 Listen databases.  Note, sometimes a tail is large due to a low
  % initial impulse and 1.0-normalization, but in this instance there is
  % also the behavior noted above.
  %
  % To see, view all left-ear el 0 *linear* responses (effect much
  % easier to see on a linear freq axis).

  for el=max(h.dgrid(1,:)):-h.elinc:min(h.dgrid(1,:)),
    figure(gcf);
    clf;
    hold on;
    for az=max(h.dgrid(2,:)):-h.azinc:min(h.dgrid(2,:)),
      [ax1,ax2] = plotresp( h.ir(:,hil(az,el,h.dgrid)), 1024, h.fs, 'b-', ...
                            0, h.fs/2, -60, 10, 0 );
      [ax1,ax2] = plotresp( h.ir(:,hir(az,el,h.dgrid)), 1024, h.fs, 'r-', ...
                            0, h.fs/2, -60, 10, 0 );
    end;
    % prevent tex underscore-to-subscript
    title( ax1, sprintf('Frequency Response - %s (%d) el %.0f', d(k).name, ...
           k, el), 'Interpreter', 'none' );
    pause;
  end;

  %pause;
end;
