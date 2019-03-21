%% Attribute number to regions and the region index in EEG structure
lbl_keySet=ROI;
lbl_valueSet=1:size(squeeze(ROI));
labeled_ROI_dict=containers.Map(lbl_keySet, lbl_valueSet);
for i=1:128
    EEG.chanlocs(i).idx_ROI=labeled_ROI_dict(char(EEG.chanlocs(i).region));
end