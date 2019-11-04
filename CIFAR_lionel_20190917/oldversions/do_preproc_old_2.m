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
if ~exist('osds',      'var'), osds      = [];    end % outlier std. devs.
if ~exist('orep',      'var'), orep      = 1;     end % replace strategy (= 1, 2, 3 - see 'routl.m')
if ~exist('wlen',      'var'), wlen      = 5;     end % length of window (secs)
if ~exist('slen',      'var'), slen      = 0.1;   end % window slide time (secs)
if ~exist('verb',      'var'), verb      = 2;     end % verbosity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hpfilt = ~isempty(hpfreq);
pfdet  = ~isempty(pford);
lnrem  = ~isempty(lnfreqs);
olrem  = ~isempty(osds);
winds  =  lnrem | olrem;

assert(hpfilt || pfdet || lnrem || olrem,'\nYou don''t seem to be doing any preprocessing!\n');

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

if pfdet % polynomial fit detrend

	fprintf('\nPerforming polynomial detrend of order %d\n',pford);
	if verb > 1, input('\nRETURN to continue: '); end

	[X,wflag] = pfdetrend(X,FS,pford);
	if wflag
		fprintf(2,'WARNING: some channels were unstable\n');
	end

	ppdir = [ppdir sprintf('_polyfit_%d',pford)];

end

if winds % make sliding windows

	[nwin,noobs,nwobs,nsobs,nobs,t,tseg,o,oseg,tlen,wlen,slen] = sliding(nobs,FS,[],wlen,slen,[],2);

	W = zeros(nchans,nwobs,nwin);
	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d\n',w,nwin);
		o = noobs+(w-1)*nsobs;       % window offset
		W(:,:,w) = X(:,o+1:o+nwobs); % the window
	end

	ppdir = [ppdir sprintf('_window_%gs_slide_%gs',wlen,slen)];

end

if lnrem % windowed line-noise filter

	if isscalar(lnfreqs) && lnfreqs < 0 % all harmonics
		lnf = -lnfreqs;
		nlnfreqs = floor(FQ/lnf);    % number of line-noise harmonics
		lnfreqs  = (1:nlnfreqs)*lnf; % line noise harmonics
	else
		assert(isvector(lnfreqs),'Line-noise frequencies must be a vector (or negative scalar for harmonics)');
		nlnfreqs = length(lnfreqs);
	end

	fprintf('\nRemoving line-noise at %s\n',sprintf('%gHz, ',lnfreqs));
	if verb > 1, input('\nRETURN to continue: '); end

	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d : ',w,nwin);
		[W(:,:,w),mnsr] = lndetrend(W(:,:,w),FS,lnfreqs);
		fprintf('mnsr =%s\n',sprintf('  %6.4f%%',100*mnsr));
	end

	ppdir = [ppdir sprintf('_lnrem%s',sprintf('_%gHz',lnfreqs))];

end

if olrem % windowed outlier removal

	fprintf('\nRemoving line-noise at %g std. devs., replacement method %d\n',osds,orep);
	if verb > 1, input('RETURN to continue: '); end

	for w = 1:nwin
		fprintf('window %4d of %d : ',w,nwin);
		[W(:,:,w),nouts] = routl(W(:,:,w),osds,orep);
		fprintf('outliers = %6.4f%%\n',100*mean(nouts)/nwobs);
	end

	ppdir = [ppdir sprintf('_olrem_%d_sdevs_%g',orep,osds)];
end

if winds % put data back together again

	fprintf('\nRe-assembling windows\n');
	if verb > 1, input('RETURN to continue: '); end

	novr = nwobs-nsobs; % window overlap
	b = blender((0:(novr-1))/(novr-1)); % the blender
	X = zeros(nchans,nobs);
	X(:,1:nwobs) = W(:,:,1);
	for w = 2:nwin % loop through windows
		fprintf('window %4d of %d ... ',w,nwin);
		o = (w-1)*nsobs; % window offset
		X(:,o+1:o+novr) = (1-b).*X(:,o+1:o+novr) + b.*W(:,1:novr,w); % blend overlap
		X(:,o+novr+1:o+nwobs) = W(:,novr+1:nwobs,w);                 % append remainder
		fprintf('done\n');
	end

end

clear W

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
