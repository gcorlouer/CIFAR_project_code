%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate MI between ROIs, conditional on rest of system, over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans1',   'var'), schans1   = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('schans2',   'var'), schans2   = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = 0;        end % bad channels (empty for none)
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

[chans1,chanstr1] = select_channels(BP,subject,dataset,schans1,badchans,1);
[chans2,chanstr2] = select_channels(BP,subject,dataset,schans2,badchans,1);

[chans,chanstr,~,ogchans] = select_channels(BP,subject,dataset,[chans1 chans2],badchans,0);

[X,ts,fs] = load_EEG(BP,subject,dataset,ppdir,[chans ogchans],tseg,ds,bigfile,1);

xchans1 = 1:length(chans1);                  % ROI 1 in X
xchans2 = length(chans1)+(1:length(chans2)); % ROI 2 in X

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window

I = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	V = tsdata_to_autocov(W,0);
	I(w) = cov_to_mvmi(V,xchans1,xchans2);
	fprintf('I = % 6.4f\n',I(w));
end

if ~isempty(fignum)

	center_fig(fignum,[1280 640]);  % create, set size (pixels) and center figure window

	plot(tsw,I);
	xlim([ts(1) ts(end)]);
	ylabel('mean conditional MI');
	xlabel('time (secs)');

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	title(plot_title(filename,ppdir,sprintf('%s\n%s',chanstr1,chanstr2),mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end