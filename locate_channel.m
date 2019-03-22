%% Add regions and label channels in the EEG structure
load('/its/home/gc349/CIFAR_guillaume/CIFAR_data/CIFAR/iEEG_10/subjects/AnRa/SUMAprojectedElectrodes.mat');
elec_region=SUMAprojectedElectrodes.aparcaseg.bestLabel.labels;
elec_region=elec_region';
elec_name=SUMAprojectedElectrodes.elecNames;
chan_name={};
chan_region={};
%Pick the labels of the chans in EEG structure
for i=1:size(EEG.chanlocs,2)
       chan_name{i}=EEG.chanlocs(i).labels;
end
chan_name=chan_name';
%Fill array of channels region according to EEG.urnumber
chan_region=chan2region(chan_name,elec_name,elec_region);
%Add channels region to the structure
for i=1:size(EEG.chanlocs,2)
    EEG.chanlocs(i).region=chan_region(i);
end
%Add regions of interest to the structure
EEG.ROI=unique(chan_region);
%% Index ROI
ROI=EEG.ROI;
ROI_idx=1:1:size(EEG.ROI);
ROI2idx=containers.Map(ROI,ROI_idx);
idx2ROI=containers.Map(ROI_idx,ROI);
%add ROI index to each channel region in the EEG structure
for i=1:size(chan_name)
    EEG.chanlocs(i).idx_chan_ROI=ROI2idx(char(EEG.chanlocs(i).region));
end
%% Show channels numbers in a given region
ROI2num_dic=region2chan(chan_region,EEG.ROI);
