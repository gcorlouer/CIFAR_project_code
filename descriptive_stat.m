%% Descriptive statistics 
%% Preprocessed
tsdata=double(EEG.data); 
fres=2^11;
fs=EEG.srate;
fc=1; %cutoff frequency
filt_order=2;
dsample=1;
tsdata_pp=tsdata2preprocessed(tsdata,dsample,fc,fs,fres,filt_order); %filter and downsample
%% Select good chans
pick_ROI=1:1:22;
pick_ROI=pick_ROI';
pick_chan=[];
[tsdata_ROI,pick_chan]=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx);
%% Slide window 
window_size=10000;
num_chan=size(tsdata_ROI,1);
tsdata_length=size(tsdata_ROI,2);
tsdata_slided=tsdata2slided(tsdata_ROI, window_size,num_chan,tsdata_length);
%% Partial correlation 
pcorr=partialcorr(tsdata_slided(:,:,1)');
imagesc(pcorr);
colormap(jet);
colorbar;
title('Partial correlation AnRa, rest')
%% Partial Correlation in ROIs
pick_ROI=6;
pick_chan_ROI=find(chan2ROIidx==pick_ROI);
pick_chan_ROI=pick_chan_ROI';
good_ch_idx=[];
for i=1:size(pick_chan_ROI,2)
    good_ch_idx=horzcat(good_ch_idx, find(pick_chan==pick_chan_ROI(i)));
end
imagesc(pcorr(good_ch_idx,good_ch_idx));
colormap(jet);
colorbar;
title(['Partial correlation AnRa, rest, ROI ', num2str(pick_ROI)])
%% Get rid off channels with high enough correlation
drop_chan=[]
for i=1:size(pcorr,1)
    for j=i+1:size(pcorr,1)
        if pcorr(i,j)>= 0.8
            drop_chan=horzcat(drop_chan,pick_chan(j))
        else 
            j=j+1;
        end
    end
end
