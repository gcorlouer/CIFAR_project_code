%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Construct mult-trial "good" data on the basis of fewest outliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('wlen',   'var'), wlen  = 2;     end

if ~exist('oudev',  'var'), oudev = 2.5;   end
if ~exist('oumad',  'var'), oumad = false; end
if ~exist('mpou',   'var'), mpou  = 0.01;  end

gpterm = 'x11';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('xloaded','var') || ~xloaded
	[EEG,filename,filepath] = load_EEG(false,'AnRa','freerecall_rest_baseline_1_preprocessed');
	XX = EEG.data;
	fs = EEG.srate;
	clear EEG
	xloaded = true;
end

X = XX(schans,:);
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

i = 1;
c = 0;
Y = [];
while i < nwin
	w = i:(i+nwobs-1);
	W = X(:,w);
	if oumad
		wpou = noutl_m(W,oudev)/nwobs;
	else
		wpou = noutl(W,oudev)/nwobs;
	end
%[max(wpou) mean(wpou) mpou]
	if mean(wpou) < mpou % got a "good" window
		c = c+1;
		fprintf('"good" window %2d at %d\n',c,i);
		Y(:,:,c) = W;
		i = i+nwobs;
	else
		i = i+1;
	end
end
