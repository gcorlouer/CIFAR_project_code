% Processing pipeline for one subject
%  If want to select figure then do figsave = true;
%TODO: more flexible channel selection
%% Select subject
BP = false;
subject = 'AnRa';
%% Select dataset
%Use ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1' for
ppdir='preproc_ptrem_o8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1';
dataset='freerecall_rest_baseline_1_preprocessed';
[filepath,filename] = CIFAR_filename(BP,subject,dataset);
load(strcat(filepath,filesep,filename)); %load metadata containing SUMA mapping
%% Select channels
schans=-6; %negative number is ROI, positive is channel
badchans=0;
[chans,chanstr,channames,ogchans] = select_channels(BP,subject,dataset,schans,badchans,[]) 
%goodchans = get_goodchans(BP,subject,dataset,badchans); 
%% Inspect time series
tseg = [23 33]; % select time segment from 23 to 27 seconds
inspect_time_series; %visual
%% Get time series
[tsdata,ts,filepath,filename] = get_EEG_tsdata(BP,subject,dataset,ppdir,0);