%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identify channels with the highest number of potential "good" windows
% on the basis of fewest outliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('wlen',   'var'), wlen  = 2;     end

if ~exist('oudev',  'var'), oudev = 2.5;   end
if ~exist('oumad',  'var'), oumad = false; end
if ~exist('mpou',   'var'), mpou  = 0.01;  end

gpterm = 'x11';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('xloaded','var') || ~xloaded
	[EEG,filename,filepath] = load_EEG(false,'AnRa','freerecall_rest_baseline_1_preprocessed');
	XX = double(EEG.data);
	fs = EEG.srate;
	clear EEG

	hipass = true;
	if hipass
		fhi  = 2;
		ford = 2;
		fprintf('High-pass filtering at %gHz ... ',fhi);
		[b,a] = butter(ford,fhi/fs,  'high');
		assert(isstable(  b,a),'high-pass filter not stable');
		assert(isminphase(b,a),'high-pass filter not minimum phase');
		for k = 1:size(XX,1);
			XX(k,:) = filtfilt(b,a,XX(k,:)')';
		end
		clear a b
		fprintf('done\n\n');
	end

	xloaded = true;
end

X = XX;
[nchans,nobs] = size(X);
t = (0:nobs-1)'/fs;
badchan = false(nchans,1);
badchan(1)   = true;
badchan(128) = true;

%gpc1 = sprintf('unset key\nset grid\nset xr [%g:%g]\n',t(1),t(end));
%gp_qplot(t',X',[],gpc1,gpterm,[1,2]);

if wlen < 0                      % -(observations in window)
	nwobs  = -wlen               % number of observations in window
else
	nwobs = round(fs*wlen);      % number of observations in window
end
wlen = nwobs/fs;                 % length of window (secs)
nwin = floor(nobs-nwobs)+1;      % number of windows

gwin = zeros(nchans,1);

parfor k = 1:nchans % need JVM!
%for k = 1:nchans
	if badchan(k), continue; end
	for i = 1:nwin
		w = i:(i+nwobs-1);
		W = X(k,w);
		if oumad
			wpou = noutl_m(W,oudev)/nwobs;
		else
			wpou = noutl(W,oudev)/nwobs
		end
		if wpou < mpou % got a "good" window
			gwin(k) = gwin(k)+1;
		end
	end
	fprintf('channel %2d of %2d : "good" windows = %d\n',k,nchans,gwin(k));
end

[gwin,gwidx] = sort(gwin);
