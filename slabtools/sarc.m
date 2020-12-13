% sarc - slab3d archive help.
%
% The slabtools slab3d archive (sarc) format is used to archive, view, analyze,
% and manipulate HRTF data.
%
% A slab3d archive file is a MATLAB MAT-format binary file containing one slab3d
% archive struct variable 'h'.
%
% A slab3d archive struct contains the following fields:
%
% name    - subject name
% date    - sarc creation date
% source  - source of data (e.g., 'snapshot', 'headzap', 'slabslh', 'cipic',
%           'custom' )
% comment - comment string
% ir      - HRIR data, all left ear data followed by all right ear data
% itd     - ITD data, #samples left lags right
% dgrid   - data grid (az,el order, elevations grouped by azimuth)
% finc    - dgrid fixed increment flag
% azinc   - fixed-inc az increment
% elinc   - fixed-inc el increment
% fs      - sample rate
% mp      - HRIR minimum-phase flag
% tgrid   - measurement grid read by head-tracker
% eqfs    - EQ sampling rate
% eqm     - mixed EQ (e.g., Snapshot eq)
% eqf     - free-field EQ
% fgrid   - free-field EQ grid (elevations grouped by azimuth)
% eqd     - diffuse-field EQ (all L then all R)
% eqb     - bass-boost EQ
% eqh     - headphone EQ (invL,invR,m1L,m1R,m2L,m2R,m3L,m3R)
% hcom    - headphone comment describing model, type, and coupling
%
% Depending on the archive, some fields may be empty.
%
% The following functions are used to manage slab3d archives:
%
% sl          sarc list
% sload       sarc load
% ssave       sarc save
% smake       sarc creation
% sinfo       sarc info
% sminp       sarc IRs to minimum phase
% slab2sarc   create slab3d archive from slab3d HRTF database (.slh)
% snap2sarc   create slab3d archive from CRE Snapshot archive
% zap2sarc    create slab3d archive from 2015-era AuSIM HeadZap archive
% zap2sarc1   create slab3d archive from 2006-era AuSIM HeadZap archive
% ahm2sarc    create slab3d archive from 2015-era AuSIM AHM file
% ahm2sarc1   create slab3d archive from 2006-era AuSIM AHM file
% cipic2sarc  create slab3d archive from CIPIC database
% cam2sarc    create slab3d archive from IRCAM database
% snow2sarc   create slab3d archive from CIPIC Snowman model
%             (requires CIPIC's Snowman model scripts)
%
% The following functions use slab3d archives (or members):
%
% hlab        HRTF Lab interactive MATLAB application
% plotresp    plot mag and phase response
% vir         HRIR and HRTF viewing utility
% vitd        ITD viewing utility
% vall        view all el's for az or all az's for el (IRs,mags)
% vsym        like vall but simultaneous left and right ear display (mags)
% vsym1       like vsym but magnitudes in one image emphasizing symmetry
% vsyms       view directional frequency response symmetry
% hcom        HRTF database comparison and quality measurement utility
% hen         displays table and graph of HRIR energies
% henfilt     similar to hen() but performs white noise filter
%
% For more information, type 'help <toolname>' or 'help slabtools'.

% modification history
% --------------------
% 11.08.02  JDM  created
%                ----  v5.3.0  ----
% 08.15.03  JDM  updated help comments
% 08.20.03  JDM  added fgrid comment
% 09.15.03  JDM  added hcom and hpower comments
%                ----  v5.4.0  ----
% 10.24.03  JDM  added azInc,elInc comments
% 10.29.03  JDM  added pfinc, etc.; removed azInc,elInc comments (in smake)
% 11.19.03  JDM  added hlab comment
% 11.21.03  JDM  version 3-to-4 sarc format overhaul; added vall()
% 11.24.03  JDM  hpower() to henfilt(); added hen()
%                ----  v6.6.0  ----
% 02.25.11  JDM  added vsym
%                ----  v6.7.5  ----
% 05.06.15  JDM  updated
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

% parameters inferred from sarc variables:
%
% #pts processed HRIR: size( h.pir, 1 )
% existence flags: data that doesn't exist is set to [], use isempty
