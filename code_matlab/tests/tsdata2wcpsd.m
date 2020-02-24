%% Wavalet cross power specral and coherence
%% Parameters
%wavelet: wavelet type, 'Morse' (default) | 'amor' | 'bump'
%fs : sampling rate
%mwcoh : multivariate wavelet coherence
%wcpsd : multivariate wavelet cross powerd specrtum
%awcoh : autocoherence
%awcpsd : autospectra
%twindow: time window. WARNING: may run out of memory if time window is too
%long
%% TODO
% Need to review autospectra
%% 
function [mwcoh,mwcpsd,awcoh,awcpsd,freq] = tsdata2wcpsd(tsdata,fs,twindow)

[tsdim, nobs,ntrials] = size(tsdata);
[bi_wcoh,bi_wcs,freq] = wcoherence(tsdata(1,twindow),tsdata(2,twindow),fs); %get the number of frequencies

%initialise
if size(twindow,2)>size(twindow,1)
    window_size=size(twindow,2);
else
    window_size=size(twindow,1);
end

mwcoh = zeros(tsdim,tsdim,size(freq,1),window_size);
mwcpsd = zeros(tsdim,tsdim,size(freq,1),window_size);

%Wavelet cross coherence and cross spectral power

for i=1:tsdim
    for j=1:tsdim
        [mwcoh(i,j,:,:), mwcpsd(i,j,:,:)]=wcoherence(tsdata(i,twindow),tsdata(j,twindow),fs);
    end
end

%Auto spectra

awcoh = zeros(1,tsdim,size(freq,1),window_size);
awcpsd = zeros(1,tsdim,size(freq,1),window_size);

for i=1:tsdim
    awcpsd(1,i,:,:) = mwcpsd(i,i,:,:);
    awcoh(1,i,:,:) = mwcoh(i,i,:,:);
end

awcoh = squeeze(awcoh);
awcpsd = squeeze(awcpsd);