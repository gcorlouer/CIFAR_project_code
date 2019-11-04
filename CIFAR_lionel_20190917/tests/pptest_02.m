%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('wlen',   'var'), wlen  = 2;     end

if ~exist('sdfac',  'var'), sdfac = 2.0;   end
if ~exist('mpou',   'var'), mpou  = 0.01;  end

gpterm = 'x11';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('reload', 'var'), reload = false; end

if reload
	[EEG,filename,filepath] = load_EEG(false,'AnRa','freerecall_rest_baseline_1_preprocessed');
	XX = EEG.data;
	fs = EEG.srate;
	clear EEG
end

X = XX(schans,:);
[nchans,nobs] = size(X);
t = (0:nobs-1)/fs;

%gpc1 = sprintf('unset key\nset grid\nset xr [%g:%g]\n',t(1),t(end));
%gp_qplot(t',X',[],gpc1,gpterm,[1,2]);

if wlen < 0                      % -(observations in window)
	nwobs  = -wlen               % number of observations in window
else
	nwobs = round(fs*wlen);      % number of observations in window
end
wlen = nwobs/fs;                 % length of window (secs)

nwin = floor(nobs-nwobs)+1; % number of windows
wt = (0:nwin-1)*winc;

wstd = nan(nchans,nwin); % window std. dev.
wpou = nan(nchans,nwin); % window fraction of outliers
gwin = 0;
i = 1;
while i <= nwin
	w = i:(i+nwobs-1);
	W = X(:,w);
	wpou = noutl(W,sdfac)/nwobs;
	if max(wpou) < mpou % got a "good" window
		fprintf('"good" window at observation %d\n',i);
		gwin = gwin+1;
		i = i+nwobs;
	else
		i = i+1;
	end
end
gwin
