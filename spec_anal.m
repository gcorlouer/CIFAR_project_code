%% Spectral analysis
run(param_init.m); %init parameters
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order); %filter and downsample
%% Select ROIs
drop_chan=find(chan2ROIidx==23); %unknown ROI
pick_chan=[];
for i=1:(max(ROI_idx)-1)
   add_chan=find(chan2ROIidx==i);
   add_chan=add_chan';
   pick_chan=horzcat(pick_chan,add_chan);
end
tsdata_ROI=tsdata_pp(pick_chan,:);
%% Compute cpsd (autospec=True mean we compute the autospectral density)
[cpsd_filt,f,fres] = tsdata_to_cpsd(tsdata_ROI,[],fs,[],[],fres,'True',[]); 
%% Plot cpsd
%filtered cpsd
figure(1); 
loglog(f,cpsd_filt)
xlabel('Frequency')
ylabel('Spectral density')
title([num2str(fc) ' Hz High pass filtered power spectral density function, downsampled by ' num2str(dsample) ', all chans, AnRa, resting raw data'])
