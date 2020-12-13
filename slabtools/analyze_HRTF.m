function analyze_HRTF

% addpath('N:\Experiments\Commoncode\Alf Control\AudioServer Functions');
addpath('C:\Users\Lab\Desktop\slabtools');

sFilename = 'N:\SLAB\HRTF\EnhancedHRTF.slh';

[ir,itd,map,version,name,strDate,comment,azInc,elInc,numPts,fs] ...
= slab2mat( sFilename )


sFilename = 'C:\Users\Lab\Documents\BitBucket\AAVS_APR12\AAVS\Assets\StreamingAssets\HRTF\AFRLGoldenEars_SnowSH6E150.slh';
[ir,itd,map,version,name,strDate,comment,azInc,elInc,numPts,fs] ...
= slab2mat( sFilename );

%slab2sarc(sFilename,'test')

sFilename = 'C:\Users\Lab\Documents\BitBucket\AAVS_APR12\AAVS\Assets\StreamingAssets\HRTF\SnowmanDSB2.slh'; 
[ir2,itd2,map2,version2,name2,strDate2,comment2,azInc2,elInc2,numPts2,fs2] ...
= slab2mat( sFilename );

size(ir)
size(ir2)

sFilename = 'C:\Users\Lab\Documents\BitBucket\AAVS_APR12\AAVS\Assets\StreamingAssets\HRTF\TrevorFromNavy_HD280.slh'; 
[ir2,itd2,map2,version2,name2,strDate2,comment2,azInc2,elInc2,numPts2,fs2] ...
= slab2mat( sFilename );

