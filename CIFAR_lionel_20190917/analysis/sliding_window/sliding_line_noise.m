%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inspect line-noise-to-signal ratio per channel (windowed)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = [];       end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false;    end % data file too large to read into memory
if ~exist('wind',      'var'), wind      = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp    = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('lnfreq',    'var'), lnfreq    = 60;       end % line-noise frequency (Hz)
if ~exist('logpow',    'var'), logpow    = true;     end % display log-power
if ~exist('verb',      'var'), verb      = 2;        end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;        end % figure number
if ~exist('figsave',   'var'), figsave   = false;    end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; dataset = 'freerecall_rest_baseline_1_preprocessed'; ppdir = test; end

[chans,chanstr,channames] = select_channels(BP,subject,dataset,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,dataset,ppdir,chans,tseg,ds,bigfile,1);

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window

nsr = nan(nwin,nchans);
for w = 1:nwin
	fprintf('window %4d of %d\n',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	for k = 1:nchans
		x = W(k,:)';
		fln = sinufitf(x,fs,lnfreq);          % fit line-noise frequency precisely
		lnoise = sinufits(x,fs,fln);          % line-noise signal for channel
		nsr(w,k) = var(lnoise)/var(x-lnoise); % line-noise-to-signal power ratio
	end
end

if logpow, nsr = 20*log10(nsr); end

mnsr = mean(nsr)';

if ~isempty(fignum)

	center_fig(fignum,[1280 960]); % create, set size (pixels) and center figure window

	subplot(2,1,1);
	plot(tsw,nsr);
	xlabel('time (secs)');
	if logpow
		ylabel('line-noise log-NSR (dB)');
	else
		ylabel('line-noise NSR');
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
	bar(mnsr);
	xlabel('channel');
	xticks(xtixp); xticklabels(xtix);
	if logpow
		ylabel('mean line-noise log-NSR (dB)');
	else
		ylabel('mean line-noise NSR');
	end

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	sgtitle(plot_title(filename,ppdir,chanstr,mfilename,fs),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
