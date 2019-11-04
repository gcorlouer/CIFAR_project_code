%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Identify channels with the highest number of potential "good" windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('wlen',   'var'), wlen  = 2;     end
if ~exist('winc',   'var'), winc  = 0.1;   end
if ~exist('sdfac',  'var'), sdfac = 2.0;   end

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

gpc1 = sprintf('unset key\nset grid\nset xr [%g:%g]\n',t(1),t(end));
gp_qplot(t',X',[],gpc1,gpterm,[1,2]);

if wlen < 0                      % -(observations in window)
	nwobs  = -wlen               % number of observations in window
else
	nwobs = round(fs*wlen);      % number of observations in window
end
wlen = nwobs/fs;                 % length of window (secs)

if winc < eps && winc > -eps     % set to window length
	nwsli = nwobs;               % number of observations to slide
else
	if winc < 0                  % -(observations to slide)
		nwsli = -winc;           % number of observations to slide
	else
		nwsli = round(fs*winc);  % number of observations to slide
	end
end
winc = nwsli/fs;                 % length of slide (secs)

nwin = floor((nobs-nwobs)/nwsli)+1; % number of windows
wt = (0:nwin-1)*winc;

wstd = nan(nchans,nwin); % window std. dev.
wpou = nan(nchans,nwin); % window fraction of outliers
for i = 1:nwin
	w = ((i-1)*nwsli+1):((i-1)*nwsli+nwobs);
	W = X(:,w);
	wstd(:,i) = std(W,[],2);
	wpou(:,i) = noutl(W,sdfac)/nwobs;
end

gpc2 = sprintf('unset key\nset grid\nset xr [%g:%g]\n',t(1),t(end));
gp_qplot(wt',wstd',[],gpc2,gpterm,[1,2]);

gpc3 = sprintf('unset key\nset grid\nset xr [%g:%g]\n',t(1),t(end));
gp_qplot(wt',wpou',[],gpc3,gpterm,[1,2]);
