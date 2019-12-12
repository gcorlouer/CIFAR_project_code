%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate mean and standard deviation over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = [];       end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false;    end % data file too large to read into memory
if ~exist('wind',      'var'), wind      = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp    = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('verb',      'var'), verb      = 2;        end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;        end % figure number
if ~exist('figsave',   'var'), figsave   = false;    end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; dataset = 'freerecall_rest_baseline_1_preprocessed'; ppdir = test; end

[chans,chanstr] = select_channels(BP,subject,dataset,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,dataset,ppdir,chans,tseg,ds,bigfile,1);

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window
    
m = zeros(nwin,nchans); mmean = zeros(nwin,1);
s = zeros(nwin,nchans); smean = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	m(w,:) = mean(W'); mmean(w) = mean(m(w,:));
	s(w,:) = std(W');  smean(w) = mean(s(w,:));
	fprintf('mean = % 8.4f, sdev = %7.4f\n',mmean(w),smean(w));
end

if ~isempty(fignum)

	%center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	yyaxis left
	plot(tsw,mmean);
	ylabel('mean mean');
	yyaxis right
	plot(tsw,smean);
	xlim([ts(1) ts(end)]);
	ylabel('mean std. dev.');
	xlabel('time (secs)');

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	title(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
