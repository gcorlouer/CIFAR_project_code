%% Spectral analysis, plot cpsd of time series
%% Preprocessed
tsdata=double(EEG.data); 
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
filt_order=2;
dsample=1;
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order); %filter and downsample
%% Select chans
pick_ROI=1:1:23;
pick_ROI=pick_ROI';
pick_chan=[];
tsdata_ROI=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx);
%% Slide window 
window_size=100000;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
tsdata_slided=tsdata2slided(tsdata_ROI, window_size,num_chan,tsdata_length);
%% Compute cpsd (autospec=True mean we compute the autospectral density)
[cpsd_filt,f,fres] = tsdata_to_cpsd(ts_madout,[],fs,[],[],fres,'True',[]); 
%% Plot cpsd
%filtered cpsd
figure; 
loglog(f,cpsd_filt)
xlabel('Frequency')
ylabel('Spectral density')
title([num2str(fc) ' Hz High pass filtered power spectral density function, downsampled by ' num2str(dsample) ', AnRa, resting raw data, 2s window'])
