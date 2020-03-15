function [envelope, tsdata_filt] = tsdata2env(tsdata, bpFilt)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract high frequency broad band envelope. 

%Parameters
%nband: number of frequency bands of interest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[nchan,nobs]=size(tsdata);

tsdata_filt = zeros(size(tsdata));
tsdata_anal = zeros(size(tsdata));
envelope = zeros(size(tsdata));

for i = 1:nchan
    tsdata_filt(i, :) = filter(bpFilt, 1, tsdata(i, :));
    tsdata_anal(i,:) = hilbert(tsdata_filt(i,:)); % extract analytic signal
    envelope(i,:)    = abs(tsdata_anal(i,:));
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
