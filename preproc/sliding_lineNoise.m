function [nsr, mnsr] = sliding_lineNoise(X, ts, varargin)

defaultFs = 500;
defaultLnfreq = 60 ;
defaultWind = [5 1];
defaultTstamp = 'mid';
defaultVerb = 0;
defaultLogpow = true;
defaultFignum = 1;
defaultFigsave   = false;
p = inputParser;

addRequired(p,'X');
addRequired(p,'ts');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'lnfreq', defaultLnfreq, @isscalar);
addParameter(p, 'wind', defaultWind, @isvector);
addParameter(p, 'tstamp', defaultTstamp, @isscalar);
addParameter(p, 'verb', defaultVerb, @isscalar);
addParameter(p, 'logpow', defaultLogpow, @islogical);
addParameter(p, 'fignum', defaultFignum);
addParameter(p, 'figsave', defaultFigsave, @islogical);

parse(p, X, ts, varargin{:});

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(p.Results.X,p.Results.ts, ...
    p.Results.fs, p.Results.wind, p.Results.tstamp, p.Results.verb);

[nchans,nobs] = size(X);

nsr = nan(nwin,nchans);
for w = 1:nwin
	fprintf('window %4d of %d\n',w,nwin);
	o = (w-1)*nsobs;      % window offset
	W = X(:,o+1:o+nwobs); % the window
	for k = 1:nchans
		x = W(k,:)';
		fln = sinufitf(x, p.Results.fs,p.Results.lnfreq);          % fit line-noise frequency precisely
		lnoise = sinufits(x,p.Results.fs,fln);          % line-noise signal for channel
		nsr(w,k) = var(lnoise)/var(x-lnoise); % line-noise-to-signal power ratio
	end
end

if p.Results.logpow, nsr = 20*log10(nsr); end

mnsr = mean(nsr)';

if ~isempty(p.Results.fignum)

	%center_fig(fignum,[1280 960]); % create, set size (pixels) and center figure window

	subplot(2,1,1);
	plot(tsw,nsr);
	xlabel('time (secs)');
	if p.Results.logpow
		ylabel('line-noise log-NSR (dB)');
	else
		ylabel('line-noise NSR');
	end
	xlim([ts(1) ts(end)]);
	if nchans <= 40
		legend(channames,'Location','northeastoutside','FontName','Monospaced','Interpreter','none');
	end

	nschans = length(schans);
	xtixn = 20; % number of xticks
	xtixi = ceil(nschans/xtixn);
	xtixp = 1:xtixi:nschans;
	xtixn = length(xtixp);
	for i = 1:xtixn, xtix{i} = num2str(schans(xtixp(i))); end

	subplot(2,1,2);
	bar(mnsr);
	xlabel('channel');
	xticks(xtixp); xticklabels(xtix);
	if logpow
		ylabel('mean line-noise log-NSR (dB)');
	else
		ylabel('mean line-noise NSR');
	end

	[filepath,filename] = CIFAR_filename(BP,subject,task);
	sgtitle(plot_title(filename,ppdir,chanstr,mfilename,fs),'Interpreter','none');
	save_fig(mfilename,filename,filepath,p.Results.figsave);

end