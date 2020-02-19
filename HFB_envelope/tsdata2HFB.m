function [envelope_band,band]=tsdata2HFB(tsdata,fs,band_low,band_size,nband,filt_order)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract high frequency broad band envelope. 

%Parameters
%nband: number of frequency bands of interest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nchan,nobs]=size(tsdata);
band=zeros(nband,1);
band(1)=band_low;

for i=1:(nband-1)
    band(i+1)=band(i)+band_size;
end

tsdata_band=zeros(nchan,nobs,nband-1);
envelope_band=zeros(nchan,nobs,nband-1);
menvelope_band=zeros(nchan,nband-1);
iir=0;

for i=1:(nband-1)
    tsdata_band(:,:,i)=tsdata2ts_filtered(tsdata,fs,band(i),band(i+1),filt_order, iir);
    envelope_band(:,:,i)=tsdata2envelope(tsdata_band(:,:,i));
end
    
%% Try to replicate Itzik method of envelope extraction
    %     menvelope_band(:,i)=squeeze(mean(envelope_band(:,:,i),2));
%     for j=1:nchan
%         normalised_envelope_band(j,:,i)=envelope_band(j,:,i)/menvelope_band(j,i); 
%     end
% end
% av_mean_envelope=1/nband*squeeze(sum(menvelope_band,2));  %average mean of envelope accross frequency bands
% HFB_normalised=1/nband*squeeze(sum(normalised_envelope_band,3));
% for i=1:nchan
%     HFB_envelope(i,:)=av_mean_envelope(i)*HFB_normalised(i,:);
% end
