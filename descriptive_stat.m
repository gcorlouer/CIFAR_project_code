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
%% Correlation 
[corr_pears,pval_corr]=corr(tsdata_slided(:,:,2)');
imagesc(corr_pears);
colormap(jet);
colorbar;
title('Partial correlation AnRa, rest, good chans ')
%% Correlation significance 
%  Want alpha very small to reduce false positive.
%  Higher false negative is ok, we want to get rid of highly partially
%  correlated channels to keep more representative one 
alpha=0.0005; 
sig_corr=significance(pval_corr,alpha,'Bonferroni');
imagesc(sig_corr);
colormap(jet);
colorbar;
title('Significance of correlation AnRa, rest')
%% Partial correlation 
[pcorr,pval_pcorr]=partialcorr(tsdata_slided(:,:,1)');
imagesc(pcorr);
colormap(jet);
colorbar;
title('Partial correlation AnRa, rest')
%set(gca,'XTick',[1:2],'XTickLabel',{'poz','fp1'})
%% Significance of partial correlation 
%  Want alpha very small to reduce false positive.
%  Higher false negative is ok, we want to get rid of highly partially
%  correlated channels to keep more representative one 
alpha=0.0005; 
sig_pcorr=significance(pval_pcorr,alpha,'Bonferroni');
imagesc(sig_pcorr);
colormap(jet);
colorbar;
title('Significance of partial correlation AnRa, rest')
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
%% Get rid off channels with significant partial correlation
drop_chan=[];
for i=1:size(pcorr,1)
    for j=i+1:size(pcorr,1)
        if pcorr(i,j)>= 0.5
            drop_chan=horzcat(drop_chan,pick_chan(i));
        else 
            j=j+1;
        end
    end
end
