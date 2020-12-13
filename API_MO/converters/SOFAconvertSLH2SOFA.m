function SOFAconvertSLH2SOFA(input_slh,output_sofa)
%% This script converts .slh HRTF files to the .sofa format 
% Chris Montagne Oct. 2019

% input_slh: string, name of input .slh file
% output_sofa: string, name of output .sofa file

% This script requires adding the path to the following Matlab toolboxes:
    % (1) The slabtools Matlab scripts(v6.8.3)
    %    http://slab3d.sourceforge.net/downloads.html
    % (2) The SOFA HRTF Matlab API 
    %    https://github.com/sofacoustics/API_MO

%% Load SLH file 
addpath('slabtools');
addpath(genpath('API_MO'));

[ir,itd,map,version,name,strDate,comment,azInc,elInc,numPts,fs] ...
  = slab2mat( input_slh );


%% Load SOFA file
%load a standard .sofa file to use its framework
temp_SOFA_path = 'API_MO\HRTFs\SOFA\sofa_api_mo_test\MIT_KEMAR_normal_pinna.sofa'; % .sofa from SOFA API 

% Start SOFA
SOFAstart;
% Load your impulse response into a struct
hrtf_orig = SOFAload(temp_SOFA_path);
hrtf_new = hrtf_orig;


%% Convert .slh IR data to .sofa format
ir_SOFA = [];
ir_SOFA(1:size(ir,2)/2,1,1:size(ir,1)) = ir(:,1:length(ir)/2)'; %left ear
ir_SOFA(1:size(ir,2)/2,2,1:size(ir,1)) = ir(:,(length(ir)/2)+1:end)'; %right ear
afrl_dist = 2.1; % ~2.1m radius of AFRL's 277 loudspeaker array
new_map = [map(2,:)',map(1,:)',afrl_dist*ones(length(map),1)]; %[azi,eli,dist]

%Remap Azimuth for .sofa SourcePosition map
azi_slh = new_map(:,1);
for i = 1:length(azi_slh)
    if azi_slh(i) <= 0  
        azi_slh(i) = abs(azi_slh(i));
    else
        azi_slh(i) = 360-azi_slh(i);
    end
end
new_map(:,1) = azi_slh;

%Reassign new SOFA IRs
hrtf_new.Data.IR = ir_SOFA;

% ITD FIX
%A positive ITD (in samples) implies a left ear lag (source in right hemisphere, positive azimuths) and a negative
%ITD implies a right ear lag (source in left hemisphere, negative azimuths).

delay_L = []; delay_R = [];
for i = 1:length(itd)
    if itd(i) >= 0
        delay_L(i) = itd(i);
        delay_R(i) = 0;
    else
        delay_L(i) = 0;
        delay_R(i) = abs(itd(i));
    end
end

hrtf_new.Data.Delay = [delay_L',delay_R'];
hrtf_new.Data.SamplingRate = fs;
hrtf_new.SourcePosition = new_map;
hrtf_new.API.N = numPts;
hrtf_new.API.M = length(map);
hrtf_new.GLOBAL_DateCreated = strDate;
hrtf_new.GLOBAL_DateModified = '';
hrtf_new.GLOBAL_History = 'Converted from the SLH format';
hrtf_new.GLOBAL_ListenerShortName = '';
hrtf_new.GLOBAL_DatabaseName = 'AFRL';

%% Save new .sofa file
SOFAsave(output_sofa,hrtf_new)



