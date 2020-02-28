%% Wavelet transform of time series
%Problem: cannot plot the scalogram of wavelet with cwt
%TODO: Improve scalogram cf here
%https://uk.mathworks.com/help/wavelet/ref/cwtfilterbank.wt.html for a
%begining 
%Heatmap of n dimensional time series
%Cross power spectral wavlet
%Hilbert transform for multiple tim series

%% input data
tsdim=4;
connect=cmatrix(tsdim);
specrad=0.98;
morder=5;
nobs=50000;
tsdata=var_sim(connect, morder, specrad, nobs);
iir=1;
[fs,fcut_low,fcut_high,filt_order, fir]=deal(500,60,110,128,0);
fs=500;
%% CWT
[wts,f]=cwt(tsdata(1,:),fs,'amor','FrequencyLimits',[fcut_low fcut_high]);
wts=zeros(tsdim,size(f,1),nobs);
for i=1:tsdim
    wts(i,:,:)=cwt(tsdata(i,:),fs,'amor','FrequencyLimits',[fcut_low fcut_high]);
end
%% Filter data 
tsdata_filtered=tsdata2ts_filtered(tsdata,fs,fcut_low,fcut_high,filt_order, iir);
%tsdata_filtered=real(wts);
%% Envelope wavelet
s=1;
wvt_envelope=abs(wts_fb(1,s,:));
% Plot envelope
chanum=1; %select channel to plot
samlping_window=5000:7000;
trange = samlping_window;
plot_envelope(tsdata_filtered,wvt_envelope,trange, chanum, fs);
%% Filter bank for Morse wavelet
band=[fcut_low fcut_high];
fb=cwtfilterbank('SignalLength',nobs,'Wavelet','Morse','SamplingFrequency',fs,'WaveletParameters',[3 60]);
[wts_fb,f]=wt(fb,tsdata(1,:));
wts_fb=zeros(tsdim,size(f,1),nobs);
%freqs=zeros(tsdim,size(f,1));
%coi=zeros(tsdim,size(f,1));
for i=1:tsdim
    [wts_fb(i,:,:),freqs,coi]=wt(fb,tsdata(i,:));
end
%% Plot scalogram
wtime=1000:2000;
pcolor(wtime,f,abs(squeeze(wts_fb(1,:,wtime))))
shading flat
set(gca,'YScale','log')
hold on
plot(time,coi,'w-','LineWidth',3)
xlabel('Time (Samples)')
ylabel('Normalized Frequency (cycles/sample)')
title('Scalogram')
%% Cross wavelet spectrum

