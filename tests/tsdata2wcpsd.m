%% Wavalet cross power specral and coherence
%% Parameters
%wavelet: wavelet type, 'Morse' (default) | 'amor' | 'bump'
%fs : sampling rate
%
%% TODO
%Try limited time and frequency window becaus of memory problem
%% 
function [wcoh,wcpsd,freq] = tsdata2wcpsd(tsdata,fs,wavelet)
[tsdim, nobs,ntrials] = size(tsdata);
[bi_wcoh,bi_wcs,freq] = wcoherence(tsdata(1,:),tsdata(2,:),fs); %get the number of frequencies
%Create filter bank to change wavelet
fb=cwtfilterbank('SignalLength',nobs,'Wavelet',wavelet,'SamplingFrequency',fs);
[wts_fb,freq]=wt(fb,tsdata(1,:)); %get number of frequencies

wcoh = zeros(tsdim,tsdim,size(freq,1),nobs);
wcpsd = zeros(tsdim,tsdim,size(freq,1),nobs);
wts_fb=zeros(tsdim,size(freq,1),nobs);

%wavelet transform time series
for i=1:tsdim
    [wts_fb(i,:,:),freq]=wt(fb,tsdata(i,:));
end

%Wavelet cross spectrum
for i=1:tsdim
     for j=1:tsdim
wcpsd(i,j,:,:)=wts_fb(i,:,:).*conj(wts_fb(j,:,:));
     end 
end

% Wavelet 
% 
% for i=1:tsdim
%     for j=1:tsdim
%         [wcoh(i,j,:,:), wcpsd(i,j,:,:)]=wcoherence(tsdata(i,:),tsdata(j,:));
%     end
% end