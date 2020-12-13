# Slab3d to SOFA HRTF Converter (.slh to .sofa)

This fork of the SOFA MATLAB API adds slab3d (.slh) to SOFA (.sofa) HRTF format conversion. 

In addition to the SOFA MATLAB API, it uses the slabtools Matlab scripts(v6.8.3):
    http://slab3d.sourceforge.net/downloads.html

## Usage example

SOFAconvertSLH2SOFA.m is the main HRTF conversion script. 
Simply provide it the paths/filenames to the input .slh and output .sofa files you want to convert. 

An example .slh HRTF (GoldenClusterMean_SH6E100_HD280.slh) is included in the root of the folder. 
From the root of the repo, run the following MATLAB line to convert the example .slh to a .sofa file.

```matlab
SOFAconvertSLH2SOFA('GoldenClusterMean_SH6E100_HD280.slh','GoldenClusterMean_SH6E100_HD280.sofa')
```      

If successful, a newly converted .sofa HRTF file will appear in the root folder. 


(The original SOFA readme is below).

----------------------------------------------

SOFA - Spatially Oriented Format for Acoustics
==============================================

SOFA is a file format for reading, saving, and describing spatially
oriented data of acoustic systems.

Examples of data we consider are head-related transfer functions (HRTFs),
binaural room impulse responses (BRIRs), multichannel measurements such as done
with microphone arrays, or directionality data of loudspeakers.

The format specifications are the major issue, but we also aim in providing APIs
for reading and writing the data in SOFA.

For more information on the format specifications and available data have a look
at http://www.sofaconventions.org/


Downloads
=========

Current versions of SOFA can be found on its [old
home](http://sourceforge.net/projects/sofacoustics/files/?source=navbar).

At the moment we are working on a new release which will be shortly available on
this site.


Usage
=====

## Matlab/Octave API

In order to use SOFA with Matlab or Octave you have to add its `API_MO` folder
to your paths. After that you can play around with your acoustic measurements
as shown by the following example which uses a head-related transfer function
measurement.

```matlab
% Start SOFA
SOFAstart;
% Load your impulse response into a struct
hrtf = SOFAload('path/to_your/HRTF.sofa'));
% Display some information about the impulse response
SOFAinfo(hrtf);
% Plot a figure with the measurement setup
SOFAplotGeometry(hrtf);
% Have a look at the size of the data
size(hrtf.Data.IR)
% Get information about the measurement setup
hrtf.ListenerPosition       % position of dummy head
hrtf.SourcePosition         % position of loudspeaker
% Head orientation of the dummy head + coordinate system and units
hrtf.ListenerView
hrtf.ListenerView_Type
hrtf.ListenerView_Units
% Calculate the source position from a listener point of view
apparentSourceVector = SOFAcalculateAPV(hrtf);
% Listen to the HRTF with azimuth of -90°
apparentSourceVector(91, 1)
SOFAplotGeometry(hrtf, 91);
soundInput = audioread('fancy_audio_file.wav');
soundOutput = [conv(squeeze(hrtf.Data.IR(91, 1, :)), soundInput) ...
               conv(squeeze(hrtf.Data.IR(91, 2, :)), soundInput)];
sound(soundOutput, hrtf.Data.SamplingRate);
```
