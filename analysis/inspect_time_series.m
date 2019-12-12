%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate mean and standard deviation over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];    end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = [];    end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [];    end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false; end % data file too large to read into memory
if ~exist('nrm',       'var'), nrm       = 0;     end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('verb',      'var'), verb      = 1;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; dataset = 'freerecall_rest_baseline_1_preprocessed'; ppdir = test; end

[chans,chanstr,channames] = select_channels(BP,subject,dataset,schans,badchans,verb);

[X,ts,fs] = load_EEG(BP,subject,dataset,ppdir,chans,tseg,ds,bigfile,verb);

if nrm > 0,	if nrm > 1, X = demean(X,true); else, X = demean(X,false); end; end

[nchans,nobs] = size(X);

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(ts',X');

	xlabel('time (secs)');
	ylabel('ECoG');
	xlim([ts(1) ts(end)]);
	if nchans <= 40
		legend(channames,'Location','northeastoutside','FontName','Monospaced','Interpreter','none');
	end

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
