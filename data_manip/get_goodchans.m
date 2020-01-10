function goodchans = get_goodchans(BP,subject,task,badchans)

EEG = get_EEG_info(BP,subject,task);

if isscalar(badchans) && badchans == 0 % bad channels are the unknown channels
	assert(isfield(EEG,'SUMA'),'No SUMA map for this dataset (have you run ''make_SUMA_channel_maps?)');
	badchans = EEG.SUMA.ROI2chans{EEG.SUMA.nROIs};
end

nchans = EEG.nbchan;
goodchans = 1:nchans;
goodchans(badchans) = [];
