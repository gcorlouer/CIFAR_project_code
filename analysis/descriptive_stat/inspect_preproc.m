%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compare stats between preprocessed and unpreprocessed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schan',     'var'), schan     = [];    end % selected channel
if ~exist('tseg',      'var'), tseg      = [];    end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;     end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false; end % data file too large to read into memory
if ~exist('verb',      'var'), verb      = 1;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BP = true; subject = 'AnRa'; task = 'rest_baseline_1'; ppdir1 = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; ppdir2 = 'nopreproc';

[chan,chanstr] = select_channels(BP,subject,task,schan,[],1);

[X,tsx,fs] = load_EEG(BP,subject,task,ppdir1,chan,tseg,ds,bigfile,1);
[Y,tsy,fs] = load_EEG(BP,subject,task,ppdir2,chan,tseg,ds,bigfile,verb);

% X and/or Y may be truncated, but should have same timestamps up to truncation point

nobs = min(length(tsx),length(tsy));
o = 1:nobs;
X = X(:,o);
Y = Y(:,o);
ts = tsx(o);
assert(maxabs(ts-tsy(o)) < eps,'Time stamps out of kilter (why?)');

oldstd  = std(     X,[],2);
oldskew = skewness(X,0, 2);
oldkurt = kurtosis(X,0, 2)-3;

newstd  = std(     Y,[],2);
newskew = skewness(Y,0, 2);
newkurt = kurtosis(Y,0, 2)-3;

fprintf('\nold std. dev., skew, excess kurtosis : %8.4f  % 8.4f  % 8.4f\n',  oldstd,oldskew,oldkurt);
fprintf(  'new std. dev., skew, excess kurtosis : %8.4f  % 8.4f  % 8.4f\n\n',newstd,newskew,newkurt);


if ~isempty(fignum)
	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(ts',[X;Y]');
	xlabel('time (secs)');
	ylabel('ECoG');
	xlim([ts(1) ts(end)]);
	legend({ppdir1,ppdir2},'Interpreter','none');

	[filepath,filename] = CIFAR_filename(BP,subject,task);
	title(plot_title(filename,[ppdir1 '/' ppdir2],chanstr,mfilename,fs),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
