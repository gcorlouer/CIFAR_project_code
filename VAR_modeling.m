%% Parameters initialisation 
tsdata=double(EEG.data); %double precision
momax=25;
moregmode='LWR';
regmode   = 'LWR';
window_size=10000; % to change in sec units do window_size*downsample/fs 
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
filter_order=2;%Filter order : unclear what to chose here 
dsample=1;
T=size(tsdata_pp,2);
num_window=floor(T/L-1);
path2plot='/its/home/gc349/CIFAR_guillaume/plots/AnRa/VAR_modeling';%save plots here
%% Preprocess and select ROIs
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order);
[cpsd_filt,f,fres] = tsdata_to_cpsd(tsdata_pp,[],fs,[],[],fres,'True',[]); %Filtered
figure(1); 
loglog(f,cpsd_filt)
xlabel('Frequency')
ylabel('Spectral density')
title([num2str(fc) ' Hz High pass filtered power spectral density function, downsampled by ' num2str(dsample) ', all chans, AnRa, resting raw data'])