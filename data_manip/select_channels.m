%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [chans,chanstr,channames,ogchans] = select_channels(BP,subject,task,schans,badchans,verb)

if nargin < 4,                  schans   = [];    end % all channels
if nargin < 5,                  badchans = [];    end % no bad channels
if nargin < 6 || isempty(verb), verb     = 2;     end % display info and prompt

EEG = get_EEG_info(BP,subject,task);

nchans = EEG.nbchan;

% Select channels

if isscalar(badchans) && badchans == 0 % bad channels are the unknown channels
	assert(isfield(EEG,'SUMA'),'No SUMA map for this dataset (have you run ''make_SUMA_channel_maps?)');
	badchans = EEG.SUMA.ROI2chans{EEG.SUMA.nROIs}
end

goodchans = 1:nchans;
goodchans(badchans) = [];

if isempty(schans) % all good channels

	chans  = goodchans;
	chanstr = sprintf('all %d (good) channels',length(chans));

elseif isscalar(schans) && schans < 0 % all good channels in specified ROI

	assert(isfield(EEG,'SUMA'),'No SUMA map for this dataset (have you run ''make_SUMA_channel_maps?)');
	roinum = -schans;
	assert(isscalar(roinum) && roinum >= 1 && roinum <= EEG.SUMA.nROIs,'ROI index out of range (%d ROIs)',EEG.SUMA.nROIs);
	chans = EEG.SUMA.ROI2chans{roinum};
	[~,idx] = intersect(chans,badchans);   % indices of bad channels in selected channels
	if ~isempty(idx), chans(idx) = []; end % omit bad channels
	chanstr = sprintf('ROI %d (%s): channels%s',roinum,EEG.SUMA.ROInames{roinum},sprintf(' %d',chans));

else % specified channels

	assert(isvector(schans),'Selected channels must be specified as empty, -(ROI number), or a vector');
	[~,u] = unique(schans);
	assert(numel(schans) == numel(u),'Duplicate selected channels');
	assert(~any(schans < 1 | schans > nchans), 'Some selected channels out of range (%d channels)',nchans);
	chans = schans;
	[~,idx] = intersect(chans,badchans);   % indices of bad channels in selected channels
	if ~isempty(idx), chans(idx) = []; end % omit bad channels
	chanstr = sprintf('channels%s',sprintf(' %d',chans));

end
assert(~isempty(chans),'No channels selected!');

ogchans = setdiff(goodchans,chans); % other (non-selected) good channels

if isfield(EEG,'SUMA')
	channames = EEG.SUMA.channames(chans);
	for k = 1:length(chans)
		channames{k} = sprintf('%3d : %s',chans(k),channames{k});
	end
else
	fprintf(2,'WARNING: No SUMA map - setting channel names to channel numbers\n');
	for k = 1:length(chans)
		channames{k} = sprintf('%3d',chans(k));
	end
end

if verb > 0
	fprintf('\nSelected %s\n',chanstr);
	if verb > 1, input('RETURN to continue: '); end
end
