%% Parameters initialisation 
%% Preprocessed
tsdata=double(EEG.data); 
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
filt_order=2;
dsample=1;
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order); %filter and downsample
%% Select chans
pick_ROI=1:1:22;
pick_ROI=pick_ROI';
pick_chan=[];
[tsdata_ROI,pick_chan]=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx);
%% Slide window 
window_size=1000;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
tsdata_slided=tsdata2slided(tsdata_ROI, window_size,num_chan,tsdata_length);
%% Count outliers
sdfac=3; 
madfac=6;
repmean='True';
repmed='True';
ts_picked=tsdata_slided(:,:,1);
[ts_madout,outs]=routl_m(ts_picked,madfac,repmed);
[ts_out,nouts] = routl(ts_picked,sdfac,repmean);
%% Select window
figure
plot_tsdata(ts_madout,[],[],[]);