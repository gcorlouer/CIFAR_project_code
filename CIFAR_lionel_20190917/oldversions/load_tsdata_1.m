%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load a segment of (preprocessed) data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract specified time segment. Too-early first time is set to the earliest time
% stamp on file; too-late  last time is set to the latest time stamp on file (first
% time can be -Inf, last time can be +Inf, to specify first and last time stamps
% respectively). If 'tseg' is empty, the entrie available data is returned. If
% 'oflag' is set, "times" are interpreted as observation indices.
%
% If the 'bigfile' flag is set, the data is read from file on disk, rather than
% loaded into memory; this may be slow - use only for very large data files or
% in case of limited memory.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [X,ts,fs,ev,schans,chanstr,goodchans,channames,filepath,filename] = load_tsdata(BP,subject,dataset,ppdir,schans,badchans,tseg,ds,bigfile,verb)

if nargin <  5                      schans   = [];    end % channel selection
if nargin <  6                      badchans = [];    end % "bad" channels (to avoid)
if nargin <  7                      tseg     = [];    end % whole time series
if nargin <  8 || isempty(ds),      ds       = 1;     end % downsample factor (1 for no downsample)
if nargin <  9 || isempty(bigfile), bigfile  = false; end % read directly from disk without loading into memory
if nargin < 10 || isempty(verb),    verb     = 2;     end % verbosity level

[filepath,filename] = CIFAR_filename(BP,subject,dataset);

filepath = fullfile(filepath,ppdir);
fname    = fullfile(filepath,[filename,'.mat']);

X  = [];
ts = [];
fs = [];
ev = [];

if bigfile
	m = matfile(fname,'Writable',false);
	[nchans,nobs] = size(m,'X');
	ts = m.ts; % we need to load this to find segment... hopefully enough memory!
	fs = m.fs;
	ev = m.ev;
else
	load(fname);
	[nchans,nobs] = size(X);
end

% Select channels

[schans,chanstr,goodchans,channames] = chan_select(subject,nchans,schans,badchans);

% Calculate time segment. If negative, treat tseg(i) as observation numbers rather than
% times. If tseg a 3-vector, interpret tseg(2) as segment length (time or observations).

if isempty(tseg)
	oseg = [1 nobs];
else
	assert (isvector(tseg),'Time segment must be an ascending 2- or 3-vector (or empty)');
	if tseg(1) < 0, oseg(1) = -tseg(1);	else, oseg(1) = nnz(tseg(1) > ts)+1; end
	if length(tseg) == 3 % tseg(2) is duration
		if tseg(2) < 0, oseg(2) = oseg(1)-tseg(2)-1; else, oseg(2) = nnz(tseg(1)+tseg(2) >= ts); end
	else
		assert (length(tseg) == 2,'Time segment must be an ascending 2- or 3-vector (or empty)');
		if tseg(2) < 0, oseg(2) = -tseg(2); else, oseg(2) = nnz(tseg(2) >= ts); end
	end
	assert(oseg(1) <= nobs,   'Bad times: first time too late');
	assert(oseg(2) >= 1,      'Bad times: last time too early');
	assert(oseg(2) >= oseg(1),'Bad times: last time earlier than first time');
end

% Got requested time segment as observationssegment

o = oseg(1):oseg(2);

if bigfile
	X  = m.X(schans,o);
else
	X  = X(schans,o);
end
ts = ts(o);

% Downsample

if ds > 1
	subsamp = 1:ds:length(o);
    X  = X(:,subsamp);
    ts = ts(subsamp);
	fs = fs/ds;
end
