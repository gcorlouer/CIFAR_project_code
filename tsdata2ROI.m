function tsdata_ROI=tsdata2ROI(tsdata_pp,pick_ROI,pick_chan,chan2ROIidx)
%Pick channels of interests in given ROI
for i=1:size(pick_ROI,1)
   add_chan=find(chan2ROIidx==pick_ROI(i,1));
   add_chan=add_chan';
   pick_chan=horzcat(pick_chan,add_chan);
end
tsdata_ROI=tsdata_pp(pick_chan,:);
end