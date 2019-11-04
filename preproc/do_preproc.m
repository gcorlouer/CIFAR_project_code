%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process data: highpass and/or polynomial detrend and/or line-noise removal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Specify ECoG data set (BP, subject, dataset), e.g.
%
% BP = false; subject = 'AnRa'; dataset = 'freerecall_rest_baseline_1_preprocessed';
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('hpfreq',    'var'), hpfreq    = [];       end % high-pass filter frequency (Hz)
if ~exist('hpord',     'var'), hpord     = [];       end % high-pass filter order
if ~exist('pford',     'var'), pford     = 8;        end % polynomial fit order
if ~exist('pfwind',    'var'), pfwind    = [5 0.1];  end % polynomial fit window width and slide time (secs)
if ~exist('lnfreqs',   'var'), lnfreqs   = [60 180]; end % line-noise frequency (Hz)
if ~exist('lnwind',    'var'), lnwind    = [5 0.1];  end % line-noise window width and slide time (secs)
if ~exist('verb',      'var'), verb      = 2;        end % verbosity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hpfilt = ~isempty(hpfreq);
pfdet  = ~isempty(pford);
lnrem  = ~isempty(lnfreqs);

assert(hpfilt || pfdet || lnrem,'\nYou don''t seem to be doing any preprocessing!\n');

if lnrem
	if isscalar(lnfreqs) && lnfreqs < 0 % all harmonics
		lnf = -lnfreqs;
		nlnfreqs = floor(fs/lnf/2);  % number of line-noise harmonics
		lnfreqs  = (1:nlnfreqs)*lnf; % line noise harmonics
	else
		assert(isvector(lnfreqs),'Line-noise frequencies must be a vector (or negative scalar for harmonics)');
		nlnfreqs = length(lnfreqs);
	end
end

% Load unpreprocessed data

[X,ts,fs] = load_EEG(BP,subject,dataset,'nopreproc');
[nchans,nobs] = size(X);

ppdir = 'preproc';

if hpfilt % high-pass filter

	fprintf('\nHigh-pass filtering at %gHz (order %d Butterworth)\n',hpfreq,hpord);
	if verb > 1, input('\nRETURN to continue: '); end

	X = hpfilter(X,fs,hpfreq,hpord); % Butterworth high-pass zero-phase filter

	ppdir = [ppdir sprintf('_hipass_%gHz_o%d',hpfreq,hpord)];

end

if pfdet % windowed polynomial trend removal

	fprintf('\nRemoving polynomial trends of order %d\n',pford);

	[X,ts,nwin,nwobs,nsobs,~,wind] = sliding(X,ts,fs,pfwind,[],verb);
	nobs = length(ts);

	nover = nwobs-nsobs; % window overlap
	assert(nover > 0,'No overlap!');
	m = mergefunc((1:nover)/(nover+1)); % merge weights

	trend = zeros(nchans,nobs);
	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d',w,nwin);
		o = (w-1)*nsobs;       % window offset
		W = X(:,o+1:o+nwobs);  % the window
		[wtrend,wflag] = pftrend(W,fs,pford);
		if wflag, fprintf(' *\n'); else, fprintf('\n'); end
		if w == 1
			trend(:,1:nwobs) = wtrend; % initialise - copy first window
		else
			trend(:,o+1:o+nover) = (1-m).*trend(:,o+1:o+nover) + m.*wtrend(:,1:nover); % merge window on overlap
			trend(:,o+nover+1:o+nwobs) = wtrend(:,nover+1:nwobs);                      % copy remainder of window
		end
	end

	X = X-trend;

	ppdir = [ppdir sprintf('_ptrem_%d_w%gs%g',pford,wind(1),wind(2))];

end

if lnrem % windowed line-noise removal

	fprintf('\nRemoving line-noise at %s\n',sprintf('%gHz, ',lnfreqs));

	[X,ts,nwin,nwobs,nsobs,~,wind] = sliding(X,ts,fs,lnwind,[],verb);
	nobs = length(ts);

	nover = nwobs-nsobs; % window overlap
	assert(nover > 0,'No overlap!');
	m = mergefunc((1:nover)/(nover+1)); % merge weights

	trend = zeros(nchans,nobs);
	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d\n',w,nwin);
		o = (w-1)*nsobs;       % window offset
		W = X(:,o+1:o+nwobs);  % the window
		wtrend = lntrend(W,fs,lnfreqs);
		if w == 1
			trend(:,1:nwobs) = wtrend; % initialise - copy first window
		else
			trend(:,o+1:o+nover) = (1-m).*trend(:,o+1:o+nover) + m.*wtrend(:,1:nover); % merge window on overlap
			trend(:,o+nover+1:o+nwobs) = wtrend(:,nover+1:nwobs);                      % copy remainder of window
		end
	end

	X = X-trend;

	ppdir = [ppdir sprintf('_lnrem%s_w%gs%g',sprintf('_%gHz',lnfreqs),wind(1),wind(2))];

end

[filepath,filename] = CIFAR_filename(BP,subject,dataset);

[status,msg] = mkdir(filepath,ppdir);
assert(status == 1,msg);

fname = fullfile(filepath,ppdir,[filename '.mat']);

fprintf('\nSaving preprocessed data in ''%s'' ... ',fname);
if verb > 1, input('RETURN to continue: '); end
save(fname,'-v7.3','X','ts');
fprintf('done\n');

function m = mergefunc(x) % window merge function ("Hamming sigmoid")

	m = (1-cos(pi*x))/2;

end
