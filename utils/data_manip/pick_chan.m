function  [X, EEG] = pick_chan(EEG, ROIs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pick channels belonging to specific ROIs
% Input: 
%%%%%%%%%
% - ROIs : ROIs to select from which pick channels
% - EEG : EEG structure
% Output: 
%%%%%%%%%
% X: time series with picked channels
% EEG: New EEG structure with picked channels
% Important note:
%%%%%%%%%%%%%%%%%%%%
% This funciton is to be used on preprocessed data i.e. with bad chans already
% removed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2 || isempty(ROIs), ROIs = EEG.preproc.igoodROI; end

picks = EEG.SUMA.ROI2chans(ROIs);

arpicks = [];
for i = 1:size(picks,1)
    arpicks = [arpicks, picks{i}];
end

npicks = size(arpicks,2);

picksIdx = zeros(npicks, 1);

X = EEG.data; % preprocessed data

for i= 1:npicks
    picksIdx(i) = find(EEG.preproc.goodchanIdx == arpicks(i));
end

nchan = size(EEG.SUMA.channames,2);
drops = [];

for i = 1:nchan
    if ~ismember(i, arpicks)
    drops = [drops i];
    end
end

EEG.picks.ichan = arpicks;
EEG.picks.idrops = drops;
EEG.picks.chanNames_pick = EEG.SUMA.channames(EEG.picks.ichan);
EEG.picks.chanNames_drop = EEG.SUMA.channames(EEG.picks.idrops);
EEG.picks.chan2ROI_pick = EEG.SUMA.chan2ROI(arpicks); 
EEG.picks.chan2ROI_drop = EEG.SUMA.chan2ROI(drops);
EEG.picks.name_chan2ROIpick  = EEG.SUMA.chan2ROIname(arpicks); 
EEG.picks.name_chan2ROIdrop = EEG.SUMA.chan2ROI(drops); 
EEG.picks.ROIname = EEG.SUMA.ROInames(ROIs);
EEG.picks.ROI2chans = EEG.SUMA.ROI2chans(ROIs);

X = X(picksIdx, :); % Return data with good picked chans
EEG.data = X;

end

