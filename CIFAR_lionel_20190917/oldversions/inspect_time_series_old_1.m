%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate mean and standard deviation over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];    end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = [];    end % bad channels (empty for none)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('nrm',       'var'), nrm       = 0;     end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('tseg',      'var'), tseg      = [];    end % start/end time  (empty for entire time series)
if ~exist('verb',      'var'), verb      = 1;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; name = 'freerecall_rest_baseline_1_preprocessed'; ppdir = test; end

[X,FS,filepath,filename] = load_preproc(BP,subject,name,ppdir);

[schans,chanstr,~,channames] = chan_select(subject,size(X,1),schans,badchans);
fprintf('\nUsing %s\n',chanstr);

[X,fs] = downsample(X(schans,:),ds,FS);

if nrm > 0,	if nrm > 1, X = demean(X,true); else, X = demean(X,false); end; end

[nchans,nobs] = size(X);

[obs,nobs,oseg,t,tlen,tseg] = timeseg(nobs,fs,tseg,verb);

if ~isempty(fignum)

	center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(t,X(:,obs)');

	xlabel('time (secs)');
	ylabel('ECoG');
	xlim(tseg);
	if nchans <= 40
		legend(channames,'Location', 'northeastoutside');
	end

	title(sprintf('%s (%s)\n%s\n%s : sample rate = %gHz\n',filename,ppdir,chanstr,mfilename,fs),'Interpreter','none');

	if figsave, save_fig(mfilename,filename,filepath); end

end
