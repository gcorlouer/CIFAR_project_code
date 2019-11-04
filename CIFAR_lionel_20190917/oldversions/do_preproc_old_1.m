%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pre-process data: highpass filter and line-noise removal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Specify ECoG data set (BP, subject, name), e.g.
%{
BP = false; subject = 'AnRa'; name = 'freerecall_rest_baseline_1_preprocessed';
%}

if ~exist('badchans',  'var'), badchans  = 1;     end % indices of crap channels to NOT preprocess
if ~exist('hpfreq',    'var'), hpfreq    = 1;     end % high-pass filter frequency (Hz)
if ~exist('hpord',     'var'), hpord     = 2;     end % high-pass filter order
if ~exist('lnfreqs',   'var'), lnfreqs   = 60;    end % line-noise frequency (Hz)
if ~exist('osds',      'var'), osds      = [];    end % outlier std. devs.
if ~exist('orep',      'var'), orep      = 1;     end % replace strategy (= 1, 2, 3 - see 'routl.m')
if ~exist('wlen',      'var'), wlen      = 5;     end % length of window (secs)
if ~exist('slen',      'var'), slen      = 0.1;   end % window slide time (secs)
if ~exist('verb',      'var'), verb      = 2;     end % verbosity

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hpfilt = ~isempty(hpfreq);
lnrem  = ~isempty(lnfreqs);
olrem  = ~isempty(osds);
winds  = lnrem | olrem;

assert(hpfilt || lnrem || olrem,'\nYou don''t seem to be doing any preprocessing!\n');

% Load unpreprocessed data

[Y,FS,filepath,filename] = load_nopreproc(BP,subject,name);

FQ = FS/2; % Nyqvist frequency

nallchans = size(Y,1);
goodchans = (1:nallchans)';
goodchans(badchans) = [];

Z             = Y(badchans,:); % the bad  channels
Y(badchans,:) = [];            % the good channels

ppdir = 'preproc';

if hpfilt % high-pass filter

	[fbh,fah] = butter(hpord,hpfreq/FS,'high');
	if ~isstable(  fbh,fah),fprintf(2,'*** WARNING: high-pass filter not stable\n');        end
	if ~isminphase(fbh,fah),fprintf(2,'*** WARNING: high-pass filter not minimum phase\n'); end

	rho = specnorm(-fah(2:end))
	trobs = ceil((-log(eps))/(-log(rho)))
	trlen = trobs/FS

	fprintf('\nHigh-pass filtering at %gHz (order %d Butterworth)\n',hpfreq,hpord);
	if verb > 1, input('\nRETURN to continue: '); end

	Y = filtfilt(fbh,fah,Y')';    % zero-phase filter

	ppdir = [ppdir sprintf('_hipass_%gHz_order_%d',hpfreq,hpord)];

end

[nchans,nobs] = size(Y);

if winds % make sliding windows

	[nwin,dlen,ndobs,wlen,nwobs,slen,nsobs] = sliding(nobs,FS,wlen,slen,[],verb);

	W = zeros(nchans,nwobs,nwin);
	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d ... ',w,nwin);
		o = (w-1)*nsobs;        % window offset
		W(:,:,w) = Y(:,o+1:o+nwobs); % the window
		fprintf('done\n');
	end

	Z = Z(:,1:ndobs);

	ppdir = [ppdir sprintf('_window_%gs_slide_%gs',wlen,slen)];

else

	ndobs = nobs;

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

	lnremstr = sprintf('%gHz, ',lnfreqs);
	fprintf('\nRemoving line-noise at %s\n',lnremstr);
	if verb > 1, input('\nRETURN to continue: '); end

	for w = 1:nwin % loop through windows
		fprintf('window %4d of %d : ',w,nwin);
		lnsr = zeros(nchans,nlnfreqs);
		for k = 2:nchans % chan 1 is crap!
			U = W(k,:,w)';
			for i = 1:nlnfreqs % run through frequencies
				fln = sinufitf(U,FS,lnfreqs(i));    % fit line-noise frequency precisely
				lnoise = sinufits(U,FS,fln);        % line-noise signal for window/channel
				U = U-lnoise;                       % remove line-noise
				lnsr(k,i) = var(lnoise)/var(U);     % line-noise-to-signal ratio
			end
			W(k,:,w) = U';
		end
		fprintf('lnsr =%s\n',sprintf('  %6.4f%%',100*mean(lnsr)));
	end

	lnremstr = sprintf('_%gHz',lnfreqs);
	ppdir = [ppdir sprintf('_lnrem%s',lnremstr)];

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
	Y = zeros(nchans,ndobs);
	Y(:,1:nwobs) = W(:,:,1);
	for w = 2:nwin % loop through windows
		fprintf('window %4d of %d ... ',w,nwin);
		o = (w-1)*nsobs; % window offset
		Y(:,o+1:o+novr) = (1-b).*Y(:,o+1:o+novr) + b.*W(:,1:novr,w); % blend overlap
		Y(:,o+novr+1:o+nwobs) = W(:,novr+1:nwobs,w);                 % append remainder
		fprintf('done\n');
	end

end

X = zeros(nallchans,ndobs);
X(goodchans,:) = Y;
X(badchans, :) = Z;
clear Y Z W U

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
