%% Parameters initialisation for mvgc
tsdata=double(EEG.data); %double precision
momax=25;
moregmode='LWR';
regmode   = 'LWR';
window_size=1000;
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
filter_order=2;%Filter order : unclear what to chose here 
dsample=1;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
pick_ROI=1:1:22;
pick_ROI=pick_ROI';
pick_chan=[];