%Create a structure array relating ROI, index of ROI, channel numbers in a
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