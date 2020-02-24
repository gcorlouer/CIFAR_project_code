function sm = get_SUMA_map(subject)

fprintf('Loading SUMA map file ... ');
global cfsubdir
SUMAprojectedElectrodes = [];
load(fullfile(cfsubdir,subject,'Brain','SUMAprojectedElectrodes.mat'));
fprintf('done\n\n');
sm = SUMAprojectedElectrodes;


% cm.chansbyROI = horzcat(cm.ROI2chans{:}); % concatenate!y = cell2mat(cm.ROI2
