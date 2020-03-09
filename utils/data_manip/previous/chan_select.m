%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Inputs:
%
% subject     - subject label (e.g., 'AnRa')
% nchans      - number of channels available
% schans      - specification of channels to select (see below)
% badchans    - vector of designated "bad" channel numbers
%
% Outputs:
%
% schans      - vector of channel numbers selected
% chanstr     - a brief description of the selected channels (string)
% goodchans   - vector of all "good" channel numbers (i.e., not designated "bad")
% channames   - channel labels for the selected channels (cell string)
%
% The input 'schans' can be empty (for all "good" channels), a vector of specific
% channel numbers, or a negative number, specifying an ROI. ROI information is
% looked up in the file .../subject/Brain/ROI_map.mat, and "bad" channels (if
% specified) are omitted,
%
% Channel names are looked up in the file .../subject/Brain/channel_names.mat.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Typical usage:
%
% [X,fs] = load_preproc(BP,subject,name,ppdir);
%
% [schans,chanstr] = chan_select(subject,size(X,1),schans,badchans);
% fprintf('\nUsing %s\n',chanstr);
%
% *** do something with X ***
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [schans,chanstr,goodchans,channames] = chan_select(BP,subject,task,nchans,schans,badchans)

if nargin < 3, schans   = []; end
if nargin < 4, badchans = []; end

[EEG,filepath,filename] = get_EEG_info(BP,subject,task);

goodchans = 1:nchans;
goodchans(badchans) = [];

if isempty(schans) % all good channels

	schans  = goodchans;
	if nargout > 1
		chanstr = sprintf('all %d (good) channels',length(goodchans));
	end

elseif isscalar(schans) && schans < 0 % all good channels in specified ROI

	rmap = get_ROI_map(subject);
	assert(nchans == rmap.nchans,'number of channels specified does not match ROI map');
	roinum = -schans;
	assert(isscalar(roinum) && roinum >= 1 && roinum <= rmap.nROIs,'ROI index out of range (%d ROIs)',rmap.nROIs);
	schans = rmap.ROI2chans{roinum};
	[~,idx] = intersect(schans,badchans);   % indices of bad channels in selected channels

	if ~isempty(idx), schans(idx) = []; end % omit bad channels
	if nargout > 1
		chanstr = sprintf('ROI %d (%s): channels%s',roinum,rmap.ROInames{roinum},sprintf(' %d',schans));
	end

else % specified channels

	assert(isvector(schans),'Selected channels must be specified as empty, -(ROI number), or a vector');
	[~,u] = unique(schans);
	assert(numel(schans) == numel(u),'Some duplicate selected channels');
	assert(~any(schans < 1 | schans > nchans), 'Some selected channels out of range (%d channels)',nchans);
	assert(isempty(badchans) || nnz(schans == badchans') == 0,'Some bad channels selected')
	if nargout > 1
		chanstr = sprintf('channels%s',sprintf(' %d',schans));
	end

end

if nargout > 3
	channames = get_channel_names(subject,schans);
end
