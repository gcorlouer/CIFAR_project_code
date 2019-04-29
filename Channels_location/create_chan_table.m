%% Create a structure array relating ROI, index of ROI, channel numbers in a
%given ROI and number of channles in that ROI
ROI=EEG.ROI;
for i=1:size(EEG.ROI)
    chan_table(i).ROIs=ROI{i,1};
end
for i=1:size(EEG.ROI)
    chan_table(i).ROIidx=ROI2idx(ROI{i,1});
end
for i=1:size(EEG.ROI)
    chan_table(i).chans_idx=ROI2num_dic(idx2ROI(i));
end
for i=1:size(EEG.ROI)
    chan_table(i).num_chans=size(chan_table(i).chans_idx,1);
end
%% Other format for python processing
ch_table.chan_idx=1:1:EEG.nbchan; %chan idx 
ch_table.chan_name=chan_name; 
chan_ROIidx=zeros(EEG.nbchan,1);
for i=1:EEG.nbchan
    chan_ROIidx(i)=ROI2idx(chan_region{i}); %give the ROIidx of a chan idx
end
ch_table.ROIidx=chan_ROIidx;
ch_table.chan_idx=ch_table.chan_idx'