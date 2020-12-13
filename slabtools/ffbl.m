function [ out, win ] = ffbl( in, fs, fLOW, fHI )
% ffbl - band-limits free-field eq.
%
% This function creates and applies a trapazoidal window to the input
% frequency domain data.

% modification history
% --------------------
%                ----  v5.6.0  ----
% 11.17.04  JDM  created (original algorithm by Agnieszka Roginska);
%                new bin_fLOW, bin_fHI calcs; moved analysis code to ffbltest
%                ----  v5.8.0  ----
% 09.28.05  JDM  added to SUR
%                ----  v6.0.0  ----
% 10.03.06  JDM  added pre-trap win normalization
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

fftlen = size(in,1);

% bin number for fHI Hz and fLOW Hz
bin_fLOW = floor( fLOW / (fs/fftlen) ) + 1;
bin_fHI  = ceil(  fHI  / (fs/fftlen) ) + 1;

% old calc - see ffbl2.m - slightly different than above
%bin_fLOW = ceil(fLOW/((fs/2)/(fftlen/2+1)));
%bin_fHI  = ceil(fHI /((fs/2)/(fftlen/2+1)));

% normalize freq range of interest (important if free-field data recorded
% at a low level - if this isn't done, a bandpass can result)
% (JDM, 10/3/06, current ffbltest() assumes no normalization, keep as is
% until all ff code can be updated and tested)
%in_mean = mean( abs(in(bin_fLOW:bin_fHI)) );
in_mean = 1;

% dB scale
in = 20*log10(abs(in)/in_mean);

% construct band-limiting window (must be applied to dB scale freq resp)
win = ones(fftlen/2+1,1);
fadeLength = 30;	% length of fade bins
win(1) = 0; % don't compensate for DC
win(2:bin_fLOW) = linspace(0, 1, bin_fLOW-1);
win(bin_fHI:min(bin_fHI+fadeLength-1,length(win))) = ...
  linspace(1, 0, min(length(win(bin_fHI:length(win))),fadeLength));
win(min(bin_fHI+fadeLength,length(win)):length(win)) = 0;
win = [win;flipud(win(2:length(win)-1))];

% apply window
out = in.*win;

% back to linear scale
out = 10.^(out.*0.05);
