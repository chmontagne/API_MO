function img = dustimg()
% dustimg - generates a low-vis dust storm image
%
% dustimg() uses a Brownian noise algorithm (mp_fm2d()) to generate
% semitransparent images for slabx's low-vis model.
%
% mp_fm2d() was written by Pavel Yatvetsky based on an algorithm from
% "The Science of Fractal Images", pg.100.
% http://technion.ac.il/~pavel/comphy/code.htm

% modification history
% --------------------
%                ----  v6.6.0  ----
% 05.11.11  JDM  created for the slabx low-vis model
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

% example range for mp_fm2d(10,1,0.4,true);
%
%[ min(min(x1)) max(max(x1)) ]
%    -3.0875    2.6715
%    -2.4150    3.7884

% fBm = mp_fm2d( maxLevel, sigma, H, Addition )
% higher H: less discrete, less distributed, more blurred
x1 = mp_fm2d(10,1,0.4,true);

% x1 is a square matrix size 2^maxLevel+1
dim = size(x1,1) - 1;
x = x1(1:dim,1:dim);

x = x - min(min(x));  % make x >= 0
x = x / max(max(x));  % normalize to 1.0

% XNA Color.SaddleBrown
rgb = [139,69,19] / 255;

img = zeros( [ size(x) 3 ] );
img(:,:,1) = rgb(1) * x;
img(:,:,2) = rgb(2) * x;
img(:,:,3) = rgb(3) * x;
if 0,
  image( img );
  figure(gcf);
end;

% http://msdn.microsoft.com/en-us/library/bb447762(v=XNAGameStudio.31).aspx
%
% XNA TextureContent - The following types are supported: .bmp, .dds, .dib,
% .hdr, .jpg, .pfm, .png, .ppm, and .tga.

% PNG supports alpha
if 0,
imwrite( x, 'dust05.png', 'png', 'Alpha', x );
end;
