%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inspect line-noise-to-signal ratio per channel (windowed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = [];       end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false;    end % data file too large to read into memory
if ~exist('wind',      'var'), wind      = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp    = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('logpow',    'var'), logpow    = true;  end % display log-power
if ~exist('verb',      'var'), verb      = 2;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; task = 'rest_baseline_1'; ppdir = test; end

[chans,chanstr,channames] = select_channels(BP,subject,task,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,1);

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window

sigpow = nan(nwin,nchans);
for w = 1:nwin
	fprintf('window %4d of %d\n',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	sigpow(w,:) = var(W,[],2); % signal variance
end

if logpow, sigpow = 20*log10(sigpow); end

msigpow = mean(sigpow)';

if ~isempty(fignum)

	%center_fig(fignum,[1280 960]);  % create, set size (pixels) and center figure window

	subplot(2,1,1);
	plot(tsw,sigpow);
	xlabel('time (secs)');
	if logpow
		ylabel('signal power (dB)');
	else
		ylabel('signal power');
	end
	xlim([ts(1) ts(end)]);
	if nchans <= 40
		legend(channames,'Location','northeastoutside','FontName','Monospaced','Interpreter','none');
	end

	nschans = length(schans);
	xtixn = 20; % number of xticks
	xtixi = ceil(nschans/xtixn);
	xtixp = 1:xtixi:nschans;
	xtixn = length(xtixp);
	for i = 1:xtixn, xtix{i} = num2str(schans(xtixp(i))); end

	subplot(2,1,2);
	bar(msigpow);
	xlabel('channel');
	xticks(xtixp); xticklabels(xtix);
	if logpow
		ylabel('mean signal power (dB)');
	else
		ylabel('mean signal power');
	end

	[filepath,filename] = CIFAR_filename(BP,subject,task);
	sgtitle(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
