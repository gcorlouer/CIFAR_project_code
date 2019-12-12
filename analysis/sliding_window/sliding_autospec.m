%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make heatmap of spectrum over a sliding window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('schans',    'var'), schans   = [];       end % selected channels (empty for all good, negative for ROI number)
if ~exist('badchans',  'var'), badchans = [];       end % bad channels (empty for none)
if ~exist('tseg',      'var'), tseg     = [];       end % start/end times (empty for entire time series)
if ~exist('ds',        'var'), ds       = 1;        end % downsample factor
if ~exist('bigfile',   'var'), bigfile  = false;    end % data file too large to read into memory
if ~exist('nrm',       'var'), nrm      = 0;        end % normalise (0 - none, 1 - mean, 2 - mean and variance)
if ~exist('wind',      'var'), wind     = [5 0.1];  end % window width and slide time (secs)
if ~exist('tstamp',    'var'), tstamp   = 'mid';    end % window time stamp: 'start', 'mid', or 'end'
if ~exist('fres',      'var'), fres     = 1024;     end % frequency resolution
if ~exist('fhi',       'var'), fhi      = 100;      end % highest frequency to display (Hz)
if ~exist('ftinc',     'var'), ftinc    = 20;       end % frequency tick increment (Hz)
if ~exist('ttinc',     'var'), ttinc    = 20;       end % time tick increment (secs)
if ~exist('verb',      'var'), verb     = 2;        end % verbosity
if ~exist('fignum',    'var'), fignum   = 1;        end % figure number
if ~exist('figsave',   'var'), figsave  = false;    end % save .fig file(s)?

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if exist('test','var'), BP = false; subject = 'AnRa'; dataset = 'freerecall_rest_baseline_1_preprocessed'; ppdir = test; end

[chans,chanstr] = select_channels(BP,subject,dataset,schans,badchans,1);

[X,ts,fs] = load_EEG(BP,subject,dataset,ppdir,chans,tseg,ds,bigfile,1);

if nrm > 0,	if nrm > 1, X = demean(X,true); else, X = demean(X,false); end; end

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(X,ts,fs,wind,tstamp,verb);

[nchans,nobs] = size(X);

% Slide window

s = zeros(fres+1,nwin);      % mean auto-power across selected channels
for w = 1:nwin               % count windows
	fprintf('window %4d of %d\n',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	S = tsdata_to_cpsd(W,false,fs,[],[],fres,true,false); % auto-spectra
	s(:,w) = mean(20*log10(S),2); % measure power as log-mean across channels (dB)
end

if ~isempty(fignum)

	%center_fig(fignum,[1760,1024]);  % create, set size (pixels) and center figure window

	fq   = fs/2;       % Nyqvist frequency
	ttix = round(ts(1):ttinc:ts(end)); % time ticks (secs)
	ftix = 0:ftinc:fq; % where we want the frequency ticks (Hz)
	ffac = fres/fq;    % convert y-values to frequencies (Hz);

	subplot(1,2,1);
	imagesc(s);
	colormap('jet');
	colorbar;
	xticks(ttix);      xticklabels(num2cell(ttix));
	yticks(ffac*ftix); yticklabels(num2cell(ftix));
	xlim([ts(1) ts(end)]);
	ylim([0 ffac*fhi])
%	caxis(subplot(1,2,1),[-11 120]) % to set colour axis limits
	xlabel('time (secs)');
	ylabel('frequency (Hz)');

	f = (0:fres)*(fq/fres); % frequency scale

	subplot(1,2,2);
	semilogx(f,s);
	xlim([1 0.999*fq]);
	xlabel('frequency (Hz, logscale)');
	ylabel('mean log-autopower (dB)');

	[filepath,filename] = CIFAR_filename(BP,subject,dataset);
	sgtitle(plot_title(filename,ppdir,chanstr,mfilename,fs,wind),'Interpreter','none');
	save_fig(mfilename,filename,filepath,figsave);

end
