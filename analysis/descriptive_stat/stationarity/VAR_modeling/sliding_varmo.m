%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate AR model orders over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = 0;      end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = 0 ;      end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [10 30];      end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;       end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false;   end % data file too large to read into memory
if ~exist('wind',      'var'), wind      = [5 1]; end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp    = 'mid';   end % window time stamp: 'start', 'mid', or 'end'
if ~exist('maxmo',     'var'), maxmo     = 15;      end % maximum AR model order
if ~exist('moregmode', 'var'), moregmode = 'LWR';   end % AR model order regression mode
if ~exist('ylims',     'var'), ylims     = [1 9];   end % y-axis limits
if ~exist('verb',      'var'), verb      = 2;       end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;       end % figure number
if ~exist('figsave',   'var'), figsave   = false;   end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BP = true; subject = 'AnRa'; task = 'rest_baseline_1'; ppdir = 'preproc_ptrem_8_w5s0.1_lnrem_60Hz_180Hz_w5s0.1'; %preproc directory


[chans,chanstr] = select_channels(BP,subject,task,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,task,ppdir,chans,tseg,ds,bigfile,1);

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window

moest = zeros(nwin,4);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs; % window offset
	W = X(:,o+1:o+nwobs);  % the window
	[moest(w,1),moest(w,2),moest(w,3),moest(w,4)] = tsdata_to_varmo(W,maxmo,moregmode);
	fprintf('AIC = %2d, BIC = %2d, HQC = %2d, LRT = %2d\n',moest(w,1),moest(w,2),moest(w,3),moest(w,4));
end

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(tsw,moest);
	xlim([ts(1) ts(end)]);
	xlabel('time (secs)');
	ylabel('VAR model order');
	legend({'AIC','BIC','HQC','LRT'});

	[filepath,filename] = CIFAR_filename(BP,subject,task);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
