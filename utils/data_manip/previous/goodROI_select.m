%Select ROI with striclty more than 1 channel

ngoodROI = 1;

for i = 1:EEG.SUMA.nROIs
    if  EEG.SUMA.nROIchans(i) > 1
        ngoodROI = ngoodROI + 1;
    else
    
    end
end
% 
% EEG.SUMA.ROIgood_name = cell(1,ngoodROI);
% EEG.SUMA.ROI2chan_good = cell(1,ngoodROI);

for i = 1:EEG.SUMA.nROIs
    if  EEG.SUMA.nROIchans(i) > 1 && strcmp(EEG.SUMA.ROInames{i},'unknown') ~= 1
     EEG.SUMA.ROIgood_name{i} = EEG.SUMA.ROInames{i};
     EEG.SUMA.ROI2chan_good{i} = EEG.SUMA.ROI2chans{i};
     EEG.SUMA.goodROInum(i) = i;
    else

    end
end

% drop empty cell
EEG.SUMA.ROIgood_name = EEG.SUMA.ROIgood_name(~cellfun('isempty',EEG.SUMA.ROIgood_name)); 
EEG.SUMA.ROI2chan_good = EEG.SUMA.ROI2chan_good(~cellfun('isempty',EEG.SUMA.ROI2chan_good));
EEG.SUMA.goodROInum = nonzeros(EEG.SUMA.goodROInum);