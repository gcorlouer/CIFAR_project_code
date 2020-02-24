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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,verb)

if nargin < 5                      chans    = [];    end % all channels
if nargin < 6                      tseg     = [];    end % whole time series
if nargin < 7 || isempty(ds),      ds       = 1;     end % no downsample
if nargin < 8 || isempty(bigfile), bigfile  = false; end % read data into memory
if nargin < 9 || isempty(verb),    verb     = 0;     end % display info, don't prompt

EEG = get_EEG_info(BP,subject,task);
    
if bigfile 
	[m,ts] = get_EEG_tsdata(BP,subject,task,ppdir,true);
	[nchans,nobs] = size(m,'X');
else
	[X,ts] = get_EEG_tsdata(BP,subject,task,ppdir,false);
	[nchans,nobs] = size(X);
end
assert(nchans == EEG.nbchan,'Number of channels doesn''t match EEG header');
if isempty(chans)
	chans = 1:nchans;
end

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
	X = X(chans,:);
else
	X  = X(chans,o);
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
	fprintf('\nSample rate = %gHz\n',fs);
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
