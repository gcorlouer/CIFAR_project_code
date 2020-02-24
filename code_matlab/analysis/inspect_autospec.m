%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute autocpsd 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];    end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = 0;    end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [];    end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('fres',      'var'), fres      = 1024;  end % frequency resolution
if ~exist('fhi',       'var'), fhi       = 250;   end % highest frequency to display (Hz)
if ~exist('bigfile',   'var'), bigfile   = false; end % data file too large to read into memory
if ~exist('nrm',       'var'), nrm       = 0;     end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('verb',      'var'), verb      = 1;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; task = 'rest_baseline_1'; ppdir = test; end

[chans,chanstr,channames] = select_channels(BP,subject,task,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,verb);

if nrm > 0,	if nrm > 1, X = demean(X,true); else, X = demean(X,false); end; end

[nchans,nobs] = size(X);

[S,f,fres] = tsdata_to_cpsd(X,false,fs,[],[],fres,true,false); % auto-spectra
S = 20*log10(S); % measure power as log-mean across channels (dB)

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(f,S);

	xlabel('frequency (Hz)');
	ylabel('power (dB)');
	xlim([0 fhi]);
	grid on
	if nchans <= 40
		legend(channames,'Location','northeastoutside','FontName','Monospaced','Interpreter','none');
	end

	[filepath,filename] = CIFAR_filename(BP,subject,task);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
