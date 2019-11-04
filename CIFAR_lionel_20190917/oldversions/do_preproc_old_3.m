%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process data: highpass filter and line-noise removal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify ECoG data set (BP, subject, name), e.g.
%{
BP = false; subject = 'AnRa'; name = 'freerecall_rest_baseline_1_preprocessed';
%}

if ~exist('hpfreq',    'var'), hpfreq    = [];    end % high-pass filter frequency (Hz)
if ~exist('hpord',     'var'), hpord     = 2;     end % high-pass filter order
if ~exist('pford',     'var'), pford     = [];    end % polynomial fit order
if ~exist('lnfreqs',   'var'), lnfreqs   = [];    end % line-noise frequency (Hz)
if ~exist('wlen',      'var'), wlen      = 5;     end % length of window (secs)
if ~exist('slen',      'var'), slen      = 0.1;   end % window slide time (secs)
if ~exist('verb',      'var'), verb      = 2;     end % verbosity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hpfilt = ~isempty(hpfreq);
pfdet  = ~isempty(pford);
lnrem  = ~isempty(lnfreqs);
winds  =  lnrem || pfdet;

assert(hpfilt || pfdet || lnrem,'\nYou don''t seem to be doing any preprocessing!\n');

% Load unpreprocessed data

[X,FS,filepath,filename] = load_nopreproc(BP,subject,name);

[nchans,nobs] = size(X);

FQ = FS/2; % Nyqvist frequency

ppdir = 'preproc';

if hpfilt % high-pass filter

	fprintf('\nHigh-pass filtering at %gHz (order %d Butterworth)\n',hpfreq,hpord);
	if verb > 1, input('\nRETURN to continue: '); end

	X = hpfilter(X,FS,hpfreq,hpord); % Butterworth high-pass zero-phase filter

	ppdir = [ppdir sprintf('_hipass_%gHz_order_%d',hpfreq,hpord)];

end

if winds % make sliding windows

	[nwin,noobs,nwobs,nsobs,nobs,t,tseg,obs,oseg,tlen,wlen,slen] = sliding(nobs,FS,[],wlen,slen,[],2);

	X = X(:,obs);

	nover = nwobs-nsobs; % window overlap
	b = blender((0:(nover-1))/(nover-1)); % the blender

	ppdir = [ppdir sprintf('_window_%gs_slide_%gs',wlen,slen)];

end

if pfdet % windowed polynomial trend removal

	fprintf('\nCalculating polynomial trends of order %d\n',pford);
	if verb > 1, input('\nRETURN to continue: '); end

	wptrend = zeros(nchans,nwobs,nwin);
	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d',w,nwin);
		o = noobs+(w-1)*nsobs;       % window offset
		W = X(:,o+1:o+nwobs); % the window
		[wptrend(:,:,w),wflag] = pftrend(W,FS,pford);
		if wflag, fprintf(' *\n'); else, fprintf('\n'); end
	end

	fprintf('\nBlending windowed polynomial trends\n');
	if verb > 1, input('RETURN to continue: '); end

	ptrend = zeros(nchans,nobs);
	ptrend(:,1:nwobs) = wptrend(:,:,1);
	for w = 2:nwin % loop through windows
		fprintf('window %4d of %d ... ',w,nwin);
		o = noobs+(w-1)*nsobs; % window offset
		ptrend(:,o+1:o+nover) = (1-b).*ptrend(:,o+1:o+nover) + b.*wptrend(:,1:nover,w); % blend overlap
		ptrend(:,o+nover+1:o+nwobs) = wptrend(:,nover+1:nwobs,w);                       % append remainder
		fprintf('done\n');
	end

	X = X-ptrend;

	clear W wptrend ptrend

	ppdir = [ppdir sprintf('_ptrem_%d',pford)];

end

if lnrem % windowed line-noise removal

	if isscalar(lnfreqs) && lnfreqs < 0 % all harmonics
		lnf = -lnfreqs;
		nlnfreqs = floor(FQ/lnf);    % number of line-noise harmonics
		lnfreqs  = (1:nlnfreqs)*lnf; % line noise harmonics
	else
		assert(isvector(lnfreqs),'Line-noise frequencies must be a vector (or negative scalar for harmonics)');
		nlnfreqs = length(lnfreqs);
	end

	fprintf('\nCalulating line-noise at %s\n',sprintf('%gHz, ',lnfreqs));
	if verb > 1, input('\nRETURN to continue: '); end

	wlnoise = zeros(nchans,nwobs,nwin);
	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d\n',w,nwin);
		o = noobs+(w-1)*nsobs;       % window offset
		W = X(:,o+1:o+nwobs); % the window
		wlnoise(:,:,w) = lntrend(W,FS,lnfreqs);
	end

	fprintf('\nBlending windowed line-noise\n');
	if verb > 1, input('RETURN to continue: '); end

	lnoise = zeros(nchans,nobs);
	lnoise(:,1:nwobs) = wlnoise(:,:,1);
	for w = 2:nwin % loop through windows
		fprintf('window %4d of %d ... ',w,nwin);
		o = noobs+(w-1)*nsobs; % window offset
		lnoise(:,o+1:o+nover) = (1-b).*lnoise(:,o+1:o+nover) + b.*wlnoise(:,1:nover,w); % blend overlap
		lnoise(:,o+nover+1:o+nwobs) = wlnoise(:,nover+1:nwobs,w);                       % append remainder
		fprintf('done\n');
	end

	X = X-lnoise;

	clear W wlnoise lnoise

	ppdir = [ppdir sprintf('_lnrem%s',sprintf('_%gHz',lnfreqs))];

end

filepath = fileparts(filepath); % strip off 'nopreproc'

[status,msg] = mkdir(filepath,ppdir);
assert(status == 1,msg);

fname = fullfile(filepath,ppdir,[filename '.mat']);

fprintf('\nSaving preprocessed data in ''%s'' ... ',fname);
if verb > 1, input('RETURN to continue: '); end
save(fname,'X','FS');
fprintf('done\n');

function b = blender(x)

	b = (1-cos(pi*x))/2;

end
