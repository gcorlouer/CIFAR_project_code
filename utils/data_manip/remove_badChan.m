function [X, EEG] = remove_badChan(EEG, dropChan)
% Remove bad chans and save bad and good chans info in the EEG structure
% Might have memory problem if we load too much data

nchan = EEG.nbchan;

goodChan = [];
for i = 1:nchan
    if ~ismember(i, dropChan)
        goodChan = [goodChan, i];
    end
end

% Bad chans info
EEG.preproc.badchanName = EEG.SUMA.channames(dropChan);
EEG.preproc.badchanIdx = dropChan ;
EEG.preproc.badchan_iROI = EEG.SUMA.chan2ROI(dropChan);
EEG.preproc.badchanROIname = EEG.SUMA.chan2ROIname(dropChan);

% Good chans info
EEG.preproc.goodchanName = EEG.SUMA.channames(goodChan);
EEG.preproc.goodchanIdx = goodChan ;
EEG.preproc.goodchan_iROI = EEG.SUMA.chan2ROI(goodChan);
EEG.preproc.goodchanROIname = EEG.SUMA.chan2ROIname(goodChan);

% Good ROIs info
EEG.preproc.igoodROI = unique(EEG.preproc.goodchan_iROI);
EEG.preproc.igoodROIname = EEG.SUMA.ROInames(EEG.preproc.igoodROI) ;

% Bad ROIs info
EEG.preproc.ibadROI = [];

for i= 1:EEG.SUMA.nROIs
    if ~ismember(i, EEG.preproc.igoodROI)
    EEG.preproc.ibadROI = [EEG.preproc.ibadROI, i];
    end
end
EEG.preproc.badROIname = EEG.SUMA.ROInames(EEG.preproc.ibadROI);

% Drop bad chans and append data
EEG =  pop_select(EEG, 'nochannel', dropChan); % Would be interesting to keep track of ROI
X = EEG.data;
