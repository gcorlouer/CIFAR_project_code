%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate skew and kurosis over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans    = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans  = [];       end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg      = [];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds        = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile   = false;    end % data file too large to read into memory
if ~exist('wind',      'var'), wind      = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp    = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('sd1',       'var'), sd1       = 3.0;   end % outlier std. dev. 1
if ~exist('sd2',       'var'), sd2       = 4.0;   end % outlier std. dev. 1
if ~exist('verb',      'var'), verb      = 2;     end % verbosity
if ~exist('fignum',    'var'), fignum    = 1;     end % figure number
if ~exist('figsave',   'var'), figsave   = false; end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; dataset = 'freerecall_rest_baseline_1_preprocessed'; ppdir = test; end

[chans,chanstr] = select_channels(BP,subject,dataset,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,dataset,ppdir,chans,tseg,ds,bigfile,1);

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window

s   = zeros(nwin,nchans); smean   = zeros(nwin,1);
k   = zeros(nwin,nchans); kmean   = zeros(nwin,1);
po1 = zeros(nwin,nchans); po1mean = zeros(nwin,1);
po2 = zeros(nwin,nchans); po2mean = zeros(nwin,1);
for w = 1:nwin
	fprintf('window %4d of %d : ',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	s(w,:)   = skewness(W');           smean(w)   = mean(s(w,:));
	k(w,:)   = kurtosis(W')-3;         kmean(w)   = mean(k(w,:));
	po1(w,:) = 100*noutl(W,sd1)/nwobs; po1mean(w) = mean(po1(w,:));
	po2(w,:) = 100*noutl(W,sd2)/nwobs; po2mean(w) = mean(po2(w,:));
	fprintf('skew = % 7.4f, kurtosis = % 7.4f, out1 = %6.4f%%, out2 = %6.4f%%\n',smean(w),kmean(w),po1mean(w),po2mean(w));
end

if ~isempty(fignum)

	center_fig(fignum,[1280 880]); % create, set size (pixels) and center figure window

	subplot(2,1,1);
	yyaxis left
	plot(tsw,smean);
	ylabel('mean skew');
	yyaxis right
	plot(tsw,kmean);
	xlim([ts(1) ts(end)]);
	ylabel('mean excess kurtosis');
	xlabel('time (secs)');

	subplot(2,1,2);
	plot(tsw,[po1mean po2mean]);
	xlim([ts(1) ts(end)]);
	ylabel('outliers (%)');
	xlabel('time (secs)');
	legend({sprintf('at %3.1f std. dev.',sd1),sprintf('at %3.1f std. dev.',sd2)});

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	sgtitle(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
