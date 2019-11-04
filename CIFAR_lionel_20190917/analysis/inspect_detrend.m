%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Examine effect of polynomial detrend
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schan',     'var'), schan     = [];    end % channel
if ~exist('tseg',      'var'), tseg      = [];    end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false; end % data file too large to read into memory
if ~exist('pford',     'var'), pford     = 8;     end % polynomial fit order
if ~exist('verb',      'var'), verb      = 1;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; dataset = 'freerecall_rest_baseline_1_preprocessed'; ppdir = test; end

[chan,chanstr] = select_channels(BP,subject,dataset,schan,[],1);

[X,ts,fs] = load_EEG(BP,subject,dataset,ppdir,chan,tseg,ds,bigfile,verb);

oldstd  = std(     X,[],2);
oldskew = skewness(X,0, 2);
oldkurt = kurtosis(X,0, 2)-3;

[Y,wflag,Z] = pfdetrend(X,fs,pford);
if wflag, fprintf(2,'WARNING: ''polyfit'' unreliable\n'); end

newstd  = std(     Y,[],2);
newskew = skewness(Y,0, 2);
newkurt = kurtosis(Y,0, 2)-3;

fprintf('\nold std. dev., skew, excess kurtosis :% 7.4f  % 7.4f  % 7.4f\n',  oldstd,oldskew,oldkurt);
fprintf(  'new std. dev., skew, excess kurtosis :% 7.4f  % 7.4f  % 7.4f\n\n',newstd,newskew,newkurt);

if ~isempty(fignum)

	center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(ts',[X;Y;Z]');
	xlabel('time (secs)');
	ylabel('ECoG');
	xlim([ts(1) ts(end)]);
	legend({'original','detrended',sprintf('trend (order = %d)',pford)},'Location', 'northeastoutside','Interpreter','none');

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
