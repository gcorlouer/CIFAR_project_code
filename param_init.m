%% Parameters initialisation
tsdata=double(EEG.data); %double precision
momax=25;
moregmode='LWR';
regmode   = 'LWR';
window_size=10000;
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
order=2;%Filter order : unclear what to chose here 
ds=1;