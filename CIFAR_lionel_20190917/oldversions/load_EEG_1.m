%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a segment of (preprocessed) data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract specified time segment. Too-early first time is set to the earliest time
% stamp on file; too-late  last time is set to the latest time stamp on file (first
% time can be -Inf, last time can be +Inf, to specify first and last time stamps
% respectively). If 'tseg' is empty, the entire available data is returned. Negative
% values in 'tseg' are interpreted as observation indices/numbers rather than times.
% If 'tseg' is a 3-vector, the second entry is interpreted as time segment duration
% rather than end time.
%
% If the 'bigfile' flag is set, the data is read from file on disk rather than
% loaded into memory (this may be slow; use only for very large datasets or in
% case of limited memory).
%
% For dataset specification, see 'utils/CIFAR_filename.m'.
%
% For channel selection, see 'utils/chan_select.m'.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X,ts,fs,schans,chanstr,goodchans,channames,EEG] = load_EEG(BP,subject,dataset,ppdir,schans,badchans,tseg,ds,bigfile,verb)

if nargin <  5                      schans   = [];    end % channel selection
if nargin <  6                      badchans = [];    end % "bad" channels (to avoid)
if nargin <  7                      tseg     = [];    end % whole time series
if nargin <  8 || isempty(ds),      ds       = 1;     end % downsample factor (1 for no downsample)
if nargin <  9 || isempty(bigfile), bigfile  = false; end % read directly from disk without loading into memory
if nargin < 10 || isempty(verb),    verb     = 2;     end % verbosity level

[EEG,filepath,filename] = get_EEG_info(BP,subject,dataset);

nchans = EEG.nbchan;

% Select channels

if isscalar(badchans) && badchans == 0 % bad channels are the unknown channels
	assert(isfield(EEG,'SUMA'),'No SUMA map for this dataset (have you run ''make_SUMA_channel_maps?)');
	badchans = EEG.SUMA.ROI2chans{EEG.SUMA.nROIs};
end

goodchans = 1:nchans;
goodchans(badchans) = [];

if isempty(schans) % all good channels

	schans  = goodchans;
	chanstr = sprintf('all %d (good) channels',length(goodchans));

elseif isscalar(schans) && schans < 0 % all good channels in specified ROI

	assert(isfield(EEG,'SUMA'),'No SUMA map for this dataset (have you run ''make_SUMA_channel_maps?)');
	roinum = -schans;
	assert(isscalar(roinum) && roinum >= 1 && roinum <= EEG.SUMA.nROIs,'ROI index out of range (%d ROIs)',EEG.SUMA.nROIs);
	schans = EEG.SUMA.ROI2chans{roinum};
	[~,idx] = intersect(schans,badchans);   % indices of bad channels in selected channels

	if ~isempty(idx), schans(idx) = []; end % omit bad channels
	chanstr = sprintf('ROI %d (%s): channels%s',roinum,EEG.SUMA.ROInames{roinum},sprintf(' %d',schans));

else % specified channels

	assert(isvector(schans),'Selected channels must be specified as empty, -(ROI number), or a vector');
	[~,u] = unique(schans);
	assert(numel(schans) == numel(u),'Some duplicate selected channels');
	assert(~any(schans < 1 | schans > nchans), 'Some selected channels out of range (%d channels)',nchans);
	assert(isempty(badchans) || nnz(schans == badchans') == 0,'Some bad channels selected')
	chanstr = sprintf('channels%s',sprintf(' %d',schans));

end

channames = EEG.SUMA.channames(schans);
for k = 1:length(schans)
	channames{k} = sprintf('%3d : %s',schans(k),channames{k});
end

if bigfile
	[m,ts] = get_EEG_tsdata(BP,subject,dataset,ppdir,true);
	[nchans,nobs] = size(m,'X');
else
	[X,ts] = get_EEG_tsdata(BP,subject,dataset,ppdir,false);
	[nchans,nobs] = size(X);
end
assert(nchans == EEG.nbchan,'Number of channels doesn''t match');

% Calculate time segment. If negative, treat tseg(i) as observation numbers rather than
% times. If tseg a 3-vector, interpret tseg(2) as segment length (time or observations).

if isempty(tseg)
	oseg = [1 nobs];
else
	assert (isvector(tseg),'Time segment must be an ascending 2- or 3-vector (or empty)');
	if tseg(1) < 0, oseg(1) = -tseg(1);	else, oseg(1) = nearest_time(ts,tseg(1)); end

	if length(tseg) == 3 % tseg(2) is duration
		if tseg(2) < 0, oseg(2) = oseg(1)-tseg(2)-1; else, oseg(2) = nearest_time(ts,tseg(1)+tseg(2)); end
	else
		assert (length(tseg) == 2,'Time segment must be an ascending 2- or 3-vector (or empty)');
		if tseg(2) < 0, oseg(2) = -tseg(2); else, oseg(2) = nearest_time(ts,tseg(2)); end
	end

	assert(oseg(1) <= nobs,   'Bad times: first time too late');
	assert(oseg(2) >= 1,      'Bad times: last time too early');
	assert(oseg(2) >= oseg(1),'Bad times: last time earlier than first time');
end

% Got requested time segment as observations segment

o  = oseg(1):oseg(2);
ts = ts(o);

if bigfile
	X = m.X(:,o);
	X = X(schans,:);
else
	X  = X(schans,o);
end

fs = double(EEG.srate);

% Downsample

if ds > 1
	dso = 1:ds:length(o);
    X  = X(:,dso);
    ts = ts(dso);
	fs = fs/ds;
end

if verb > 0
	fprintf('\nFile: %s (%s)\n',filename,ppdir);
	fprintf('%s\n',chanstr);
	fprintf('sample rate = %gHz\n',fs);
	fprintf('-----------------------------------------------\n');
	fprintf('total   : %7d observations  = %8.3f secs\n',length(ts),ts(end)-ts(1));
	fprintf('start   : %7d observations  = %8.3f secs\n',o(1),ts(1));
	fprintf('end     : %7d observations  = %8.3f secs\n',o(end),ts(end));
	fprintf('-----------------------------------------------\n');
	if verb > 1, input('RETURN to continue: '); end
end

end % function

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function i = nearest_time(ts,t)

	if t < ts(1),   t = ts(i);   i = 1;          return; end
	if t > ts(end), t = ts(end); i = length(ts); return; end
	[~,i] = min(abs(ts-t));

end

function i = nearest_time_alt(ts,t,firstime)

	if firstime
		i = nnz(t > ts)+1;
	else
		nnz(t >= ts);
	end

end
