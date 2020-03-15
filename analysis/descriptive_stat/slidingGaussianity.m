function [smean,kmean,po1mean,po2mean] = slidingGaussianity(X,ts,varargin)

defaultFs = 500;
defaultWind = [5 1];
defaultTstamp = 'mid';
defaultVerb = 0;
defaultFignum = 1;
defaultFigsave   = false;
defaultSd1       = 3.0; % outlier std. dev. 1
defaultSd2       = 4.0; % outlier std. dev. 2

p = inputParser;

addRequired(p,'X');
addRequired(p,'ts');
addParameter(p, 'fs', defaultFs, @isscalar);
addParameter(p, 'wind', defaultWind, @isvector);
addParameter(p, 'tstamp', defaultTstamp, @isscalar);
addParameter(p, 'verb', defaultVerb, @isscalar);
addParameter(p, 'fignum', defaultFignum);
addParameter(p, 'figsave', defaultFigsave, @islogical);
addParameter(p, 'sd1', defaultSd1, @isscalar);
addParameter(p, 'sd2', defaultSd2, @isscalar);

parse(p, X, ts, varargin{:});

[X,ts,nwin,nwobs,nsobs,tsw,wind] = sliding(p.Results.X,p.Results.ts, ...
    p.Results.fs, p.Results.wind, p.Results.tstamp, p.Results.verb);

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
	po1(w,:) = 100*noutl(W,p.Results.sd1)/nwobs; po1mean(w) = mean(po1(w,:));
	po2(w,:) = 100*noutl(W,p.Results.sd2)/nwobs; po2mean(w) = mean(po2(w,:));
	fprintf('skew = % 7.4f, kurtosis = % 7.4f, out1 = %6.4f%%, out2 = %6.4f%%\n',smean(w),kmean(w),po1mean(w),po2mean(w));
end

if ~isempty(p.Results.fignum)

	%center_fig(fignum,[1280 880]); % create, set size (pixels) and center figure window

	subplot(2,1,1);
	yyaxis left
	plot(tsw,smean);
	ylabel('mean skew');
	yyaxis right
	plot(tsw,kmean);
	xlim([tsw(1) tsw(end)]);
	ylabel('mean excess kurtosis');
	xlabel('time (secs)');

	subplot(2,1,2);
	plot(tsw,[po1mean po2mean]);
	xlim([tsw(1) tsw(end)]);
	ylabel('outliers (%)');
	xlabel('time (secs)');
	legend({sprintf('at %3.1f std. dev.',p.Results.sd1),sprintf('at %3.1f std. dev.',p.Results.sd2)});

end