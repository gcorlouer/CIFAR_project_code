function [Xep, EEG] = epoch_preprocECoG(subject, task, BP)

[chans1,chanstr1] = select_channels(BP,subject,task,schans1); % Drop bad channels
[chans2,chanstr2] = select_channels(BP,subject,task,schans2);
[cdensityChans, cdensityChanstr] = select_channels(BP,subject,task,schans);

[EEG,filepath,filename] = get_EEG_info(BP,subject,task);
goodROI_select; %add good ROI to EEG struct (to be implemented in the SUMA file later)
[chans,chanstr,~,ogchans] = select_channels(BP,subject,task,[chans1 chans2]);
[X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds); % [chans ogchans] for all ROI and chans otherwise

xchans1 = 1:length(chans1);                  % ROI 1 in X
xchans2 = length(chans1)+(1:length(chans2)); % ROI 2 in X
group = num2cell([xchans1 , xchans2],1);

EEG.data = X;

outEEG=eeg_regepochs(EEG, 'recurrence', 1, 'limits', [0 2]); 
Xep = outEEG.data;
